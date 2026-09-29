--[[
	AchievementService.luau
	Concede conquistas (Definitions.Achievements) e cuida das notificações.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Definitions = require(Shared.Data.Definitions)
local Episodes = require(Shared.Data.Episodes)
local Net = require(Shared.Net)

local ProfileService = require(script.Parent.ProfileService)

local AchievementService = {}

function AchievementService.award(player, achievementId)
	local achievement = Definitions.getAchievement(achievementId)
	if not achievement then
		return false
	end
	local granted = ProfileService.grantAchievement(player, achievementId)
	if granted then
		Net.fireClient(player, "ClientUnlock", {
			kind = "achievement",
			id = achievementId,
			name = achievement.name,
			description = achievement.description,
			reward = achievement.reward,
		})
		Net.fireClient(player, "ClientSfx", { sound = "Ping", volume = 0.7 })
	end
	return granted
end

function AchievementService.checkEpisode(player, episodeId)
	local profile = ProfileService.get(player)
	if not profile then
		return
	end
	AchievementService.award(player, "primeiro_caso")

	if episodeId == "EP01" then
		AchievementService.award(player, "heroi_do_farol")
	end

	-- completou todos os capítulos de todos os episódios?
	local completed = profile.progress.completedEpisodes or {}
	local total = 0
	for _, id in ipairs(Episodes.Season.order) do
		if completed[id] then
			total += 1
		end
	end
	if total >= #Episodes.Season.order then
		AchievementService.award(player, "craque_de_coolsville")
		AchievementService.award(player, "todos_os_cenarios")
	end
end

function AchievementService.checkClues(player, amount)
	if amount >= 12 then
		AchievementService.award(player, "mestre_das_pistas")
	end
end

function AchievementService.checkParty(player, size)
	if size >= 4 then
		AchievementService.award(player, "turma_completa")
	end
end

function AchievementService.checkSnacks(player, amount)
	if amount >= 5000 then
		AchievementService.award(player, "amigo_do_scooby")
	end
end

function AchievementService.start()
	ProfileService.ProfileChanged:Connect(function(player, profile, reason)
		if reason == "stat:timesCaught" then
			-- sobreviveu a um capítulo inteiro sem ser pego
		elseif reason == "conquista" or reason == "pista" then
			local stats = profile and profile.stats or {}
			AchievementService.checkClues(player, stats.cluesFound or 0)
		end
	end)
end

return AchievementService
