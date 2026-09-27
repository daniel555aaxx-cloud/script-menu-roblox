--[[
    HazardService.lua
    Gatos odeiam água! Qualquer parte marcada como água manda o jogador
    de volta pro último checkpoint com um "splash" e um miado de susto.
]]

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local HazardService = {}
HazardService.CheckpointService = nil -- injetado pelo Main.server.lua

local SPLASH_SOUND_ID = "rbxassetid://9125619202" -- splash genérico

function HazardService:CreateWaterHazard(part)
    part.Transparency = 0.25
    part.Color = Color3.fromRGB(45, 130, 220)
    part.Material = Enum.Material.Glass
    part.CanCollide = false
    part.Anchored = true

    local debounce = {}

    part.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        if not character then return end
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end

        if debounce[player] then return end
        debounce[player] = true
        task.delay(1.2, function() debounce[player] = nil end)

        -- efeito sonoro no ponto de contato
        local sound = Instance.new("Sound")
        sound.SoundId = SPLASH_SOUND_ID
        sound.Volume = 0.6
        sound.Parent = part
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)

        if self.CheckpointService then
            self.CheckpointService:Respawn(player, "Gatos odeiam água! Você foi enxotado de volta ao checkpoint.")
        end
    end)

    return part
end

return HazardService
