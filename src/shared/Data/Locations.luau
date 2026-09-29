--[[
	Locations.luau
	Definição declarativa de todos os mapas.

	COMO O MAPA É MONTADO (src/server/Builders/MapBuilder.luau):
		1. Todos os blocos da grade viram parede (sólido).
		2. Cada sala/corredor é "escavado" (virando piso caminhável).
		3. O gerador cria paredes automaticamente nas divisas entre piso e bloco sólido,
		   então salas conectadas por corredores ganham portas naturais.
		4. Piso, teto, paredes, luzes e decoração vêm de `floor`, `wall`, `ceiling`
		   e de `kind` (tema de decoração automática).
		5. `markers` posicionam as pistas, NPCs, pontos de armadilha e saídas.
		   Os capítulos (Episodes.luau) referenciam esses IDs.

	Unidades: `x`, `z` = coluna/linha da grade; `w`, `d` = largura/profundidade em
	células. Cada célula = Config.Grid.CELL (8 studs).
	`offset` de um marker é em studs, relativo ao centro da sala.
]]

local Locations = {}

-- Todos os mapas do jogo ficam em Locations.Maps
Locations.Maps = {}

-- ==========================================================
-- A SEDE — LOBBY DE MATCHMAKING (Corretores de Mistério)
-- ==========================================================
Locations.Maps.Lobby = {
	id = "Lobby",
	name = "Sede do Mistério S.A.",
	subtitle = "Corretores de Mistério — Coolsville",
	mood = "Lobby",
	cellSize = 8,
	width = 44,
	depth = 40,
	origin = { x = 0, y = 0, z = 0 },
	outdoorSky = true,
	ground = { material = "Grass", color = "MysteryGreen" },

	rooms = {
		{
			id = "Lobby_Hall",
			label = "Hall de Entrada",
			kind = "lobby_hall",
			x = 16,
			z = 8,
			w = 12,
			d = 8,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "WoodPlanks", color = "MysteryOrange" },
			ceiling = { material = "WoodPlanks", color = "Panel" },
			height = 14,
			light = { color = "MysteryOrange", brightness = 2.6, count = 2 },
		},
		{
			id = "Lobby_Sede",
			label = "Escritório do Mistério S.A.",
			kind = "office",
			x = 10,
			z = 4,
			w = 12,
			d = 4,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "Plaster", color = "MysteryTeal" },
			height = 14,
			light = { color = "Text", brightness = 2.2, count = 2 },
		},
		{
			id = "Lobby_Quadro",
			label = "Sala do Quadro de Casos",
			kind = "case_board",
			x = 24,
			z = 4,
			w = 12,
			d = 4,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "Plaster", color = "Purple" },
			height = 14,
			light = { color = "Accent", brightness = 2.4, count = 2 },
		},
		{
			id = "Lobby_Garagem",
			label = "Garagem da Mystery Machine",
			kind = "garage",
			x = 28,
			z = 16,
			w = 14,
			d = 12,
			floor = { material = "Concrete", color = "PanelLight" },
			wall = { material = "CorrugatedMetal", color = "MysteryBlue" },
			height = 16,
			light = { color = "Text", brightness = 1.9, count = 3 },
		},
		{
			id = "Lobby_Loja",
			label = "Loja do Scooby Snack",
			kind = "shop",
			x = 6,
			z = 16,
			w = 10,
			d = 8,
			floor = { material = "Tile", color = "Text" },
			wall = { material = "Plaster", color = "MysteryGreen" },
			height = 13,
			light = { color = "MysteryGreen", brightness = 2.4, count = 2 },
		},
		{
			id = "Lobby_Treino",
			label = "Sala de Treino",
			kind = "training",
			x = 6,
			z = 26,
			w = 12,
			d = 10,
			floor = { material = "Concrete", color = "Panel" },
			wall = { material = "Concrete", color = "PanelLight" },
			height = 14,
			light = { color = "Warning", brightness = 2.2, count = 3 },
		},
		{
			id = "Lobby_Patio",
			label = "Pátio",
			kind = "yard",
			outdoor = true,
			x = 20,
			z = 20,
			w = 14,
			d = 16,
			floor = { material = "Grass", color = "MysteryGreen" },
			height = 20,
			light = { color = "Text", brightness = 1.6, count = 0 },
		},
		{
			id = "Lobby_Portais",
			label = "Corredor dos Casos",
			kind = "portal_hall",
			x = 20,
			z = 32,
			w = 22,
			d = 6,
			floor = { material = "Marble", color = "PanelLight" },
			wall = { material = "Marble", color = "Purple" },
			height = 18,
			light = { color = "Purple", brightness = 2.6, count = 4 },
		},
	},

	corridors = {
		{ from = "Lobby_Hall", to = "Lobby_Sede", x = 15, z = 7, w = 2, d = 2 },
		{ from = "Lobby_Hall", to = "Lobby_Quadro", x = 27, z = 7, w = 2, d = 2 },
		{ from = "Lobby_Hall", to = "Lobby_Garagem", x = 27, z = 14, w = 2, d = 4 },
		{ from = "Lobby_Hall", to = "Lobby_Loja", x = 9, z = 13, w = 2, d = 4 },
		{ from = "Lobby_Patio", to = "Lobby_Garagem", x = 29, z = 18, w = 3, d = 2 },
		{ from = "Lobby_Patio", to = "Lobby_Treino", x = 17, z = 29, w = 3, d = 3 },
		{ from = "Lobby_Patio", to = "Lobby_Portais", x = 26, z = 31, w = 4, d = 2 },
		{ from = "Lobby_Loja", to = "Lobby_Treino", x = 10, z = 24, w = 2, d = 2 },
	},

	markers = {
		{ id = "Lobby_Spawn", room = "Lobby_Hall", offset = { x = 0, z = -2 }, kind = "spawn" },
		{ id = "Lobby_Spawn2", room = "Lobby_Hall", offset = { x = -4, z = 2 }, kind = "spawn" },
		{ id = "Lobby_Spawn3", room = "Lobby_Hall", offset = { x = 4, z = 2 }, kind = "spawn" },
		{ id = "Lobby_Spawn4", room = "Lobby_Hall", offset = { x = 0, z = 4 }, kind = "spawn" },
		{ id = "Lobby_Fita", room = "Lobby_Garagem", offset = { x = -3, z = -3 }, kind = "interact" },
		{ id = "Lobby_Van", room = "Lobby_Garagem", offset = { x = 0, z = 0 }, kind = "prop" },
		{ id = "Lobby_Quadro", room = "Lobby_Quadro", offset = { x = 0, z = -6 }, kind = "interact" },
		{ id = "Lobby_Scooby", room = "Lobby_Hall", offset = { x = 6, z = -3 }, kind = "npc" },
		{ id = "Lobby_Loja", room = "Lobby_Loja", offset = { x = 0, z = -2 }, kind = "interact" },
		{ id = "Lobby_Treino_Alvo", room = "Lobby_Treino", offset = { x = 0, z = 0 }, kind = "test" },
		{ id = "Lobby_Portal_EP01", room = "Lobby_Portais", offset = { x = -36, z = 0 }, kind = "portal" },
		{ id = "Lobby_Portal_EP02", room = "Lobby_Portais", offset = { x = -22, z = 0 }, kind = "portal" },
		{ id = "Lobby_Portal_EP03", room = "Lobby_Portais", offset = { x = -8, z = 0 }, kind = "portal" },
		{ id = "Lobby_Portal_EP04", room = "Lobby_Portais", offset = { x = 6, z = 0 }, kind = "portal" },
		{ id = "Lobby_Portal_EP05", room = "Lobby_Portais", offset = { x = 20, z = 0 }, kind = "portal" },
		{ id = "Lobby_Portal_EP06", room = "Lobby_Portais", offset = { x = 34, z = 0 }, kind = "portal" },
		{ id = "Lobby_Portal_FINAL", room = "Lobby_Portais", offset = { x = 48, z = 0 }, kind = "portal" },
		{ id = "Lobby_Espelho_Papeis", room = "Lobby_Sede", offset = { x = 0, z = -4 }, kind = "interact" },
	},

	spawns = {
		players = "Lobby_Spawn",
		exit = "Lobby_Portais",
		scooby = "Lobby_Scooby",
	},

	props = {
		{ type = "mystery_machine", marker = "Lobby_Van", rotY = -90 },
		{ type = "case_board", marker = "Lobby_Quadro", rotY = 180 },
		{ type = "role_mirror", marker = "Lobby_Espelho_Papeis", rotY = 180 },
		{ type = "shop_counter", marker = "Lobby_Loja" },
		{ type = "sofa", room = "Lobby_Hall", offset = { x = -8, z = -4 }, rotY = 90 },
		{ type = "plant", room = "Lobby_Hall", offset = { x = 8, z = -4 }, rotY = 0 },
		{ type = "desk", room = "Lobby_Sede", offset = { x = -6, z = 2 }, rotY = 0 },
		{ type = "bookshelf", room = "Lobby_Sede", offset = { x = 6, z = 2 }, rotY = 0 },
		{ type = "snack_machine", room = "Lobby_Loja", offset = { x = -6, z = 3 }, rotY = 0 },
		{ type = "training_dummy", room = "Lobby_Treino", offset = { x = -4, z = 0 }, rotY = 0 },
		{ type = "training_dummy", room = "Lobby_Treino", offset = { x = 4, z = 0 }, rotY = 0 },
		{ type = "crate_stack", room = "Lobby_Garagem", offset = { x = 8, z = 6 }, rotY = 0 },
		{ type = "tire_stack", room = "Lobby_Garagem", offset = { x = -8, z = 6 }, rotY = 0 },
		{ type = "bench", room = "Lobby_Patio", offset = { x = -6, z = -6 }, rotY = 0 },
		{ type = "fountain", room = "Lobby_Patio", offset = { x = 4, z = 4 }, rotY = 0 },
		{ type = "street_lamp", room = "Lobby_Patio", offset = { x = -12, z = 8 }, rotY = 0 },
		{ type = "street_lamp", room = "Lobby_Patio", offset = { x = 12, z = -8 }, rotY = 0 },
		{ type = "portal_door", marker = "Lobby_Portal_EP01", episode = "EP01", rotY = 0 },
		{ type = "portal_door", marker = "Lobby_Portal_EP02", episode = "EP02", rotY = 0 },
		{ type = "portal_door", marker = "Lobby_Portal_EP03", episode = "EP03", rotY = 0 },
		{ type = "portal_door", marker = "Lobby_Portal_EP04", episode = "EP04", rotY = 0 },
		{ type = "portal_door", marker = "Lobby_Portal_EP05", episode = "EP05", rotY = 0 },
		{ type = "portal_door", marker = "Lobby_Portal_EP06", episode = "EP06", rotY = 0 },
		{ type = "portal_door", marker = "Lobby_Portal_FINAL", episode = "FINAL", rotY = 0 },
	},
}

