--[[
    RaceService.lua
    Cronômetro da corrida: começa quando o jogador sai do HUB e termina
    quando ele pisa no FinishPad. Mantém um "melhor tempo" em memória
    (e tenta salvar em DataStore se a API estiver disponível/publicada).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RaceService = {}
RaceService._startTimes = {}
RaceService._bestTimes = {}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RaceFinished = Remotes:WaitForChild("RaceFinished")

local dataStoreOk, dataStore = pcall(function()
    return game:GetService("DataStoreService"):GetDataStore("CatParkour_BestTimes_v1")
end)

function RaceService:StartTimer(player)
    if self._startTimes[player] then return end
    self._startTimes[player] = os.clock()
end

function RaceService:AttachToCheckpoint(part)
    part.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        if not character then return end
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end
        self:StartTimer(player)
    end)
end

function RaceService:AttachToFinish(finishPad)
    local debounce = {}
    finishPad.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        if not character then return end
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end
        if debounce[player] then return end
        debounce[player] = true
        task.delay(2, function() debounce[player] = nil end)

        local start = self._startTimes[player]
        if not start then return end
        local elapsed = os.clock() - start
        self._startTimes[player] = nil

        local best = self._bestTimes[player]
        local isNewBest = not best or elapsed < best
        if isNewBest then
            self._bestTimes[player] = elapsed
            if dataStoreOk then
                task.spawn(function()
                    pcall(function()
                        dataStore:UpdateAsync(tostring(player.UserId), function(old)
                            if not old or elapsed < old then
                                return elapsed
                            end
                            return old
                        end)
                    end)
                end)
            end
        end

        RaceFinished:FireClient(player, elapsed, isNewBest)
    end)
end

return RaceService
