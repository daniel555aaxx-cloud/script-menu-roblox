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

-- Gera o mapa inteiro (hub + 3 zonas + final) ANTES de qualquer outra coisa
-- que dependa dele (checkpoints, respawn, etc.)
local mapInfo = MapBuilder.Build()

-- Liga o cronômetro: começa no checkpoint do hub, termina no pad final
local hubCheckpoint = mapInfo.folder:FindFirstChild("Checkpoint_0_Hub")
if hubCheckpoint then
    RaceService:AttachToCheckpoint(hubCheckpoint)
end
RaceService:AttachToFinish(mapInfo.finishPad)

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

-- ============= Personagem =============
--
-- IMPORTANTE: `CharacterAdded` só garante que o Model do personagem existe,
-- mas a APARÊNCIA (avatar, roupas, e principalmente a escala do corpo) ainda
-- pode estar carregando de forma assíncrona nesse momento e sobrescrever
-- nossas mudanças (Roblox carrega isso depois, via `CharacterAppearanceLoaded`).
-- Por isso aplicamos `CatRigService.Setup` tanto em CharacterAdded quanto de
-- novo em CharacterAppearanceLoaded — a segunda chamada sempre "vence" por
-- último e garante que o jogador SEMPRE nasça como gato.

local function applyCatRig(player, character)
    local ok, err = pcall(function()
        CatRigService.Setup(player, character)
    end)
    if not ok then
        warn("[Main] Falha ao transformar " .. player.Name .. " em gato: " .. tostring(err))
    end

    local data = CheckpointService:GetData(player)
    if not data.position then
        CheckpointService:SetSpawn(player, mapInfo.hubSpawnPosition)
    end
end

local function onCharacterAdded(player, character)
    character:SetAttribute("SpawnedAt", os.clock())

    -- Aplica na hora (cobre o caso comum onde a aparência já carregou rápido)
    applyCatRig(player, character)

    local humanoid = character:WaitForChild("Humanoid")
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

local function onCharacterAppearanceLoaded(player, character)
    -- Reaplica DEPOIS que a aparência "de fábrica" do avatar terminou de
    -- carregar, garantindo que o visual de gato sempre seja o que fica.
    applyCatRig(player, character)
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end)
    player.CharacterAppearanceLoaded:Connect(function(character)
        onCharacterAppearanceLoaded(player, character)
    end)

    -- Caso o personagem (e/ou aparência) já tenha carregado antes da gente conectar
    if player.Character then
        onCharacterAdded(player, player.Character)
        onCharacterAppearanceLoaded(player, player.Character)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

print("[GatoParkour] Mapa gerado e servidor pronto. 🐾")