-- ==========================================================
-- EPISÓDIO 1 — FAROL DE PEDRA
-- ==========================================================
Locations.Maps.FarolEP1 = {
	id = "FarolEP1",
	name = "Porto Pedra",
	subtitle = "Vila Pesqueira & Farol",
	mood = "EP01_Farol",
	cellSize = 8,
	width = 60,
	depth = 52,
	origin = { x = 2600, y = 0, z = 0 },
	ground = { material = "Sand", color = "Gold" },
	water = {
		{ x = 1, z = 1, w = 58, d = 14 },
		{ x = 1, z = 15, w = 8, d = 20 },
	},

	rooms = {
		{
			id = "Farol_Entrada",
			label = "Estrada de Entrada",
			kind = "roadside",
			outdoor = true,
			x = 4,
			z = 36,
			w = 10,
			d = 6,
			floor = { material = "Cobblestone", color = "Text" },
			height = 18,
			light = { color = "Warning", brightness = 1.4, count = 2 },
		},
		{
			id = "Doca_Doca",
			label = "Doca Principal",
			kind = "dock",
			outdoor = true,
			x = 10,
			z = 22,
			w = 18,
			d = 8,
			floor = { material = "WoodPlanks", color = "ShaggyHair" },
			height = 18,
			light = { color = "Warning", brightness = 1.6, count = 4 },
		},
		{
			id = "Doca_Pier",
			label = "Píer de Pescadores",
			kind = "pier",
			outdoor = true,
			tags = { "pier", "patrol" },
			x = 12,
			z = 14,
			w = 6,
			d = 10,
			floor = { material = "WoodPlanks", color = "ShaggyHair" },
			height = 16,
			light = { color = "Warning", brightness = 1.5, count = 2 },
		},
		{
			id = "Galpao_Barcos",
			label = "Galpão de Barcos",
			kind = "boathouse",
			tags = { "patrol" },
			x = 8,
			z = 32,
			w = 14,
			d = 10,
			floor = { material = "Concrete", color = "PanelLight" },
			wall = { material = "WoodPlanks", color = "Scooby" },
			height = 16,
			light = { color = "Warning", brightness = 1.9, count = 3 },
		},
		{
			id = "Vila_Pousada",
			label = "Pousada da Lucille",
			kind = "inn",
			x = 32,
			z = 22,
			w = 12,
			d = 10,
			floor = { material = "WoodPlanks", color = "Scooby" },
			wall = { material = "Plaster", color = "MysteryTeal" },
			height = 15,
			light = { color = "Warning", brightness = 2.2, count = 3 },
		},
		{
			id = "Vila_Sala",
			label = "Sala Comunitária da Vila",
			kind = "office",
			x = 46,
			z = 22,
			w = 12,
			d = 10,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "Plaster", color = "MysteryBlue" },
			height = 15,
			light = { color = "Text", brightness = 2.1, count = 3 },
		},
		{
			id = "Vila_Laboratorio",
			label = "Laboratório Marinho",
			kind = "laboratory",
			x = 32,
			z = 34,
			w = 12,
			d = 10,
			floor = { material = "Tile", color = "Text" },
			wall = { material = "Tile", color = "MysteryTeal" },
			height = 15,
			light = { color = "Accent", brightness = 2.3, count = 3 },
		},
		{
			id = "Porto_Loja",
			label = "Loja do Porto",
			kind = "shop",
			x = 46,
			z = 34,
			w = 10,
			d = 10,
			floor = { material = "WoodPlanks", color = "ShaggyHair" },
			wall = { material = "WoodPlanks", color = "MysteryOrange" },
			height = 14,
			light = { color = "Warning", brightness = 2.2, count = 2 },
		},
		{
			id = "Canteiro_Area",
			label = "Canteiro de Obras do Resort",
			kind = "construction",
			outdoor = true,
			tags = { "patrol" },
			x = 10,
			z = 42,
			w = 18,
			d = 8,
			floor = { material = "Gravel", color = "PanelLight" },
			height = 20,
			light = { color = "Warning", brightness = 2, count = 3 },
		},
		{
			id = "Farol_Base",
			label = "Base do Farol",
			kind = "lighthouse_base",
			tags = { "lighthouse", "patrol" },
			x = 36,
			z = 4,
			w = 12,
			d = 12,
			floor = { material = "Slate", color = "Panel" },
			wall = { material = "Slate", color = "Text" },
			height = 18,
			light = { color = "Warning", brightness = 2.4, count = 3 },
		},
		{
			id = "Farol_Torre",
			label = "Torre do Farol",
			kind = "lighthouse_tower",
			tags = { "lighthouse" },
			x = 50,
			z = 4,
			w = 8,
			d = 12,
			floor = { material = "Slate", color = "Panel" },
			wall = { material = "Slate", color = "Text" },
			height = 26,
			light = { color = "Accent", brightness = 3.2, count = 2 },
		},
	},

	corridors = {
		{ x = 14, z = 20, w = 4, d = 3 }, -- chegada -> doca
		{ x = 14, z = 24, w = 3, d = 2 }, -- doca -> píer (acesso)
		{ x = 20, z = 26, w = 12, d = 3 }, -- doca -> vila
		{ x = 24, z = 30, w = 3, d = 6 }, -- vila -> laboratório
		{ x = 42, z = 26, w = 12, d = 3 }, -- vila -> sala comunitária (rua)
		{ x = 27, z = 34, w = 20, d = 3 }, -- laboratório -> loja do porto
		{ x = 18, z = 30, w = 3, d = 4 }, -- doca -> galpão
		{ x = 12, z = 38, w = 3, d = 4 }, -- galpão -> canteiro
		{ x = 22, z = 44, w = 3, d = 2 }, -- canteiro -> estrada
		{ x = 30, z = 44, w = 3, d = 2 },
		{ x = 42, z = 18, w = 3, d = 6 }, -- píer/vila -> farol
		{ x = 48, z = 10, w = 3, d = 3 }, -- base -> torre
		{ x = 50, z = 16, w = 3, d = 6 }, -- torre -> vila
		{ x = 44, z = 18, w = 6, d = 3 }, -- vila -> farol (trilha)
	},

	markers = {
		{ id = "EP01_PlayerSpawn", room = "Farol_Entrada", offset = { x = 0, z = 0 }, kind = "spawn" },
		{ id = "Farol_Entrada_Marker", room = "Farol_Entrada", offset = { x = 8, z = -6 }, kind = "objective" },
		{ id = "Doca_Pegadas", room = "Doca_Doca", offset = { x = -14, z = 6 }, kind = "clue" },
		{ id = "Doca_Contrapeso", room = "Doca_Doca", offset = { x = 18, z = -6 }, kind = "trap_part" },
		{ id = "Doca_Caixas", room = "Doca_Doca", offset = { x = 6, z = 8 }, kind = "prop" },
		{ id = "Farol_Quadro", room = "Farol_Base", offset = { x = -18, z = -20 }, kind = "clue" },
		{ id = "Farol_Escada", room = "Farol_Torre", offset = { x = 0, z = 6 }, kind = "prop" },
		{ id = "Galpao_Mesa", room = "Galpao_Barcos", offset = { x = 6, z = 8 }, kind = "clue" },
		{ id = "Galpao_Corda", room = "Galpao_Barcos", offset = { x = -8, z = 8 }, kind = "trap_part" },
		{ id = "Canteiro_Prancha", room = "Canteiro_Area", offset = { x = 12, z = 6 }, kind = "clue" },
		{ id = "Canteiro_Botas", room = "Canteiro_Area", offset = { x = -12, z = 6 }, kind = "clue" },
		{ id = "Canteiro_Elevador", room = "Canteiro_Area", offset = { x = 0, z = -8 }, kind = "prop" },
		{ id = "Porto_Anzol", room = "Porto_Loja", offset = { x = 0, z = 2 }, kind = "trap_part" },
		{ id = "Farol_TrapA", room = "Doca_Pier", offset = { x = 0, z = -6 }, kind = "trap" },
		{ id = "Farol_TrapB", room = "Farol_Base", offset = { x = 20, z = 24 }, kind = "trap" },
		{ id = "Farol_Saida", room = "Farol_Entrada", offset = { x = -8, z = 0 }, kind = "exit" },
		{ id = "EP01_Keeper", room = "Farol_Base", offset = { x = 0, z = 10 }, kind = "npc" },
		{ id = "EP01_Lucille", room = "Vila_Pousada", offset = { x = 0, z = 4 }, kind = "npc" },
		{ id = "EP01_Duarte", room = "Doca_Doca", offset = { x = 4, z = -4 }, kind = "npc" },
		{ id = "EP01_Bea", room = "Doca_Pier", offset = { x = 0, z = 12 }, kind = "npc" },
		{ id = "EP01_Suspeito_Cole", room = "Vila_Sala", offset = { x = 0, z = 4 }, kind = "npc" },
		{ id = "EP01_Suspeito_Marta", room = "Vila_Laboratorio", offset = { x = 0, z = 4 }, kind = "npc" },
		{ id = "EP01_MonsterSpawn", room = "Farol_Base", offset = { x = 0, z = -10 }, kind = "monster" },
	},

	spawns = {
		players = "EP01_PlayerSpawn",
		monster = "EP01_MonsterSpawn",
		exit = "Farol_Saida",
	},

	props = {
		{ type = "lighthouse_light", marker = "Farol_Escada", height = 22 },
		{ type = "crane", marker = "Canteiro_Elevador", rotY = 0 },
		{ type = "boat", marker = "Doca_Caixas", rotY = 90 },
		{ type = "fishing_net_pile", room = "Galpao_Barcos", offset = { x = 0, z = -6 }, rotY = 0 },
		{ type = "buoy", room = "Doca_Pier", offset = { x = 2, z = -10 }, rotY = 0 },
		{ type = "crate_stack", room = "Doca_Doca", offset = { x = -6, z = 8 }, rotY = 0 },
		{ type = "fish_crate", room = "Doca_Doca", offset = { x = 10, z = -2 }, rotY = 0 },
		{ type = "bench", room = "Doca_Pier", offset = { x = 2, z = 4 }, rotY = 0 },
		{ type = "barrel", room = "Canteiro_Area", offset = { x = -6, z = -6 }, rotY = 0 },
		{ type = "barrel", room = "Canteiro_Area", offset = { x = 6, z = -6 }, rotY = 0 },
		{ type = "scaffold", room = "Canteiro_Area", offset = { x = 0, z = 6 }, rotY = 0 },
		{ type = "desk", room = "Vila_Sala", offset = { x = -6, z = -4 }, rotY = 0 },
		{ type = "bookshelf", room = "Vila_Sala", offset = { x = 6, z = -4 }, rotY = 0 },
		{ type = "bed", room = "Vila_Pousada", offset = { x = -6, z = -4 }, rotY = 0 },
		{ type = "bed", room = "Vila_Pousada", offset = { x = 6, z = -4 }, rotY = 0 },
		{ type = "lab_bench", room = "Vila_Laboratorio", offset = { x = 0, z = -6 }, rotY = 0 },
		{ type = "aquarium", room = "Vila_Laboratorio", offset = { x = -10, z = 4 }, rotY = 0 },
		{ type = "shop_shelf", room = "Porto_Loja", offset = { x = -8, z = -4 }, rotY = 0 },
		{ type = "shop_shelf", room = "Porto_Loja", offset = { x = 8, z = -4 }, rotY = 0 },
		{ type = "anchor", room = "Porto_Loja", offset = { x = 0, z = 6 }, rotY = 0 },
	},
}

