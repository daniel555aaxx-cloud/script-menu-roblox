--[[
	TrapService.luau
	Armadilhas em 3 partes (clássico do desenho):

		1. Encontrar as PEÇAS espalhadas pelo mapa  (trap_part markers)
		2. MONTAR a armadilha em um trap spot      (trap markers)
		3. ISCAR o monstro e armar                  (bait + arm)

	O cliente também pode validar cada passo pelo RemoteFunction ValidateTrapStep
	para a UI mostrar o que falta sem trapaça possível (o servidor é a verdade).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Locations = require(Shared.Data.Locations)
local Episodes = require(Shared.Data.Episodes)
local Net = require(Shared.Net)
local Signal = require(Shared.Signal)

local PartKit = require(script.Parent.Parent.Builders.PartKit)

local Services = script.Parent
local ProfileService = require(Services.ProfileService)

local TrapService = {}

TrapService.TrapBuilt = Signal.new()
TrapService.TrapArmed = Signal.new()
TrapService.MonsterCaptured = Signal.new()

-- estado por capítulo
-- traps[chapterId] = { spots = { [spotId] = { built, armed, baited, parts = {}, model } },
--                     collectedParts = { [player] = { [partId] = true } } }
local traps = {}

local function ensureState(chapterId)
	if not traps[chapterId] then
		traps[chapterId] = {
			spots = {},
			collectedParts = {},
			capturedMonster = nil,
		}
	end
	return traps[chapterId]
end

function TrapService.resetChapter(chapterId)
	traps[chapterId] = nil
end

function TrapService.getState(chapterId)
	return ensureState(chapterId)
end

-- ==========================================================
-- PEÇAS
-- ==========================================================
local function chapterTrapParts(chapterId)
	local parts = {}
	local chapter = Episodes.getChapter(chapterId)
	if not chapter then
		return parts
	end
	for _, clue in ipairs(chapter.clues or {}) do
		if clue.trapPart or clue.kind == "trap_part" then
			table.insert(parts, clue)
		end
	end
	return parts
end

function TrapService.collectPart(player, partMarkerId, chapterId)
	local state = ensureState(chapterId)
	state.collectedParts[player] = state.collectedParts[player] or {}

	if state.collectedParts[player][partMarkerId] then
		return false, "peça já coletada"
	end

	local chapter = Episodes.getChapter(chapterId)
	local valid = false
	for _, clue in ipairs(chapter and chapter.clues or {}) do
		if clue.trapPart or clue.kind == "trap_part" then
			if (clue.marker or clue.id) == partMarkerId or clue.id == partMarkerId then
				valid = true
				break
			end
		end
	end
	if not valid and not string.find(tostring(partMarkerId), "Part") then
		-- aceita markers "Trap_Part_A/B/C" declarados no mapa
	end

	state.collectedParts[player][partMarkerId] = true

	-- efeitos visuais: peça "gruda" no personagem
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		local leftover = PartKit.part({
			name = "TrapPart_" .. tostring(partMarkerId),
			size = { 0.8, 0.8, 0.8 },
			color = "Gold",
			material = Enum.Material.Metal,
			canCollide = false,
			canQuery = false,
			parent = character,
		})
		leftover.CFrame = root.CFrame * CFrame.new(0, 1.4, -1)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = leftover
		weld.Parent = leftover
	end

	local count = TrapService.partsHeld(player, chapterId)
	Net.fireClient(player, "ClientNotify", {
		title = "Peça de armadilha",
		text = ("Parte %d de %d encontrada."):format(count, Config.Traps.PARTS_NEEDED),
		kind = "info",
		sound = "Snap",
	})
	ProfileService.addSnacks(player, 5, "peça")
	Net.fireClient(player, "ClientHud", TrapService.hudState(player, chapterId))
	return true
end

function TrapService.partsHeld(player, chapterId)
	local state = ensureState(chapterId)
	local collected = state.collectedParts[player] or {}
	local count = 0
	for _ in pairs(collected) do
		count += 1
	end
	return math.min(count, Config.Traps.PARTS_NEEDED)
end

function TrapService.groupPartsHeld(chapterId, party)
	local best = 0
	for _, member in ipairs(party) do
		local held = TrapService.partsHeld(member, chapterId)
		if held > best then
			best = held
		end
	end
	return best
end

-- ==========================================================
-- MONTAGEM
-- ==========================================================
function TrapService.buildTrap(player, spotId, chapterId)
	local chapter = Episodes.getChapter(chapterId)
	if not chapter then
		return false, "capítulo inválido"
	end

	local held = TrapService.partsHeld(player, chapterId)
	if held < Config.Traps.PARTS_NEEDED then
		return false, ("Faltam peças! Você tem %d de %d."):format(held, Config.Traps.PARTS_NEEDED)
	end

	local state = ensureState(chapterId)
	state.spots[spotId] = state.spots[spotId] or { parts = {}, built = false, armed = false, baited = false }
	local spot = state.spots[spotId]
	if spot.built then
		return false, "armadilha já montada aqui"
	end

	local built = TrapService.spawnTrapModel(chapter, spotId)
	if not built then
		return false, "ponto de armadilha inválido"
	end

	spot.built = true
	spot.model = built

	TrapService.TrapBuilt:Fire(chapterId, spotId, player)
	Net.fireAll("ClientNotify", {
		title = "Armadilha montada!",
		text = ("%s armou o plano em %s. Agora falta a isca."):format(player.Name, spotId),
		kind = "success",
		sound = "Switch",
	})
	TrapService.broadcastHud(chapterId)
	return true, spot
end

function TrapService.spawnTrapModel(chapter, spotId)
	local mapId = chapter.location
	local position = require(Shared.Data.Locations).markerPosition(mapId, spotId)
	if not position and chapter.trapSpots then
		for _, spot in ipairs(chapter.trapSpots) do
			if spot.id == spotId or spot.room == spotId then
				local map = Locations.getMap(mapId)
				local room = Locations.getRoom(map, spot.room or spotId)
				if room then
					position = Locations.roomCenter(map, room)
				end
			end
		end
	end
	if not position then
		return nil
	end

	local folder = workspace:FindFirstChild("MysteryTraps")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "MysteryTraps"
		folder.Parent = workspace
	end

	local model = Instance.new("Model")
	model.Name = "Trap_" .. tostring(spotId)

	local base = PartKit.part({
		name = "Base",
		size = { 10, 0.5, 10 },
		color = "Panel",
		material = "Wood",
		canCollide = false,
		parent = model,
	})
	base.Position = Vector3.new(position.X, position.Y + 0.3, position.Z)

	-- rede suspensa (visual clássico)
	local net = PartKit.part({
		name = "Net",
		size = { 9, 0.4, 12 },
		color = "Scooby",
		material = "Fabric",
		transparency = 0.35,
		canCollide = false,
		parent = model,
	})
	net.Position = Vector3.new(position.X, position.Y + 7, position.Z)

	local rope = PartKit.part({
		name = "Rope",
		size = { 0.4, 7, 0.4 },
		color = "Warning",
		material = "Fabric",
		canCollide = false,
		parent = model,
	})
	rope.Position = Vector3.new(position.X + 4, position.Y + 3.6, position.Z)

	local bait = PartKit.part({
		name = "Bait",
		size = { 1.6, 1.6, 1.6 },
		color = "MysteryOrange",
		material = "Plastic",
		canCollide = false,
		parent = model,
	})
	bait.Position = Vector3.new(position.X, position.Y + 1.4, position.Z)
	bait:SetAttribute("TrapBait", true)

	local spring = PartKit.part({
		name = "Spring",
		size = { 3, 1, 3 },
		color = "Danger",
		material = "Metal",
		canCollide = false,
		canQuery = false,
		parent = model,
	})
	spring.Position = Vector3.new(position.X, position.Y + 0.8, position.Z)

	model:SetAttribute("TrapSpot", spotId)
	model:SetAttribute("Chapter", chapter.id)
	model.PrimaryPart = base
	model.Parent = folder
	return model
end

-- ==========================================================
-- ISCA / ARMAR / CAPTURAR
-- ==========================================================
function TrapService.baitTrap(player, spotId, chapterId)
	local state = ensureState(chapterId)
	local spot = state.spots[spotId]
	if not spot or not spot.built then
		return false, "nenhuma armadilha montada aqui"
	end
	if spot.baited then
		return false, "a isca já está no lugar"
	end

	-- isca com Scooby Snack (custa 10) ou com o próprio Shaggy/Scooby
	local hasSnack = ProfileService.hasItem(player, "snack_basic") or player:GetAttribute("Snacks") ~= nil
	local okSpend = true
	if not hasSnack then
		okSpend = ProfileService.spendSnacks(player, 10)
	end
	if not okSpend then
		return false, "sem isca! Compre Scooby Snacks na van."
	end

	spot.baited = true
	local model = spot.model
	if model then
		local bait = model:FindFirstChild("Bait")
		if bait then
			bait.Color = PartKit.color("Accent")
			PartKit.pointLight(bait, { color = "Accent", brightness = 2, range = 12 })
		end
	end

	local emitterPart = model and model:FindFirstChild("Base")
	if emitterPart then
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "SnackSmell"
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitter.Color = ColorSequence.new(PartKit.color("Accent"))
		emitter.Size = NumberSequence.new(0.7)
		emitter.Lifetime = NumberRange.new(1.6)
		emitter.Rate = 22
		emitter.Speed = NumberRange.new(2.2)
		emitter.SpreadAngle = Vector2.new(30, 30)
		emitter.Parent = emitterPart
	end

	Net.fireClient(player, "ClientNotify", {
		title = "Isca no lugar",
		text = "Agora arme a armadilha antes que o vulto volte.",
		kind = "info",
		sound = "Pop",
	})
	TrapService.broadcastHud(chapterId)
	return true
end

function TrapService.armTrap(player, spotId, chapterId)
	local state = ensureState(chapterId)
	local spot = state.spots[spotId]
	if not spot or not spot.built then
		return false, "monte a armadilha primeiro"
	end
	if not spot.baited then
		return false, "coloque a isca primeiro"
	end
	if spot.armed then
		return false, "a armadilha já está armada"
	end

	spot.armed = true
	spot.armedBy = player
	TrapService.TrapArmed:Fire(chapterId, spotId, player)

	Net.fireAll("ClientNotify", {
		title = "Armadilha armada!",
		text = ("Agora é atrair %s para o ponto %s."):format("o vulto", spotId),
		kind = "success",
		sound = "SwitchAlt",
	})
	TrapService.broadcastHud(chapterId)
	return true, spot
end

-- chamado pelo MonsterService quando o monstro pisa na armadilha armada
function TrapService.tryCapture(monsterModel, chapterId)
	local state = ensureState(chapterId)
	local monsterPosition = monsterModel:GetPivot().Position
	for spotId, spot in pairs(state.spots) do
		if spot.armed and spot.model and spot.model.PrimaryPart then
			local distance = (spot.model.PrimaryPart.Position - monsterPosition).Magnitude
			if distance < 9 then
				spot.captured = true
				state.capturedMonster = chapterId
				spot.model:SetAttribute("Captured", true)

				local base = spot.model:FindFirstChild("Base")
				if base then
					PartKit.highlight(spot.model, "Accent", { fillTransparency = 0.4, outlineTransparency = 0 })
					local sound = PartKit.sound(base, "rbxasset://sounds/switch3.wav", { volume = 0.8 })
					if sound then
						sound:Play()
					end
				end

				TrapService.MonsterCaptured:Fire(monsterModel, chapterId, spotId)
				return true, spotId
			end
		end
	end
	return false
end

function TrapService.isCaptured(chapterId)
	local state = ensureState(chapterId)
	return state.capturedMonster ~= nil
end

-- ==========================================================
-- HUD / FEEDBACK
-- ==========================================================
function TrapService.hudState(player, chapterId)
	local state = ensureState(chapterId)
	local armed = 0
	local built = 0
	for _, spot in pairs(state.spots) do
		if spot.built then
			built += 1
		end
		if spot.armed then
			armed += 1
		end
	end
	return {
		trap = {
			parts = TrapService.partsHeld(player, chapterId),
			partsNeeded = Config.Traps.PARTS_NEEDED,
			built = built,
			armed = armed,
			captured = state.capturedMonster ~= nil,
		},
	}
end

function TrapService.broadcastHud(chapterId)
	local Players = game:GetService("Players")
	local Events = require(ReplicatedStorage:WaitForChild("Shared").Net)
	for _, player in ipairs(Players:GetPlayers()) do
		if player:GetAttribute("ChapterId") == chapterId then
			Events.fireClient(player, "ClientHud", TrapService.hudState(player, chapterId))
		end
	end
end

-- validação consultada pela UI
function TrapService.validateStep(player, chapterId, step, spotId)
	if step == "parts" then
		local mapId = player:GetAttribute("CurrentMap")
		local position = mapId and Locations.markerPosition(mapId, spotId)
		return TrapService.partsHeld(player, chapterId) >= Config.Traps.PARTS_NEEDED,
			("Peças: %d/%d"):format(TrapService.partsHeld(player, chapterId), Config.Traps.PARTS_NEEDED)
	end
	if step == "build" then
		local state = ensureState(chapterId)
		return state.spots[spotId] ~= nil and state.spots[spotId].built, "Montar armadilha"
	end
	if step == "bait" then
		local state = ensureState(chapterId)
		return state.spots[spotId] ~= nil and state.spots[spotId].baited, "Iscar"
	end
	if step == "arm" then
		local state = ensureState(chapterId)
		return state.spots[spotId] ~= nil and state.spots[spotId].armed, "Armar"
	end
	return false, "passo desconhecido"
end

function TrapService.start()
	-- A UI pergunta ao servidor o que falta para armar (nunca confia no cliente).
	Net.Function("ValidateTrapStep").OnServerInvoke = function(player, chapterId, step, spotId)
		if type(chapterId) ~= "string" or type(step) ~= "string" then
			return false, "payload inválido"
		end
		local match = require(script.Parent.MatchService).getMatch(player)
		if not match or match.chapterId ~= chapterId then
			return false, "capítulo não está ativo para você"
		end
		return TrapService.validateStep(player, chapterId, step, spotId)
	end
end

function TrapService.resetPlayer(player, chapterId)
	local state = ensureState(chapterId)
	state.collectedParts[player] = {}
end

return TrapService
