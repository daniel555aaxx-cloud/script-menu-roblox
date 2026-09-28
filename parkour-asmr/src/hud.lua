--[[
	Parkour ASMR — HUD (LocalScript no StarterPlayerScripts)
	• Nome do mundo + barra de progresso dos níveis
	• Moedas, cronômetro e contador de mortes
	• Aviso de controles, pop-up de nível com sparkle
	• Tela de comemoração com tempo + confete
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

---------------------------------------------------------------
-- Mundos gerados pelo build (primeiro nível de cada mundo)
local WORLDS = {
__WORLDS_CONFIG__
}

---------------------------------------------------------------
-- Totais reais do mapa
local totalCheckpoints = 42
local totalCoins = 20
do
	local map = workspace:WaitForChild("ParkourMap", 15)
	local course = map and map:WaitForChild("Course", 8)
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
-- Barra de níveis (topo central)
local topBar = Instance.new("Frame")
topBar.Name = "LevelBar"
topBar.AnchorPoint = Vector2.new(0.5, 0)
topBar.Position = UDim2.new(0.5, 0, 0, 12)
topBar.Size = UDim2.fromOffset(370, 86)
topBar.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
topBar.BackgroundTransparency = 0.2
topBar.Parent = gui
addCorner(topBar, 12)
addStroke(topBar, Color3.fromRGB(0, 240, 255), 2)

local worldText = Instance.new("TextLabel")
worldText.Name = "World"
worldText.Position = UDim2.new(0, 12, 0, 6)
worldText.Size = UDim2.new(1, -24, 0, 18)
worldText.BackgroundTransparency = 1
worldText.Font = Enum.Font.GothamBold
worldText.TextSize = 14
worldText.Text = "LOBBY"
worldText.TextColor3 = Color3.fromRGB(120, 220, 255)
worldText.Parent = topBar

local cpText = Instance.new("TextLabel")
cpText.Name = "Value"
cpText.Position = UDim2.new(0, 12, 0, 26)
cpText.Size = UDim2.new(1, -20, 0, 26)
cpText.BackgroundTransparency = 1
cpText.Font = Enum.Font.GothamBold
cpText.TextSize = 21
cpText.Text = "NÍVEL 0 / " .. totalCheckpoints
cpText.TextColor3 = Color3.fromRGB(240, 245, 255)
cpText.Parent = topBar

local barBack = Instance.new("Frame")
barBack.Name = "BarBack"
barBack.Position = UDim2.new(0.06, 0, 0, 62)
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
-- Estatísticas (topo direito): moedas, tempo, mortes
local statsBar = Instance.new("Frame")
statsBar.Name = "Stats"
statsBar.AnchorPoint = Vector2.new(1, 0)
statsBar.Position = UDim2.new(1, -14, 0, 12)
statsBar.Size = UDim2.fromOffset(300, 46)
statsBar.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
statsBar.BackgroundTransparency = 0.2
statsBar.Parent = gui
addCorner(statsBar, 10)
addStroke(statsBar, Color3.fromRGB(255, 215, 80), 2)

local statsText = Instance.new("TextLabel")
statsText.Name = "Value"
statsText.Size = UDim2.fromScale(1, 1)
statsText.BackgroundTransparency = 1
statsText.Font = Enum.Font.GothamBold
statsText.TextSize = 17
statsText.Text = "Moedas 0    Tempo 0:00.00    Mortes 0"
statsText.TextColor3 = Color3.fromRGB(255, 230, 150)
statsText.Parent = statsBar

local coinShown = 0
local deaths = 0

local function renderStats(timeText)
	statsText.Text = string.format(
		"Moedas %d    Tempo %s    Mortes %d",
		coinShown, timeText, deaths
	)
end

---------------------------------------------------------------
-- Aviso de controles (some depois de um tempo)
local hint = Instance.new("Frame")
hint.Name = "Hint"
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -12)
hint.Size = UDim2.fromOffset(640, 42)
hint.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
hint.BackgroundTransparency = 0.35
hint.Parent = gui
addCorner(hint, 10)

local hintText = Instance.new("TextLabel")
hintText.Size = UDim2.fromScale(1, 1)
hintText.BackgroundTransparency = 1
hintText.Font = Enum.Font.Gotham
hintText.TextSize = 16
hintText.Text = "WASD andar   •   ESPACO pular   •   SHIFT correr   •   K ligar/desligar ASMR   •   R reiniciar"
hintText.TextColor3 = Color3.fromRGB(200, 235, 255)
hintText.Parent = hint

task.delay(10, function()
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
-- Pop-up de nível
local popup = Instance.new("TextLabel")
popup.Name = "Popup"
popup.AnchorPoint = Vector2.new(0.5, 0.5)
popup.Position = UDim2.new(0.5, 0, 0.2, 0)
popup.Size = UDim2.fromOffset(560, 70)
popup.BackgroundTransparency = 1
popup.Font = Enum.Font.GothamBlack
popup.TextSize = 42
popup.Text = "NÍVEL"
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
	popup.Position = UDim2.new(0.5, 0, 0.22, 0)
	local fadeIn = TweenService:Create(
		popup,
		TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.19, 0) }
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
-- Destaque local do nível tocado (cor + sparkle, só no cliente)
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

		local sparkle = pad:FindFirstChild("LocalSparkle")
		if not sparkle then
			sparkle = Instance.new("ParticleEmitter")
			sparkle.Name = "LocalSparkle"
			sparkle.Rate = 0
			sparkle.Lifetime = NumberRange.new(0.5, 1.1)
			sparkle.Speed = NumberRange.new(5, 10)
			sparkle.SpreadAngle = Vector2.new(75, 75)
			sparkle.Acceleration = Vector3.new(0, 6, 0)
			sparkle.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.45),
				NumberSequenceKeypoint.new(1, 0.05),
			})
			sparkle.Color = ColorSequence.new(
				Color3.fromRGB(140, 255, 190),
				Color3.fromRGB(255, 255, 255)
			)
			sparkle.LightEmission = 0.9
			sparkle.Parent = pad
		end
		sparkle:Emit(28)
	end
