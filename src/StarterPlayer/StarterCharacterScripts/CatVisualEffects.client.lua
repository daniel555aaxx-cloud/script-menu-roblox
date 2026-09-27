--[[
    CatVisualEffects.client.lua
    Roda uma vez por personagem (StarterCharacterScripts é clonado pro
    character toda vez que o jogador nasce). Cuida dos detalhes visuais
    que vendem a ilusão de "gato": rabo balançando, orelhas reagindo ao
    pouso e passos de pata alternados.
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ============= Rabo (spring/pêndulo simples) =============

local tailFolder = character:WaitForChild("CatTail", 5)
local tailJoints = {}

if tailFolder then
    local previous = character:FindFirstChild("LowerTorso")
    if previous then
        for i = 1, 5 do
            local motor = previous:FindFirstChild("TailJoint" .. i)
            if motor then
                table.insert(tailJoints, { motor = motor, baseC0 = motor.C0, index = i })
                previous = motor.Part1
            end
        end
    end
end

local lastVelocity = Vector3.new()
local swayPhase = 0

local function updateTail(dt)
    if #tailJoints == 0 then return end

    local vel = rootPart.AssemblyLinearVelocity
    local accel = (vel - lastVelocity) / math.max(dt, 1 / 240)
    lastVelocity = vel

    swayPhase += dt * 3.2

    -- o rabo reage à aceleração horizontal (efeito "contrapeso") + uma leve ondulação natural
    local localAccel = rootPart.CFrame:VectorToObjectSpace(accel)
    local lagX = math.clamp(-localAccel.X * 0.01, -0.6, 0.6)
    local lagZ = math.clamp(-localAccel.Z * 0.01, -0.6, 0.6)

    for _, joint in ipairs(tailJoints) do
        local amplitude = 0.12 + (joint.index * 0.05)
        local wave = math.sin(swayPhase - joint.index * 0.6) * amplitude
        joint.motor.C0 = joint.baseC0 * CFrame.Angles(lagZ * 0.5, wave + lagX * 0.5, 0)
    end
end

-- ============= Orelhas (reação ao pouso) =============

local function twitchEars()
    local earFolder = character:FindFirstChild("CatEars")
    if not earFolder then return end
    -- pequeno "flick": escala rápida de tamanho pra simular o movimento da orelha
    for _, ear in ipairs(earFolder:GetChildren()) do
        if ear:IsA("BasePart") then
            local originalSize = ear.Size
            local tweenDown = TweenService:Create(ear, TweenInfo.new(0.08, Enum.EasingStyle.Quad), { Size = originalSize * Vector3.new(1, 0.6, 1) })
            tweenDown:Play()
            tweenDown.Completed:Connect(function()
                TweenService:Create(ear, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Size = originalSize }):Play()
            end)
        end
    end
end

character:GetAttributeChangedSignal("IsGrounded"):Connect(function()
    if character:GetAttribute("IsGrounded") then
        twitchEars()
    end
end)

-- ============= Passos de pata (sons alternados) =============

local FOOTSTEP_IDS = {
    "rbxassetid://9126687728",
    "rbxassetid://9126687728",
}
local stepTimer = 0
local stepToggle = false

local function playFootstep()
    local sound = Instance.new("Sound")
    sound.SoundId = FOOTSTEP_IDS[1]
    sound.Volume = 0.18
    sound.PlaybackSpeed = stepToggle and 1.05 or 0.95
    stepToggle = not stepToggle
    sound.Parent = rootPart
    sound:Play()
    Debris:AddItem(sound, 2)
end

local function updateFootsteps(dt)
    local grounded = character:GetAttribute("IsGrounded")
    local speed = rootPart.AssemblyLinearVelocity.Magnitude

    if grounded and speed > 2 then
        stepTimer -= dt
        if stepTimer <= 0 then
            playFootstep()
            -- passos mais rápidos quando correndo, mais espaçados quando andando
            stepTimer = math.clamp(2.2 / speed, 0.12, 0.55)
        end
    else
        stepTimer = 0
    end
end

RunService.Heartbeat:Connect(function(dt)
    if not character.Parent then return end
    updateTail(dt)
    updateFootsteps(dt)
end)
