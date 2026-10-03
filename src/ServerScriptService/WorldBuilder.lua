-- Constrói o escritório inteiro em tempo de execução, sem depender de modelos externos.
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local WorldBuilder = {}

local C = {
	Ink = Color3.fromRGB(22, 32, 45),
	Navy = Color3.fromRGB(25, 43, 63),
	Blue = Color3.fromRGB(45, 111, 145),
	Teal = Color3.fromRGB(54, 153, 145),
	Mint = Color3.fromRGB(118, 205, 177),
	Coral = Color3.fromRGB(242, 135, 103),
	Gold = Color3.fromRGB(243, 189, 91),
	Wall = Color3.fromRGB(229, 235, 235),
	WallShade = Color3.fromRGB(200, 212, 215),
	Floor = Color3.fromRGB(201, 211, 211),
	Carpet = Color3.fromRGB(73, 106, 119),
	Wood = Color3.fromRGB(137, 101, 76),
	WoodLight = Color3.fromRGB(183, 145, 106),
	Dark = Color3.fromRGB(41, 49, 58),
	White = Color3.fromRGB(247, 249, 247),
	Green = Color3.fromRGB(83, 147, 102),
	Glass = Color3.fromRGB(150, 213, 222),
}

local function makePart(parent, name, size, cframe, color, material, transparency, canCollide, shape)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cframe
	item.Color = color or C.White
	item.Material = material or Enum.Material.SmoothPlastic
	item.Transparency = transparency or 0
	item.Anchored = true
	item.CanCollide = canCollide ~= false
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.CastShadow = true
	if shape then
		item.Shape = shape
	end
	item.Parent = parent
	return item
end

local function box(parent, name, size, position, color, material, transparency, canCollide, rotation, shape)
	local cframe = CFrame.new(position)
	if rotation then
		cframe *= rotation
	end
	return makePart(parent, name, size, cframe, color, material, transparency, canCollide, shape)
end

local function addPointLight(parent, color, brightness, range)
	local light = Instance.new("PointLight")
	light.Color = color or C.White
	light.Brightness = brightness or 1.2
	light.Range = range or 20
	light.Shadows = false
	light.Parent = parent
	return light
end

local function addSurfaceText(panel, face, text, textColor, backgroundColor, textSize, yScale)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "OfficeSign"
	gui.Face = face or Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(math.max(250, math.floor(panel.Size.X * 100)), math.max(120, math.floor(panel.Size.Y * 100)))
	gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	gui.LightInfluence = 0
	gui.AlwaysOnTop = false
	gui.Parent = panel

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundColor3 = backgroundColor or Color3.new(0, 0, 0)
	label.BackgroundTransparency = backgroundColor and 0.1 or 1
	label.BorderSizePixel = 0
	label.Size = UDim2.new(1, -30, yScale or 1, -24)
	label.Position = UDim2.new(0, 15, 0, 12)
	label.Font = Enum.Font.GothamBold
	label.Text = text or ""
	label.TextColor3 = textColor or C.White
	label.TextSize = textSize or 42
	label.TextWrapped = true
	label.TextScaled = false
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = gui
	return label, gui
end

local function addDecorativeWindow(parent, orientation, center, width, height)
	local glassSize
	local glassPosition
	local framePieces = {}
	if orientation == "Side" then
		glassSize = Vector3.new(0.35, height, width)
		glassPosition = Vector3.new(center.X, center.Y, center.Z)
		framePieces = {
			{Vector3.new(0.5, 0.35, width + 0.5), Vector3.new(center.X, center.Y + height / 2, center.Z)},
			{Vector3.new(0.5, 0.35, width + 0.5), Vector3.new(center.X, center.Y - height / 2, center.Z)},
			{Vector3.new(0.5, height + 0.5, 0.35), Vector3.new(center.X, center.Y, center.Z - width / 2)},
			{Vector3.new(0.5, height + 0.5, 0.35), Vector3.new(center.X, center.Y, center.Z + width / 2)},
			{Vector3.new(0.5, 0.18, 0.18), Vector3.new(center.X, center.Y, center.Z)},
		}
	else
		glassSize = Vector3.new(width, height, 0.35)
		glassPosition = Vector3.new(center.X, center.Y, center.Z)
		framePieces = {
			{Vector3.new(width + 0.5, 0.35, 0.5), Vector3.new(center.X, center.Y + height / 2, center.Z)},
			{Vector3.new(width + 0.5, 0.35, 0.5), Vector3.new(center.X, center.Y - height / 2, center.Z)},
			{Vector3.new(0.35, height + 0.5, 0.5), Vector3.new(center.X - width / 2, center.Y, center.Z)},
			{Vector3.new(0.35, height + 0.5, 0.5), Vector3.new(center.X + width / 2, center.Y, center.Z)},
			{Vector3.new(0.18, height, 0.5), Vector3.new(center.X, center.Y, center.Z)},
		}
	end

	box(parent, "PanoramicGlass", glassSize, glassPosition, C.Glass, Enum.Material.Glass, 0.48, false)
	for _, piece in ipairs(framePieces) do
		box(parent, "WindowFrame", piece[1], piece[2], C.White, Enum.Material.Metal, 0, false)
	end
end

