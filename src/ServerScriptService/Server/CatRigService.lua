--[[
    CatRigService.lua
    Transforma o personagem padrão (R15) em um "gato": encolhe o corpo,
    adiciona orelhas e rabo (feitos só de parts, sem precisar de assets externos),
    desliga o pulo padrão do Humanoid (o controle é 100% custom no cliente) e
    define os atributos usados pela física custom.
]]

local CatConfig = require(script.Parent.Parent.Parent.ReplicatedStorage.Shared.CatConfig)

local CatRigService = {}

local EAR_COLOR = Color3.fromRGB(235, 180, 120)
local TAIL_COLOR = Color3.fromRGB(235, 180, 120)

local function weld(part0, part1, c0, c1)
    local w = Instance.new("Weld")
    w.Part0 = part0
    w.Part1 = part1
    w.C0 = c0 or CFrame.new()
    w.C1 = c1 or CFrame.new()
    w.Parent = part0
    return w
end

local function addEars(character, head)
    -- remove orelhas antigas se essa função já rodou antes nesse personagem
    -- (Setup pode rodar mais de uma vez: em CharacterAdded e de novo em
    -- CharacterAppearanceLoaded, pra garantir que a aparência do gato sempre vença)
    local existing = character:FindFirstChild("CatEars")
    if existing then existing:Destroy() end

    local earFolder = Instance.new("Folder")
    earFolder.Name = "CatEars"
    earFolder.Parent = character

    for _, side in ipairs({-1, 1}) do
        local ear = Instance.new("WedgePart")
        ear.Name = "Ear"
        ear.Size = Vector3.new(0.35, 0.55, 0.35)
        ear.Color = character:GetAttribute("CatColor") and Color3.new() or EAR_COLOR
        ear.Material = Enum.Material.SmoothPlastic
        ear.CanCollide = false
        ear.CanQuery = false
        ear.Massless = true
        ear.Parent = earFolder
        weld(head, ear, CFrame.new(0.32 * side, 0.55, -0.05) * CFrame.Angles(math.rad(-90), 0, math.rad(20 * side)))
    end
end

local function addTail(character, lowerTorso)
    local existing = character:FindFirstChild("CatTail")
    if existing then existing:Destroy() end

    -- o primeiro Motor6D do rabo fica pendurado no LowerTorso (fora da pasta CatTail),
    -- então precisa ser limpo manualmente pra não duplicar se Setup rodar de novo
    local oldFirstJoint = lowerTorso:FindFirstChild("TailJoint1")
    if oldFirstJoint then oldFirstJoint:Destroy() end

    local tailFolder = Instance.new("Folder")
    tailFolder.Name = "CatTail"
    tailFolder.Parent = character

    local segments = {}
    local previous = lowerTorso
    local previousC0 = CFrame.new(0, -0.1, 0.55)

    for i = 1, 5 do
        local segment = Instance.new("Part")
        segment.Name = "TailSegment" .. i
        segment.Shape = Enum.PartType.Cylinder
        segment.Size = Vector3.new(0.55, 0.22 - (i * 0.015), 0.22 - (i * 0.015))
        segment.Color = TAIL_COLOR
        segment.Material = Enum.Material.SmoothPlastic
        segment.CanCollide = false
        segment.CanQuery = false
        segment.Massless = true
        segment.Parent = tailFolder

        local motor = Instance.new("Motor6D")
        motor.Name = "TailJoint" .. i
        motor.Part0 = previous
        motor.Part1 = segment
        motor.C0 = previousC0
        motor.C1 = CFrame.new(0.26, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
        motor.Parent = previous

        previous = segment
        previousC0 = CFrame.new(0.5, 0, 0) * CFrame.Angles(0, 0, math.rad(8))

        table.insert(segments, segment)
    end

    return segments
end

function CatRigService.Setup(player, character)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local head = character:WaitForChild("Head")
    local lowerTorso = character:FindFirstChild("LowerTorso")

    -- Só funciona 100% com rigs R15 (padrão atual do Roblox)
    humanoid.RigType = Enum.HumanoidRigType.R15

    -- O pulo é inteiramente controlado pelo CatController no cliente,
    -- então desligamos o pulo/gravidade padrão do Humanoid.
    humanoid.JumpPower = 0
    humanoid.JumpHeight = 0
    humanoid.UseJumpPower = true
    humanoid.AutoRotate = true
    humanoid.WalkSpeed = CatConfig.WalkSpeed
    humanoid.BreakJointsOnDeath = false
    humanoid.RequiresNeck = false

    -- Encolhe o rig todo (mantendo proporções) para o tamanho de um gato.
    -- IMPORTANTE: fazemos isso ANTES de fixar o HipHeight final, porque ScaleTo
    -- também reajusta o HipHeight proporcionalmente — queremos que o valor do
    -- CatConfig seja a palavra final, não multiplicado de novo pela escala.
    local ok = pcall(function()
        character:ScaleTo(CatConfig.BodyScale)
    end)
    if not ok then
        warn("[CatRigService] ScaleTo falhou (rig talvez não seja R15). Continuando sem escala.")
    end

    humanoid.HipHeight = CatConfig.HipHeightStand

    -- Visual: orelhas e rabo
    pcall(addEars, character, head)
    if lowerTorso then
        pcall(addTail, character, lowerTorso)
    end

    -- Garante que existam os NumberValues de escala corporal (usados pro squash&stretch de pouso).
    -- Em alguns jogos com "Avatar Scaling" desabilitado eles não existem por padrão.
    for _, valueName in ipairs({ "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" }) do
        if not humanoid:FindFirstChild(valueName) then
            local nv = Instance.new("NumberValue")
            nv.Name = valueName
            nv.Value = 1
            nv.Parent = humanoid
        end
    end

    -- Sem barra de vida visível/dano de queda: gato nunca "morre" de queda
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge

    -- Atributos usados pela física/animação (client)
    character:SetAttribute("IsGrounded", true)
    character:SetAttribute("IsCrouching", false)
    character:SetAttribute("IsSprinting", false)
    character:SetAttribute("IsDazed", false)
    character:SetAttribute("HasDoubleJump", CatConfig.DoubleJumpUnlockedByDefault)
    character:SetAttribute("Stamina", CatConfig.MaxStamina)

    -- Evita que o jogo empurre o gato pra "PlatformStand" em situações estranhas
    humanoid.PlatformStand = false

    return humanoid, rootPart
end

return CatRigService
