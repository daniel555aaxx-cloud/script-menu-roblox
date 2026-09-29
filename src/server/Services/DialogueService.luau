--[[
	DialogueService.luau
	NPCs com fala + motor de diálogo.

	* Spawna os NPCs do capítulo nas suas salas (homeRoom) usando Cast.Npcs.
	* Cria um ProximityPrompt "Conversar" em cada NPC.
	* Dirige uma sessão de diálogo por jogador: envia o nó atual, recebe a
	  escolha (GameDialogueChoice) e aplica os efeitos:
			effect.clue      -> registra pista no quadro
			effect.points    -> pontua
			effect.flag      -> marca flag no personagem
			effect.objective -> completa objetivo (via MatchService)
			effect.reveal    -> marca que o NPC pode ser acusado
			onEnd            -> aplicado ao terminar a árvore
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Cast = require(Shared.Data.Cast)
local Dialogue = require(Shared.Data.Dialogue)
local Episodes = require(Shared.Data.Episodes)
local Locations = require(Shared.Data.Locations)
local Net = require(Shared.Net)
local Signal = require(Shared.Signal)

local Builders = script.Parent.Parent.Builders
local CharacterBuilder = require(Builders.CharacterBuilder)
local PartKit = require(Builders.PartKit)

local Services = script.Parent
local ProfileService = require(Services.ProfileService)

local DialogueService = {}

DialogueService.SessionStarted = Signal.new()
DialogueService.SessionEnded = Signal.new()
DialogueService.EffectApplied = Signal.new()

local spawnedNpcs = {} -- chapterId -> { [npcId] = { model, joints, npc, prompt } }
local sessions = {} -- player -> { treeId, nodeId, npcId, chapterId, lastNode }

-- ganchos preenchidos pelo MatchService (evita dependência circular)
local hooks = {
	onObjective = nil,
	onPoints = nil,
	onReveal = nil,
}

function DialogueService.setHooks(newHooks)
	for key, value in pairs(newHooks) do
		hooks[key] = value
	end
end

-- ==========================================================
-- SPAWN DOS NPCs
-- ==========================================================
function DialogueService.despawnChapter(chapterId)
	local list = spawnedNpcs[chapterId]
	if not list then
		return
	end
	for _, entry in pairs(list) do
		if entry.model then
			entry.model:Destroy()
		end
	end
	spawnedNpcs[chapterId] = nil
end

function DialogueService.spawnChapter(chapterId)
	local chapter = Episodes.getChapter(chapterId)
	if not chapter then
		return {}
	end

	DialogueService.despawnChapter(chapterId)

	local folder = workspace:FindFirstChild("MysteryNpcs")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "MysteryNpcs"
		folder.Parent = workspace
	end

	local list = {}
	for _, npcId in ipairs(chapter.npcs or {}) do
		local npc = Cast.getNpc(npcId)
		if npc then
			local model, joints = CharacterBuilder.buildNpc(npcId)
			if model then
				model.Parent = folder

				-- posição: marker do NPC ou centro da sala dele
				local position = Locations.markerPosition(chapter.location, npc.id)
				if not position then
					local room = Locations.getRoom(chapter.location, npc.homeRoom)
					if room then
						position = Locations.roomCenter(Locations.getMap(chapter.location), room)
					end
				end
				if position then
					model:PivotTo(CFrame.new(position.X, position.Y + 3, position.Z))
				else
					warn("[DialogueService] NPC sem lugar: " .. npcId)
					model:Destroy()
					model = nil
				end

				if model then
					-- animação de respiração simples
					task.spawn(function()
						local phase = 0
						while model.Parent do
							phase += 0.05
							local joints2 = { joints.torso, joints.head }
							for _, joint in ipairs(joints2) do
								joint.CFrame = joint.CFrame * CFrame.new(0, math.sin(phase) * 0.03, 0)
							end
							task.wait(0.1)
						end
					end)

					local promptPart = joints.torso
					local prompt = Instance.new("ProximityPrompt")
					prompt.ActionText = "Conversar"
					prompt.ObjectText = npc.name or npcId
					prompt.HoldDuration = 0.3
					prompt.MaxActivationDistance = 14
					prompt.RequiresLineOfSight = false
					prompt.KeyboardKeyCode = Enum.KeyCode.E
					prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
					prompt:SetAttribute("InteractKind", "npc")
					prompt:SetAttribute("NpcId", npcId)
					prompt.Parent = promptPart

					PartKit.billboard(joints.head, npc.name or npcId, {
						width = 220,
						color = "Accent",
						heightOffset = 1.5,
						maxDistance = 80,
					})

					list[npcId] = {
						npc = npc,
						model = model,
						joints = joints,
						prompt = prompt,
						position = position,
					}
				end
			end
		end
	end

	spawnedNpcs[chapterId] = list
	return list
end

function DialogueService.getNpcEntry(npcId)
	for _, list in pairs(spawnedNpcs) do
		if list[npcId] then
			return list[npcId]
		end
	end
	return nil
end

-- ==========================================================
-- SESSÃO DE DIÁLOGO
-- ==========================================================
local function findStartTreeId(npcId)
	local npc = Cast.getNpc(npcId)
	if npc and npc.dialogue then
		return npc.dialogue
	end
	if Dialogue.Nodes[npcId] then
		return npcId
	end
	return nil
end

function DialogueService.start(player, npcId, chapterId)
	local treeId = findStartTreeId(npcId)
	if not treeId then
		return false, "NPC sem diálogo"
	end

	local tree = Dialogue.get(treeId)
	if not tree then
		return false, "árvore de diálogo não encontrada"
	end

	local nodes = tree.nodes or tree
	local startId = tree.start or "n1"
	local firstNode = nodes[startId]
	if not firstNode then
		return false, "nó inicial inválido"
	end

	local entry = DialogueService.getNpcEntry(npcId)
	local npcName = (entry and entry.npc and entry.npc.name) or (tree.title or npcId)

	sessions[player] = {
		treeId = treeId,
		nodeId = startId,
		npcId = npcId,
		chapterId = chapterId,
		title = npcName,
		tree = tree,
	}

	player:SetAttribute("InDialogue", true)

	Net.fireClient(player, "ClientDialogue", {
		action = "start",
		treeId = treeId,
		npcId = npcId,
		title = npcName,
		subtitle = tree.subtitle,
		nodeId = startId,
		text = firstNode.text,
		emote = firstNode.emote,
		sfx = firstNode.sfx,
		choices = firstNode.choices,
		camera = firstNode.camera,
	})

	if firstNode.sfx then
		Net.fireClient(player, "ClientSfx", { sound = firstNode.sfx, volume = 0.4 })
	end

	DialogueService.SessionStarted:Fire(player, npcId, treeId)
	return true
end

local function currentTree(session)
	local tree = session.tree
	return tree.nodes or tree
end

local function buildChoices(node)
	local choices = {}
	for index, choice in ipairs(node.choices or {}) do
		table.insert(choices, {
			index = index,
			text = choice.text,
			role = choice.role,
		})
	end
	return choices
end

local function applyEffect(player, session, effect, source)
	if not effect then
		return
	end

	if effect.clue then
		local ClueService = require(script.Parent.ClueService)
		local ok, clue = ClueService.collect(player, effect.clue, session.chapterId)
		if not ok and clue then
			-- a pista pode existir no quadro como vinda de diálogo
			local Locations2 = require(Shared.Data.Locations)
			Net.fireClient(player, "ClientSfx", { sound = "Ping", volume = 0.3 })
		end
	end

	if effect.objective and hooks.onObjective then
		hooks.onObjective(player, effect.objective, session.chapterId)
	end

	if effect.reveal and hooks.onReveal then
		hooks.onReveal(player, effect.reveal, session.npcId, session.chapterId)
	end

	if effect.flag then
		player:SetAttribute("Flag_" .. effect.flag, true)
	end

	if effect.points and effect.points > 0 then
		if hooks.onPoints then
			hooks.onPoints(player, effect.points, "diálogo")
		else
			ProfileService.addSnacks(player, math.floor(effect.points * 0.1), "diálogo")
		end
	end

	DialogueService.EffectApplied:Fire(player, session.npcId, effect, source)
end

local function sendNode(player, session, nodeId)
	local nodes = currentTree(session)
	local node = nodes[nodeId]
	if not node then
		DialogueService.finish(player, session)
		return
	end

	session.nodeId = nodeId

	Net.fireClient(player, "ClientDialogue", {
		action = "node",
		treeId = session.treeId,
		npcId = session.npcId,
		title = session.title,
		nodeId = nodeId,
		text = node.text,
		emote = node.emote,
		sfx = node.sfx,
		choices = buildChoices(node),
		camera = node.camera,
	})

	if node.sfx then
		Net.fireClient(player, "ClientSfx", { sound = node.sfx, volume = 0.35 })
	end

	-- efeitos automáticos do nó
	applyEffect(player, session, node.effect, "node")

	if #(node.choices or {}) == 0 and not node.next then
		-- fim da conversa
		task.delay(0.2, function()
			DialogueService.finish(player, session, node)
		end)
	end
end

function DialogueService.advance(player)
	local session = sessions[player]
	if not session then
		return false
	end
	local nodes = currentTree(session)
	local node = nodes[session.nodeId]
	if not node then
		DialogueService.finish(player, session)
		return true
	end
	if node.next then
		-- aplica efeitos do nó atual ao avançar
		applyEffect(player, session, node.effect, "advance")
		sendNode(player, session, node.next)
	else
		DialogueService.finish(player, session, node)
	end
	return true
end

function DialogueService.choose(player, choiceIndex)
	local session = sessions[player]
	if not session then
		return false
	end
	local nodes = currentTree(session)
	local node = nodes[session.nodeId]
	if not node or not node.choices then
		return false
	end
	local choice = node.choices[choiceIndex]
	if not choice then
		return false
	end

	-- valida o papel (algumas falas são exclusivas de um personagem)
	local roleId = player:GetAttribute("RoleId")
	if choice.role and roleId and choice.role ~= roleId then
		Net.fireClient(player, "ClientNotify", {
			title = "Fala de " .. choice.role,
			text = "Só o " .. choice.role .. " pode dizer essa linha. Peça para ele responder!",
			kind = "warn",
			sound = "Hit",
		})
		return false
	end

	applyEffect(player, session, choice.effect, "choice")

	if choice.next then
		sendNode(player, session, choice.next)
	else
		DialogueService.finish(player, session, node)
	end
	return true
end

function DialogueService.finish(player, session, lastNode)
	session = session or sessions[player]
	if not session then
		return
	end

	if lastNode and lastNode.onEnd then
		applyEffect(player, session, lastNode.onEnd, "onEnd")
	end
	-- efeitos pendentes do último nó
	local nodes = currentTree(session)
	local node = nodes[session.nodeId]
	if node and node.onEnd and node ~= lastNode then
		applyEffect(player, session, node.onEnd, "onEnd")
	end

	Net.fireClient(player, "ClientDialogueEnd", { treeId = session.treeId, npcId = session.npcId })
	player:SetAttribute("InDialogue", false)

	DialogueService.SessionEnded:Fire(player, session.npcId, session.treeId)
	sessions[player] = nil
end

function DialogueService.getSession(player)
	return sessions[player]
end

function DialogueService.isTalking(player)
	return sessions[player] ~= nil
end

-- ==========================================================
-- INTERAÇÕES DO CLIENTE
-- ==========================================================
function DialogueService.start()
	Net.Event("GameDialogueChoice").OnServerEvent:Connect(function(player, choiceIndex)
		if type(choiceIndex) == "number" then
			DialogueService.choose(player, choiceIndex)
		end
	end)

	Net.Event("GameDialogueAdvance").OnServerEvent:Connect(function(player)
		DialogueService.advance(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		sessions[player] = nil
	end)
end

return DialogueService
