--[[
	Parkour ASMR — HUD (LocalScript no StarterPlayerScripts)
	• Barra de progresso dos checkpoints
	• Contador de moedas
	• Aviso de controles
	• Pop-up de checkpoint
	• Tela de comemoração + confete ao terminar
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

---------------------------------------------------------------
-- Descobre a quantidade total de checkpoints e moedas
local totalCheckpoints = 9
local totalCoins = 6
do
	local map = workspace:FindFirstChild("ParkourMap")
	local course = map and map:FindFirstChild("Course")
	if course then
		local cpFolder = course:FindFirstChild("Checkpoints")
		if cpFolder then
			local count = 0
			for _, item in ipairs(cpFolder:GetChildren()) do
				if string.match(item.Name, "^Checkpoint_%d+$") then
					count = count + 1
				end
			end
			if count > 0 then
				totalCheckpoints = count
			end
		end
		local coinFolder = course:FindFirstChild("Coins")
		if coinFolder then
			local count = #coinFolder:GetChildren()
			if count > 0 then
				totalCoins = count
			end
		end
	end
end

---------------------------------------------------------------
-- GUI base
local gui = Instance.new("ScreenGui")
gui.Name = "ParkourHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 8
gui.Parent = player:WaitForChild("PlayerGui")

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function addStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = 0.2
	stroke.Parent = parent
	return stroke
end

---------------------------------------------------------------
-- Barra de checkpoints (topo central)
local topBar = Instance.new("Frame")
topBar.Name = "CheckpointBar"
topBar.AnchorPoint = Vector2.new(0.5, 0)
topBar.Position = UDim2.new(0.5, 0, 0, 14)
topBar.Size = UDim2.fromOffset(330, 66)
topBar.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
topBar.BackgroundTransparency = 0.2
topBar.Parent = gui
addCorner(topBar, 12)
addStroke(topBar, Color3.fromRGB(0, 240, 255), 2)

local cpText = Instance.new("TextLabel")
cpText.Name = "Value"
cpText.Position = UDim2.new(0, 10, 0, 7)
cpText.Size = UDim2.new(1, -20, 0, 24)
cpText.BackgroundTransparency = 1
cpText.Font = Enum.Font.GothamBold
cpText.TextSize = 19
cpText.Text = "CHECKPOINT 0 / " .. totalCheckpoints
cpText.TextColor3 = Color3.fromRGB(240, 245, 255)
cpText.Parent = topBar

local barBack = Instance.new("Frame")
barBack.Name = "BarBack"
barBack.Position = UDim2.new(0.06, 0, 0, 44)
barBack.Size = UDim2.new(0.88, 0, 0, 10)
barBack.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
barBack.BorderSizePixel = 0
barBack.Parent = topBar
addCorner(barBack, 5)

local barFill = Instance.new("Frame")
barFill.Name = "Fill"
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = Color3.fromRGB(80, 255, 165)
barFill.BorderSizePixel = 0
barFill.Parent = barBack
addCorner(barFill, 5)

---------------------------------------------------------------
-- Contador de moedas (topo direito)
local coinBar = Instance.new("Frame")
coinBar.Name = "CoinBar"
coinBar.AnchorPoint = Vector2.new(1, 0)
coinBar.Position = UDim2.new(1, -14, 0, 14)
coinBar.Size = UDim2.fromOffset(150, 46)
coinBar.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
coinBar.BackgroundTransparency = 0.2
coinBar.Parent = gui
addCorner(coinBar, 10)
addStroke(coinBar, Color3.fromRGB(255, 215, 80), 2)

local coinText = Instance.new("TextLabel")
coinText.Name = "Value"
coinText.Size = UDim2.fromScale(1, 1)
coinText.BackgroundTransparency = 1
coinText.Font = Enum.Font.GothamBold
coinText.TextSize = 21
coinText.Text = "Moedas: 0"
coinText.TextColor3 = Color3.fromRGB(255, 224, 120)
coinText.Parent = coinBar

---------------------------------------------------------------
-- Aviso de controles (some depois de um tempo)
local hint = Instance.new("Frame")
hint.Name = "Hint"
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -14)
hint.Size = UDim2.fromOffset(600, 44)
hint.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
hint.BackgroundTransparency = 0.35
hint.Parent = gui
addCorner(hint, 10)

local hintText = Instance.new("TextLabel")
hintText.Size = UDim2.fromScale(1, 1)
hintText.BackgroundTransparency = 1
hintText.Font = Enum.Font.Gotham
hintText.TextSize = 17
hintText.Text = "WASD andar   •   ESPACO pular   •   SHIFT correr   •   K ligar/desligar ASMR"
hintText.TextColor3 = Color3.fromRGB(200, 235, 255)
hintText.Parent = hint

task.delay(9, function()
	local tweenOut = TweenService:Create(
		hint,
		TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ BackgroundTransparency = 1 }
	)
	local textOut = TweenService:Create(
		hintText,
		TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ TextTransparency = 1 }
	)
	tweenOut:Play()
	textOut:Play()
