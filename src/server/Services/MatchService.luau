--[[
	MatchService.luau
	O maestro do jogo. Cuida de:

		* LOBBY   -> monta a turma (via PartyService), roda o prólogo e escolhe o episódio
		* CAPÍTULO-> carrega mapa, teleporta, liga pistas/NPCs/monstro, cronometra
		* OBJETIVOS -> controla o progresso (clues, talks, traps, deductions, capture)
		* FIM     -> revelação (tira a máscara), pontuação, próximo capítulo, fim de episódio
		* FINAL   -> temporada concluída

	Todo o fluxo é orientado pelos dados de Episodes.luau — adicionar um capítulo
	novo não exige mexer aqui.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Cast = require(Shared.Data.Cast)
local Dialogue = require(Shared.Data.Dialogue)
local Episodes = require(Shared.Data.Episodes)
local Locations = require(Shared.Data.Locations)
local Net = require(Shared.Net)
local Signal = require(Shared.Signal)
local Util = require(Shared.Util)

local Services = script.Parent
local ProfileService = require(Services.ProfileService)
local MapService = require(Services.MapService)
local PartyService = require(Services.PartyService)
local ClueService = require(Services.ClueService)
local TrapService = require(Services.TrapService)
local DialogueService = require(Services.DialogueService)
local MonsterService = require(Services.MonsterService)
local InteractionService = require(Services.InteractionService)
local AchievementService = require(Services.AchievementService)
local CutsceneService = require(Services.CutsceneService)
local AudioService = require(Services.AudioService)
local CharacterService = require(Services.CharacterService)

local MatchService = {}

MatchService.ChapterStarted = Signal.new()
MatchService.ChapterCompleted = Signal.new()
MatchService.EpisodeCompleted = Signal.new()
MatchService.ObjectiveCompleted = Signal.new()
MatchService.SeasonCompleted = Signal.new()

local PHASE = {
	Lobby = "lobby",
	Intro = "intro",
	Playing = "playing",
	Reveal = "reveal",
	Result = "result",
}

MatchService.Phase = PHASE

-- matches[partyId] = { id, party, episodeId, chapterId, phase, objectives, completed, startedAt, points, ... }
local matches = {}
local playerMatch = {}

local function newMatch(party, episodeId)
	local match = {
		id = Util.makeId("match", 6),
		party = party,
		episodeId = episodeId or "EP01",
		chapterId = nil,
		phase = PHASE.Lobby,
		objectives = {},
		completed = {},
		points = 0,
		stats = { clues = 0, traps = 0, caught = 0, deductions = 0 },
		startedAt = os.time(),
		chapterStartedAt = nil,
		flags = {},
		votes = {},
	}
	matches[match.id] = match
	for _, player in ipairs(party) do
		playerMatch[player] = match
	end
	return match
end

function MatchService.getMatch(player)
	return playerMatch[player]
end

function MatchService.getMatchById(id)
	return matches[id]
end

function MatchService.getMatchPlayers(match)
	local list = {}
	for player in pairs(playerMatch) do
		if playerMatch[player] == match and player.Parent == Players then
			table.insert(list, player)
		end
	end
	return list
end

-- ==========================================================
-- PONTUAÇÃO
-- ==========================================================
function MatchService.addPoints(player, points, reason)
	local match = playerMatch[player]
	if not match then
		-- no lobby ainda vale (prólogo)
		ProfileService.addSnacks(player, math.floor(points * Config.Rewards.COIN_PER_POINT), reason)
		return
	end
	match.points += points
	ProfileService.addStat(player, "totalPoints", points)
	ProfileService.addSnacks(player, math.floor(points * Config.Rewards.COIN_PER_POINT), reason)

	Net.fireClient(player, "ClientHud", {
		points = match.points,
		gain = points,
		reason = reason,
	})
end

-- ==========================================================
-- OBJETIVOS
-- ==========================================================
local function syncObjectives(match)
	local objectives = {}
	for _, objective in ipairs(match.objectives) do
		table.insert(objectives, {
			id = objective.id,
			label = objective.label,
			kind = objective.kind,
			done = match.completed[objective.id] == true,
			marker = objective.marker,
			points = objective.points,
		})
	end
	for _, player in ipairs(MatchService.getMatchPlayers(match)) do
		Net.fireClient(player, "ClientObjectives", {
			chapter = match.chapterId,
			episode = match.episodeId,
			objectives = objectives,
			phase = match.phase,
		})
	end
end

function MatchService.completeObjective(player, objectiveId, silent)
	local match = playerMatch[player]
	if not match or not objectiveId then
		return false
	end
	if match.completed[objectiveId] then
		return false
	end

	local objective = nil
	for _, candidate in ipairs(match.objectives) do
		if candidate.id == objectiveId then
			objective = candidate
			break
		end
	end
	-- objetivos de diálogo referenciam ids de objective declarados no capítulo
	if not objective then
		objective = { id = objectiveId, label = objectiveId, points = 30 }
		table.insert(match.objectives, objective)
	end

	match.completed[objectiveId] = true
	if objective.points and objective.points > 0 then
		MatchService.addPoints(player, objective.points, "objetivo")
	end

	MatchService.ObjectiveCompleted:Fire(match, player, objective)
	syncObjectives(match)

	if not silent then
		Net.fireAll("ClientNotify", {
			title = "Objetivo concluído",
			text = objective.label,
			kind = "success",
			sound = "Ping",
		})
	end

	-- monstro aparece depois do objetivo marcado no capítulo
	local chapter = Episodes.getChapter(match.chapterId)
	if chapter and chapter.monsterIntro and chapter.monsterIntro.objective == objectiveId then
		MonsterService.spawn(match.chapterId, match.episodeId, chapter.location)
		Net.fireAll("ClientNotify", {
			title = "Cuidado!",
			text = chapter.monsterIntro.text,
			kind = "danger",
			sound = "GhostMoan",
		})
	end

	MatchService.checkChapterProgress(match)
	return true
end

-- objetivos podem ser concluídos por qualquer membro; pistas também contam
function MatchService.objectiveFromClue(match, clueId)
	local chapter = Episodes.getChapter(match.chapterId)
	if not chapter then
		return nil
	end
	for _, objective in ipairs(match.objectives) do
		if objective.clue == clueId then
			return objective.id
		end
	end
	return nil
end

function MatchService.objectiveFromMarker(match, markerId)
	for _, objective in ipairs(match.objectives) do
		if objective.marker == markerId then
			return objective.id
		end
	end
	return nil
end

-- ==========================================================
-- DEDUÇÕES
-- ==========================================================
function MatchService.resolveDeduction(player, deductionId, optionIndex)
	local match = playerMatch[player]
	if not match then
		return false, "sem partida"
	end
	local chapter = Episodes.getChapter(match.chapterId)
	if not chapter then
		return false, "sem capítulo"
	end

	local deduction = nil
	for _, entry in ipairs(chapter.deductions or {}) do
		if entry.id == deductionId then
			deduction = entry
			break
		end
	end
	if not deduction then
		return false, "dedução inválida"
	end

	local option = deduction.options and deduction.options[optionIndex]
	if not option then
		return false, "opção inválida"
	end

	if option.correct then
		MatchService.addPoints(player, deduction.points or Config.Rewards.DEDUCTION, "dedução")
		match.stats.deductions += 1
		-- libera os objetivos do tipo deduce que apontam para esta dedução
		for _, objective in ipairs(match.objectives) do
			if objective.kind == "deduce" and (objective.deduction == deductionId or not objective.deduction) then
				if not match.completed[objective.id] then
					MatchService.completeObjective(player, objective.id)
				end
			end
		end
		local correctText = option.feedback or deduction.logic or "A dedução fecha o caso."
		for _, member in ipairs(MatchService.getMatchPlayers(match)) do
			Net.fireClient(member, "ClientNotify", {
				title = "Dedução correta!",
				text = deduction.question .. " — " .. correctText,
				kind = "success",
				sound = "SwitchAlt",
			})
		end
		return true, deduction
	end

	for _, member in ipairs(MatchService.getMatchPlayers(match)) do
		Net.fireClient(member, "ClientNotify", {
			title = "Hipótese errada",
			text = option.feedback or "Essa não é a resposta. Voltem às pistas.",
			kind = "warn",
			sound = "Hit",
		})
	end
	return false, option.feedback or "resposta incorreta"
end

-- ==========================================================
-- INTERAÇÕES GENÉRICAS (objetivos reach/search)
-- ==========================================================
function MatchService.interact(player, markerId)
	local match = playerMatch[player]
	if not match then
		return false
	end
	local objectiveId = MatchService.objectiveFromMarker(match, markerId)
	if objectiveId then
		MatchService.completeObjective(player, objectiveId)
		return true
	end
	-- objetivo do tipo reach sem marker exato: conclui pelo rótulo da sala
	return false
end

-- ==========================================================
-- CICLO DE CAPÍTULO
-- ==========================================================
local chapterTimers = {}

local function stopTimer(match)
	local timer = chapterTimers[match.id]
	if timer then
		timer:Disconnect()
		chapterTimers[match.id] = nil
	end
end

local function startTimer(match, chapter)
	stopTimer(match)
	local limit = chapter.timeLimit or Config.Match.CHAPTER_TIME_LIMIT
	local remaining = limit
	chapterTimers[match.id] = RunService.Heartbeat:Connect(function()
		match.timeAccumulator = (match.timeAccumulator or 0) + 1 / 60
		if match.timeAccumulator >= 1 then
			match.timeAccumulator = 0
			remaining -= 1
			if remaining == 300 or remaining == 120 or remaining == 60 then
				Net.fireAll("ClientNotify", {
					title = "Tempo",
					text = ("Restam %d minutos neste capítulo."):format(math.floor(remaining / 60)),
					kind = "warn",
					sound = "Ping",
				})
			end
			if remaining <= 0 then
				stopTimer(match)
				Net.fireAll("ClientResult", {
					title = "Tempo esgotado",
					text = "O vulto escapou desta vez. O capítulo será reiniciado.",
					kind = "fail",
					chapter = chapter.id,
				})
				task.delay(5, function()
					MatchService.startChapter(match, chapter.id)
				end)
			end
		end
	end)
end

function MatchService.startChapter(match, chapterId)
	local chapter = Episodes.getChapter(chapterId)
	if not chapter then
		warn("[MatchService] capítulo inexistente: " .. tostring(chapterId))
		return
	end

	DialogueService.despawnChapter(match.chapterId or "")
	MonsterService.despawn(match.chapterId or "")
	TrapService.resetChapter(chapterId)
	ClueService.resetChapter(chapterId)

	match.chapterId = chapterId
	match.episodeId = chapter.episode
	match.phase = PHASE.Intro
	match.objectives = {}
	match.completed = {}
	match.points = match.points or 0
	match.chapterStartedAt = os.time()
	match.timeAccumulator = 0

	for _, objective in ipairs(chapter.objectives or {}) do
		table.insert(match.objectives, objective)
	end

	local players = MatchService.getMatchPlayers(match)
	local mapId = chapter.location

	InteractionService.setContext(mapId, chapterId)
	MapService.setMood(mapId)

	-- teleporta a turma para o ponto de spawn do mapa
	for _, player in ipairs(players) do
		player:SetAttribute("ChapterId", chapterId)
		player:SetAttribute("EpisodeId", chapter.episode)
		player:SetAttribute("ChapterStartTime", os.time())
		player:SetAttribute("Caught", false)
		player:SetAttribute("Fear", 0)
		ProfileService.setProgress(player, chapter.episode, chapterId)
		CharacterService.ensureCharacter(player)
		MapService.teleportTo(player, mapId, nil, {})
		ProfileService.addStat(player, "matchesPlayed", 0)
	end

	-- NPCs e atmosfera
	DialogueService.spawnChapter(chapterId)
	AudioService.playForParty(players, "Steady", { mood = chapter.mood or chapter.location })
	InteractionService.refreshMap(mapId, chapterId)

	-- cutscene de abertura (slides do capítulo)
	CutsceneService.playIntro(players, chapter)

	syncObjectives(match)
	MatchService.ChapterStarted:Fire(match, chapter)

	task.delay(Config.Match.INTERMISSION, function()
		if match.phase == PHASE.Intro then
			match.phase = PHASE.Playing
			startTimer(match, chapter)
			syncObjectives(match)
			for _, player in ipairs(MatchService.getMatchPlayers(match)) do
				Net.fireClient(player, "ClientChapterStart", {
					chapter = chapter.id,
					name = chapter.name,
					brief = chapter.brief,
					episode = chapter.episode,
					location = chapter.location,
					locationName = Locations.getMap(mapId).name,
				})
			end
		end
	end)
end

function MatchService.checkChapterProgress(match)
	local chapter = Episodes.getChapter(match.chapterId)
	if not chapter then
		return
	end
	-- todos os objetivos concluídos?
	for _, objective in ipairs(match.objectives) do
		if not match.completed[objective.id] then
			return
		end
	end
	MatchService.finishChapter(match)
end

function MatchService.finishChapter(match)
	if match.phase == PHASE.Reveal or match.phase == PHASE.Result then
		return
	end
	local chapter = Episodes.getChapter(match.chapterId)
	if not chapter then
		return
	end

	stopTimer(match)
	match.phase = PHASE.Reveal
	local players = MatchService.getMatchPlayers(match)

	-- bônus de tempo e de "sem sustos"
	local elapsed = os.time() - (match.chapterStartedAt or os.time())
	local limit = chapter.timeLimit or Config.Match.CHAPTER_TIME_LIMIT
	local speedBonus = math.floor(Config.Rewards.TIME_BONUS_MAX * math.clamp(1 - elapsed / limit, 0, 1))

	for _, player in ipairs(players) do
		ProfileService.completeChapter(player, chapter.episode, chapter.id)
		ProfileService.addStat(player, "totalPoints", 0)
		ProfileService.addSnacks(player, chapter.rewards and chapter.rewards.snacks or 0, "capítulo")
		if speedBonus > 0 then
			MatchService.addPoints(player, speedBonus, "bônus de tempo")
		end
		if match.stats.caught == 0 then
			MatchService.addPoints(player, math.floor(Config.Rewards.NO_CAUGHT_BONUS / 2), "sem sustos")
		end
		-- desbloqueia o próximo capítulo no perfil
		if chapter.nextChapter then
			ProfileService.setProgress(player, chapter.episode, chapter.nextChapter)
		end
	end

	-- revelação: tira a máscara do monstro
	CutsceneService.playReveal(players, chapter)

	MatchService.ChapterCompleted:Fire(match, chapter)

	task.delay(9, function()
		local nextId = chapter.nextChapter
		if nextId and Episodes.getChapter(nextId) then
			MatchService.startChapter(match, nextId)
		else
			MatchService.finishEpisode(match, chapter.episode)
		end
	end)
end

function MatchService.finishEpisode(match, episodeId)
	local episode = Episodes.getEpisode(episodeId)
	local players = MatchService.getMatchPlayers(match)
	match.phase = PHASE.Result

	for _, player in ipairs(players) do
		ProfileService.completeEpisode(player, episodeId)
		MatchService.addPoints(player, Config.Rewards.EPISODE_COMPLETE, "episódio completo")
		AchievementService.checkEpisode(player, episodeId)
		Net.fireClient(player, "ClientResult", {
			title = "Episódio concluído!",
			text = episode and (episode.name .. " — " .. (episode.summary or "")) or "Caso encerrado.",
			kind = "episode",
			points = match.points,
			next = Episodes.Season.order[Util.indexOf(Episodes.Season.order, episodeId) + 1],
		})
	end

	MatchService.EpisodeCompleted:Fire(match, episodeId)

	task.delay(6, function()
		if episodeId == "FINAL" then
			MatchService.finishSeason(match)
		else
			-- volta para o lobby para escolher o próximo caso
			MatchService.returnToLobby(match)
		end
	end)
end

function MatchService.finishSeason(match)
	match.phase = PHASE.Result
	local players = MatchService.getMatchPlayers(match)
	for _, player in ipairs(players) do
		Net.fireClient(player, "ClientResult", {
			title = "TEMPORADA 1 CONCLUÍDA",
			text = "Vocês desmascararam o Colecionador e desmontaram a rede C². Coolsville está em paz.",
			kind = "season",
			points = match.points,
		})
		AchievementService.award(player, "todos_os_cenarios")
	end
	MatchService.SeasonCompleted:Fire(match)
	match.points = 0
end

function MatchService.returnToLobby(match)
	local players = MatchService.getMatchPlayers(match)
	match.phase = PHASE.Lobby
	match.chapterId = nil
	for _, player in ipairs(players) do
		player:SetAttribute("ChapterId", nil)
		CharacterService.ensureCharacter(player)
		MapService.teleportTo(player, "Lobby", "Lobby_Spawn", {})
	end
	PartyService.broadcastParty(match.party)
end

-- ==========================================================
-- ESCAPE DO MONSTRO / CAPTURA
-- ==========================================================
function MatchService.handlePlayerCaught(player)
	local match = playerMatch[player]
	if not match then
		return
	end
	match.stats.caught += 1
	ProfileService.addStat(player, "timesCaught", 1)
	local chapter = Episodes.getChapter(match.chapterId)
	task.delay(Config.Match.RESPAWN_DELAY, function()
		if match.phase == PHASE.Playing and chapter then
			MapService.teleportTo(player, chapter.location, nil, {})
			player:SetAttribute("Caught", false)
			player:SetAttribute("Fear", 0)
		end
	end)
end

-- ==========================================================
-- INÍCIO DE PARTIDA
-- ==========================================================
function MatchService.startMatch(party, episodeId)
	local episode = Episodes.getEpisode(episodeId)
	if not episode then
		episodeId = "EP01"
		episode = Episodes.getEpisode("EP01")
	end

	local match = newMatch(party, episodeId)
	for _, player in ipairs(party) do
		ProfileService.addStat(player, "matchesPlayed", 1)
	end

	Net.fireAll("ClientVote", {
		phase = "starting",
		episode = episodeId,
		episodeName = episode.name,
		chapter = episode.chapters[1],
	})

	-- prólogo na sede se for a primeira partida da turma
	local firstChapter = episode.chapters[1]
	local needsPrologue = not playerMatch[party[1]] or false
	MatchService.startChapter(match, firstChapter)
	return match
end

-- ==========================================================
-- LOBBY: PRÓLOGO E PORTAS
-- ==========================================================
function MatchService.startPrologue(player)
	local match = playerMatch[player] or newMatch({ player }, "EP01")
	playerMatch[player] = match
	match.phase = PHASE.Lobby
	match.chapterId = "PROLOGUE"
	match.objectives = Episodes.Prologue.objectives
	match.completed = {}
	syncObjectives(match)
	return match
end

function MatchService.requestEpisode(player, episodeId)
	local party = PartyService.getPartyOf(player) or { player }
	local leader = party[1]
	if leader ~= player then
		Net.fireClient(player, "ClientNotify", {
			title = "Só o líder",
			text = "Apenas o líder da turma escolhe o caso. Fale com " .. leader.Name .. ".",
			kind = "warn",
			sound = "Hit",
		})
		return false
	end
	return MatchService.startMatch(party, episodeId)
end

-- ==========================================================
-- LIGAÇÕES
-- ==========================================================
function MatchService.callbacks()
	return {
		onObjective = function(player, objectiveId)
			MatchService.completeObjective(player, objectiveId)
		end,
		onPoints = function(player, points, reason)
			MatchService.addPoints(player, points, reason)
		end,
		onReveal = function(player, reveal, npcId, chapterId)
			local match = playerMatch[player]
			if match then
				match.flags["reveal_" .. tostring(reveal)] = npcId
			end
		end,
	}
end

function MatchService.start()
	-- pistas coletadas -> objetivos correspondentes
	ClueService.ClueCollected:Connect(function(player, clue)
		local match = playerMatch[player]
		if not match then
			return
		end
		match.stats.clues += 1
		ProfileService.addStat(player, "cluesFound", 1)
		local objectiveId = MatchService.objectiveFromClue(match, clue.id)
		if objectiveId then
			MatchService.completeObjective(player, objectiveId, true)
		end
		Net.fireAll("ClientNotify", {
			title = "Pista encontrada",
			text = clue.name or clue.id,
			kind = "info",
			sound = "Ping",
		})
	end)

	-- captura do monstro
	TrapService.MonsterCaptured:Connect(function(monsterModel, chapterId)
		local match = playerMatch[monsterModel] -- não usado; mantido por segurança
		for _, candidate in pairs(matches) do
			if candidate.chapterId == chapterId then
				match = candidate
				break
			end
		end
		if not match then
			return
		end
		match.stats.traps += 1
		for _, player in ipairs(MatchService.getMatchPlayers(match)) do
			ProfileService.addStat(player, "trapsSprung", 1)
			MatchService.addPoints(player, Config.Rewards.CAPTURE_MONSTER, "captura")
		end
	end)

	-- jogador pego pelo monstro
	MonsterService.PlayerCaught:Connect(function(player)
		MatchService.handlePlayerCaught(player)
	end)

	-- interações dos prompts
	InteractionService.register("clue", function(player, part, chapterId)
		local markerId = part:GetAttribute("MarkerId") or part:GetAttribute("ClueMarker")
		local ok = ClueService.collect(player, markerId, chapterId)
		return ok
	end)

	InteractionService.register("trap_part", function(player, part, chapterId)
		local markerId = part:GetAttribute("MarkerId")
		local ok = TrapService.collectPart(player, markerId, chapterId)
		local match = playerMatch[player]
		if ok and match then
			local objectiveId = MatchService.objectiveFromMarker(match, markerId)
			if objectiveId then
				MatchService.completeObjective(player, objectiveId, true)
			end
		end
		return ok
	end)

	InteractionService.register("trap", function(player, part, chapterId)
		local spotId = part:GetAttribute("MarkerId")
		local ok, message = TrapService.buildTrap(player, spotId, chapterId)
		if not ok then
			Net.fireClient(
				player,
				"ClientNotify",
				{ title = "Armadilha", text = message, kind = "warn", sound = "Hit" }
			)
			return false
		end
		local match = playerMatch[player]
		if match then
			local objectiveId = MatchService.objectiveFromMarker(match, spotId)
			if objectiveId then
				MatchService.completeObjective(player, objectiveId, true)
			end
		end
		return true
	end)

	InteractionService.register("exit", function(player, part, chapterId)
		local match = playerMatch[player]
		if match and match.phase == PHASE.Reveal then
			MatchService.finishChapter(match)
		end
		return true
	end)

	InteractionService.register("interact", function(player, part, chapterId)
		local markerId = part:GetAttribute("MarkerId")
		return MatchService.interact(player, markerId)
	end)

	InteractionService.register("objective", function(player, part, chapterId)
		local markerId = part:GetAttribute("MarkerId")
		return MatchService.interact(player, markerId)
	end)

	-- remotes de jogo
	Net.Event("GameDeduce").OnServerEvent:Connect(function(player, deductionId, optionIndex)
		if type(deductionId) == "string" and type(optionIndex) == "number" then
			MatchService.resolveDeduction(player, deductionId, optionIndex)
		end
	end)

	Net.Event("GameRequestHint").OnServerEvent:Connect(function(player)
		local match = playerMatch[player]
		if match and match.chapterId then
			ClueService.requestHint(player, match.chapterId)
		end
	end)

	Net.Event("GameTrapComplete").OnServerEvent:Connect(function(player, spotId)
		local match = playerMatch[player]
		if match and match.chapterId then
			TrapService.buildTrap(player, spotId, match.chapterId)
		end
	end)

	Net.Event("GameBaitTrap").OnServerEvent:Connect(function(player, spotId)
		local match = playerMatch[player]
		if match and match.chapterId then
			TrapService.baitTrap(player, spotId, match.chapterId)
		end
	end)

	Net.Event("GameArmTrap").OnServerEvent:Connect(function(player, spotId)
		local match = playerMatch[player]
		if match and match.chapterId then
			TrapService.armTrap(player, spotId, match.chapterId)
		end
	end)

	Net.Event("GameTaunt").OnServerEvent:Connect(function(player)
		MonsterService.lure(player:GetAttribute("ChapterId") or "", 6)
		local line = Dialogue.buildLine("Shaggy", "taunt", Random.new())
		Net.fireAll("ClientDialogue", {
			action = "bark",
			npcId = "Shaggy",
			title = "Salsicha",
			text = line or "Ei, fantasma! Vem cá, se for capaz!",
		})
	end)

	Net.Event("GameReport").OnServerEvent:Connect(function(player, reportType)
		local match = playerMatch[player]
		if not match then
			return
		end
		Net.fireAll("ClientNotify", {
			title = "Denúncia da turma",
			text = ("%s reportou: %s"):format(player.Name, tostring(reportType)),
			kind = "info",
			sound = "Click",
		})
	end)

	Net.Event("GameSkipCutscene").OnServerEvent:Connect(function(player)
		CutsceneService.skip(player)
	end)

	-- jogador sai
	Players.PlayerRemoving:Connect(function(player)
		local match = playerMatch[player]
		playerMatch[player] = nil
		if match then
			local remaining = MatchService.getMatchPlayers(match)
			if #remaining == 0 then
				stopTimer(match)
				MonsterService.despawn(match.chapterId or "")
			end
		end
	end)

	DialogueService.setHooks(MatchService.callbacks())
end

MatchService.PHASE = PHASE

return MatchService
