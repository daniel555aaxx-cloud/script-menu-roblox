--[[
	Graphics.luau
	Presets de qualidade visual. O servidor aplica a "atmosfera base" do
	capítulo (noite, neblina, tom) e cada cliente aplica os efeitos extras
	que só ele vê (bloom, depth of field, rayos de sol, color grading).

	Observação técnica: Lighting.Technology ("Future") só pode ser definido no
	Studio/arquivo de place. Os presets abaixo assumem Future com sombras
	dinâmicas ligadas (já configurado no default.project.json).
]]

local Config = require(script.Parent.Config)

local Graphics = {}

Graphics.Presets = {
	Baixo = {
		label = "Baixo (celular/PC fraco)",
		bloom = false,
		dof = false,
		sunRays = false,
		colorCorrection = true,
		atmosphere = true,
		shadowSoftness = 0,
		environmentDiffuse = 0.35,
		environmentSpecular = 0.35,
		maxParticles = 25,
		renderDistance = 900,
		drawQuality = 0.5,
	},
	Medio = {
		label = "Médio",
		bloom = true,
		dof = false,
		sunRays = false,
		colorCorrection = true,
		atmosphere = true,
		shadowSoftness = 0.25,
		environmentDiffuse = 0.6,
		environmentSpecular = 0.6,
		maxParticles = 60,
		renderDistance = 1600,
		drawQuality = 0.8,
	},
	Alto = {
		label = "Alto",
		bloom = true,
		dof = true,
		sunRays = true,
		colorCorrection = true,
		atmosphere = true,
		shadowSoftness = 0.35,
		environmentDiffuse = 0.85,
		environmentSpecular = 0.85,
		maxParticles = 120,
		renderDistance = 2600,
		drawQuality = 1,
	},
	Ultra = {
		label = "Ultra (realista)",
		bloom = true,
		dof = true,
		sunRays = true,
		colorCorrection = true,
		atmosphere = true,
		shadowSoftness = 0.45,
		environmentDiffuse = 1,
		environmentSpecular = 1,
		maxParticles = 220,
		renderDistance = 4200,
		drawQuality = 1.35,
	},
	Cinema = {
		label = "Cinema (gravação de vídeo)",
		bloom = true,
		dof = true,
		sunRays = true,
		colorCorrection = true,
		atmosphere = true,
		shadowSoftness = 0.55,
		environmentDiffuse = 1,
		environmentSpecular = 1,
		maxParticles = 300,
		renderDistance = 6000,
		drawQuality = 1.6,
	},
}

Graphics.Order = { "Baixo", "Medio", "Alto", "Ultra", "Cinema" }