local function addOfficePlant(parent, x, y, z, scale)
	scale = scale or 1
	box(parent, "PlantPot", Vector3.new(1.15, 1.1, 1.15) * scale, Vector3.new(x, y + 0.55 * scale, z), C.Wood, Enum.Material.SmoothPlastic)
	box(parent, "PlantSoil", Vector3.new(0.92, 0.12, 0.92) * scale, Vector3.new(x, y + 1.06 * scale, z), Color3.fromRGB(72, 54, 39), Enum.Material.Ground, 0, false)
	box(parent, "PlantStem", Vector3.new(0.18, 1.5, 0.18) * scale, Vector3.new(x, y + 1.75 * scale, z), C.Green, Enum.Material.SmoothPlastic, 0, false)
	for i = 1, 5 do
		local angle = (math.pi * 2 / 5) * i
		local leafPosition = Vector3.new(x + math.cos(angle) * 0.48 * scale, y + (1.75 + (i % 2) * 0.38) * scale, z + math.sin(angle) * 0.48 * scale)
		box(parent, "Leaf", Vector3.new(0.8, 0.65, 0.8) * scale, leafPosition, i % 2 == 0 and C.Green or C.Mint, Enum.Material.Grass, 0, false, nil, Enum.PartType.Ball)
	end
	box(parent, "LeafTop", Vector3.new(0.8, 0.8, 0.8) * scale, Vector3.new(x, y + 2.55 * scale, z), C.Green, Enum.Material.Grass, 0, false, nil, Enum.PartType.Ball)
end

local function addChair(parent, x, z, color, facing)
	facing = facing or 1
	local backZ = z + (1.05 * facing)
	box(parent, "ChairSeat", Vector3.new(2.0, 0.35, 1.9), Vector3.new(x, 1.45, z), color, Enum.Material.SmoothPlastic)
	box(parent, "ChairBack", Vector3.new(2.0, 2.1, 0.3), Vector3.new(x, 2.5, backZ), color, Enum.Material.SmoothPlastic)
	box(parent, "ChairPost", Vector3.new(0.3, 1.05, 0.3), Vector3.new(x, 0.85, z), C.Dark, Enum.Material.Metal)
	box(parent, "ChairBase", Vector3.new(1.8, 0.18, 1.8), Vector3.new(x, 0.26, z), C.Dark, Enum.Material.Metal)
	for _, dx in ipairs({-0.72, 0.72}) do
		for _, dz in ipairs({-0.72, 0.72}) do
			box(parent, "ChairLeg", Vector3.new(0.12, 0.55, 0.12), Vector3.new(x + dx, 0.28, z + dz), C.Dark, Enum.Material.Metal, 0, false)
		end
	end
end

local function addMonitor(parent, x, z, accent)
	box(parent, "MonitorBase", Vector3.new(1.45, 0.16, 0.9), Vector3.new(x, 3.13, z), C.Dark, Enum.Material.Metal, 0, false)
	box(parent, "MonitorStand", Vector3.new(0.2, 0.72, 0.2), Vector3.new(x, 3.53, z), C.Dark, Enum.Material.Metal, 0, false)
	local screen = box(parent, "Monitor", Vector3.new(2.5, 1.55, 0.2), Vector3.new(x, 4.38, z - 0.25), C.Ink, Enum.Material.SmoothPlastic, 0, false, CFrame.Angles(0, math.pi, 0))
	local label = addSurfaceText(screen, Enum.NormalId.Front, "ATENDIMENTO\n● ONLINE", accent or C.Mint, C.Ink, 33, 1)
	label.Font = Enum.Font.GothamMedium
	box(parent, "Keyboard", Vector3.new(2.4, 0.14, 0.8), Vector3.new(x, 3.08, z + 0.72), C.Dark, Enum.Material.SmoothPlastic, 0, false)
	box(parent, "KeyboardLights", Vector3.new(1.7, 0.025, 0.05), Vector3.new(x, 3.16, z + 0.69), accent or C.Teal, Enum.Material.Neon, 0, false)
end

local function addWallText(parent, name, position, size, text, rotation, face, accent)
	local panel = box(parent, name, size, position, C.Navy, Enum.Material.SmoothPlastic, 0, false, rotation)
	return addSurfaceText(panel, face or Enum.NormalId.Front, text, accent or C.Mint, C.Navy, 45, 1)
end

