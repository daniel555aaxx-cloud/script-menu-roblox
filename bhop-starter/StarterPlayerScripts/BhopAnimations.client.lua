-- Opcional: animações próprias de salto e aterrissagem.
-- Antes de usar, publique animações criadas por você e preencha os IDs abaixo.
-- Coloque como LocalScript em StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- IDs numéricos publicados no Roblox. Deixe "" para usar as animações padrão do avatar.
local JUMP_ANIMATION_ID = ""
local LAND_ANIMATION_ID = ""

local function makeTrack(animator, animationId, priority)
	if animationId == "" then
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. animationId
	local track = animator:LoadAnimation(animation)
	track.Priority = priority
	return track
end

local function setup(character)
	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	local jumpTrack = makeTrack(animator, JUMP_ANIMATION_ID, Enum.AnimationPriority.Action)
	local landTrack = makeTrack(animator, LAND_ANIMATION_ID, Enum.AnimationPriority.Action)

	humanoid.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Jumping and jumpTrack then
			if landTrack and landTrack.IsPlaying then
				landTrack:Stop(0.08)
			end
			jumpTrack:Play(0.08)
		elseif newState == Enum.HumanoidStateType.Landed and landTrack then
			if jumpTrack and jumpTrack.IsPlaying then
				jumpTrack:Stop(0.08)
			end
			landTrack:Play(0.06)
		end
	end)
end

player.CharacterAdded:Connect(setup)
if player.Character then
	task.spawn(setup, player.Character)
end
