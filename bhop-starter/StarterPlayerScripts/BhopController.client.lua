-- Bhop movement controller for this original Roblox experience.
-- First-person + Source-style ground friction/acceleration, air acceleration and air-strafe.
-- Put this LocalScript in StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Tune these values in Studio Play tests to set the feel/difficulty.
local FIRST_PERSON_FOV = 82
local GROUND_MAX_SPEED = 24
local GROUND_ACCEL = 14
local GROUND_FRICTION = 5.2
local STOP_SPEED = 7
local AIR_ACCEL = 20
local AIR_WISH_SPEED_CAP = 36
local AIR_DRAG = 0.01
local JUMP_SPEED = 52
local MAX_SPEED = 220
local JUMP_BUFFER_SECONDS = 0.12
local SURF_MIN_NORMAL_Y = 0.08
local SURF_MAX_NORMAL_Y = 0.88
local SURF_ACCEL = 8

local keysDown = {}
local jumpHeld = false
local jumpBufferUntil = 0
local controls
local currentConnection
local currentHumanoid

-- Get Roblox's standard control vector for thumbsticks and the mobile joystick.
pcall(function()
	local playerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
	controls = playerModule:GetControls()
end)

local function setFirstPerson()
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	player.CameraMinZoomDistance = 0.5
	player.CameraMaxZoomDistance = 0.5
	local camera = workspace.CurrentCamera
	if camera then
		camera.FieldOfView = FIRST_PERSON_FOV
	end
end

local function getInputVector(humanoid)
	local x = (keysDown[Enum.KeyCode.D] and 1 or 0) - (keysDown[Enum.KeyCode.A] and 1 or 0)
	local z = (keysDown[Enum.KeyCode.W] and 1 or 0) - (keysDown[Enum.KeyCode.S] and 1 or 0)

	if x ~= 0 or z ~= 0 then
		local magnitude = math.sqrt(x * x + z * z)
		return x / magnitude, z / magnitude
	end

	if controls then
		local move = controls:GetMoveVector()
		if move.Magnitude > 0.05 then
			local localX = move.X
			local localZ = -move.Z
			local magnitude = math.sqrt(localX * localX + localZ * localZ)
			return localX / magnitude, localZ / magnitude
		end
	end

	-- Fallback for Roblox control schemes that expose only Humanoid.MoveDirection.
	local direction = humanoid.MoveDirection
	local camera = workspace.CurrentCamera
	if direction.Magnitude > 0.05 and camera then
		local flatForward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
		local flatRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
		if flatForward.Magnitude > 0 and flatRight.Magnitude > 0 then
			flatForward = flatForward.Unit
			flatRight = flatRight.Unit
			return direction:Dot(flatRight), direction:Dot(flatForward)
		end
	end

	return 0, 0
end

local function getWishDirection(localX, localForward)
	if math.abs(localX) < 0.001 and math.abs(localForward) < 0.001 then
		return Vector3.zero
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return Vector3.zero
	end

	local forward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
	local right = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
	if forward.Magnitude < 0.001 or right.Magnitude < 0.001 then
		return Vector3.zero
	end

	local wish = right.Unit * localX + forward.Unit * localForward
	if wish.Magnitude > 1 then
		wish = wish.Unit
	end
	return wish
end

local function accelerate(velocity, wishDirection, wishSpeed, acceleration, deltaTime)
	if wishDirection.Magnitude < 0.001 or wishSpeed <= 0 then
		return velocity
	end

	local currentSpeed = velocity:Dot(wishDirection)
	local addSpeed = wishSpeed - currentSpeed
	if addSpeed <= 0 then
		return velocity
	end

	local accelerationSpeed = math.min(acceleration * wishSpeed * deltaTime, addSpeed)
	return velocity + wishDirection * accelerationSpeed
end

local function applyGroundFriction(velocity, deltaTime)
	local speed = velocity.Magnitude
	if speed < 0.01 then
		return Vector3.zero
	end

	local control = math.max(speed, STOP_SPEED)
	local newSpeed = math.max(0, speed - control * GROUND_FRICTION * deltaTime)
	return velocity * (newSpeed / speed)
end

local function getGroundHit(character, root, humanoid, raycastParams)
	local castLength = humanoid.HipHeight + root.Size.Y * 0.5 + 0.45
	return workspace:Raycast(root.Position, Vector3.new(0, -castLength, 0), raycastParams)
end