local function addDesk(parent, index, x, z)
	local model = Instance.new("Model")
	model.Name = string.format("Estacao_%02d", index)
	model.Parent = parent

	box(model, "DeskTop", Vector3.new(8.5, 0.35, 3.5), Vector3.new(x, 2.75, z), C.WoodLight, Enum.Material.WoodPlanks)
	for _, dx in ipairs({-3.8, 3.8}) do
		for _, dz in ipairs({-1.35, 1.35}) do
			box(model, "DeskLeg", Vector3.new(0.25, 2.55, 0.25), Vector3.new(x + dx, 1.3, z + dz), C.Dark, Enum.Material.Metal)
		end
	end
	box(model, "DeskApron", Vector3.new(7.8, 0.28, 0.22), Vector3.new(x, 2.42, z + 1.3), C.Wood, Enum.Material.WoodPlanks, 0, false)
	addMonitor(model, x - 0.65, z - 1.05, index % 2 == 0 and C.Mint or C.Gold)

	local phone = box(model, "Telefone", Vector3.new(1.3, 0.38, 0.95), Vector3.new(x + 2.8, 3.08, z + 0.78), C.Ink, Enum.Material.SmoothPlastic, 0, false)
	box(model, "TelefoneDisplay", Vector3.new(0.62, 0.08, 0.24), Vector3.new(x + 2.8, 3.29, z + 0.68), C.Mint, Enum.Material.Neon, 0, false)
	box(model, "TelefoneTeclado", Vector3.new(0.48, 0.06, 0.42), Vector3.new(x + 2.8, 3.29, z + 1.0), C.White, Enum.Material.SmoothPlastic, 0, false)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "AtenderLigacao"
	prompt.ActionText = "Atender ligação"
	prompt.ObjectText = "Estação " .. tostring(index)
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0.35
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.ClickablePrompt = true
	prompt.Parent = phone

	addChair(model, x, z + 4.4, index % 2 == 0 and C.Blue or C.Teal, 1)
	box(model, "PrivacyPanel", Vector3.new(0.22, 2.6, 3.2), Vector3.new(x - 4.25, 4.1, z), C.Glass, Enum.Material.Glass, 0.35, false)
	box(model, "StationNumber", Vector3.new(1.0, 0.12, 0.42), Vector3.new(x - 3.5, 3.1, z - 1.2), index % 2 == 0 and C.Gold or C.Coral, Enum.Material.Neon, 0, false)

	return {
		Index = index,
		Prompt = prompt,
		Phone = phone,
		DeskPosition = phone.Position,
	}
end

local function addReception(parent)
	local model = Instance.new("Model")
	model.Name = "Recepcao"
	model.Parent = parent
	box(model, "ReceptionCounter", Vector3.new(24, 3.1, 4.4), Vector3.new(0, 1.55, 31), C.Wood, Enum.Material.WoodPlanks)
	box(model, "ReceptionCounterTop", Vector3.new(24.6, 0.28, 4.9), Vector3.new(0, 3.18, 31), C.WoodLight, Enum.Material.WoodPlanks)
	box(model, "ReceptionFrontAccent", Vector3.new(18, 0.38, 0.12), Vector3.new(0, 1.5, 28.78), C.Teal, Enum.Material.Neon, 0, false)
	addMonitor(model, -5.5, 30, C.Mint)
	addOfficePlant(model, -13, 0, 30, 1.4)
	addOfficePlant(model, 13, 0, 30, 1.4)

	addWallText(model, "ReceptionLogo", Vector3.new(0, 7.8, 34.3), Vector3.new(14, 3.5, 0.45), "CENTRAL DO CAÔ\nESTÚDIO DE HISTÓRIAS", CFrame.new(), Enum.NormalId.Front, C.Gold)

	-- Sala de espera: sofá, poltronas e mesa baixa.
	box(model, "SofaSeat", Vector3.new(10, 1.2, 2.3), Vector3.new(-16, 1.0, 38), C.Blue, Enum.Material.Fabric)
	box(model, "SofaBack", Vector3.new(10, 2.0, 0.55), Vector3.new(-16, 2.2, 39), C.Navy, Enum.Material.Fabric)
	box(model, "SofaArmL", Vector3.new(0.7, 1.7, 2.3), Vector3.new(-20.6, 1.6, 38), C.Navy, Enum.Material.Fabric)
	box(model, "SofaArmR", Vector3.new(0.7, 1.7, 2.3), Vector3.new(-11.4, 1.6, 38), C.Navy, Enum.Material.Fabric)
	box(model, "LobbyTable", Vector3.new(5.0, 0.45, 2.8), Vector3.new(-16, 0.65, 33.5), C.WoodLight, Enum.Material.WoodPlanks)
	box(model, "LobbyTableLeg", Vector3.new(0.45, 0.7, 0.45), Vector3.new(-16, 0.28, 33.5), C.Dark, Enum.Material.Metal)
	box(model, "LobbyRug", Vector3.new(17, 0.08, 9), Vector3.new(-16, 0.08, 36), C.Carpet, Enum.Material.Fabric, 0, false)
end

