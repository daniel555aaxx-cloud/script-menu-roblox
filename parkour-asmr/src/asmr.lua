--[[
	Parkour ASMR — Teclado & Sons (LocalScript no StarterPlayerScripts)
	• Cliques de teclado ASMR em qualquer tecla (e no mouse)
	• Passinhos suaves enquanto você anda
	• Sons de pulo e aterrissagem
	• Moeda, checkpoint e chegada
	• Tecla K liga/desliga o ASMR do teclado
	• Opcional: cole seus próprios IDs de áudio em CUSTOM
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

---------------------------------------------------------------
-- CONFIGURAÇÃO DE ÁUDIO (opcional)
-- Cole aqui IDs seus (ex.: "rbxassetid://1234567890") para
-- usar áudios ASMR personalizados em vez dos embutidos.
local CUSTOM = {
	key = "",        -- clique do teclado
	step = "",       -- passinhos
	jump = "",       -- pulo
	land = "",       -- aterrissagem
	coin = "",       -- moeda
	checkpoint = "", -- checkpoint
	finish = "",     -- chegada
	music = "",      -- música de fundo (loop; vazio = sem música)
}

-- Sons clássicos embutidos do Roblox (funcionam sem upload)
local CANDIDATES = {
	key = {
		"rbxasset://sounds/button.mp3",
		"rbxasset://sounds/switch.mp3",
		"rbxasset://sounds/snap.mp3",
		"rbxasset://sounds/clickfast.mp3",
	},
	step = {
		"rbxasset://sounds/plasticplastic.mp3",
		"rbxasset://sounds/bfsl-minifigfoots1.mp3",
		"rbxasset://sounds/button.mp3",
	},
	jump = {
		"rbxasset://sounds/action_jump.mp3",
		"rbxasset://sounds/swoosh.mp3",
		"rbxasset://sounds/snap.mp3",
	},
	land = {
		"rbxasset://sounds/action_jump_land.mp3",
		"rbxasset://sounds/hit.mp3",
		"rbxasset://sounds/splat.mp3",
	},
	coin = {
		"rbxasset://sounds/electronicpingshort.mp3",
		"rbxasset://sounds/bass.mp3",
	},
	checkpoint = {
		"rbxasset://sounds/electronicpingshort.mp3",
		"rbxasset://sounds/bass.mp3",
	},
	finish = {
		"rbxasset://sounds/victory.mp3",
		"rbxasset://sounds/electronicpingshort.mp3",
	},
}

local VOLUME = {
	key = 0.35,
	step = 0.3,
	jump = 0.45,
	land = 0.4,
	coin = 0.55,
	checkpoint = 0.6,
	finish = 0.7,
}

local BASE_SPEED = {
	key = 1.25,
	step = 1,
	jump = 1,
	land = 1.05,
	coin = 1.5,
	checkpoint = 1.2,
	finish = 1,
}

local SLOTS = { "key", "step", "jump", "land", "coin", "checkpoint", "finish" }
local POOL_SIZE = 3

local asmrOn = true

---------------------------------------------------------------
-- Pools de sons (permite sobreposição de cliques)
local group = Instance.new("SoundGroup")
group.Name = "ASMRGroup"
group.Volume = 1
group.Parent = SoundService

local pools = {}

local function makePool(slot)
	local list = {}
	local firstId = (CUSTOM[slot] ~= "" and CUSTOM[slot]) or CANDIDATES[slot][1]
	for i = 1, POOL_SIZE do
		local sound = Instance.new("Sound")
		sound.Name = "ASMR_" .. slot .. "_" .. i
		sound.SoundId = firstId
		sound.Volume = VOLUME[slot]
		sound.PlaybackSpeed = BASE_SPEED[slot]
		sound.SoundGroup = group
		sound.Parent = SoundService
		list[i] = sound
	end
	pools[slot] = { sounds = list, index = 0 }
end

for _, slot in ipairs(SLOTS) do
	makePool(slot)
end

local function play(slot, pitch, volumeScale)
	local pool = pools[slot]
	if not pool then
		return
	end
	pool.index = (pool.index % #pool.sounds) + 1
	local sound = pool.sounds[pool.index]
	sound.PlaybackSpeed = BASE_SPEED[slot] * (pitch or 1)
	sound.Volume = math.clamp(VOLUME[slot] * (volumeScale or 1), 0, 1)
	sound:Stop()
	sound.TimePosition = 0
	sound:Play()
end

---------------------------------------------------------------
-- Se o primeiro candidato não carregar, testa os próximos
local function resolveSlot(slot)
	if CUSTOM[slot] ~= "" then
		return
	end
	task.spawn(function()
		local probe = Instance.new("Sound")
		probe.SoundGroup = group
		probe.Volume = 0
		probe.Parent = SoundService
		local cands = CANDIDATES[slot]
		for i = 1, #cands do
			local loaded = false
			probe.SoundId = cands[i]
			local conn = probe.Loaded:Connect(function()
				loaded = true
			end)
			probe:Play()
			local tries = 0
			while tries < 10 and not loaded do
				task.wait(0.03)
				tries = tries + 1
			end
			probe:Stop()
			conn:Disconnect()
			if loaded then
				if i ~= 1 then
					for _, sound in ipairs(pools[slot].sounds) do
						sound.SoundId = cands[i]
					end
				end
				probe:Destroy()
				return
			end
		end
		probe:Destroy()
	end)
end

for _, slot in ipairs(SLOTS) do
	resolveSlot(slot)
end

---------------------------------------------------------------
-- Música de fundo opcional
if CUSTOM.music ~= "" then
	local music = Instance.new("Sound")
	music.Name = "ParkourMusic"
	music.SoundId = CUSTOM.music
	music.Looped = true
	music.Volume = 0.3
	music.SoundGroup = group
	music.Parent = SoundService
	music:Play()
end

---------------------------------------------------------------
-- Indicador "ASMR ON/OFF" (canto inferior esquerdo)
local gui = Instance.new("ScreenGui")
gui.Name = "ASMRToggle"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9
gui.Parent = player:WaitForChild("PlayerGui")

local indicator = Instance.new("TextLabel")
indicator.Name = "State"
indicator.AnchorPoint = Vector2.new(0, 1)
indicator.Position = UDim2.new(0, 14, 1, -14)
indicator.Size = UDim2.fromOffset(210, 40)
indicator.BackgroundColor3 = Color3.fromRGB(0, 190, 110)
indicator.BackgroundTransparency = 0.15
indicator.Font = Enum.Font.GothamBold
indicator.TextSize = 17
indicator.Text = "ASMR: LIGADO  (K)"
indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
indicator.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = indicator

local function updateIndicator()
	if asmrOn then
		indicator.Text = "ASMR: LIGADO  (K)"
		indicator.BackgroundColor3 = Color3.fromRGB(0, 190, 110)
	else
		indicator.Text = "ASMR: DESLIGADO  (K)"
		indicator.BackgroundColor3 = Color3.fromRGB(70, 72, 82)
	end
end

---------------------------------------------------------------
-- Teclado e mouse
local lastTick = 0

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	local inputType = input.UserInputType
	if inputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.K then
			asmrOn = not asmrOn
			updateIndicator()
			play("key", 1.1, 1)
			return
		end
		if asmrOn then
			local now = tick()
			if now - lastTick > 0.055 then
				lastTick = now
				play("key", 0.9 + math.random() * 0.3, 0.8 + math.random() * 0.35)
			end
		end
	elseif inputType == Enum.UserInputType.MouseButton1 then
		if asmrOn then
			play("key", 1.12, 0.85)
		end
	end
end)

---------------------------------------------------------------
-- Passinhos, pulo e aterrissagem
local character
local humanoid
local stepTimer = 0

local function bindCharacter(char)
	character = char
	humanoid = nil
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then
		return
	end
	humanoid = hum
	hum.StateChanged:Connect(function(oldState, newState)
		if not asmrOn then
			return
		end
		if newState == Enum.HumanoidStateType.Jumping and oldState ~= Enum.HumanoidStateType.Jumping then
			play("jump", 0.95 + math.random() * 0.12, 1)
		elseif newState == Enum.HumanoidStateType.Landed then
			play("land", 0.95 + math.random() * 0.15, 1)
		end
	end)
end

if player.Character then
	bindCharacter(player.Character)
end
player.CharacterAdded:Connect(bindCharacter)

RunService.Heartbeat:Connect(function(delta)
	if not asmrOn or not humanoid or not character or not character.Parent then
		return
	end
	if humanoid.Health <= 0 then
		return
	end
	if humanoid.MoveDirection.Magnitude > 0.05 and humanoid.FloorMaterial ~= Enum.Material.Air then
		stepTimer = stepTimer - delta
		if stepTimer <= 0 then
			stepTimer = 0.24 + math.random() * 0.08
			play("step", 0.92 + math.random() * 0.2, 0.7 + math.random() * 0.4)
		end
	else
		stepTimer = 0.08
	end
end)

---------------------------------------------------------------
-- Efeitos vindos do servidor (moeda / checkpoint / chegada)
local fx = ReplicatedStorage:WaitForChild("ParkourFX")

fx.OnClientEvent:Connect(function(kind, value)
	if kind == "coin" then
		play("coin", 1 + math.random() * 0.25, 1)
	elseif kind == "checkpoint" then
		play("checkpoint", 0.95 + (tonumber(value) or 1) * 0.05, 1)
	elseif kind == "finish" then
		play("finish", 1, 1)
		task.delay(0.2, function()
			play("coin", 1.35, 0.9)
		end)
		task.delay(0.42, function()
			play("coin", 1.7, 0.9)
		end)
	end
end)

updateIndicator()
