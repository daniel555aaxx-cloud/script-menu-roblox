--[[
	PartKit.luau
	Fábrica de peças e props. É a camada que traduz os dados "amigáveis"
	(cores da paleta, nomes de material em português/inglês) para Instances
	do Roblox com materiais, luzes, partículas e sons.

	Usada por: MapBuilder, Decorator, PropBuilder, CharacterBuilder, MonsterBuilder.
]]

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local Assets = require(game:GetService("ReplicatedStorage").Shared.Assets)

local PartKit = {}

-- ==========================================================
-- MATERIAIS
-- ==========================================================
PartKit.Materials = {
	-- nomes "friendly" -> Enum.Material real
	Carpet = Enum.Material.Fabric,
	Ceramic = Enum.Material.Marble,
	Tile = Enum.Material.Marble,
	Plaster = Enum.Material.Concrete,
	Gravel = Enum.Material.Pebble,
	CorrugatedMetal = Enum.Material.DiamondPlate,
	Rubber = Enum.Material.Plastic,
	SmoothPlastic = Enum.Material.SmoothPlastic,
	Dirt = Enum.Material.Ground,
	Snow = Enum.Material.Snow,
	Leaves = Enum.Material.LeafyGrass,
}

local warnedMaterials = {}

function PartKit.material(name)
	if typeof(name) == "EnumItem" then
		return name
	end
	if not name then
		return Enum.Material.Plastic
	end
	local direct = Enum.Material[name]
	if direct then
		return direct
	end
	local mapped = PartKit.Materials[name]
	if mapped then
		return mapped
	end
	if not warnedMaterials[name] then
		warnedMaterials[name] = true
		warn(("[PartKit] Material desconhecido '%s' — usando Concrete."):format(tostring(name)))
	end
	return Enum.Material.Concrete
end

-- ==========================================================
-- CORES
-- ==========================================================
function PartKit.color(value)
	if typeof(value) == "Color3" then
		return value
	end
	if type(value) == "table" then
		if value.r and value.g and value.b then
			return Color3.fromRGB(value.r, value.g, value.b)
		end
		return Config.Palette[value[1]] or Color3.fromRGB(180, 180, 180)
	end
	if type(value) == "string" then
		local palette = Config.Palette[value]
		if typeof(palette) == "Color3" then
			return palette
		end
		-- permite "12,240,120"
		local r, g, b = value:match("(%d+),(%d+),(%d+)")
		if r then
			return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
		end
	end
	return Color3.fromRGB(180, 180, 180)
end

-- ==========================================================
-- CRIAÇÃO DE PEÇAS
-- ==========================================================
local SHAPES = {
	Block = Enum.PartType.Block,
	Ball = Enum.PartType.Ball,
	Cylinder = Enum.PartType.Cylinder,
	Wedge = Enum.PartType.Wedge,
	Corner = Enum.PartType.CornerWedge,
}

function PartKit.part(spec, parent)
	local part = Instance.new("Part")
	part.Name = spec.name or "Part"
	part.Anchored = spec.anchored ~= false
	part.CanCollide = spec.canCollide ~= false
	part.CanQuery = spec.canQuery ~= false
	part.CanTouch = spec.canTouch ~= false
	part.CastShadow = spec.castShadow ~= false
	part.Size = Vector3.new(spec.size[1], spec.size[2], spec.size[3])
	part.Shape = SHAPES[spec.shape or "Block"] or Enum.PartType.Block
	part.Material = spec.emissive and Enum.Material.Neon or PartKit.material(spec.material)
	part.Color = PartKit.color(spec.color)
	part.Transparency = spec.transparency or 0
	part.Reflectivity = spec.reflectivity or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Locked = true

	if spec.rotation then
		part.CFrame = CFrame.new(0, 0, 0)
			* CFrame.Angles(
				math.rad(spec.rotation[1] or 0),
				math.rad(spec.rotation[2] or 0),
				math.rad(spec.rotation[3] or 0)
			)
	end

	if spec.parent then
		part.Parent = spec.parent
	end

	return part
end

-- CFrame padrão de um prop: posição do chão + rotação Y
function PartKit.originCFrame(position, rotY)
	return CFrame.new(position) * CFrame.Angles(0, math.rad(rotY or 0), 0)
end

