-- Match scoreboard, goal callout, possession state and stamina/shot bars.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local touchMode = UserInputService.TouchEnabled
local gui = Instance.new("ScreenGui")
gui.Name = "ArenaFootballHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

local scorePanel = Instance.new("Frame")
scorePanel.Name = "Scoreboard"
scorePanel.AnchorPoint = Vector2.new(0.5, 0)
scorePanel.Position = UDim2.new(0.5, 0, 0, 18)
scorePanel.Size = UDim2.new(0.9, 0, 0, 82)
local scoreConstraint = Instance.new("UISizeConstraint")
scoreConstraint.MinSize = Vector2.new(300, 82)
scoreConstraint.MaxSize = Vector2.new(470, 100)
scoreConstraint.Parent = scorePanel
scorePanel.BackgroundColor3 = Color3.fromRGB(14, 20, 28)
scorePanel.BackgroundTransparency = 0.12
scorePanel.BorderSizePixel = 0
scorePanel.Parent = gui
addCorner(scorePanel, 12)
local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(190, 205, 220)
panelStroke.Transparency = 0.68
panelStroke.Parent = scorePanel

local scoreText = Instance.new("TextLabel")
scoreText.Name = "Score"
scoreText.Position = UDim2.new(0, 10, 0, 7)
scoreText.Size = UDim2.new(1, -20, 0, 38)
scoreText.BackgroundTransparency = 1
scoreText.Font = Enum.Font.GothamBlack
scoreText.TextColor3 = Color3.fromRGB(250, 250, 247)
scoreText.TextSize = 24
scoreText.TextScaled = true
local scoreTextConstraint = Instance.new("UITextSizeConstraint")
scoreTextConstraint.MinTextSize = 14
scoreTextConstraint.MaxTextSize = 24
scoreTextConstraint.Parent = scoreText
scoreText.Text = "RUBRO FC   0 — 0   AZUL FC"
scoreText.Parent = scorePanel

local timerText = Instance.new("TextLabel")
timerText.Name = "Timer"
timerText.Position = UDim2.new(0, 10, 0, 46)
timerText.Size = UDim2.new(1, -20, 0, 24)
timerText.BackgroundTransparency = 1
timerText.Font = Enum.Font.GothamBold
timerText.TextColor3 = Color3.fromRGB(174, 205, 232)
timerText.TextSize = 16
timerText.Text = "03:00"
timerText.Parent = scorePanel

local goalCallout = Instance.new("TextLabel")
goalCallout.Name = "GoalCallout"
goalCallout.AnchorPoint = Vector2.new(0.5, 0.5)
goalCallout.Position = UDim2.new(0.5, 0, 0.27, 0)
goalCallout.Size = UDim2.new(0.9, 0, 0, 64)
local goalConstraint = Instance.new("UISizeConstraint")
goalConstraint.MinSize = Vector2.new(300, 64)
goalConstraint.MaxSize = Vector2.new(500, 80)
goalConstraint.Parent = goalCallout
goalCallout.BackgroundColor3 = Color3.fromRGB(12, 18, 25)
goalCallout.BackgroundTransparency = 0.15
goalCallout.BorderSizePixel = 0
goalCallout.Font = Enum.Font.GothamBlack
goalCallout.TextColor3 = Color3.fromRGB(255, 226, 105)
goalCallout.TextSize = touchMode and 22 or 32
goalCallout.Text = ""
goalCallout.Visible = false
goalCallout.Parent = gui
addCorner(goalCallout, 12)

local possessionText = Instance.new("TextLabel")
possessionText.Name = "Possession"
possessionText.AnchorPoint = Vector2.new(0.5, 1)
possessionText.Position = touchMode and UDim2.new(0.5, 0, 1, -198) or UDim2.new(0.5, 0, 1, -30)
possessionText.Size = UDim2.new(0.9, 0, 0, 34)
local possessionConstraint = Instance.new("UISizeConstraint")
possessionConstraint.MinSize = Vector2.new(270, 34)
possessionConstraint.MaxSize = Vector2.new(500, 46)
possessionConstraint.Parent = possessionText
possessionText.BackgroundColor3 = Color3.fromRGB(15, 22, 30)
possessionText.BackgroundTransparency = 0.22
possessionText.BorderSizePixel = 0
possessionText.Font = Enum.Font.GothamBold
possessionText.TextColor3 = Color3.fromRGB(245, 247, 250)
possessionText.TextSize = touchMode and 12 or 16
possessionText.Text = "Aproxime-se da bola"
possessionText.Parent = gui
addCorner(possessionText, 9)