-- "Atmosfera" de cada episódio: tudo aplicado no Lighting pelo servidor.
Graphics.Moods = {
	EP01_Farol = {
		clockTime = 20.2,
		brightness = 1.4,
		ambient = Color3.fromRGB(38, 46, 66),
		outdoorAmbient = Color3.fromRGB(64, 74, 96),
		fogColor = Color3.fromRGB(62, 78, 104),
		fogStart = 60,
		fogEnd = 520,
		atmosphereDensity = 0.42,
		atmosphereHaze = 2.4,
		atmosphereColor = Color3.fromRGB(120, 140, 180),
		colorTint = Color3.fromRGB(196, 210, 236),
		saturation = -0.06,
		contrast = 0.08,
		exposure = 0.05,
	},
	EP02_Hotel = {
		clockTime = 21.6,
		brightness = 1.1,
		ambient = Color3.fromRGB(44, 36, 40),
		outdoorAmbient = Color3.fromRGB(60, 52, 60),
		fogColor = Color3.fromRGB(48, 40, 48),
		fogStart = 40,
		fogEnd = 380,
		atmosphereDensity = 0.5,
		atmosphereHaze = 2.8,
		atmosphereColor = Color3.fromRGB(120, 100, 130),
		colorTint = Color3.fromRGB(214, 190, 200),
		saturation = -0.1,
		contrast = 0.12,
		exposure = 0.02,
	},
	EP03_Circo = {
		clockTime = 19.4,
		brightness = 1.6,
		ambient = Color3.fromRGB(52, 40, 70),
		outdoorAmbient = Color3.fromRGB(72, 56, 92),
		fogColor = Color3.fromRGB(74, 56, 96),
		fogStart = 55,
		fogEnd = 460,
		atmosphereDensity = 0.38,
		atmosphereHaze = 2.2,
		atmosphereColor = Color3.fromRGB(150, 120, 190),
		colorTint = Color3.fromRGB(220, 200, 240),
		saturation = 0.06,
		contrast = 0.1,
		exposure = 0.1,
	},
	EP04_Fabrica = {
		clockTime = 22.1,
		brightness = 1.2,
		ambient = Color3.fromRGB(46, 40, 34),
		outdoorAmbient = Color3.fromRGB(64, 56, 46),
		fogColor = Color3.fromRGB(52, 46, 40),
		fogStart = 35,
		fogEnd = 340,
		atmosphereDensity = 0.46,
		atmosphereHaze = 2.6,
		atmosphereColor = Color3.fromRGB(140, 120, 100),
		colorTint = Color3.fromRGB(226, 208, 186),
		saturation = -0.02,
		contrast = 0.14,
		exposure = 0.04,
	},
	EP05_Estrada = {
		clockTime = 23.2,
		brightness = 0.9,
		ambient = Color3.fromRGB(30, 32, 44),
		outdoorAmbient = Color3.fromRGB(46, 48, 62),
		fogColor = Color3.fromRGB(40, 44, 58),
		fogStart = 25,
		fogEnd = 300,
		atmosphereDensity = 0.55,
		atmosphereHaze = 3.1,
		atmosphereColor = Color3.fromRGB(110, 118, 140),
		colorTint = Color3.fromRGB(198, 206, 228),
		saturation = -0.16,
		contrast = 0.16,
		exposure = -0.02,
	},
	EP06_Mansao = {
		clockTime = 20.8,
		brightness = 1.35,
		ambient = Color3.fromRGB(42, 34, 54),
		outdoorAmbient = Color3.fromRGB(62, 52, 78),
		fogColor = Color3.fromRGB(56, 46, 72),
		fogStart = 45,
		fogEnd = 420,
		atmosphereDensity = 0.4,
		atmosphereHaze = 2.3,
		atmosphereColor = Color3.fromRGB(150, 130, 190),
		colorTint = Color3.fromRGB(222, 206, 244),
		saturation = 0.03,
		contrast = 0.1,
		exposure = 0.06,
	},
	Lobby = {
		clockTime = 18.4,
		brightness = 2.4,
		ambient = Color3.fromRGB(96, 96, 112),
		outdoorAmbient = Color3.fromRGB(128, 128, 148),
		fogColor = Color3.fromRGB(150, 150, 170),
		fogStart = 220,
		fogEnd = 1200,
		atmosphereDensity = 0.28,
		atmosphereHaze = 1.6,
		atmosphereColor = Color3.fromRGB(180, 186, 210),
		colorTint = Color3.fromRGB(248, 248, 255),
		saturation = 0.05,
		contrast = 0.04,
		exposure = 0.08,
	},
}

function Graphics.getPreset(name)
	return Graphics.Presets[name] or Graphics.Presets.Alto
end

function Graphics.getMood(name)
	return Graphics.Moods[name] or Graphics.Moods.Lobby
end

