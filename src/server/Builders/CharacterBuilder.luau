--[[
	CharacterBuilder.luau
	Monta os personagens (heróis e NPCs) como modelos rígidos (R6-like) feitos
	de peças, com cores e acessórios fiéis ao desenho:

		Fred    = camisa azul clara, calça azul, cachecol laranja
		Daphne  = vestido roxo, cabelo laranja, faixa verde
		Velma   = suéter laranja, saia vermelha, cabelo castanho, óculos
		Shaggy  = camiseta verde, calça marrom, barba rala
		Scooby  = cachorro marrom com coleira azul e medalha amarela

	Cada peça é soldada numa raiz ancorada que passa a ser movida pelo servidor
	(para NPCs) ou pelo jogador (para heróis, via Humanoid).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Cast = require(Shared.Data.Cast)

local PartKit = require(script.Parent.PartKit)

local CharacterBuilder = {}

local function deepCopy(source)
	local copy = {}
	for key, value in pairs(source) do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function part(name, size, color, parent, material)
	return PartKit.part({
		name = name,
		size = size,
		color = color,
		material = material or "SmoothPlastic",
		parent = parent,
	})
end

-- Blocos básicos de um corpo humano estilizado
local function buildHumanoidBody(model, palette, options)
	options = options or {}
	local root = part("HumanoidRootPart", Vector3.new(2, 2, 1), palette.shirt, model)
	root.Transparency = 1
	root.CanCollide = false

	local torso = part("Torso", Vector3.new(2, 2, 1), palette.torso, model)
	torso.Position = Vector3.new(0, 3, 0)

	local head = part("Head", Vector3.new(1.6, 1.6, 1.6), palette.skin or "Skin", model)
	head.Position = Vector3.new(0, 4.8, 0)

	local hair = part("Hair", Vector3.new(1.8, 0.7, 1.8), palette.hair or "ShaggyHair", model)
	hair.Position = Vector3.new(0, 5.6, 0)
	hair.Material = Enum.Material.SmoothPlastic

	local armLeft = part("Left Arm", Vector3.new(0.8, 2, 0.8), palette.arm or palette.shirt, model)
	armLeft.Position = Vector3.new(-1.4, 3, 0)
	local armRight = part("Right Arm", Vector3.new(0.8, 2, 0.8), palette.arm or palette.shirt, model)
	armRight.Position = Vector3.new(1.4, 3, 0)

	local legLeft = part("Left Leg", Vector3.new(0.9, 2, 0.9), palette.legs, model)
	legLeft.Position = Vector3.new(-0.6, 1, 0)
	local legRight = part("Right Leg", Vector3.new(0.9, 2, 0.9), palette.legs, model)
	legRight.Position = Vector3.new(0.6, 1, 0)

	if palette.face then
		local face = Instance.new("Decal")
		face.Texture = palette.face
		face.Face = Enum.NormalId.Front
		face.Parent = head
	end

	if options.glasses then
		local glasses = part("Glasses", Vector3.new(1.9, 0.3, 0.3), "Text", model, "SmoothPlastic")
		glasses.Position = Vector3.new(0, 4.9, 0.85)
		glasses.Transparency = 0.2
	end

	if options.scarf then
		local scarf = part("Scarf", Vector3.new(1.7, 0.5, 1.7), options.scarf, model, "Fabric")
		scarf.Position = Vector3.new(0, 4.05, 0)
	end

	if options.hairLong then
		local back = part("HairBack", Vector3.new(1.7, 2.2, 0.6), palette.hair or "DaphneHair", model)
		back.Position = Vector3.new(0, 4, -0.7)
	end

	return root,
		{
			torso = torso,
			head = head,
			hair = hair,
			armLeft = armLeft,
			armRight = armRight,
			legLeft = legLeft,
			legRight = legRight,
		}
end

-- ==========================================================
-- HEROÍNAS / HERÓIS
-- ==========================================================
local HERO_PALETTES = {
	Fred = {
		shirt = "Fred",
		torso = "Fred",
		legs = "Fred",
		hair = "FredHair",
		scarf = "MysteryOrange",
	},
	Daphne = {
		shirt = "Daphne",
		torso = "Daphne",
		legs = "DaphneHair",
		hair = "DaphneHair",
		scarf = "MysteryGreen",
	},
	Velma = {
		shirt = "Velma",
		torso = "Velma",
		legs = "Danger",
		hair = "VelmaHair",
	},
	Shaggy = {
		shirt = "Shaggy",
		torso = "Shaggy",
		legs = "ScoobyDark",
		hair = "ShaggyHair",
	},
}

function CharacterBuilder.buildHero(roleId)
	local role = Cast.Heroes[roleId]
	local palette = HERO_PALETTES[roleId] or HERO_PALETTES.Shaggy

	local model = Instance.new("Model")
	model.Name = "HERO_" .. roleId

	local root, joints = buildHumanoidBody(model, palette, {
		glasses = roleId == "Velma",
		scarf = palette.scarf,
		hairLong = roleId == "Daphne",
	})
	root.Transparency = 1
	root.CanCollide = false

	model.PrimaryPart = root
	model:SetAttribute("RoleId", roleId)
	model:SetAttribute("CharacterName", role.name or roleId)

	-- cor de identificação (usada para nametag)
	local highlight = PartKit.highlight(model, palette.torso, { fillTransparency = 0.85, outlineTransparency = 0.45 })
	highlight.Name = "TeamHighlight"

	-- nametag
	local billboard =
		PartKit.billboard(joints.head, (role.name or roleId) .. " — " .. (role.title or "Membro da turma"), {
			width = 240,
			color = "Text",
			heightOffset = 1.4,
			maxDistance = 90,
		})
	billboard.Name = "NameTag"

	-- acessórios
	for _, accessory in ipairs(role.accessories or {}) do
		CharacterBuilder.attachAccessory(model, joints, accessory)
	end

	return model, joints
end

function CharacterBuilder.attachAccessory(model, joints, accessory)
	if accessory == "glasses" and not joints.glasses then
		local glasses = part("Glasses", Vector3.new(1.9, 0.3, 0.3), "Text", model, "SmoothPlastic")
		glasses.Position = joints.head.Position + Vector3.new(0, 0.1, 0.85)
		glasses.Transparency = 0.15
		joints.glasses = glasses
	elseif accessory == "net" or accessory == "trap_kit" then
		local kit = part("TrapKit", Vector3.new(0.9, 1.1, 0.7), "Warning", model)
		kit.Position = joints.torso.Position + Vector3.new(0, -0.4, -0.9)
	elseif accessory == "magnifier" or accessory == "magnifying_glass" then
		local handle = part("Magnifier", Vector3.new(0.3, 0.3, 1.2), "Gold", model)
		handle.Position = joints.armRight.Position + Vector3.new(0, -0.9, 0.4)
	elseif accessory == "collar" or accessory == "medal" then
		local medal = part("Medal", Vector3.new(0.7, 0.7, 0.2), "Gold", model)
		medal.Position = joints.torso.Position + Vector3.new(0, 0.4, 0.7)
	elseif accessory == "hat" then
		local hat = part("Hat", Vector3.new(2, 0.4, 2), "Purple", model)
		hat.Position = joints.head.Position + Vector3.new(0, 1, 0)
	elseif accessory == "cap" then
		local cap = part("Cap", Vector3.new(1.8, 0.4, 1.8), "MysteryBlue", model)
		cap.Position = joints.head.Position + Vector3.new(0, 0.9, 0)
		local brim = part("Brim", Vector3.new(1.6, 0.2, 0.8), "MysteryBlue", model)
		brim.Position = joints.head.Position + Vector3.new(0, 0.75, 0.8)
	elseif accessory == "apron" then
		local apron = part("Apron", Vector3.new(1.9, 1.5, 0.2), "Text", model, "Fabric")
		apron.Position = joints.torso.Position + Vector3.new(0, -0.3, 0.6)
	elseif accessory == "vest_reflective" then
		local vest = part("Vest", Vector3.new(2.1, 1.4, 1.1), "Warning", model, "Fabric")
		vest.Position = joints.torso.Position
		vest.Transparency = 0.25
	elseif accessory == "uniform" then
		local badge = part("Badge", Vector3.new(0.5, 0.5, 0.2), "Gold", model)
		badge.Position = joints.torso.Position + Vector3.new(-0.5, 0.4, 0.6)
	elseif accessory == "scarf_green" then
		local scarf = part("Scarf", Vector3.new(1.7, 0.4, 1.7), "MysteryGreen", model, "Fabric")
		scarf.Position = joints.torso.Position + Vector3.new(0, 1.05, 0)
	elseif accessory == "notepad" then
		local notepad = part("Notepad", Vector3.new(0.9, 1.2, 0.15), "Text", model)
		notepad.Position = joints.armLeft.Position + Vector3.new(0, -0.9, 0.3)
	elseif accessory == "camera" then
		local camera = part("Camera", Vector3.new(1, 0.8, 0.7), "Panel", model)
		camera.Position = joints.head.Position + Vector3.new(0, 0.2, 1.1)
	elseif accessory == "rope" then
		local rope = part("Rope", Vector3.new(0.4, 1.6, 0.4), "Scooby", model)
		rope.Position = joints.torso.Position + Vector3.new(1, -0.6, 0)
	end
end

-- ==========================================================
-- SCOOBY
-- ==========================================================
function CharacterBuilder.buildScooby()
	local model = Instance.new("Model")
	model.Name = "HERO_Scooby"

	local root = part("HumanoidRootPart", Vector3.new(2, 2, 3), "Scooby", model)
	root.Transparency = 1
	root.CanCollide = false

	local body = part("Body", Vector3.new(2.2, 2.2, 3.4), "Scooby", model)
	body.Position = Vector3.new(0, 2, 0)

	local chest = part("Chest", Vector3.new(2.3, 1.4, 1.6), "Scooby", model)
	chest.Position = Vector3.new(0, 3.3, 0.7)

	local head = part("Head", Vector3.new(1.8, 1.8, 1.8), "Scooby", model)
	head.Position = Vector3.new(0, 4.4, 1.2)

	local snout = part("Snout", Vector3.new(1, 0.9, 1), "ScoobyDark", model)
	snout.Position = Vector3.new(0, 4.1, 2)

	local earLeft = part("EarLeft", Vector3.new(0.6, 1.2, 0.4), "ScoobyDark", model)
	earLeft.Position = Vector3.new(-0.8, 5.4, 0.9)
	local earRight = part("EarRight", Vector3.new(0.6, 1.2, 0.4), "ScoobyDark", model)
	earRight.Position = Vector3.new(0.8, 5.4, 0.9)

	local collar = part("Collar", Vector3.new(2, 0.4, 1.9), "MysteryBlue", model, "Fabric")
	collar.Position = Vector3.new(0, 3.6, 1)

	local medal = part("Medal", Vector3.new(0.8, 0.8, 0.25), "Gold", model)
	medal.Position = Vector3.new(0, 3.2, 2)

	local tail = part("Tail", Vector3.new(0.35, 0.35, 1.6), "Scooby", model)
	tail.Position = Vector3.new(0, 3.2, -2)

	local legFrontLeft = part("LegFL", Vector3.new(0.6, 1.4, 0.6), "Scooby", model)
	legFrontLeft.Position = Vector3.new(-0.7, 0.7, 1.1)
	local legFrontRight = part("LegFR", Vector3.new(0.6, 1.4, 0.6), "Scooby", model)
	legFrontRight.Position = Vector3.new(0.7, 0.7, 1.1)
	local legBackLeft = part("LegBL", Vector3.new(0.6, 1.4, 0.6), "Scooby", model)
	legBackLeft.Position = Vector3.new(-0.7, 0.7, -1.1)
	local legBackRight = part("LegBR", Vector3.new(0.6, 1.4, 0.6), "Scooby", model)
	legBackRight.Position = Vector3.new(0.7, 0.7, -1.1)

	model.PrimaryPart = root
	model:SetAttribute("RoleId", "Scooby")

	local billboard = PartKit.billboard(
		head,
		"Scooby-Doo — cadê você?",
		{ width = 240, color = "Text", heightOffset = 1.6, maxDistance = 90 }
	)
	billboard.Name = "NameTag"

	return model, {
		torso = body,
		head = head,
		earLeft = earLeft,
		earRight = earRight,
		tail = tail,
	}
end

-- ==========================================================
-- NPCs
-- ==========================================================
local NPC_PALETTES = {
	civilian = { shirt = "PanelLight", torso = "PanelLight", legs = "Panel", hair = "ScoobyDark" },
	worker = { shirt = "Warning", torso = "Warning", legs = "Panel", hair = "ScoobyDark" },
	official = { shirt = "MysteryBlue", torso = "MysteryBlue", legs = "Panel", hair = "ScoobyDark" },
	artist = { shirt = "Purple", torso = "Purple", legs = "Panel", hair = "Purple" },
	farmer = { shirt = "MysteryGreen", torso = "MysteryGreen", legs = "ScoobyDark", hair = "FredHair" },
}

function CharacterBuilder.buildNpc(npcId)
	local npc = Cast.getNpc(npcId)
	if not npc then
		return nil
	end

	local model = Instance.new("Model")
	model.Name = "NPC_" .. npcId

	local palette = deepCopy(NPC_PALETTES[npc.palette or "civilian"] or NPC_PALETTES.civilian)
	local colors = npc.humanColors
	if colors then
		palette.shirt = colors.shirt or palette.shirt
		palette.torso = colors.shirt or palette.torso
		palette.legs = colors.pants or palette.legs
		palette.hair = colors.hair or palette.hair
		if colors.skin then
			palette.skin = colors.skin
		end
	end

	local root, joints = buildHumanoidBody(model, palette, {
		glasses = npc.glasses,
	})
	root.Transparency = 1
	root.CanCollide = false
	model.PrimaryPart = root
	model:SetAttribute("NpcId", npcId)
	model:SetAttribute("NpcRole", npc.role or "figurante")

	for _, accessory in ipairs(npc.accessories or {}) do
		CharacterBuilder.attachAccessory(model, joints, accessory)
	end

	local billboard = PartKit.billboard(joints.head, npc.name or npcId, {
		width = 220,
		color = "Text",
		heightOffset = 1.3,
		maxDistance = 80,
	})
	billboard.Name = "NameTag"

	return model, joints
end

local MONSTER_SHAPES = {
	cloak = Enum.PartType.Block,
	hood = Enum.PartType.Ball,
	head = Enum.PartType.Ball,
	eye = Enum.PartType.Ball,
	arm = Enum.PartType.Block,
	leg = Enum.PartType.Block,
	wisp = Enum.PartType.Block,
	body = Enum.PartType.Block,
	tentacle = Enum.PartType.Cylinder,
	spike = Enum.PartType.Wedge,
	hat = Enum.PartType.Block,
	barrel = Enum.PartType.Cylinder,
	mask = Enum.PartType.Block,
	propeller = Enum.PartType.Block,
	light = Enum.PartType.Ball,
	claw = Enum.PartType.Wedge,
	hose = Enum.PartType.Cylinder,
	tank = Enum.PartType.Cylinder,
	veil = Enum.PartType.Block,
	crown = Enum.PartType.Block,
	orb = Enum.PartType.Ball,
	crystal = Enum.PartType.Wedge,
	patch = Enum.PartType.Block,
	pumpkin_head = Enum.PartType.Ball,
	engine = Enum.PartType.Cylinder,
	wheel = Enum.PartType.Cylinder,
	cape = Enum.PartType.Block,
	cane = Enum.PartType.Cylinder,
	top_hat = Enum.PartType.Cylinder,
	frame = Enum.PartType.Block,
	glass_panel = Enum.PartType.Block,
}

-- Constrói o monstro a partir da especificação declarativa em Cast.Monsters[id].model
function CharacterBuilder.buildMonster(monsterId, monsterData)
	local monster = monsterData or Cast.getMonster(monsterId)
	if not monster or not monster.model then
		return nil
	end

	local spec = monster.model
	local model = Instance.new("Model")
	model.Name = "MONSTER_" .. tostring(monster.id or monsterId)

	local root = PartKit.part({
		name = "HumanoidRootPart",
		size = { 4, 2, 4 },
		color = spec.baseColor or "PanelLight",
		transparency = 1,
		canCollide = false,
		parent = model,
	})

	local partsFolder = Instance.new("Folder")
	partsFolder.Name = "Parts"
	partsFolder.Parent = model

	local built = {}
	for index, partSpec in ipairs(spec.parts or {}) do
		local offset = partSpec.offset or { 0, 0, 0 }
		local part = PartKit.part({
			name = ("%s_%d"):format(partSpec.kind or "part", index),
			size = partSpec.size or { 1, 1, 1 },
			shape = MONSTER_SHAPES[partSpec.kind or "body"] or Enum.PartType.Block,
			color = partSpec.color or spec.baseColor or "PanelLight",
			material = (partSpec.kind == "eye" or partSpec.kind == "light") and Enum.Material.Neon
				or spec.material
				or "Fabric",
			transparency = partSpec.transparency or spec.transparency or 0,
			reflectivity = partSpec.reflectivity or spec.reflectivity or 0,
			rotation = partSpec.rotation,
			canCollide = false,
			castShadow = partSpec.kind ~= "eye",
			parent = partsFolder,
		})
		part.CFrame = CFrame.new(offset[1], offset[2], offset[3])
			* CFrame.Angles(
				math.rad((partSpec.rotation and partSpec.rotation[1]) or 0),
				math.rad((partSpec.rotation and partSpec.rotation[2]) or 0),
				math.rad((partSpec.rotation and partSpec.rotation[3]) or 0)
			)
		part.Anchored = false
		table.insert(built, part)

		-- brilho extra nos olhos/luzes
		if partSpec.kind == "eye" or partSpec.kind == "light" or partSpec.glow then
			PartKit.pointLight(part, {
				color = partSpec.color or spec.accentColor or "Accent",
				brightness = partSpec.glowBrightness or 2.5,
				range = partSpec.glowRange or 14,
			})
		end
	end

	-- solda todas as peças na raiz (modelo rígido controlado pelo servidor)
	for _, part in ipairs(built) do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = part
		weld.Parent = part
	end

	model.PrimaryPart = root
	model:SetAttribute("MonsterId", monster.id or monsterId)
	model:SetAttribute("MonsterName", monster.name or "???")
	model:SetAttribute("SpecKind", spec.kind or "custom")

	-- aura/partículas
	for _, effect in ipairs(spec.effects or {}) do
		if effect == "aura_soft" or effect == "fog_trail" or effect == "glow_pulse" or effect == "smoke" then
			local emitterPart = built[1]
			if emitterPart then
				local emitter = Instance.new("ParticleEmitter")
				emitter.Name = "Aura_" .. effect
				emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
				emitter.Color = ColorSequence.new(PartKit.color(spec.accentColor or spec.baseColor or "Text"))
				emitter.Size = NumberSequence.new(effect == "fog_trail" and 3 or 1.6)
				emitter.Transparency = NumberSequence.new(0.75)
				emitter.Lifetime = NumberRange.new(1.6)
				emitter.Rate = effect == "fog_trail" and 18 or 8
				emitter.Speed = NumberRange.new(0.8)
				emitter.SpreadAngle = Vector2.new(45, 45)
				emitter.LightEmission = 0.5
				emitter.Parent = emitterPart
			end
		end
	end

	local head = built[1]
	local billboard = PartKit.billboard(head or root, monster.name or "???", {
		width = 280,
		color = "Danger",
		heightOffset = (spec.height or 8) + 1,
		maxDistance = 160,
		alwaysOnTop = true,
	})
	billboard.Name = "NameTag"

	return model, {
		root = root,
		parts = built,
		head = head,
		spec = spec,
	}
end

return CharacterBuilder
