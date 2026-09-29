--[[
	CharacterService.luau
	Dono do personagem de cada jogador.

	Por padrão usa o avatar Roblox do jogador (R15/R6 real) — assim o jogo tem
	a aparência "realista" que já existe na plataforma — mas permite
	`CharacterService.forceClassic = true` para usar os modelos fiéis ao desenho
	construídos pelo CharacterBuilder (Fred, Daphne, Velma, Salsinha, Scooby).

	* aplica o papel (role) escolhido no lobby;
	* liga a tag do nome + cor de time;
	* respawna com o script de morte do MatchService.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Cast = require(Shared.Data.Cast)
local Net = require(Shared.Net)
local Roles = require(Shared.Roles)

local Builders = script.Parent.Parent.Builders
local CharacterBuilder = require(Builders.CharacterBuilder)
local PartKit = require(Builders.PartKit)

local Services = script.Parent
local ProfileService = require(Services.ProfileService)

local CharacterService = {}

-- Troque para true para forçar os modelos "do desenho" em todos os jogadores.
CharacterService.forceClassic = false
-- Troque para true para usar os modelos customizados de ServerStorage.CustomModels.
CharacterService.preferCustomModels = false

local function randomRole()
	local ids = {}
	for id in pairs(Cast.Heroes) do
		table.insert(ids, id)
	end
	return ids[math.random(1, #ids)]
end

function CharacterService.assignRole(player, roleId)
	if not Roles.isValid(roleId) then
		-- Scooby é opcional: papéis válidos + Scooby
		if roleId ~= "Scooby" then
			roleId = randomRole()
		end
	end
	player:SetAttribute("RoleId", roleId)
	local role = Cast.Heroes[roleId] or Cast.Scooby
	if role then
		Net.fireClient(player, "ClientNotify", {
			title = "Você é " .. (role.displayName or role.name or roleId),
			text = (role.passive and role.passive.description) or (role.description or "Boa sorte na investigação!"),
			kind = "info",
			sound = "Button",
		})
	end
	return roleId
end

function CharacterService.applyRoleToCharacter(player, character)
	local roleId = player:GetAttribute("RoleId") or CharacterService.assignRole(player)
	local role = Cast.Heroes[roleId] or Cast.Scooby
	if not role then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = Config.Players.WALK_SPEED + (player:GetAttribute("SpeedBonus") or 0)
		humanoid.JumpHeight = Config.Players.JUMP_HEIGHT
		humanoid.UseJumpPower = false
	end

	-- cor de time e tag no avatar Roblox
	local head = character:FindFirstChild("Head")
	if head then
		local existing = head:FindFirstChild("RoleTag")
		if existing then
			existing:Destroy()
		end
		local tag = PartKit.billboard(head, (role.displayName or roleId) .. " · " .. player.Name, {
			width = 240,
			color = "Accent",
			heightOffset = 2.6,
			maxDistance = 90,
		})
		tag.Name = "RoleTag"
	end

	-- boné/cores opcionais para reconhecer o papel
	if player:GetAttribute("Tag_classic") then
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if torso then
			PartKit.highlight(character, roleId == "Daphne" and "Daphne" or roleId, {
				fillTransparency = 0.85,
				outlineTransparency = 0.4,
			})
		end
	end
end

function CharacterService.spawnClassic(player)
	local roleId = player:GetAttribute("RoleId") or CharacterService.assignRole(player)
	local model, joints
	if roleId == "Scooby" then
		model, joints = CharacterBuilder.buildScooby()
	else
		model, joints = CharacterBuilder.buildHero(roleId)
	end
	if not model then
		return nil
	end
	return model, joints
end

-- ==========================================================
-- CARREGAMENTO DE PERSONAGEM
-- ==========================================================
function CharacterService.ensureCharacter(player)
	if player.Character then
		return player.Character
	end
	local loaded = false
	local start = os.clock()
	player:LoadCharacter()
	repeat
		RunService.Heartbeat:Wait()
		loaded = player.Character ~= nil
	until loaded or (os.clock() - start) > 5
	local character = player.Character
	if character then
		CharacterService.applyRoleToCharacter(player, character)
	end
	return character
end

function CharacterService.start()
	local function onCharacter(player, character)
		CharacterService.applyRoleToCharacter(player, character)

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Died:Connect(function()
				player:SetAttribute("Caught", true)
				local match = require(Services.MatchService).getMatch(player)
				task.delay(Config.Match.RESPAWN_DELAY, function()
					if player.Parent then
						player:LoadCharacter()
					end
				end)
			end)
		end
	end

	Players.PlayerAdded:Connect(function(player)
		local roleId = CharacterService.assignRole(player)
		player.CharacterAdded:Connect(function(character)
			onCharacter(player, character)
		end)
		player:LoadCharacter()
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		CharacterService.assignRole(player)
		player.CharacterAdded:Connect(function(character)
			onCharacter(player, character)
		end)
		player:LoadCharacter()
	end

	Net.Event("LobbySelectCharacter").OnServerEvent:Connect(function(player, roleId)
		if type(roleId) == "string" then
			CharacterService.assignRole(player, roleId)
			if player.Character then
				CharacterService.applyRoleToCharacter(player, player.Character)
			end
		end
	end)
end

return CharacterService