-- Aplica o clima no Lighting (servidor). Cria/atualiza os objetos de efeito.
function Graphics.applyMood(moodName)
	local Lighting = game:GetService("Lighting")
	local mood = Graphics.getMood(moodName)

	Lighting.ClockTime = mood.clockTime
	Lighting.Brightness = mood.brightness
	Lighting.Ambient = mood.ambient
	Lighting.OutdoorAmbient = mood.outdoorAmbient
	Lighting.FogColor = mood.fogColor
	Lighting.FogStart = mood.fogStart
	Lighting.FogEnd = mood.fogEnd
	Lighting.ExposureCompensation = mood.exposure
	Lighting.GlobalShadows = true

	local atmosphere = Lighting:FindFirstChild("MysteryAtmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "MysteryAtmosphere"
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = mood.atmosphereDensity
	atmosphere.Haze = mood.atmosphereHaze
	atmosphere.Glare = 0.15
	atmosphere.Color = mood.atmosphereColor
	atmosphere.Decay = Color3.fromRGB(106, 112, 125)

	local colorCorrection = Lighting:FindFirstChild("MysteryColorCorrection")
	if not colorCorrection then
		colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Name = "MysteryColorCorrection"
		colorCorrection.Parent = Lighting
	end
	colorCorrection.TintColor = mood.colorTint
	colorCorrection.Saturation = mood.saturation
	colorCorrection.Contrast = mood.contrast
	colorCorrection.Brightness = 0

	return mood
end

-- Efeitos que rodam no cliente (não afetam os outros jogadores).
function Graphics.applyClientPreset(player, presetName)
	local Lighting = game:GetService("Lighting")
	local preset = Graphics.getPreset(presetName)

	Lighting.ShadowSoftness = preset.shadowSoftness
	Lighting.EnvironmentDiffuseScale = preset.environmentDiffuse
	Lighting.EnvironmentSpecularScale = preset.environmentSpecular

	local function ensure(className, name)
		local instance = Lighting:FindFirstChild(name)
		if not instance then
			instance = Instance.new(className)
			instance.Name = name
			instance.Parent = Lighting
		end
		return instance
	end

	local function setEnabled(className, name, enabled)
		if not enabled then
			local existing = Lighting:FindFirstChild(name)
			if existing then
				existing.Enabled = false
			end
			return nil
		end
		local instance = ensure(className, name)
		instance.Enabled = true
		return instance
	end

	setEnabled("BloomEffect", "MM_Bloom", preset.bloom)
	if preset.bloom then
		local bloom = Lighting:FindFirstChild("MM_Bloom")
		bloom.Intensity = 0.7 + preset.drawQuality * 0.25
		bloom.Size = 18 + preset.drawQuality * 6
		bloom.Threshold = 0.92
	end

	local dof = setEnabled("DepthOfFieldEffect", "MM_Dof", preset.dof)
	if dof then
		dof.FarIntensity = 0.12
		dof.FocusDistance = 42
		dof.InFocusRadius = 48
		dof.NearIntensity = 0.05
	end

	local rays = setEnabled("SunRaysEffect", "MM_SunRays", preset.sunRays)
	if rays then
		rays.Intensity = 0.06 + preset.drawQuality * 0.04
		rays.Spread = 1
	end

	local cc = setEnabled("ColorCorrectionEffect", "MM_ClientColor", preset.colorCorrection)
	if cc then
		cc.Brightness = 0
		cc.Contrast = 0.03
		cc.Saturation = 0.02
		cc.TintColor = Color3.fromRGB(252, 250, 255)
	end

	local Lighting = Lighting
	Lighting.GlobalShadows = true

	if player then
		player:SetAttribute("GraphicsPreset", presetName)
	end

	return preset
end

function Graphics.serverBaseLighting()
	local Lighting = game:GetService("Lighting")
	Lighting.Technology = Lighting.Technology -- no-op, mantido por clareza
	Lighting.ShadowSoftness = 0.35
	Lighting.EnvironmentDiffuseScale = 0.85
	Lighting.EnvironmentSpecularScale = 0.85
	Lighting.GlobalShadows = true
	Lighting.ExposureCompensation = 0.12
	Graphics.applyMood("Lobby")
end

-- Resolve uma cor nomeada da paleta (usado por dados/decorators)
function Graphics.paletteColor(name)
	local value = Config.Palette[name]
	if typeof(value) == "Color3" then
		return value
	end
	return Color3.fromRGB(200, 200, 200)
end

return Graphics
