--[[
    MapBuilder.lua
    Gera todo o mapa do jogo por código (sem precisar de nenhum asset externo):
      HUB -> Zona 1 "Telhados" (parkour + enigma de memória)
          -> Zona 2 "Jardim Secreto" (água + enigma dos totens giratórios)
          -> Zona 3 "Sótão Misterioso" (wall-jump + plataformas móveis + enigma do painel numérico)
          -> Final "Telhado das Estrelas"

    Cada zona termina com um "portão" (gate) que só abre quando o enigma é resolvido,
    e cada zona começa com um checkpoint.

    OBS: as distâncias de pulo foram calculadas para a config padrão de
    src/ReplicatedStorage/Shared/CatConfig.lua. Se você alterar a força de pulo
    ou a gravidade do Workspace, pode ser necessário reajustar os números aqui
    (todas as posições estão em tabelas fáceis de editar).
]]

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local CheckpointService = require(script.Parent.CheckpointService)
local HazardService = require(script.Parent.HazardService)
local PuzzleService = require(script.Parent.PuzzleService)

HazardService.CheckpointService = CheckpointService

local MapBuilder = {}

-- ================= Helpers =================

local FOLDER = Instance.new("Folder")
FOLDER.Name = "GeneratedMap"

local function newPart(props)
    -- props.ClassName = classe do Instance ("Part", "WedgePart", ...). Padrão: "Part".
    -- props.PartType  = formato do Part (Enum.PartType.Ball/Cylinder/Block), só vale pra classe "Part".
    local part = Instance.new(props.ClassName or "Part")
    part.Name = props.Name or "Part"
    part.Size = props.Size or Vector3.new(4, 1, 4)
    part.CFrame = props.CFrame or CFrame.new(0, 0, 0)
    part.Anchored = props.Anchored ~= false
    part.CanCollide = props.CanCollide ~= false
    part.Material = props.Material or Enum.Material.SmoothPlastic
    part.Color = props.Color or Color3.fromRGB(160, 160, 160)
    part.Parent = props.Parent or FOLDER
    if props.Transparency then part.Transparency = props.Transparency end
    if props.PartType and part:IsA("Part") then part.Shape = props.PartType end
    return part
end

local function platform(name, position, size, color, material)
    return newPart({
        Name = name,
        Size = size,
        CFrame = CFrame.new(position),
        Color = color or Color3.fromRGB(150, 130, 110),
        Material = material or Enum.Material.WoodPlanks,
    })
end

local function sign(text, position, size)
    local part = newPart({
        Name = "Sign",
        Size = size or Vector3.new(10, 4, 0.6),
        CFrame = CFrame.new(position),
        Color = Color3.fromRGB(35, 30, 45),
        Material = Enum.Material.SmoothPlastic,
        CanCollide = false,
    })
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.Parent = part
    gui.LightInfluence = 0
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 230, 150)
    label.Font = Enum.Font.FredokaOne
    label.TextScaled = true
    label.Parent = gui
    return part
end

local function checkpointPad(name, position, order)
    local pad = newPart({
        Name = name,
        Size = Vector3.new(6, 0.4, 6),
        CFrame = CFrame.new(position),
        Color = Color3.fromRGB(120, 255, 190),
        Material = Enum.Material.Neon,
        CanCollide = false,
    })
    CheckpointService:CreateCheckpoint(pad, order, name)
    return pad
end

local function waterStrip(name, position, size)
    local water = newPart({
        Name = name,
        Size = size,
        CFrame = CFrame.new(position),
        CanCollide = false,
    })
    HazardService:CreateWaterHazard(water)
    return water
end

local function gateDoor(name, position, size)
    return newPart({
        Name = name,
        Size = size,
        CFrame = CFrame.new(position),
        Color = Color3.fromRGB(90, 60, 50),
        Material = Enum.Material.Wood,
    })
end

-- cria uma sequência de plataformas em zigue-zague subindo suavemente (parkour de telhado)
local function buildZigZagPath(baseName, startPos, count, dx, dyRange, dzAmplitude, sizeRange, color)
    local platforms = {}
    local pos = startPos
    for i = 1, count do
        local zOffset = math.sin(i * 0.9) * dzAmplitude
        local yOffset = (math.random() * (dyRange.max - dyRange.min)) + dyRange.min
        pos = pos + Vector3.new(dx, yOffset, 0)
        local plat = platform(
            baseName .. i,
            Vector3.new(pos.X, pos.Y, pos.Z + zOffset),
            Vector3.new(
                math.random(sizeRange.min, sizeRange.max),
                2,
                math.random(sizeRange.min, sizeRange.max)
            ),
            color
        )
        table.insert(platforms, plat)
        pos = Vector3.new(pos.X, pos.Y, pos.Z + zOffset)
    end
    return platforms, pos