end)

---------------------------------------------------------------
-- Pop-up de checkpoint
local popup = Instance.new("TextLabel")
popup.Name = "Popup"
popup.AnchorPoint = Vector2.new(0.5, 0.5)
popup.Position = UDim2.new(0.5, 0, 0.18, 0)
popup.Size = UDim2.fromOffset(560, 70)
popup.BackgroundTransparency = 1
popup.Font = Enum.Font.GothamBlack
popup.TextSize = 42
popup.Text = "CHECKPOINT"
popup.TextColor3 = Color3.fromRGB(110, 255, 170)
popup.TextTransparency = 1
popup.TextStrokeColor3 = Color3.fromRGB(10, 30, 20)
popup.TextStrokeTransparency = 0.5
popup.Parent = gui

local popupBusy = false

local function showPopup(text)
	if popupBusy then
		return
	end
	popupBusy = true
	popup.Text = text
	popup.TextTransparency = 1
	popup.Position = UDim2.new(0.5, 0, 0.2, 0)
	local fadeIn = TweenService:Create(
		popup,
		TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.17, 0) }
	)
	fadeIn:Play()
	fadeIn.Completed:Wait()
	task.delay(1.4, function()
		local fadeOut = TweenService:Create(
			popup,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ TextTransparency = 1 }
		)
		fadeOut:Play()
		fadeOut.Completed:Wait()
		popupBusy = false
	end)
end

---------------------------------------------------------------
-- Destaque local do pad tocado (só visual, no cliente)
local function flashPad(idx)
	local map = workspace:FindFirstChild("ParkourMap")
	if not map then
		return
	end
	local pad = map:FindFirstChild("Checkpoint_" .. idx, true)
	if pad and pad:IsA("BasePart") then
		local original = pad.Color
		pad.Color = Color3.fromRGB(255, 255, 255)
		task.delay(0.28, function()
			if pad.Parent then
				pad.Color = original
			end
		end)
	end
end

---------------------------------------------------------------
-- Tela de comemoração + confete
local overlay = Instance.new("Frame")
overlay.Name = "FinishOverlay"
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(5, 6, 10)
overlay.BackgroundTransparency = 1
overlay.Visible = false
overlay.ZIndex = 20
overlay.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(480, 300)
panel.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
panel.BackgroundTransparency = 0.05
panel.ZIndex = 21
panel.Parent = overlay
addCorner(panel, 18)
addStroke(panel, Color3.fromRGB(255, 215, 80), 3)

local finishTitle = Instance.new("TextLabel")
finishTitle.AnchorPoint = Vector2.new(0.5, 0)
finishTitle.Position = UDim2.new(0.5, 0, 0, 34)
finishTitle.Size = UDim2.new(1, -40, 0, 64)
finishTitle.BackgroundTransparency = 1
finishTitle.Font = Enum.Font.GothamBlack
finishTitle.TextSize = 40
finishTitle.Text = "VOCE CONCLUIU!"
finishTitle.TextColor3 = Color3.fromRGB(255, 224, 110)
finishTitle.ZIndex = 22
finishTitle.Parent = panel

local finishStats = Instance.new("TextLabel")
finishStats.AnchorPoint = Vector2.new(0.5, 0)
finishStats.Position = UDim2.new(0.5, 0, 0, 120)
finishStats.Size = UDim2.new(1, -40, 0, 60)
finishStats.BackgroundTransparency = 1
finishStats.Font = Enum.Font.GothamBold
finishStats.TextSize = 22
finishStats.Text = ""
finishStats.TextColor3 = Color3.fromRGB(210, 235, 255)
finishStats.ZIndex = 22
finishStats.Parent = panel

