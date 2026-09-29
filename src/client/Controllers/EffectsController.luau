--[[
	EffectsController.luau
	Áudio, câmera de perseguição e sensação de medo:

		* toca efeitos pedidos pelo servidor (ClientSfx), com canal de música
		* distorção de câmera / tilt quando o monstro está perto
		* batimento cardíaco e vinheta vermelha quando o medo sobe
		* passos, lanterna e interação local (E) quando o prompt não dispara
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Assets = require(Shared.Assets)
local Net = require(Shared.Net)

local UIKit = require(script.Parent.Parent.Modules.UIKit)

local EffectsController = {}

local vignette
local heartbeatSound
local ambientSound
local chaseShake = 0

local function ensureSound(name, soundId, props)
	local existing = SoundService:FindFirstChild(name)
	if existing then
		if soundId and existing.SoundId ~= soundId then
			existing.SoundId = soundId
		end
		return existing
	end
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = soundId or ""
	sound.Volume = props and props.volume or 0.5
	sound.Looped = props and props.looped or false
	sound.Parent = SoundService
	return sound
end

function EffectsController.build()
	local gui = Instance.new("ScreenGui")
	gui.Name = "MysteryEffects"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 3
	gui.Parent = player:WaitForChild("PlayerGui")

	vignette = Instance.new("ImageLabel")
	vignette.Name = "Vignette"
	vignette.BackgroundTransparency = 1
	vignette.Image = "rbxassetid://6234275856" -- vinheta/scanline opcional
	vignette.ImageTransparency = 1
	vignette.ImageColor3 = UIKit.Palette.Danger
	vignette.Size = UDim2.fromScale(1, 1)
	vignette.ZIndex = 2
	vignette.Parent = gui
	EffectsController.Vignette = vignette

	-- lanterna (SpotLight no personagem)
	local function attachFlashlight(character)
		local head = character:FindFirstChild("Head")
		if not head then
			return
		end
		if head:FindFirstChild("Flashlight") then
			head.Flashlight:Destroy()
		end
		local light = Instance.new("SpotLight")
		light.Name = "Flashlight"
		light.Angle = 55
		light.Brightness = 2.2
		light.Range = 48
		light.Face = Enum.NormalId.Front
		light.Color = Color3.fromRGB(255, 240, 200)
		light.Shadows = true
		light.Enabled = false
		light.Parent = head
	end

	if player.Character then
		attachFlashlight(player.Character)
	end
	player.CharacterAdded:Connect(attachFlashlight)
end

function EffectsController.toggleFlashlight()
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local light = head and head:FindFirstChild("Flashlight")
	if light then
		light.Enabled = not light.Enabled
		Net.fireServer("GameReport", "lanterna:" .. tostring(light.Enabled))
	end
end

function EffectsController.playSfx(payload)
	if not payload then
		return
	end
	local volume = payload.volume or 0.5

	if payload.channel == "ambient" then
		ambientSound = ambientSound or ensureSound("MysteryAmbient", nil, { volume = volume, looped = true })
		if payload.sound and payload.sound ~= "" then
			ambientSound.SoundId = payload.sound
			ambientSound.Volume = volume
			ambientSound.Looped = payload.looped == true
			ambientSound:Play()
		end
		return
	end

	local sound = ensureSound("MysterySfx_" .. tostring(payload.sound), payload.sound, { volume = volume })
	sound.SoundId = payload.sound or sound.SoundId
	sound.Volume = volume
	sound.TimePosition = 0
	sound:Play()
end

function EffectsController.start()
	EffectsController.build()

	heartbeatSound = ensureSound("MysteryHeartbeat", Assets.Sfx.Bass, { volume = 0.0, looped = true })
	heartbeatSound:Play()

	Net.Event("ClientSfx").OnClientEvent:Connect(EffectsController.playSfx)

	Net.Event("ClientChase").OnClientEvent:Connect(function(payload)
		if payload.chasing then
			chaseShake = 1
			heartbeatSound.Volume = 0.45
		else
			chaseShake = 0
			heartbeatSound.Volume = 0.08
		end
	end)

	-- vinheta + tremor conforme o medo
	local accumulator = 0
	RunService.RenderStepped:Connect(function(deltaTime)
		local fear = (player:GetAttribute("Fear") or 0) / Config.Fear.MAX
		if vignette then
			vignette.ImageTransparency = 1 - math.clamp(fear * 0.8, 0, 0.8)
		end
		if fear > 0.1 then
			heartbeatSound.Volume = math.max(heartbeatSound.Volume, fear * 0.5)
		end

		accumulator += deltaTime
		if chaseShake > 0 and accumulator > 0.05 then
			accumulator = 0
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and camera.CameraType == Enum.CameraType.Custom then
				local offset =
					Vector3.new(math.random(-1, 1) * 0.12 * chaseShake, math.random(-1, 1) * 0.12 * chaseShake, 0)
				camera.CFrame = camera.CFrame + offset
			end
		end
	end)
end

return EffectsController