-- ==========================================================
-- EPISÓDIO 2 — HOTEL EXCELSIOR
-- ==========================================================
Locations.Maps.HotelEP2 = {
	id = "HotelEP2",
	name = "Hotel Excelsior",
	subtitle = "Art Déco de 1962, 41 quartos, 3 hóspedes e 1 fantasma",
	mood = "EP02_Hotel",
	cellSize = 8,
	width = 60,
	depth = 52,
	origin = { x = 5200, y = 0, z = 0 },
	ground = { material = "Cobblestone", color = "Panel" },

	rooms = {
		{
			id = "Hotel_Fachada",
			label = "Fachada e Jardim",
			kind = "garden",
			outdoor = true,
			x = 20,
			z = 44,
			w = 20,
			d = 6,
			floor = { material = "Cobblestone", color = "PanelLight" },
			height = 18,
			light = { color = "Warning", brightness = 1.7, count = 3 },
		},
		{
			id = "Hotel_Recepcao",
			label = "Recepção",
			kind = "hotel_lobby",
			tags = { "patrol" },
			x = 18,
			z = 30,
			w = 14,
			d = 12,
			floor = { material = "Marble", color = "Text" },
			wall = { material = "Marble", color = "Panel" },
			height = 20,
			light = { color = "Warning", brightness = 2.6, count = 4 },
		},
		{
			id = "Hotel_Salao",
			label = "Salão de Festas",
			kind = "ballroom",
			tags = { "patrol", "hotel_floor3" },
			x = 34,
			z = 28,
			w = 16,
			d = 14,
			floor = { material = "WoodPlanks", color = "ShaggyHair" },
			wall = { material = "Plaster", color = "Purple" },
			height = 22,
			light = { color = "Gold", brightness = 2.2, count = 4 },
		},
		{
			id = "Hotel_Elevador",
			label = "Elevador de Serviço",
			kind = "elevator_hall",
			tags = { "patrol" },
			x = 34,
			z = 16,
			w = 10,
			d = 10,
			floor = { material = "Metal", color = "PanelLight" },
			wall = { material = "Metal", color = "Panel" },
			height = 20,
			light = { color = "Accent", brightness = 2.3, count = 2 },
		},
		{
			id = "Hotel_Cozinha",
			label = "Cozinha",
			kind = "kitchen",
			x = 4,
			z = 30,
			w = 12,
			d = 12,
			floor = { material = "Tile", color = "Text" },
			wall = { material = "Tile", color = "MysteryTeal" },
			height = 16,
			light = { color = "Text", brightness = 2.4, count = 3 },
		},
		{
			id = "Hotel_Deposito",
			label = "Depósito de Porcelana",
			kind = "storage",
			x = 4,
			z = 16,
			w = 12,
			d = 12,
			floor = { material = "Concrete", color = "Panel" },
			wall = { material = "Brick", color = "Scooby" },
			height = 15,
			light = { color = "Warning", brightness = 1.7, count = 2 },
		},
		{
			id = "Hotel_Corredor2",
			label = "Corredor do 2º Andar",
			kind = "hotel_corridor",
			tags = { "patrol" },
			x = 18,
			z = 16,
			w = 16,
			d = 4,
			floor = { material = "Carpet", color = "Danger" },
			wall = { material = "Plaster", color = "Danger" },
			height = 15,
			light = { color = "Warning", brightness = 2, count = 4 },
		},
		{
			id = "Hotel_Quarto201",
			label = "Quarto 201",
			kind = "hotel_room",
			x = 18,
			z = 4,
			w = 10,
			d = 10,
			floor = { material = "Carpet", color = "MysteryBlue" },
			wall = { material = "Plaster", color = "PanelLight" },
			height = 15,
			light = { color = "Warning", brightness = 1.9, count = 2 },
		},
		{
			id = "Hotel_Corredor3",
			label = "Corredor do 3º Andar (Interditado)",
			kind = "hotel_corridor",
			tags = { "patrol", "hotel_floor3" },
			x = 32,
			z = 4,
			w = 24,
			d = 4,
			floor = { material = "Carpet", color = "DeepPurple" },
			wall = { material = "Plaster", color = "Purple" },
			height = 15,
			light = { color = "Purple", brightness = 1.6, count = 5 },
		},
		{
			id = "Hotel_Suite",
			label = "Suíte 302",
			kind = "hotel_suite",
			tags = { "patrol", "hotel_floor3" },
			x = 32,
			z = 10,
			w = 14,
			d = 10,
			floor = { material = "Carpet", color = "DeepPurple" },
			wall = { material = "Plaster", color = "Purple" },
			height = 17,
			light = { color = "Purple", brightness = 1.9, count = 3 },
		},
		{
			id = "Hotel_Conessa",
			label = "Suíte da Condessa",
			kind = "hotel_suite",
			x = 48,
			z = 10,
			w = 10,
			d = 10,
			floor = { material = "Carpet", color = "Purple" },
			wall = { material = "Plaster", color = "Gold" },
			height = 16,
			light = { color = "Gold", brightness = 2.2, count = 3 },
		},
		{
			id = "Hotel_Duto",
			label = "Duto de Serviço",
			kind = "duct",
			x = 50,
			z = 4,
			w = 6,
			d = 6,
			floor = { material = "Metal", color = "Panel" },
			wall = { material = "Metal", color = "PanelLight" },
			height = 10,
			light = { color = "Accent", brightness = 1.2, count = 1 },
		},
		{
			id = "Hotel_Ginasio",
			label = "Ginásio Antigo",
			kind = "gym",
			x = 46,
			z = 28,
			w = 12,
			d = 12,
			floor = { material = "WoodPlanks", color = "ShaggyHair" },
			wall = { material = "WoodPlanks", color = "Scooby" },
			height = 20,
			light = { color = "Warning", brightness = 1.8, count = 3 },
		},
		{
			id = "Hotel_Porao",
			label = "Porao e Cabos",
			kind = "basement",
			x = 4,
			z = 44,
			w = 14,
			d = 6,
			floor = { material = "Concrete", color = "Night" },
			wall = { material = "Concrete", color = "Panel" },
			height = 14,
			light = { color = "Warning", brightness = 1.3, count = 2 },
		},
	},

	corridors = {
		{ x = 30, z = 42, w = 4, d = 4 }, -- fachada -> recepção
		{ x = 32, z = 24, w = 4, d = 8 }, -- recepção -> elevador
		{ x = 16, z = 26, w = 4, d = 10 }, -- recepção -> corredor 2
		{ x = 16, z = 32, w = 4, d = 4 }, -- corredor 2 -> cozinha
		{ x = 16, z = 18, w = 4, d = 4 }, -- corredor 2 -> depósito
		{ x = 22, z = 12, w = 4, d = 10 }, -- quarto 201 -> corredor 2
		{ x = 32, z = 20, w = 4, d = 4 }, -- elevador -> corredor3
		{ x = 28, z = 6, w = 6, d = 3 }, -- corredor3 -> quarto 201 (escada)
		{ x = 44, z = 12, w = 6, d = 4 }, -- corredor3 -> suíte 302
		{ x = 46, z = 12, w = 4, d = 2 }, -- suíte 302 -> condessa
		{ x = 50, z = 6, w = 3, d = 3 }, -- corredor3 -> duto
		{ x = 40, z = 26, w = 4, d = 6 }, -- elevador -> salão
		{ x = 28, z = 34, w = 8, d = 3 }, -- recepção -> salão
		{ x = 44, z = 32, w = 4, d = 4 }, -- salão -> ginásio
		{ x = 8, z = 28, w = 6, d = 4 }, -- painel hidráulico -> cozinha
		{ x = 8, z = 40, w = 4, d = 6 }, -- cozinha -> porão
	},

	markers = {
		{ id = "EP02_PlayerSpawn", room = "Hotel_Fachada", offset = { x = 0, z = 0 }, kind = "spawn" },
		{ id = "Hotel_Piano", room = "Hotel_Salao", offset = { x = -12, z = -8 }, kind = "clue" },
		{ id = "Hotel_Teto_Salao", room = "Hotel_Salao", offset = { x = -12, z = 2 }, kind = "clue" },
		{ id = "Hotel_Cozinha_Mesa", room = "Hotel_Cozinha", offset = { x = 0, z = -6 }, kind = "prop" },
		{ id = "Hotel_Registro", room = "Hotel_Recepcao", offset = { x = 6, z = -12 }, kind = "clue" },
		{ id = "Hotel_Deposito_Marker", room = "Hotel_Deposito", offset = { x = 0, z = -4 }, kind = "clue" },
		{ id = "Hotel_Duto_Marker", room = "Hotel_Duto", offset = { x = 0, z = 0 }, kind = "clue" },
		{ id = "Hotel_Cabos", room = "Hotel_Porao", offset = { x = -8, z = 0 }, kind = "trap_part" },
		{ id = "Hotel_Ginasio_Marker", room = "Hotel_Ginasio", offset = { x = 0, z = -6 }, kind = "trap_part" },
		{ id = "Hotel_Salao_Marker", room = "Hotel_Salao", offset = { x = 12, z = -8 }, kind = "trap_part" },
		{ id = "Hotel_TrapA", room = "Hotel_Elevador", offset = { x = 0, z = 0 }, kind = "trap" },
		{ id = "Hotel_TrapB", room = "Hotel_Corredor3", offset = { x = -10, z = 0 }, kind = "trap" },
		{ id = "Hotel_Saida", room = "Hotel_Fachada", offset = { x = -12, z = 0 }, kind = "exit" },
		{ id = "EP02_Gerente", room = "Hotel_Recepcao", offset = { x = 0, z = 8 }, kind = "npc" },
		{ id = "EP02_Mucama", room = "Hotel_Corredor2", offset = { x = -12, z = 0 }, kind = "npc" },
		{ id = "EP02_Pianista", room = "Hotel_Salao", offset = { x = -4, z = -10 }, kind = "npc" },
		{ id = "EP02_Convidada", room = "Hotel_Conessa", offset = { x = 0, z = 0 }, kind = "npc" },
		{ id = "EP02_Bellboy", room = "Hotel_Recepcao", offset = { x = -10, z = 6 }, kind = "npc" },
		{ id = "EP02_MonsterSpawn", room = "Hotel_Suite", offset = { x = 0, z = 0 }, kind = "monster" },
	},

	spawns = {
		players = "EP02_PlayerSpawn",
		monster = "EP02_MonsterSpawn",
		exit = "Hotel_Saida",
	},

	props = {
		{ type = "grand_piano", marker = "Hotel_Piano", rotY = 90 },
		{ type = "reception_counter", marker = "Hotel_Registro", rotY = 180 },
		{ type = "chandelier", marker = "Hotel_Teto_Salao", height = 12 },
		{ type = "service_elevator", marker = "Hotel_TrapA", rotY = 0 },
		{ type = "kitchen_counter", marker = "Hotel_Cozinha_Mesa", rotY = 0 },
		{ type = "shelf_porcelain", marker = "Hotel_Deposito_Marker", rotY = 0 },
		{ type = "duct_pipe", marker = "Hotel_Duto_Marker", rotY = 0 },
		{ type = "weight_rack", marker = "Hotel_Ginasio_Marker", rotY = 0 },
		{ type = "curtain", room = "Hotel_Salao", offset = { x = 12, z = 10 }, rotY = 0 },
		{ type = "curtain", room = "Hotel_Salao", offset = { x = -12, z = 10 }, rotY = 0 },
		{ type = "round_table", room = "Hotel_Salao", offset = { x = 4, z = -4 }, rotY = 0 },
		{ type = "round_table", room = "Hotel_Salao", offset = { x = 4, z = 4 }, rotY = 0 },
		{ type = "bed", room = "Hotel_Quarto201", offset = { x = 0, z = -4 }, rotY = 0 },
		{ type = "bed", room = "Hotel_Suite", offset = { x = -8, z = -2 }, rotY = 0 },
		{ type = "vanity", room = "Hotel_Suite", offset = { x = 8, z = -4 }, rotY = 0 },
		{ type = "armoire", room = "Hotel_Suite", offset = { x = 0, z = 6 }, rotY = 0 },
		{ type = "jewel_case", room = "Hotel_Conessa", offset = { x = 0, z = -4 }, rotY = 0 },
		{ type = "sofa", room = "Hotel_Recepcao", offset = { x = -10, z = -10 }, rotY = 0 },
		{ type = "plant", room = "Hotel_Recepcao", offset = { x = 12, z = -12 }, rotY = 0 },
		{ type = "luggage_cart", room = "Hotel_Recepcao", offset = { x = 12, z = 6 }, rotY = 0 },
		{ type = "mirror_wall", room = "Hotel_Corredor3", offset = { x = 4, z = -2 }, rotY = 0 },
		{ type = "mirror_wall", room = "Hotel_Corredor3", offset = { x = 16, z = -2 }, rotY = 0 },
		{ type = "gaslight", room = "Hotel_Corredor2", offset = { x = 0, z = -2 }, rotY = 0 },
		{ type = "staircase", room = "Hotel_Elevador", offset = { x = -8, z = 8 }, rotY = 0 },
	},

	-- Rotas do elevador de serviço (usadas pelo monstro "phase" quando ele reaparece)
	links = {
		{ id = "Hotel_Elevador_Link", from = "Hotel_Elevador", to = "Hotel_Suite", cost = 4 },
	},
}

