-- Controle de bunny hop e air-strafe para a experiência própria.
-- Coloque como LocalScript em StarterPlayer > StarterPlayerScripts.
-- O movimento padrão do Roblox continua cuidando do teclado, gamepad e controles touch.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local BASE_WALK_SPEED = 16
local MAX_WALK_SPEED = 42
local MAX_AIR_SPEED = 76
local AIR_ACCELERATION = 32
local AIR_DRAG = 0.985

local jumpHeld = false
local characterConnections = {}

local function disconnectCharacterConnections()
	for _, connection in characterConnections do
		connection:Disconnect()
	end
	table.clear(characterConnections)
end

local function setupCharacter(character)
	disconnectCharacterConnections()
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")

	humanoid.UseJumpPower = true
	humanoid.JumpPower = 50
	humanoid.WalkSpeed = BASE_WALK_SPEED

	local heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		if not character.Parent or humanoid.Health <= 0 then
			return
		end

		-- Segurar espaço ativa auto-hop; humanoid.Jump também respeita o botão touch padrão.
		if jumpHeld or humanoid.Jump then
			if humanoid.FloorMaterial ~= Enum.Material.Air then
				humanoid.Jump = true
			end
		end

		local velocity = root.AssemblyLinearVelocity
		local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
		local speed = horizontal.Magnitude

		if humanoid.FloorMaterial == Enum.Material.Air then
			local inputDirection = humanoid.MoveDirection
			inputDirection = Vector3.new(inputDirection.X, 0, inputDirection.Z)

			if inputDirection.Magnitude > 0.05 then
				inputDirection = inputDirection.Unit
				local accelerated = horizontal + inputDirection * AIR_ACCELERATION * deltaTime
				if accelerated.Magnitude > MAX_AIR_SPEED then
					accelerated = accelerated.Unit * MAX_AIR_SPEED
				end
				horizontal = accelerated
			else
				horizontal *= AIR_DRAG
			end

			root.AssemblyLinearVelocity = Vector3.new(horizontal.X, velocity.Y, horizontal.Z)
			speed = horizontal.Magnitude
		end

		-- Ajuste gradual de velocidade máxima no chão conforme o momentum adquirido.
		humanoid.WalkSpeed = math.clamp(BASE_WALK_SPEED + math.max(0, speed - BASE_WALK_SPEED) * 0.28, BASE_WALK_SPEED, MAX_WALK_SPEED)
	end)
	table.insert(characterConnections, heartbeatConnection)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.Space then
		jumpHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		jumpHeld = false
	end
end)

player.CharacterAdded:Connect(setupCharacter)
if player.Character then
	task.spawn(setupCharacter, player.Character)
end
