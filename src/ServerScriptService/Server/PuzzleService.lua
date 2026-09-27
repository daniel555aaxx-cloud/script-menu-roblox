--[[
    PuzzleService.lua
    Contém a lógica dos 3 tipos de enigma do jogo:
      1) Sequência de Pisos (jogo da memória - "Simon Says" felino)
      2) Pilares Giratórios (alinhar os fios de lã)
      3) Painel Numérico (achar os ratinhos escondidos pra descobrir o código)
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SequenceState = Remotes:WaitForChild("SequenceState")
local KeypadSubmit = Remotes:WaitForChild("KeypadSubmit")
local KeypadFeedback = Remotes:WaitForChild("KeypadFeedback")
local CollectibleGrabbed = Remotes:WaitForChild("CollectibleGrabbed")

local PuzzleService = {}

local PAD_COLORS = {
    Color3.fromRGB(255, 90, 90),
    Color3.fromRGB(90, 190, 255),
    Color3.fromRGB(255, 210, 80),
    Color3.fromRGB(120, 230, 120),
}

local function openGate(gate)
    if not gate or gate:GetAttribute("Opened") then return end
    gate:SetAttribute("Opened", true)

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9126854342" -- porta abrindo
    sound.Volume = 0.7
    sound.Parent = gate
    sound:Play()
    Debris:AddItem(sound, 3)

    local targetCFrame = gate.CFrame * CFrame.new(0, -gate.Size.Y - 1, 0)
    local tween = TweenService:Create(gate, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        CFrame = targetCFrame,
        Transparency = 1,
    })
    gate.CanCollide = false
    tween:Play()
end

local function flashPad(pad, duration)
    local original = pad.Color
    local highlight = pad:GetAttribute("HighlightColor")
    pad.Material = Enum.Material.Neon
    if highlight then
        pad.Color = highlight
    end
    task.delay(duration, function()
        if pad and pad.Parent then
            pad.Material = Enum.Material.SmoothPlastic
            pad.Color = original
        end
    end)
end