-- ==========================================================
-- EPISÓDIO 3 — CIRCO ROMANELLI
-- ==========================================================
Locations.Maps.CircoEP3 = {
	id = "CircoEP3",
	name = "Circo Romanelli",
	subtitle = "40 anos na estrada, uma tenda e um riso de mentira",
	mood = "EP03_Circo",
	cellSize = 8,
	width = 64,
	depth = 56,
	origin = { x = 7800, y = 0, z = 0 },
	ground = { material = "Grass", color = "MysteryGreen" },

	rooms = {
		{
			id = "Circo_Portao",
			label = "Portão de Entrada",
			kind = "circus_gate",
			outdoor = true,
			x = 24,
			z = 44,
			w = 12,
			d = 8,
			floor = { material = "Gravel", color = "PanelLight" },
			height = 18,
			light = { color = "Warning", brightness = 2.2, count = 4 },
		},
		{
			id = "Circo_Bilheteria",
			label = "Bilheteria",
			kind = "ticket_office",
			x = 38,
			z = 44,
			w = 8,
			d = 8,
			floor = { material = "WoodPlanks", color = "Danger" },
			wall = { material = "WoodPlanks", color = "Danger" },
			height = 13,
			light = { color = "Warning", brightness = 2, count = 2 },
		},
		{
			id = "Circo_Picadeiro",
			label = "Picadeiro Central",
			kind = "circus_ring",
			tags = { "patrol", "circus_ring" },
			x = 22,
			z = 20,
			w = 20,
			d = 20,
			floor = { material = "Fabric", color = "Gold" },
			wall = { material = "Fabric", color = "Danger" },
			height = 30,
			light = { color = "Gold", brightness = 2.8, count = 6 },
		},
		{
			id = "Circo_Arquibancada",
			label = "Arquibancada",
			kind = "bleachers",
			tags = { "patrol" },
			x = 44,
			z = 20,
			w = 14,
			d = 20,
			floor = { material = "WoodPlanks", color = "Scooby" },
			wall = { material = "Fabric", color = "MysteryBlue" },
			height = 22,
			light = { color = "Warning", brightness = 2, count = 4 },
		},
		{
			id = "Circo_Camarim",
			label = "Camarins",
			kind = "dressing_room",
			x = 6,
			z = 20,
			w = 12,
			d = 12,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "WoodPlanks", color = "Daphne" },
			height = 15,
			light = { color = "Warning", brightness = 2.2, count = 3 },
		},
		{
			id = "Circo_Jaulas",
			label = "Jaulas e Animais",
			kind = "cages",
			tags = { "patrol" },
			x = 6,
			z = 34,
			w = 14,
			d = 12,
			floor = { material = "Gravel", color = "Panel" },
			wall = { material = "Metal", color = "Metal" },
			height = 16,
			light = { color = "Warning", brightness = 1.7, count = 3 },
		},
		{
			id = "Circo_Escritorio",
			label = "Escritório do Dono",
			kind = "circus_office",
			x = 6,
			z = 4,
			w = 12,
			d = 12,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "WoodPlanks", color = "Gold" },
			height = 15,
			light = { color = "Gold", brightness = 2.2, count = 3 },
		},
		{
			id = "Circo_Deposito",
			label = "Depósito de Cenários",
			kind = "storage",
			x = 22,
			z = 4,
			w = 14,
			d = 12,
			floor = { material = "Concrete", color = "Panel" },
			wall = { material = "CorrugatedMetal", color = "MysteryBlue" },
			height = 18,
			light = { color = "Warning", brightness = 1.6, count = 3 },
		},
		{
			id = "Circo_Cabine_Som",
			label = "Cabine de Som",
			kind = "sound_booth",
			x = 40,
			z = 4,
			w = 10,
			d = 10,
			floor = { material = "Concrete", color = "Night" },
			wall = { material = "WoodPlanks", color = "Night" },
			height = 13,
			light = { color = "Accent", brightness = 1.9, count = 2 },
		},
		{
			id = "Circo_Trapezio",
			label = "Passarela do Trapézio",
			kind = "trapeze_rig",
			tags = { "patrol", "circus_ring" },
			x = 52,
			z = 20,
			w = 8,
			d = 20,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "Fabric", color = "Purple" },
			height = 34,
			light = { color = "Accent", brightness = 2.4, count = 3 },
		},
		{
			id = "Circo_Lanchonete",
			label = "Barraca de Pipoca",
			kind = "food_stand",
			outdoor = true,
			x = 40,
			z = 34,
			w = 10,
			d = 10,
			floor = { material = "Gravel", color = "Gold" },
			height = 16,
			light = { color = "Warning", brightness = 2.4, count = 3 },
		},
	},

	corridors = {
		{ x = 28, z = 40, w = 4, d = 6 }, -- portão -> picadeiro
		{ x = 34, z = 46, w = 4, d = 2 }, -- portão -> bilheteria
		{ x = 16, z = 46, w = 10, d = 4 }, -- portão -> lanchonete
		{ x = 18, z = 30, w = 6, d = 4 }, -- picadeiro -> camarins
		{ x = 18, z = 24, w = 4, d = 6 }, -- camarins -> picadeiro
		{ x = 18, z = 38, w = 4, d = 4 }, -- camarins -> jaulas
		{ x = 18, z = 8, w = 4, d = 14 }, -- escritório -> depósito -> picadeiro
		{ x = 36, z = 8, w = 6, d = 4 }, -- depósito -> cabine de som
		{ x = 40, z = 12, w = 4, d = 10 }, -- cabine -> picadeiro
		{ x = 42, z = 28, w = 4, d = 4 }, -- picadeiro -> arquibancada
		{ x = 52, z = 28, w = 3, d = 4 }, -- arquibancada -> trapézio
		{ x = 52, z = 12, w = 3, d = 4 }, -- trapézio -> cabine
		{ x = 44, z = 38, w = 4, d = 4 }, -- lanchonete -> arquibancada
	},

	markers = {
		{ id = "EP03_PlayerSpawn", room = "Circo_Portao", offset = { x = 0, z = 0 }, kind = "spawn" },
		{ id = "Circo_Confete", room = "Circo_Picadeiro", offset = { x = 0, z = 0 }, kind = "clue" },
		{ id = "Circo_Pegadas", room = "Circo_Picadeiro", offset = { x = -14, z = -14 }, kind = "clue" },
		{ id = "Circo_Som", room = "Circo_Cabine_Som", offset = { x = 0, z = 0 }, kind = "clue" },
		{ id = "Circo_Escala", room = "Circo_Escritorio", offset = { x = 0, z = -4 }, kind = "clue" },
		{ id = "Circo_Lona", room = "Circo_Picadeiro", offset = { x = 14, z = 14 }, kind = "clue" },
		{ id = "Circo_Camarim_Marker", room = "Circo_Camarim", offset = { x = 0, z = 4 }, kind = "clue" },
		{ id = "Circo_Rede", room = "Circo_Trapezio", offset = { x = 0, z = -12 }, kind = "trap_part" },
		{ id = "Circo_Contrapeso", room = "Circo_Jaulas", offset = { x = 0, z = -6 }, kind = "trap_part" },
		{ id = "Circo_Corda", room = "Circo_Deposito", offset = { x = 0, z = 0 }, kind = "trap_part" },
		{ id = "Circo_TrapA", room = "Circo_Picadeiro", offset = { x = 0, z = -6 }, kind = "trap" },
		{ id = "Circo_TrapB", room = "Circo_Jaulas", offset = { x = 6, z = 4 }, kind = "trap" },
		{ id = "Circo_Saida", room = "Circo_Portao", offset = { x = -14, z = 0 }, kind = "exit" },
		{ id = "EP03_Dono", room = "Circo_Escritorio", offset = { x = 0, z = 6 }, kind = "npc" },
		{ id = "EP03_Trapezista", room = "Circo_Camarim", offset = { x = -6, z = 6 }, kind = "npc" },
		{ id = "EP03_PalhacoTriste", room = "Circo_Camarim", offset = { x = 6, z = -6 }, kind = "npc" },
		{ id = "EP03_Feirante", room = "Circo_Lanchonete", offset = { x = 0, z = 0 }, kind = "npc" },
		{ id = "EP03_MonsterSpawn", room = "Circo_Deposito", offset = { x = 0, z = -8 }, kind = "monster" },
	},

	spawns = {
		players = "EP03_PlayerSpawn",
		monster = "EP03_MonsterSpawn",
		exit = "Circo_Saida",
	},

	props = {
		{ type = "audio_console", marker = "Circo_Som", rotY = 180 },
		{ type = "trapeze", marker = "Circo_Rede", height = 26 },
		{ type = "circus_ring_prop", room = "Circo_Picadeiro", offset = { x = 0, z = 0 }, rotY = 0 },
		{ type = "bleacher", room = "Circo_Arquibancada", offset = { x = -8, z = -12 }, rotY = 90 },
		{ type = "bleacher", room = "Circo_Arquibancada", offset = { x = -8, z = -4 }, rotY = 90 },
		{ type = "bleacher", room = "Circo_Arquibancada", offset = { x = -8, z = 4 }, rotY = 90 },
		{ type = "bleacher", room = "Circo_Arquibancada", offset = { x = -8, z = 12 }, rotY = 90 },
		{ type = "cage", room = "Circo_Jaulas", offset = { x = -12, z = -8 }, rotY = 0 },
		{ type = "cage", room = "Circo_Jaulas", offset = { x = -12, z = 6 }, rotY = 0 },
		{ type = "cage", room = "Circo_Jaulas", offset = { x = 12, z = -8 }, rotY = 0 },
		{ type = "costume_rack", room = "Circo_Camarim", offset = { x = -8, z = -6 }, rotY = 0 },
		{ type = "vanity", room = "Circo_Camarim", offset = { x = 8, z = -6 }, rotY = 0 },
		{ type = "stilts", room = "Circo_Camarim", offset = { x = 0, z = -8 }, rotY = 0 },
		{ type = "popcorn_machine", room = "Circo_Lanchonete", offset = { x = 0, z = -6 }, rotY = 0 },
		{ type = "cannon", room = "Circo_Deposito", offset = { x = 8, z = 6 }, rotY = 0 },
		{ type = "barrel", room = "Circo_Deposito", offset = { x = -8, z = 6 }, rotY = 0 },
		{ type = "desk", room = "Circo_Escritorio", offset = { x = 0, z = -6 }, rotY = 0 },
		{ type = "safe", room = "Circo_Escritorio", offset = { x = 8, z = 6 }, rotY = 0 },
		{ type = "clown_car", room = "Circo_Picadeiro", offset = { x = 16, z = 16 }, rotY = 45 },
		{ type = "concession_stand", room = "Circo_Bilheteria", offset = { x = 0, z = 0 }, rotY = 0 },
		{ type = "string_lights", room = "Circo_Portao", offset = { x = 0, z = 0 }, rotY = 0, height = 10 },
	},
}

