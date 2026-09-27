--[[
    CatController.client.lua
    Física custom de movimento do gato. Roda 100% no cliente (o cliente é o
    "network owner" do próprio personagem, então isso replica normalmente).

    Recursos implementados:
      - Pulo com altura variável (segura pra pular mais alto, solta pra cortar o pulo)
      - Salto "Pounce": agachar (Ctrl) + pular = salto maior e mais longe, pra frente
      - Controle aéreo forte (gatos são muito ágeis no ar)
      - Gravidade customizada: cai mais rápido do que sobe (queda "decidida")
      - Reflexo de endireitamento: sempre tenta cair de pé
      - Pouso com "squash & stretch" (achatamento realista de gato pousando)
      - Quedas muito altas deixam o gato "atordoado" por um instante (sem dano)
      - Wall Jump: pular fora de paredes no ar
      - Ledge Mantle: escalar automaticamente beiradas na altura do peito
      - Sprint com stamina (fôlego curto e explosivo, como gatos de verdade)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CatConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CatConfig"))

local player = Players.LocalPlayer

-- ============= Estado =============

local character, humanoid, rootPart
local grounded = false
local fallStartY = nil
local lastGroundedTime = 0
local isCrouching = false
local isSprinting = false
local stamina = CatConfig.MaxStamina
local staminaAttrTimer = 0

local jumpHeldSince = nil
local jumpCooldownUntil = 0
local hasSustained = false
local jumpIsCuttable = false -- só o pulo normal (não-pounce, não-wall-jump) pode ser "cortado" ao soltar cedo

local wallJumpCooldownUntil = 0
local ledgeMantleCooldownUntil = 0
local isMantling = false

local RAY_PARAMS = RaycastParams.new()
RAY_PARAMS.FilterType = Enum.RaycastFilterType.Exclude

local function updateRayFilter()
    if character then
        RAY_PARAMS.FilterDescendantsInstances = { character }
    end
end

-- ============= Utilitário: raycast simples =============

local function raycast(origin, direction)
    return Workspace:Raycast(origin, direction, RAY_PARAMS)
end

local function isGrounded()
    if not rootPart then return false end
    local hipHeight = (humanoid and humanoid.HipHeight or 1) 
    local castLength = hipHeight + 1.1
    local result = raycast(rootPart.Position, Vector3.new(0, -castLength, 0))
    return result ~= nil, result
end

-- ============= Squash & Stretch (pouso) =============

local function playLandSquash(intensity)
    if not humanoid then return end
    intensity = intensity or 1

    -- BodyHeightScale/BodyWidthScale/BodyDepthScale são NumberValues filhos do Humanoid (padrão R15)
    local heightScale = humanoid:FindFirstChild("BodyHeightScale")
    local widthScale = humanoid:FindFirstChild("BodyWidthScale")
    local depthScale = humanoid:FindFirstChild("BodyDepthScale")
    if not (heightScale and widthScale and depthScale) then return end

    local squashXZ = 1 + (CatConfig.LandSquashScaleXZ - 1) * intensity
    local squashY = 1 - (1 - CatConfig.LandSquashScaleY) * intensity

    local baseHeight, baseWidth, baseDepth = heightScale.Value, widthScale.Value, depthScale.Value

    local squashTweenInfo = TweenInfo.new(CatConfig.LandSquashTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local squashTween = TweenService:Create(heightScale, squashTweenInfo, { Value = baseHeight * squashY })
    local squashTweenW = TweenService:Create(widthScale, squashTweenInfo, { Value = baseWidth * squashXZ })
    local squashTweenD = TweenService:Create(depthScale, squashTweenInfo, { Value = baseDepth * squashXZ })

    squashTween:Play()
    squashTweenW:Play()
    squashTweenD:Play()

    squashTween.Completed:Connect(function()
        local stretchTweenInfo = TweenInfo.new(CatConfig.LandStretchTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(heightScale, stretchTweenInfo, { Value = baseHeight }):Play()
        TweenService:Create(widthScale, stretchTweenInfo, { Value = baseWidth }):Play()
        TweenService:Create(depthScale, stretchTweenInfo, { Value = baseDepth }):Play()
    end)
end

local function handleDazed()
    character:SetAttribute("IsDazed", true)
    local originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = originalSpeed * CatConfig.DazedSpeedMultiplier
    task.delay(CatConfig.DazedDuration, function()
        if humanoid and humanoid.Parent then
            character:SetAttribute("IsDazed", false)
        end
    end)
end

-- ============= Detecção de parede (wall jump / ledge) =============

local function getMoveDirectionOrLook()
    if humanoid.MoveDirection.Magnitude > 0.05 then
        return humanoid.MoveDirection.Unit
    end
    return rootPart.CFrame.LookVector
end

local function findWall()
    local dir = getMoveDirectionOrLook()
    local origin = rootPart.Position
    local result = raycast(origin, dir * CatConfig.WallCheckDistance)
    if result then
        return result
    end
    -- também testa reto pra frente da câmera/olhar, caso o input não bata exatamente com a parede
    local lookResult = raycast(origin, rootPart.CFrame.LookVector * CatConfig.WallCheckDistance)
    return lookResult
end

local function tryLedgeMantle()
    if not CatConfig.LedgeGrabEnabled then return false end
    if isMantling then return false end
    if os.clock() < ledgeMantleCooldownUntil then return false end

    local dir = getMoveDirectionOrLook()
    local lowerOrigin = rootPart.Position
    local lowerHit = raycast(lowerOrigin, dir * 2.6)
    if not lowerHit then return false end

    local upperOrigin = rootPart.Position + Vector3.new(0, CatConfig.LedgeCheckHeight, 0)
    local upperHit = raycast(upperOrigin, dir * 2.6)
    if upperHit then return false end -- tem parede lá em cima também, não é uma beirada escalável

    -- procura o topo da beirada descendo um raio a partir de um ponto acima e à frente
    local ledgeProbeOrigin = upperOrigin + dir * 2.6
    local downHit = raycast(ledgeProbeOrigin, Vector3.new(0, -CatConfig.LedgeCheckHeight - 1, 0))
    if not downHit then return false end

    isMantling = true
    ledgeMantleCooldownUntil = os.clock() + 0.6

    local targetPos = downHit.Position + Vector3.new(0, (humanoid.HipHeight + 1.6), 0) + dir * 1.2
    local startCFrame = rootPart.CFrame
    local targetCFrame = CFrame.new(targetPos, targetPos + rootPart.CFrame.LookVector)

    rootPart.AssemblyLinearVelocity = Vector3.new()
    rootPart.Anchored = true

    local elapsed = 0
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        local alpha = math.clamp(elapsed / CatConfig.LedgeMantleTime, 0, 1)
        rootPart.CFrame = startCFrame:Lerp(targetCFrame, alpha)
        if alpha >= 1 then
            connection:Disconnect()
            rootPart.Anchored = false
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 4, 0)
            isMantling = false
        end
    end)

    return true
end

-- ============= Pulo =============

local function computeJumpDirectionBoost()
    local moveDir = humanoid.MoveDirection
    if moveDir.Magnitude > 0.05 then
        return moveDir.Unit
    end
    return rootPart.CFrame.LookVector
end

local function doJump(isPounce)
    if os.clock() < jumpCooldownUntil then return end
    jumpCooldownUntil = os.clock() + CatConfig.JumpCooldown

    local currentVel = rootPart.AssemblyLinearVelocity
    local jumpPower = isPounce and CatConfig.MaxChargedJumpPower or CatConfig.BaseJumpPower

    local horizontalBoost = Vector3.new()
    if isPounce then
        horizontalBoost = computeJumpDirectionBoost() * CatConfig.ChargeForwardBoost
    end

    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

    rootPart.AssemblyLinearVelocity = Vector3.new(
        currentVel.X + horizontalBoost.X,
        jumpPower,
        currentVel.Z + horizontalBoost.Z
    )

    jumpHeldSince = os.clock()
    hasSustained = false
    jumpIsCuttable = not isPounce -- o salto pounce é uma ação só, não deve ser "cortado" ao soltar o botão
    grounded = false
    fallStartY = rootPart.Position.Y
end

local function tryWallJump()
    if not CatConfig.WallJumpEnabled then return false end
    if os.clock() < wallJumpCooldownUntil then return false end
    if grounded then return false end

    local hit = findWall()
    if not hit then return false end

    wallJumpCooldownUntil = os.clock() + CatConfig.WallJumpCooldown

    local normal = hit.Normal
    local currentVel = rootPart.AssemblyLinearVelocity
    rootPart.AssemblyLinearVelocity = Vector3.new(
        normal.X * CatConfig.WallJumpAwayPower,
        CatConfig.WallJumpUpPower,
        normal.Z * CatConfig.WallJumpAwayPower
    )

    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    jumpHeldSince = os.clock()
    hasSustained = false
    jumpIsCuttable = false -- wall jump também é uma ação só
    return true
end

local function onJumpBegin()
    if isMantling then return end

    if grounded then
        if isCrouching then
            doJump(true) -- pounce
        else
            doJump(false)
        end
    else
        -- no ar: tenta escalar uma beirada, senão tenta wall jump, senão nada (já pulou)
        if not tryLedgeMantle() then
            tryWallJump()
        end
    end
end

local function onJumpEnd()
    -- corta o pulo normal se soltar cedo (salto "tap" curto vs. segurar = pulo alto).
    -- Pounce e wall-jump são impulsos únicos e não são cortados.
    if jumpHeldSince and not grounded and jumpIsCuttable then
        local heldTime = os.clock() - jumpHeldSince
        if heldTime < CatConfig.JumpSustainTime then
            local vel = rootPart.AssemblyLinearVelocity
            if vel.Y > 0 then
                rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, vel.Y * 0.45, vel.Z)
            end
        end
    end
    jumpHeldSince = nil
end

-- ============= Crouch / Sprint (Input) =============

local function setCrouch(active)
    isCrouching = active
    character:SetAttribute("IsCrouching", active)
    if humanoid then
        humanoid.HipHeight = active and CatConfig.HipHeightCrouch or CatConfig.HipHeightStand
    end
end

local function jumpAction(actionName, inputState)
    if inputState == Enum.UserInputState.Begin then
        onJumpBegin()
    elseif inputState == Enum.UserInputState.End then
        onJumpEnd()
    end
    return Enum.ContextActionResult.Pass
end

local function crouchAction(actionName, inputState)
    if inputState == Enum.UserInputState.Begin then
        setCrouch(true)
    elseif inputState == Enum.UserInputState.End then
        setCrouch(false)
    end
    return Enum.ContextActionResult.Pass
end

local function sprintAction(actionName, inputState)
    if inputState == Enum.UserInputState.Begin then
        isSprinting = true
    elseif inputState == Enum.UserInputState.End then
        isSprinting = false
    end
    return Enum.ContextActionResult.Pass
end

local function resetAction(actionName, inputState)
    if inputState == Enum.UserInputState.Begin then
        local remotes = ReplicatedStorage:WaitForChild("Remotes")
        remotes:WaitForChild("RequestReset"):FireServer()
    end
    return Enum.ContextActionResult.Pass
end

-- ============= Loop principal (Heartbeat) =============

local function updateMovementSpeed(dt)
    if isCrouching then
        humanoid.WalkSpeed = CatConfig.CrouchSpeed
        return
    end

    local wantsSprint = isSprinting and stamina > CatConfig.MinStaminaToSprint and humanoid.MoveDirection.Magnitude > 0.05

    if wantsSprint then
        humanoid.WalkSpeed = CatConfig.SprintSpeed
        stamina = math.max(0, stamina - CatConfig.SprintDrainRate * dt)
    else
        humanoid.WalkSpeed = CatConfig.WalkSpeed
        stamina = math.min(CatConfig.MaxStamina, stamina + CatConfig.StaminaRegenRate * dt)
    end

    character:SetAttribute("IsSprinting", wantsSprint)

    staminaAttrTimer += dt
    if staminaAttrTimer > 0.1 then
        staminaAttrTimer = 0
        character:SetAttribute("Stamina", stamina)
    end
end

local function updateAirPhysics(dt)
    if isMantling or rootPart.Anchored then return end

    local vel = rootPart.AssemblyLinearVelocity

    -- Controle aéreo: dirige a velocidade horizontal em direção ao input, sem "travar" a inércia
    local desiredSpeed = isSprinting and CatConfig.SprintSpeed or CatConfig.WalkSpeed
    local desiredHorizontal = humanoid.MoveDirection * desiredSpeed
    local currentHorizontal = Vector3.new(vel.X, 0, vel.Z)
    local alpha = math.clamp(CatConfig.AirControl * dt * 6, 0, 1)
    local newHorizontal = currentHorizontal:Lerp(desiredHorizontal, alpha)

    -- Gravidade customizada: cai mais forte do que sobe
    local gravity = Workspace.Gravity
    local velY = vel.Y
    if velY < 0 then
        local extraGravity = gravity * (CatConfig.FallGravityMultiplier - 1)
        velY = velY - extraGravity * dt
    end
    velY = math.max(velY, -CatConfig.TerminalFallSpeed)

    -- Sustain: segurando o pulo normal durante a subida, adiciona um pouco de força extra (salto controlado)
    if jumpHeldSince and jumpIsCuttable and velY > 0 then
        local heldTime = os.clock() - jumpHeldSince
        if heldTime < CatConfig.JumpSustainTime then
            velY += CatConfig.JumpSustainForce * dt
        end
    end

    rootPart.AssemblyLinearVelocity = Vector3.new(newHorizontal.X, velY, newHorizontal.Z)
end

local function onHeartbeat(dt)
    if not rootPart or not humanoid or rootPart.Anchored then return end

    local wasGrounded = grounded
    local groundedNow, groundHit = isGrounded()
    grounded = groundedNow
    character:SetAttribute("IsGrounded", grounded)

    if grounded then
        if not wasGrounded then
            -- ACABOU de aterrissar
            local fallDistance = fallStartY and (fallStartY - rootPart.Position.Y) or 0
            if fallDistance > CatConfig.SafeFallHeight * 0.4 then
                local intensity = math.clamp(fallDistance / CatConfig.HardFallHeight, 0.2, 1.4)
                playLandSquash(intensity)
            end
            if fallDistance > CatConfig.HardFallHeight then
                handleDazed()
            end
            fallStartY = nil
            hasSustained = false
        end
        lastGroundedTime = os.clock()
    else
        if wasGrounded then
            fallStartY = rootPart.Position.Y
        elseif fallStartY and rootPart.Position.Y > fallStartY then
            fallStartY = rootPart.Position.Y -- estava subindo, recalibra o topo
        end
        updateAirPhysics(dt)
    end

    updateMovementSpeed(dt)
end

-- ============= Setup / Ciclo de vida do personagem =============

local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")

    grounded = true
    fallStartY = nil
    isCrouching = false
    isSprinting = false
    stamina = CatConfig.MaxStamina
    jumpHeldSince = nil

    updateRayFilter()

    humanoid.HipHeight = CatConfig.HipHeightStand
    humanoid.WalkSpeed = CatConfig.WalkSpeed
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end

RunService.Heartbeat:Connect(onHeartbeat)

ContextActionService:BindAction("CatJump", jumpAction, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
ContextActionService:BindAction("CatCrouch", crouchAction, false, Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonL2)
ContextActionService:BindAction("CatSprint", sprintAction, false, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonR1)
ContextActionService:BindAction("CatReset", resetAction, false, Enum.KeyCode.R, Enum.KeyCode.ButtonY)
