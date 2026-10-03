-- Central do Caô: jogo cooperativo de atendimento fictício.
-- Todas as decisões, recompensas e estatísticas são validadas no servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local TextService = game:GetService("TextService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))
local World = WorldBuilder.Build()

local DATA_VERSION = 1
local MAX_STAT = 2000000000
local AUTOSAVE_SECONDS = 120
local RANK_REFRESH_SECONDS = 60
local CALL_COOLDOWN_SECONDS = 4
local CALL_IDLE_TIMEOUT_SECONDS = math.clamp(tonumber(Config.CallIdleTimeoutSeconds) or 120, 30, 600)

local profileStore = DataStoreService:GetDataStore("CentralDoCao_PlayerData_v1")
local rankingStore = DataStoreService:GetOrderedDataStore("CentralDoCao_Ranking_v1")

local remotesFolder = ReplicatedStorage:FindFirstChild("OfficeRemotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "OfficeRemotes"
	remotesFolder.Parent = ReplicatedStorage
end

local function getOrCreateRemote(name)
	local remote = remotesFolder:FindFirstChild(name)
	if remote and remote:IsA("RemoteEvent") then
		return remote
	end
	if remote then
		remote:Destroy()
	end
	remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotesFolder
	return remote
end

local actionRemote = getOrCreateRemote("PlayerAction")
local clientRemote = getOrCreateRemote("ClientUpdate")

local sessions = {}
local stationSessions = {}
local actionTimes = {}
local profilesLoaded = {}
local queuedSaves = {}
local callCooldowns = {}
local clientReady = {}
local nameCache = {}
local rankingCache = {}
local rankRefreshRunning = false

local function sendToast(player, message, tone)
	if player and player.Parent == Players then
		clientRemote:FireClient(player, "toast", {
			message = message,
			tone = tone or "info",
		})
	end
end

local function setStationBusy(station, busy)
	if not station then
		return
	end

	local prompt = station.Prompt
	if prompt and prompt.Parent then
		prompt.Enabled = true
		prompt.ActionText = busy and "Estação ocupada" or "Atender ligação"
		prompt.ObjectText = "Estação " .. tostring(station.Index)
	end

	local phone = station.Phone
	if phone and phone.Parent then
		phone:SetAttribute("InUse", busy)
		local indicator = phone.Parent:FindFirstChild("TelefoneDisplay")
		if indicator and indicator:IsA("BasePart") then
			indicator.Color = busy and Color3.fromRGB(242, 133, 108) or Color3.fromRGB(118, 222, 184)
		end
	end
end

local function releaseStation(session)
	local station = session and session.Station
	if station and stationSessions[station] == session then
		stationSessions[station] = nil
		setStationBusy(station, false)
	end
end

local function safeInteger(value, fallback, minimum, maximum)
	local numberValue = tonumber(value)
	if not numberValue then
		return fallback
	end
	return math.clamp(math.floor(numberValue), minimum or 0, maximum or MAX_STAT)
end

local function createLeaderValue(parent, name, value)
	local object = Instance.new("IntValue")
	object.Name = name
	object.Value = value
	object.Parent = parent
	return object
end

local function createLeaderstats(player)
	local old = player:FindFirstChild("leaderstats")
	if old then
		old:Destroy()
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	createLeaderValue(leaderstats, "Dinheiro", Config.StartingMoney)
	createLeaderValue(leaderstats, "TotalGanho", 0)
	createLeaderValue(leaderstats, "Reputacao", Config.StartingReputation)
	createLeaderValue(leaderstats, "Atendimentos", 0)
	player:SetAttribute("DataLoaded", false)
end

local function getStats(player)
	local folder = player:FindFirstChild("leaderstats")
	if not folder then
		return nil
	end
	return {
		Money = folder:FindFirstChild("Dinheiro"),
		TotalEarned = folder:FindFirstChild("TotalGanho"),
		Reputation = folder:FindFirstChild("Reputacao"),
		Calls = folder:FindFirstChild("Atendimentos"),
	}
end

local function statsPayload(player)
	local stats = getStats(player)
	if not stats or not stats.Money then
		return {loading = true}
	end
	return {
		money = stats.Money.Value,
		totalEarned = stats.TotalEarned.Value,
		reputation = stats.Reputation.Value,
		calls = stats.Calls.Value,
		loading = not profilesLoaded[player],
	}
end

local function pushStats(player)
	if player and player.Parent == Players then
		clientRemote:FireClient(player, "stats", statsPayload(player))
	end
end

local function loadPlayer(player)
	createLeaderstats(player)
	local key = "u_" .. tostring(player.UserId)
	local loadedData
	local success, result = pcall(function()
		return profileStore:GetAsync(key)
	end)
	if success and type(result) == "table" then
		loadedData = result
	elseif not success then
		warn("Central do Caô: não foi possível carregar o perfil de " .. player.UserId .. ".")
	end

	if player.Parent ~= Players then
		return
	end

	local stats = getStats(player)
	if loadedData then
		stats.Money.Value = safeInteger(loadedData.Money, Config.StartingMoney, 0, MAX_STAT)
		stats.TotalEarned.Value = safeInteger(loadedData.TotalEarned, stats.Money.Value, 0, MAX_STAT)
		stats.Reputation.Value = safeInteger(loadedData.Reputation, Config.StartingReputation, 0, 1000)
		stats.Calls.Value = safeInteger(loadedData.Calls, 0, 0, MAX_STAT)
		-- Mantém valores coerentes em perfis antigos/incompletos.
		stats.TotalEarned.Value = math.max(stats.TotalEarned.Value, stats.Money.Value)
	end

	profilesLoaded[player] = true
	player:SetAttribute("DataLoaded", true)
	pushStats(player)
end

local function snapshotProfile(player)
	local stats = getStats(player)
	if not stats or not stats.Money or not profilesLoaded[player] then
		return nil
	end
	return {
		Version = DATA_VERSION,
		Money = safeInteger(stats.Money.Value, 0, 0, MAX_STAT),
		TotalEarned = safeInteger(stats.TotalEarned.Value, 0, 0, MAX_STAT),
		Reputation = safeInteger(stats.Reputation.Value, Config.StartingReputation, 0, 1000),
		Calls = safeInteger(stats.Calls.Value, 0, 0, MAX_STAT),
	}
end

local function savePlayer(player)
	local snapshot = snapshotProfile(player)
	if not snapshot then
		return
	end

	local key = "u_" .. tostring(player.UserId)
	local success, err = pcall(function()
		profileStore:UpdateAsync(key, function(oldData)
			oldData = type(oldData) == "table" and oldData or {}
			-- No jogo atual o saldo só aumenta; os máximos evitam que uma sessão
			-- simultânea sobrescreva acidentalmente um valor maior já salvo.
			return {
				Version = DATA_VERSION,
				Money = math.max(safeInteger(oldData.Money, 0, 0, MAX_STAT), snapshot.Money),
				TotalEarned = math.max(safeInteger(oldData.TotalEarned, 0, 0, MAX_STAT), snapshot.TotalEarned),
				Reputation = snapshot.Reputation,
				Calls = math.max(safeInteger(oldData.Calls, 0, 0, MAX_STAT), snapshot.Calls),
			}
		end)
	end)
	if not success then
		warn("Central do Caô: falha ao salvar o perfil de " .. player.UserId .. ": " .. tostring(err))
	end

	local rankSuccess, rankErr = pcall(function()
		rankingStore:UpdateAsync(tostring(player.UserId), function(oldValue)
			return math.max(safeInteger(oldValue, 0, 0, MAX_STAT), snapshot.TotalEarned)
		end)
	end)
	if not rankSuccess then
		warn("Central do Caô: falha ao atualizar o ranking de " .. player.UserId .. ": " .. tostring(rankErr))
	end
end

local function queueSave(player, delaySeconds)
	if queuedSaves[player] then
		return
	end
	queuedSaves[player] = true
	task.delay(delaySeconds or 10, function()
		queuedSaves[player] = nil
		if player.Parent == Players then
			savePlayer(player)
		end
	end)
end

local function playerNameForUserId(userId)
	if nameCache[userId] then
		return nameCache[userId]
	end
	local online = Players:GetPlayerByUserId(userId)
	if online then
		nameCache[userId] = online.Name
		return online.Name
	end
	local success, name = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)
	if success and type(name) == "string" then
		nameCache[userId] = name
		return name
	end
	return "Agente " .. tostring(userId)
end

local function onlineRankingRows()
	local rows = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local stats = getStats(player)
		if stats and stats.TotalEarned then
			table.insert(rows, {
				userId = player.UserId,
				name = player.Name,
				value = stats.TotalEarned.Value,
			})
		end
	end
	return rows
end

local function fetchRankingRows()
	local rowsByUserId = {}
	local success, pages = pcall(function()
		return rankingStore:GetSortedAsync(false, 10)
	end)

	if success and pages then
		local pageSuccess, page = pcall(function()
			return pages:GetCurrentPage()
		end)
		if pageSuccess and type(page) == "table" then
			for _, entry in ipairs(page) do
				local userId = tonumber(entry.key)
				local value = safeInteger(entry.value, 0, 0, MAX_STAT)
				if userId and value > 0 then
					rowsByUserId[userId] = {
						userId = userId,
						name = playerNameForUserId(userId),
						value = value,
					}
				end
			end
		end
	end

	-- Inclui imediatamente quem ainda não chegou ao próximo salvamento periódico.
	for _, row in ipairs(onlineRankingRows()) do
		local previous = rowsByUserId[row.userId]
		if not previous or row.value > previous.value then
			rowsByUserId[row.userId] = row
		end
	end

	local rows = {}
	for _, row in pairs(rowsByUserId) do
		table.insert(rows, row)
	end
	table.sort(rows, function(a, b)
		if a.value == b.value then
			return a.name < b.name
		end
		return a.value > b.value
	end)
	while #rows > 10 do
		table.remove(rows)
	end
	return rows
end

local function rankingText(rows)
	if #rows == 0 then
		return "Ainda sem resultados.\nAtenda sua primeira ligação!"
	end
	local lines = {}
	for index, row in ipairs(rows) do
		table.insert(lines, string.format("%02d   %-16s   %s", index, row.name, tostring(row.value)))
	end
	return table.concat(lines, "\n")
end

local function refreshRanking()
	if rankRefreshRunning then
		return
	end
	rankRefreshRunning = true
	local rows = fetchRankingRows()
	rankingCache = {}
	for _, row in ipairs(rows) do
		table.insert(rankingCache, {
			name = row.name,
			value = row.value,
		})
	end
	if World.RankingRows and World.RankingRows.Parent then
		World.RankingRows.Text = rankingText(rankingCache)
	end
	clientRemote:FireAllClients("ranking", rankingCache)
	rankRefreshRunning = false
end

local function isNearCallStation(player, session)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not session or not session.Phone then
		return false
	end
	return (root.Position - session.Phone.Position).Magnitude <= Config.MaxCallDistance
end

local function containsPhrase(paddedText, phrase)
	return string.find(paddedText, " " .. phrase .. " ", 1, true) ~= nil
end

local accentMap = {
	["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a",
	["é"] = "e", ["ê"] = "e", ["è"] = "e",
	["í"] = "i", ["ì"] = "i", ["î"] = "i",
	["ó"] = "o", ["ô"] = "o", ["õ"] = "o", ["ò"] = "o",
	["ú"] = "u", ["ü"] = "u", ["ù"] = "u",
	["ç"] = "c",
	["Á"] = "A", ["À"] = "A", ["Â"] = "A", ["Ã"] = "A",
	["É"] = "E", ["Ê"] = "E", ["È"] = "E",
	["Í"] = "I", ["Ì"] = "I", ["Î"] = "I",
	["Ó"] = "O", ["Ô"] = "O", ["Õ"] = "O", ["Ò"] = "O",
	["Ú"] = "U", ["Ü"] = "U", ["Ù"] = "U",
	["Ç"] = "C",
}

local function normalizePortuguese(text)
	for accented, plain in pairs(accentMap) do
		text = string.gsub(text, accented, plain)
	end
	text = string.lower(text)
	text = string.gsub(text, "[^%w%s]", " ")
	text = string.gsub(text, "%s+", " ")
	return " " .. text .. " "
end

local function hasAnyPhrase(paddedText, phrases)
	for _, phrase in ipairs(phrases) do
		if containsPhrase(paddedText, phrase) then
			return true
		end
	end
	return false
end

local function containsSensitiveTopic(normalized)
	return hasAnyPhrase(normalized, {
		"cpf", "senha", "cartao", "telefone", "endereco", "email", "e mail",
		"pix", "banco", "documento", "token", "codigo de acesso", "numero do cartao",
	}) or string.find(normalized, "%d%d%d%d") ~= nil
end

local function inferIntent(session, rawText)
	local normalized = normalizePortuguese(rawText)
	if containsSensitiveTopic(normalized) then
		return "safety"
	end

	if hasAnyPhrase(normalized, {"encerrar", "tchau", "quero sair", "nao quero", "nao aceito", "nao vou aceitar", "prefiro nao", "nao obrigado", "nao obrigada", "pode parar", "sair da ligacao"}) then
		return "end"
	end
	if hasAnyPhrase(normalized, {"promessa", "prometer", "prometo", "garantir o impossivel", "garantia impossivel"}) then
		return "promise"
	end
	if hasAnyPhrase(normalized, {"como funciona", "o que e", "qual e", "explica", "explique", "me explica", "por que", "quanto custa", "duvida", "tenho uma pergunta", "quero saber", "fale mais", "conte mais", "detalhes"}) then
		return "ask"
	end
	if hasAnyPhrase(normalized, {"resolver", "resolva", "solucionar", "solucao", "ajudar", "ajuda", "orientar", "consertar", "atender o caso"}) and session.choices.resolve then
		return "resolve"
	end
	if hasAnyPhrase(normalized, {"sim", "aceito", "aceitar", "quero", "fechado", "topo", "pode ser", "compro", "pode registrar"}) then
		if session.choices.accept_offer then
			return "accept_offer"
		end
		if session.choices.offer then
			return "offer"
		end
	end
	if hasAnyPhrase(normalized, {"oferta", "oferecer", "ofereco", "pacote", "comprar", "vender", "manda"}) then
		if session.choices.offer then
			return "offer"
		end
		if session.choices.accept_offer then
			return "ask"
		end
		return "ask"
	end
	if hasAnyPhrase(normalized, {"brincadeira", "ficticio", "imaginario", "so no jogo", "somente no jogo", "moedas do jogo", "nao e real", "nao existe", "sem valor real", "de mentirinha", "nao e de verdade"}) then
		return "explain"
	end
	if normalized == " nao " or normalized == " nao obrigado " or normalized == " nao obrigada " then
		return "end"
	end
	return "unknown"
end

local function choiceList(session, ids)
	local options = {}
	local lookup = {}
	for _, item in ipairs(ids) do
		local option = {
			id = item.id,
			label = item.label,
		}
		table.insert(options, option)
		lookup[item.id] = item.label
	end
	session.choices = lookup
	return options
end

local function sendNpcLine(player, session, text, options)
	clientRemote:FireClient(player, "npcLine", {
		name = session.Customer.Name,
		text = text,
		choices = options,
	})
end

local function currentIntroChoices(session)
	return choiceList(session, {
		{id = "ask", label = "Entender melhor o que aconteceu"},
		{id = "resolve", label = "Resolver o caso com honestidade"},
		{id = "explain", label = "Explicar a brincadeira com clareza"},
		{id = "offer", label = "Apresentar o pacote imaginário"},
		{id = "promise", label = "Fazer uma promessa impossível"},
		{id = "end", label = "Encerrar a ligação"},
	})
end

local function currentPitchChoices(session)
	return choiceList(session, {
		{id = "accept_offer", label = "Concluir a oferta e ouvir a resposta"},
		{id = "ask", label = "Reexplicar a oferta fictícia"},
		{id = "resolve", label = "Resolver o caso sem pressão"},
		{id = "end", label = "Encerrar sem venda"},
	})
end

local function currentResolvedChoices(session)
	return choiceList(session, {
		{id = "offer", label = "Apresentar a oferta fictícia (opcional)"},
		{id = "ask", label = "Revisar a solução do caso"},
		{id = "end", label = "Finalizar atendimento"},
	})
end

local function currentRecoveryChoices(session)
	return choiceList(session, {
		{id = "resolve", label = "Corrigir e resolver o caso honestamente"},
		{id = "explain", label = "Corrigir e explicar que era uma piada"},
		{id = "ask", label = "Responder à dúvida do cliente"},
		{id = "end", label = "Encerrar a ligação"},
	})
end

local function choicesForSession(session)
	if session.stage == "pitch" then
		return currentPitchChoices(session)
	elseif session.stage == "resolved" then
		return currentResolvedChoices(session)
	elseif session.stage == "recovery" then
		return currentRecoveryChoices(session)
	end
	return currentIntroChoices(session)
end

local function finishCall(player, session, finalText, reward)
	if sessions[player] ~= session then
		return
	end

	local stats = getStats(player)
	if stats and stats.Calls then
		stats.Calls.Value = math.min(MAX_STAT, stats.Calls.Value + 1)
	end
	if reward and reward > 0 and stats and stats.Money and stats.TotalEarned then
		stats.Money.Value = math.min(MAX_STAT, stats.Money.Value + reward)
		stats.TotalEarned.Value = math.min(MAX_STAT, stats.TotalEarned.Value + reward)
	end

	releaseStation(session)
	sessions[player] = nil
	callCooldowns[player] = os.clock() + CALL_COOLDOWN_SECONDS
	clientRemote:FireClient(player, "finishCall", {
		name = session.Customer.Name,
		text = finalText,
		reward = reward or 0,
		stats = statsPayload(player),
	})
	queueSave(player, 5)
	pushStats(player)
	task.defer(refreshRanking)
end

local function armCallTimeout(player, session)
	session.TimeoutGeneration = (session.TimeoutGeneration or 0) + 1
	local generation = session.TimeoutGeneration
	session.LastActivityAt = os.clock()
	task.delay(CALL_IDLE_TIMEOUT_SECONDS, function()
		if sessions[player] ~= session or session.TimeoutGeneration ~= generation then
			return
		end

		local reward = session.Resolved and session.ResolutionReward or 0
		local finalText = "A ligação foi encerrada por falta de resposta. Nenhum crédito foi perdido."
		if reward > 0 then
			finalText ..= string.format("\n\nCaso resolvido: +%d Créditos fictícios.", reward)
		end
		finishCall(player, session, finalText, reward)
	end)
end

local function updateReputation(player, amount)
	local stats = getStats(player)
	if not stats or not stats.Reputation then
		return
	end
	stats.Reputation.Value = math.clamp(stats.Reputation.Value + amount, 0, 1000)
	pushStats(player)
end

local function resolvePurchase(player, session, chance, wasTransparent)
	chance = math.clamp(chance, 0.05, 0.85)
	local serviceReward = session.Resolved and session.ResolutionReward or 0
	if math.random() <= chance then
		local reward = session.Quote + serviceReward
		if wasTransparent then
			updateReputation(player, 3)
		end
		local rewardText = string.format("+%d Créditos fictícios!", reward)
		if serviceReward > 0 then
			rewardText = string.format("+%d Créditos pelo pacote e %d pela solução do caso!", session.Quote, serviceReward)
		end
		local text = string.format(
			"%s: Fechado! Entendi que a oferta era uma brincadeira e só vale neste jogo.\n\n%s",
			session.Customer.Name,
			rewardText
		)
		finishCall(player, session, text, reward)
	else
		local rewardText = serviceReward > 0 and string.format("O atendimento foi resolvido: +%d Créditos fictícios.", serviceReward) or "Nenhum crédito foi perdido."
		local text = string.format(
			"%s: Obrigado por explicar. Vou deixar o pacote passar desta vez.\n\n%s\nLigação encerrada.",
			session.Customer.Name,
			rewardText
		)
		finishCall(player, session, text, serviceReward)
	end
end

local function handleChoice(player, choiceId)
	local session = sessions[player]
	if not session then
		sendToast(player, "Atenda uma estação para iniciar uma nova ligação.", "warning")
		return
	end
	if choiceId == "end" then
		local reward = session.Resolved and session.ResolutionReward or 0
		local finalText = session.Customer.Name .. ": Obrigado pela conversa. Até mais!\n\nLigação encerrada sem custo."
		if reward > 0 then
			finalText = string.format("%s: Obrigado por resolver meu caso com transparência.\n\nAtendimento concluído: +%d Créditos fictícios.", session.Customer.Name, reward)
		end
		finishCall(player, session, finalText, reward)
		return
	end
	if not session.choices[choiceId] then
		return
	end
	armCallTimeout(player, session)

	if choiceId == "ask" then
		local text
		if session.stage == "pitch" then
			text = string.format("A oferta é para %s. Ela só existe neste jogo, custa %d Créditos fictícios e não envolve pagamento real. Você pode registrar a resposta do cliente ou encerrar.", session.Customer.Product, session.Quote)
		elseif session.stage == "resolved" then
			text = (session.Customer.Resolution or "O caso foi explicado com transparência.") .. " A oferta imaginária é opcional; você também pode finalizar sem vender."
		elseif session.stage == "recovery" then
			text = session.Customer.Question .. " Desculpe pela promessa impossível. Posso corrigir a informação, resolver o caso ou encerrar."
		else
			text = session.Customer.Question .. " Você pode pedir mais detalhes, resolver o caso com honestidade, apresentar a brincadeira fictícia ou encerrar."
		end
		sendNpcLine(player, session, text, choicesForSession(session))
		return
	end

	if choiceId == "resolve" then
		if not session.Resolved then
			session.Resolved = true
			session.ResolutionReward = safeInteger(Config.ServiceResolutionReward, 16, 0, 1000)
			session.Trust = math.min(1, session.Trust + 0.35)
			updateReputation(player, 4)
		end
		session.stage = "resolved"
		local solution = session.Customer.Resolution or "A situação foi explicada com clareza e sem custos reais."
		local options = currentResolvedChoices(session)
		local text = string.format(
			"%s: Obrigado por resolver minha dúvida. %s Nenhum dado pessoal ou pagamento real é necessário. Você pode finalizar agora; qualquer pacote é opcional.",
			session.Customer.Name,
			solution
		)
		sendNpcLine(player, session, text, options)
		return
	end

	if choiceId == "explain" then
		session.Trust = math.min(1, session.Trust + 0.25)
		updateReputation(player, 2)
		session.stage = "pitch"
		local options = currentPitchChoices(session)
		local text = string.format(
			"%s: Obrigado por explicar. Entendi que é só uma brincadeira, sem valor fora do jogo. O pacote %s custa %d Créditos fictícios; a oferta é opcional e não há pagamento real.",
			session.Customer.Name,
			session.Customer.Product,
			session.Quote
		)
		sendNpcLine(player, session, text, options)
		return
	end

	if choiceId == "offer" then
		session.stage = "pitch"
		local options = currentPitchChoices(session)
		local text = string.format(
			"%s: Entendi a oferta do pacote %s. Ela é apenas uma brincadeira deste jogo, custa %d Créditos fictícios e não exige dinheiro real. Vou decidir se aceito.",
			session.Customer.Name,
			session.Customer.Product,
			session.Quote
		)
		sendNpcLine(player, session, text, options)
		return
	end

	if choiceId == "accept_offer" then
		local chance = session.Customer.BuyChance + 0.28 + session.Trust * 0.12
		resolvePurchase(player, session, chance, true)
		return
	end

	if choiceId == "promise" then
		updateReputation(player, -6)
		session.stage = "recovery"
		local text = string.format(
			"%s: Essa promessa é impossível, então não vou aceitá-la. Na simulação, inventar uma garantia reduz sua reputação. Você pode corrigir a informação, resolver meu caso ou encerrar.",
			session.Customer.Name
		)
		sendNpcLine(player, session, text, currentRecoveryChoices(session))
		return
	end
end

local function startCall(player, station)
	if not profilesLoaded[player] then
		sendToast(player, "Carregando seus dados. Tente novamente em um instante.", "warning")
		return
	end
	if sessions[player] then
		sendToast(player, "Você já está em uma ligação. Termine-a antes de atender outra.", "warning")
		return
	end
	if callCooldowns[player] and os.clock() < callCooldowns[player] then
		sendToast(player, "Aguarde alguns segundos antes de atender outra ligação.", "info")
		return
	end
	local existingSession = stationSessions[station]
	if existingSession then
		local owner = existingSession.Player
		if owner and sessions[owner] == existingSession then
			sendToast(player, "Esta estação está ocupada. Use outro telefone ou aguarde.", "warning")
			return
		end
		stationSessions[station] = nil
		setStationBusy(station, false)
	end
	if #Config.Customers == 0 then
		sendToast(player, "Nenhum cliente de brincadeira está disponível.", "warning")
		return
	end

	local customer = Config.Customers[math.random(1, #Config.Customers)]
	local quote = math.random(customer.MinReward, customer.MaxReward)
	local session = {
		Player = player,
		Station = station,
		Customer = customer,
		Phone = station.Phone,
		Quote = quote,
		Trust = 0,
		Resolved = false,
		ResolutionReward = safeInteger(Config.ServiceResolutionReward, 16, 0, 1000),
		stage = "intro",
		choices = {},
		StartedAt = os.clock(),
	}
	sessions[player] = session
	stationSessions[station] = session
	setStationBusy(station, true)
	armCallTimeout(player, session)
	local options = currentIntroChoices(session)
	clientRemote:FireClient(player, "callStart", {
		name = customer.Name,
		product = customer.Product,
		station = station.Index,
		text = customer.Opening,
		choices = options,
	})
end

local function filterPrivateInput(player, rawText)
	local success, filtered = pcall(function()
		local filterResult = TextService:FilterStringAsync(rawText, player.UserId)
		return filterResult:GetNonChatStringForUserAsync(player.UserId)
	end)
	if success and type(filtered) == "string" then
		return filtered
	end
	return nil
end

local function handleSpeechOrText(player, rawText)
	local session = sessions[player]
	if not session then
		return
	end
	if typeof(rawText) ~= "string" or #rawText == 0 then
		return
	end
	if #rawText > Config.MaxInputLength then
		rawText = string.sub(rawText, 1, Config.MaxInputLength)
	end
	if not isNearCallStation(player, session) then
		sendToast(player, "Volte para a sua estação para continuar a conversa.", "warning")
		return
	end
	armCallTimeout(player, session)

	-- A fala é transitória: não é registrada nem enviada a outros jogadores. Se for
	-- exibida, primeiro passa pelo filtro oficial de texto do Roblox.
	local filtered = filterPrivateInput(player, rawText)
	if sessions[player] ~= session then
		return
	end
	local normalized = normalizePortuguese(rawText)
	local isSensitive = containsSensitiveTopic(normalized)
	if filtered then
		clientRemote:FireClient(player, "playerLine", {
			text = isSensitive and "Fala omitida por segurança." or filtered,
		})
	end

	if isSensitive then
		local options = choicesForSession(session)
		sendNpcLine(player, session,
			"Não compartilhe senha, telefone, endereço, documentos ou dados de pagamento. Esta brincadeira não precisa de nenhum dado pessoal.",
			options
		)
		return
	end

	local intent = inferIntent(session, rawText)
	if intent == "safety" then
		local options = choicesForSession(session)
		sendNpcLine(player, session,
			"Não compartilhe dados pessoais ou de pagamento. Nenhuma informação desse tipo é necessária para jogar.",
			options
		)
		return
	end
	if intent == "unknown" then
		local options = choicesForSession(session)
		sendNpcLine(player, session,
			"Entendi. Posso ouvir mais detalhes, resolver o caso com honestidade, explicar a brincadeira, apresentar a oferta imaginária ou encerrar. Todas as moedas são apenas do jogo.",
			options
		)
		return
	end
	if not session.choices[intent] then
		-- Adapta uma confirmação falada ao passo disponível, sem confiar no cliente.
		if intent == "offer" and session.choices.accept_offer then
			intent = "accept_offer"
		elseif intent == "accept_offer" and session.choices.offer then
			intent = "offer"
		else
			local options = choicesForSession(session)
			sendNpcLine(player, session,
				"Ainda não chegamos a essa parte. Quer ouvir como funciona a brincadeira ou prefere encerrar?",
				options
			)
			return
		end
	end
	handleChoice(player, intent)
end

local function allowAction(player)
	local now = os.clock()
	local last = actionTimes[player] or 0
	if now - last < Config.ActionCooldown then
		return false
	end
	actionTimes[player] = now
	return true
end

actionRemote.OnServerEvent:Connect(function(player, action, payload)
	if typeof(action) ~= "string" then
		return
	end
	if action == "ready" then
		if clientReady[player] then
			return
		end
		clientReady[player] = true
		pushStats(player)
		clientRemote:FireClient(player, "ranking", rankingCache)
		return
	end
	if not allowAction(player) then
		return
	end

	if action == "say" then
		handleSpeechOrText(player, payload)
	elseif action == "choice" then
		if typeof(payload) ~= "string" or #payload > 32 then
			return
		end
		local session = sessions[player]
		if not session then
			return
		end
		if payload ~= "end" and not isNearCallStation(player, session) then
			sendToast(player, "Volte para a sua estação para continuar a conversa.", "warning")
			return
		end
		local selectedLabel = session.choices[payload]
		if not selectedLabel then
			return
		end
		clientRemote:FireClient(player, "playerLine", {text = selectedLabel})
		handleChoice(player, payload)
	end
end)

for _, station in ipairs(World.Stations) do
	station.Prompt.Triggered:Connect(function(player)
		startCall(player, station)
	end)
end

local function onPlayerAdded(player)
	nameCache[player.UserId] = player.Name
	task.spawn(loadPlayer, player)
end

local function onPlayerRemoving(player)
	if sessions[player] then
		finishCall(player, sessions[player], "Ligação encerrada porque você saiu do escritório.", 0)
	end
	savePlayer(player)
	sessions[player] = nil
	actionTimes[player] = nil
	profilesLoaded[player] = nil
	queuedSaves[player] = nil
	callCooldowns[player] = nil
	clientReady[player] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Auto-save espaçado para evitar rajadas desnecessárias de DataStore requests.
task.spawn(function()
	while true do
		task.wait(AUTOSAVE_SECONDS)
		for _, player in ipairs(Players:GetPlayers()) do
			task.spawn(savePlayer, player)
			task.wait(0.35)
		end
	end
end)

task.spawn(function()
	while true do
		refreshRanking()
		task.wait(RANK_REFRESH_SECONDS)
	end
end)

game:BindToClose(function()
	local pending = 0
	for _, player in ipairs(Players:GetPlayers()) do
		pending += 1
		task.spawn(function()
			savePlayer(player)
			pending -= 1
		end)
	end
	local deadline = os.clock() + 25
	while pending > 0 and os.clock() < deadline do
		task.wait(0.1)
	end
end)

print("Central do Caô carregado: mapa procedural, diálogo, moedas e ranking ativos.")