end

-- ================= ZONA 0: HUB =================

local function buildHub()
    local hubFloor = platform("HubFloor", Vector3.new(0, 0, 0), Vector3.new(50, 2, 50), Color3.fromRGB(90, 150, 90), Enum.Material.Grass)

    sign("🐾 GATO PARKOUR\nEnigmas Felinos 🐾", Vector3.new(0, 9, -23), Vector3.new(24, 8, 0.6))
    sign("Controles:\nWASD - Mover | Espaço - Pular (segure p/ pulo mais alto)\nShift - Correr | Ctrl + Espaço - Salto Pounce (mais longe)\nE - Interagir | R - Voltar ao checkpoint", Vector3.new(18, 6, 0), Vector3.new(18, 7, 0.5))

    -- caixas de treino (pulo curto -> médio -> agachado+pulo)
    for i = 1, 3 do
        platform("PracticeBox" .. i, Vector3.new(-14 + i * 6, 1 + i * 1.1, 14), Vector3.new(4, 1 + i * 1.4, 4), Color3.fromRGB(200, 170, 120), Enum.Material.Wood)
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "HubSpawn"
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.CFrame = CFrame.new(0, 2, 10)
    spawn.Anchored = true
    spawn.CanCollide = true
    spawn.Transparency = 1
    spawn.Duration = 0
    spawn.Parent = FOLDER

    checkpointPad("Checkpoint_0_Hub", Vector3.new(0, 1.3, -5), 0)

    return Vector3.new(0, 4, 10)
end

-- ================= ZONA 1: TELHADOS (parkour + memória) =================

local function buildZone1()
    sign("ZONA 1: TELHADOS\nSiga os telhados e resolva o enigma da memória!", Vector3.new(38, 8, -20), Vector3.new(18, 5, 0.5))

    platform("Z1_Start", Vector3.new(40, 2, 0), Vector3.new(12, 2, 12), Color3.fromRGB(180, 90, 70), Enum.Material.Slate)

    local platforms, lastPos = buildZigZagPath(
        "Z1_Roof_",
        Vector3.new(40, 3, 0),
        9,
        9,      -- avanço em X por plataforma
        { min = 0.5, max = 3.5 },
        6,      -- amplitude do zigue-zague em Z
        { min = 5, max = 7 },
        Color3.fromRGB(170, 95, 75)
    )

    -- pequena plataforma de pouso logo após o zigue-zague (fica mais fácil de acertar o checkpoint)
    local landingPos = lastPos + Vector3.new(7, -1.5, 0)
    platform("Z1_Landing", landingPos, Vector3.new(8, 2, 8), Color3.fromRGB(170, 95, 75))
    checkpointPad("Checkpoint_1_Roofs", landingPos + Vector3.new(0, 1.5, 0), 1)

    -- plataforma intermediária pra quebrar o vão grande até a arena (usa o Salto Pounce aqui!)
    local midGapPos = landingPos + Vector3.new(11, -1, 0)
    platform("Z1_MidGap", midGapPos, Vector3.new(6, 2, 6), Color3.fromRGB(170, 95, 75))

    -- Arena do enigma de sequência (4 pads + portão)
    local arenaCenter = midGapPos + Vector3.new(11, -1, 0)
    platform("Z1_PuzzleFloor", arenaCenter, Vector3.new(22, 2, 18), Color3.fromRGB(120, 100, 90), Enum.Material.Concrete)

    local pads = {}
    local padPositions = {
        arenaCenter + Vector3.new(-6, 1.5, -5),
        arenaCenter + Vector3.new(6, 1.5, -5),
        arenaCenter + Vector3.new(-6, 1.5, 5),
        arenaCenter + Vector3.new(6, 1.5, 5),
    }
    for i, pos in ipairs(padPositions) do
        pads[i] = newPart({
            Name = "SequencePad" .. i,
            Size = Vector3.new(4.5, 0.5, 4.5),
            CFrame = CFrame.new(pos),
            CanCollide = true,
        })
    end

    sign("Memorize a sequência de cores\ne pise nos pisos na ordem certa!", arenaCenter + Vector3.new(0, 6, -12), Vector3.new(16, 4, 0.4))

    local gate1 = gateDoor("Gate_Zone1", arenaCenter + Vector3.new(0, 6, 12), Vector3.new(20, 12, 2))
    PuzzleService.CreateSequencePuzzle({ pads = pads, gate = gate1, length = 4, playSpeed = 0.6 })

    checkpointPad("Checkpoint_1b_AfterPuzzle", arenaCenter + Vector3.new(0, 0, 16), 2)

    return arenaCenter + Vector3.new(0, 2, 22)
