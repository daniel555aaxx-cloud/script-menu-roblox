--[[
	init.server.luau
	Ponto de entrada do servidor. A ordem importa:

		1. Net.bootstrap  -> cria todos os remotes ANTES de qualquer coisa
		2. Serviços base  -> Profile, Map, Character, Party, Achievement, Shop, Audio, Cutscene
		3. Serviços de jogo (Match por último: ele amarra todo mundo)

	O servidor suporta vários "matches" simultâneos: cada turma tem sua própria
	partida, e o lobby é compartilhado.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)
local Config = require(Shared.Config)

-- 1) remotes
Net.bootstrap()

local Services = script.Parent
local ProfileService = require(Services.ProfileService)
local CharacterService = require(Services.CharacterService)
local MapService = require(Services.MapService)
local PartyService = require(Services.PartyService)
local AchievementService = require(Services.AchievementService)
local ShopService = require(Services.ShopService)
local AudioService = require(Services.AudioService)
local CutsceneService = require(Services.CutsceneService)
local DialogueService = require(Services.DialogueService)
local InteractionService = require(Services.InteractionService)
local ClueService = require(Services.ClueService)
local TrapService = require(Services.TrapService)
local MonsterService = require(Services.MonsterService)
local MatchService = require(Services.MatchService)

-- 2) base
ProfileService.start()
CharacterService.start()
MapService.start()
AchievementService.start()
AudioService.start()
CutsceneService.start()
ShopService.start()
DialogueService.start()
ClueService.start()
TrapService.start()
InteractionService.start()
MonsterService.start()
PartyService.start()
MatchService.start()

-- pontuação/acertos do ClueService falam com o MatchService
ClueService.setPointHandler(function(player, points, reason)
	MatchService.addPoints(player, points, reason)
end)

-- 3) lobby inicial: todo mundo na sede, com o prólogo ligado
Players.PlayerAdded:Connect(function(player)
	task.wait(3)
	if not require(Services.PartyService).getPartyOf(player) then
		MatchService.startPrologue(player)
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		task.wait(3)
		if not PartyService.getPartyOf(player) then
			MatchService.startPrologue(player)
		end
	end)
end

-- mensagem de boas-vindas
Players.PlayerAdded:Connect(function(player)
	task.wait(4)
	Net.fireClient(player, "ClientNotify", {
		title = Config.GAME_NAME,
		text = "Bem-vindo! Aperte L para abrir a turma e T para conversar.",
		kind = "info",
		sound = "Button",
	})
end)

print(
	("[Mistério S.A.] Servidor iniciado — %s v%s · %d capítulos"):format(
		Config.GAME_NAME,
		Config.VERSION,
		require(Shared.Data.Episodes).chapterCount()
	)
)