-- ==========================================================
-- EPISÓDIO 4 — FÁBRICA KRAFT
-- ==========================================================
Locations.Maps.FabricaEP4 = {
	id = "FabricaEP4",
	name = "Fábrica Kraft",
	subtitle = "Zona Industrial — Linha 4",
	mood = "EP04_Fabrica",
	cellSize = 8,
	width = 64,
	depth = 56,
	origin = { x = 10400, y = 0, z = 0 },
	ground = { material = "Asphalt", color = "Panel" },

	rooms = {
		{
			id = "Fabrica_Patio",
			label = "Pátio de Carga (cerca)",
			kind = "loading_yard",
			outdoor = true,
			x = 24,
			z = 44,
			w = 18,
			d = 8,
			floor = { material = "Asphalt", color = "Panel" },
			height = 20,
			light = { color = "Warning", brightness = 2, count = 4 },
		},
		{
			id = "Fabrica_Linha4",
			label = "Linha de Montagem 4",
			kind = "factory_floor",
			tags = { "patrol", "factory_floor" },
			x = 20,
			z = 22,
			w = 24,
			d = 20,
			floor = { material = "Concrete", color = "PanelLight" },
			wall = { material = "DiamondPlate", color = "Panel" },
			height = 26,
			light = { color = "Warning", brightness = 2.2, count = 6 },
		},
		{
			id = "Fabrica_Prensa",
			label = "Prensa Hidráulica",
			kind = "press_hall",
			tags = { "patrol" },
			x = 46,
			z = 22,
			w = 14,
			d = 14,
			floor = { material = "Metal", color = "Panel" },
			wall = { material = "CorrodedMetal", color = "Scooby" },
			height = 24,
			light = { color = "Warning", brightness = 1.9, count = 4 },
		},
		{
			id = "Fabrica_SalaControle",
			label = "Sala de Controle",
			kind = "control_room",
			tags = { "patrol" },
			x = 24,
			z = 6,
			w = 14,
			d = 12,
			floor = { material = "Metal", color = "PanelLight" },
			wall = { material = "Metal", color = "MysteryTeal" },
			height = 16,
			light = { color = "Accent", brightness = 2.4, count = 3 },
		},
		{
			id = "Fabrica_Vestiario",
			label = "Vestiário",
			kind = "locker_room",
			x = 4,
			z = 6,
			w = 14,
			d = 12,
			floor = { material = "Tile", color = "Text" },
			wall = { material = "Tile", color = "PanelLight" },
			height = 15,
			light = { color = "Text", brightness = 2.3, count = 3 },
		},
		{
			id = "Fabrica_Painel",
			label = "Painel Elétrico",
			kind = "power_room",
			x = 6,
			z = 22,
			w = 12,
			d = 12,
			floor = { material = "Concrete", color = "Night" },
			wall = { material = "Concrete", color = "Panel" },
			height = 16,
			light = { color = "Warning", brightness = 1.6, count = 3 },
		},
		{
			id = "Fabrica_Cantina",
			label = "Cantina da Dona Cida",
			kind = "canteen",
			x = 6,
			z = 36,
			w = 14,
			d = 12,
			floor = { material = "Tile", color = "Text" },
			wall = { material = "Tile", color = "Gold" },
			height = 15,
			light = { color = "Warning", brightness = 2.5, count = 3 },
		},
		{
			id = "Fabrica_Almox",
			label = "Almoxarifado",
			kind = "warehouse",
			x = 46,
			z = 6,
			w = 14,
			d = 14,
			floor = { material = "Concrete", color = "Panel" },
			wall = { material = "CorrugatedMetal", color = "PanelLight" },
			height = 20,
			light = { color = "Warning", brightness = 1.7, count = 4 },
		},
		{
			id = "Fabrica_Armario",
			label = "Armários do Pessoal",
			kind = "locker_room",
			x = 24,
			z = 36,
			w = 12,
			d = 10,
			floor = { material = "Tile", color = "Text" },
			wall = { material = "Tile", color = "MysteryBlue" },
			height = 15,
			light = { color = "Text", brightness = 2.2, count = 2 },
		},
		{
			id = "Fabrica_Escritorio",
			label = "Escritório de Produção",
			kind = "office",
			x = 48,
			z = 38,
			w = 12,
			d = 10,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "Plaster", color = "PanelLight" },
			height = 15,
			light = { color = "Warning", brightness = 2.3, count = 3 },
		},
		{
			id = "Fabrica_Tunel",
			label = "Túnel de Serviço",
			kind = "service_tunnel",
			tags = { "patrol" },
			x = 38,
			z = 6,
			w = 6,
			d = 14,
			floor = { material = "Concrete", color = "Night" },
			wall = { material = "Concrete", color = "Panel" },
			height = 12,
			light = { color = "Warning", brightness = 1.2, count = 3 },
		},
	},

	corridors = {
		{ x = 30, z = 40, w = 6, d = 6 }, -- pátio -> linha 4
		{ x = 44, z = 30, w = 4, d = 4 }, -- linha 4 -> prensa
		{ x = 24, z = 16, w = 4, d = 8 }, -- linha 4 -> sala de controle
		{ x = 16, z = 26, w = 6, d = 4 }, -- linha 4 -> painel
		{ x = 16, z = 10, w = 10, d = 4 }, -- vestiário -> painel
		{ x = 18, z = 30, w = 4, d = 4 }, -- painel -> cantina
		{ x = 18, z = 40, w = 8, d = 4 }, -- cantina -> armários
		{ x = 34, z = 40, w = 6, d = 4 }, -- armários -> escritório
		{ x = 44, z = 42, w = 4, d = 4 }, -- escritório -> pátio
		{ x = 44, z = 14, w = 4, d = 10 }, -- almox -> prensa
		{ x = 38, z = 12, w = 4, d = 10 }, -- tunel -> linha 4
		{ x = 40, z = 4, w = 6, d = 4 }, -- tunel -> sala de controle
	},

	markers = {
		{ id = "EP04_PlayerSpawn", room = "Fabrica_Patio", offset = { x = 0, z = 0 }, kind = "spawn" },
		{ id = "Fabrica_Pegadas", room = "Fabrica_Linha4", offset = { x = 0, z = 0 }, kind = "clue" },
		{ id = "Fabrica_Painel_Marker", room = "Fabrica_Painel", offset = { x = 0, z = -4 }, kind = "clue" },
		{ id = "Fabrica_SalaControle_Marker", room = "Fabrica_SalaControle", offset = { x = 0, z = 0 }, kind = "clue" },
		{ id = "Fabrica_Cracha", room = "Fabrica_Linha4", offset = { x = -18, z = 14 }, kind = "clue" },
		{ id = "Fabrica_Almox_Marker", room = "Fabrica_Almox", offset = { x = 0, z = -6 }, kind = "clue" },
		{ id = "Fabrica_Armario_Marker", room = "Fabrica_Armario", offset = { x = 0, z = -4 }, kind = "clue" },
		{ id = "Fabrica_Cabo", room = "Fabrica_Almox", offset = { x = -10, z = 6 }, kind = "trap_part" },
		{ id = "Fabrica_Roletes", room = "Fabrica_Linha4", offset = { x = 16, z = -10 }, kind = "trap_part" },
		{ id = "Fabrica_Grade", room = "Fabrica_Prensa", offset = { x = 0, z = -6 }, kind = "trap_part" },
		{ id = "Fabrica_TrapA", room = "Fabrica_Linha4", offset = { x = 0, z = -6 }, kind = "trap" },
		{ id = "Fabrica_TrapB", room = "Fabrica_Prensa", offset = { x = 0, z = 6 }, kind = "trap" },
		{ id = "Fabrica_Saida", room = "Fabrica_Patio", offset = { x = -14, z = 0 }, kind = "exit" },
		{ id = "EP04_Engenheira", room = "Fabrica_SalaControle", offset = { x = 0, z = -4 }, kind = "npc" },
		{ id = "EP04_Seguranca", room = "Fabrica_Vestiario", offset = { x = 0, z = 4 }, kind = "npc" },
		{ id = "EP04_Estagiario", room = "Fabrica_Painel", offset = { x = 0, z = 4 }, kind = "npc" },
		{ id = "EP04_Dona", room = "Fabrica_Cantina", offset = { x = 0, z = 0 }, kind = "npc" },
		{ id = "EP04_MonsterSpawn", room = "Fabrica_Linha4", offset = { x = 0, z = 18 }, kind = "monster" },
	},

	spawns = {
		players = "EP04_PlayerSpawn",
		monster = "EP04_MonsterSpawn",
		exit = "Fabrica_Saida",
	},

	props = {
		{ type = "conveyor", marker = "Fabrica_Pegadas", rotY = 0 },
		{ type = "control_desk", marker = "Fabrica_SalaControle_Marker", rotY = 180 },
		{ type = "breaker_panel", marker = "Fabrica_Painel_Marker", rotY = 0 },
		{ type = "locker", room = "Fabrica_Vestiario", offset = { x = -8, z = -6 }, rotY = 0 },
		{ type = "locker", room = "Fabrica_Vestiario", offset = { x = 8, z = -6 }, rotY = 0 },
		{ type = "bench", room = "Fabrica_Vestiario", offset = { x = 0, z = 0 }, rotY = 0 },
		{ type = "press_machine", room = "Fabrica_Prensa", offset = { x = 0, z = 0 }, rotY = 0 },
		{ type = "crane_hook", room = "Fabrica_Linha4", offset = { x = 16, z = 10 }, rotY = 0, height = 18 },
		{ type = "barrel", room = "Fabrica_Linha4", offset = { x = -10, z = 14 }, rotY = 0 },
		{ type = "barrel", room = "Fabrica_Linha4", offset = { x = -6, z = 14 }, rotY = 0 },
		{ type = "pallet", room = "Fabrica_Almox", offset = { x = -10, z = -2 }, rotY = 0 },
		{ type = "pallet", room = "Fabrica_Almox", offset = { x = 10, z = 2 }, rotY = 0 },
		{ type = "canteen_table", room = "Fabrica_Cantina", offset = { x = -6, z = 4 }, rotY = 0 },
		{ type = "canteen_table", room = "Fabrica_Cantina", offset = { x = 6, z = 4 }, rotY = 0 },
		{ type = "coffee_machine", room = "Fabrica_Cantina", offset = { x = 0, z = -8 }, rotY = 0 },
		{ type = "desk", room = "Fabrica_Escritorio", offset = { x = 0, z = -4 }, rotY = 0 },
		{ type = "filing_cabinet", room = "Fabrica_Escritorio", offset = { x = -8, z = 4 }, rotY = 0 },
		{ type = "filing_cabinet", room = "Fabrica_Escritorio", offset = { x = 8, z = 4 }, rotY = 0 },
		{ type = "pipe_run", room = "Fabrica_Tunel", offset = { x = 0, z = 0 }, rotY = 90 },
		{ type = "generator", room = "Fabrica_Painel", offset = { x = 8, z = 8 }, rotY = 0 },
		{ type = "forklift", room = "Fabrica_Patio", offset = { x = 10, z = 4 }, rotY = 30 },
		{ type = "fence", room = "Fabrica_Patio", offset = { x = 0, z = -8 }, rotY = 0 },
	},
}

