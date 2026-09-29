--[[
	Net.luau
	Centraliza todos os remotes do jogo. O servidor cria, o cliente espera.
	Nomes ficam em uma lista única para evitar erro de digitação entre os lados.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Net = {}

Net.FolderName = "Remotes"

-- Eventos (fire-and-forget)
Net.Events = {
	-- Lobby / Party
	"PartyCreate",
	"PartyJoin",
	"PartyLeave",
	"PartyKick",
	"PartySetPrivacy",
	"PartyInviteFriend",
	"PartyStartMatch",
	"PartySetEpisode",
	"LobbySelectCharacter",
	"LobbyBuyItem",
	"LobbySetGraphics",
	"LobbyRequestState",

	-- Fluxo de jogo
	"GameVote",
	"GameReady",
	"GameRequestHint",
	"GameInteract",
	"GameDeduce",
	"GameAccuse",
	"GameThrowSnack",
	"GameDistract",
	"GameTrapStep",
	"GameTrapComplete",
	"GameBaitTrap",
	"GameArmTrap",
	"GameSkipCutscene",
	"GameDialogueChoice",
	"GameDialogueAdvance",
	"GameTaunt",
	"GameReport",

	-- Servidor -> Cliente
	"ClientDialogue",
	"ClientDialogueEnd",
	"ClientNotify",
	"ClientEvidence",
	"ClientObjectives",
	"ClientHud",
	"ClientParty",
	"ClientLobby",
	"ClientCutscene",
	"ClientCutsceneEnd",
	"ClientChase",
	"ClientResult",
	"ClientEffects",
	"ClientSfx",
	"ClientChapterStart",
	"ClientUnlock",
	"ClientMinimap",
	"ClientMarker",
	"ClientVote",
}

-- Funções remotas (request/response)
Net.Functions = {
	"GetLobbyState",
	"GetEvidence",
	"GetParty",
	"ValidateTrapStep",
}

local function getFolder()
	local folder = ReplicatedStorage:FindFirstChild(Net.FolderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = Net.FolderName
		folder.Parent = ReplicatedStorage
	end
	return folder
end

function Net.bootstrap()
	local folder = getFolder()
	for _, name in ipairs(Net.Events) do
		if not folder:FindFirstChild(name) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
	end
	for _, name in ipairs(Net.Functions) do
		if not folder:FindFirstChild(name) then
			local remote = Instance.new("RemoteFunction")
			remote.Name = name
			remote.Parent = folder
		end
	end
	return folder
end

function Net.Event(name)
	local folder = getFolder()
	if RunService:IsServer() then
		local remote = folder:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
		return remote
	end
	return folder:WaitForChild(name, 30)
end

function Net.Function(name)
	local folder = getFolder()
	if RunService:IsServer() then
		local remote = folder:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteFunction")
			remote.Name = name
			remote.Parent = folder
		end
		return remote
	end
	return folder:WaitForChild(name, 30)
end

function Net.fireClient(player, name, ...)
	local remote = Net.Event(name)
	if remote then
		remote:FireClient(player, ...)
	end
end

function Net.fireAll(name, ...)
	local remote = Net.Event(name)
	if remote then
		remote:FireAllClients(...)
	end
end

function Net.fireServer(name, ...)
	local remote = Net.Event(name)
	if remote then
		remote:FireServer(...)
	end
end

function Net.invokeServer(name, ...)
	local remote = Net.Function(name)
	if remote then
		return remote:InvokeServer(...)
	end
	return nil
end

return Net
