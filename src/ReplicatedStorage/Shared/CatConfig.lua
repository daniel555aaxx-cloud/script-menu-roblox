--[[
    CatConfig.lua
    Tabela central com todas as constantes de física e jogabilidade do gato.
    Ajuste estes números para "sentir" o movimento do gato do jeito que quiser.
]]

local CatConfig = {}

-- ===== Locomoção =====
CatConfig.WalkSpeed        = 14      -- studs/s andando
CatConfig.SprintSpeed      = 24      -- studs/s correndo (explosivo, gasta stamina rápido)
CatConfig.CrouchSpeed      = 7       -- studs/s agachado (aproximação silenciosa)
CatConfig.Acceleration     = 45      -- studs/s^2 -- gatos aceleram/freiam quase instantaneamente
CatConfig.AirControl       = 0.85    -- 0-1, quanto o jogador controla a trajetória no ar (gatos são MUITO ágeis no ar)

-- ===== Stamina (sprint) =====
CatConfig.MaxStamina       = 100
CatConfig.SprintDrainRate  = 28      -- por segundo enquanto correndo
CatConfig.StaminaRegenRate = 18      -- por segundo quando não corre
CatConfig.MinStaminaToSprint = 8

-- ===== Salto / Pulo felino =====
CatConfig.BaseJumpPower     = 42     -- impulso vertical de um pulo "tap" rápido
CatConfig.MaxChargedJumpPower = 68   -- impulso vertical com agachamento carregado ao máximo (pounce)
CatConfig.MaxChargeTime     = 0.65   -- segundos para carregar o pulo 100%
CatConfig.ChargeForwardBoost = 30    -- impulso horizontal extra do pounce, na direção do olhar/movimento
CatConfig.JumpSustainTime   = 0.18   -- janela em que segurar o pulo ainda adiciona força ascendente (salto controlado)
CatConfig.JumpSustainForce  = 90     -- força extra por segundo aplicada durante o sustain
CatConfig.JumpCooldown      = 0.15

-- ===== Gravidade customizada =====
CatConfig.FallGravityMultiplier   = 1.35  -- caindo, a gravidade "efetiva" aumenta (queda mais decidida)
CatConfig.GlideGravityMultiplier  = 0.55  -- se o jogador segurar o pulo caindo e não sustain, plana levemente como gato "espalmado"
CatConfig.TerminalFallSpeed       = 120

-- ===== Reflexo de endireitamento (righting reflex) =====
CatConfig.RightingReflexEnabled   = true
CatConfig.RightingReflexDelay     = 0.12   -- tempo em queda livre antes do reflexo ativar
CatConfig.RightingReflexTorque    = 25000  -- força de rotação do BodyGyro
CatConfig.SafeFallHeight          = 22     -- abaixo disso, pouso 100% limpo
CatConfig.HardFallHeight          = 45     -- acima disso, o gato fica "atordoado" por um instante (sem dano!)
CatConfig.DazedDuration           = 0.9
CatConfig.DazedSpeedMultiplier    = 0.35

-- ===== Pouso (squash & stretch) =====
CatConfig.LandSquashScaleXZ  = 1.18
CatConfig.LandSquashScaleY   = 0.78
CatConfig.LandSquashTime     = 0.10
CatConfig.LandStretchTime    = 0.22

-- ===== Parede: pulo e escalada =====
CatConfig.WallJumpEnabled       = true
CatConfig.WallCheckDistance     = 2.6
CatConfig.WallJumpUpPower       = 40
CatConfig.WallJumpAwayPower     = 34
CatConfig.WallJumpCooldown      = 0.25
CatConfig.LedgeGrabEnabled      = true
CatConfig.LedgeCheckHeight      = 4.6   -- altura acima dos pés pra procurar uma borda livre
CatConfig.LedgeMantleTime       = 0.32

-- ===== Segundo fôlego (habilidade desbloqueável, opcional) =====
CatConfig.DoubleJumpUnlockedByDefault = false
CatConfig.DoubleJumpPower = 34

-- ===== Água (gatos odeiam água) =====
CatConfig.WaterKnockback = true

-- ===== Corpo / colisão do gato =====
CatConfig.HipHeightStand  = 1.1
CatConfig.HipHeightCrouch = 0.55
CatConfig.BodyScale       = 0.62   -- escala geral aplicada ao personagem (baixinho como um gato)

return CatConfig