-- ============================================================
-- 1) ENIGMA DE SEQUÊNCIA DE PISOS (memória)
-- ============================================================
function PuzzleService.CreateSequencePuzzle(cfg)
    -- cfg = { pads = {Part,...}, gate = Part, length = number, playSpeed = number }
    local pads = cfg.pads
    local gate = cfg.gate
    local length = cfg.length or 5
    local playSpeed = cfg.playSpeed or 0.55

    for i, pad in ipairs(pads) do
        pad:SetAttribute("HighlightColor", PAD_COLORS[((i - 1) % #PAD_COLORS) + 1])
        pad.Color = PAD_COLORS[((i - 1) % #PAD_COLORS) + 1]
        pad.Material = Enum.Material.SmoothPlastic
    end

    local state = {
        sequence = {},
        playerProgress = {},
        busy = false,
        solved = false,
    }

    local function generateSequence()
        state.sequence = {}
        for i = 1, length do
            state.sequence[i] = math.random(1, #pads)
        end
    end

    local function playSequenceForAll()
        state.busy = true
        state.playerProgress = {}
        for _, index in ipairs(state.sequence) do
            flashPad(pads[index], playSpeed * 0.8)
            SequenceState:FireAllClients("show", index)
            task.wait(playSpeed)
        end
        SequenceState:FireAllClients("ready")
        state.busy = false
    end

    local function startRound()
        if state.solved then return end
        generateSequence()
        task.delay(1, playSequenceForAll)
    end

    for i, pad in ipairs(pads) do
        pad.Touched:Connect(function(hit)
            if state.solved or state.busy then return end
            local character = hit:FindFirstAncestorOfClass("Model")
            if not character then return end
            local player = Players:GetPlayerFromCharacter(character)
            if not player then return end

            local progress = state.playerProgress[player] or 0
            local expected = state.sequence[progress + 1]

            if expected == i then
                progress += 1
                state.playerProgress[player] = progress
                flashPad(pad, 0.25)
                if progress >= #state.sequence then
                    state.solved = true
                    SequenceState:FireAllClients("solved")
                    openGate(gate)
                else
                    SequenceState:FireClient(player, "correct", progress)
                end
            else
                state.playerProgress[player] = 0
                SequenceState:FireClient(player, "wrong")
                pad.Color = Color3.fromRGB(255, 40, 40)
                task.delay(0.35, function()
                    if pad and pad.Parent then
                        pad.Color = pad:GetAttribute("HighlightColor")
                    end
                end)
                task.delay(1.2, startRound)
            end
        end)
    end

    startRound()

    return state
end

-- ============================================================
-- 2) ENIGMA DOS PILARES GIRATÓRIOS (fios de lã)
-- ============================================================
function PuzzleService.CreateRotatorPuzzle(cfg)
    -- cfg = { pillars = { {part=Part, target=number(0-3), steps=number} , ... }, gate = Part }
    local gate = cfg.gate
    local pillars = cfg.pillars
    local solved = false

    for _, info in ipairs(pillars) do
        info.current = 0
        info.steps = info.steps or 4
        info.part:SetAttribute("RotationIndex", 0)

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Girar Pilar"
        prompt.ObjectText = "Fio de Lã"
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 9
        prompt.Parent = info.part

        prompt.Triggered:Connect(function(player)
            if solved then return end
            info.current = (info.current + 1) % info.steps
            info.part:SetAttribute("RotationIndex", info.current)

            local anglePerStep = 360 / info.steps
            local targetCFrame = info.baseCFrame * CFrame.Angles(0, math.rad(anglePerStep * info.current), 0)
            local tween = TweenService:Create(info.part, TweenInfo.new(0.28, Enum.EasingStyle.Back), { CFrame = targetCFrame })
            tween:Play()

            -- (a própria rotação do part já replica normalmente pra todos os clientes)

            -- checa se todos os pilares estão na posição correta
            local allCorrect = true
            for _, p in ipairs(pillars) do
                if p.current ~= p.target then
                    allCorrect = false
                    break
                end
            end

            if allCorrect then
                solved = true
                openGate(gate)
            end
        end)
    end

    return { pillars = pillars, gate = gate }
end

-- ============================================================
-- 3) ENIGMA DO PAINEL NUMÉRICO (ratinhos escondidos)
-- ============================================================
function PuzzleService.CreateKeypadPuzzle(cfg)
    -- cfg = { code = "482", gate = Part, mice = {{part=Part, digit="4"},...}, surfaceGui = SurfaceGui, display = TextLabel }
    local code = cfg.code
    local gate = cfg.gate
    local display = cfg.display
    local entered = ""
    local solved = false
    local foundDigits = {}

    for _, mouseInfo in ipairs(cfg.mice) do
        local part = mouseInfo.part
        local digit = mouseInfo.digit
        local grabbed = {}

        part.Touched:Connect(function(hit)
            local character = hit:FindFirstAncestorOfClass("Model")
            if not character then return end
            local player = Players:GetPlayerFromCharacter(character)
            if not player then return end
            if grabbed[player] or part:GetAttribute("Collected") then return end
            grabbed[player] = true
            part:SetAttribute("Collected", true)

            foundDigits[digit] = true

            local total = 0
            for _ in pairs(cfg.mice) do total += 1 end
            local foundCount = 0
            for _ in pairs(foundDigits) do foundCount += 1 end

            CollectibleGrabbed:FireClient(player, digit, foundCount, total)

            part.Transparency = 1
            part.CanCollide = false
            task.delay(0.05, function()
                for _, d in ipairs(part:GetDescendants()) do
                    if d:IsA("BasePart") then d.Transparency = 1 end
                end
            end)
        end)
    end

    KeypadSubmit.OnServerEvent:Connect(function(player, digitOrAction, keypadId)
        if solved then return end
        if keypadId ~= cfg.id then return end

        if digitOrAction == "CLEAR" then
            entered = ""
        elseif digitOrAction == "ENTER" then
            if entered == code then
                solved = true
                KeypadFeedback:FireClient(player, "correct", cfg.id)
                openGate(gate)
            else
                KeypadFeedback:FireClient(player, "wrong", cfg.id)
                entered = ""
            end
        else
            if #entered < #code then
                entered = entered .. tostring(digitOrAction)
            end
        end

        if display then
            display.Text = string.rep("•", #entered) .. string.rep("_", math.max(0, #code - #entered))
        end
        KeypadFeedback:FireClient(player, "update", cfg.id, entered)
    end)

    return { code = code }
end

return PuzzleService
