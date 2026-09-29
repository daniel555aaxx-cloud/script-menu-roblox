--[[
	InteractionService.luau
	Centraliza TODA interação por ProximityPrompt:

		clue       -> ClueService.collect
		trap_part  -> TrapService.collectPart
		trap       -> TrapService.buildTrap
		exit       -> MatchService.requestExit (volta para o lobby / próximo capítulo)
		portal     -> MatchService.requestEpisode (lobby)
		npc        -> DialogueService.start
		interact   -> MatchService.chapterInteract (objetivos "Search"/"Reach")
		shop/roles -> UI do cliente (o servidor só valida)

	O serviço também desliga prompts que não pertencem ao capítulo atual, para
	o jogador não pegar pistas de um episódio que ainda não começou.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)

local InteractionService = {}

local handlers = {}
local contextByMap = {} -- mapId -> chapterId atual (ou nil)

function InteractionService.register(kind, handler)
	handlers[kind] = handler
end

function InteractionService.setContext(mapId, chapterId)
	contextByMap[mapId] = chapterId
end

function InteractionService.getContext(mapId)
	return contextByMap[mapId]
end

function InteractionService.handle(player, part, kind, extra)
	if not part then
		return false
	end
	local mapId = player:GetAttribute("CurrentMap")
	local chapterId = extra and extra.chapterId or (mapId and contextByMap[mapId])
	local handler = handlers[kind]
	if not handler then
		return false
	end
	return handler(player, part, chapterId, extra)
end

-- ==========================================================
-- DISTRIBUIÇÃO DE PROMPTS
-- ==========================================================
-- Percorre os prompts de um mapa e habilita somente os que pertencem ao capítulo.
function InteractionService.refreshMap(mapId, chapterId)
	local mapModel = workspace:FindFirstChild("MysteryMaps")
	if not mapModel then
		return
	end
	local mapFolder = mapModel:FindFirstChild("MAP_" .. mapId)
	if not mapFolder then
		return
	end

	local Locations = require(Shared.Data.Locations)
	local Episodes = require(Shared.Data.Episodes)
	local chapter = chapterId and Episodes.getChapter(chapterId) or nil

	local allowedClues = {}
	if chapter then
		for _, clue in ipairs(chapter.clues or {}) do
			allowedClues[clue.id] = true
			allowedClues[clue.marker or clue.id] = true
		end
	end

	for _, descendant in ipairs(mapFolder:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") then
			local markerPart = descendant.Parent
			local markerKind = markerPart and markerPart:GetAttribute("MarkerKind")
			if markerKind == "clue" then
				local markerId = markerPart:GetAttribute("MarkerId")
				descendant.Enabled = allowedClues[markerId] == true
			elseif markerKind == "exit" or markerKind == "portal" then
				descendant.Enabled = true
			elseif markerKind == "npc" then
				descendant.Enabled = true
			elseif markerKind == "trap" or markerKind == "trap_part" then
				descendant.Enabled = chapter ~= nil
			end
		end
	end
end

function InteractionService.enableMapPrompts(mapId, enabled)
	local mapModel = workspace:FindFirstChild("MysteryMaps")
	if not mapModel then
		return
	end
	local mapFolder = mapModel:FindFirstChild("MAP_" .. mapId)
	if not mapFolder then
		return
	end
	for _, descendant in ipairs(mapFolder:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") then
			local markerKind = descendant.Parent and descendant.Parent:GetAttribute("MarkerKind")
			if markerKind ~= "portal" then
				descendant.Enabled = enabled
			end
		end
	end
end

-- ==========================================================
-- LIGAÇÃO COM O CLIENTE
-- ==========================================================
function InteractionService.start()
	-- O cliente pode pedir a interação "forçada" (quando o prompt do Roblox não
	-- dispara por causa de streaming); o servidor valida a distância.
	Net.Event("GameInteract").OnServerEvent:Connect(function(player, payload)
		if type(payload) ~= "table" then
			return
		end
		local instance = payload.instance
		if typeof(instance) ~= "Instance" or not instance:IsDescendantOf(workspace) then
			return
		end
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		if (root.Position - instance.Position).Magnitude > 32 then
			return
		end
		local kind = instance:GetAttribute("InteractKind")
			or instance.Parent and instance.Parent:GetAttribute("MarkerKind")
			or instance:GetAttribute("MarkerKind")
		InteractionService.handle(player, instance, kind, payload)
	end)
end

return InteractionService