-- ==========================================================
-- EPISÓDIO 5 — ESTRADA DO KM 13
-- ==========================================================
Locations.Maps.EstradaEP5 = {
	id = "EstradaEP5",
	name = "Estrada do KM 13",
	subtitle = "Neblina, asfalto velho e um cavaleiro sem cabeça",
	mood = "EP05_Estrada",
	cellSize = 8,
	width = 64,
	depth = 60,
	origin = { x = 13000, y = 0, z = 0 },
	ground = { material = "Grass", color = "MysteryGreen" },

	rooms = {
		{
			id = "Estrada_Curva",
			label = "Curva do KM 13",
			kind = "road_curve",
			outdoor = true,
			tags = { "patrol", "road" },
			x = 22,
			z = 24,
			w = 20,
			d = 12,
			floor = { material = "Asphalt", color = "Night" },
			height = 24,
			light = { color = "Warning", brightness = 1.5, count = 4 },
		},
		{
			id = "Estrada_Retas",
			label = "Reta da Neblina",
			kind = "road_straight",
			outdoor = true,
			tags = { "patrol", "road" },
			x = 22,
			z = 38,
			w = 10,
			d = 18,
			floor = { material = "Asphalt", color = "Night" },
			height = 22,
			light = { color = "Warning", brightness = 1.3, count = 3 },
		},
		{
			id = "Estrada_Posto",
			label = "Posto da Zulmira",
			kind = "gas_station",
			tags = { "patrol" },
			x = 40,
			z = 36,
			w = 14,
			d = 12,
			floor = { material = "Concrete", color = "PanelLight" },
			wall = { material = "CorrugatedMetal", color = "MysteryBlue" },
			height = 18,
			light = { color = "Warning", brightness = 2.4, count = 4 },
		},
		{
			id = "Estrada_Lanchonete",
			label = "Lanchonete do Bigode",
			kind = "diner",
			x = 6,
			z = 38,
			w = 14,
			d = 12,
			floor = { material = "Tile", color = "Text" },
			wall = { material = "Plaster", color = "Danger" },
			height = 16,
			light = { color = "Warning", brightness = 2.5, count = 4 },
		},
		{
			id = "Estrada_Ponte",
			label = "Ponte de Madeira",
			kind = "old_bridge",
			outdoor = true,
			tags = { "patrol" },
			x = 24,
			z = 4,
			w = 12,
			d = 10,
			floor = { material = "WoodPlanks", color = "Scooby" },
			height = 20,
			light = { color = "Warning", brightness = 1.2, count = 2 },
		},
		{
			id = "Estrada_Celeiro",
			label = "Celeiro do Seu Otávio",
			kind = "barn",
			tags = { "patrol", "farm" },
			x = 44,
			z = 6,
			w = 16,
			d = 14,
			floor = { material = "WoodPlanks", color = "ShaggyHair" },
			wall = { material = "WoodPlanks", color = "Scooby" },
			height = 24,
			light = { color = "Warning", brightness = 1.8, count = 4 },
		},
		{
			id = "Estrada_Fazenda",
			label = "Casa da Fazenda",
			kind = "farmhouse",
			x = 24,
			z = 6,
			w = 14,
			d = 12,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "WoodPlanks", color = "MysteryOrange" },
			height = 16,
			light = { color = "Warning", brightness = 2.2, count = 3 },
		},
		{
			id = "Estrada_Placa",
			label = "Canteiro da Obra da Rodovia",
			kind = "construction",
			outdoor = true,
			x = 4,
			z = 22,
			w = 14,
			d = 12,
			floor = { material = "Gravel", color = "PanelLight" },
			height = 20,
			light = { color = "Warning", brightness = 2, count = 3 },
		},
		{
			id = "Estrada_Bosque",
			label = "Bosque Nebuloso",
			kind = "forest",
			outdoor = true,
			tags = { "patrol" },
			x = 6,
			z = 6,
			w = 14,
			d = 12,
			floor = { material = "Grass", color = "MysteryGreen" },
			height = 26,
			light = { color = "Text", brightness = 0.9, count = 2 },
		},
	},

	corridors = {
		{ x = 26, z = 34, w = 4, d = 6 }, -- reta -> curva
		{ x = 30, z = 30, w = 12, d = 4 }, -- curva -> posto
		{ x = 18, z = 30, w = 6, d = 4 }, -- curva -> lanchonete
		{ x = 28, z = 16, w = 4, d = 8 }, -- curva -> ponte
		{ x = 36, z = 12, w = 8, d = 4 }, -- ponte -> celeiro
		{ x = 26, z = 18, w = 4, d = 8 }, -- ponte -> fazenda
		{ x = 34, z = 12, w = 4, d = 6 }, -- fazenda -> celeiro
		{ x = 18, z = 26, w = 4, d = 4 }, -- curva -> obra
		{ x = 18, z = 16, w = 4, d = 6 }, -- obra -> bosque
		{ x = 12, z = 18, w = 4, d = 6 }, -- bosque -> lanchonete
		{ x = 20, z = 40, w = 4, d = 4 }, -- lanchonete -> reta
	},

	markers = {
		{ id = "EP05_PlayerSpawn", room = "Estrada_Retas", offset = { x = 0, z = 0 }, kind = "spawn" },
		{ id = "Estrada_Casco", room = "Estrada_Curva", offset = { x = 0, z = 0 }, kind = "clue" },
		{ id = "Estrada_Poste", room = "Estrada_Retas", offset = { x = 4, z = 10 }, kind = "clue" },
		{ id = "Estrada_Celeiro_Marker", room = "Estrada_Celeiro", offset = { x = 0, z = 0 }, kind = "clue" },
		{ id = "Estrada_Placa_Marker", room = "Estrada_Placa", offset = { x = 0, z = -4 }, kind = "clue" },
		{ id = "Estrada_Notas", room = "Estrada_Posto", offset = { x = 0, z = -6 }, kind = "clue" },
		{ id = "Estrada_Gravador", room = "Estrada_Lanchonete", offset = { x = 0, z = -6 }, kind = "clue" },
		{ id = "Estrada_Guincho", room = "Estrada_Posto", offset = { x = 10, z = 6 }, kind = "trap_part" },
		{ id = "Estrada_Lona", room = "Estrada_Lanchonete", offset = { x = -10, z = 6 }, kind = "trap_part" },
		{ id = "Estrada_Tabuas", room = "Estrada_Ponte", offset = { x = 0, z = 0 }, kind = "trap_part" },
		{ id = "Estrada_TrapA", room = "Estrada_Curva", offset = { x = 0, z = -6 }, kind = "trap" },
		{ id = "Estrada_TrapB", room = "Estrada_Ponte", offset = { x = 0, z = 6 }, kind = "trap" },
		{ id = "Estrada_Saida", room = "Estrada_Retas", offset = { x = 0, z = 16 }, kind = "exit" },
		{ id = "EP05_Mecanico", room = "Estrada_Posto", offset = { x = 0, z = 6 }, kind = "npc" },
		{ id = "EP05_Motorista", room = "Estrada_Lanchonete", offset = { x = 0, z = 6 }, kind = "npc" },
		{ id = "EP05_Fazendeiro", room = "Estrada_Celeiro", offset = { x = 0, z = 4 }, kind = "npc" },
		{ id = "EP05_Jornalista", room = "Estrada_Lanchonete", offset = { x = 8, z = -8 }, kind = "npc" },
		{ id = "EP05_MonsterSpawn", room = "Estrada_Bosque", offset = { x = 0, z = 0 }, kind = "monster" },
	},

	spawns = {
		players = "EP05_PlayerSpawn",
		monster = "EP05_MonsterSpawn",
		exit = "Estrada_Saida",
	},

	props = {
		{ type = "gas_pump", room = "Estrada_Posto", offset = { x = -8, z = -6 }, rotY = 0 },
		{ type = "gas_pump", room = "Estrada_Posto", offset = { x = 4, z = -6 }, rotY = 0 },
		{ type = "road_sign", room = "Estrada_Retas", offset = { x = 8, z = -12 }, rotY = 0 },
		{ type = "road_sign", room = "Estrada_Curva", offset = { x = -16, z = 6 }, rotY = 45 },
		{ type = "wrecked_car", room = "Estrada_Curva", offset = { x = 12, z = 6 }, rotY = 20 },
		{ type = "truck", room = "Estrada_Lanchonete", offset = { x = 12, z = -10 }, rotY = 90 },
		{ type = "diner_booth", room = "Estrada_Lanchonete", offset = { x = -8, z = 2 }, rotY = 0 },
		{ type = "diner_booth", room = "Estrada_Lanchonete", offset = { x = -8, z = -4 }, rotY = 0 },
		{ type = "counter", room = "Estrada_Lanchonete", offset = { x = 6, z = 8 }, rotY = 180 },
		{ type = "tractor", room = "Estrada_Celeiro", offset = { x = -6, z = 0 }, rotY = 0 },
		{ type = "haystack", room = "Estrada_Celeiro", offset = { x = 10, z = -8 }, rotY = 0 },
		{ type = "haystack", room = "Estrada_Celeiro", offset = { x = 10, z = 8 }, rotY = 0 },
		{ type = "horse_trough", room = "Estrada_Celeiro", offset = { x = -12, z = 8 }, rotY = 0 },
		{ type = "fence", room = "Estrada_Fazenda", offset = { x = 0, z = -8 }, rotY = 0 },
		{ type = "windmill", room = "Estrada_Fazenda", offset = { x = 10, z = 8 }, rotY = 0, height = 20 },
		{ type = "log_pile", room = "Estrada_Bosque", offset = { x = -8, z = 0 }, rotY = 0 },
		{ type = "tree", room = "Estrada_Bosque", offset = { x = 0, z = -8 }, rotY = 0 },
		{ type = "tree", room = "Estrada_Bosque", offset = { x = 8, z = 6 }, rotY = 0 },
		{ type = "tree", room = "Estrada_Bosque", offset = { x = -10, z = 8 }, rotY = 0 },
		{ type = "barrier", room = "Estrada_Placa", offset = { x = 0, z = 6 }, rotY = 0 },
		{ type = "excavator", room = "Estrada_Placa", offset = { x = 8, z = -6 }, rotY = 120 },
		{ type = "bridge_beam", room = "Estrada_Ponte", offset = { x = 0, z = -8 }, rotY = 0 },
		{ type = "street_lamp", room = "Estrada_Curva", offset = { x = 0, z = -12 }, rotY = 0, height = 16 },
	},
}

