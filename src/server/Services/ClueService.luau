--[[
	ClueService.luau
	Cuida das pistas: revelar objetos examináveis, validar a coleta, guardar o
	quadro de evidências de cada jogador e resolver a dedução.

	Fluxo:
		interagir com marker de pista -> coleta -> entra no quadro de evidências
		-> quando todas as pistas obrigatórias do capítulo estão no quadro, os
		jogadores podem deduzir -> a dedução libera a fase da armadilha.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Cast = require(Shared.Data.Cast)
local Episodes = require(Shared.Data.Episodes)
local Dialogue = require(Shared.Data.Dialogue)
local Net = require(Shared.Net)
local Signal = require(Shared.Signal)

local Services = script.Parent
local ProfileService = require(Services.ProfileService)
local InteractionService = require(Services.InteractionService)

local ClueService = {}

ClueService.ClueCollected = Signal.new()
ClueService.EvidenceChanged = Signal.new()

-- evidence[player] = { [clueId] = { id, label, text, foundBy, at } }
local evidence = {}
-- collectedByChapter[chapterId] = { [clueId] = true }  (progresso do grupo)
local groupClues = {}

local function ensureEvidence(player)
	local board = evidence[player]
	if not board then
		board = {}
		evidence[player] = board
	end
	return board
end

function ClueService.getEvidence(player)
	return ensureEvidence(player)
end

function ClueService.getGroupClues(chapterId)
	groupClues[chapterId] = groupClues[chapterId] or {}
	return groupClues[chapterId]
end

function ClueService.resetChapter(chapterId)
	groupClues[chapterId] = {}
end

-- ==========================================================
-- COLETA
-- ==========================================================
local function findClueInChapter(chapter, clueId)
	for _, clue in ipairs(chapter.clues or {}) do
		if clue.id == clueId then
			return clue
		end
	end
	return nil
end

function ClueService.collect(player, markerId, chapterId)
	local chapter = Episodes.getChapter(chapterId)
	if not chapter then
		return false, "capítulo inválido"
	end

	local clue = findClueInChapter(chapter, markerId)
	if not clue then
		-- o marker pode ser "EPxx_Cn" com id diferente do marker; tenta pelo marker
		for _, candidate in ipairs(chapter.clues or {}) do
			if candidate.marker == markerId or candidate.id == markerId then
				clue = candidate
				break
			end
		end
	end
	if not clue then
		return false, "pista não pertence a este capítulo"
	end

	local board = ensureEvidence(player)
	if board[clue.id] then
		return false, "pista já coletada"
	end

	board[clue.id] = {
		id = clue.id,
		label = clue.label or clue.id,
		text = clue.text or clue.description or "",
		foundBy = player.Name,
		at = os.time(),
	}
	ClueService.getGroupClues(chapterId)[clue.id] = true

	ClientEvidence(player, chapterId)
	ClueService.ClueCollected:Fire(player, clue, chapterId)

	-- pontos e snacks
	local points = clue.points or Config.Rewards.CLUE
	MatchServiceAddPoints(player, points, "pista")
	if clue.flag then
		player:SetAttribute("Flag_" .. clue.flag, true)
	end

	return true, clue
end

-- evita dependência circular: MatchService se registra aqui
local pointHandler = nil
function ClueService.setPointHandler(handler)
	pointHandler = handler
end

function MatchServiceAddPoints(player, points, reason)
	if pointHandler then
		pointHandler(player, points, reason)
	else
		ProfileService.addSnacks(player, math.floor(points * Config.Rewards.COIN_PER_POINT), reason)
	end
end

function ClueService.readyToDeduce(chapterId)
	local chapter = Episodes.getChapter(chapterId)
	if not chapter then
		return false, 0, 0
	end
	local required = {}
	for _, clue in ipairs(chapter.clues or {}) do
		if clue.required ~= false then
			table.insert(required, clue)
		end
	end
	local found = ClueService.getGroupClues(chapterId)
	local have = 0
	for _, clue in ipairs(required) do
		if found[clue.id] then
			have += 1
		end
	end
	return have >= #required and #required > 0, have, #required
end

function ClueService.progress(chapterId)
	local chapter = Episodes.getChapter(chapterId)
	if not chapter then
		return 0, 0
	end
	local required = 0
	local have = 0
	local found = ClueService.getGroupClues(chapterId)
	for _, clue in ipairs(chapter.clues or {}) do
		if clue.required ~= false then
			required += 1
			if found[clue.id] then
				have += 1
			end
		end
	end
	return have, required
end

-- ==========================================================
-- DEDUÇÃO
-- ==========================================================
function ClueService.deduce(player, chapterId, guess)
	local chapter = Episodes.getChapter(chapterId)
	if not chapter then
		return false, "capítulo inválido"
	end
	local ready, have, required = ClueService.readyToDeduce(chapterId)
	if not ready then
		return false, ("Pistas insuficientes (%d/%d)"):format(have, required)
	end

	-- aceita tanto o id do suspeito quanto o nome
	local expected = chapter.deduction and (chapter.deduction.answer or chapter.deduction.suspectId)
	local accepted = chapter.deduction and chapter.deduction.accepted
	local correct = false
	if expected and guess == expected then
		correct = true
	end
	if not correct and accepted then
		for _, id in ipairs(accepted) do
			if id == guess then
				correct = true
				break
			end
		end
	end

	if correct then
		PlayerSetFlag(player, "deducao_" .. chapterId, guess)
		MatchServiceAddPoints(player, Config.Rewards.DEDUCTION, "dedução")
		Net.fireClient(player, "ClientNotify", {
			title = "Dedução correta!",
			text = (chapter.deduction and chapter.deduction.successText) or "Vocês descobriram o padrão do fantasma.",
			kind = "success",
			sound = "Ping",
		})
		ClueService.EvidenceChanged:Fire(chapterId, "deduced")
	else
		Net.fireClient(player, "ClientNotify", {
			title = "Hipótese errada",
			text = (chapter.deduction and chapter.deduction.failText)
				or "As pistas não fecham com esse nome. Revise o quadro.",
			kind = "warn",
			sound = "Hit",
		})
	end

	return correct, correct and nil or "resposta incorreta"
end

function PlayerSetFlag(player, flag, value)
	player:SetAttribute("Flag_" .. flag, value == nil and true or value)
end

function ClueService.hasFlag(player, flag)
	return player:GetAttribute("Flag_" .. flag) == true or player:GetAttribute("Flag_" .. flag) ~= nil
end

-- ==========================================================
-- DICAS (Velma paga / palpite do grupo)
-- ==========================================================
function ClueService.requestHint(player, chapterId)
	local chapter = Episodes.getChapter(chapterId)
	if not chapter then
		return false
	end
	local board = ensureEvidence(player)
	for _, clue in ipairs(chapter.clues or {}) do
		if not board[clue.id] then
			local ok = ProfileService.spendSnacks(player, Config.Clues.HINT_COST)
			if not ok then
				Net.fireClient(player, "ClientNotify", {
					title = "Sem Scooby Snacks",
					text = "Vocês precisam de " .. Config.Clues.HINT_COST .. " snacks para a Velma apontar o caminho.",
					kind = "warn",
					sound = "Hit",
				})
				return false
			end
			local room = clue.room and require(Shared.Data.Locations).getRoom(chapter.location, clue.room)
			local roomName = room and room.name or clue.room
			Net.fireClient(player, "ClientNotify", {
				title = "Dica da Velma",
				text = ("Jinkies! Procurem %s em %s."):format(
					clue.label or "algo suspeito",
					roomName or "algum lugar do mapa"
				),
				kind = "hint",
				sound = "Ping",
			})
			Net.fireClient(player, "ClientMarker", {
				marker = clue.marker or clue.id,
				kind = "clue",
				highlight = true,
			})
			return true
		end
	end
	Net.fireClient(player, "ClientNotify", {
		title = "Nada a revelar",
		text = "O quadro de evidências já está completo. Hora de deduzir!",
		kind = "info",
		sound = "Ping",
	})
	return false
end

-- ==========================================================
-- SINCRONIZAÇÃO COM O CLIENTE
-- ==========================================================
function ClientEvidence(player, chapterId)
	local board = ensureEvidence(player)
	local list = {}
	for _, entry in pairs(board) do
		table.insert(list, entry)
	end
	table.sort(list, function(a, b)
		return a.id < b.id
	end)
	Net.fireClient(player, "ClientEvidence", {
		chapter = chapterId,
		entries = list,
	})
end

function ClueService.syncAll(player, chapterId)
	ClientEvidence(player, chapterId)
end

-- ==========================================================
-- BANCO DE DICAS (falas do Scooby/Velma quando perto de pista)
-- ==========================================================
function ClueService.start()
	-- A UI pode pedir o resumo do capítulo (progresso de pistas) via função remota
	-- já respondida pelo MatchService; aqui só garantimos que nada fica pendente.
	Net.Event("GameReport").OnServerEvent:Connect(function(player, reportType)
		if reportType == "clues" then
			local match = require(script.Parent.MatchService).getMatch(player)
			if match and match.chapterId then
				local have, required = ClueService.progress(match.chapterId)
				Net.fireClient(player, "ClientHud", { clueProgress = { have = have, required = required } })
			end
		end
	end)
end

function ClueService.proximityWhisper(player, markerId, chapterId)
	local chapter = Episodes.getChapter(chapterId)
	if not chapter then
		return
	end
	local clue = findClueInChapter(chapter, markerId)
	if not clue then
		return
	end
	local line = Dialogue.buildLine(player:GetAttribute("RoleId") or "Velma", "clue", Random.new())
	if line then
		Net.fireClient(player, "ClientSfx", { sound = "Ping", volume = 0.25 })
	end
end

return ClueService