end

---------------------------------------------------------------
-- Cronômetro
local startTime = tick()
local finalTime = nil
local lastClock = ""

local function formatTime(t)
	local minutes = math.floor(t / 60)
	local seconds = t - minutes * 60
	return string.format("%d:%05.2f", minutes, seconds)
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
panel.Size = UDim2.fromOffset(500, 330)
panel.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
panel.BackgroundTransparency = 0.05
panel.ZIndex = 21
panel.Parent = overlay
addCorner(panel, 18)
addStroke(panel, Color3.fromRGB(255, 215, 80), 3)

local finishTitle = Instance.new("TextLabel")
finishTitle.AnchorPoint = Vector2.new(0.5, 0)
finishTitle.Position = UDim2.new(0.5, 0, 0, 32)
finishTitle.Size = UDim2.new(1, -40, 0, 60)
finishTitle.BackgroundTransparency = 1
finishTitle.Font = Enum.Font.GothamBlack
finishTitle.TextSize = 40
finishTitle.Text = "VOCE CONCLUIU!"
finishTitle.TextColor3 = Color3.fromRGB(255, 224, 110)
finishTitle.ZIndex = 22
finishTitle.Parent = panel

local finishStats = Instance.new("TextLabel")
finishStats.AnchorPoint = Vector2.new(0.5, 0)
finishStats.Position = UDim2.new(0.5, 0, 0, 112)
finishStats.Size = UDim2.new(1, -40, 0, 96)
finishStats.BackgroundTransparency = 1
finishStats.Font = Enum.Font.GothamBold
finishStats.TextSize = 21
finishStats.Text = ""
finishStats.TextColor3 = Color3.fromRGB(210, 235, 255)
finishStats.TextWrapped = true
finishStats.ZIndex = 22
finishStats.Parent = panel