local function addBreakRoom(parent)
	local model = Instance.new("Model")
	model.Name = "Copa"
	model.Parent = parent
	box(model, "KitchenCounter", Vector3.new(20, 2.2, 2.8), Vector3.new(43, 1.1, 29), C.WoodLight, Enum.Material.WoodPlanks)
	box(model, "KitchenCounterTop", Vector3.new(20.4, 0.22, 3.0), Vector3.new(43, 2.32, 29), C.White, Enum.Material.SmoothPlastic)
	box(model, "UpperCabinet", Vector3.new(18, 3.2, 1.4), Vector3.new(43, 7.0, 28), C.Teal, Enum.Material.SmoothPlastic)
	for _, x in ipairs({38.5, 43, 47.5}) do
		box(model, "CabinetDoor", Vector3.new(3.6, 2.5, 0.12), Vector3.new(x, 7, 27.25), C.Mint, Enum.Material.SmoothPlastic, 0, false)
	end

	-- Geladeira e bebedouro.
	box(model, "Fridge", Vector3.new(3.6, 7.5, 3.0), Vector3.new(55, 3.75, 36), C.White, Enum.Material.Metal)
	box(model, "FridgeHandle", Vector3.new(0.12, 2.5, 0.12), Vector3.new(53.35, 4.0, 34.35), C.Dark, Enum.Material.Metal, 0, false)
	box(model, "WaterDispenser", Vector3.new(2.4, 4.2, 2.3), Vector3.new(32, 2.1, 34), C.White, Enum.Material.SmoothPlastic)
	box(model, "WaterJug", Vector3.new(1.5, 2.0, 1.5), Vector3.new(32, 5.1, 34), C.Glass, Enum.Material.Glass, 0.28, false)
	box(model, "WaterSpout", Vector3.new(0.65, 0.4, 0.25), Vector3.new(32, 2.6, 32.8), C.Blue, Enum.Material.SmoothPlastic, 0, false)

	-- Cafeteira, canecas e mesas.
	box(model, "CoffeeMachine", Vector3.new(2.7, 3.3, 2.3), Vector3.new(39, 4.0, 29), C.Ink, Enum.Material.Metal)
	box(model, "CoffeeMachineScreen", Vector3.new(0.75, 0.45, 0.12), Vector3.new(39, 4.55, 27.78), C.Mint, Enum.Material.Neon, 0, false)
	box(model, "CoffeeMug", Vector3.new(0.8, 0.9, 0.8), Vector3.new(42.7, 2.9, 29), C.Coral, Enum.Material.SmoothPlastic, 0, false)
	box(model, "SnackMachine", Vector3.new(4.3, 8.0, 2.3), Vector3.new(54, 4, 25), C.Navy, Enum.Material.Metal)
	box(model, "SnackWindow", Vector3.new(2.9, 4.0, 0.12), Vector3.new(54, 5.0, 23.78), C.Glass, Enum.Material.Glass, 0.32, false)
	local snackColors = {C.Gold, C.Coral, C.Mint}
	for row = 0, 2 do
		for col = 0, 2 do
			local snackColor = snackColors[(row + col) % 3 + 1]
			box(model, "SnackColor", Vector3.new(0.55, 0.55, 0.25), Vector3.new(53 + col * 0.82, 6.2 - row * 1.1, 23.65), snackColor, Enum.Material.Neon, 0, false)
		end
	end
	box(model, "LunchTable", Vector3.new(10, 0.42, 5), Vector3.new(42, 2.3, 39), C.WoodLight, Enum.Material.WoodPlanks)
	for _, x in ipairs({38, 42, 46}) do
		addChair(model, x, 42, C.Teal, 1)
		addChair(model, x, 36, C.Blue, -1)
	end
	addWallText(model, "BreakRoomSign", Vector3.new(43, 10.5, 18.5), Vector3.new(11, 2.4, 0.35), "PAUSA & CAFÉ", CFrame.Angles(0, 0, 0), Enum.NormalId.Front, C.Gold)
	addOfficePlant(model, 31, 0, 22, 0.9)
end

local function addCopyAndServerRoom(parent)
	local model = Instance.new("Model")
	model.Name = "ImpressaoE TI"
	model.Parent = parent
	-- Impressora multifuncional.
	box(model, "PrinterBody", Vector3.new(6.0, 3.5, 4.0), Vector3.new(-43, 2.2, 30), C.White, Enum.Material.SmoothPlastic)
	box(model, "PrinterLid", Vector3.new(5.7, 0.3, 3.7), Vector3.new(-43, 4.1, 30), C.WallShade, Enum.Material.Metal)
	box(model, "PrinterScreen", Vector3.new(1.0, 0.8, 0.14), Vector3.new(-40.5, 3.3, 28.0), C.Teal, Enum.Material.Neon, 0, false)
	box(model, "PaperTray", Vector3.new(3.2, 0.28, 1.0), Vector3.new(-43, 1.5, 27.8), C.Wall, Enum.Material.SmoothPlastic, 0, false)
	box(model, "PrinterPaper", Vector3.new(2.7, 0.1, 0.8), Vector3.new(-43, 1.72, 27.8), C.White, Enum.Material.SmoothPlastic, 0, false)
	box(model, "CopyTable", Vector3.new(14, 0.38, 2.5), Vector3.new(-44, 2.4, 38), C.Wood, Enum.Material.WoodPlanks)
	for _, x in ipairs({-49, -44, -39}) do
		box(model, "ArchiveBox", Vector3.new(3.1, 2.4, 2.4), Vector3.new(x, 1.2, 38), C.WoodLight, Enum.Material.WoodPlanks)
	end

	-- Armários de rede: decoração apenas; sem interação ou conexão externa.
	for i = 0, 2 do
		local x = -54 + i * 8
		box(model, "ServerRack", Vector3.new(5.5, 10.5, 3.2), Vector3.new(x, 5.25, 21), C.Dark, Enum.Material.Metal)
		box(model, "RackDoor", Vector3.new(4.8, 9.5, 0.12), Vector3.new(x, 5.2, 19.32), C.Ink, Enum.Material.Metal, 0, false)
		for row = 0, 4 do
			box(model, "ServerVent", Vector3.new(3.3, 0.12, 0.08), Vector3.new(x, 8.8 - row * 1.45, 19.2), C.WallShade, Enum.Material.Metal, 0, false)
			box(model, "ServerStatus", Vector3.new(0.18, 0.18, 0.1), Vector3.new(x + 1.85, 8.8 - row * 1.45, 19.15), row % 2 == 0 and C.Mint or C.Gold, Enum.Material.Neon, 0, false)
		end
	end
	addOfficePlant(model, -31, 0, 40, 0.85)
	addWallText(model, "ITSign", Vector3.new(-43, 10.5, 18.5), Vector3.new(12, 2.4, 0.35), "IMPRESSÃO & TI", CFrame.Angles(0, 0, 0), Enum.NormalId.Front, C.Mint)
