--[[
    CameraController.client.lua
    Não substitui a câmera padrão do Roblox (que já faz um bom trabalho em 3ª pessoa),
    só adiciona um "tempero" por cima dela: FOV dinâmico ao correr/pular e uma
    leve inclinação de câmera nas curvas, pra dar sensação de velocidade e agilidade felina.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local BASE_FOV = 70
local SPRINT_FOV = 82
local FOV_LERP_SPEED = 6

local currentTiltAngle = 0
local lastLookVector = nil

local function getCharacterState()
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return nil end
    return character, humanoid, root
end

RunService:BindToRenderStep("CatCameraFX", Enum.RenderPriority.Camera.Value + 1, function(dt)
    camera = Workspace.CurrentCamera
    if not camera then return end

    local character, humanoid, root = getCharacterState()
    if not character then
        currentTiltAngle = 0
        return
    end

    local isSprinting = character:GetAttribute("IsSprinting")
    local targetFov = isSprinting and SPRINT_FOV or BASE_FOV
    camera.FieldOfView += (targetFov - camera.FieldOfView) * math.clamp(FOV_LERP_SPEED * dt, 0, 1)

    -- Leve "roll" de câmera baseado na velocidade de giro horizontal (sensação ágil)
    local look = root.CFrame.LookVector
    local targetTilt = 0
    if lastLookVector then
        local cross = lastLookVector:Cross(look)
        local turnRate = cross.Y / math.max(dt, 1 / 240)
        targetTilt = math.clamp(-turnRate * 0.35, -6, 6)
    end
    lastLookVector = look

    currentTiltAngle += (targetTilt - currentTiltAngle) * math.clamp(8 * dt, 0, 1)

    if math.abs(currentTiltAngle) > 0.01 then
        camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, math.rad(currentTiltAngle))
    end
end)

player.CharacterAdded:Connect(function()
    lastLookVector = nil
    currentTiltAngle = 0
end)