local function setupCharacter(character)
	if currentConnection then
		currentConnection:Disconnect()
		currentConnection = nil
	end

	setFirstPerson()
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")
	currentHumanoid = humanoid

	humanoid.UseJumpPower = true
	humanoid.JumpPower = 0 -- jump impulse is applied by this controller
	humanoid.WalkSpeed = 0 -- default locomotion is replaced by the bhop controller
	humanoid.AutoRotate = true

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }

	currentConnection = RunService.PreSimulation:Connect(function(deltaTime)
		if not character.Parent or humanoid.Health <= 0 or not root.Parent then
			return
		end

		local localX, localForward = getInputVector(humanoid)
		local wishDirection = getWishDirection(localX, localForward)
		local wishSpeed = wishDirection.Magnitude > 0 and GROUND_MAX_SPEED or 0
		local groundHit = getGroundHit(character, root, humanoid, raycastParams)
		local grounded = groundHit ~= nil and root.AssemblyLinearVelocity.Y <= 2
		local surfNormal
		local onSurf = false

		if groundHit then
			local hitPart = groundHit.Instance
			onSurf = hitPart:GetAttribute("SurfSurface") == true
				or hitPart:GetAttribute("MovementSurface") == "Surf"
			if onSurf and groundHit.Normal.Y >= SURF_MIN_NORMAL_Y and groundHit.Normal.Y <= SURF_MAX_NORMAL_Y then
				surfNormal = groundHit.Normal
			else
				onSurf = false
			end
		end

		local velocity = root.AssemblyLinearVelocity
		local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
		local wantsJump = jumpHeld or humanoid.Jump or os.clock() <= jumpBufferUntil

		-- Momentum-preserving auto-bhop: holding jump skips landing friction and jumps on contact.
		if grounded and wantsJump then
			velocity = Vector3.new(velocity.X, JUMP_SPEED, velocity.Z)
			humanoid.Jump = false
			jumpBufferUntil = 0
			horizontal = Vector3.new(velocity.X, 0, velocity.Z)
			-- A jump leaves the ramp plane; do not project away its upward impulse.
			onSurf = false
			surfNormal = nil
		elseif grounded and not onSurf then
			horizontal = applyGroundFriction(horizontal, deltaTime)
		end

		if onSurf and surfNormal then
			-- Surf ramps are ordinary parts tagged with the SurfSurface attribute.
			-- Project gravity and steering onto the ramp plane to preserve the glide.
			local fullGravity = Vector3.new(0, -workspace.Gravity, 0)
			local tangentGravity = fullGravity - surfNormal * fullGravity:Dot(surfNormal)
			velocity = velocity - surfNormal * velocity:Dot(surfNormal) + tangentGravity * deltaTime
			local projectedWish = wishDirection - surfNormal * wishDirection:Dot(surfNormal)
			if projectedWish.Magnitude > 0.001 then
				velocity = accelerate(velocity, projectedWish.Unit, GROUND_MAX_SPEED, SURF_ACCEL, deltaTime)
			end
		elseif grounded then
			horizontal = accelerate(horizontal, wishDirection, wishSpeed, GROUND_ACCEL, deltaTime)
			velocity = Vector3.new(horizontal.X, velocity.Y, horizontal.Z)
		else
			-- Source-style air acceleration: cap wish speed, not total momentum.
			local airWishSpeed = math.min(GROUND_MAX_SPEED * 1.5, AIR_WISH_SPEED_CAP)
			local airVelocity = Vector3.new(velocity.X, 0, velocity.Z)
			airVelocity = accelerate(airVelocity, wishDirection, airWishSpeed, AIR_ACCEL, deltaTime)
			airVelocity *= math.max(0, 1 - AIR_DRAG * deltaTime)
			velocity = Vector3.new(airVelocity.X, velocity.Y, airVelocity.Z)
		end

		local finalHorizontal = Vector3.new(velocity.X, 0, velocity.Z)
		if finalHorizontal.Magnitude > MAX_SPEED then
			finalHorizontal = finalHorizontal.Unit * MAX_SPEED
		end
		root.AssemblyLinearVelocity = Vector3.new(finalHorizontal.X, velocity.Y, finalHorizontal.Z)
	end)

	setFirstPerson()
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		keysDown[input.KeyCode] = true
	end

	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
		jumpHeld = true
		jumpBufferUntil = os.clock() + JUMP_BUFFER_SECONDS
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		keysDown[input.KeyCode] = nil
	end

	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
		jumpHeld = false
	end
end)

-- Enforce first person again if the character respawns or camera scripts reset.
player.CharacterAdded:Connect(setupCharacter)
if player.Character then
	task.spawn(setupCharacter, player.Character)
end