end

local function addMeetingRoom(parent)
	local model = Instance.new("Model")
	model.Name = "SalaDeReuniao"
	model.Parent = parent
	-- Divisórias de vidro que delimitam uma sala de reunião sem fechar a vista.
	box(model, "MeetingGlassLeft", Vector3.new(0.35, 10, 27), Vector3.new(-58.4, 5, -30), C.Glass, Enum.Material.Glass, 0.48, false)
	box(model, "MeetingGlassFront", Vector3.new(25, 10, 0.35), Vector3.new(-45, 5, -16.5), C.Glass, Enum.Material.Glass, 0.48, false)
	box(model, "MeetingHeader", Vector3.new(27, 0.65, 0.55), Vector3.new(-45, 10.2, -16.5), C.Teal, Enum.Material.Metal, 0, false)
	box(model, "MeetingTable", Vector3.new(16, 0.45, 6), Vector3.new(-45, 2.6, -30), C.WoodLight, Enum.Material.WoodPlanks)
	for _, x in ipairs({-52, -45, -38}) do
		addChair(model, x, -24.5, C.Blue, 1)
		addChair(model, x, -35.5, C.Teal, -1)
	end
	local whiteboard = box(model, "Whiteboard", Vector3.new(13, 5, 0.28), Vector3.new(-45, 7, -46.2), C.White, Enum.Material.SmoothPlastic, 0, false, CFrame.Angles(0, math.pi, 0))
	addSurfaceText(whiteboard, Enum.NormalId.Front, "IDEIAS\n→", C.Blue, C.White, 55, 1)
	box(model, "MeetingPlantTable", Vector3.new(3, 0.6, 3), Vector3.new(-56, 1.5, -18), C.Wood, Enum.Material.WoodPlanks)
	addOfficePlant(model, -56, 1.8, -18, 0.9)
	addWallText(model, "MeetingSign", Vector3.new(-45, 11.3, -16.2), Vector3.new(12, 2.1, 0.35), "SALA DE REUNIÃO", CFrame.Angles(0, math.pi, 0), Enum.NormalId.Front, C.Gold)
end

local function addManagerRoom(parent)
	local model = Instance.new("Model")
	model.Name = "SalaDaGerencia"
	model.Parent = parent
	box(model, "ManagerGlassRight", Vector3.new(0.35, 10, 27), Vector3.new(58.4, 5, -30), C.Glass, Enum.Material.Glass, 0.48, false)
	box(model, "ManagerGlassFront", Vector3.new(25, 10, 0.35), Vector3.new(45, 5, -16.5), C.Glass, Enum.Material.Glass, 0.48, false)
	box(model, "ManagerHeader", Vector3.new(27, 0.65, 0.55), Vector3.new(45, 10.2, -16.5), C.Gold, Enum.Material.Metal, 0, false)
	box(model, "ManagerDesk", Vector3.new(10, 0.5, 4), Vector3.new(45, 2.7, -31), C.Wood, Enum.Material.WoodPlanks)
	addChair(model, 45, -25.5, C.Navy, 1)
	for _, x in ipairs({38, 45, 52}) do
		box(model, "FilingCabinet", Vector3.new(3.1, 5.4, 2.3), Vector3.new(x, 2.7, -43), C.WallShade, Enum.Material.Metal)
		for row = 0, 2 do
			box(model, "Drawer", Vector3.new(2.7, 1.3, 0.08), Vector3.new(x, 4.45 - row * 1.6, -41.8), C.White, Enum.Material.Metal, 0, false)
			box(model, "DrawerHandle", Vector3.new(0.75, 0.1, 0.09), Vector3.new(x, 4.45 - row * 1.6, -41.7), C.Dark, Enum.Material.Metal, 0, false)
		end
	end
	addOfficePlant(model, 55, 0, -20, 1.0)
	addWallText(model, "ManagerSign", Vector3.new(45, 11.3, -16.2), Vector3.new(12, 2.1, 0.35), "GERÊNCIA", CFrame.Angles(0, math.pi, 0), Enum.NormalId.Front, C.Gold)
end