local finishHint = Instance.new("TextLabel")
finishHint.AnchorPoint = Vector2.new(0.5, 0)
finishHint.Position = UDim2.new(0.5, 0, 0, 210)
finishHint.Size = UDim2.new(1, -40, 0, 44)
finishHint.BackgroundTransparency = 1
finishHint.Font = Enum.Font.Gotham
finishHint.TextSize = 17
finishHint.Text = "Aperte R para recomeçar e bater seu recorde!"
finishHint.TextColor3 = Color3.fromRGB(160, 200, 230)
finishHint.ZIndex = 22
finishHint.Parent = panel

local confettiLayer = Instance.new("Frame")
confettiLayer.Name = "Confetti"
confettiLayer.Size = UDim2.fromScale(1, 1)
confettiLayer.BackgroundTransparency = 1
confettiLayer.ZIndex = 30
confettiLayer.Parent = overlay

local function burstConfetti(amount)
	for _ = 1, amount do
		local piece = Instance.new("Frame")
		piece.Size = UDim2.fromOffset(6 + math.random(9), 10 + math.random(12))
		piece.BackgroundColor3 = Color3.fromHSV(math.random(), 0.8, 1)
		piece.BorderSizePixel = 0
		piece.Position = UDim2.fromScale(math.random(), -0.12)
		piece.Rotation = math.random(360)
		piece.ZIndex = 31
		piece.Parent = confettiLayer
		local fall = TweenService:Create(
			piece,
			TweenInfo.new(2.4 + math.random() * 1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{
				Position = UDim2.fromScale(math.random(), 1.15),
				Rotation = piece.Rotation + (math.random(2) == 1 and 360 or -360),
			}
		)
		task.delay(math.random() * 1.0, function()
			fall:Play()
		end)
		fall.Completed:Connect(function()
			piece:Destroy()
		end)
	end
end

local finishedShown = false

local function showFinish()
	if finishedShown then
		return
	end
	finishedShown = true
	local coins = player:GetAttribute("Coins") or 0
	local cp = player:GetAttribute("Checkpoint") or 0
	finishStats.Text = string.format(
		"Checkpoints: %d / %d      Moedas: %d / %d",
		cp,
		totalCheckpoints,
		coins,
		totalCoins
	)
	overlay.Visible = true
	panel.Size = UDim2.fromOffset(430, 264)
	local fadeIn = TweenService:Create(
		overlay,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.45 }
	)
	local panelIn = TweenService:Create(
		panel,
		TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = UDim2.fromOffset(480, 300) }
	)
	fadeIn:Play()
	panelIn:Play()
	burstConfetti(30)
	task.delay(1.1, function()
		burstConfetti(24)
	end)
end

---------------------------------------------------------------
-- Reações aos atributos do jogador
local function refreshProgress()
	local idx = player:GetAttribute("Checkpoint") or 0
	cpText.Text = "CHECKPOINT " .. idx .. " / " .. totalCheckpoints
	local ratio = math.clamp(idx / math.max(totalCheckpoints, 1), 0, 1)
	local tween = TweenService:Create(
		barFill,
		TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.fromScale(ratio, 1) }
	)
	tween:Play()
end

local function refreshCoins()
	local coins = player:GetAttribute("Coins") or 0
	coinText.Text = "Moedas: " .. coins
	coinText.TextSize = 25
	task.delay(0.15, function()
		coinText.TextSize = 21
	end)
end

player:GetAttributeChangedSignal("Checkpoint"):Connect(function()
	local idx = player:GetAttribute("Checkpoint") or 0
	if idx > 0 then
		refreshProgress()
		showPopup("CHECKPOINT " .. idx .. "  ✔")
		flashPad(idx)
	end
end)

player:GetAttributeChangedSignal("Coins"):Connect(refreshCoins)

player:GetAttributeChangedSignal("Finished"):Connect(function()
	if player:GetAttribute("Finished") then
		showFinish()
	end
end)

refreshProgress()
refreshCoins()
