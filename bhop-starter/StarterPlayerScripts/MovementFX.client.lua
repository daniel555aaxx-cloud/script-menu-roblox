-- Feedback visual leve de velocidade: FOV responsivo e balanço suave da câmera.
-- Coloque como LocalScript em StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local BASE_FOV = 82
local MAX_EXTRA_FOV = 12
local OFFSET_STRENGTH = 0.12

local currentHumanoid
local connection

local function bindCharacter(character)
	if connection then
		connection:Disconnect()
	end
	currentHumanoid = character:WaitForChild("Humanoid")
	currentHumanoid.CameraOffset = Vector3.zero

	connection = RunService.RenderStepped:Connect(function(deltaTime)
		local camera = workspace.CurrentCamera
		local root = character:FindFirstChild("HumanoidRootPart")
		if not camera or not root or not currentHumanoid or currentHumanoid.Health <= 0 then
			return
		end

		local velocity = root.AssemblyLinearVelocity
		local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
		local speedAlpha = math.clamp((horizontalSpeed - 16) / 60, 0, 1)
		local targetFov = BASE_FOV + speedAlpha * MAX_EXTRA_FOV
		camera.FieldOfView += (targetFov - camera.FieldOfView) * math.clamp(deltaTime * 5, 0, 1)

		local move = currentHumanoid.MoveDirection
		local targetOffset = Vector3.new(-move.X * OFFSET_STRENGTH, 0, 0)
		currentHumanoid.CameraOffset = currentHumanoid.CameraOffset:Lerp(targetOffset, math.clamp(deltaTime * 7, 0, 1))
	end)
end

player.CharacterAdded:Connect(bindCharacter)
if player.Character then
	task.spawn(bindCharacter, player.Character)
end