-- ==========================================================
-- EPISÓDIO 6 — MANSÃO BLACKWOOD
-- ==========================================================
Locations.Maps.MansaoEP6 = {
	id = "MansaoEP6",
	name = "Mansão Blackwood",
	subtitle = "Museu particular desde 1963",
	mood = "EP06_Mansao",
	cellSize = 8,
	width = 64,
	depth = 60,
	origin = { x = 15600, y = 0, z = 0 },
	ground = { material = "Grass", color = "MysteryGreen" },

	rooms = {
		{
			id = "Mansao_Jardim",
			label = "Jardim e Portão de Ferro",
			kind = "manor_garden",
			outdoor = true,
			x = 24,
			z = 46,
			w = 16,
			d = 8,
			floor = { material = "Cobblestone", color = "Panel" },
			height = 20,
			light = { color = "Warning", brightness = 1.5, count = 3 },
		},
		{
			id = "Mansao_Salao",
			label = "Salão de Entrada",
			kind = "manor_hall",
			tags = { "patrol", "mansion_hall" },
			x = 20,
			z = 30,
			w = 20,
			d = 14,
			floor = { material = "Marble", color = "Text" },
			wall = { material = "Marble", color = "Panel" },
			height = 26,
			light = { color = "Gold", brightness = 2.4, count = 5 },
		},
		{
			id = "Mansao_Galeria",
			label = "Galeria de Espelhos",
			kind = "mirror_gallery",
			tags = { "patrol", "mansion_hall" },
			x = 42,
			z = 30,
			w = 16,
			d = 14,
			floor = { material = "WoodPlanks", color = "ShaggyHair" },
			wall = { material = "Plaster", color = "Purple" },
			height = 22,
			light = { color = "Purple", brightness = 1.9, count = 5 },
		},
		{
			id = "Mansao_Biblioteca",
			label = "Biblioteca",
			kind = "library",
			tags = { "patrol" },
			x = 4,
			z = 30,
			w = 14,
			d = 14,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "WoodPlanks", color = "Scooby" },
			height = 24,
			light = { color = "Warning", brightness = 2.2, count = 4 },
		},
		{
			id = "Mansao_Atelie",
			label = "Ateliê de Restauro",
			kind = "art_studio",
			x = 4,
			z = 46,
			w = 12,
			d = 10,
			floor = { material = "Concrete", color = "PanelLight" },
			wall = { material = "Plaster", color = "Text" },
			height = 16,
			light = { color = "Text", brightness = 2.4, count = 3 },
		},
		{
			id = "Mansao_Cozinha",
			label = "Cozinha Antiga",
			kind = "old_kitchen",
			x = 18,
			z = 46,
			w = 12,
			d = 10,
			floor = { material = "Tile", color = "Text" },
			wall = { material = "Tile", color = "MysteryTeal" },
			height = 16,
			light = { color = "Warning", brightness = 2.3, count = 3 },
		},
		{
			id = "Mansao_Corredor_Leste",
			label = "Corredor Leste",
			kind = "manor_corridor",
			tags = { "patrol", "mansion_hall" },
			x = 42,
			z = 16,
			w = 18,
			d = 4,
			floor = { material = "Carpet", color = "Danger" },
			wall = { material = "Plaster", color = "Danger" },
			height = 16,
			light = { color = "Warning", brightness = 1.9, count = 5 },
		},
		{
			id = "Mansao_Quarto",
			label = "Quarto Principal",
			kind = "bedroom_lux",
			x = 42,
			z = 4,
			w = 16,
			d = 10,
			floor = { material = "Carpet", color = "Purple" },
			wall = { material = "Plaster", color = "Purple" },
			height = 18,
			light = { color = "Purple", brightness = 2, count = 3 },
		},
		{
			id = "Mansao_Tuneis",
			label = "Túneis da Família",
			kind = "catacombs",
			tags = { "patrol" },
			x = 4,
			z = 10,
			w = 34,
			d = 6,
			floor = { material = "Cobblestone", color = "Night" },
			wall = { material = "Brick", color = "Night" },
			height = 12,
			light = { color = "Warning", brightness = 1.2, count = 6 },
		},
		{
			id = "Mansao_Camara",
			label = "Câmara Central da Coleção",
			kind = "secret_vault",
			tags = { "patrol" },
			x = 4,
			z = 18,
			w = 14,
			d = 10,
			floor = { material = "Slate", color = "Panel" },
			wall = { material = "Slate", color = "Panel" },
			height = 14,
			light = { color = "Gold", brightness = 2.6, count = 3 },
		},
		{
			id = "Mansao_Escada_Tunel",
			label = "Escada dos Túneis",
			kind = "service_stairs",
			x = 24,
			z = 18,
			w = 8,
			d = 8,
			floor = { material = "Concrete", color = "Panel" },
			wall = { material = "Brick", color = "PanelLight" },
			height = 14,
			light = { color = "Warning", brightness = 1.4, count = 2 },
		},
		{
			id = "Mansao_Deposito",
			label = "Depósito de Peças",
			kind = "storage",
			x = 48,
			z = 46,
			w = 12,
			d = 10,
			floor = { material = "Concrete", color = "Panel" },
			wall = { material = "Brick", color = "Scooby" },
			height = 16,
			light = { color = "Warning", brightness = 1.6, count = 3 },
		},
	},

	corridors = {
		{ x = 30, z = 44, w = 4, d = 4 }, -- jardim -> salão
		{ x = 40, z = 34, w = 4, d = 4 }, -- salão -> galeria
		{ x = 18, z = 34, w = 4, d = 4 }, -- salão -> biblioteca
		{ x = 18, z = 42, w = 4, d = 6 }, -- salão -> cozinha
		{ x = 10, z = 42, w = 4, d = 6 }, -- biblioteca -> ateliê
		{ x = 30, z = 50, w = 12, d = 3 }, -- cozinha -> depósito
		{ x = 44, z = 42, w = 4, d = 6 }, -- galeria -> depósito
		{ x = 42, z = 20, w = 4, d = 12 }, -- galeria -> corredor leste
		{ x = 46, z = 14, w = 8, d = 4 }, -- corredor leste -> quarto
		{ x = 20, z = 22, w = 4, d = 10 }, -- escada -> salão
		{ x = 12, z = 16, w = 22, d = 4 }, -- camara -> escada
		{ x = 4, z = 22, w = 6, d = 10 }, -- camara -> túneis
		{ x = 40, z = 12, w = 4, d = 12 }, -- túneis -> corredor leste
		{ x = 24, z = 24, w = 4, d = 4 }, -- escada -> camara
	},

	markers = {
		{ id = "EP06_PlayerSpawn", room = "Mansao_Jardim", offset = { x = 0, z = 0 }, kind = "spawn" },
		{ id = "Mansao_Quadro", room = "Mansao_Galeria", offset = { x = 0, z = -10 }, kind = "clue" },
		{ id = "Mansao_Espelho", room = "Mansao_Galeria", offset = { x = 10, z = 4 }, kind = "clue" },
		{ id = "Mansao_Atelie_Marker", room = "Mansao_Atelie", offset = { x = 0, z = -4 }, kind = "clue" },
		{ id = "Mansao_Biblioteca_Marker", room = "Mansao_Biblioteca", offset = { x = 0, z = -6 }, kind = "clue" },
		{ id = "Mansao_Atelie_Fundo", room = "Mansao_Atelie", offset = { x = 8, z = 4 }, kind = "clue" },
		{ id = "Mansao_Corrente", room = "Mansao_Jardim", offset = { x = -14, z = 0 }, kind = "trap_part" },
		{ id = "Mansao_Contrapeso", room = "Mansao_Escada_Tunel", offset = { x = 0, z = 0 }, kind = "trap_part" },
		{ id = "Mansao_Lencois", room = "Mansao_Galeria", offset = { x = -10, z = 8 }, kind = "trap_part" },
		{ id = "Mansao_TrapA", room = "Mansao_Escada_Tunel", offset = { x = 0, z = -6 }, kind = "trap" },
		{ id = "Mansao_TrapB", room = "Mansao_Galeria", offset = { x = 0, z = 6 }, kind = "trap" },
		{
			id = "Mansao_Corredor_Leste_Marker",
			room = "Mansao_Corredor_Leste",
			offset = { x = 0, z = 0 },
			kind = "objective",
		},
		{ id = "Mansao_Saida", room = "Mansao_Jardim", offset = { x = 0, z = 8 }, kind = "exit" },
		{ id = "Mansao_Camara_Marker", room = "Mansao_Camara", offset = { x = 0, z = 0 }, kind = "objective" },
		{ id = "EP06_Advogado", room = "Mansao_Biblioteca", offset = { x = 0, z = 4 }, kind = "npc" },
		{ id = "EP06_Curador", room = "Mansao_Galeria", offset = { x = -4, z = -6 }, kind = "npc" },
		{ id = "EP06_Restauradora", room = "Mansao_Atelie", offset = { x = -6, z = -4 }, kind = "npc" },
		{ id = "EP06_Fotografo", room = "Mansao_Salao", offset = { x = 12, z = -8 }, kind = "npc" },
		{ id = "EP06_Zelador", room = "Mansao_Cozinha", offset = { x = 0, z = 0 }, kind = "npc" },
		{ id = "EP06_MonsterSpawn", room = "Mansao_Camara", offset = { x = 0, z = -6 }, kind = "monster" },
	},

	spawns = {
		players = "EP06_PlayerSpawn",
		monster = "EP06_MonsterSpawn",
		exit = "Mansao_Saida",
	},

	props = {
		{ type = "grand_painting", marker = "Mansao_Quadro", rotY = 180 },
		{ type = "mirror_wall", marker = "Mansao_Espelho", rotY = 90 },
		{ type = "easel", marker = "Mansao_Atelie_Fundo", rotY = 0 },
		{ type = "bookshelf", room = "Mansao_Biblioteca", offset = { x = -12, z = -8 }, rotY = 0 },
		{ type = "bookshelf", room = "Mansao_Biblioteca", offset = { x = -12, z = 0 }, rotY = 0 },
		{ type = "bookshelf", room = "Mansao_Biblioteca", offset = { x = -12, z = 8 }, rotY = 0 },
		{ type = "reading_desk", room = "Mansao_Biblioteca", offset = { x = 4, z = 6 }, rotY = 0 },
		{ type = "candelabra", room = "Mansao_Salao", offset = { x = 0, z = -10 }, rotY = 0 },
		{ type = "staircase_grand", room = "Mansao_Salao", offset = { x = -14, z = 8 }, rotY = 0 },
		{ type = "mirror_wall", room = "Mansao_Galeria", offset = { x = -8, z = -10 }, rotY = 0 },
		{ type = "mirror_wall", room = "Mansao_Galeria", offset = { x = 4, z = -10 }, rotY = 0 },
		{ type = "pedestal", room = "Mansao_Galeria", offset = { x = 0, z = 0 }, rotY = 0 },
		{ type = "sarcophagus", room = "Mansao_Tuneis", offset = { x = -20, z = 0 }, rotY = 0 },
		{ type = "pipe_run", room = "Mansao_Tuneis", offset = { x = 10, z = 2 }, rotY = 90 },
		{ type = "crate_stack", room = "Mansao_Camara", offset = { x = -8, z = -4 }, rotY = 0 },
		{ type = "display_case", room = "Mansao_Camara", offset = { x = 6, z = 0 }, rotY = 0 },
		{ type = "service_elevator", marker = "Mansao_Contrapeso", rotY = 0 },
		{ type = "bed_canopy", room = "Mansao_Quarto", offset = { x = 0, z = 0 }, rotY = 0 },
		{ type = "dresser", room = "Mansao_Quarto", offset = { x = -10, z = 6 }, rotY = 0 },
		{ type = "old_stove", room = "Mansao_Cozinha", offset = { x = 0, z = -6 }, rotY = 0 },
		{ type = "hanging_pots", room = "Mansao_Cozinha", offset = { x = 8, z = 0 }, rotY = 0, height = 9 },
		{ type = "gargoyle", room = "Mansao_Jardim", offset = { x = 12, z = -6 }, rotY = 180 },
		{ type = "fountain_dry", room = "Mansao_Jardim", offset = { x = 0, z = -4 }, rotY = 0 },
		{ type = "iron_fence", room = "Mansao_Jardim", offset = { x = 0, z = 8 }, rotY = 0 },
		{ type = "crate_stack", room = "Mansao_Deposito", offset = { x = 0, z = 0 }, rotY = 0 },
	},

	links = {
		{ id = "Mansao_Tunel_Link", from = "Mansao_Tuneis", to = "Mansao_Camara", cost = 3 },
		{ id = "Mansao_Camara_Link", from = "Mansao_Camara", to = "Mansao_Galeria", cost = 5 },
	},
}