end

-- ================= ZONA 2: JARDIM SECRETO (água + totens) =================

local function buildZone2(entryPos)
    local baseX = entryPos.X + 15
    sign("ZONA 2: JARDIM SECRETO\nGatos odeiam água! Não caia nos canais.", Vector3.new(baseX, 8, entryPos.Z - 18), Vector3.new(20, 5, 0.5))

    platform("Z2_Garden", Vector3.new(baseX, 1, entryPos.Z), Vector3.new(50, 2, 40), Color3.fromRGB(80, 140, 80), Enum.Material.Grass)

    -- canais de água cruzando o jardim, com pedras de apoio (stepping stones)
    for i = 1, 3 do
        local waterZ = entryPos.Z - 12 + (i * 8)
        waterStrip("Z2_Water" .. i, Vector3.new(baseX, 1.1, waterZ), Vector3.new(50, 0.6, 3))

        for s = -2, 2 do
            platform(
                "Z2_Stone_" .. i .. "_" .. s,
                Vector3.new(baseX + s * 8 + (i % 2 == 0 and 4 or 0), 1.6, waterZ),
                Vector3.new(3.4, 1, 3.4),
                Color3.fromRGB(140, 140, 150),
                Enum.Material.Rock
            )
        end
    end

    -- Área dos totens
    local totemAreaPos = Vector3.new(baseX, 1, entryPos.Z + 22)
    platform("Z2_TotemFloor", totemAreaPos, Vector3.new(34, 2, 20), Color3.fromRGB(70, 120, 70), Enum.Material.Grass)

    sign("Gire os totens (E) para que todos\nolhem na mesma direção do portão!", totemAreaPos + Vector3.new(0, 6, -8), Vector3.new(16, 4, 0.4))

    local pillarSpecs = {
        { offset = Vector3.new(-9, 0, 0), target = 1 },
        { offset = Vector3.new(0, 0, 3),  target = 3 },
        { offset = Vector3.new(9, 0, 0),  target = 2 },
    }

    local pillars = {}
    for i, spec in ipairs(pillarSpecs) do
        local basePos = totemAreaPos + spec.offset + Vector3.new(0, 3, 0)
        local baseCFrame = CFrame.new(basePos)
        local totem = newPart({
            Name = "Totem" .. i,
            Size = Vector3.new(2.2, 6, 2.2),
            CFrame = baseCFrame,
            Color = Color3.fromRGB(200, 150, 90),
            Material = Enum.Material.Wood,
        })
        -- "olho" pintado numa face pra indicar a direção do totem
        local eye = newPart({
            Name = "Eye",
            Size = Vector3.new(0.3, 1.2, 1.2),
            CFrame = baseCFrame * CFrame.new(1.1, 1, 0),
            Color = Color3.fromRGB(255, 220, 80),
            Material = Enum.Material.Neon,
            CanCollide = false,
        })
        eye.Parent = totem
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = totem
        weld.Part1 = eye
        weld.Parent = totem

        totem:SetAttribute("PuzzleIndex", i)
        pillars[i] = { part = totem, baseCFrame = baseCFrame, target = spec.target, steps = 4 }
    end

    local gate2 = gateDoor("Gate_Zone2", totemAreaPos + Vector3.new(0, 6, 12), Vector3.new(18, 12, 2))
    PuzzleService.CreateRotatorPuzzle({ pillars = pillars, gate = gate2 })

    checkpointPad("Checkpoint_2_Garden", totemAreaPos, 3)
    checkpointPad("Checkpoint_2b_AfterTotems", totemAreaPos + Vector3.new(0, 0, 16), 4)

    return totemAreaPos + Vector3.new(0, 2, 22)
end

-- ================= ZONA 3: SÓTÃO MISTERIOSO (wall-jump + plataformas móveis + keypad) =================

