--[[
	PartyService.luau
	Turmas (parties) de 1 a 4 jogadores.

	* Privacidade: pública, SOMENTE AMIGOS (usa Players:GetFriendsAsync para
	  aceitar só quem é amigo do líder), somente convite e fechada.
	* O líder monta a turma no lobby; quando a turma está pronta, o líder
	  escolhe o caso (ou o sistema sorteia) e o MatchService puxa a partida.
	* O lobby é compartilhado (todo mundo vê quem está procurando turma), mas
	  cada turma tem sua própria "sala" de partida.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Episodes = require(Shared.Data.Episodes)
local Net = require(Shared.Net)
local Signal = require(Shared.Signal)
local Util = require(Shared.Util)

local Services = script.Parent
local ProfileService = require(Services.ProfileService)

local PartyService = {}

PartyService.PartyChanged = Signal.new()
PartyService.PartyStarted = Signal.new()

local parties = {} -- id -> party
local partyOf = {} -- player -> party
local invites = {} -- player -> { [partyId] = inviterUserId }

local function partyPublicState(party, viewer)
	local members = {}
	for _, member in ipairs(party.members) do
		table.insert(members, {
			id = member.UserId,
			name = member.Name,
			displayName = member.DisplayName,
			role = member:GetAttribute("RoleId"),
			isLeader = member == party.leader,
			ready = member:GetAttribute("Ready") == true,
			snacks = (ProfileService.get(member) or {}).snacks or 0,
		})
	end
	return {
		id = party.id,
		leaderId = party.leader.UserId,
		leaderName = party.leader.Name,
		privacy = party.privacy,
		maxSize = Config.Match.MAX_PLAYERS,
		size = #party.members,
		members = members,
		episode = party.episode,
		createdAt = party.createdAt,
		joinable = #party.members < Config.Match.MAX_PLAYERS and (party.privacy == Config.PartyPrivacy.Public),
	}
end

function PartyService.broadcastParty(party, extra)
	if not party then
		return
	end
	for _, member in ipairs(party.members) do
		Net.fireClient(member, "ClientParty", {
			party = partyPublicState(party, member),
			extra = extra,
		})
	end
end

function PartyService.broadcastLobby()
	local list = {}
	for _, party in pairs(parties) do
		table.insert(list, {
			id = party.id,
			leaderName = party.leader.Name,
			size = #party.members,
			maxSize = Config.Match.MAX_PLAYERS,
			privacy = party.privacy,
			episode = party.episode,
			joinable = #party.members < Config.Match.MAX_PLAYERS and party.privacy == Config.PartyPrivacy.Public,
		})
	end
	table.sort(list, function(a, b)
		return a.size > b.size
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		if not partyOf[player] then
			Net.fireClient(player, "ClientLobby", { parties = list, invites = invites[player] or {} })
		end
	end
end

-- ==========================================================
-- CRIAÇÃO / ENTRADA / SAÍDA
-- ==========================================================
local function canJoin(party, player)
	if #party.members >= Config.Match.MAX_PLAYERS then
		return false, "turma cheia"
	end
	if party.privacy == Config.PartyPrivacy.Closed then
		return false, "turma fechada"
	end
	if party.privacy == Config.PartyPrivacy.InviteOnly then
		local invited = invites[player] and invites[player][party.id]
		if not invited then
			return false, "só por convite"
		end
	end
	if party.privacy == Config.PartyPrivacy.FriendsOnly then
		-- Somente amigos do líder (a checagem de amizade do Roblox é assíncrona)
		local isFriend = false
		local ok, result = pcall(function()
			return player:IsFriendsWith(party.leader.UserId)
		end)
		if ok and result then
			isFriend = true
		else
			-- fallback: varre a lista de amigos do líder em cache
			local success, pages = pcall(function()
				return Players:GetFriendsAsync(party.leader.UserId)
			end)
			if success and pages then
				local finished = false
				while not finished do
					local items = pages:GetCurrentPage()
					for _, item in ipairs(items) do
						if item.Id == player.UserId then
							isFriend = true
							break
						end
					end
					if pages.IsFinished then
						finished = true
					else
						local okNext = pcall(function()
							pages:AdvanceToNextPageAsync()
						end)
						if not okNext then
							finished = true
						end
					end
				end
			end
		end
		if not isFriend then
			return false, "esta turma só aceita amigos do líder"
		end
	end
	return true
end

function PartyService.create(player, privacy)
	if partyOf[player] then
		PartyService.leave(player)
	end
	local party = {
		id = Util.makeId("party", 5),
		leader = player,
		members = { player },
		privacy = privacy or Config.PartyPrivacy.Public,
		episode = "EP01",
		createdAt = os.time(),
	}
	parties[party.id] = party
	partyOf[player] = party
	party.members[1]:SetAttribute("Ready", false)
	PartyService.broadcastParty(party)
	PartyService.broadcastLobby()
	return party
end

function PartyService.getPartyOf(player)
	return partyOf[player]
end

function PartyService.getParty(id)
	return parties[id]
end

function PartyService.join(player, partyId)
	local party = parties[partyId]
	if not party then
		return false, "turma não existe"
	end
	if partyOf[player] == party then
		return false, "já está na turma"
	end
	local allowed, reason = canJoin(party, player)
	if not allowed then
		return false, reason
	end

	if partyOf[player] then
		PartyService.leave(player)
	end

	table.insert(party.members, player)
	partyOf[player] = party
	party.members[#party.members]:SetAttribute("Ready", false)

	PartyService.broadcastParty(party, { joined = player.Name })
	PartyService.broadcastLobby()
	Net.fireClient(player, "ClientNotify", {
		title = "Turma",
		text = ("Você entrou na turma de %s."):format(party.leader.Name),
		kind = "success",
		sound = "Button",
	})
	return true
end

function PartyService.leave(player)
	local party = partyOf[player]
	if not party then
		return false
	end
	local index = Util.indexOf(party.members, player)
	if index then
		table.remove(party.members, index)
	end
	partyOf[player] = nil
	player:SetAttribute("Ready", nil)

	if #party.members == 0 then
		parties[party.id] = nil
	else
		if party.leader == player then
			party.leader = party.members[1]
			Net.fireAll("ClientNotify", {
				title = "Novo líder",
				text = party.leader.Name .. " agora comanda a turma.",
				kind = "info",
				sound = "Ping",
			})
		end
		PartyService.broadcastParty(party, { left = player.Name })
	end
	PartyService.broadcastLobby()
	return true
end

function PartyService.kick(player, targetUserId)
	local party = partyOf[player]
	if not party or party.leader ~= player then
		return false, "só o líder pode remover"
	end
	for _, member in ipairs(party.members) do
		if member.UserId == targetUserId then
			party.members[Util.indexOf(party.members, member)] = nil
			table.remove(party.members, Util.indexOf(party.members, member))
			partyOf[member] = nil
			Net.fireClient(member, "ClientNotify", {
				title = "Você saiu da turma",
				text = "O líder removeu você da turma.",
				kind = "warn",
				sound = "Hit",
			})
			PartyService.broadcastParty(party)
			PartyService.broadcastLobby()
			return true
		end
	end
	return false, "jogador não está na turma"
end

function PartyService.setPrivacy(player, privacy)
	local party = partyOf[player]
	if not party or party.leader ~= player then
		return false, "só o líder pode mudar a privacidade"
	end
	party.privacy = privacy
	PartyService.broadcastParty(party, { privacyChanged = privacy })
	Net.fireClient(player, "ClientNotify", {
		title = "Privacidade da turma",
		text = "Agora: " .. tostring(privacy),
		kind = "info",
		sound = "Switch",
	})
	return true
end

-- Convite para amigo (o amigo entra pela lista de convites do lobby)
function PartyService.inviteFriend(player, friendUserId)
	local party = partyOf[player]
	if not party or party.leader ~= player then
		return false, "só o líder convida"
	end
	local friend = nil
	for _, target in ipairs(Players:GetPlayers()) do
		if target.UserId == friendUserId then
			friend = target
			break
		end
	end
	if not friend then
		return false, "esse amigo não está no servidor"
	end
	-- confirma a amizade
	local ok, isFriend = pcall(function()
		return player:IsFriendsWith(friendUserId)
	end)
	if ok and isFriend ~= true and party.privacy == Config.PartyPrivacy.FriendsOnly then
		return false, "você só pode convidar amigos"
	end

	invites[friend] = invites[friend] or {}
	invites[friend][party.id] = player.UserId
	Net.fireClient(friend, "ClientLobby", {
		invites = invites[friend],
		invitedBy = player.Name,
		partyId = party.id,
	})
	Net.fireClient(friend, "ClientNotify", {
		title = "Convite de turma",
		text = ("%s convidou você para o caso. Abra o lobby (L) para aceitar."):format(player.Name),
		kind = "info",
		sound = "Ping",
	})
	return true
end

function PartyService.setEpisode(player, episodeId)
	local party = partyOf[player]
	if not party then
		return false
	end
	if party.leader ~= player then
		return false, "só o líder escolhe"
	end
	party.episode = episodeId
	PartyService.broadcastParty(party, { episodeChanged = episodeId })
	return true
end

function PartyService.setReady(player, ready)
	local party = partyOf[player]
	if party then
		player:SetAttribute("Ready", ready == true)
		PartyService.broadcastParty(party)
	end
	return true
end

-- Todos prontos (ou líder sozinho) => puxa a partida
function PartyService.tryStart(party)
	if #party.members < Config.Match.MIN_PLAYERS then
		return false
	end
	for _, member in ipairs(party.members) do
		if member ~= party.leader and member:GetAttribute("Ready") ~= true then
			return false
		end
	end
	PartyService.PartyStarted:Fire(party)
	return true
end

-- ==========================================================
-- LOBBY STATE (para o RemoteFunction GetLobbyState / GetParty)
-- ==========================================================
function PartyService.lobbyState(player)
	local party = partyOf[player]
	local list = {}
	for _, other in pairs(parties) do
		table.insert(list, {
			id = other.id,
			leaderName = other.leader.Name,
			size = #other.members,
			maxSize = Config.Match.MAX_PLAYERS,
			privacy = other.privacy,
			episode = other.episode,
			joinable = #other.members < Config.Match.MAX_PLAYERS and other.privacy == Config.PartyPrivacy.Public,
		})
	end
	table.sort(list, function(a, b)
		if a.size == b.size then
			return a.leaderName < b.leaderName
		end
		return a.size > b.size
	end)

	local profile = ProfileService.get(player)
	local shopCatalog = nil
	local okShop, ShopService = pcall(require, script.Parent.ShopService)
	if okShop and ShopService then
		shopCatalog = ShopService.catalog()
	end
	return {
		shop = shopCatalog,
		party = party and partyPublicState(party, player) or nil,
		parties = list,
		invites = invites[player] or {},
		profile = profile and {
			snacks = profile.snacks,
			difficulty = profile.difficulty,
			skin = profile.skin,
			stats = profile.stats,
			achievements = profile.achievements,
			items = profile.items,
			progress = profile.progress,
		} or nil,
		config = {
			maxPlayers = Config.Match.MAX_PLAYERS,
			minPlayers = Config.Match.MIN_PLAYERS,
			countdown = Config.Match.LOBBY_COUNTDOWN,
			season = Episodes.Season.title,
		},
	}
end

-- ==========================================================
-- LIGAÇÕES
-- ==========================================================
function PartyService.start()
	Net.Event("PartyCreate").OnServerEvent:Connect(function(player, privacy)
		PartyService.create(player, privacy)
	end)

	Net.Event("PartyJoin").OnServerEvent:Connect(function(player, partyId)
		PartyService.join(player, partyId)
	end)

	Net.Event("PartyLeave").OnServerEvent:Connect(function(player)
		PartyService.leave(player)
		PartyService.broadcastLobby()
	end)

	Net.Event("PartyKick").OnServerEvent:Connect(function(player, userId)
		PartyService.kick(player, userId)
	end)

	Net.Event("PartySetPrivacy").OnServerEvent:Connect(function(player, privacy)
		PartyService.setPrivacy(player, privacy)
	end)

	Net.Event("PartyInviteFriend").OnServerEvent:Connect(function(player, userId)
		PartyService.inviteFriend(player, userId)
	end)

	Net.Event("PartySetEpisode").OnServerEvent:Connect(function(player, episodeId)
		PartyService.setEpisode(player, episodeId)
	end)

	Net.Event("PartyStartMatch").OnServerEvent:Connect(function(player)
		local party = partyOf[player]
		if not party then
			party = PartyService.create(player)
		end
		if party.leader ~= player then
			Net.fireClient(player, "ClientNotify", {
				title = "Só o líder",
				text = "Apenas o líder pode iniciar a partida.",
				kind = "warn",
				sound = "Hit",
			})
			return
		end
		-- aviso e contagem regressiva
		local countdown = Config.Match.LOBBY_COUNTDOWN
		for remaining = countdown, 1, -1 do
			for _, member in ipairs(party.members) do
				Net.fireClient(member, "ClientVote", {
					phase = "countdown",
					seconds = remaining,
					episode = party.episode,
				})
			end
			task.wait(1)
		end
		PartyService.PartyStarted:Fire(party)
	end)

	Net.Event("LobbyRequestState").OnServerEvent:Connect(function(player)
		Net.fireClient(player, "ClientLobby", PartyService.lobbyState(player))
		local party = partyOf[player]
		if party then
			PartyService.broadcastParty(party)
		end
	end)

	Net.Function("GetLobbyState").OnServerInvoke = function(player)
		return PartyService.lobbyState(player)
	end

	Net.Function("GetParty").OnServerInvoke = function(player)
		local party = partyOf[player]
		return party and partyPublicState(party, player) or nil
	end

	Players.PlayerRemoving:Connect(function(player)
		PartyService.leave(player)
		invites[player] = nil
		PartyService.broadcastLobby()
	end)

	-- quem entra sem turma vê o lobby
	Players.PlayerAdded:Connect(function(player)
		task.wait(2)
		Net.fireClient(player, "ClientLobby", PartyService.lobbyState(player))
	end)
end

return PartyService