-- ==========================================================
-- ARCO FINAL — ARMAZÉM DO PENHASCO
-- ==========================================================
Locations.Maps.PenhascoFinal = {
	id = "PenhascoFinal",
	name = "Armazém do Penhasco",
	subtitle = "Coolsville — a exposição particular do Colecionador",
	mood = "EP06_Mansao",
	cellSize = 8,
	width = 68,
	depth = 56,
	origin = { x = 18200, y = 0, z = 0 },
	ground = { material = "Grass", color = "MysteryGreen" },

	rooms = {
		{
			id = "Penhasco_Externo",
			label = "Estrada do Penhasco",
			kind = "cliff_road",
			outdoor = true,
			x = 26,
			z = 46,
			w = 16,
			d = 8,
			floor = { material = "Asphalt", color = "Night" },
			height = 22,
			light = { color = "Warning", brightness = 1.4, count = 3 },
		},
		{
			id = "Penhasco_Armazem",
			label = "Armazém — Entrada",
			kind = "warehouse_entry",
			x = 22,
			z = 32,
			w = 22,
			d = 12,
			floor = { material = "Concrete", color = "Panel" },
			wall = { material = "CorrugatedMetal", color = "PanelLight" },
			height = 24,
			light = { color = "Warning", brightness = 2.2, count = 5 },
		},
		{
			id = "Penhasco_Cenario1",
			label = "Cenário 1 — Farol",
			kind = "set_lighthouse",
			tags = { "patrol", "collection" },
			x = 4,
			z = 32,
			w = 14,
			d = 12,
			floor = { material = "Slate", color = "Panel" },
			wall = { material = "Fabric", color = "MysteryTeal" },
			height = 20,
			light = { color = "Accent", brightness = 2.4, count = 3 },
		},
		{
			id = "Penhasco_Cenario2",
			label = "Cenário 2 — Hotel",
			kind = "set_hotel",
			tags = { "patrol", "collection" },
			x = 48,
			z = 32,
			w = 16,
			d = 12,
			floor = { material = "Marble", color = "Text" },
			wall = { material = "Fabric", color = "Purple" },
			height = 20,
			light = { color = "Purple", brightness = 2.2, count = 3 },
		},
		{
			id = "Penhasco_Cenario3",
			label = "Cenário 3 — Circo",
			kind = "set_circus",
			tags = { "patrol", "collection" },
			x = 4,
			z = 18,
			w = 14,
			d = 12,
			floor = { material = "Fabric", color = "Gold" },
			wall = { material = "Fabric", color = "Danger" },
			height = 22,
			light = { color = "Gold", brightness = 2.3, count = 3 },
		},
		{
			id = "Penhasco_Cenario4",
			label = "Cenário 4 — Fábrica",
			kind = "set_factory",
			tags = { "patrol", "collection" },
			x = 48,
			z = 18,
			w = 16,
			d = 12,
			floor = { material = "Metal", color = "Panel" },
			wall = { material = "Fabric", color = "PanelLight" },
			height = 20,
			light = { color = "Warning", brightness = 2.1, count = 3 },
		},
		{
			id = "Penhasco_Cenario5",
			label = "Cenário 5 — Estrada",
			kind = "set_road",
			tags = { "patrol", "collection" },
			x = 4,
			z = 4,
			w = 14,
			d = 12,
			floor = { material = "Asphalt", color = "Night" },
			wall = { material = "Fabric", color = "MysteryBlue" },
			height = 20,
			light = { color = "Warning", brightness = 1.6, count = 3 },
		},
		{
			id = "Penhasco_Cenario6",
			label = "Cenário 6 — Mansão",
			kind = "set_manor",
			tags = { "patrol", "collection" },
			x = 48,
			z = 4,
			w = 16,
			d = 12,
			floor = { material = "Marble", color = "Panel" },
			wall = { material = "Fabric", color = "DeepPurple" },
			height = 20,
			light = { color = "Purple", brightness = 2.1, count = 3 },
		},
		{
			id = "Penhasco_Palco",
			label = "Palco Central — LOTE 7",
			kind = "final_stage",
			tags = { "patrol", "stage" },
			x = 22,
			z = 12,
			w = 22,
			d = 20,
			floor = { material = "WoodPlanks", color = "Panel" },
			wall = { material = "Fabric", color = "Night" },
			height = 30,
			light = { color = "Accent", brightness = 3, count = 6 },
		},
		{
			id = "Penhasco_Bastidores",
			label = "Bastidores — Mesa de Som",
			kind = "backstage",
			tags = { "patrol" },
			x = 44,
			z = 12,
			w = 14,
			d = 8,
			floor = { material = "Concrete", color = "Night" },
			wall = { material = "CorrugatedMetal", color = "Night" },
			height = 16,
			light = { color = "Accent", brightness = 1.9, count = 3 },
		},
		{
			id = "Penhasco_Deposito",
			label = "Depósito de Figurinos",
			kind = "costume_storage",
			x = 4,
			z = 46,
			w = 14,
			d = 8,
			floor = { material = "Concrete", color = "Panel" },
			wall = { material = "CorrugatedMetal", color = "Scooby" },
			height = 16,
			light = { color = "Warning", brightness = 1.8, count = 3 },
		},
		{
			id = "Penhasco_Portao",
			label = "Portão de Carga",
			kind = "loading_door",
			outdoor = true,
			x = 44,
			z = 46,
			w = 12,
			d = 8,
			floor = { material = "Concrete", color = "PanelLight" },
			height = 20,
			light = { color = "Warning", brightness = 2.2, count = 3 },
		},
	},

	corridors = {
		{ x = 32, z = 42, w = 6, d = 4 }, -- externo -> armazém
		{ x = 16, z = 36, w = 8, d = 4 }, -- armazém -> cenário 1
		{ x = 42, z = 36, w = 8, d = 4 }, -- armazém -> cenário 2
		{ x = 16, z = 22, w = 8, d = 4 }, -- cenário1 -> cenário3
		{ x = 44, z = 22, w = 8, d = 4 }, -- cenário2 -> cenário4
		{ x = 16, z = 8, w = 8, d = 4 }, -- cenário3 -> cenário5
		{ x = 44, z = 8, w = 8, d = 4 }, -- cenário4 -> cenário6
		{ x = 20, z = 12, w = 4, d = 22 }, -- cenário1/3 -> palco
		{ x = 44, z = 14, w = 4, d = 20 }, -- cenário2/4 -> palco
		{ x = 44, z = 10, w = 4, d = 5 }, -- cenário6 -> bastidores
		{ x = 42, z = 26, w = 4, d = 4 }, -- bastidores -> palco
		{ x = 20, z = 26, w = 4, d = 6 }, -- palco -> armazém
		{ x = 12, z = 42, w = 4, d = 6 }, -- cenário1 -> depósito
		{ x = 44, z = 42, w = 4, d = 6 }, -- cenário2 -> portão
		{ x = 18, z = 46, w = 6, d = 4 }, -- depósito -> externo
		{ x = 56, z = 40, w = 8, d = 4 }, -- portão -> cenário 2
		{ x = 24, z = 42, w = 4, d = 4 }, -- armazém -> depósito
	},

	markers = {
		{ id = "FINAL_PlayerSpawn", room = "Penhasco_Externo", offset = { x = 0, z = 0 }, kind = "spawn" },
		{ id = "Penhasco_Catalogo", room = "Penhasco_Armazem", offset = { x = 0, z = -6 }, kind = "clue" },
		{ id = "Penhasco_Cenario1_Marker", room = "Penhasco_Cenario1", offset = { x = 0, z = 0 }, kind = "clue" },
		{ id = "Penhasco_Cenario3_Marker", room = "Penhasco_Cenario3", offset = { x = 0, z = 0 }, kind = "clue" },
		{ id = "Penhasco_Cenario6_Marker", room = "Penhasco_Cenario6", offset = { x = 0, z = 0 }, kind = "clue" },
		{ id = "Penhasco_Cabos", room = "Penhasco_Bastidores", offset = { x = 0, z = -4 }, kind = "trap_part" },
		{ id = "Penhasco_Contrapeso", room = "Penhasco_Palco", offset = { x = -16, z = -16 }, kind = "trap_part" },
		{ id = "Penhasco_Holofote", room = "Penhasco_Deposito", offset = { x = 0, z = 0 }, kind = "trap_part" },
		{ id = "Penhasco_TrapA", room = "Penhasco_Palco", offset = { x = 0, z = 0 }, kind = "trap" },
		{ id = "Penhasco_TrapB", room = "Penhasco_Portao", offset = { x = 0, z = 0 }, kind = "trap" },
		{ id = "Penhasco_Saida", room = "Penhasco_Externo", offset = { x = -12, z = 0 }, kind = "exit" },
		{ id = "Penhasco_Mesa", room = "Penhasco_Bastidores", offset = { x = 0, z = 4 }, kind = "objective" },
		{ id = "FINAL_MonsterSpawn", room = "Penhasco_Bastidores", offset = { x = 8, z = -4 }, kind = "monster" },
	},

	spawns = {
		players = "FINAL_PlayerSpawn",
		monster = "FINAL_MonsterSpawn",
		exit = "Penhasco_Saida",
	},

	props = {
		{ type = "catalog_table", marker = "Penhasco_Catalogo", rotY = 180 },
		{ type = "audio_console", marker = "Penhasco_Mesa", rotY = 180 },
		{ type = "fog_machine", room = "Penhasco_Cenario1", offset = { x = 8, z = -6 }, rotY = 0 },
		{ type = "piano_prop", room = "Penhasco_Cenario2", offset = { x = 0, z = 0 }, rotY = 0 },
		{ type = "clown_car", room = "Penhasco_Cenario3", offset = { x = 0, z = 0 }, rotY = 45 },
		{ type = "conveyor", room = "Penhasco_Cenario4", offset = { x = 0, z = 0 }, rotY = 0 },
		{ type = "wrecked_car", room = "Penhasco_Cenario5", offset = { x = 0, z = 0 }, rotY = 90 },
		{ type = "mirror_wall", room = "Penhasco_Cenario6", offset = { x = 0, z = -6 }, rotY = 0 },
		{ type = "spotlight", room = "Penhasco_Palco", offset = { x = -12, z = 12 }, rotY = 0, height = 24 },
		{ type = "spotlight", room = "Penhasco_Palco", offset = { x = 12, z = 12 }, rotY = 0, height = 24 },
		{ type = "display_case", room = "Penhasco_Palco", offset = { x = 0, z = -8 }, rotY = 0 },
		{ type = "costume_rack", room = "Penhasco_Deposito", offset = { x = -6, z = 0 }, rotY = 0 },
		{ type = "costume_rack", room = "Penhasco_Deposito", offset = { x = 6, z = 0 }, rotY = 0 },
		{ type = "crate_stack", room = "Penhasco_Armazem", offset = { x = 12, z = 6 }, rotY = 0 },
		{ type = "crate_stack", room = "Penhasco_Armazem", offset = { x = -12, z = 6 }, rotY = 0 },
		{ type = "cable_spool", room = "Penhasco_Bastidores", offset = { x = -8, z = 0 }, rotY = 0 },
		{ type = "string_lights", room = "Penhasco_Externo", offset = { x = 0, z = 0 }, rotY = 0, height = 12 },
		{ type = "loading_door", room = "Penhasco_Portao", offset = { x = 0, z = -6 }, rotY = 0 },
	},
}

-- ==========================================================
-- HELPERS
-- ==========================================================
function Locations.getMap(id)
	return Locations.Maps[id] or Locations.Maps.Lobby
end

function Locations.getRoom(mapOrId, roomId)
	local map = type(mapOrId) == "string" and Locations.getMap(mapOrId) or mapOrId
	for _, room in ipairs(map.rooms) do
		if room.id == roomId then
			return room
		end
	end
	for _, corridor in ipairs(map.corridors) do
		if corridor.id == roomId then
			return corridor
		end
	end
	return nil
end

-- Centro da sala em coordenadas de mundo
function Locations.roomCenter(map, room)
	local cellSize = map.cellSize or 8
	local origin = map.origin or { x = 0, y = 0, z = 0 }
	return Vector3.new(
		origin.x + (room.x + room.w / 2 - 0.5) * cellSize,
		origin.y,
		origin.z + (room.z + room.d / 2 - 0.5) * cellSize
	)
end

-- Posição de um marker (offset em studs a partir do centro da sala)
function Locations.markerPosition(mapOrId, markerId)
	local map = type(mapOrId) == "string" and Locations.getMap(mapOrId) or mapOrId
	for _, marker in ipairs(map.markers) do
		if marker.id == markerId then
			local room = Locations.getRoom(map, marker.room)
			if not room then
				return nil
			end
			local center = Locations.roomCenter(map, room)
			local offset = marker.offset or { x = 0, z = 0 }
			return Vector3.new(center.X + (offset.x or 0), center.Y, center.Z + (offset.z or 0)), marker
		end
	end
	-- fallback: o id pode ser o id de uma sala
	local room = Locations.getRoom(map, markerId)
	if room then
		return Locations.roomCenter(map, room), { id = markerId, room = room.id, kind = "room" }
	end
	return nil, nil
end

function Locations.markersOfKind(map, kind)
	local list = {}
	for _, marker in ipairs(map.markers) do
		if marker.kind == kind then
			table.insert(list, marker)
		end
	end
	return list
end

function Locations.roomTagged(map, tag)
	local list = {}
	for _, room in ipairs(map.rooms) do
		for _, roomTag in ipairs(room.tags or {}) do
			if roomTag == tag then
				table.insert(list, room)
				break
			end
		end
	end
	return list
end

function Locations.validate()
	local problems = {}
	for mapId, map in pairs(Locations.Maps) do
		local seenRooms = {}
		local function checkRect(rect, label)
			if rect.w <= 0 or rect.d <= 0 then
				table.insert(problems, ("%s: %s com tamanho inválido"):format(mapId, label))
			end
			if rect.x < 1 or rect.z < 1 or rect.x + rect.w - 1 > map.width or rect.z + rect.d - 1 > map.depth then
				table.insert(
					problems,
					("%s: %s fora da grade (%d,%d %dx%d)"):format(mapId, label, rect.x, rect.z, rect.w, rect.d)
				)
			end
		end
		for _, room in ipairs(map.rooms) do
			if seenRooms[room.id] then
				table.insert(problems, ("%s: sala duplicada %s"):format(mapId, room.id))
			end
			seenRooms[room.id] = room
			checkRect(room, "sala " .. room.id)
		end
		for index, corridor in ipairs(map.corridors) do
			checkRect(corridor, "corredor #" .. index)
		end
		for _, marker in ipairs(map.markers) do
			if not seenRooms[marker.room] then
				table.insert(
					problems,
					("%s: marker %s aponta para sala inexistente %s"):format(mapId, marker.id, marker.room)
				)
			end
		end
		local coverage = Locations.coveragePercent(map)
		if coverage < 4 then
			table.insert(problems, ("%s: mapa com pouca área caminhável (%.1f%%)"):format(mapId, coverage))
		end
	end
	return #problems == 0, problems
end

function Locations.coveragePercent(map)
	local total = map.width * map.depth
	local walkable = {}
	local function carve(rect)
		for x = rect.x, rect.x + rect.w - 1 do
			for z = rect.z, rect.z + rect.d - 1 do
				walkable[x .. "," .. z] = true
			end
		end
	end
	for _, room in ipairs(map.rooms) do
		carve(room)
	end
	for _, corridor in ipairs(map.corridors) do
		carve(corridor)
	end
	local count = 0
	for _ in pairs(walkable) do
		count += 1
	end
	return count / total * 100
end

return Locations