-- ==========================================================
-- CONSTRUÇÃO DE PROPS
-- ==========================================================
function PartKit.buildProp(propType, library, origin, parent, options)
	local spec = library[propType]
	if not spec then
		warn("[PartKit] Prop desconhecido: " .. tostring(propType))
		return nil
	end

	options = options or {}
	local model = Instance.new("Model")
	model.Name = spec.label or propType

	local scale = options.scale or 1
	local partsFolder = Instance.new("Folder")
	partsFolder.Name = "Parts"
	partsFolder.Parent = model

	for index, partSpec in ipairs(spec.parts) do
		local offset = partSpec.offset or { 0, 0, 0 }
		local part = PartKit.part({
			name = ("%s_%d"):format(propType, index),
			size = {
				(partSpec.size[1] or 1) * scale,
				(partSpec.size[2] or 1) * scale,
				(partSpec.size[3] or 1) * scale,
			},
			shape = partSpec.shape,
			color = partSpec.color or spec.baseColor,
			material = partSpec.material or spec.material,
			transparency = partSpec.transparency,
			emissive = partSpec.emissive,
			reflectivity = partSpec.reflectivity,
			rotation = partSpec.rotation,
			canCollide = options.collide ~= false and partSpec.canCollide ~= false,
			castShadow = options.castShadow,
			parent = partsFolder,
		})
		part.CFrame = origin
			* CFrame.new(offset[1] * scale, offset[2] * scale, offset[3] * scale)
			* (partSpec.rotation and CFrame.Angles(0, 0, 0) or CFrame.new())

		-- rotação local combinada com a rotação do prop
		if partSpec.rotation then
			local rx = math.rad(partSpec.rotation[1] or 0)
			local ry = math.rad(partSpec.rotation[2] or 0)
			local rz = math.rad(partSpec.rotation[3] or 0)
			part.CFrame = origin
				* CFrame.new(offset[1] * scale, offset[2] * scale, offset[3] * scale)
				* CFrame.Angles(rx, ry, rz)
		end

		if partSpec.emissive then
			PartKit.pointLight(part, { color = partSpec.color or spec.baseColor, brightness = 1.4, range = 10 })
		end
	end

	-- luzes declaradas
	for _, lightSpec in ipairs(spec.lights or {}) do
		local offset = lightSpec.offset or { 0, 0, 0 }
		local holder = PartKit.part({
			name = "LightHolder",
			size = { 0.2, 0.2, 0.2 },
			color = lightSpec.color or "Text",
			transparency = 1,
			canCollide = false,
			canQuery = false,
			parent = partsFolder,
		})
		holder.Anchored = true
		holder.CFrame = origin * CFrame.new(offset[1], offset[2], offset[3])
		PartKit.pointLight(holder, lightSpec)
	end

	-- luz única (atalho `light = {...}`)
	if spec.light then
		local lightSpec = spec.light
		local offset = lightSpec.offset or { 0, 0, 0 }
		local holder = PartKit.part({
			name = "LightHolder",
			size = { 0.2, 0.2, 0.2 },
			transparency = 1,
			canCollide = false,
			canQuery = false,
			parent = partsFolder,
		})
		holder.Anchored = true
		holder.CFrame = origin * CFrame.new(offset[1], offset[2], offset[3])
		PartKit.pointLight(holder, lightSpec)
	end

	-- partículas
	for _, particleSpec in ipairs(spec.particles or {}) do
		local offset = particleSpec.offset or { 0, 0, 0 }
		local emitterPart = partsFolder:FindFirstChild("ParticleHolder")
		if not emitterPart then
			emitterPart = PartKit.part({
				name = "ParticleHolder",
				size = { 0.4, 0.4, 0.4 },
				transparency = 1,
				canCollide = false,
				canQuery = false,
				parent = partsFolder,
			})
			emitterPart.Anchored = true
			emitterPart.CFrame = origin
		end
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "Fx"
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitter.Color = ColorSequence.new(PartKit.color(particleSpec.color or "Text"))
		emitter.Size = NumberSequence.new(particleSpec.size or 0.6)
		emitter.Transparency = NumberSequence.new(0.35)
		emitter.Lifetime = NumberRange.new(1.4)
		emitter.Rate = particleSpec.rate or 12
		emitter.Speed = NumberRange.new(particleSpec.speed or 1.2)
		emitter.SpreadAngle = Vector2.new(25, 25)
		emitter.LightEmission = 0.35
		emitter.Parent = emitterPart
	end

	-- decais
	for _, decalSpec in ipairs(spec.decals or {}) do
		local texture = Assets.texture(decalSpec.key)
		if texture then
			local offset = decalSpec.offset or { 0, 0, 0 }
			local part = PartKit.part({
				name = "DecalSurface",
				size = { (decalSpec.size and decalSpec.size[1]) or 4, (decalSpec.size and decalSpec.size[2]) or 4, 0.1 },
				color = "Text",
				transparency = 0,
				canCollide = false,
				canQuery = false,
				parent = partsFolder,
			})
			part.Anchored = true
			part.CFrame = origin * CFrame.new(offset[1], offset[2], offset[3])
			local decal = Instance.new("Decal")
			decal.Texture = texture
			decal.Face = Enum.NormalId.Front
			decal.Parent = part
		end
	end

	-- metadados usados pelos serviços
	model:SetAttribute("PropType", propType)
	model:SetAttribute("BlocksMovement", spec.blocksMovement == true)
	model.PrimaryPart = partsFolder:FindFirstChildWhichIsA("BasePart")

	local interact = options.interact or spec.interact
	if interact then
		local interactPart = partsFolder:FindFirstChildWhichIsA("BasePart")
		if interactPart then
			interactPart:SetAttribute("InteractKind", interact.kind or "generic")
			interactPart.Name = "InteractPart"
		end
	end

	model.Parent = parent
	return model
