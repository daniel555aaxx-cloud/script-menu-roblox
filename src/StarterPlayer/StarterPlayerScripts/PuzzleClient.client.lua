--[[
    PuzzleClient.client.lua
    Liga os cliques dos botões do painel numérico (SurfaceGui no mundo 3D)
    ao RemoteEvent do servidor. TextButton.MouseButton1Click só existe no
    cliente, por isso esse "meio de campo" é necessário.

    Os pisos de sequência e os totens giratórios não precisam de nada aqui:
    o piso usa .Touched (colisão) e o totem usa ProximityPrompt, ambos já
    disparam eventos no servidor automaticamente.
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local KeypadSubmit = Remotes:WaitForChild("KeypadSubmit")

local connectedButtons = {}

local function connectButton(button)
    if connectedButtons[button] then return end
    connectedButtons[button] = true

    local keypadId = button:GetAttribute("KeypadId")
    local value = button:GetAttribute("Value")
    if not keypadId or not value then return end

    button.MouseButton1Click:Connect(function()
        if value == "CLR" then
            KeypadSubmit:FireServer("CLEAR", keypadId)
        elseif value == "OK" then
            KeypadSubmit:FireServer("ENTER", keypadId)
        else
            KeypadSubmit:FireServer(value, keypadId)
        end
    end)
end

local function scanForButtons(root)
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("TextButton") and descendant:GetAttribute("KeypadId") then
            connectButton(descendant)
        end
    end
end

local mapFolder = Workspace:WaitForChild("GeneratedMap", 15)
if mapFolder then
    scanForButtons(mapFolder)
    mapFolder.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("TextButton") and descendant:GetAttribute("KeypadId") then
            connectButton(descendant)
        end
    end)
end
