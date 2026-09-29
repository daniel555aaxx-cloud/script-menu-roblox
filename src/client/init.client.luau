--[[
	init.client.luau
	Ponto de entrada do cliente. Liga todos os controllers e liga os remotes
	que o servidor dispara.

	Ordem: HUD -> diálogo -> cutscene -> efeitos -> lobby -> input
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)
local Config = require(Shared.Config)
local Graphics = require(Shared.Graphics)

local player = Players.LocalPlayer

local Controllers = script.Parent.Controllers
local HudController = require(Controllers.HudController)
local DialogueController = require(Controllers.DialogueController)
local CutsceneController = require(Controllers.CutsceneController)
local EffectsController = require(Controllers.EffectsController)
local LobbyController = require(Controllers.LobbyController)
local InputController = require(Controllers.InputController)

local clientStart = os.clock()

-- gráficos: aplica o preset escolhido (o jogador pode trocar com F10 no chat)
Graphics.applyClientPreset(player, player:GetAttribute("GraphicsPreset") or "Alto")

HudController.start()
DialogueController.start()
CutsceneController.start()
EffectsController.start()
LobbyController.start()
InputController.start()

-- ==========================================================
-- EVENTOS DO SERVIDOR -> HUD
-- ==========================================================
Net.Event("ClientObjectives").OnClientEvent:Connect(function(payload)
	HudController.setObjectives(payload)
end)

Net.Event("ClientHud").OnClientEvent:Connect(function(payload)
	HudController.setHud(payload)
end)

Net.Event("ClientEvidence").OnClientEvent:Connect(function(payload)
	HudController.setEvidence(payload)
	HudController.toggleEvidence()
end)

Net.Event("ClientNotify").OnClientEvent:Connect(function(payload)
	HudController.notify(payload)
	if payload.sound then
		EffectsController.playSfx({ sound = payload.sound, volume = 0.45 })
	end
end)

Net.Event("ClientResult").OnClientEvent:Connect(function(payload)
	HudController.showResult(payload)
end)

Net.Event("ClientUnlock").OnClientEvent:Connect(function(payload)
	HudController.showUnlock(payload)
end)

Net.Event("ClientChase").OnClientEvent:Connect(function(payload)
	HudController.setChasing(payload.chasing == true, payload.monster)
	if payload.caught then
		HudController.notify({
			title = "Você foi pego!",
			text = "Respire fundo — o Fred já tem um plano novo.",
			kind = "danger",
			sound = "Hit",
		})
	end
end)

Net.Event("ClientEffects").OnClientEvent:Connect(function(payload)
	if payload and payload.mood then
		Graphics.applyMood(payload.mood)
	end
end)

Net.Event("ClientChapterStart").OnClientEvent:Connect(function(payload)
	HudController.notify({
		title = payload.name or "Capítulo iniciado",
		text = payload.brief or "",
		kind = "info",
		duration = 8,
	})
end)

Net.Event("ClientMarker").OnClientEvent:Connect(function(payload)
	if payload and payload.highlight then
		HudController.notify({
			title = "Pista revelada",
			text = "A Velma marcou uma pista no seu mapa.",
			kind = "hint",
		})
	end
end)

-- ==========================================================
-- RELÓGIO DO CAPÍTULO (sincronizado pelo servidor via ClientChapterStart)
-- ==========================================================
task.spawn(function()
	while true do
		task.wait(1)
		local chapterId = player:GetAttribute("ChapterId")
		if chapterId then
			local Episodes = require(Shared.Data.Episodes)
			local chapter = Episodes.getChapter(chapterId)
			if chapter then
				local elapsed = os.time() - (player:GetAttribute("ChapterStartTime") or os.time())
				HudController.setClock((chapter.timeLimit or Config.Match.CHAPTER_TIME_LIMIT) - elapsed)
			end
		end
	end
end)

print(
	("[Mistério S.A.] Cliente pronto em %.2fs — %s v%s"):format(
		os.clock() - clientStart,
		Config.GAME_NAME,
		Config.VERSION
	)
)