local function addRestroom(parent)
	local model = Instance.new("Model")
	model.Name = "Banheiro"
	model.Parent = parent
	-- Cabine acessível simples, lavatório e espelho.
	box(model, "RestroomSideLeft", Vector3.new(0.4, 9, 15), Vector3.new(-12.6, 4.5, -40.5), C.WallShade, Enum.Material.SmoothPlastic)
	box(model, "RestroomSideRight", Vector3.new(0.4, 9, 15), Vector3.new(12.6, 4.5, -40.5), C.WallShade, Enum.Material.SmoothPlastic)
	box(model, "RestroomBack", Vector3.new(25, 9, 0.4), Vector3.new(0, 4.5, -48), C.WallShade, Enum.Material.SmoothPlastic)
	box(model, "RestroomFrontLeft", Vector3.new(7, 9, 0.4), Vector3.new(-9, 4.5, -33), C.WallShade, Enum.Material.SmoothPlastic)
	box(model, "RestroomFrontRight", Vector3.new(7, 9, 0.4), Vector3.new(9, 4.5, -33), C.WallShade, Enum.Material.SmoothPlastic)
	box(model, "RestroomStallWall", Vector3.new(0.3, 7, 6), Vector3.new(2, 3.5, -42), C.Wall, Enum.Material.SmoothPlastic)
	box(model, "RestroomStallDoor", Vector3.new(0.3, 6, 0.25), Vector3.new(2, 3, -37.8), C.Teal, Enum.Material.SmoothPlastic)
	box(model, "RestroomToiletBase", Vector3.new(1.7, 1.15, 2.1), Vector3.new(5.3, 0.65, -43), C.White, Enum.Material.SmoothPlastic)
	box(model, "RestroomToiletTank", Vector3.new(1.8, 2.4, 0.65), Vector3.new(5.3, 1.9, -44), C.White, Enum.Material.SmoothPlastic)
	box(model, "RestroomSinkCounter", Vector3.new(8, 1.2, 2), Vector3.new(-6.5, 2.3, -44), C.White, Enum.Material.SmoothPlastic)
	box(model, "RestroomSinkBowl", Vector3.new(2.4, 0.24, 1.2), Vector3.new(-7, 2.98, -44), C.Glass, Enum.Material.Glass, 0.18, false)
	box(model, "RestroomMirror", Vector3.new(7, 3.6, 0.16), Vector3.new(-6.5, 6, -47.65), C.Glass, Enum.Material.Glass, 0.3, false)
	addWallText(model, "RestroomSign", Vector3.new(0, 10.5, -32.65), Vector3.new(10, 2.0, 0.35), "BANHEIRO", CFrame.Angles(0, math.pi, 0), Enum.NormalId.Front, C.Mint)
end

local function addOutdoorDecor(parent)
	box(parent, "Ground", Vector3.new(260, 1, 260), Vector3.new(0, -1.2, 0), Color3.fromRGB(108, 137, 111), Enum.Material.Grass)
	box(parent, "FrontWalk", Vector3.new(100, 0.4, 25), Vector3.new(0, -0.2, 60), Color3.fromRGB(184, 192, 187), Enum.Material.Concrete)
	box(parent, "ParkingLot", Vector3.new(120, 0.45, 36), Vector3.new(0, -0.25, 86), Color3.fromRGB(68, 78, 82), Enum.Material.Asphalt)
	for x = -50, 50, 10 do
		box(parent, "ParkingLine", Vector3.new(0.22, 0.05, 13), Vector3.new(x, 0.02, 82), C.Gold, Enum.Material.Neon, 0.12, false)
	end
	box(parent, "Road", Vector3.new(180, 0.5, 20), Vector3.new(0, -0.25, 116), Color3.fromRGB(52, 62, 68), Enum.Material.Asphalt)
	box(parent, "RoadCenterLine", Vector3.new(160, 0.06, 0.32), Vector3.new(0, 0.03, 116), C.Gold, Enum.Material.Neon, 0.2, false)
	for _, pair in ipairs({{-82, -68}, {68, 82}}) do
		for _, x in ipairs(pair) do
			box(parent, "RoadSideLine", Vector3.new(0.25, 0.06, 20), Vector3.new(x, 0.03, 116), C.White, Enum.Material.Neon, 0.25, false)
		end
	end
	for _, position in ipairs({Vector3.new(-78, -0.65, 51), Vector3.new(78, -0.65, 51), Vector3.new(-75, -0.65, 100), Vector3.new(75, -0.65, 100)}) do
		box(parent, "TreeTrunk", Vector3.new(1.4, 7, 1.4), position + Vector3.new(0, 3.5, 0), C.Wood, Enum.Material.Wood)
		box(parent, "TreeCanopy", Vector3.new(8, 8, 8), position + Vector3.new(0, 9, 0), C.Green, Enum.Material.Grass, 0, false, nil, Enum.PartType.Ball)
	end
	for _, x in ipairs({-40, -25, 25, 40}) do
		box(parent, "WalkwayLightPole", Vector3.new(0.55, 9, 0.55), Vector3.new(x, 4.5, 57), C.Dark, Enum.Material.Metal)
		local lamp = box(parent, "WalkwayLamp", Vector3.new(2.2, 0.45, 1.1), Vector3.new(x, 9.1, 57), C.Gold, Enum.Material.Neon, 0, false)
		addPointLight(lamp, C.Gold, 0.7, 12)
	end
end

