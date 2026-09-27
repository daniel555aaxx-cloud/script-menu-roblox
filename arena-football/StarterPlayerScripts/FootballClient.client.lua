-- Client input/camera for ARENA FOOTBALL. Server validates all ball actions.
-- Controls: WASD, Shift sprint, hold mouse 1/E to charge a shot, Q pass, F tackle.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("FootballRemotes")
local actionEvent = remotes:WaitForChild("Action")
local sprintEvent = remotes:WaitForChild("Sprint")

player.CameraMode = Enum.CameraMode.Classic
player.CameraMinZoomDistance = 9
player.CameraMaxZoomDistance = 18

local charging = false
local chargeStartedAt = 0
local sprinting = false
local mobileGui

local function hasBall()
	return (workspace:GetAttribute("BallCarrierUserId") or 0) == player.UserId
end

local function getAimPoint()
	local camera = workspace.CurrentCamera
	if not camera then return Vector3.new(0, 0, 0) end

	local viewport = camera.ViewportSize
	local ray = camera:ViewportPointToRay(viewport.X * 0.5, viewport.Y * 0.5)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local excluded = {}
	if player.Character then table.insert(excluded, player.Character) end
	local ball = workspace:FindFirstChild("ArenaFootball") and workspace.ArenaFootball:FindFirstChild("MatchBall")
	if ball then table.insert(excluded, ball) end
	params.FilterDescendantsInstances = excluded

	local result = workspace:Raycast(ray.Origin, ray.Direction * 700, params)
	if result then return result.Position end

	-- When the reticle points above the horizon, project a usable target ahead.
	local direction = ray.Direction
	if direction.Y < -0.04 then
		local distance = -ray.Origin.Y / direction.Y
		if distance > 2 and distance < 700 then
			return ray.Origin + direction * distance
		end
	end
	local flat = Vector3.new(direction.X, 0, direction.Z)
	if flat.Magnitude < 0.01 then flat = Vector3.new(0, 0, -1) end
	local fallbackTarget = ray.Origin + flat.Unit * 400
	return Vector3.new(fallbackTarget.X, 0, fallbackTarget.Z)
end

local function beginShot()
	if not hasBall() or charging then return end
	charging = true
	chargeStartedAt = os.clock()
	player:SetAttribute("ShotCharge", 0)
end

local function releaseShot()
	if not charging then return end
	charging = false
	local charge = math.clamp((os.clock() - chargeStartedAt) / 1.15, 0.15, 1)
	player:SetAttribute("ShotCharge", 0)
	actionEvent:FireServer("Shoot", getAimPoint(), charge)
end

local function passBall()
	if hasBall() then
		actionEvent:FireServer("Pass")
	end
end

local function tackle()
	actionEvent:FireServer("Tackle")
end

local function setSprint(active)
	if sprinting == active then return end
	sprinting = active
	sprintEvent:FireServer(active)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.KeyCode == Enum.KeyCode.E
		or input.KeyCode == Enum.KeyCode.ButtonR2 then
		beginShot()
	elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonX then
		passBall()
	elseif input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonB then
		tackle()
	elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL3 then
		setSprint(true)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.KeyCode == Enum.KeyCode.E
		or input.KeyCode == Enum.KeyCode.ButtonR2 then
		releaseShot()
	elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL3 then
		setSprint(false)
	end
end)

-- Touch controls for phones/tablets: charge shot by holding its button.
if UserInputService.TouchEnabled then
	local gui = Instance.new("ScreenGui")
	gui.Name = "FootballTouchControls"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = player:WaitForChild("PlayerGui")
	mobileGui = gui

	local tray = Instance.new("Frame")
	tray.Name = "ActionTray"
	tray.AnchorPoint = Vector2.new(1, 1)
	tray.Position = UDim2.new(1, -18, 1, -22)
	tray.Size = UDim2.fromOffset(230, 170)
	tray.BackgroundTransparency = 1
	tray.Parent = gui

	local function makeButton(name, title, position, size, color)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Position = position
		button.Size = size
		button.BackgroundColor3 = color
		button.BackgroundTransparency = 0.12
		button.BorderSizePixel = 0
		button.Font = Enum.Font.GothamBold
		button.Text = title
		button.TextColor3 = Color3.new(1, 1, 1)
		button.TextSize = 14
		button.TextWrapped = true
		button.Parent = tray
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = button
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(240, 240, 240)
		stroke.Transparency = 0.68
		stroke.Parent = button
		return button
	end

	local shootButton = makeButton("Shoot", "CHUTE", UDim2.fromOffset(139, 76), UDim2.fromOffset(82, 82), Color3.fromRGB(202, 65, 51))
	shootButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			beginShot()
		end
	end)
	shootButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			releaseShot()
		end
	end)

	local passButton = makeButton("Pass", "PASSE", UDim2.fromOffset(73, 95), UDim2.fromOffset(60, 60), Color3.fromRGB(47, 112, 190))
	passButton.Activated:Connect(passBall)
	local tackleButton = makeButton("Tackle", "DESARME", UDim2.fromOffset(8, 45), UDim2.fromOffset(68, 68), Color3.fromRGB(210, 137, 44))
	tackleButton.Activated:Connect(tackle)
	local sprintButton = makeButton("Sprint", "CORRER", UDim2.fromOffset(78, 22), UDim2.fromOffset(60, 58), Color3.fromRGB(50, 130, 87))
	sprintButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then setSprint(true) end
	end)
	sprintButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then setSprint(false) end
	end)
end

RunService.RenderStepped:Connect(function()
	if charging then
		player:SetAttribute("ShotCharge", math.clamp((os.clock() - chargeStartedAt) / 1.15, 0, 1))
	end
end)

player.CharacterAdded:Connect(function()
	charging = false
	setSprint(false)
end)