end

-- ==========================================================
-- EFEITOS SIMPLES
-- ==========================================================
function PartKit.pointLight(parent, spec)
	local light = Instance.new("PointLight")
	light.Color = PartKit.color(spec.color or "Text")
	light.Brightness = spec.brightness or 2
	light.Range = spec.range or 16
	light.Shadows = spec.shadows ~= false
	if spec.flicker then
		light.Name = "FlickerLight"
	end
	light.Parent = parent
	return light
end

function PartKit.spotLight(parent, spec)
	local light = Instance.new("SpotLight")
	light.Color = PartKit.color(spec.color or "Text")
	light.Brightness = spec.brightness or 3
	light.Range = spec.range or 40
	light.Angle = spec.angle or 60
	light.Face = spec.face or Enum.NormalId.Front
	light.Shadows = true
	light.Parent = parent
	return light
end

function PartKit.surfaceAppearance(part, options)
	local appearance = Instance.new("SurfaceAppearance")
	appearance.Name = "SurfaceAppearance"
	if options.albedo then
		appearance.ColorMap = options.albedo
	end
	if options.normal then
		appearance.NormalMap = options.normal
	end
	if options.roughness then
		appearance.RoughnessMap = options.roughness
	end
	if options.metalness then
		appearance.MetalnessMap = options.metalness
	end
	appearance.AlphaMode = Enum.AlphaMode.Overlay
	appearance.Parent = part
	return appearance
end

function PartKit.decal(parent, textureId, face, size)
	if not textureId then
		return nil
	end
	local decal = Instance.new("Decal")
	decal.Texture = textureId
	decal.Face = face or Enum.NormalId.Front
	decal.Parent = parent
	return decal
end

function PartKit.sound(parent, soundId, options)
	if not soundId then
		return nil
	end
	options = options or {}
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = options.volume or 0.5
	sound.Looped = options.looped == true
	sound.RollOffMaxDistance = options.maxDistance or 120
	sound.RollOffMinDistance = options.minDistance or 8
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.Name = options.name or "Sound"
	sound.Parent = parent
	if options.play then
		sound:Play()
	end
	return sound
end

function PartKit.highlight(parent, color, options)
	options = options or {}
	local highlight = Instance.new("Highlight")
	highlight.FillColor = PartKit.color(color or "Accent")
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = options.fillTransparency or 0.6
	highlight.OutlineTransparency = options.outlineTransparency or 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = parent
	return highlight
end

function PartKit.billboard(parent, text, options)
	options = options or {}
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.new(0, options.width or 200, 0, options.height or 60)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, options.heightOffset or 4, 0)
	billboard.AlwaysOnTop = options.alwaysOnTop ~= false
	billboard.MaxDistance = options.maxDistance or 120

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = PartKit.color(options.color or "Text")
	label.TextStrokeTransparency = 0.4
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Text = text
	label.Parent = billboard
	billboard.Parent = parent
	return billboard
end

-- ==========================================================
-- HELPERS GEOMÉTRICOS (usados pelos builders de parede/mapa)
-- ==========================================================
function PartKit.wallSegment(position, size, options)
	return PartKit.part({
		name = options and options.name or "Wall",
		size = size,
		color = options and options.color or "PanelLight",
		material = options and options.material or "Concrete",
		parent = options and options.parent,
		castShadow = options and options.castShadow,
	})
end

function PartKit.floorSlab(position, size, options)
	return PartKit.part({
		name = options and options.name or "Floor",
		size = size,
		color = options and options.color or "Panel",
		material = options and options.material or "Concrete",
		parent = options and options.parent,
	})
end

function PartKit.setAllAnchored(instance, anchored)
	for _, descendant in ipairs(instance:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = anchored
		end
	end
end

return PartKit
