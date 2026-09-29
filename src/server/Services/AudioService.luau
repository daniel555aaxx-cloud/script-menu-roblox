--[[
	AudioService.luau
	Atmosfera sonora: música de fundo por humor, stingers e sons de assinatura.

	Como o jogo não depende de uploads, tudo usa `rbxasset://` (biblioteca do
	cliente) e as partículas/luzes fazem o trabalho visual. Se você colar IDs em
	Assets.Sounds, eles passam a tocar automaticamente no lugar dos embutidos.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(Shared.Assets)
local Net = require(Shared.Net)

local AudioService = {}

local AMBIENT_TRACKS = {
	Lobby = { id = "LobbyMusic", fallback = "electronicpingshort" },
	Steady = { id = "SuspenseMusic", fallback = "bass" },
	Chase = { id = "ChaseMusic", fallback = "bass" },
	Reveal = { id = "RevealMusic", fallback = "switch3" },
	Episode = { id = "ThemeMusic", fallback = "electronicpingshort" },
}

local ambient = nil

function AudioService.playForParty(players, kind, options)
	local track = AMBIENT_TRACKS[kind] or AMBIENT_TRACKS.Steady
	local soundId = Assets.sound(track.id)
	if not soundId then
		soundId = Assets.Sfx[track.fallback == "bass" and "Bass" or "Ping"]
	end

	for _, player in ipairs(players) do
		Net.fireClient(player, "ClientSfx", {
			sound = soundId,
			volume = kind == "Chase" and 0.5 or 0.3,
			looped = kind == "Steady" or kind == "Lobby",
			channel = "ambient",
			mood = options and options.mood,
		})
	end
end

function AudioService.stinger(players, soundName, volume)
	for _, player in ipairs(players) do
		Net.fireClient(player, "ClientSfx", {
			sound = Assets.sound(soundName) or Assets.Sfx.Ping,
			volume = volume or 0.8,
		})
	end
end

function AudioService.broadcastStinger(soundName, volume)
	Net.fireAll("ClientSfx", {
		sound = Assets.sound(soundName) or Assets.Sfx.Ping,
		volume = volume or 0.8,
	})
end

function AudioService.start()
	-- cria a pasta de som no servidor (opcional, para quem quiser tocar global)
	local folder = SoundService:FindFirstChild("MysteryAudio")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "MysteryAudio"
		folder.Parent = SoundService
	end
end

return AudioService