local finishHint = Instance.new("TextLabel")
finishHint.AnchorPoint = Vector2.new(0.5, 0)
finishHint.Position = UDim2.new(0.5, 0, 0, 252)
finishHint.Size = UDim2.new(1, -40, 0, 44)
finishHint.BackgroundTransparency = 1
finishHint.Font = Enum.Font.Gotham
finishHint.TextSize = 17
finishHint.Text = "Aperte R para recomeçar — o cronômetro zera!"
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
	finalTime = tick() - startTime
	local coins = player:GetAttribute("Coins") or 0
	local level = player:GetAttribute("Checkpoint") or 0
	finishStats.Text = string.format(
		"Nível: %d / %d      Moedas: %d / %d\nTempo: %s      Mortes: %d",
		level, totalCheckpoints, coins, totalCoins,
		formatTime(finalTime), deaths
	)
	overlay.Visible = true
	panel.Size = UDim2.fromOffset(450, 292)
	local fadeIn = TweenService:Create(
		overlay,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.45 }
	)
	local panelIn = TweenService:Create(
		panel,
		TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = UDim2.fromOffset(500, 330) }
	)
	fadeIn:Play()
	panelIn:Play()
	burstConfetti(34)
	task.delay(1.1, function()
		burstConfetti(26)
	end)
end

local function resetRun()
	if not finishedShown then
		return
	end
	finishedShown = false
	finalTime = nil
	startTime = tick()
	overlay.Visible = false
end

---------------------------------------------------------------
-- Mundo atual
local function worldInfo(idx)
	local current = nil
	local number = nil
	for i, w in ipairs(WORLDS) do
		if idx >= w.first then
			current = w.name
			number = i
		else
			break
		end
	end
	return number, current
end

local function renderWorld(idx)
	if idx <= 0 then
		worldText.Text = "LOBBY — subindo até o céu"
		return
	end
	local number, name = worldInfo(idx)
	if number and name then
		worldText.Text = string.format(
			"MUNDO %d/%d — %s", number, #WORLDS, name
		)
	else
		worldText.Text = "NÍVEL ALTO"
	end
end

---------------------------------------------------------------
-- Progresso e reações aos atributos
local function refreshProgress()
	local idx = player:GetAttribute("Checkpoint") or 0
	cpText.Text = "NÍVEL " .. idx .. " / " .. totalCheckpoints
	renderWorld(idx)
	local ratio = math.clamp(idx / math.max(totalCheckpoints, 1), 0, 1)
	local tween = TweenService:Create(
		barFill,
		TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.fromScale(ratio, 1) }
	)
	tween:Play()
end

local function refreshCoins()
	coinShown = player:GetAttribute("Coins") or 0
	statsText.TextSize = 20
	renderStats(lastClock ~= "" and lastClock or "0:00.00")
	task.delay(0.15, function()
		statsText.TextSize = 17
	end)
end

player:GetAttributeChangedSignal("Checkpoint"):Connect(function()
	local idx = player:GetAttribute("Checkpoint") or 0
	if idx > 0 then
		refreshProgress()
		showPopup("NÍVEL " .. idx .. "  ✔")
		flashPad(idx)
	end
end)

player:GetAttributeChangedSignal("Coins"):Connect(refreshCoins)

player:GetAttributeChangedSignal("Finished"):Connect(function()
	if player:GetAttribute("Finished") then
		showFinish()
	else
		resetRun()
	end
end)

---------------------------------------------------------------
-- Morte = renascimento (reinicia a tentativa)
local seenCharacter = false
player.CharacterAdded:Connect(function()
	if seenCharacter then
		deaths = deaths + 1
		renderStats(lastClock ~= "" and lastClock or "0:00.00")
	end
	seenCharacter = true
end)

---------------------------------------------------------------
-- Relógio
RunService.Heartbeat:Connect(function()
	local t = finalTime or (tick() - startTime)
	local txt = formatTime(t)
	if txt ~= lastClock then
		lastClock = txt
		renderStats(txt)
	end
end)

refreshProgress()
refreshCoins()
renderStats("0:00.00")
