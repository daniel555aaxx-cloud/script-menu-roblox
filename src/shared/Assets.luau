--[[
	Assets.luau
	Central de recursos visuais/sonoros.

	IMPORTANTE (leia docs/ASSETS-E-GRAFICOS.md):
	* Os sons em `Assets.Sfx` usam arquivos que já vêm no cliente do Roblox
	  (rbxasset://sounds/...). Funcionam sem upload.
	* `Assets.Sounds` e `Assets.Textures` são "slots" para você colar IDs dos
	  seus próprios uploads (músicas, texturas PBR, decais do desenho/filme).
	  Enquanto o ID for 0, o jogo usa o fallback procedural (cor + material),
	  então o jogo funciona 100% sem nenhum asset externo.
	* `Assets.Models` permite substituir os modelos procedurais por modelos
	  customizados que você colocou em ServerStorage.CustomModels.
]]

local Assets = {}

-- ==========================================================
-- SONS EMBUTIDOS NO CLIENTE (não precisam de upload)
-- ==========================================================
Assets.Sfx = {
	Click = "rbxasset://sounds/clickfast.wav",
	Button = "rbxasset://sounds/button.wav",
	Switch = "rbxasset://sounds/switch.wav",
	SwitchAlt = "rbxasset://sounds/switch3.wav",
	Ping = "rbxasset://sounds/electronicpingshort.wav",
	Bass = "rbxasset://sounds/bass.wav",
	Hit = "rbxasset://sounds/hit.wav",
	Metal = "rbxasset://sounds/metal.ogg",
	Snap = "rbxasset://sounds/snap.mp3",
	Pop = "rbxasset://sounds/pop_mid.ogg",
	Water = "rbxasset://sounds/impact_water.mp3",
	Footsteps = "rbxasset://sounds/action_footsteps_plastic.mp3",
	Jump = "rbxasset://sounds/action_jump.mp3",
	Land = "rbxasset://sounds/action_jump_land.mp3",
	Fall = "rbxasset://sounds/action_falling.mp3",
	GetUp = "rbxasset://sounds/action_get_up.mp3",
	Swim = "rbxasset://sounds/action_swim.mp3",
	Oof = "rbxasset://sounds/uuhhh.mp3",
}

-- ==========================================================
-- SLOTS DE UPLOAD (cole seus IDs aqui)
-- Formato: "rbxassetid://NUMERO" ou 0 para desativado
-- ==========================================================
Assets.Sounds = {
	-- Músicas (mude para músicas licenciadas que você subir)
	ThemeMusic = 0,
	LobbyMusic = 0,
	ChaseMusic = 0,
	RevealMusic = 0,
	SuspenseMusic = 0,

	-- Efeitos de assinatura (grátis para subir no seu grupo)
	MysteryMachineHorn = 0,
	ScoobySnackCrunch = 0,
	GhostMoan = 0,
	Heartbeat = 0,
	TrapSpring = 0,
	UnmaskStinger = 0,
	JumpscareScream = 0,
	RuhRoh = 0, -- "Ruh-roh!" do Scooby
	RaggyCall = 0, -- "Socorro, Salsicha!"
}

Assets.Textures = {
	-- Superfícies PBR (SurfaceAppearance). 0 = usa só material/cor.
	WoodFloor = 0,
	OldCarpet = 0,
	ConcreteWall = 0,
	CrackedBrick = 0,
	Asphalt = 0,
	Gravel = 0,
	Grass = 0,
	RustyMetal = 0,
	CorrugatedMetal = 0,
	CircusCanvas = 0,
	Cobblestone = 0,
	MarbleFloor = 0,
	WallpaperVictorian = 0,
	TileFloor = 0,
	FactoryPanel = 0,
}

Assets.Decals = {
	-- Decais de parede (cartazes, avisos, quadros do desenho)
	MysteryMachineFlower = 0,
	ScarePoster = 0,
	MissingPet = 0,
	CircusPoster = 0,
	CandyAd = 0,
	LighthouseLog = 0,
	GangPhoto = 0,
}

Assets.Models = {
	-- Se existir um Model com este nome dentro de ServerStorage.CustomModels,
	-- ele é usado no lugar do modelo procedural.
	MysteryMachine = "MysteryMachine_Hero",
	Scooby = "Scooby_Model",
	MonsterPrefix = "Monster_", -- Monster_EP01, Monster_EP02...
	NpcPrefix = "NPC_",
	Lobby = "Lobby_Model",
}

Assets.MeshIds = {
	-- Malhas prontas (opcional). 0 = usa peças primitivas.
	ScoobySnack = 0,
	Lantern = 0,
	Flashlight = 0,
}

-- ==========================================================
-- Helpers
-- ==========================================================
function Assets.id(slot)
	if type(slot) == "number" then
		if slot <= 0 then
			return nil
		end
		return "rbxassetid://" .. tostring(slot)
	end
	if type(slot) == "string" and slot ~= "" then
		return slot
	end
	return nil
end

function Assets.sound(name)
	return Assets.id(Assets.Sounds[name]) or Assets.Sfx[name] or nil
end

function Assets.texture(name)
	return Assets.id(Assets.Textures[name]) or Assets.id(Assets.Decals[name])
end

function Assets.hasCustomModel(serverStorage, name)
	if not name then
		return nil
	end
	local folder = serverStorage:FindFirstChild("CustomModels")
	if not folder then
		return nil
	end
	local model = folder:FindFirstChild(name)
	if model and model:IsA("Model") then
		return model
	end
	return nil
end

return Assets
