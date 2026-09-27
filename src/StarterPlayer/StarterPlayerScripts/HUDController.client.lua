--[[
    HUDController.client.lua
    Monta toda a interface do jogo em runtime (sem precisar de nenhum
    arquivo de UI serializado): timer, stamina, contador de ratinhos,
    avisos de checkpoint, splash de água e tela de finalização.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CheckpointReached = Remotes:WaitForChild("CheckpointReached")
local WaterSplash = Remotes:WaitForChild("WaterSplash")
local RaceFinished = Remotes:WaitForChild("RaceFinished")
local CollectibleGrabbed = Remotes:WaitForChild("CollectibleGrabbed")
local SequenceState = Remotes:WaitForChild("SequenceState")
local KeypadFeedback = Remotes:WaitForChild("KeypadFeedback")
local RequestFullReset = Remotes:WaitForChild("RequestFullReset")

-- ============= Base da UI =============

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CatHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 10)
    corner.Parent = parent
    return corner
end

local function makeStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 1.5
    stroke.Transparency = 0.4
    stroke.Parent = parent
    return stroke
end

-- ===== Timer (topo-esquerda) =====
local timerFrame = Instance.new("Frame")
timerFrame.Size = UDim2.fromOffset(160, 46)
timerFrame.Position = UDim2.new(0, 16, 0, 16)
timerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
timerFrame.BackgroundTransparency = 0.25
timerFrame.Parent = screenGui
makeCorner(timerFrame)
makeStroke(timerFrame, Color3.fromRGB(255, 200, 120))

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.fromScale(1, 1)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "00:00.0"
timerLabel.TextColor3 = Color3.fromRGB(255, 240, 210)
timerLabel.Font = Enum.Font.Code
timerLabel.TextScaled = true
timerLabel.Parent = timerFrame

-- ===== Stamina bar (topo-direita) =====
local staminaFrame = Instance.new("Frame")
staminaFrame.Size = UDim2.fromOffset(220, 20)
staminaFrame.Position = UDim2.new(1, -236, 0, 16)
staminaFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
staminaFrame.BackgroundTransparency = 0.25
staminaFrame.Parent = screenGui
makeCorner(staminaFrame, UDim.new(1, 0))
makeStroke(staminaFrame, Color3.fromRGB(120, 230, 255))

local staminaFill = Instance.new("Frame")
staminaFill.Size = UDim2.fromScale(1, 1)
staminaFill.BackgroundColor3 = Color3.fromRGB(120, 230, 255)
staminaFill.BorderSizePixel = 0
staminaFill.Parent = staminaFrame
makeCorner(staminaFill, UDim.new(1, 0))

local staminaLabel = Instance.new("TextLabel")
staminaLabel.Size = UDim2.fromScale(1, 1)
staminaLabel.BackgroundTransparency = 1
staminaLabel.Text = "FÔLEGO"
staminaLabel.TextColor3 = Color3.fromRGB(20, 20, 26)
staminaLabel.Font = Enum.Font.FredokaOne
staminaLabel.TextScaled = true
staminaLabel.ZIndex = 2
staminaLabel.Parent = staminaFrame

-- ===== Contador de ratinhos (abaixo da stamina) =====
local mouseFrame = Instance.new("Frame")
mouseFrame.Size = UDim2.fromOffset(220, 32)
mouseFrame.Position = UDim2.new(1, -236, 0, 44)
mouseFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
mouseFrame.BackgroundTransparency = 0.25
mouseFrame.Parent = screenGui
mouseFrame.Visible = false
makeCorner(mouseFrame)
makeStroke(mouseFrame, Color3.fromRGB(255, 180, 120))

local mouseLabel = Instance.new("TextLabel")
mouseLabel.Size = UDim2.fromScale(1, 1)
mouseLabel.BackgroundTransparency = 1
mouseLabel.Text = "🐭 Ratinhos: 0/3"
mouseLabel.TextColor3 = Color3.fromRGB(255, 230, 210)
mouseLabel.Font = Enum.Font.FredokaOne
mouseLabel.TextScaled = true
mouseLabel.Parent = mouseFrame

-- ===== Toasts (avisos, centro-inferior) =====
local toastContainer = Instance.new("Frame")
toastContainer.Size = UDim2.new(0, 480, 0, 200)
toastContainer.AnchorPoint = Vector2.new(0.5, 1)
toastContainer.Position = UDim2.new(0.5, 0, 1, -60)
toastContainer.BackgroundTransparency = 1
toastContainer.Parent = screenGui

local toastLayout = Instance.new("UIListLayout")
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.Padding = UDim.new(0, 6)
toastLayout.Parent = toastContainer

local function showToast(text, color)
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, 0, 0, 36)
    toast.AutomaticSize = Enum.AutomaticSize.X
    toast.BackgroundColor3 = color or Color3.fromRGB(30, 30, 38)
    toast.BackgroundTransparency = 0.1
    toast.Parent = toastContainer
    makeCorner(toast, UDim.new(0, 8))

    local label = Instance.new("TextLabel")
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Size = UDim2.new(0, 0, 1, 0)
    label.Position = UDim2.fromOffset(14, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 20
    label.Parent = toast

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = toast

    toast.BackgroundTransparency = 1
    label.TextTransparency = 1
    TweenService:Create(toast, TweenInfo.new(0.25), { BackgroundTransparency = 0.1 }):Play()
    TweenService:Create(label, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()

    task.delay(2.6, function()
        local fadeOut = TweenService:Create(toast, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
        TweenService:Create(label, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            toast:Destroy()
        end)
    end)
end

-- ===== Overlay de água (splash) =====
local waterOverlay = Instance.new("Frame")
waterOverlay.Size = UDim2.fromScale(1, 1)
waterOverlay.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
waterOverlay.BackgroundTransparency = 1
waterOverlay.ZIndex = 50
waterOverlay.Parent = screenGui

local function flashWater()
    TweenService:Create(waterOverlay, TweenInfo.new(0.08), { BackgroundTransparency = 0.55 }):Play()
    task.delay(0.1, function()
        TweenService:Create(waterOverlay, TweenInfo.new(0.7), { BackgroundTransparency = 1 }):Play()
    end)
end

-- ===== Tela de finalização =====
local finishOverlay = Instance.new("Frame")
finishOverlay.Size = UDim2.fromScale(1, 1)
finishOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
finishOverlay.BackgroundTransparency = 1
finishOverlay.Visible = false
finishOverlay.ZIndex = 60
finishOverlay.Parent = screenGui

local finishPanel = Instance.new("Frame")
finishPanel.Size = UDim2.fromOffset(420, 260)
finishPanel.AnchorPoint = Vector2.new(0.5, 0.5)
finishPanel.Position = UDim2.fromScale(0.5, 0.5)
finishPanel.BackgroundColor3 = Color3.fromRGB(28, 24, 38)
finishPanel.ZIndex = 61
finishPanel.Parent = finishOverlay
makeCorner(finishPanel, UDim.new(0, 18))
makeStroke(finishPanel, Color3.fromRGB(255, 210, 110), 2)

local finishTitle = Instance.new("TextLabel")
finishTitle.Size = UDim2.new(1, 0, 0, 60)
finishTitle.Position = UDim2.fromOffset(0, 20)
finishTitle.BackgroundTransparency = 1
finishTitle.Text = "🏆 Você chegou ao topo!"
finishTitle.TextColor3 = Color3.fromRGB(255, 225, 160)
finishTitle.Font = Enum.Font.FredokaOne
finishTitle.TextScaled = true
finishTitle.ZIndex = 62
finishTitle.Parent = finishPanel

local finishTimeLabel = Instance.new("TextLabel")
finishTimeLabel.Size = UDim2.new(1, 0, 0, 60)
finishTimeLabel.Position = UDim2.fromOffset(0, 90)
finishTimeLabel.BackgroundTransparency = 1
finishTimeLabel.Text = "Tempo: 00:00.0"
finishTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
finishTimeLabel.Font = Enum.Font.Code
finishTimeLabel.TextScaled = true
finishTimeLabel.ZIndex = 62
finishTimeLabel.Parent = finishPanel

local playAgainButton = Instance.new("TextButton")
playAgainButton.Size = UDim2.fromOffset(220, 50)
playAgainButton.AnchorPoint = Vector2.new(0.5, 0)
playAgainButton.Position = UDim2.new(0.5, 0, 0, 170)
playAgainButton.BackgroundColor3 = Color3.fromRGB(120, 200, 120)
playAgainButton.Text = "🐾 Jogar novamente"
playAgainButton.TextColor3 = Color3.fromRGB(20, 30, 20)
playAgainButton.Font = Enum.Font.FredokaOne
playAgainButton.TextScaled = true
playAgainButton.ZIndex = 62
playAgainButton.Parent = finishPanel
makeCorner(playAgainButton)

playAgainButton.MouseButton1Click:Connect(function()
    finishOverlay.Visible = false
    RequestFullReset:FireServer()
end)

-- ============= Lógica: timer =============

local raceStartClock = nil
local raceFinishedTime = nil

RunService.RenderStepped:Connect(function()
    if raceFinishedTime then return end
    if not raceStartClock then return end
    local elapsed = os.clock() - raceStartClock
    local minutes = math.floor(elapsed / 60)
    local seconds = elapsed % 60
    timerLabel.Text = string.format("%02d:%04.1f", minutes, seconds)
end)

local function formatTime(t)
    local minutes = math.floor(t / 60)
    local seconds = t % 60
    return string.format("%02d:%04.1f", minutes, seconds)
end

-- ============= Eventos do servidor =============

CheckpointReached.OnClientEvent:Connect(function(label)
    local prettyLabel = label:gsub("_", " ")
    showToast("✅ " .. prettyLabel, Color3.fromRGB(40, 110, 60))
    if label:find("Hub") then
        raceStartClock = os.clock()
        raceFinishedTime = nil
        finishOverlay.Visible = false
    end
end)

WaterSplash.OnClientEvent:Connect(function(message)
    flashWater()
    showToast("💦 " .. (message or "Gatos odeiam água!"), Color3.fromRGB(60, 90, 160))
end)

RaceFinished.OnClientEvent:Connect(function(elapsed, isNewBest)
    raceFinishedTime = elapsed
    finishTimeLabel.Text = "Tempo: " .. formatTime(elapsed) .. (isNewBest and "  🌟 Recorde!" or "")
    finishOverlay.Visible = true
    TweenService:Create(finishOverlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.35 }):Play()
end)

CollectibleGrabbed.OnClientEvent:Connect(function(digit, foundCount, total)
    mouseFrame.Visible = true
    mouseLabel.Text = string.format("🐭 Ratinhos: %d/%d", foundCount, total)
    showToast("🐭 Você achou um ratinho! Dígito revelado: " .. tostring(digit), Color3.fromRGB(150, 110, 60))
end)

SequenceState.OnClientEvent:Connect(function(status)
    if status == "wrong" then
        showToast("❌ Ordem errada! Observe de novo...", Color3.fromRGB(150, 50, 50))
    elseif status == "solved" then
        showToast("🎉 Sequência correta! Portão aberto.", Color3.fromRGB(50, 140, 90))
    elseif status == "ready" then
        showToast("👉 Agora é sua vez! Pise na ordem.", Color3.fromRGB(60, 90, 150))
    end
end)

KeypadFeedback.OnClientEvent:Connect(function(status)
    if status == "correct" then
        showToast("🔓 Código correto! Portão aberto.", Color3.fromRGB(50, 140, 90))
    elseif status == "wrong" then
        showToast("❌ Código incorreto. Tente de novo.", Color3.fromRGB(150, 50, 50))
    end
end)

-- ============= Loop: stamina bar =============

local function getCharacterAttribute(name, default)
    local character = player.Character
    if not character then return default end
    local value = character:GetAttribute(name)
    if value == nil then return default end
    return value
end

RunService.Heartbeat:Connect(function()
    local staminaRatio = getCharacterAttribute("Stamina", 100) / 100
    staminaFill.Size = UDim2.fromScale(math.clamp(staminaRatio, 0, 1), 1)
    staminaFill.BackgroundColor3 = staminaRatio < 0.25 and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(120, 230, 255)
end)

-- ============= Painel de controles (canto inferior esquerdo) =============

local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.fromOffset(260, 150)
controlsFrame.Position = UDim2.new(0, 16, 1, -166)
controlsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
controlsFrame.BackgroundTransparency = 0.35
controlsFrame.Parent = screenGui
makeCorner(controlsFrame)
makeStroke(controlsFrame, Color3.fromRGB(200, 200, 220))

local controlsLabel = Instance.new("TextLabel")
controlsLabel.Size = UDim2.new(1, -16, 1, -16)
controlsLabel.Position = UDim2.fromOffset(8, 8)
controlsLabel.BackgroundTransparency = 1
controlsLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
controlsLabel.Font = Enum.Font.Gotham
controlsLabel.TextSize = 14
controlsLabel.TextXAlignment = Enum.TextXAlignment.Left
controlsLabel.TextYAlignment = Enum.TextYAlignment.Top
controlsLabel.TextWrapped = true
controlsLabel.Text = "🐾 CONTROLES\nWASD — Mover\nEspaço — Pular (segure = mais alto)\nCtrl + Espaço — Salto Pounce\nShift — Correr\nE — Interagir\nR — Voltar ao checkpoint"
controlsLabel.Parent = controlsFrame
