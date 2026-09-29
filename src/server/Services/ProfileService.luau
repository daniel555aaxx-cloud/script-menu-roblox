--[[
	ProfileService.luau
	Guarda os dados persistentes do jogador (Scooby Snacks, conquistas, estatísticas,
	itens comprados, skin escolhida, dificuldade).

	Usa DataStore quando disponível e cai para memória em Studio/servidor de teste
	(assim o jogo roda sem configurar nada).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Definitions = require(Shared.Data.Definitions)
local Signal = require(Shared.Signal)

local ProfileService = {}

ProfileService.ProfileLoaded = Signal.new()
ProfileService.ProfileChanged = Signal.new()

local STORE_NAME = "MysteryArchives_v1"
local AUTOSAVE_INTERVAL = 120

local store = nil
local canPersist = false

if not RunService:IsStudio() then
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(STORE_NAME)
	end)
	if ok then
		store = result
		canPersist = true
	end
end

local profiles = {}

local function defaultProfile()
	return {
		version = 1,
		snacks = 250,
		difficulty = "detetive",
		skin = "classico",
		items = { snack_basic = 1, costume_extra = 0 },
		achievements = {},
		stats = {
			chaptersCompleted = 0,
			episodesCompleted = 0,
			cluesFound = 0,
			trapsSprung = 0,
			monstersUnmasked = 0,
			timesCaught = 0,
			totalPoints = 0,
			matchesPlayed = 0,
			deaths = 0,
			playtimeSeconds = 0,
		},
		progress = {
			episode = "EP01",
			chapter = "EP01_C1",
			completedChapters = {},
			completedEpisodes = {},
			evidence = {},
		},
		firstJoin = os.time(),
		lastJoin = os.time(),
	}
end

local function keyFor(player)
	return "player_" .. tostring(player.UserId)
end

local function loadAsync(player)
	local profile = defaultProfile()
	if canPersist then
		local ok, saved = pcall(function()
			return store:GetAsync(keyFor(player))
		end)
		if ok and type(saved) == "table" then
			for key, value in pairs(saved) do
				if type(value) == "table" and type(profile[key]) == "table" then
					for innerKey, innerValue in pairs(value) do
						profile[key][innerKey] = innerValue
					end
				else
					profile[key] = value
				end
			end
		end
	end
	profile.lastJoin = os.time()
	return profile
end

local function saveAsync(player, profile)
	if not canPersist or not profile then
		return
	end
	pcall(function()
		store:SetAsync(keyFor(player), profile)
	end)
end

function ProfileService.get(player)
	return profiles[player]
end

function ProfileService.getByUserId(userId)
	for player, profile in pairs(profiles) do
		if player.UserId == userId then
			return profile
		end
	end
	return nil
end

function ProfileService.load(player)
	local profile = loadAsync(player)
	profiles[player] = profile
	ProfileService.ProfileLoaded:Fire(player, profile)
	return profile
end

function ProfileService.save(player)
	local profile = profiles[player]
	if profile then
		saveAsync(player, profile)
	end
end

function ProfileService.unload(player)
	local profile = profiles[player]
	if profile then
		saveAsync(player, profile)
		profiles[player] = nil
	end
end

function ProfileService.changed(player, reason)
	ProfileService.ProfileChanged:Fire(player, profiles[player], reason)
end

-- ==========================================================
-- MOEDA
-- ==========================================================
function ProfileService.addSnacks(player, amount, reason)
	local profile = profiles[player]
	if not profile then
		return 0
	end
	profile.snacks = math.max(0, profile.snacks + amount)
	ProfileService.changed(player, reason or "snacks")
	return profile.snacks
end

function ProfileService.spendSnacks(player, amount)
	local profile = profiles[player]
	if not profile then
		return false, "sem perfil"
	end
	if profile.snacks < amount then
		return false, "snacks insuficientes"
	end
	profile.snacks -= amount
	ProfileService.changed(player, "compra")
	return true
end

-- ==========================================================
-- ESTATÍSTICAS / CONQUISTAS
-- ==========================================================
function ProfileService.addStat(player, statName, amount)
	local profile = profiles[player]
	if not profile or not profile.stats then
		return
	end
	profile.stats[statName] = (profile.stats[statName] or 0) + (amount or 1)
	ProfileService.changed(player, "stat:" .. statName)
end

function ProfileService.hasAchievement(player, achievementId)
	local profile = profiles[player]
	return profile ~= nil and profile.achievements[achievementId] == true
end

function ProfileService.grantAchievement(player, achievementId)
	local profile = profiles[player]
	if not profile or profile.achievements[achievementId] then
		return false
	end
	local definition = Definitions.getAchievement(achievementId)
	if not definition then
		return false
	end
	profile.achievements[achievementId] = true
	if definition.reward and definition.reward > 0 then
		ProfileService.addSnacks(player, definition.reward, "conquista")
	end
	ProfileService.changed(player, "conquista")
	return true
end

-- ==========================================================
-- PROGRESSO DA HISTÓRIA
-- ==========================================================
function ProfileService.setProgress(player, episodeId, chapterId)
	local profile = profiles[player]
	if not profile then
		return
	end
	profile.progress.episode = episodeId or profile.progress.episode
	profile.progress.chapter = chapterId or profile.progress.chapter
	ProfileService.changed(player, "progresso")
end

function ProfileService.completeChapter(player, episodeId, chapterId)
	local profile = profiles[player]
	if not profile then
		return
	end
	if not profile.progress.completedChapters[chapterId] then
		profile.progress.completedChapters[chapterId] = true
		ProfileService.addStat(player, "chaptersCompleted", 1)
	end
	profile.progress.episode = episodeId
	profile.progress.chapter = chapterId
	ProfileService.changed(player, "capitulo")
end

function ProfileService.completeEpisode(player, episodeId)
	local profile = profiles[player]
	if not profile then
		return
	end
	profile.progress.completedEpisodes[episodeId] = true
	ProfileService.addStat(player, "episodesCompleted", 1)
	ProfileService.changed(player, "episodio")
end

function ProfileService.hasItem(player, itemId)
	local profile = profiles[player]
	if not profile then
		return false
	end
	return (profile.items[itemId] or 0) > 0
end

function ProfileService.giveItem(player, itemId, amount)
	local profile = profiles[player]
	if not profile then
		return
	end
	profile.items[itemId] = (profile.items[itemId] or 0) + (amount or 1)
	ProfileService.changed(player, "item")
end

-- ==========================================================
-- RUNTIME
-- ==========================================================
function ProfileService.start()
	local function onPlayerAdded(player)
		local profile = ProfileService.load(player)
		player:SetAttribute("Difficulty", profile.difficulty)
		player:SetAttribute("Skin", profile.skin)
	end

	local function onPlayerRemoving(player)
		ProfileService.unload(player)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL)
			for player, profile in pairs(profiles) do
				saveAsync(player, profile)
			end
		end
	end)

	-- salvamento especial ao fechar o servidor
	game:BindToClose(function()
		for player, profile in pairs(profiles) do
			saveAsync(player, profile)
		end
	end)
end

return ProfileService
