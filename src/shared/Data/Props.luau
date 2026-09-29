--[[
	Props.luau
	Biblioteca de móveis/objetos declarativos + temas de decoração por tipo de sala.

	Cada peça da biblioteca é uma lista de partes primitivas (`parts`) descritas com:
		size      = { x, y, z } em studs
		offset    = { x, y, z } relativo ao centro do prop (Y = altura do chão)
		color     = nome da cor em Config.Palette (ou {r,g,b})
		material  = material "amigável" (ver src/server/Builders/PartKit.luau)
		shape     = "Block" | "Ball" | "Cylinder" | "Wedge" | "Corner"
		rotation  = { x, y, z } em graus (opcional)
		emissive  = true cria Neon + PointLight
		transparency = 0..1

	Campos extras do prop:
		parts, lights, particles, sounds, anchorClick (permite interagir),
		blocksMovement (cria colisão de navegação para a grade),
		interact = { kind = "clue" | "trap" | "npc" | "shop" ... }
]]

local Props = {}

Props.Library = {
	--------------------------------------------------------------- LOBBY
	mystery_machine = {
		label = "Mystery Machine",
		blocksMovement = true,
		parts = {
			{ size = { 7, 3, 15 }, offset = { 0, 3, 0 }, color = "MysteryTeal", material = "Metal" },
			{ size = { 6.6, 3.6, 5 }, offset = { 0, 5.4, 1 }, color = "MysteryTeal", material = "Metal" },
			{ size = { 6.6, 1.2, 5 }, offset = { 0, 7.6, 1 }, color = "MysteryBlue", material = "Metal" },
			{
				size = { 6.4, 3.2, 4 },
				offset = { 0, 7.2, 3.4 },
				color = "MysteryTeal",
				material = "Glass",
				transparency = 0.35,
			},
			{ size = { 6.8, 0.4, 15.4 }, offset = { 0, 4.6, 0 }, color = "MysteryOrange", material = "Metal" },
			{ size = { 0.4, 2, 3 }, offset = { -3.6, 6.6, -6 }, color = "Accent", material = "Neon" },
			{ size = { 0.4, 2, 3 }, offset = { 3.6, 6.6, -6 }, color = "Accent", material = "Neon" },
			{ size = { 1.6, 1.6, 0.4 }, offset = { -2.4, 6.6, -7.6 }, color = "Warning", material = "Neon" },
			{ size = { 1.6, 1.6, 0.4 }, offset = { 2.4, 6.6, -7.6 }, color = "Warning", material = "Neon" },
			{
				size = { 1.6, 3.2, 1.6 },
				offset = { -3.8, 1.6, -5 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 1.6, 3.2, 1.6 },
				offset = { 3.8, 1.6, -5 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 1.6, 3.2, 1.6 },
				offset = { -3.8, 1.6, 5 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 1.6, 3.2, 1.6 },
				offset = { 3.8, 1.6, 5 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{ size = { 6.8, 0.3, 15 }, offset = { 0, 8.9, 0.4 }, color = "MysteryTeal", material = "Fabric" },
		},
		lights = {
			{ offset = { 0, 8, -7 }, color = "Warning", brightness = 2.4, range = 40 },
		},
		decals = { { key = "MysteryMachineFlower", offset = { 0, 6, 4.5 }, size = { 4, 4 } } },
	},

	case_board = {
		label = "Quadro de Casos",
		parts = {
			{ size = { 9, 5, 0.5 }, offset = { 0, 3.5, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 8.4, 4.4, 0.2 }, offset = { 0, 3.5, -0.35 }, color = "PanelLight", material = "Fabric" },
			{
				size = { 2.6, 1.8, 0.1 },
				offset = { -2.6, 4.2, -0.5 },
				color = "Text",
				material = "Plastic",
				rotation = { 0, 0, -4 },
			},
			{
				size = { 2.6, 1.8, 0.1 },
				offset = { 2.4, 3.4, -0.5 },
				color = "Gold",
				material = "Plastic",
				rotation = { 0, 0, 6 },
			},
			{
				size = { 4, 0.2, 0.1 },
				offset = { 0, 2.4, -0.5 },
				color = "Danger",
				material = "Plastic",
				rotation = { 0, 0, 3 },
			},
			{ size = { 3, 0.2, 0.1 }, offset = { 1, 1.9, -0.5 }, color = "MysteryBlue", material = "Plastic" },
		},
		interact = { kind = "case_board" },
	},

	role_mirror = {
		label = "Espelho dos Papéis",
		parts = {
			{ size = { 6, 7, 0.6 }, offset = { 0, 4, 0 }, color = "Gold", material = "Metal" },
			{
				size = { 5.2, 6.2, 0.2 },
				offset = { 0, 4, -0.4 },
				color = "Accent",
				material = "Glass",
				transparency = 0.45,
			},
			{ size = { 6.6, 0.6, 1.4 }, offset = { 0, 0.4, 0 }, color = "Scooby", material = "WoodPlanks" },
		},
		light = { offset = { 0, 7.6, 0 }, color = "Accent", brightness = 2.2, range = 18 },
		interact = { kind = "roles" },
	},

	shop_counter = {
		label = "Balcão da Loja",
		parts = {
			{ size = { 8, 3, 2 }, offset = { 0, 3, 0 }, color = "MysteryGreen", material = "WoodPlanks" },
			{ size = { 8.4, 0.3, 2.4 }, offset = { 0, 4.6, 0 }, color = "Gold", material = "Marble" },
			{ size = { 2, 1.4, 1.6 }, offset = { -2.4, 5.4, 0 }, color = "Warning", material = "Plastic" },
			{ size = { 1.6, 1.6, 1.4 }, offset = { 1.6, 5.5, 0 }, color = "Danger", material = "Plastic" },
			{ size = { 8.6, 0.4, 0.4 }, offset = { 0, 5.4, -1.4 }, color = "Accent", material = "Neon" },
		},
		interact = { kind = "shop" },
	},

	snack_machine = {
		label = "Máquina de Scooby Snacks",
		parts = {
			{ size = { 3, 6, 2 }, offset = { 0, 3, 0 }, color = "Danger", material = "Metal" },
			{
				size = { 2.4, 3.4, 0.2 },
				offset = { 0, 4, -1.1 },
				color = "Accent",
				material = "Glass",
				transparency = 0.4,
			},
			{ size = { 1.6, 0.6, 0.2 }, offset = { 0, 2, -1.2 }, color = "Night", material = "Metal" },
			{ size = { 2.6, 0.6, 0.3 }, offset = { 0, 6.6, 0 }, color = "Gold", material = "Neon" },
		},
		interact = { kind = "shop" },
	},

	portal_door = {
		label = "Portal do Caso",
		parts = {
			{ size = { 6, 8, 0.6 }, offset = { 0, 4, 0 }, color = "DeepPurple", material = "Metal" },
			{
				size = { 4.6, 6.6, 0.2 },
				offset = { 0, 4, -0.5 },
				color = "Purple",
				material = "Neon",
				transparency = 0.25,
			},
			{ size = { 7, 0.6, 1.4 }, offset = { 0, 8.4, 0 }, color = "Gold", material = "Metal" },
		},
		light = { offset = { 0, 4, -1.6 }, color = "Purple", brightness = 2.6, range = 22 },
		interact = { kind = "portal" },
	},

	sofa = {
		label = "Sofá",
		parts = {
			{ size = { 6, 1.2, 3 }, offset = { 0, 1.4, 0 }, color = "MysteryBlue", material = "Fabric" },
			{ size = { 6, 2, 0.8 }, offset = { 0, 2.4, 1.4 }, color = "MysteryBlue", material = "Fabric" },
			{ size = { 0.8, 2, 3 }, offset = { -2.8, 2.4, 0 }, color = "MysteryBlue", material = "Fabric" },
			{ size = { 0.8, 2, 3 }, offset = { 2.8, 2.4, 0 }, color = "MysteryBlue", material = "Fabric" },
		},
	},

	plant = {
		label = "Planta",
		parts = {
			{ size = { 2, 2, 2 }, offset = { 0, 1, 0 }, color = "MysteryOrange", material = "Plastic" },
			{ size = { 3, 3, 3 }, offset = { 0, 3.4, 0 }, color = "MysteryGreen", material = "Grass" },
			{ size = { 1.4, 2.6, 1.4 }, offset = { 1.2, 4.4, -0.6 }, color = "MysteryGreen", material = "Grass" },
		},
	},

	desk = {
		label = "Escrivaninha",
		parts = {
			{ size = { 6, 0.4, 3 }, offset = { 0, 3, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 0.4, 3, 3 }, offset = { -2.8, 1.5, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 0.4, 3, 3 }, offset = { 2.8, 1.5, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 2, 1.2, 0.3 }, offset = { 0, 4, -0.8 }, color = "Night", material = "Plastic" },
			{ size = { 1.4, 0.4, 1 }, offset = { -1.6, 3.4, 0.4 }, color = "Text", material = "Plastic" },
		},
	},

	bookshelf = {
		label = "Estante",
		parts = {
			{ size = { 6, 7, 1.6 }, offset = { 0, 3.5, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 5.6, 0.3, 1.4 }, offset = { 0, 2.4, -0.2 }, color = "ShaggyHair", material = "WoodPlanks" },
			{ size = { 5.6, 0.3, 1.4 }, offset = { 0, 4.4, -0.2 }, color = "ShaggyHair", material = "WoodPlanks" },
			{ size = { 5.6, 0.3, 1.4 }, offset = { 0, 6.4, -0.2 }, color = "ShaggyHair", material = "WoodPlanks" },
			{ size = { 1, 1.8, 1 }, offset = { -1.8, 5.5, -0.4 }, color = "Danger", material = "Fabric" },
			{ size = { 1, 1.8, 1 }, offset = { -0.6, 5.5, -0.4 }, color = "MysteryBlue", material = "Fabric" },
			{ size = { 1, 1.8, 1 }, offset = { 0.6, 5.5, -0.4 }, color = "Gold", material = "Fabric" },
			{ size = { 1, 1.8, 1 }, offset = { 1.8, 5.5, -0.4 }, color = "MysteryGreen", material = "Fabric" },
		},
	},

	training_dummy = {
		label = "Boneco de Treino",
		parts = {
			{ size = { 1.6, 5, 1.6 }, offset = { 0, 2.5, 0 }, color = "ShaggyHair", material = "Fabric" },
			{ size = { 2.6, 2, 1.4 }, offset = { 0, 5, 0 }, color = "ShaggyHair", material = "Fabric" },
			{ size = { 1.4, 1.4, 1.4 }, offset = { 0, 6.6, 0 }, color = "Text", material = "Fabric" },
			{ size = { 3, 0.4, 0.4 }, offset = { 0, 5.4, 0 }, color = "Scooby", material = "WoodPlanks" },
		},
	},

	crate_stack = {
		label = "Caixotes",
		blocksMovement = true,
		parts = {
			{ size = { 3, 3, 3 }, offset = { 0, 1.5, 0 }, color = "Scooby", material = "WoodPlanks" },
			{
				size = { 3, 3, 3 },
				offset = { 0, 4.5, 0 },
				color = "ShaggyHair",
				material = "WoodPlanks",
				rotation = { 0, 12, 0 },
			},
			{ size = { 2.6, 2.6, 2.6 }, offset = { 3.4, 1.3, 0.6 }, color = "Scooby", material = "WoodPlanks" },
		},
	},

	tire_stack = {
		label = "Pilha de Pneus",
		parts = {
			{ size = { 4, 1, 4 }, offset = { 0, 0.5, 0 }, color = "Night", material = "Rubber", shape = "Cylinder" },
			{ size = { 4, 1, 4 }, offset = { 0, 1.5, 0 }, color = "Night", material = "Rubber", shape = "Cylinder" },
			{ size = { 4, 1, 4 }, offset = { 0, 2.5, 0 }, color = "Night", material = "Rubber", shape = "Cylinder" },
		},
	},

	bench = {
		label = "Banco",
		parts = {
			{ size = { 6, 0.5, 2 }, offset = { 0, 1.6, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 6, 1.6, 0.4 }, offset = { 0, 2.8, 0.9 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 0.4, 1.6, 2 }, offset = { -2.6, 0.8, 0 }, color = "Metal", material = "Metal" },
			{ size = { 0.4, 1.6, 2 }, offset = { 2.6, 0.8, 0 }, color = "Metal", material = "Metal" },
		},
	},

	fountain = {
		label = "Fonte",
		blocksMovement = true,
		parts = {
			{ size = { 10, 1.4, 10 }, offset = { 0, 0.7, 0 }, color = "Marble", material = "Marble" },
			{
				size = { 8, 0.6, 8 },
				offset = { 0, 1.6, 0 },
				color = "MysteryTeal",
				material = "Glass",
				transparency = 0.4,
			},
			{ size = { 2, 4, 2 }, offset = { 0, 3.6, 0 }, color = "Marble", material = "Marble" },
			{ size = { 3, 0.6, 3 }, offset = { 0, 5.6, 0 }, color = "Marble", material = "Marble" },
		},
		particles = { { offset = { 0, 6, 0 }, color = "MysteryTeal", size = 0.8, rate = 18 } },
		light = { offset = { 0, 4, 0 }, color = "MysteryTeal", brightness = 1.6, range = 16 },
	},

	street_lamp = {
		label = "Poste de Luz",
		parts = {
			{ size = { 0.6, 9, 0.6 }, offset = { 0, 4.5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 2, 0.6, 1.2 }, offset = { 0.8, 9, 0 }, color = "Metal", material = "Metal" },
			{ size = { 1.2, 1.2, 1.2 }, offset = { 1.6, 8.4, 0 }, color = "Warning", material = "Neon" },
		},
		light = { offset = { 1.6, 8, 0 }, color = "Warning", brightness = 2.6, range = 26 },
	},

	--------------------------------------------------------------- HOTEL / CASA
	grand_piano = {
		label = "Piano de Cauda",
		blocksMovement = true,
		parts = {
			{ size = { 6, 3, 8 }, offset = { 0, 3, 0 }, color = "Night", material = "Wood" },
			{ size = { 6.4, 0.4, 8.4 }, offset = { 0, 4.6, 0 }, color = "DeepPurple", material = "Wood" },
			{ size = { 5.6, 0.5, 1.6 }, offset = { 0, 4.9, 3.4 }, color = "Text", material = "Plastic" },
			{ size = { 5, 1, 1.6 }, offset = { 0, 4.4, 4.6 }, color = "Night", material = "Wood" },
			{ size = { 1.2, 1.2, 1.2 }, offset = { -2, 3.6, -1 }, color = "Gold", material = "Metal" },
		},
		decals = { { key = "CandyAd", offset = { 0, 5.2, -4.3 }, size = { 3, 3 } } },
	},

	piano_prop = {
		label = "Piano de Palco",
		blocksMovement = true,
		parts = {
			{ size = { 5, 2.6, 7 }, offset = { 0, 2.6, 0 }, color = "Night", material = "Wood" },
			{ size = { 5.4, 0.4, 7.4 }, offset = { 0, 4, 0 }, color = "DeepPurple", material = "Wood" },
			{ size = { 4.6, 0.5, 1.4 }, offset = { 0, 4.3, 3 }, color = "Text", material = "Plastic" },
		},
	},

	chandelier = {
		label = "Lustre",
		parts = {
			{ size = { 0.4, 4, 0.4 }, offset = { 0, 2, 0 }, color = "Gold", material = "Metal" },
			{ size = { 5, 0.6, 5 }, offset = { 0, 0, 0 }, color = "Gold", material = "Metal", shape = "Cylinder" },
			{
				size = { 3.4, 0.5, 3.4 },
				offset = { 0, -0.8, 0 },
				color = "Gold",
				material = "Metal",
				shape = "Cylinder",
			},
			{ size = { 0.8, 1.6, 0.8 }, offset = { -2, -1.4, 0 }, color = "Warning", material = "Neon" },
			{ size = { 0.8, 1.6, 0.8 }, offset = { 2, -1.4, 0 }, color = "Warning", material = "Neon" },
			{ size = { 0.8, 1.6, 0.8 }, offset = { 0, -1.4, -2 }, color = "Warning", material = "Neon" },
			{ size = { 0.8, 1.6, 0.8 }, offset = { 0, -1.4, 2 }, color = "Warning", material = "Neon" },
		},
		light = { offset = { 0, -1.6, 0 }, color = "Warning", brightness = 3, range = 30 },
	},

	reception_counter = {
		label = "Balcão da Recepção",
		blocksMovement = true,
		parts = {
			{ size = { 10, 3.4, 2.4 }, offset = { 0, 1.7, 0 }, color = "Scooby", material = "Marble" },
			{ size = { 10.4, 0.3, 2.8 }, offset = { 0, 3.6, 0 }, color = "Gold", material = "Marble" },
			{ size = { 2, 1.8, 1 }, offset = { -3, 4.5, 0 }, color = "Text", material = "Plastic" },
			{ size = { 1.6, 1.2, 1.2 }, offset = { 3, 4.3, 0 }, color = "Warning", material = "Neon" },
		},
		light = { offset = { 0, 6, 0 }, color = "Warning", brightness = 2, range = 16 },
	},

	service_elevator = {
		label = "Elevador de Serviço",
		blocksMovement = true,
		parts = {
			{ size = { 6, 12, 6 }, offset = { 0, 6, 0 }, color = "Metal", material = "Metal" },
			{ size = { 4.6, 9, 0.4 }, offset = { 0, 5.4, -3.1 }, color = "PanelLight", material = "DiamondPlate" },
			{ size = { 0.4, 9, 0.3 }, offset = { 0, 5.4, -3.3 }, color = "Accent", material = "Neon" },
			{ size = { 3, 0.6, 1 }, offset = { 0, 11.6, -3.4 }, color = "Danger", material = "Neon" },
		},
		light = { offset = { 0, 8, -4 }, color = "Accent", brightness = 2, range = 14 },
	},

	kitchen_counter = {
		label = "Bancada da Cozinha",
		parts = {
			{ size = { 10, 3, 3 }, offset = { 0, 1.5, 0 }, color = "Text", material = "Marble" },
			{ size = { 10, 0.2, 3.2 }, offset = { 0, 3.1, 0 }, color = "PanelLight", material = "SmoothPlastic" },
			{ size = { 2, 2, 2 }, offset = { -3, 4, 0 }, color = "Metal", material = "Metal", shape = "Cylinder" },
			{ size = { 1.2, 1.2, 1.2 }, offset = { 0, 3.8, 0 }, color = "Night", material = "Metal" },
			{ size = { 3, 1.6, 2 }, offset = { 3, 3.8, 0 }, color = "Warning", material = "Plastic" },
			{ size = { 6, 1.6, 1.2 }, offset = { 0, 5.4, -2.4 }, color = "Scooby", material = "WoodPlanks" },
		},
	},

	shelf_porcelain = {
		label = "Estante de Porcelana",
		parts = {
			{ size = { 8, 8, 1.6 }, offset = { 0, 4, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 7.6, 0.3, 1.4 }, offset = { 0, 2.2, -0.2 }, color = "Gold", material = "Fabric" },
			{ size = { 7.6, 0.3, 1.4 }, offset = { 0, 4.6, -0.2 }, color = "Gold", material = "Fabric" },
			{ size = { 7.6, 0.3, 1.4 }, offset = { 0, 6.8, -0.2 }, color = "Gold", material = "Fabric" },
			{
				size = { 1.4, 1.4, 1.4 },
				offset = { -2.4, 5.4, -0.2 },
				color = "Text",
				material = "Ceramic",
				shape = "Cylinder",
			},
			{
				size = { 1.4, 1.4, 1.4 },
				offset = { 0, 5.4, -0.2 },
				color = "Text",
				material = "Ceramic",
				shape = "Cylinder",
			},
			{
				size = { 1.4, 1.4, 1.4 },
				offset = { 2.4, 5.4, -0.2 },
				color = "Text",
				material = "Ceramic",
				shape = "Cylinder",
			},
		},
	},

	duct_pipe = {
		label = "Duto de Serviço",
		parts = {
			{
				size = { 4, 4, 8 },
				offset = { 0, 12, 0 },
				color = "Metal",
				material = "DiamondPlate",
				rotation = { 0, 0, 45 },
			},
			{ size = { 4.4, 4.4, 0.4 }, offset = { 0, 12, -4.2 }, color = "Metal", material = "Metal" },
		},
	},

	weight_rack = {
		label = "Rack de Pesos",
		parts = {
			{ size = { 6, 0.4, 2 }, offset = { 0, 0.4, 0 }, color = "Metal", material = "Metal" },
			{ size = { 1, 4, 1 }, offset = { -2.4, 2, 0 }, color = "Metal", material = "Metal", shape = "Cylinder" },
			{ size = { 1, 4, 1 }, offset = { 2.4, 2, 0 }, color = "Metal", material = "Metal", shape = "Cylinder" },
			{
				size = { 1.4, 1.4, 1.4 },
				offset = { -1.2, 0.6, 0 },
				color = "Night",
				material = "Metal",
				shape = "Ball",
			},
			{ size = { 1.4, 1.4, 1.4 }, offset = { 1.2, 0.6, 0 }, color = "Night", material = "Metal", shape = "Ball" },
		},
		-- contrapeso que pode virar parte de armadilha
		interact = { kind = "trap_part" },
	},

	curtain = {
		label = "Cortina de Brocado",
		blocksMovement = true,
		parts = {
			{ size = { 0.4, 12, 8 }, offset = { 0, 6, 0 }, color = "Danger", material = "Fabric" },
			{ size = { 0.8, 0.6, 8.4 }, offset = { 0, 12.2, 0 }, color = "Gold", material = "Metal" },
		},
	},

	round_table = {
		label = "Mesa Redonda",
		parts = {
			{ size = { 4, 0.4, 4 }, offset = { 0, 3, 0 }, color = "Text", material = "Marble", shape = "Cylinder" },
			{ size = { 0.8, 3, 0.8 }, offset = { 0, 1.5, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 1.4, 1.6, 1.4 }, offset = { 0, 4, 0 }, color = "Warning", material = "Neon" },
		},
		light = { offset = { 0, 5.6, 0 }, color = "Warning", brightness = 2, range = 14 },
	},

	bed = {
		label = "Cama",
		parts = {
			{ size = { 6, 1.4, 8 }, offset = { 0, 1.4, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 5.6, 1, 7.6 }, offset = { 0, 2.6, 0 }, color = "Text", material = "Fabric" },
			{ size = { 5.6, 0.6, 2 }, offset = { 0, 3.2, -2.6 }, color = "MysteryBlue", material = "Fabric" },
			{ size = { 6, 3, 0.6 }, offset = { 0, 3.4, -4 }, color = "Scooby", material = "Wood" },
		},
	},

	vanity = {
		label = "Penteadeira",
		parts = {
			{ size = { 5, 3, 2.4 }, offset = { 0, 1.5, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 4, 3, 0.3 }, offset = { 0, 4.4, -1.2 }, color = "Gold", material = "Metal" },
			{
				size = { 3.4, 2.4, 0.2 },
				offset = { 0, 4.4, -1.4 },
				color = "Accent",
				material = "Glass",
				transparency = 0.4,
			},
			{ size = { 1.2, 1.2, 0.2 }, offset = { 0, 3.2, -1.4 }, color = "Warning", material = "Neon" },
		},
	},

	armoire = {
		label = "Armário",
		blocksMovement = true,
		parts = {
			{ size = { 6, 9, 3 }, offset = { 0, 4.5, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 0.2, 8, 0.2 }, offset = { 0, 4.5, -1.6 }, color = "Gold", material = "Metal" },
		},
	},

	jewel_case = {
		label = "Vitrine de Joias",
		parts = {
			{ size = { 4, 3, 2 }, offset = { 0, 1.5, 0 }, color = "Scooby", material = "Wood" },
			{
				size = { 3.6, 2.6, 1.6 },
				offset = { 0, 4.6, 0 },
				color = "Accent",
				material = "Glass",
				transparency = 0.5,
			},
			{ size = { 0.8, 0.8, 0.8 }, offset = { 0, 3.6, 0 }, color = "Gold", material = "Neon" },
		},
		light = { offset = { 0, 5.4, 0 }, color = "Gold", brightness = 2, range = 10 },
	},

	luggage_cart = {
		label = "Carrinho de Malas",
		parts = {
			{ size = { 4, 0.3, 6 }, offset = { 0, 1.2, 0 }, color = "Gold", material = "Metal" },
			{ size = { 0.3, 5, 0.3 }, offset = { -1.6, 3.5, -2.6 }, color = "Gold", material = "Metal" },
			{ size = { 0.3, 5, 0.3 }, offset = { 1.6, 3.5, -2.6 }, color = "Gold", material = "Metal" },
			{ size = { 3.6, 0.3, 0.3 }, offset = { 0, 6, -2.6 }, color = "Gold", material = "Metal" },
			{ size = { 3, 3, 4 }, offset = { 0, 3, 0 }, color = "PanelLight", material = "Fabric" },
		},
	},

	mirror_wall = {
		label = "Espelho de Parede",
		parts = {
			{ size = { 6, 9, 0.4 }, offset = { 0, 5, 0 }, color = "Gold", material = "Metal" },
			{
				size = { 5.2, 8, 0.2 },
				offset = { 0, 5, -0.3 },
				color = "Accent",
				material = "Glass",
				transparency = 0.35,
				reflectivity = 0.6,
			},
		},
		light = { offset = { 0, 5, -1 }, color = "Accent", brightness = 1.2, range = 12 },
	},

	gaslight = {
		label = "Lâmpada Antiga",
		parts = {
			{ size = { 1.2, 1.6, 1.2 }, offset = { 0, 10, 0 }, color = "Warning", material = "Neon" },
			{ size = { 1.6, 0.4, 1.6 }, offset = { 0, 9, 0 }, color = "Gold", material = "Metal" },
		},
		light = { offset = { 0, 9.6, 0 }, color = "Warning", brightness = 2.4, range = 20 },
	},

	staircase = {
		label = "Escada de Serviço",
		blocksMovement = true,
		parts = {
			{ size = { 6, 0.6, 2 }, offset = { 0, 1, 0 }, color = "Metal", material = "DiamondPlate" },
			{ size = { 6, 0.6, 2 }, offset = { 0, 2.6, 2 }, color = "Metal", material = "DiamondPlate" },
			{ size = { 6, 0.6, 2 }, offset = { 0, 4.2, 4 }, color = "Metal", material = "DiamondPlate" },
			{ size = { 6, 0.6, 2 }, offset = { 0, 5.8, 6 }, color = "Metal", material = "DiamondPlate" },
			{ size = { 6, 6, 8 }, offset = { 0, 3, 8 }, color = "Metal", material = "DiamondPlate" },
		},
	},

	staircase_grand = {
		label = "Escadaria Principal",
		blocksMovement = true,
		parts = {
			{ size = { 14, 0.8, 2 }, offset = { 0, 1, 0 }, color = "Marble", material = "Marble" },
			{ size = { 14, 0.8, 2 }, offset = { 0, 2.6, 2 }, color = "Marble", material = "Marble" },
			{ size = { 14, 0.8, 2 }, offset = { 0, 4.2, 4 }, color = "Marble", material = "Marble" },
			{ size = { 14, 0.8, 2 }, offset = { 0, 5.8, 6 }, color = "Marble", material = "Marble" },
			{ size = { 14, 8, 10 }, offset = { 0, 4, 9 }, color = "Marble", material = "Marble" },
			{ size = { 0.6, 6, 12 }, offset = { -7, 4, 5 }, color = "Gold", material = "Metal" },
			{ size = { 0.6, 6, 12 }, offset = { 7, 4, 5 }, color = "Gold", material = "Metal" },
		},
	},

	--------------------------------------------------------------- EXTERIOR
	fishing_net_pile = {
		label = "Pilha de Redes",
		parts = {
			{ size = { 6, 1.6, 6 }, offset = { 0, 0.8, 0 }, color = "ShaggyHair", material = "Fabric" },
			{
				size = { 4.4, 1.4, 4.4 },
				offset = { 0.6, 1.8, -0.4 },
				color = "MysteryGreen",
				material = "Fabric",
				rotation = { 0, 20, 0 },
			},
		},
	},

	buoy = {
		label = "Bóia",
		parts = {
			{ size = { 3, 3, 3 }, offset = { 0, 1.6, 0 }, color = "Danger", material = "Plastic", shape = "Ball" },
			{ size = { 1, 1.6, 1 }, offset = { 0, 3.2, 0 }, color = "Text", material = "Plastic", shape = "Cylinder" },
			{ size = { 1, 1, 1 }, offset = { 0, 4.4, 0 }, color = "Warning", material = "Neon", shape = "Ball" },
		},
	},

	crate_stack_small = {
		label = "Caixas Pequenas",
		parts = {
			{ size = { 2, 2, 2 }, offset = { 0, 1, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 2, 2, 2 }, offset = { 0, 3, 0 }, color = "ShaggyHair", material = "WoodPlanks" },
		},
	},

	fish_crate = {
		label = "Caixa de Peixe",
		parts = {
			{ size = { 3, 1.6, 2 }, offset = { 0, 0.8, 0 }, color = "MysteryTeal", material = "WoodPlanks" },
			{ size = { 2.6, 0.4, 1.6 }, offset = { 0, 1.7, 0 }, color = "PanelLight", material = "Metal" },
		},
	},

	boat = {
		label = "Barco de Pesca",
		blocksMovement = true,
		parts = {
			{ size = { 6, 2.4, 14 }, offset = { 0, 1.6, 0 }, color = "MysteryBlue", material = "WoodPlanks" },
			{ size = { 5, 1.4, 4 }, offset = { 0, 3.4, 4 }, color = "Text", material = "WoodPlanks" },
			{ size = { 3, 4, 3 }, offset = { 0, 5, 5 }, color = "Night", material = "Metal" },
			{ size = { 0.4, 8, 0.4 }, offset = { 0, 8, -4 }, color = "Scooby", material = "WoodPlanks" },
		},
	},

	crane = {
		label = "Guindaste do Canteiro",
		blocksMovement = true,
		parts = {
			{ size = { 4, 1.4, 8 }, offset = { 0, 0.7, 0 }, color = "Warning", material = "DiamondPlate" },
			{ size = { 1.6, 22, 1.6 }, offset = { 0, 11, 0 }, color = "Warning", material = "Metal" },
			{ size = { 1.2, 1.2, 18 }, offset = { 0, 22, -8 }, color = "Warning", material = "Metal" },
			{ size = { 0.3, 8, 0.3 }, offset = { 0, 18, -16 }, color = "Metal", material = "Metal" },
			{ size = { 3, 1.2, 3 }, offset = { 0, 13.4, -16 }, color = "Night", material = "Metal" },
		},
		light = { offset = { 0, 22, -16 }, color = "Danger", brightness = 2, range = 22 },
	},

	scaffold = {
		label = "Andaime",
		blocksMovement = true,
		parts = {
			{ size = { 8, 0.4, 4 }, offset = { 0, 6, 0 }, color = "Warning", material = "Metal" },
			{ size = { 8, 0.4, 4 }, offset = { 0, 12, 0 }, color = "Warning", material = "Metal" },
			{ size = { 0.4, 12, 0.4 }, offset = { -3.6, 6, -1.6 }, color = "Metal", material = "Metal" },
			{ size = { 0.4, 12, 0.4 }, offset = { 3.6, 6, -1.6 }, color = "Metal", material = "Metal" },
			{ size = { 0.4, 12, 0.4 }, offset = { -3.6, 6, 1.6 }, color = "Metal", material = "Metal" },
			{ size = { 0.4, 12, 0.4 }, offset = { 3.6, 6, 1.6 }, color = "Metal", material = "Metal" },
		},
	},

	barrel = {
		label = "Barril",
		parts = {
			{ size = { 2.4, 3, 2.4 }, offset = { 0, 1.5, 0 }, color = "Scooby", material = "Wood", shape = "Cylinder" },
			{
				size = { 2.6, 0.4, 2.6 },
				offset = { 0, 0.6, 0 },
				color = "Metal",
				material = "Metal",
				shape = "Cylinder",
			},
			{
				size = { 2.6, 0.4, 2.6 },
				offset = { 0, 2.4, 0 },
				color = "Metal",
				material = "Metal",
				shape = "Cylinder",
			},
		},
	},

	lighthouse_light = {
		label = "Lanterna do Farol",
		parts = {
			{ size = { 8, 1.4, 8 }, offset = { 0, 0, 0 }, color = "Slate", material = "Slate" },
			{ size = { 6, 6, 6 }, offset = { 0, 4, 0 }, color = "Accent", material = "Glass", transparency = 0.35 },
			{ size = { 3, 3, 3 }, offset = { 0, 4, 0 }, color = "Warning", material = "Neon", shape = "Ball" },
			{ size = { 7, 1, 7 }, offset = { 0, 7.6, 0 }, color = "Slate", material = "Slate" },
			{ size = { 1, 3, 1 }, offset = { 0, 9, 0 }, color = "Metal", material = "Metal" },
		},
		light = { offset = { 0, 4, 0 }, color = "Warning", brightness = 3.4, range = 120 },
	},

	anchor = {
		label = "Âncora Antiga",
		parts = {
			{ size = { 0.8, 6, 0.8 }, offset = { 0, 3, 0 }, color = "Metal", material = "CorrodedMetal" },
			{ size = { 4, 0.8, 0.8 }, offset = { 0, 1, 0 }, color = "Metal", material = "CorrodedMetal" },
			{ size = { 1, 0.8, 0.8 }, offset = { 0, 6.2, 0 }, color = "Metal", material = "CorrodedMetal" },
		},
	},

	shop_shelf = {
		label = "Prateleira da Loja",
		parts = {
			{ size = { 6, 7, 1.4 }, offset = { 0, 3.5, 0 }, color = "ShaggyHair", material = "WoodPlanks" },
			{ size = { 5.6, 0.3, 1.2 }, offset = { 0, 2.2, -0.2 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 5.6, 0.3, 1.2 }, offset = { 0, 4.4, -0.2 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 5.6, 0.3, 1.2 }, offset = { 0, 6.4, -0.2 }, color = "Scooby", material = "WoodPlanks" },
			{
				size = { 1.2, 1.2, 1.2 },
				offset = { -1.8, 5.4, -0.2 },
				color = "Danger",
				material = "Plastic",
				shape = "Cylinder",
			},
			{
				size = { 1.2, 1.2, 1.2 },
				offset = { 0, 5.4, -0.2 },
				color = "Warning",
				material = "Plastic",
				shape = "Cylinder",
			},
			{
				size = { 1.2, 1.2, 1.2 },
				offset = { 1.8, 5.4, -0.2 },
				color = "MysteryGreen",
				material = "Plastic",
				shape = "Cylinder",
			},
		},
	},

	lab_bench = {
		label = "Bancada de Laboratório",
		parts = {
			{ size = { 10, 0.4, 4 }, offset = { 0, 3, 0 }, color = "Text", material = "Marble" },
			{ size = { 0.5, 3, 4 }, offset = { -4.6, 1.5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 0.5, 3, 4 }, offset = { 4.6, 1.5, 0 }, color = "Metal", material = "Metal" },
			{
				size = { 1.6, 2.4, 1.6 },
				offset = { -3, 4.2, 0 },
				color = "Accent",
				material = "Glass",
				transparency = 0.5,
				shape = "Cylinder",
			},
			{ size = { 2, 1.2, 1.4 }, offset = { 1.6, 3.8, 0 }, color = "Night", material = "Plastic" },
			{ size = { 1.6, 1.6, 0.3 }, offset = { 3.6, 4.4, -1.4 }, color = "Accent", material = "Neon" },
		},
		light = { offset = { 0, 6, 0 }, color = "Accent", brightness = 1.8, range = 16 },
	},

	aquarium = {
		label = "Aquário",
		parts = {
			{ size = { 8, 4, 4 }, offset = { 0, 4, 0 }, color = "MysteryTeal", material = "Glass", transparency = 0.5 },
			{ size = { 8.4, 0.6, 4.4 }, offset = { 0, 1.6, 0 }, color = "Metal", material = "Metal" },
			{ size = { 2, 1.6, 1.6 }, offset = { -2, 4, 0 }, color = "Warning", material = "Neon", shape = "Ball" },
			{
				size = { 1.6, 1.2, 1.2 },
				offset = { 2.4, 3.8, 0.4 },
				color = "Daphne",
				material = "Neon",
				shape = "Ball",
			},
		},
		light = { offset = { 0, 6, 0 }, color = "MysteryTeal", brightness = 2, range = 16 },
	},

	grand_painting = {
		label = "Quadro 'A Dama de Preto'",
		parts = {
			{ size = { 6, 8, 0.5 }, offset = { 0, 5, 0 }, color = "Gold", material = "Wood" },
			{ size = { 5.2, 7.2, 0.2 }, offset = { 0, 5, -0.35 }, color = "Night", material = "Fabric" },
			{ size = { 2.6, 4.4, 0.1 }, offset = { 0, 5.4, -0.5 }, color = "DeepPurple", material = "Fabric" },
			{ size = { 1.6, 1.6, 0.1 }, offset = { 0, 7.4, -0.5 }, color = "Text", material = "Fabric" },
			{ size = { 3.6, 0.3, 0.1 }, offset = { 0, 3.2, -0.5 }, color = "Purple", material = "Fabric" },
		},
		interact = { kind = "clue" },
	},

	easel = {
		label = "Cavalete de Restauro",
		parts = {
			{ size = { 0.4, 8, 0.4 }, offset = { -2, 4, -1 }, color = "Scooby", material = "Wood" },
			{ size = { 0.4, 8, 0.4 }, offset = { 2, 4, -1 }, color = "Scooby", material = "Wood" },
			{ size = { 0.4, 8, 0.4 }, offset = { 0, 4, 1.4 }, color = "Scooby", material = "Wood" },
			{ size = { 4.4, 0.4, 1 }, offset = { 0, 3.4, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 4, 5, 0.2 }, offset = { 0, 6, -0.6 }, color = "Text", material = "Fabric" },
		},
	},

	reading_desk = {
		label = "Mesa de Leitura",
		parts = {
			{ size = { 8, 0.5, 4 }, offset = { 0, 3, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 1, 3, 4 }, offset = { -3.6, 1.5, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 1, 3, 4 }, offset = { 3.6, 1.5, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 1.6, 0.6, 1.2 }, offset = { -2, 3.6, 0 }, color = "Danger", material = "Fabric" },
			{ size = { 1, 1.2, 1 }, offset = { 2, 4, 0 }, color = "Warning", material = "Neon" },
		},
		light = { offset = { 2, 5, 0 }, color = "Warning", brightness = 2, range = 12 },
	},

	candelabra = {
		label = "Candelabro",
		parts = {
			{ size = { 0.6, 4, 0.6 }, offset = { 0, 10, 0 }, color = "Gold", material = "Metal" },
			{ size = { 4, 0.4, 0.4 }, offset = { 0, 12, 0 }, color = "Gold", material = "Metal" },
			{ size = { 0.6, 1.4, 0.6 }, offset = { -1.8, 12.8, 0 }, color = "Warning", material = "Neon" },
			{ size = { 0.6, 1.4, 0.6 }, offset = { 1.8, 12.8, 0 }, color = "Warning", material = "Neon" },
		},
		light = { offset = { 0, 13, 0 }, color = "Warning", brightness = 2.6, range = 24 },
	},

	pedestal = {
		label = "Pedestal de Exposição",
		parts = {
			{ size = { 3, 4, 3 }, offset = { 0, 2, 0 }, color = "Marble", material = "Marble" },
			{ size = { 3.6, 0.4, 3.6 }, offset = { 0, 4.2, 0 }, color = "Marble", material = "Marble" },
			{ size = { 2, 2, 2 }, offset = { 0, 5.4, 0 }, color = "Gold", material = "Neon", shape = "Ball" },
		},
		light = { offset = { 0, 6.4, 0 }, color = "Gold", brightness = 2.2, range = 14 },
	},

	sarcophagus = {
		label = "Sarcófago",
		blocksMovement = true,
		parts = {
			{ size = { 4, 3, 10 }, offset = { 0, 1.5, 0 }, color = "Slate", material = "Slate" },
			{ size = { 3.4, 1.4, 9 }, offset = { 0, 3.4, 0 }, color = "Gold", material = "Slate" },
			{ size = { 2.6, 0.3, 6.4 }, offset = { 0, 4.2, 0 }, color = "Warning", material = "Neon" },
		},
	},

	bed_canopy = {
		label = "Cama com Dossel",
		parts = {
			{ size = { 8, 1.6, 10 }, offset = { 0, 1.4, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 7.4, 1.2, 9.4 }, offset = { 0, 2.8, 0 }, color = "Text", material = "Fabric" },
			{ size = { 0.6, 12, 0.6 }, offset = { -3.6, 6, -4.4 }, color = "Scooby", material = "Wood" },
			{ size = { 0.6, 12, 0.6 }, offset = { 3.6, 6, -4.4 }, color = "Scooby", material = "Wood" },
			{ size = { 8, 4, 10 }, offset = { 0, 12, 0 }, color = "Purple", material = "Fabric", transparency = 0.35 },
		},
	},

	dresser = {
		label = "Cômoda",
		parts = {
			{ size = { 6, 4, 3 }, offset = { 0, 2, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 5, 0.3, 2.4 }, offset = { 0, 1.6, -1.6 }, color = "Gold", material = "Metal" },
			{ size = { 5, 0.3, 2.4 }, offset = { 0, 3, -1.6 }, color = "Gold", material = "Metal" },
			{ size = { 2, 1.4, 1.4 }, offset = { 0, 5, 0 }, color = "Accent", material = "Glass" },
		},
	},

	old_stove = {
		label = "Fogão Antigo",
		parts = {
			{ size = { 5, 4, 4 }, offset = { 0, 2, 0 }, color = "Night", material = "CorrodedMetal" },
			{ size = { 4.4, 0.4, 3.4 }, offset = { 0, 4.2, 0 }, color = "Metal", material = "Metal" },
			{ size = { 2, 1.6, 0.4 }, offset = { 0, 2.4, -2.1 }, color = "Danger", material = "Neon" },
		},
	},

	hanging_pots = {
		label = "Panelas Penduradas",
		parts = {
			{ size = { 0.3, 3, 0.3 }, offset = { 0, 1.5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 4, 0.3, 0.3 }, offset = { 0, 0, 0 }, color = "Metal", material = "Metal" },
			{ size = { 1.6, 1.6, 0.4 }, offset = { -1.4, -1.2, 0 }, color = "Metal", material = "CorrodedMetal" },
			{ size = { 1.4, 1.2, 0.4 }, offset = { 1.4, -1, 0 }, color = "Metal", material = "CorrodedMetal" },
		},
	},

	gargoyle = {
		label = "Gárgula",
		parts = {
			{ size = { 4, 2, 5 }, offset = { 0, 1, 0 }, color = "Slate", material = "Slate" },
			{ size = { 3, 4, 3 }, offset = { 0, 4, 0.5 }, color = "Slate", material = "Slate" },
			{ size = { 2.4, 2.4, 2.4 }, offset = { 0, 7, 0 }, color = "Slate", material = "Slate" },
			{ size = { 4, 1, 1 }, offset = { -2, 7.4, 0 }, color = "Slate", material = "Slate" },
			{ size = { 4, 1, 1 }, offset = { 2, 7.4, 0 }, color = "Slate", material = "Slate" },
			{
				size = { 0.6, 0.6, 0.6 },
				offset = { -0.7, 7.4, -1.2 },
				color = "Danger",
				material = "Neon",
				shape = "Ball",
			},
			{
				size = { 0.6, 0.6, 0.6 },
				offset = { 0.7, 7.4, -1.2 },
				color = "Danger",
				material = "Neon",
				shape = "Ball",
			},
		},
	},

	fountain_dry = {
		label = "Fonte Seca",
		blocksMovement = true,
		parts = {
			{ size = { 10, 1.2, 10 }, offset = { 0, 0.6, 0 }, color = "Slate", material = "Slate" },
			{ size = { 8, 2, 8 }, offset = { 0, 2, 0 }, color = "Cobblestone", material = "Cobblestone" },
			{ size = { 2, 5, 2 }, offset = { 0, 5, 0 }, color = "Slate", material = "Slate" },
		},
	},

	iron_fence = {
		label = "Grade de Ferro",
		blocksMovement = true,
		parts = {
			{ size = { 16, 6, 0.4 }, offset = { 0, 3, 0 }, color = "Night", material = "Metal" },
			{ size = { 16, 0.6, 0.8 }, offset = { 0, 6.2, 0 }, color = "Night", material = "Metal" },
			{ size = { 0.6, 7, 0.6 }, offset = { -8, 3.5, 0 }, color = "Night", material = "Metal" },
			{ size = { 0.6, 7, 0.6 }, offset = { 8, 3.5, 0 }, color = "Night", material = "Metal" },
		},
	},

	fence = {
		label = "Cerca de Madeira",
		parts = {
			{ size = { 14, 1, 0.4 }, offset = { 0, 3.4, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 14, 1, 0.4 }, offset = { 0, 1.8, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 0.6, 5, 0.6 }, offset = { -6, 2.4, 0 }, color = "ShaggyHair", material = "WoodPlanks" },
			{ size = { 0.6, 5, 0.6 }, offset = { 0, 2.4, 0 }, color = "ShaggyHair", material = "WoodPlanks" },
			{ size = { 0.6, 5, 0.6 }, offset = { 6, 2.4, 0 }, color = "ShaggyHair", material = "WoodPlanks" },
		},
	},

	--------------------------------------------------------------- CIRCO
	circus_ring_prop = {
		label = "Picadeiro",
		parts = {
			{ size = { 22, 0.4, 22 }, offset = { 0, 0.2, 0 }, color = "Gold", material = "Fabric", shape = "Cylinder" },
			{
				size = { 18, 0.6, 18 },
				offset = { 0, 0.5, 0 },
				color = "Danger",
				material = "Fabric",
				shape = "Cylinder",
			},
			{ size = { 12, 0.8, 12 }, offset = { 0, 0.9, 0 }, color = "Text", material = "Fabric", shape = "Cylinder" },
		},
	},

	trapeze = {
		label = "Trapézio e Rede",
		parts = {
			{ size = { 0.4, 26, 0.4 }, offset = { -10, 13, 0 }, color = "Metal", material = "Metal" },
			{ size = { 0.4, 26, 0.4 }, offset = { 10, 13, 0 }, color = "Metal", material = "Metal" },
			{ size = { 20, 0.4, 0.4 }, offset = { 0, 24, 0 }, color = "Metal", material = "Metal" },
			{ size = { 0.3, 8, 0.3 }, offset = { -2, 20, 0 }, color = "ShaggyHair", material = "Fabric" },
			{ size = { 0.3, 8, 0.3 }, offset = { 2, 20, 0 }, color = "ShaggyHair", material = "Fabric" },
			{ size = { 4, 0.3, 0.3 }, offset = { 0, 16, 0 }, color = "Scooby", material = "WoodPlanks" },
			{
				size = { 22, 1, 22 },
				offset = { 0, 4, 0 },
				color = "MysteryGreen",
				material = "Fabric",
				transparency = 0.55,
			},
		},
	},

	bleacher = {
		label = "Arquibancada",
		blocksMovement = true,
		parts = {
			{ size = { 6, 2, 18 }, offset = { 0, 1, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 6, 2, 18 }, offset = { -6, 3, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 6, 2, 18 }, offset = { -12, 5, 0 }, color = "Scooby", material = "WoodPlanks" },
		},
	},

	cage = {
		label = "Jaula",
		blocksMovement = true,
		parts = {
			{ size = { 12, 0.4, 12 }, offset = { 0, 0.2, 0 }, color = "Metal", material = "Metal" },
			{ size = { 12, 0.4, 12 }, offset = { 0, 10, 0 }, color = "Metal", material = "Metal" },
			{ size = { 12, 10, 0.3 }, offset = { 0, 5, -6 }, color = "Metal", material = "Metal" },
			{ size = { 12, 10, 0.3 }, offset = { 0, 5, 6 }, color = "Metal", material = "Metal" },
			{ size = { 0.3, 10, 12 }, offset = { -6, 5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 0.3, 10, 12 }, offset = { 6, 5, 0 }, color = "Metal", material = "Metal" },
		},
	},

	costume_rack = {
		label = "Arara de Figurinos",
		parts = {
			{ size = { 0.4, 7, 0.4 }, offset = { -4, 3.5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 0.4, 7, 0.4 }, offset = { 4, 3.5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 8, 0.3, 0.3 }, offset = { 0, 7, 0 }, color = "Metal", material = "Metal" },
			{ size = { 1.6, 3.4, 0.6 }, offset = { -2.4, 5.2, 0 }, color = "Danger", material = "Fabric" },
			{ size = { 1.6, 3.4, 0.6 }, offset = { 0, 5.2, 0 }, color = "Purple", material = "Fabric" },
			{ size = { 1.6, 3.4, 0.6 }, offset = { 2.4, 5.2, 0 }, color = "MysteryTeal", material = "Fabric" },
		},
	},

	stilts = {
		label = "Pernas de Pau",
		parts = {
			{ size = { 0.5, 10, 0.5 }, offset = { -0.6, 5, 0 }, color = "Danger", material = "WoodPlanks" },
			{ size = { 0.5, 10, 0.5 }, offset = { 0.6, 5, 0 }, color = "Danger", material = "WoodPlanks" },
			{ size = { 2.4, 0.6, 1.4 }, offset = { 0, 10.4, 0 }, color = "Warning", material = "WoodPlanks" },
		},
		interact = { kind = "clue" },
	},

	popcorn_machine = {
		label = "Máquina de Pipoca",
		parts = {
			{ size = { 3, 4, 3 }, offset = { 0, 2, 0 }, color = "Danger", material = "Metal" },
			{ size = { 2.6, 2, 2.6 }, offset = { 0, 5, 0 }, color = "Accent", material = "Glass", transparency = 0.4 },
			{ size = { 3.4, 0.6, 3.4 }, offset = { 0, 4.2, 0 }, color = "Gold", material = "Metal" },
		},
		light = { offset = { 0, 5.6, 0 }, color = "Warning", brightness = 2.4, range = 16 },
		interact = { kind = "shop" },
	},

	cannon = {
		label = "Canhão de Circo",
		blocksMovement = true,
		parts = {
			{
				size = { 4, 4, 8 },
				offset = { 0, 2, 0 },
				color = "Danger",
				material = "Metal",
				shape = "Cylinder",
				rotation = { 90, 0, 0 },
			},
			{ size = { 6, 1, 8 }, offset = { 0, 1, 0 }, color = "Gold", material = "Metal" },
			{
				size = { 4.4, 4.4, 0.6 },
				offset = { 0, 2, -4 },
				color = "Warning",
				material = "Metal",
				shape = "Cylinder",
				rotation = { 90, 0, 0 },
			},
		},
	},

	clown_car = {
		label = "Carro de Palhaço",
		blocksMovement = true,
		parts = {
			{ size = { 4, 2.4, 7 }, offset = { 0, 2.4, 0 }, color = "Danger", material = "Metal" },
			{ size = { 3.4, 2.6, 3 }, offset = { 0, 4.6, 1 }, color = "Text", material = "Metal" },
			{ size = { 1.2, 1.2, 1.2 }, offset = { 0, 4, -3.4 }, color = "Warning", material = "Neon", shape = "Ball" },
			{
				size = { 1.4, 2.4, 1.4 },
				offset = { -1.8, 1.2, -2.4 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 1.4, 2.4, 1.4 },
				offset = { 1.8, 1.2, -2.4 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 1.4, 2.4, 1.4 },
				offset = { -1.8, 1.2, 2.4 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 1.4, 2.4, 1.4 },
				offset = { 1.8, 1.2, 2.4 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
		},
	},

	audio_console = {
		label = "Mesa de Som",
		parts = {
			{ size = { 10, 3, 3 }, offset = { 0, 1.5, 0 }, color = "Night", material = "Metal" },
			{
				size = { 9.4, 0.4, 2.4 },
				offset = { 0, 3.2, -0.2 },
				color = "Panel",
				material = "Metal",
				rotation = { -12, 0, 0 },
			},
			{ size = { 1.4, 1.6, 0.4 }, offset = { -3.4, 4, -1 }, color = "Accent", material = "Glass" },
			{ size = { 1.4, 1.6, 0.4 }, offset = { 3.4, 4, -1 }, color = "Accent", material = "Glass" },
			{
				size = { 0.4, 0.4, 0.4 },
				offset = { -1, 4.2, 0.6 },
				color = "Danger",
				material = "Neon",
				shape = "Ball",
			},
			{
				size = { 0.4, 0.4, 0.4 },
				offset = { 0, 4.2, 0.6 },
				color = "Warning",
				material = "Neon",
				shape = "Ball",
			},
			{
				size = { 0.4, 0.4, 0.4 },
				offset = { 1, 4.2, 0.6 },
				color = "MysteryGreen",
				material = "Neon",
				shape = "Ball",
			},
		},
		light = { offset = { 0, 5.4, 0 }, color = "Accent", brightness = 1.8, range = 14 },
		interact = { kind = "clue" },
	},

	concession_stand = {
		label = "Bilheteria",
		parts = {
			{ size = { 8, 4, 4 }, offset = { 0, 2, 0 }, color = "Danger", material = "WoodPlanks" },
			{ size = { 9, 0.6, 6 }, offset = { 0, 5, -1 }, color = "Danger", material = "Fabric" },
			{ size = { 4, 0.6, 2 }, offset = { 0, 4.2, -2.4 }, color = "Gold", material = "WoodPlanks" },
			{ size = { 2, 1.4, 0.3 }, offset = { 0, 6, -3.4 }, color = "Warning", material = "Neon" },
		},
		light = { offset = { 0, 7, -2 }, color = "Warning", brightness = 2.6, range = 20 },
	},

	string_lights = {
		label = "Luzes de Fio",
		parts = {
			{ size = { 0.2, 0.2, 24 }, offset = { 0, 0, 0 }, color = "Night", material = "Plastic" },
			{
				size = { 0.8, 0.8, 0.8 },
				offset = { 0, -0.4, -10 },
				color = "Warning",
				material = "Neon",
				shape = "Ball",
			},
			{ size = { 0.8, 0.8, 0.8 }, offset = { 0, -0.4, -5 }, color = "Danger", material = "Neon", shape = "Ball" },
			{ size = { 0.8, 0.8, 0.8 }, offset = { 0, -0.4, 0 }, color = "Accent", material = "Neon", shape = "Ball" },
			{ size = { 0.8, 0.8, 0.8 }, offset = { 0, -0.4, 5 }, color = "Gold", material = "Neon", shape = "Ball" },
			{ size = { 0.8, 0.8, 0.8 }, offset = { 0, -0.4, 10 }, color = "Daphne", material = "Neon", shape = "Ball" },
		},
		light = { offset = { 0, -1, 0 }, color = "Warning", brightness = 1.8, range = 22 },
	},

	--------------------------------------------------------------- FÁBRICA
	conveyor = {
		label = "Esteira de Montagem",
		blocksMovement = true,
		parts = {
			{ size = { 6, 2, 26 }, offset = { 0, 2, 0 }, color = "PanelLight", material = "Metal" },
			{ size = { 6.4, 0.4, 26 }, offset = { 0, 3.2, 0 }, color = "Night", material = "Rubber" },
			{ size = { 7, 0.6, 26.4 }, offset = { 0, 1.2, 0 }, color = "Metal", material = "DiamondPlate" },
			{ size = { 2, 1.4, 2 }, offset = { 0, 4, -11 }, color = "Danger", material = "Neon" },
		},
		light = { offset = { 0, 5, -11 }, color = "Danger", brightness = 2, range = 14 },
	},

	press_machine = {
		label = "Prensa Hidráulica",
		blocksMovement = true,
		parts = {
			{ size = { 14, 1, 12 }, offset = { 0, 0.5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 3, 16, 3 }, offset = { -5, 9, 0 }, color = "CorrodedMetal", material = "CorrodedMetal" },
			{ size = { 3, 16, 3 }, offset = { 5, 9, 0 }, color = "CorrodedMetal", material = "CorrodedMetal" },
			{ size = { 10, 3, 10 }, offset = { 0, 15, 0 }, color = "Metal", material = "Metal" },
			{ size = { 8, 2, 8 }, offset = { 0, 12, 0 }, color = "Danger", material = "Metal" },
			{ size = { 4, 0.6, 4 }, offset = { 0, 6, 0 }, color = "Warning", material = "Neon" },
		},
		light = { offset = { 0, 6, 0 }, color = "Warning", brightness = 2, range = 18 },
	},

	control_desk = {
		label = "Mesa de Controle",
		blocksMovement = true,
		parts = {
			{ size = { 12, 0.6, 4 }, offset = { 0, 3, 0 }, color = "Panel", material = "Metal" },
			{ size = { 1, 3, 4 }, offset = { -5.4, 1.5, 0 }, color = "PanelLight", material = "Metal" },
			{ size = { 1, 3, 4 }, offset = { 5.4, 1.5, 0 }, color = "PanelLight", material = "Metal" },
			{ size = { 3, 2.4, 0.4 }, offset = { -3.4, 4.4, -1.4 }, color = "Accent", material = "Glass" },
			{ size = { 3, 2.4, 0.4 }, offset = { 0, 4.4, -1.4 }, color = "Accent", material = "Glass" },
			{ size = { 3, 2.4, 0.4 }, offset = { 3.4, 4.4, -1.4 }, color = "Accent", material = "Glass" },
			{
				size = { 2, 1.4, 1.4 },
				offset = { -4, 4, 1.2 },
				color = "Text",
				material = "Plastic",
				shape = "Cylinder",
			},
		},
		light = { offset = { 0, 6, 0 }, color = "Accent", brightness = 2.2, range = 18 },
		interact = { kind = "clue" },
	},

	breaker_panel = {
		label = "Quadro Elétrico",
		parts = {
			{ size = { 8, 10, 1 }, offset = { 0, 5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 7, 8.4, 0.2 }, offset = { 0, 5, -0.6 }, color = "Panel", material = "Metal" },
			{ size = { 1, 1.6, 0.4 }, offset = { -2.4, 6, -0.9 }, color = "Danger", material = "Neon" },
			{ size = { 1, 1.6, 0.4 }, offset = { 0, 6, -0.9 }, color = "Warning", material = "Neon" },
			{ size = { 1, 1.6, 0.4 }, offset = { 2.4, 6, -0.9 }, color = "MysteryGreen", material = "Neon" },
		},
		light = { offset = { 0, 5, -2 }, color = "Warning", brightness = 1.8, range = 14 },
		interact = { kind = "clue" },
	},

	locker = {
		label = "Armário de Aço",
		blocksMovement = true,
		parts = {
			{ size = { 3, 9, 3 }, offset = { 0, 4.5, 0 }, color = "PanelLight", material = "Metal" },
			{ size = { 2.4, 0.4, 0.2 }, offset = { 0, 6, -1.6 }, color = "Metal", material = "Metal" },
			{
				size = { 0.6, 0.6, 0.6 },
				offset = { 1, 4.6, -1.6 },
				color = "Gold",
				material = "Metal",
				shape = "Cylinder",
				rotation = { 90, 0, 0 },
			},
		},
	},

	generator = {
		label = "Gerador",
		blocksMovement = true,
		parts = {
			{ size = { 8, 4, 5 }, offset = { 0, 2, 0 }, color = "Warning", material = "CorrodedMetal" },
			{ size = { 3, 4, 3 }, offset = { -5, 2, 0 }, color = "Metal", material = "Metal", shape = "Cylinder" },
			{ size = { 1.4, 4, 1.4 }, offset = { 4, 6, 0 }, color = "Metal", material = "Metal", shape = "Cylinder" },
			{ size = { 2, 1.4, 0.4 }, offset = { 0, 3.4, -2.6 }, color = "Accent", material = "Glass" },
			{
				size = { 0.6, 0.6, 0.6 },
				offset = { 2, 4.4, -2.6 },
				color = "Danger",
				material = "Neon",
				shape = "Ball",
			},
		},
		light = { offset = { 0, 6, -1 }, color = "Danger", brightness = 1.6, range = 14 },
	},

	pallet = {
		label = "Palete com Carga",
		blocksMovement = true,
		parts = {
			{ size = { 4, 0.4, 5 }, offset = { 0, 0.2, 0 }, color = "ShaggyHair", material = "WoodPlanks" },
			{ size = { 3.6, 3, 4.4 }, offset = { 0, 2, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 3.6, 2, 4.4 }, offset = { 0, 4.4, 0 }, color = "ShaggyHair", material = "WoodPlanks" },
		},
	},

	canteen_table = {
		label = "Mesa da Cantina",
		parts = {
			{ size = { 8, 0.4, 4 }, offset = { 0, 3, 0 }, color = "Text", material = "Plastic" },
			{ size = { 1, 3, 4 }, offset = { -3.4, 1.5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 1, 3, 4 }, offset = { 3.4, 1.5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 4, 0.4, 1.4 }, offset = { 0, 1.8, 4 }, color = "Warning", material = "Plastic" },
			{ size = { 4, 0.4, 1.4 }, offset = { 0, 1.8, -4 }, color = "Warning", material = "Plastic" },
			{
				size = { 1.2, 0.8, 1.2 },
				offset = { -2, 3.6, 0 },
				color = "Danger",
				material = "Plastic",
				shape = "Cylinder",
			},
		},
	},

	coffee_machine = {
		label = "Cafeteira Industrial",
		parts = {
			{ size = { 3, 4, 2.4 }, offset = { 0, 2, 0 }, color = "Metal", material = "Metal" },
			{
				size = { 2, 1.6, 1.6 },
				offset = { 0, 1.6, -1.4 },
				color = "Text",
				material = "Ceramic",
				shape = "Cylinder",
			},
			{ size = { 2.4, 0.6, 0.3 }, offset = { 0, 4.4, -1.2 }, color = "Warning", material = "Neon" },
		},
		light = { offset = { 0, 4.6, -1 }, color = "Warning", brightness = 1.6, range = 10 },
	},

	filing_cabinet = {
		label = "Arquivo de Aço",
		blocksMovement = true,
		parts = {
			{ size = { 4, 7, 3 }, offset = { 0, 3.5, 0 }, color = "PanelLight", material = "Metal" },
			{ size = { 3.4, 0.4, 0.2 }, offset = { 0, 2, -1.6 }, color = "Metal", material = "Metal" },
			{ size = { 3.4, 0.4, 0.2 }, offset = { 0, 4, -1.6 }, color = "Metal", material = "Metal" },
			{ size = { 3.4, 0.4, 0.2 }, offset = { 0, 6, -1.6 }, color = "Metal", material = "Metal" },
		},
	},

	pipe_run = {
		label = "Tubulação",
		parts = {
			{
				size = { 2, 2, 20 },
				offset = { 0, 14, 0 },
				color = "CorrodedMetal",
				material = "CorrodedMetal",
				shape = "Cylinder",
				rotation = { 90, 0, 0 },
			},
			{
				size = { 2.4, 2.4, 0.6 },
				offset = { 0, 14, -10 },
				color = "Metal",
				material = "Metal",
				shape = "Cylinder",
				rotation = { 90, 0, 0 },
			},
		},
	},

	crane_hook = {
		label = "Gancho de Ponte Rolante",
		parts = {
			{ size = { 24, 1, 1.6 }, offset = { 0, 0, 0 }, color = "Warning", material = "Metal" },
			{ size = { 0.4, 12, 0.4 }, offset = { 0, -6, 0 }, color = "Metal", material = "Metal" },
			{ size = { 2, 2, 2 }, offset = { 0, -12, 0 }, color = "Metal", material = "Metal" },
			{
				size = { 0.6, 0.6, 0.6 },
				offset = { 0, -12, -1.4 },
				color = "Danger",
				material = "Neon",
				shape = "Ball",
			},
		},
		light = { offset = { 0, -12, -1.6 }, color = "Danger", brightness = 1.8, range = 14 },
	},

	forklift = {
		label = "Empilhadeira",
		blocksMovement = true,
		parts = {
			{ size = { 4, 3, 5 }, offset = { 0, 2.6, 0 }, color = "Warning", material = "Metal" },
			{ size = { 3, 4, 3 }, offset = { 0, 6, 1.6 }, color = "Metal", material = "Metal" },
			{ size = { 4.4, 0.4, 2.4 }, offset = { 0, 1, -3.8 }, color = "Metal", material = "Metal" },
			{ size = { 0.4, 5, 0.4 }, offset = { -1.6, 4.6, -3.4 }, color = "Metal", material = "Metal" },
			{ size = { 0.4, 5, 0.4 }, offset = { 1.6, 4.6, -3.4 }, color = "Metal", material = "Metal" },
			{ size = { 0.4, 5, 0.4 }, offset = { 0, 6, -3.4 }, color = "Metal", material = "Metal" },
			{
				size = { 1.4, 2.4, 1.4 },
				offset = { -2.2, 1.2, 0 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 1.4, 2.4, 1.4 },
				offset = { 2.2, 1.2, 0 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
		},
	},

	--------------------------------------------------------------- ESTRADA / FAZENDA
	gas_pump = {
		label = "Bomba de Combustível",
		parts = {
			{ size = { 3, 1, 3 }, offset = { 0, 0.5, 0 }, color = "Concrete", material = "Concrete" },
			{ size = { 3, 5, 2.4 }, offset = { 0, 3.5, 0 }, color = "Danger", material = "Metal" },
			{ size = { 2.4, 1.4, 0.2 }, offset = { 0, 5, -1.3 }, color = "Text", material = "Glass" },
			{ size = { 0.4, 3, 0.4 }, offset = { 1.6, 3, -1.4 }, color = "Night", material = "Rubber" },
		},
	},

	road_sign = {
		label = "Placa de Estrada",
		parts = {
			{ size = { 0.4, 9, 0.4 }, offset = { 0, 4.5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 4, 2.4, 0.2 }, offset = { 0, 8, 0 }, color = "Warning", material = "Metal" },
			{ size = { 3, 1.6, 0.1 }, offset = { 0, 8, -0.2 }, color = "Night", material = "Plastic" },
		},
	},

	wrecked_car = {
		label = "Carro Batido",
		blocksMovement = true,
		parts = {
			{
				size = { 6, 2.4, 12 },
				offset = { 0, 2.2, 0 },
				color = "PanelLight",
				material = "Metal",
				rotation = { 0, 0, 4 },
			},
			{
				size = { 5, 2.6, 5 },
				offset = { 0, 4.6, 1 },
				color = "Panel",
				material = "Metal",
				rotation = { 0, 0, 6 },
			},
			{
				size = { 5.2, 1.6, 3 },
				offset = { 0, 4.4, 4 },
				color = "PanelLight",
				material = "Glass",
				transparency = 0.5,
			},
			{
				size = { 1.6, 2.6, 1.6 },
				offset = { -3, 1.4, -4 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 1.6, 2.6, 1.6 },
				offset = { 3, 1.4, 4 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
		},
	},

	truck = {
		label = "Caminhão",
		blocksMovement = true,
		parts = {
			{ size = { 8, 4, 10 }, offset = { 0, 5, 8 }, color = "MysteryBlue", material = "Metal" },
			{ size = { 8, 5, 6 }, offset = { 0, 6, -2 }, color = "Danger", material = "Metal" },
			{
				size = { 7.4, 3, 0.4 },
				offset = { 0, 7.4, -5 },
				color = "Accent",
				material = "Glass",
				transparency = 0.4,
			},
			{ size = { 10, 0.6, 22 }, offset = { 0, 3.4, 4 }, color = "PanelLight", material = "DiamondPlate" },
			{
				size = { 2.4, 4, 2.4 },
				offset = { -4, 2, -4 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 2.4, 4, 2.4 },
				offset = { 4, 2, -4 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 2.4, 4, 2.4 },
				offset = { -4, 2, 6 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 2.4, 4, 2.4 },
				offset = { 4, 2, 6 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 2.4, 4, 2.4 },
				offset = { -4, 2, 12 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 2.4, 4, 2.4 },
				offset = { 4, 2, 12 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
		},
	},

	diner_booth = {
		label = "Cabine da Lanchonete",
		parts = {
			{ size = { 4, 0.4, 4 }, offset = { 0, 3, 0 }, color = "Text", material = "Plastic" },
			{ size = { 4, 3, 0.6 }, offset = { 0, 4.4, 1.6 }, color = "Danger", material = "Fabric" },
			{ size = { 4, 3, 0.6 }, offset = { 0, 4.4, -1.6 }, color = "Danger", material = "Fabric" },
			{ size = { 0.4, 3, 4 }, offset = { 0, 1.5, 0 }, color = "Metal", material = "Metal" },
		},
	},

	counter = {
		label = "Balcão do Restaurante",
		blocksMovement = true,
		parts = {
			{ size = { 12, 3.4, 3 }, offset = { 0, 1.7, 0 }, color = "Danger", material = "Plastic" },
			{ size = { 12.4, 0.3, 3.4 }, offset = { 0, 3.6, 0 }, color = "Metal", material = "Metal" },
			{
				size = { 1.4, 1.6, 1 },
				offset = { -4, 4.4, 0 },
				color = "Warning",
				material = "Plastic",
				shape = "Cylinder",
			},
			{
				size = { 1.4, 1.6, 1 },
				offset = { -1, 4.4, 0 },
				color = "Warning",
				material = "Plastic",
				shape = "Cylinder",
			},
			{ size = { 2, 1.2, 1.4 }, offset = { 3, 4.2, 0 }, color = "Gold", material = "Metal" },
		},
	},

	tractor = {
		label = "Trator Pequeno",
		blocksMovement = true,
		parts = {
			{ size = { 3, 3, 6 }, offset = { 0, 3, 0 }, color = "MysteryBlue", material = "Metal" },
			{ size = { 2.6, 4, 3 }, offset = { 0, 6, 1.6 }, color = "Metal", material = "Metal" },
			{ size = { 5.4, 0.5, 2.4 }, offset = { 0, 8.4, 1.6 }, color = "Metal", material = "Metal" },
			{ size = { 0.4, 1, 0.4 }, offset = { 0, 9, 1.6 }, color = "Night", material = "Metal", shape = "Cylinder" },
			{
				size = { 2.4, 5, 2.4 },
				offset = { -2, 2.5, -2 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 2.4, 5, 2.4 },
				offset = { 2, 2.5, -2 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 1.6, 2.4, 1.6 },
				offset = { -2, 1.2, 3 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 1.6, 2.4, 1.6 },
				offset = { 2, 1.2, 3 },
				color = "Night",
				material = "Rubber",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{ size = { 3, 1.6, 0.4 }, offset = { 0, 4.4, -3.2 }, color = "Warning", material = "Neon" },
		},
	},

	haystack = {
		label = "Fardo de Feno",
		blocksMovement = true,
		parts = {
			{ size = { 6, 4, 5 }, offset = { 0, 2, 0 }, color = "Gold", material = "Grass" },
			{ size = { 5, 3, 4 }, offset = { 0, 5, 0 }, color = "Gold", material = "Grass", rotation = { 0, 24, 0 } },
		},
	},

	horse_trough = {
		label = "Cocho",
		parts = {
			{ size = { 8, 2, 2.4 }, offset = { 0, 1, 0 }, color = "Scooby", material = "WoodPlanks" },
			{
				size = { 7.4, 1.4, 1.8 },
				offset = { 0, 1.6, 0 },
				color = "MysteryTeal",
				material = "Glass",
				transparency = 0.5,
			},
		},
	},

	windmill = {
		label = "Moinho de Vento",
		blocksMovement = true,
		parts = {
			{ size = { 3, 14, 3 }, offset = { 0, 7, 0 }, color = "Metal", material = "Metal" },
			{ size = { 1.4, 1.4, 1.4 }, offset = { 0, 14, 0 }, color = "Metal", material = "Metal" },
			{
				size = { 0.4, 8, 0.4 },
				offset = { 0, 14, 0 },
				color = "Scooby",
				material = "WoodPlanks",
				rotation = { 45, 0, 0 },
			},
			{
				size = { 0.4, 8, 0.4 },
				offset = { 0, 14, 0 },
				color = "Scooby",
				material = "WoodPlanks",
				rotation = { -45, 0, 0 },
			},
			{ size = { 4, 1.4, 0.3 }, offset = { 2, 17, 0 }, color = "Text", material = "Fabric" },
			{ size = { 4, 1.4, 0.3 }, offset = { -2, 11, 0 }, color = "Text", material = "Fabric" },
		},
	},

	log_pile = {
		label = "Pilha de Toras",
		blocksMovement = true,
		parts = {
			{
				size = { 2, 2, 12 },
				offset = { -1, 1, 0 },
				color = "Scooby",
				material = "Wood",
				shape = "Cylinder",
				rotation = { 90, 0, 0 },
			},
			{
				size = { 2, 2, 12 },
				offset = { 1, 1, 0 },
				color = "ShaggyHair",
				material = "Wood",
				shape = "Cylinder",
				rotation = { 90, 0, 0 },
			},
			{
				size = { 2, 2, 12 },
				offset = { 0, 3, 0 },
				color = "Scooby",
				material = "Wood",
				shape = "Cylinder",
				rotation = { 90, 0, 0 },
			},
		},
	},

	tree = {
		label = "Árvore",
		blocksMovement = true,
		parts = {
			{ size = { 2, 12, 2 }, offset = { 0, 6, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 10, 6, 10 }, offset = { 0, 14, 0 }, color = "MysteryGreen", material = "Grass" },
			{ size = { 7, 4, 7 }, offset = { 2, 17, 1 }, color = "MysteryGreen", material = "Grass" },
		},
	},

	barrier = {
		label = "Barreira de Obra",
		parts = {
			{ size = { 14, 2, 0.6 }, offset = { 0, 4, 0 }, color = "Warning", material = "WoodPlanks" },
			{ size = { 14, 2, 0.6 }, offset = { 0, 1.4, 0 }, color = "Warning", material = "WoodPlanks" },
			{ size = { 0.6, 5, 0.6 }, offset = { -6, 2.5, 0 }, color = "Metal", material = "Metal" },
			{ size = { 0.6, 5, 0.6 }, offset = { 6, 2.5, 0 }, color = "Metal", material = "Metal" },
		},
	},

	excavator = {
		label = "Escavadeira",
		blocksMovement = true,
		parts = {
			{ size = { 4, 2, 10 }, offset = { 0, 1, 0 }, color = "Night", material = "Metal" },
			{ size = { 5, 3, 6 }, offset = { 0, 5, -1 }, color = "Warning", material = "Metal" },
			{ size = { 3, 3, 3 }, offset = { 0, 8.6, -1 }, color = "PanelLight", material = "Metal" },
			{
				size = { 2, 2, 8 },
				offset = { 0, 7, -5 },
				color = "Warning",
				material = "Metal",
				rotation = { 40, 0, 0 },
			},
			{ size = { 3, 3, 3 }, offset = { 0, 4, -9 }, color = "Metal", material = "CorrodedMetal" },
		},
	},

	bridge_beam = {
		label = "Viga da Ponte",
		blocksMovement = true,
		parts = {
			{ size = { 20, 1.4, 1.4 }, offset = { 0, 2, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 1.4, 6, 1.4 }, offset = { -10, 3, 0 }, color = "Scooby", material = "WoodPlanks" },
			{ size = { 1.4, 6, 1.4 }, offset = { 10, 3, 0 }, color = "Scooby", material = "WoodPlanks" },
		},
	},

	--------------------------------------------------------------- MANSÃO / FINAL
	catalog_table = {
		label = "Mesa do Catálogo",
		parts = {
			{ size = { 10, 0.5, 5 }, offset = { 0, 3, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 1.4, 3, 5 }, offset = { -4.4, 1.5, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 1.4, 3, 5 }, offset = { 4.4, 1.5, 0 }, color = "Scooby", material = "Wood" },
			{ size = { 4, 1.4, 3 }, offset = { 0, 4, 0 }, color = "DeepPurple", material = "Fabric" },
			{ size = { 1.4, 1.4, 1.4 }, offset = { 0, 5.2, 0 }, color = "Gold", material = "Neon", shape = "Ball" },
		},
		light = { offset = { 0, 6, 0 }, color = "Gold", brightness = 2.2, range = 16 },
		interact = { kind = "clue" },
	},

	fog_machine = {
		label = "Máquina de Névoa",
		parts = {
			{ size = { 4, 3, 3 }, offset = { 0, 1.5, 0 }, color = "Panel", material = "Metal" },
			{
				size = { 1.6, 1.6, 3.4 },
				offset = { 2.4, 1.6, 0 },
				color = "Metal",
				material = "Metal",
				shape = "Cylinder",
				rotation = { 90, 0, 0 },
			},
			{ size = { 0.8, 0.8, 0.8 }, offset = { -1, 3.4, 0 }, color = "Accent", material = "Neon", shape = "Ball" },
		},
		particles = { { offset = { 4, 2, 0 }, color = "Text", size = 2.4, rate = 22 } },
	},

	spotlight = {
		label = "Holofote de Palco",
		parts = {
			{ size = { 2, 2, 2 }, offset = { 0, 0, 0 }, color = "Night", material = "Metal" },
			{ size = { 2.4, 2.4, 2.4 }, offset = { 0, -2, 0 }, color = "Text", material = "Metal" },
			{ size = { 1.6, 1.6, 0.4 }, offset = { 0, -2, -1.4 }, color = "Warning", material = "Neon" },
		},
		light = { offset = { 0, -6, -2 }, color = "Warning", brightness = 3, range = 40 },
	},

	display_case = {
		label = "Vitrine de Acervo",
		parts = {
			{ size = { 6, 3, 4 }, offset = { 0, 1.5, 0 }, color = "Scooby", material = "Wood" },
			{
				size = { 5.4, 4, 3.4 },
				offset = { 0, 5.2, 0 },
				color = "Accent",
				material = "Glass",
				transparency = 0.55,
			},
			{ size = { 4, 2, 2 }, offset = { 0, 4, 0 }, color = "DeepPurple", material = "Fabric" },
			{ size = { 1.4, 1.4, 1.4 }, offset = { 0, 4, 0 }, color = "Gold", material = "Neon", shape = "Ball" },
		},
		light = { offset = { 0, 6, 0 }, color = "Gold", brightness = 2, range = 14 },
	},

	loading_door = {
		label = "Portão de Carga",
		blocksMovement = true,
		parts = {
			{ size = { 14, 12, 0.6 }, offset = { 0, 6, 0 }, color = "PanelLight", material = "DiamondPlate" },
			{ size = { 14.4, 0.8, 1 }, offset = { 0, 12.4, 0 }, color = "Warning", material = "Metal" },
			{ size = { 3, 0.8, 0.4 }, offset = { 0, 8, -0.5 }, color = "Danger", material = "Neon" },
		},
	},

	cable_spool = {
		label = "Carretel de Cabos",
		parts = {
			{
				size = { 3, 3, 3 },
				offset = { 0, 3, 0 },
				color = "Warning",
				material = "Metal",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 4, 0.4, 4 },
				offset = { -1, 3, 0 },
				color = "Scooby",
				material = "Wood",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
			{
				size = { 4, 0.4, 4 },
				offset = { 1, 3, 0 },
				color = "Scooby",
				material = "Wood",
				shape = "Cylinder",
				rotation = { 0, 0, 90 },
			},
		},
	},

	ammeter_case = {
		label = "Mostruário",
		parts = {
			{ size = { 6, 8, 2 }, offset = { 0, 4, 0 }, color = "Scooby", material = "Wood" },
			{
				size = { 5.4, 7, 0.4 },
				offset = { 0, 4, -1.2 },
				color = "Accent",
				material = "Glass",
				transparency = 0.5,
			},
			{ size = { 1.2, 1.2, 1.2 }, offset = { 0, 4, -1 }, color = "Gold", material = "Neon", shape = "Ball" },
		},
	},

	iron_gate = {
		label = "Portão de Ferro",
		parts = {
			{ size = { 16, 10, 0.6 }, offset = { 0, 5, 0 }, color = "Night", material = "Metal" },
			{ size = { 0.8, 12, 1.2 }, offset = { -8, 6, 0 }, color = "Night", material = "Metal" },
			{ size = { 0.8, 12, 1.2 }, offset = { 8, 6, 0 }, color = "Night", material = "Metal" },
		},
	},
}

-- ==========================================================
-- TEMAS DE DECORAÇÃO POR TIPO DE SALA
-- O Decorator (src/server/Builders/Decorator.luau) distribui automaticamente
-- os props de acordo com `placement`:
--    wall    = encostado nas paredes
--    corner  = cantos da sala
--    center  = centro (mesa, picadeiro...)
--    scatter = posições aleatórias (com semente fixa, então é sempre igual)
-- ==========================================================
local function theme(...)
	local list = { ... }
	return { props = list }
end

Props.RoomThemes = {
	------------------------------------------------- LOBBY
	lobby_hall = theme(
		{ type = "sofa", count = 2, placement = "wall" },
		{ type = "plant", count = 3, placement = "corner" },
		{ type = "bench", count = 1, placement = "scatter" }
	),
	office = theme(
		{ type = "desk", count = 2, placement = "wall" },
		{ type = "bookshelf", count = 3, placement = "wall" },
		{ type = "filing_cabinet", count = 2, placement = "corner" }
	),
	case_board = theme(
		{ type = "bookshelf", count = 2, placement = "wall" },
		{ type = "plant", count = 1, placement = "corner" }
	),
	shop = theme(
		{ type = "shop_shelf", count = 3, placement = "wall" },
		{ type = "snack_machine", count = 1, placement = "wall" }
	),
	training = theme(
		{ type = "training_dummy", count = 4, placement = "scatter" },
		{ type = "weight_rack", count = 2, placement = "wall" },
		{ type = "bench", count = 1, placement = "wall" }
	),
	garage = theme(
		{ type = "crate_stack", count = 2, placement = "corner" },
		{ type = "tire_stack", count = 3, placement = "wall" },
		{ type = "toolbox", count = 0, placement = "scatter" }
	),
	yard = theme(
		{ type = "bench", count = 2, placement = "scatter" },
		{ type = "tree", count = 3, placement = "scatter" },
		{ type = "street_lamp", count = 2, placement = "scatter" }
	),
	portal_hall = theme(
		{ type = "plant", count = 4, placement = "wall" },
		{ type = "bench", count = 2, placement = "scatter" }
	),

	------------------------------------------------- EP1
	roadside = theme(
		{ type = "road_sign", count = 1, placement = "scatter" },
		{ type = "barrier", count = 1, placement = "scatter" },
		{ type = "street_lamp", count = 2, placement = "scatter" }
	),
	dock = theme(
		{ type = "fish_crate", count = 3, placement = "scatter" },
		{ type = "crate_stack_small", count = 2, placement = "wall" },
		{ type = "barrel", count = 2, placement = "corner" }
	),
	pier = theme(
		{ type = "buoy", count = 2, placement = "scatter" },
		{ type = "bench", count = 1, placement = "scatter" },
		{ type = "fishing_net_pile", count = 1, placement = "wall" }
	),
	boathouse = theme(
		{ type = "boat", count = 1, placement = "center" },
		{ type = "fishing_net_pile", count = 2, placement = "wall" },
		{ type = "barrel", count = 3, placement = "corner" },
		{ type = "crate_stack", count = 1, placement = "wall" }
	),
	inn = theme(
		{ type = "bed", count = 3, placement = "wall" },
		{ type = "dresser", count = 2, placement = "wall" },
		{ type = "plant", count = 2, placement = "corner" }
	),
	laboratory = theme(
		{ type = "lab_bench", count = 2, placement = "wall" },
		{ type = "aquarium", count = 1, placement = "wall" },
		{ type = "locker", count = 2, placement = "wall" }
	),
	construction = theme(
		{ type = "barrel", count = 4, placement = "scatter" },
		{ type = "pallet", count = 2, placement = "scatter" },
		{ type = "scaffold", count = 1, placement = "center" },
		{ type = "barrier", count = 2, placement = "scatter" }
	),
	lighthouse_base = theme(
		{ type = "desk", count = 1, placement = "wall" },
		{ type = "bookshelf", count = 1, placement = "wall" },
		{ type = "breaker_panel", count = 1, placement = "wall" },
		{ type = "crate_stack_small", count = 2, placement = "corner" }
	),
	lighthouse_tower = theme(
		{ type = "staircase", count = 1, placement = "center" },
		{ type = "pipe_run", count = 1, placement = "center" }
	),

	------------------------------------------------- EP2
	garden = theme(
		{ type = "plant", count = 4, placement = "scatter" },
		{ type = "bench", count = 2, placement = "scatter" },
		{ type = "fountain", count = 1, placement = "center" }
	),
	hotel_lobby = theme(
		{ type = "reception_counter", count = 1, placement = "wall" },
		{ type = "sofa", count = 2, placement = "wall" },
		{ type = "plant", count = 3, placement = "corner" },
		{ type = "luggage_cart", count = 1, placement = "scatter" }
	),
	ballroom = theme(
		{ type = "round_table", count = 4, placement = "scatter" },
		{ type = "curtain", count = 4, placement = "wall" },
		{ type = "chandelier", count = 1, placement = "center" }
	),
	elevator_hall = theme(
		{ type = "staircase", count = 1, placement = "wall" },
		{ type = "crate_stack_small", count = 1, placement = "corner" }
	),
	kitchen = theme(
		{ type = "kitchen_counter", count = 2, placement = "wall" },
		{ type = "old_stove", count = 1, placement = "wall" },
		{ type = "hanging_pots", count = 2, placement = "center" }
	),
	storage = theme(
		{ type = "ammeter_case", count = 2, placement = "wall" },
		{ type = "crate_stack", count = 3, placement = "corner" },
		{ type = "barrel", count = 2, placement = "scatter" }
	),
	hotel_corridor = theme(
		{ type = "mirror_wall", count = 2, placement = "wall" },
		{ type = "gaslight", count = 3, placement = "wall" },
		{ type = "plant", count = 2, placement = "corner" }
	),
	hotel_room = theme(
		{ type = "bed", count = 2, placement = "wall" },
		{ type = "vanity", count = 1, placement = "wall" },
		{ type = "armoire", count = 1, placement = "wall" }
	),
	hotel_suite = theme(
		{ type = "bed", count = 2, placement = "wall" },
		{ type = "vanity", count = 1, placement = "wall" },
		{ type = "armoire", count = 1, placement = "wall" },
		{ type = "jewel_case", count = 1, placement = "corner" }
	),
	duct = theme({ type = "pipe_run", count = 2, placement = "center" }),
	gym = theme(
		{ type = "weight_rack", count = 3, placement = "wall" },
		{ type = "bench", count = 2, placement = "scatter" }
	),
	basement = theme(
		{ type = "cable_spool", count = 3, placement = "scatter" },
		{ type = "crate_stack", count = 2, placement = "corner" },
		{ type = "generator", count = 1, placement = "wall" }
	),

	------------------------------------------------- EP3
	circus_gate = theme(
		{ type = "string_lights", count = 2, placement = "center" },
		{ type = "concession_stand", count = 1, placement = "wall" },
		{ type = "barrier", count = 2, placement = "scatter" }
	),
	ticket_office = theme(
		{ type = "concession_stand", count = 1, placement = "wall" },
		{ type = "desk", count = 1, placement = "wall" },
		{ type = "crate_stack_small", count = 1, placement = "corner" }
	),
	circus_ring = theme(
		{ type = "circus_ring_prop", count = 1, placement = "center" },
		{ type = "cannon", count = 1, placement = "wall" },
		{ type = "clown_car", count = 1, placement = "scatter" },
		{ type = "barrel", count = 3, placement = "corner" }
	),
	bleachers = theme(
		{ type = "bleacher", count = 4, placement = "wall" },
		{ type = "string_lights", count = 1, placement = "center" }
	),
	dressing_room = theme(
		{ type = "costume_rack", count = 3, placement = "wall" },
		{ type = "vanity", count = 2, placement = "wall" },
		{ type = "stilts", count = 1, placement = "corner" }
	),
	cages = theme(
		{ type = "cage", count = 3, placement = "scatter" },
		{ type = "barrel", count = 2, placement = "corner" }
	),
	circus_office = theme(
		{ type = "desk", count = 1, placement = "wall" },
		{ type = "safe", count = 0, placement = "corner" },
		{ type = "bookshelf", count = 2, placement = "wall" },
		{ type = "filing_cabinet", count = 1, placement = "corner" }
	),
	sound_booth = theme(
		{ type = "audio_console", count = 1, placement = "center" },
		{ type = "cable_spool", count = 2, placement = "corner" }
	),
	trapeze_rig = theme(
		{ type = "trapeze", count = 1, placement = "center" },
		{ type = "cable_spool", count = 2, placement = "wall" }
	),
	food_stand = theme(
		{ type = "popcorn_machine", count = 1, placement = "wall" },
		{ type = "counter", count = 1, placement = "wall" },
		{ type = "string_lights", count = 1, placement = "center" },
		{ type = "crate_stack_small", count = 2, placement = "corner" }
	),

	------------------------------------------------- EP4
	loading_yard = theme(
		{ type = "pallet", count = 3, placement = "scatter" },
		{ type = "forklift", count = 2, placement = "scatter" },
		{ type = "fence", count = 2, placement = "wall" },
		{ type = "barrel", count = 3, placement = "corner" }
	),
	factory_floor = theme(
		{ type = "conveyor", count = 2, placement = "center" },
		{ type = "crane_hook", count = 2, placement = "center" },
		{ type = "barrel", count = 4, placement = "scatter" },
		{ type = "pallet", count = 3, placement = "corner" },
		{ type = "locker", count = 2, placement = "wall" }
	),
	press_hall = theme(
		{ type = "press_machine", count = 2, placement = "scatter" },
		{ type = "pipe_run", count = 2, placement = "center" },
		{ type = "barrel", count = 2, placement = "corner" }
	),
	control_room = theme(
		{ type = "control_desk", count = 2, placement = "wall" },
		{ type = "filing_cabinet", count = 2, placement = "corner" },
		{ type = "breaker_panel", count = 1, placement = "wall" }
	),
	locker_room = theme(
		{ type = "locker", count = 4, placement = "wall" },
		{ type = "bench", count = 2, placement = "scatter" },
		{ type = "coffee_machine", count = 1, placement = "wall" }
	),
	power_room = theme(
		{ type = "breaker_panel", count = 2, placement = "wall" },
		{ type = "generator", count = 2, placement = "scatter" },
		{ type = "pipe_run", count = 1, placement = "center" }
	),
	canteen = theme(
		{ type = "canteen_table", count = 4, placement = "scatter" },
		{ type = "counter", count = 1, placement = "wall" },
		{ type = "coffee_machine", count = 1, placement = "wall" },
		{ type = "popcorn_machine", count = 0, placement = "wall" }
	),
	warehouse = theme(
		{ type = "pallet", count = 4, placement = "scatter" },
		{ type = "crate_stack", count = 3, placement = "corner" },
		{ type = "forklift", count = 1, placement = "scatter" }
	),
	service_tunnel = theme(
		{ type = "pipe_run", count = 3, placement = "center" },
		{ type = "cable_spool", count = 2, placement = "wall" }
	),

	------------------------------------------------- EP5
	road_curve = theme(
		{ type = "road_sign", count = 2, placement = "scatter" },
		{ type = "street_lamp", count = 2, placement = "scatter" },
		{ type = "wrecked_car", count = 1, placement = "scatter" },
		{ type = "tree", count = 3, placement = "scatter" }
	),
	road_straight = theme(
		{ type = "road_sign", count = 2, placement = "scatter" },
		{ type = "street_lamp", count = 3, placement = "scatter" },
		{ type = "tree", count = 4, placement = "scatter" },
		{ type = "barrier", count = 1, placement = "scatter" }
	),
	gas_station = theme(
		{ type = "gas_pump", count = 3, placement = "scatter" },
		{ type = "counter", count = 1, placement = "wall" },
		{ type = "crate_stack_small", count = 2, placement = "corner" },
		{ type = "street_lamp", count = 1, placement = "scatter" }
	),
	diner = theme(
		{ type = "diner_booth", count = 4, placement = "scatter" },
		{ type = "counter", count = 1, placement = "wall" },
		{ type = "coffee_machine", count = 1, placement = "wall" },
		{ type = "string_lights", count = 1, placement = "center" }
	),
	old_bridge = theme(
		{ type = "bridge_beam", count = 3, placement = "scatter" },
		{ type = "log_pile", count = 2, placement = "corner" },
		{ type = "fence", count = 2, placement = "wall" }
	),
	barn = theme(
		{ type = "haystack", count = 4, placement = "scatter" },
		{ type = "tractor", count = 1, placement = "center" },
		{ type = "horse_trough", count = 1, placement = "wall" },
		{ type = "fence", count = 2, placement = "wall" }
	),
	farmhouse = theme(
		{ type = "desk", count = 1, placement = "wall" },
		{ type = "bed", count = 1, placement = "wall" },
		{ type = "bookshelf", count = 1, placement = "wall" },
		{ type = "old_stove", count = 1, placement = "wall" }
	),
	forest = theme(
		{ type = "tree", count = 8, placement = "scatter" },
		{ type = "log_pile", count = 2, placement = "scatter" },
		{ type = "barrel", count = 1, placement = "scatter" }
	),

	------------------------------------------------- EP6
	manor_garden = theme(
		{ type = "gargoyle", count = 2, placement = "wall" },
		{ type = "fountain_dry", count = 1, placement = "center" },
		{ type = "iron_fence", count = 2, placement = "wall" },
		{ type = "tree", count = 3, placement = "scatter" }
	),
	manor_hall = theme(
		{ type = "staircase_grand", count = 1, placement = "wall" },
		{ type = "candelabra", count = 3, placement = "center" },
		{ type = "plant", count = 2, placement = "corner" }
	),
	mirror_gallery = theme(
		{ type = "mirror_wall", count = 5, placement = "wall" },
		{ type = "pedestal", count = 3, placement = "scatter" },
		{ type = "candelabra", count = 2, placement = "center" }
	),
	library = theme(
		{ type = "bookshelf", count = 6, placement = "wall" },
		{ type = "reading_desk", count = 2, placement = "scatter" },
		{ type = "candelabra", count = 2, placement = "center" }
	),
	art_studio = theme(
		{ type = "easel", count = 3, placement = "scatter" },
		{ type = "pallet", count = 2, placement = "corner" },
		{ type = "reading_desk", count = 1, placement = "wall" }
	),
	old_kitchen = theme(
		{ type = "old_stove", count = 2, placement = "wall" },
		{ type = "kitchen_counter", count = 2, placement = "wall" },
		{ type = "hanging_pots", count = 3, placement = "center" }
	),
	manor_corridor = theme(
		{ type = "grand_painting", count = 3, placement = "wall" },
		{ type = "candelabra", count = 2, placement = "center" },
		{ type = "mirror_wall", count = 1, placement = "wall" }
	),
	bedroom_lux = theme(
		{ type = "bed_canopy", count = 1, placement = "center" },
		{ type = "dresser", count = 2, placement = "wall" },
		{ type = "jewel_case", count = 1, placement = "corner" }
	),
	catacombs = theme(
		{ type = "sarcophagus", count = 3, placement = "wall" },
		{ type = "crate_stack", count = 2, placement = "scatter" },
		{ type = "pipe_run", count = 2, placement = "center" }
	),
	secret_vault = theme(
		{ type = "display_case", count = 3, placement = "wall" },
		{ type = "pedestal", count = 2, placement = "scatter" },
		{ type = "candelabra", count = 2, placement = "center" }
	),
	service_stairs = theme(
		{ type = "staircase", count = 1, placement = "center" },
		{ type = "cable_spool", count = 2, placement = "wall" }
	),

	------------------------------------------------- FINAL
	cliff_road = theme(
		{ type = "road_sign", count = 2, placement = "scatter" },
		{ type = "street_lamp", count = 2, placement = "scatter" },
		{ type = "tree", count = 3, placement = "scatter" }
	),
	warehouse_entry = theme(
		{ type = "crate_stack", count = 4, placement = "scatter" },
		{ type = "pallet", count = 3, placement = "corner" },
		{ type = "forklift", count = 1, placement = "scatter" },
		{ type = "string_lights", count = 2, placement = "center" }
	),
	set_lighthouse = theme(
		{ type = "fog_machine", count = 1, placement = "wall" },
		{ type = "lighthouse_light", count = 1, placement = "wall" },
		{ type = "barrel", count = 2, placement = "corner" }
	),
	set_hotel = theme(
		{ type = "piano_prop", count = 1, placement = "center" },
		{ type = "curtain", count = 2, placement = "wall" },
		{ type = "round_table", count = 2, placement = "scatter" }
	),
	set_circus = theme(
		{ type = "clown_car", count = 1, placement = "center" },
		{ type = "trapeze", count = 1, placement = "wall" },
		{ type = "string_lights", count = 1, placement = "center" }
	),
	set_factory = theme(
		{ type = "conveyor", count = 1, placement = "center" },
		{ type = "press_machine", count = 1, placement = "wall" },
		{ type = "barrel", count = 3, placement = "corner" }
	),
	set_road = theme(
		{ type = "wrecked_car", count = 1, placement = "center" },
		{ type = "road_sign", count = 2, placement = "scatter" },
		{ type = "log_pile", count = 1, placement = "corner" }
	),
	set_manor = theme(
		{ type = "mirror_wall", count = 3, placement = "wall" },
		{ type = "grand_painting", count = 2, placement = "wall" },
		{ type = "sarcophagus", count = 1, placement = "corner" }
	),
	final_stage = theme(
		{ type = "spotlight", count = 4, placement = "center" },
		{ type = "display_case", count = 2, placement = "scatter" },
		{ type = "pedestal", count = 3, placement = "scatter" },
		{ type = "cable_spool", count = 2, placement = "corner" }
	),
	backstage = theme(
		{ type = "audio_console", count = 1, placement = "wall" },
		{ type = "cable_spool", count = 3, placement = "scatter" },
		{ type = "fog_machine", count = 2, placement = "corner" }
	),
	costume_storage = theme(
		{ type = "costume_rack", count = 4, placement = "wall" },
		{ type = "crate_stack", count = 2, placement = "corner" },
		{ type = "stilts", count = 2, placement = "scatter" }
	),
	loading_door = theme(
		{ type = "pallet", count = 2, placement = "scatter" },
		{ type = "forklift", count = 1, placement = "scatter" },
		{ type = "barrier", count = 2, placement = "scatter" }
	),
}

-- ==========================================================
-- HELPERS
-- ==========================================================
function Props.get(propType)
	return Props.Library[propType]
end

function Props.getTheme(roomKind)
	return Props.RoomThemes[roomKind] or { props = {} }
end

function Props.propTypes()
	local list = {}
	for name in pairs(Props.Library) do
		table.insert(list, name)
	end
	table.sort(list)
	return list
end

function Props.partCount(propType)
	local prop = Props.Library[propType]
	if not prop then
		return 0
	end
	return #prop.parts
end

function Props.validate()
	local problems = {}
	for name, prop in pairs(Props.Library) do
		if not prop.parts or #prop.parts == 0 then
			table.insert(problems, "Prop sem partes: " .. name)
		end
		for index, part in ipairs(prop.parts or {}) do
			if not part.size then
				table.insert(problems, ("Prop %s parte %d sem size"):format(name, index))
			end
			if not part.color then
				table.insert(problems, ("Prop %s parte %d sem color"):format(name, index))
			end
		end
	end
	for kind, roomTheme in pairs(Props.RoomThemes) do
		for _, entry in ipairs(roomTheme.props) do
			-- entradas com count 0 são "desligadas" de propósito (placeholder)
			if (entry.count or 1) > 0 and not Props.Library[entry.type] then
				table.insert(problems, ("Tema %s referencia prop inexistente: %s"):format(kind, entry.type))
			end
		end
	end
	return #problems == 0, problems
end

return Props
