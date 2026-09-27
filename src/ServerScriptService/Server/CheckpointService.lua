--[[
    CheckpointService.lua
    Sistema de checkpoints: guarda a última posição segura de cada jogador
    e o teleporta de volta quando cai na água ou precisa respawnar.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CheckpointService = {}
CheckpointService._playerData = {} -- [player] = {position = Vector3, order = number}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CheckpointReached = Remotes:WaitForChild("CheckpointReached")

function CheckpointService:GetData(player)
    local data = self._playerData[player]
    if not data then
        data = { position = nil, order = -1 }
        self._playerData[player] = data
    end
    return data
end

function CheckpointService:CreateCheckpoint(part, order, label)
    part.CanCollide = false
    part.Anchored = true

    local debounce = {}

    part.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        if not character then return end
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end

        local data = self:GetData(player)
        if order <= data.order then return end -- já passou por esse ou por um mais avançado

        if debounce[player] then return end
        debounce[player] = true
        task.delay(0.5, function() debounce[player] = nil end)

        data.order = order
        data.position = part.Position + Vector3.new(0, 4, 0)

        CheckpointReached:FireClient(player, label or ("Checkpoint " .. order))
    end)

    return part
end

function CheckpointService:Respawn(player, reason)
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    local data = self:GetData(player)
    local targetPosition = data.position or (root.Position + Vector3.new(0, 10, 0))

    -- zera velocidades para não "voar" ao reaparecer
    root.AssemblyLinearVelocity = Vector3.new()
    root.AssemblyAngularVelocity = Vector3.new()
    root.CFrame = CFrame.new(targetPosition)

    if reason then
        local Remotes2 = ReplicatedStorage:WaitForChild("Remotes")
        Remotes2:WaitForChild("WaterSplash"):FireClient(player, reason)
    end
end

function CheckpointService:SetSpawn(player, position)
    local data = self:GetData(player)
    if not data.position then
        data.position = position
    end
end

Players.PlayerRemoving:Connect(function(player)
    CheckpointService._playerData[player] = nil
end)

return CheckpointService