local function buildZone3(entryPos)
    local baseX = entryPos.X + 15
    sign("ZONA 3: SÓTÃO MISTERIOSO\nEscale as paredes e ache os 3 ratinhos!", Vector3.new(baseX, 10, entryPos.Z - 16), Vector3.new(20, 5, 0.5))

    platform("Z3_Entry", Vector3.new(baseX, 1, entryPos.Z), Vector3.new(20, 2, 16), Color3.fromRGB(120, 100, 80), Enum.Material.WoodPlanks)

    -- Corredor de wall-jump: duas paredes paralelas, o gato precisa saltar de uma pra outra subindo
    local corridorZ = entryPos.Z
    local wallGap = 6
    local corridorHeight = 34
    local wallA = newPart({
        Name = "Z3_WallJumpA",
        Size = Vector3.new(2, corridorHeight, 10),
        CFrame = CFrame.new(baseX - wallGap / 2, corridorHeight / 2, corridorZ + 14),
        Color = Color3.fromRGB(110, 90, 70),
        Material = Enum.Material.Wood,
    })
    local wallB = newPart({
        Name = "Z3_WallJumpB",
        Size = Vector3.new(2, corridorHeight, 10),
        CFrame = CFrame.new(baseX + wallGap / 2, corridorHeight / 2, corridorZ + 14),
        Color = Color3.fromRGB(110, 90, 70),
        Material = Enum.Material.Wood,
    })
    wallA:SetAttribute("WallJumpSurface", true)
    wallB:SetAttribute("WallJumpSurface", true)

    -- pequenas beiradas de apoio a cada trecho, pro jogador poder descansar se errar
    for i = 1, 4 do
        platform(
            "Z3_RestLedge" .. i,
            Vector3.new(baseX + (i % 2 == 0 and wallGap or -wallGap), i * 7, corridorZ + 14),
            Vector3.new(4, 1, 4),
            Color3.fromRGB(150, 120, 90)
        )
    end

    local topLanding = platform("Z3_TopLanding", Vector3.new(baseX, corridorHeight + 2, corridorZ + 14), Vector3.new(16, 2, 14), Color3.fromRGB(130, 105, 85), Enum.Material.WoodPlanks)
    checkpointPad("Checkpoint_3_TopOfWalls", Vector3.new(baseX, corridorHeight + 3.5, corridorZ + 14), 5)

    -- Vigas do sótão com plataformas móveis sobre um vão
    local pitStartZ = corridorZ + 24
    platform("Z3_AtticFloorStart", Vector3.new(baseX, corridorHeight + 2, pitStartZ), Vector3.new(14, 2, 6), Color3.fromRGB(130, 105, 85))
    local atticFloorEnd = platform("Z3_AtticFloorEnd", Vector3.new(baseX, corridorHeight + 2, pitStartZ + 40), Vector3.new(16, 2, 8), Color3.fromRGB(130, 105, 85))

    local movingPlatformsData = {}
    for i = 1, 3 do
        local plat = platform(
            "Z3_MovingPlank" .. i,
            Vector3.new(baseX, corridorHeight + 2, pitStartZ + 8 + (i - 1) * 12),
            Vector3.new(6, 1, 5),
            Color3.fromRGB(160, 130, 95),
            Enum.Material.WoodPlanks
        )
        table.insert(movingPlatformsData, plat)

        local goingRight = i % 2 == 0
        local travel = 9
        local targetPos = plat.Position + Vector3.new(goingRight and travel or -travel, 0, 0)
        local tween = TweenService:Create(plat, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = targetPos })
        tween:Play()
    end

    -- Ratinhos escondidos (collectibles) espalhados pelas vigas
    local mouseSpots = {
        { pos = Vector3.new(baseX - 8, corridorHeight + 4, pitStartZ + 14), digit = "4" },
        { pos = Vector3.new(baseX + 9, corridorHeight + 6, pitStartZ + 26), digit = "8" },
        { pos = Vector3.new(baseX, corridorHeight + 4, pitStartZ + 36), digit = "2" },
    }
    local mice = {}
    for i, spot in ipairs(mouseSpots) do
        -- pequena plataforma de apoio pro ratinho não ficar flutuando sem propósito
        platform("Z3_MouseLedge" .. i, spot.pos - Vector3.new(0, 1.6, 0), Vector3.new(4, 0.6, 4), Color3.fromRGB(140, 110, 85))

        local mouse = newPart({
            Name = "Mouse" .. i,
            PartType = Enum.PartType.Ball,
            Size = Vector3.new(1.6, 1.6, 1.6),
            CFrame = CFrame.new(spot.pos),
            Color = Color3.fromRGB(120, 100, 100),
            Material = Enum.Material.Fabric,
            CanCollide = true,
        })
        local tag = Instance.new("BillboardGui")
        tag.Size = UDim2.fromOffset(120, 40)
        tag.StudsOffset = Vector3.new(0, 1.5, 0)
        tag.AlwaysOnTop = true
        tag.Parent = mouse
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Text = "🐭"
        label.TextScaled = true
        label.Font = Enum.Font.FredokaOne
        label.Parent = tag

        table.insert(mice, { part = mouse, digit = spot.digit })
    end

    checkpointPad("Checkpoint_3b_Attic", Vector3.new(baseX, corridorHeight + 3.5, pitStartZ + 14), 6)

    -- Painel numérico (keypad) e portão final do sótão
    local keypadPos = atticFloorEnd.Position + Vector3.new(0, 4, 3)
    local keypadPart = newPart({
        Name = "KeypadTerminal",
        Size = Vector3.new(4, 5, 1),
        CFrame = CFrame.new(keypadPos),
        Color = Color3.fromRGB(40, 40, 45),
        Material = Enum.Material.Metal,
        CanCollide = true,
    })

    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.Parent = keypadPart
    gui.LightInfluence = 0

    local grid = Instance.new("Frame")
    grid.Size = UDim2.fromScale(1, 1)
    grid.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    grid.Parent = gui

    local display = Instance.new("TextLabel")
    display.Size = UDim2.new(1, 0, 0.2, 0)
    display.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    display.TextColor3 = Color3.fromRGB(120, 255, 150)
    display.Font = Enum.Font.Code
    display.TextScaled = true
    display.Text = "___"
    display.Parent = grid

    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Size = UDim2.new(1, 0, 0.8, 0)
    buttonsFrame.Position = UDim2.new(0, 0, 0.2, 0)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = grid

    local layout = Instance.new("UIGridLayout")
    layout.CellSize = UDim2.fromScale(0.33, 0.25)
    layout.CellPadding = UDim2.fromScale(0.005, 0.02)
    layout.Parent = buttonsFrame

    local keypadId = "Zone3Keypad"

    -- Os botões só definem sua aparência e atributos aqui; o clique de fato é
    -- capturado no CLIENTE (PuzzleClient.client.lua), que dispara o RemoteEvent
    -- KeypadSubmit para o servidor (TextButton.MouseButton1Click só existe no cliente).
    local labels = { "1","2","3","4","5","6","7","8","9","CLR","0","OK" }
    for _, labelText in ipairs(labels) do
        local btn = Instance.new("TextButton")
        btn.Name = "Key_" .. labelText
        btn.Text = labelText
        btn.Font = Enum.Font.FredokaOne
        btn.TextScaled = true
        btn.BackgroundColor3 = (labelText == "CLR" and Color3.fromRGB(150, 60, 60)) or (labelText == "OK" and Color3.fromRGB(60, 150, 90)) or Color3.fromRGB(60, 60, 70)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn:SetAttribute("KeypadId", keypadId)
        btn:SetAttribute("Value", labelText)
        btn.Parent = buttonsFrame
    end
    keypadPart:SetAttribute("KeypadId", keypadId)

    local gate3 = gateDoor("Gate_Zone3", atticFloorEnd.Position + Vector3.new(0, 6, 8), Vector3.new(16, 12, 2))

    PuzzleService.CreateKeypadPuzzle({
        id = keypadId,
        code = "482",
        gate = gate3,
        display = display,
        mice = mice,
    })

    return atticFloorEnd.Position + Vector3.new(0, 2, 12)