local staminaFrame = Instance.new("Frame")
staminaFrame.Name = "StaminaFrame"
staminaFrame.AnchorPoint = Vector2.new(0, 1)
staminaFrame.Position = touchMode and UDim2.new(0, 16, 0, 128) or UDim2.new(0, 24, 1, -28)
staminaFrame.Size = UDim2.new(0, touchMode and 190 or 220, 0, 24)
staminaFrame.BackgroundColor3 = Color3.fromRGB(19, 26, 31)
staminaFrame.BorderSizePixel = 0
staminaFrame.Parent = gui
addCorner(staminaFrame, 8)
local staminaFill = Instance.new("Frame")
staminaFill.Name = "Fill"
staminaFill.Position = UDim2.new(0, 3, 0, 3)
staminaFill.Size = UDim2.new(1, -6, 1, -6)
staminaFill.BackgroundColor3 = Color3.fromRGB(72, 220, 135)
staminaFill.BorderSizePixel = 0
staminaFill.Parent = staminaFrame
addCorner(staminaFill, 6)
local staminaText = Instance.new("TextLabel")
staminaText.Name = "Label"
staminaText.Size = UDim2.fromScale(1, 1)
staminaText.BackgroundTransparency = 1
staminaText.Font = Enum.Font.GothamBold
staminaText.TextColor3 = Color3.new(1, 1, 1)
staminaText.TextSize = 12
staminaText.Text = "FÔLEGO 100%"
staminaText.ZIndex = 2
staminaText.Parent = staminaFrame

local chargeFrame = Instance.new("Frame")
chargeFrame.Name = "ShotChargeFrame"
chargeFrame.AnchorPoint = Vector2.new(0.5, 1)
chargeFrame.Position = touchMode and UDim2.new(0.5, 0, 1, -270) or UDim2.new(0.5, 0, 1, -75)
chargeFrame.Size = UDim2.new(0, 250, 0, 18)
chargeFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
chargeFrame.BorderSizePixel = 0
chargeFrame.Visible = false
chargeFrame.Parent = gui
addCorner(chargeFrame, 7)
local chargeFill = Instance.new("Frame")
chargeFill.Name = "Fill"
chargeFill.Size = UDim2.new(0, 0, 1, 0)
chargeFill.BackgroundColor3 = Color3.fromRGB(255, 190, 57)
chargeFill.BorderSizePixel = 0
chargeFill.Parent = chargeFrame
addCorner(chargeFill, 7)

local hint = Instance.new("TextLabel")
hint.Name = "ControlsHint"
hint.Visible = not touchMode
hint.AnchorPoint = Vector2.new(0, 1)
hint.Position = UDim2.new(0, 24, 1, -60)
hint.Size = UDim2.new(0, 340, 0, 30)
hint.BackgroundTransparency = 1
hint.Font = Enum.Font.GothamMedium
hint.TextColor3 = Color3.fromRGB(222, 230, 236)
hint.TextSize = 12
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Text = "Shift correr • Clique/E chutar • Q passe • F desarme"
hint.Parent = gui

local lastGoalSequence = 0
local goalHideAt = 0
local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

RunService.RenderStepped:Connect(function()
	local homeName = workspace:GetAttribute("HomeName") or "RUBRO FC"
	local awayName = workspace:GetAttribute("AwayName") or "AZUL FC"
	local homeScore = workspace:GetAttribute("HomeScore") or 0
	local awayScore = workspace:GetAttribute("AwayScore") or 0
	scoreText.Text = string.format("%s   %d — %d   %s", homeName, homeScore, awayScore, awayName)

	local startedAt = workspace:GetAttribute("MatchStartedAt") or 0
	local duration = workspace:GetAttribute("MatchDuration") or 180
	local ended = workspace:GetAttribute("MatchEnded") == true
	if startedAt <= 0 then
		timerText.Text = "AGUARDANDO JOGADORES"
	elseif ended then
		timerText.Text = "FIM DE JOGO"
	else
		timerText.Text = formatTime(duration - (workspace:GetServerTimeNow() - startedAt))
	end

	local carrierId = workspace:GetAttribute("BallCarrierUserId") or 0
	if carrierId == player.UserId then
		possessionText.Text = "VOCÊ ESTÁ COM A BOLA  •  Clique/E chuta  •  Q passa"
	elseif carrierId == 0 then
		possessionText.Text = "DISPUTA A BOLA  •  Clique/E chuta ao dominar"
	else
		local carrier = Players:GetPlayerByUserId(carrierId)
		possessionText.Text = carrier and ("BOLA COM " .. string.upper(carrier.DisplayName)) or "BOLA EM JOGO"
	end

	local stamina = math.clamp(player:GetAttribute("Stamina") or 100, 0, 100)
	staminaFill.Size = UDim2.new(stamina / 100, -6 * stamina / 100, 1, -6)
	staminaText.Text = string.format("FÔLEGO %d%%", math.floor(stamina + 0.5))
	staminaFill.BackgroundColor3 = stamina < 25 and Color3.fromRGB(235, 87, 75) or Color3.fromRGB(72, 220, 135)

	local charge = math.clamp(player:GetAttribute("ShotCharge") or 0, 0, 1)
	chargeFrame.Visible = charge > 0 and carrierId == player.UserId
	chargeFill.Size = UDim2.new(charge, 0, 1, 0)
	chargeFill.BackgroundColor3 = Color3.fromRGB(255, math.floor(220 - charge * 100), 55)

	local message = workspace:GetAttribute("LastGoalMessage") or ""
	local sequence = workspace:GetAttribute("GoalSequence") or 0
	if message ~= "" and sequence ~= lastGoalSequence then
		lastGoalSequence = sequence
		goalCallout.Text = message
		goalCallout.Visible = true
		goalHideAt = os.clock() + 3
	end
	if goalCallout.Visible and os.clock() >= goalHideAt then
		goalCallout.Visible = false
	end
end)
