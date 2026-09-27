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

local function getAimDirection()
	local camera = workspace.CurrentCamera
	return camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
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
	actionEvent:FireServer("Shoot", getAimDirection(), charge)
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
