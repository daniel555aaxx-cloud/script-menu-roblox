-- HUD: velocidade, tempo da tentativa, checkpoint, recorde e botão de reset.
-- Coloque como LocalScript em StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local resetEvent = ReplicatedStorage:WaitForChild("BhopReset")
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "BhopHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Mira discreta para orientar a câmera em primeira pessoa.
local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.fromScale(0.5, 0.5)
crosshair.Size = UDim2.fromOffset(5, 5)
crosshair.BackgroundColor3 = Color3.fromRGB(245, 250, 255)
crosshair.BorderSizePixel = 0
crosshair.ZIndex = 10
crosshair.Parent = gui
local crosshairCorner = Instance.new("UICorner")
crosshairCorner.CornerRadius = UDim.new(1, 0)
crosshairCorner.Parent = crosshair

local panel = Instance.new("Frame")
panel.Name = "StatsPanel"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 18)
panel.Size = UDim2.new(0, 380, 0, 108)
panel.BackgroundColor3 = Color3.fromRGB(17, 22, 34)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(65, 190, 255)
stroke.Transparency = 0.35
stroke.Thickness = 1.5
stroke.Parent = panel

local function makeLabel(name, position, size, textSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamSemibold
	label.TextColor3 = color or Color3.fromRGB(240, 245, 255)
	label.TextSize = textSize
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Text = "--"
	label.Parent = panel
	return label
end

local speedLabel = makeLabel("Speed", UDim2.new(0, 8, 0, 10), UDim2.new(0, 115, 0, 42), 25, Color3.fromRGB(83, 215, 255))
local timerLabel = makeLabel("Timer", UDim2.new(0, 132, 0, 10), UDim2.new(0, 115, 0, 42), 25)
local checkpointLabel = makeLabel("Checkpoint", UDim2.new(0, 260, 0, 10), UDim2.new(0, 110, 0, 42), 20, Color3.fromRGB(110, 255, 170))
local hintLabel = makeLabel("Hint", UDim2.new(0, 10, 0, 57), UDim2.new(0, 250, 0, 32), 13, Color3.fromRGB(177, 190, 210))
hintLabel.Text = "Segure ESPAÇO + alterne A/D no ar"

local resetButton = Instance.new("TextButton")
resetButton.Name = "ResetButton"
resetButton.Position = UDim2.new(1, -112, 0, 59)
resetButton.Size = UDim2.new(0, 100, 0, 30)
resetButton.BackgroundColor3 = Color3.fromRGB(38, 54, 77)
resetButton.BorderSizePixel = 0
resetButton.Font = Enum.Font.GothamBold
resetButton.Text = "RESET (R)"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextSize = 13
resetButton.Parent = panel
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = resetButton

local bestLabel = Instance.new("TextLabel")
bestLabel.Name = "BestTime"
bestLabel.AnchorPoint = Vector2.new(0.5, 0)
bestLabel.Position = UDim2.new(0.5, 0, 0, 135)
bestLabel.Size = UDim2.new(0, 280, 0, 26)
bestLabel.BackgroundTransparency = 1
bestLabel.Font = Enum.Font.GothamMedium
bestLabel.TextColor3 = Color3.fromRGB(255, 214, 105)
bestLabel.TextSize = 15
bestLabel.Parent = gui

local function requestReset()
	resetEvent:FireServer()
end
resetButton.Activated:Connect(requestReset)

UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.R then
		requestReset()
	end
end)

local function formatTime(seconds)
	return string.format("%02d:%05.2f", math.floor(seconds / 60), seconds % 60)
end

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local speed = 0
	if root then
		local velocity = root.AssemblyLinearVelocity
		speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	end
	speedLabel.Text = string.format("%.0f", speed)

	local startTime = player:GetAttribute("RunStartTime")
	local active = player:GetAttribute("RunActive")
	local finished = player:GetAttribute("RunFinished")
	if active and typeof(startTime) == "number" then
		timerLabel.Text = formatTime(workspace:GetServerTimeNow() - startTime)
	elseif finished then
		timerLabel.Text = formatTime(player:GetAttribute("LastRunTime") or 0)
	else
		timerLabel.Text = "00:00.00"
	end

	checkpointLabel.Text = "CP " .. tostring(player:GetAttribute("Checkpoint") or 0)
	local best = player:GetAttribute("BestTime") or 0
	bestLabel.Text = best > 0 and ("Recorde: " .. formatTime(best)) or "Toque na plataforma azul para iniciar"
end)