local function addMainBuilding(parent)
	box(parent, "OfficeFloor", Vector3.new(120, 1, 100), Vector3.new(0, -0.5, 0), C.Floor, Enum.Material.Concrete)
	box(parent, "OfficeCeiling", Vector3.new(120, 1, 100), Vector3.new(0, 20.5, 0), C.Wall, Enum.Material.SmoothPlastic)
	box(parent, "BackWallLeft", Vector3.new(10, 20, 2), Vector3.new(-55, 10, -50), C.Wall, Enum.Material.Concrete)
	box(parent, "BackWallLeftInner", Vector3.new(8, 20, 2), Vector3.new(-24, 10, -50), C.Wall, Enum.Material.Concrete)
	box(parent, "BackWallCenterLeft", Vector3.new(1, 20, 2), Vector3.new(-19.5, 10, -50), C.Wall, Enum.Material.Concrete)
	box(parent, "BackWallCenterRight", Vector3.new(1, 20, 2), Vector3.new(19.5, 10, -50), C.Wall, Enum.Material.Concrete)
	box(parent, "BackWallRightInner", Vector3.new(8, 20, 2), Vector3.new(24, 10, -50), C.Wall, Enum.Material.Concrete)
	box(parent, "BackWallRight", Vector3.new(10, 20, 2), Vector3.new(55, 10, -50), C.Wall, Enum.Material.Concrete)
	addDecorativeWindow(parent, "Back", Vector3.new(-39, 10, -49.2), 22, 9)
	addDecorativeWindow(parent, "Back", Vector3.new(0, 10, -49.2), 38, 9)
	addDecorativeWindow(parent, "Back", Vector3.new(39, 10, -49.2), 22, 9)

	-- Paredes laterais segmentadas para permitir janelas panorâmicas.
	for _, side in ipairs({-1, 1}) do
		local x = side * 59
		for _, segment in ipairs({{-44, 12}, {-16, 12}, {10.5, 9}, {40.5, 19}}) do
			box(parent, "SideWall", Vector3.new(2, 20, segment[2]), Vector3.new(x, 10, segment[1]), C.Wall, Enum.Material.Concrete)
		end
		for _, z in ipairs({-30, -2, 23}) do
			addDecorativeWindow(parent, "Side", Vector3.new(x, 10, z), 16, 9)
		end
	end

	-- Frente com entrada aberta, portas de vidro e janelas laterais.
	box(parent, "FrontWallLeftSolid", Vector3.new(20, 20, 2), Vector3.new(-50, 10, 50), C.Wall, Enum.Material.Concrete)
	box(parent, "FrontWallRightSolid", Vector3.new(20, 20, 2), Vector3.new(50, 10, 50), C.Wall, Enum.Material.Concrete)
	box(parent, "FrontWindowPillarLeft", Vector3.new(1, 20, 2), Vector3.new(-12.5, 10, 50), C.Wall, Enum.Material.Concrete)
	box(parent, "FrontWindowPillarRight", Vector3.new(1, 20, 2), Vector3.new(12.5, 10, 50), C.Wall, Enum.Material.Concrete)
	addDecorativeWindow(parent, "Front", Vector3.new(-26, 10, 49.2), 26, 9)
	addDecorativeWindow(parent, "Front", Vector3.new(26, 10, 49.2), 26, 9)
	box(parent, "EntranceLintel", Vector3.new(24, 4, 2), Vector3.new(0, 18, 50), C.Wall, Enum.Material.Concrete)
	box(parent, "EntranceDoorLeft", Vector3.new(4.5, 13, 0.35), Vector3.new(-4.5, 6.5, 49.0), C.Glass, Enum.Material.Glass, 0.48, false)
	box(parent, "EntranceDoorRight", Vector3.new(4.5, 13, 0.35), Vector3.new(4.5, 6.5, 49.0), C.Glass, Enum.Material.Glass, 0.48, false)
	box(parent, "EntranceHandleLeft", Vector3.new(0.12, 2.2, 0.12), Vector3.new(-0.9, 6.5, 48.78), C.Dark, Enum.Material.Metal, 0, false)
	box(parent, "EntranceHandleRight", Vector3.new(0.12, 2.2, 0.12), Vector3.new(0.9, 6.5, 48.78), C.Dark, Enum.Material.Metal, 0, false)

	local facadeSign = box(parent, "FacadeSign", Vector3.new(26, 3.5, 0.65), Vector3.new(0, 17.1, 51.25), C.Navy, Enum.Material.SmoothPlastic, 0, false, CFrame.Angles(0, math.pi, 0))
	addSurfaceText(facadeSign, Enum.NormalId.Front, "CENTRAL DO CAÔ", C.Gold, C.Navy, 57, 1)

	-- Carpet paths and meeting-zone rugs.
	box(parent, "MainCarpet", Vector3.new(78, 0.12, 45), Vector3.new(0, 0.08, -2), C.Carpet, Enum.Material.Fabric, 0, false)
	box(parent, "LobbyCarpet", Vector3.new(43, 0.12, 20), Vector3.new(0, 0.08, 35), Color3.fromRGB(106, 134, 137), Enum.Material.Fabric, 0, false)
	box(parent, "MeetingCarpet", Vector3.new(27, 0.12, 28), Vector3.new(-45, 0.09, -31), C.Carpet, Enum.Material.Fabric, 0, false)
	box(parent, "ManagerCarpet", Vector3.new(27, 0.12, 28), Vector3.new(45, 0.09, -31), Color3.fromRGB(111, 100, 83), Enum.Material.Fabric, 0, false)
	box(parent, "KitchenTile", Vector3.new(29, 0.12, 27), Vector3.new(43, 0.1, 30), Color3.fromRGB(167, 192, 186), Enum.Material.CeramicTiles, 0, false)
	box(parent, "ITFloor", Vector3.new(29, 0.12, 27), Vector3.new(-43, 0.1, 30), Color3.fromRGB(153, 170, 181), Enum.Material.CeramicTiles, 0, false)

	-- Divisórias baixas e envidraçadas dos setores.
	box(parent, "KitchenDivider", Vector3.new(0.55, 10, 27), Vector3.new(28.2, 5, 30), C.Glass, Enum.Material.Glass, 0.55, false)
	box(parent, "ITDivider", Vector3.new(0.55, 10, 27), Vector3.new(-28.2, 5, 30), C.Glass, Enum.Material.Glass, 0.55, false)
	box(parent, "MeetingSideWall", Vector3.new(0.55, 10, 27), Vector3.new(-31.2, 5, -30), C.Glass, Enum.Material.Glass, 0.55, false)
	box(parent, "ManagerSideWall", Vector3.new(0.55, 10, 27), Vector3.new(31.2, 5, -30), C.Glass, Enum.Material.Glass, 0.55, false)

	-- Hall central e pilares decorativos.
	for _, x in ipairs({-36, 36}) do
		box(parent, "LobbyPillar", Vector3.new(1.4, 19, 1.4), Vector3.new(x, 9.5, 34), C.WallShade, Enum.Material.Concrete)
		box(parent, "PillarAccent", Vector3.new(1.5, 4, 1.5), Vector3.new(x, 3, 34), C.Teal, Enum.Material.SmoothPlastic)
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "OfficeSpawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(0, 0.6, 43)
	spawn.Transparency = 1
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.AllowTeamChangeOnTouch = false
	spawn.Parent = parent

	-- Plafoniers com luzes quentes espalhadas pelo escritório.
	for _, x in ipairs({-40, 0, 40}) do
		for _, z in ipairs({-36, -8, 20, 39}) do
			local lamp = box(parent, "CeilingLight", Vector3.new(5.5, 0.28, 2.5), Vector3.new(x, 19.85, z), C.White, Enum.Material.Neon, 0.05, false)
			addPointLight(lamp, Color3.fromRGB(255, 242, 220), 0.65, 22)
		end
	end
