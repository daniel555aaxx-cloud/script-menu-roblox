--[[
    Main.server.lua
    Ponto de entrada do servidor: constrói o mapa, prepara cada jogador
    como um gato e liga o cronômetro da corrida.
]]

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapBuilder = require(script.Parent.MapBuilder)
local CatRigService = require(script.Parent.CatRigService)
local CheckpointService = require(script.Parent.CheckpointService)
local RaceService = require(script.Parent.RaceService)

-- Botão "Reset" (R): joga o jogador de volta pro último checkpoint (útil se ficar preso)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestReset = Remotes:WaitForChild("RequestReset")
local RequestFullReset = Remotes:WaitForChild("RequestFullReset")

local resetDebounce = {}
RequestReset.OnServerEvent:Connect(function(player)
    if resetDebounce[player] then return end
    resetDebounce[player] = true
    task.delay(1, function() resetDebounce[player] = nil end)
    CheckpointService:Respawn(player)
end)

-- "Jogar novamente" (depois de terminar a corrida): volta pro início de tudo
local fullResetDebounce = {}
RequestFullReset.OnServerEvent:Connect(function(player)
    if fullResetDebounce[player] then return end
    fullResetDebounce[player] = true
    task.delay(1, function() fullResetDebounce[player] = nil end)

    local data = CheckpointService:GetData(player)
    data.order = -1
    data.position = mapInfo.hubSpawnPosition
    CheckpointService:Respawn(player)
end)

-- Gera o mapa inteiro (hub + 3 zonas + final)
local mapInfo = MapBuilder.Build()

-- Liga o cronômetro: começa no checkpoint do hub, termina no pad final
local hubCheckpoint = mapInfo.folder:FindFirstChild("Checkpoint_0_Hub")
if hubCheckpoint then
    RaceService:AttachToCheckpoint(hubCheckpoint)
end
RaceService:AttachToFinish(mapInfo.finishPad)

local function onCharacterAdded(player, character)
    character:SetAttribute("SpawnedAt", os.clock())

    local humanoid = character:WaitForChild("Humanoid")
    CatRigService.Setup(player, character)

    -- se ainda não tem checkpoint, usa o spawn do hub
    local data = CheckpointService:GetData(player)
    if not data.position then
        CheckpointService:SetSpawn(player, mapInfo.hubSpawnPosition)
    end

    humanoid.Died:Connect(function()
        -- o gato "nunca morre de verdade" (sem dano), mas por segurança,
        -- se algo forçar a morte, respawna no checkpoint depois de um instante
        task.delay(1, function()
            if player and player.Parent then
                player:LoadCharacter()
            end
        end)
    end)
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end)
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

print("[GatoParkour] Mapa gerado e servidor pronto. 🐾")
