-- Procedural action and dribbling poses for all visible characters.
-- Uses Motor6D overlays, so no externally uploaded animation IDs are needed.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remotes = ReplicatedStorage:WaitForChild("FootballRemotes")
local feedbackEvent = remotes:WaitForChild("Feedback")

local motorCache = setmetatable({}, { __mode = "k" })
local actionStates = setmetatable({}, { __mode = "k" })
local dribblePhase = setmetatable({}, { __mode = "k" })

local function normalizedName(name)
	return string.lower((string.gsub(name, "%s+", "")))
end

local function getMotors(character)
	local cached = motorCache[character]
	if cached then return cached end

	local motors = {}
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("Motor6D") then
			local key = normalizedName(descendant.Name)
			if key == "righthip" then motors.RightHip = descendant end
			if key == "lefthip" then motors.LeftHip = descendant end
			if key == "rightknee" then motors.RightKnee = descendant end
			if key == "leftknee" then motors.LeftKnee = descendant end
			if key == "waist" then motors.Waist = descendant end
			if key == "rootjoint" or key == "root" then motors.Root = descendant end
			if key == "rightshoulder" then motors.RightShoulder = descendant end
			if key == "leftshoulder" then motors.LeftShoulder = descendant end
		end
	end
	motorCache[character] = motors
	return motors
end

local function setAngle(motors, name, x, y, z, weight)
	local motor = motors[name]
	if motor then
		motor.Transform = motor.Transform * CFrame.Angles(x * weight, y * weight, z * weight)
	end
end

local function ease(value)
	value = math.clamp(value, 0, 1)
	return value * value * (3 - 2 * value)
end

local function kickPose(motors, progress, power, isPass)
	local windupEnd = isPass and 0.20 or 0.27
	local strikeEnd = isPass and 0.48 or 0.53
	local windup = ease(progress / windupEnd)
	local strike = ease((progress - windupEnd) / (strikeEnd - windupEnd))
	local follow = 1 - ease((progress - strikeEnd) / (1 - strikeEnd))
	local peak = isPass and 0.8 or (1.0 + power * 0.48)

	local hipAngle
	if progress < windupEnd then
		hipAngle = -0.34 * windup
	elseif progress < strikeEnd then
		hipAngle = -0.34 + (peak + 0.34) * strike
	else
		hipAngle = peak * follow
	end

	local kneeAngle = progress < windupEnd and (0.18 * windup) or (0.52 * follow)
	setAngle(motors, "RightHip", hipAngle, 0, 0, 1)
	setAngle(motors, "RightKnee", -kneeAngle, 0, 0, 1)
	setAngle(motors, "LeftHip", -0.13 * follow, 0, 0, 1)
	setAngle(motors, "LeftKnee", 0.10 * follow, 0, 0, 1)
	setAngle(motors, "Waist", 0.05, 0.18 * follow, -0.10 * follow, 1)
	setAngle(motors, "Root", 0.03 * follow, -0.10 * follow, 0, 1)
	setAngle(motors, "LeftShoulder", -0.16 * follow, 0, -0.10 * follow, 1)
	setAngle(motors, "RightShoulder", 0.12 * follow, 0, 0.08 * follow, 1)
end

local function tacklePose(motors, progress)
	local enter = ease(progress / 0.22)
	local recover = 1 - ease((progress - 0.52) / 0.48)
	local weight = math.min(enter, recover)
	setAngle(motors, "Root", -0.18 * weight, 0, 0.04 * weight, 1)
	setAngle(motors, "Waist", -0.55 * weight, 0.08 * weight, 0, 1)
	setAngle(motors, "RightHip", 0.85 * weight, 0, 0, 1)
	setAngle(motors, "RightKnee", -0.28 * weight, 0, 0, 1)
	setAngle(motors, "LeftHip", -0.38 * weight, 0, 0, 1)
	setAngle(motors, "LeftKnee", 0.9 * weight, 0, 0, 1)
	setAngle(motors, "RightShoulder", -0.55 * weight, 0, -0.18 * weight, 1)
	setAngle(motors, "LeftShoulder", -0.55 * weight, 0, 0.18 * weight, 1)
end

feedbackEvent.OnClientEvent:Connect(function(player, action, power)
	local character = player and player.Character
	if not character then return end
	local duration = action == "SlideTackle" and 0.78 or (action == "Pass" and 0.46 or 0.62)
	actionStates[character] = {
		Name = action,
		Started = os.clock(),
		Duration = duration,
		Power = math.clamp(tonumber(power) or 0, 0, 1),
	}
	getMotors(character)
end)

RunService.PreSimulation:Connect(function(deltaTime)
	local carrierId = workspace:GetAttribute("BallCarrierUserId") or 0
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local motors = getMotors(character)
			local action = actionStates[character]
			if action then
				local progress = (os.clock() - action.Started) / action.Duration
				if progress >= 1 then
					actionStates[character] = nil
				else
					if action.Name == "SlideTackle" then
						tacklePose(motors, progress)
					else
						kickPose(motors, progress, action.Power, action.Name == "Pass")
					end
				end
			elseif carrierId == player.UserId then
				local root = character:FindFirstChild("HumanoidRootPart")
				local velocity = root and root.AssemblyLinearVelocity or Vector3.zero
				local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
				if speed > 1.5 then
					local phase = (dribblePhase[character] or 0) + deltaTime * (5.5 + speed * 0.04)
					dribblePhase[character] = phase % (math.pi * 2)
					local tap = math.sin(phase) * 0.16
					setAngle(motors, "RightHip", tap, 0, 0, 1)
					setAngle(motors, "LeftHip", -tap * 0.72, 0, 0, 1)
					setAngle(motors, "RightKnee", -math.max(0, tap) * 0.25, 0, 0, 1)
					setAngle(motors, "LeftKnee", math.max(0, tap) * 0.18, 0, 0, 1)
					setAngle(motors, "Waist", 0, math.sin(phase * 0.5) * 0.035, 0, 1)
				end
			end
		end
	end
end)