end

local function addRankingBoard(parent)
	local board = box(parent, "RankingBoard", Vector3.new(15, 9.5, 0.65), Vector3.new(0, 8.2, 25.5), C.Navy, Enum.Material.SmoothPlastic, 0, false, CFrame.Angles(0, math.pi, 0))
	local gui = Instance.new("SurfaceGui")
	gui.Name = "RankingSurface"
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(900, 570)
	gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	gui.LightInfluence = 0
	gui.AlwaysOnTop = false
	gui.Parent = board

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -40, 0, 90)
	title.Position = UDim2.new(0, 20, 0, 12)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.Text = "RANKING DE AGENTES"
	title.TextColor3 = C.Gold
	title.TextSize = 48
	title.TextWrapped = true
	title.Parent = gui

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(1, -40, 0, 40)
	subtitle.Position = UDim2.new(0, 20, 0, 96)
	subtitle.BackgroundTransparency = 1
	subtitle.Font = Enum.Font.GothamMedium
	subtitle.Text = "CRÉDITOS FICTÍCIOS GANHOS"
	subtitle.TextColor3 = C.Mint
	subtitle.TextSize = 24
	subtitle.Parent = gui

	local rows = Instance.new("TextLabel")
	rows.Name = "Rows"
	rows.Size = UDim2.new(1, -55, 1, -155)
	rows.Position = UDim2.new(0, 28, 0, 148)
	rows.BackgroundTransparency = 1
	rows.Font = Enum.Font.GothamMedium
	rows.Text = "Carregando ranking..."
	rows.TextColor3 = C.White
	rows.TextSize = 30
	rows.TextXAlignment = Enum.TextXAlignment.Left
	rows.TextYAlignment = Enum.TextYAlignment.Top
	rows.TextWrapped = true
	rows.Parent = gui
	return rows
end

function WorldBuilder.Build()
	local old = Workspace:FindFirstChild("GeneratedOffice")
	if old then
		old:Destroy()
	end

	Lighting.Brightness = 2.1
	Lighting.ClockTime = 13.5
	Lighting.Ambient = Color3.fromRGB(146, 158, 169)
	Lighting.OutdoorAmbient = Color3.fromRGB(166, 181, 184)
	Lighting.EnvironmentDiffuseScale = 0.4
	Lighting.EnvironmentSpecularScale = 0.35
	Lighting.ExposureCompensation = 0.05

	local atmosphere = Lighting:FindFirstChild("OfficeAtmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "OfficeAtmosphere"
		atmosphere.Parent = Lighting
	end
	atmosphere.Color = Color3.fromRGB(205, 225, 230)
	atmosphere.Decay = Color3.fromRGB(110, 142, 157)
	atmosphere.Density = 0.18
	atmosphere.Glare = 0.06
	atmosphere.Haze = 0.4

	local map = Instance.new("Folder")
	map.Name = "GeneratedOffice"
	map.Parent = Workspace

	addOutdoorDecor(map)
	addMainBuilding(map)
	addReception(map)
	addBreakRoom(map)
	addCopyAndServerRoom(map)
	addMeetingRoom(map)
	addManagerRoom(map)
	addRestroom(map)

	local stationsFolder = Instance.new("Folder")
	stationsFolder.Name = "CallStations"
	stationsFolder.Parent = map
	local stations = {}
	local deskXs = {-28, -17, -6, 6, 17, 28}
	for index, x in ipairs(deskXs) do
		table.insert(stations, addDesk(stationsFolder, index, x, -7.5))
	end

	local rankingRows = addRankingBoard(map)
	return {
		Folder = map,
		Stations = stations,
		RankingRows = rankingRows,
	}
end

return WorldBuilder
