--[[
	InputController.luau
	Atalhos e qualidade de vida:

		L       -> abre/fecha a turma
		Q       -> quadro de pistas
		H       -> dica da Velma (custa Scooby Snacks)
		T       -> provocar o fantasma (isca)
		F       -> lanterna
		SHIFT   -> correr (com estamina)
		R       -> reiniciar o capítulo (só o líder)
		E       -> interagir com o que estiver na frente
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Net = require(Shared.Net)

local LobbyController = require(script.Parent.LobbyController)
local HudController = require(script.Parent.HudController)
local EffectsController = require(script.Parent.EffectsController)

local InputController = {}

local sprinting = false
local stamina = Config.Players.SPRINT_STAMINA

local function baseSpeed()
	return Config.Players.WALK_SPEED + (player:GetAttribute("SpeedBonus") or 0)
end

local function applySpeed()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if player:GetAttribute("Scared") then
		humanoid.WalkSpeed = Config.Players.SCARED_WALK_SPEED
	elseif sprinting and stamina > 5 then
		humanoid.WalkSpeed = Config.Players.SPRINT_SPEED
	else
		humanoid.WalkSpeed = baseSpeed()
	end
end

local function findInteractable()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	local range = Config.Players.INTERACT_RANGE
	local best, bestDistance = nil, range
	local folder = workspace:FindFirstChild("MysteryMaps")
	if not folder then
		return nil
	end
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local kind = descendant:GetAttribute("MarkerKind") or descendant:GetAttribute("InteractKind")
			if kind and kind ~= "monster" and kind ~= "spawn" then
				local distance = (descendant.Position - root.Position).Magnitude
				if distance < bestDistance then
					best = descendant
					bestDistance = distance
				end
			end
		end
	end
	-- NPCs
	local npcs = workspace:FindFirstChild("MysteryNpcs")
	if npcs then
		for _, descendant in ipairs(npcs:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Name == "Torso" then
				local distance = (descendant.Position - root.Position).Magnitude
				if distance < bestDistance then
					best = descendant
					bestDistance = distance
				end
			end
		end
	end
	return best
end

function InputController.start()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.KeyCode == Enum.KeyCode.L then
			LobbyController.toggle()
		elseif input.KeyCode == Enum.KeyCode.Q then
			HudController.toggleEvidence()
		elseif input.KeyCode == Enum.KeyCode.H then
			Net.fireServer("GameRequestHint")
		elseif input.KeyCode == Enum.KeyCode.T then
			Net.fireServer("GameTaunt")
		elseif input.KeyCode == Enum.KeyCode.F then
			EffectsController.toggleFlashlight()
		elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			sprinting = true
			applySpeed()
		elseif input.KeyCode == Enum.KeyCode.E then
			local target = findInteractable()
			if target then
				Net.fireServer("GameInteract", { instance = target })
			end
		elseif input.KeyCode == Enum.KeyCode.R then
			Net.fireServer("GameReport", "reiniciar")
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			sprinting = false
			applySpeed()
		end
	end)

	RunService.Heartbeat:Connect(function(deltaTime)
		if sprinting then
			stamina = math.max(0, stamina - Config.Players.SPRINT_DRAIN * deltaTime)
		else
			stamina = math.min(Config.Players.SPRINT_STAMINA, stamina + Config.Players.SPRINT_REGEN * deltaTime)
		end
		if sprinting and stamina <= 0 then
			sprinting = false
		end
		applySpeed()
	end)

	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		applySpeed()
	end)
end

return InputController