end

-- ================= FINAL: TELHADO DAS ESTRELAS =================

local function buildFinish(entryPos)
    local finishPos = entryPos + Vector3.new(0, 0, 14)
    platform("FinishFloor", finishPos, Vector3.new(26, 2, 26), Color3.fromRGB(60, 50, 90), Enum.Material.Neon)
    sign("🏆 TELHADO DAS ESTRELAS 🏆\nVocê completou o desafio felino!", finishPos + Vector3.new(0, 8, -12), Vector3.new(20, 5, 0.5))

    local finishPad = newPart({
        Name = "FinishPad",
        Size = Vector3.new(8, 0.4, 8),
        CFrame = CFrame.new(finishPos + Vector3.new(0, 1.2, 0)),
        Color = Color3.fromRGB(255, 215, 90),
        Material = Enum.Material.Neon,
        CanCollide = false,
    })

    checkpointPad("Checkpoint_Final", finishPos + Vector3.new(0, 0, -6), 7)

    return finishPad
end

-- ================= BUILD =================

function MapBuilder.Build()
    FOLDER.Parent = Workspace

    local hubSpawn = buildHub()
    local afterZone1 = buildZone1()
    local afterZone2 = buildZone2(afterZone1)
    local afterZone3 = buildZone3(afterZone2)
    local finishPad = buildFinish(afterZone3)

    return {
        hubSpawnPosition = hubSpawn,
        finishPad = finishPad,
        folder = FOLDER,
    }
end

return MapBuilder
