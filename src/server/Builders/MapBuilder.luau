--[[
	MapBuilder.luau
	Constrói um mapa inteiro a partir de Locations.luau:
		1. Escava as salas/corredores na grade de navegação (GridNav).
		2. Cria chão, paredes (com mesclagem de segmentos), tetos e luzes.
		3. Cria água, terreno externo e limites do mapa.
		4. Coloca os props declarados + decoração automática por tipo de sala.
		5. Cria as "partes de marker" (pistas, NPCs, pontos de armadilha, saídas)
		   com ProximityPrompt e atributos — é por elas que o jogo inteiro conversa.

	O mapa é construído UMA vez por servidor e reaproveitado por todas as partidas
	(ele fica no Workspace, longe do lobby, e recebe streaming off).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Locations = require(Shared.Data.Locations)
local Props = require(Shared.Data.Props)
local GridNav = require(Shared.GridNav)

local PartKit = require(script.Parent.PartKit)
local Decorator = require(script.Parent.Decorator)

local MapBuilder = {}

MapBuilder.RootName = "MysteryMaps"

local function getRoot()
	local root = Workspace:FindFirstChild(MapBuilder.RootName)
	if not root then
		root = Instance.new("Folder")
		root.Name = MapBuilder.RootName
		root.Parent = Workspace
	end
	return root
end

-- ==========================================================
-- GRADE
-- ==========================================================
local function buildNav(map)
	local origin = map.origin or { x = 0, y = 0, z = 0 }
	local nav = GridNav.new({
		width = map.width,
		depth = map.depth,
		cellSize = map.cellSize or Config.Grid.CELL,
		origin = Vector3.new(origin.x, origin.y, origin.z),
	})
	nav:BlockAll()

	local function carve(rect, tags)
		for x = rect.x, rect.x + rect.w - 1 do
			for z = rect.z, rect.z + rect.d - 1 do
				local cost = 1
				local tag = nil
				for _, roomTag in ipairs(tags or {}) do
					if
						roomTag == "patrol"
						or roomTag == "pier"
						or roomTag == "lighthouse"
						or roomTag == "hotel_floor3"
						or roomTag == "circus_ring"
						or roomTag == "factory_floor"
						or roomTag == "road"
						or roomTag == "farm"
						or roomTag == "mansion_hall"
					then
						tag = roomTag
					end
				end
				nav:SetCell(x, z, { walkable = true, cost = cost, tag = tag })
			end
		end
	end

	for _, room in ipairs(map.rooms) do
		carve(room, room.tags)
	end
	for _, corridor in ipairs(map.corridors) do
		carve(corridor, { "patrol" })
	end

	return nav
end

-- ==========================================================
-- GEOMETRIA
-- ==========================================================
local function cellToWorld(map, x, z)
	local origin = map.origin or { x = 0, y = 0, z = 0 }
	local cell = map.cellSize or Config.Grid.CELL
	return Vector3.new(origin.x + (x - 0.5) * cell, origin.y, origin.z + (z - 0.5) * cell)
end

local function roomWorldCentre(map, room)
	local cell = map.cellSize or Config.Grid.CELL
	local origin = map.origin or { x = 0, y = 0, z = 0 }
	return Vector3.new(
		origin.x + (room.x + room.w / 2 - 0.5) * cell,
		origin.y,
		origin.z + (room.z + room.d / 2 - 0.5) * cell
	)
end

local function ensureFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function buildGround(map, folder)
	local cell = map.cellSize or Config.Grid.CELL
	local origin = map.origin or { x = 0, y = 0, z = 0 }
	local thickness = 4
	local ground = map.ground or { material = "Grass", color = "MysteryGreen" }

	local slab = PartKit.part({
		name = "GroundBase",
		size = { map.width * cell + 80, thickness, map.depth * cell + 80 },
		color = ground.color,
		material = ground.material,
		castShadow = false,
		parent = folder,
	})
	slab.Position =
		Vector3.new(origin.x + map.width * cell / 2, origin.y - thickness / 2, origin.z + map.depth * cell / 2)
	slab.Locked = true

	-- Água (mares, rios)
	for index, water in ipairs(map.water or {}) do
		local waterPart = PartKit.part({
			name = "Water" .. index,
			size = { water.w * cell, 1.5, water.d * cell },
			color = "MysteryTeal",
			material = Enum.Material.Glass,
			transparency = 0.35,
			reflectivity = 0.2,
			canCollide = false,
			parent = folder,
		})
		waterPart.Position = Vector3.new(
			origin.x + (water.x + water.w / 2 - 0.5) * cell,
			origin.y - 1.2,
			origin.z + (water.z + water.d / 2 - 0.5) * cell
		)
		waterPart.CanCollide = false
	end
end

local function buildRooms(map, nav, folder)
	local cell = map.cellSize or Config.Grid.CELL
	local origin = map.origin or { x = 0, y = 0, z = 0 }
	local wallHeight = Config.Grid.WALL_HEIGHT

	local floors = ensureFolder(folder, "Floors")
	local walls = ensureFolder(folder, "Walls")
	local ceilings = ensureFolder(folder, "Ceilings")
	local lights = ensureFolder(folder, "Lights")
	local roomInfo = {}

	local function addRoom(rect, isCorridor)
		local floorSpec = rect.floor or { material = "Concrete", color = "Panel" }
		local wallSpec = rect.wall or { material = "Concrete", color = "PanelLight" }
		local ceilingSpec = rect.ceiling
		local height = rect.height or wallHeight

		local centre = roomWorldCentre(map, rect)

		-- chão
		local floor = PartKit.part({
			name = "F_" .. tostring(rect.id or "corridor"),
			size = { rect.w * cell, 1, rect.d * cell },
			color = floorSpec.color,
			material = floorSpec.material,
			castShadow = false,
			parent = floors,
		})
		floor.Position = Vector3.new(centre.X, origin.y - 0.5, centre.Z)

		-- teto (salas internas)
		if not rect.outdoor then
			local ceiling = PartKit.part({
				name = "C_" .. tostring(rect.id or "corridor"),
				size = { rect.w * cell, 1, rect.d * cell },
				color = (ceilingSpec and ceilingSpec.color) or wallSpec.color,
				material = (ceilingSpec and ceilingSpec.material) or wallSpec.material,
				castShadow = false,
				parent = ceilings,
			})
			ceiling.Position = Vector3.new(centre.X, origin.y + height, centre.Z)
		end

		-- luzes internas
		local lightSpec = rect.light
		if lightSpec and (lightSpec.count or 0) > 0 then
			local columns = math.max(1, math.floor(math.sqrt(lightSpec.count)))
			local rows = math.ceil(lightSpec.count / columns)
			for column = 1, columns do
				for row = 1, rows do
					if (column - 1) * rows + row <= lightSpec.count then
						local fx = (column - 0.5) / columns
						local fz = (row - 0.5) / rows
						local position = Vector3.new(
							origin.x + (rect.x + rect.w * fx - 0.5) * cell,
							origin.y + height - 2,
							origin.z + (rect.z + rect.d * fz - 0.5) * cell
						)
						local bulb = PartKit.part({
							name = "Lamp",
							size = { 1.4, 0.4, 1.4 },
							color = lightSpec.color,
							material = Enum.Material.Neon,
							canCollide = false,
							canQuery = false,
							parent = lights,
						})
						bulb.Position = position
						PartKit.pointLight(bulb, {
							color = lightSpec.color,
							brightness = lightSpec.brightness,
							range = lightSpec.range or math.max(rect.w, rect.d) * cell * 0.7,
						})
					end
				end
			end
		end

		roomInfo[rect.id or ("corridor_" .. tostring(#roomInfo + 1))] = {
			data = rect,
			centre = centre,
			isCorridor = isCorridor,
		}
	end

	for _, room in ipairs(map.rooms) do
		addRoom(room, false)
	end
	for _, corridor in ipairs(map.corridors) do
		addRoom(corridor, true)
	end

	-- ======================================================
	-- PAREDES (nas divisas entre piso e bloco sólido)
	-- ======================================================
	local usedCells = {}
	for _, room in ipairs(map.rooms) do
		for x = room.x, room.x + room.w - 1 do
			for z = room.z, room.z + room.d - 1 do
				usedCells[x .. "," .. z] = room
			end
		end
	end
	for _, corridor in ipairs(map.corridors) do
		for x = corridor.x, corridor.x + corridor.w - 1 do
			for z = corridor.z, corridor.z + corridor.d - 1 do
				usedCells[x .. "," .. z] = corridor
			end
		end
	end

	local function wallInfoFor(x, z)
		local room = usedCells[x .. "," .. z]
		if room then
			return room.wall or { material = "Concrete", color = "PanelLight" }, room.height or wallHeight
		end
		return nil
	end

	-- Paredes ao longo de Z (faces norte/sul)
	for x = 1, map.width do
		local runStart = nil
		local runSpec, runHeight = nil, nil
		for z = 1, map.depth + 1 do
			local needsWall = false
			local spec, height = nil, nil
			if z <= map.depth and usedCells[x .. "," .. z] and not usedCells[x .. "," .. (z - 1)] then
				needsWall = true
				spec, height = wallInfoFor(x, z)
			elseif z <= map.depth and not usedCells[x .. "," .. z] and usedCells[x .. "," .. (z - 1)] then
				needsWall = true
				spec, height = wallInfoFor(x, z - 1)
			end
			if needsWall and spec then
				if not runStart then
					runStart = z
					runSpec = spec
					runHeight = height
				elseif runSpec ~= spec then
					-- material mudou: fecha o segmento anterior
					local length = (z - runStart) * cell
					local wall = PartKit.part({
						name = "WallZ",
						size = { Config.Grid.WALL_THICK, runHeight, length },
						color = runSpec.color,
						material = runSpec.material,
						parent = walls,
					})
					wall.Position = Vector3.new(
						origin.x + (x - 0.5) * cell,
						origin.y + runHeight / 2,
						origin.z + (runStart + (z - runStart) / 2 - 0.5) * cell
					)
					runStart = z
					runSpec = spec
					runHeight = height
				end
			elseif runStart then
				local length = (z - runStart) * cell
				local wall = PartKit.part({
					name = "WallZ",
					size = { Config.Grid.WALL_THICK, runHeight, length },
					color = runSpec.color,
					material = runSpec.material,
					parent = walls,
				})
				wall.Position = Vector3.new(
					origin.x + (x - 0.5) * cell,
					origin.y + runHeight / 2,
					origin.z + (runStart + (z - runStart) / 2 - 0.5) * cell
				)
				runStart = nil
			end
		end
	end

	-- Paredes ao longo de X (faces leste/oeste)
	for z = 1, map.depth do
		local runStart = nil
		local runSpec, runHeight = nil, nil
		for x = 1, map.width + 1 do
			local needsWall = false
			local spec, height = nil, nil
			if x <= map.width and usedCells[x .. "," .. z] and not usedCells[(x - 1) .. "," .. z] then
				needsWall = true
				spec, height = wallInfoFor(x, z)
			elseif x <= map.width and not usedCells[x .. "," .. z] and usedCells[(x - 1) .. "," .. z] then
				needsWall = true
				spec, height = wallInfoFor(x - 1, z)
			end
			if needsWall and spec then
				if not runStart then
					runStart = x
					runSpec = spec
					runHeight = height
				elseif runSpec ~= spec then
					local length = (x - runStart) * cell
					local wall = PartKit.part({
						name = "WallX",
						size = { length, runHeight, Config.Grid.WALL_THICK },
						color = runSpec.color,
						material = runSpec.material,
						parent = walls,
					})
					wall.Position = Vector3.new(
						origin.x + (runStart + (x - runStart) / 2 - 0.5) * cell,
						origin.y + runHeight / 2,
						origin.z + (z - 0.5) * cell
					)
					runStart = x
					runSpec = spec
					runHeight = height
				end
			elseif runStart then
				local length = (x - runStart) * cell
				local wall = PartKit.part({
					name = "WallX",
					size = { length, runHeight, Config.Grid.WALL_THICK },
					color = runSpec.color,
					material = runSpec.material,
					parent = walls,
				})
				wall.Position = Vector3.new(
					origin.x + (runStart + (x - runStart) / 2 - 0.5) * cell,
					origin.y + runHeight / 2,
					origin.z + (z - 0.5) * cell
				)
				runStart = nil
			end
		end
	end

	return roomInfo
end

-- ==========================================================
-- MARKERS
-- ==========================================================
local MARKER_STYLES = {
	clue = { color = "Accent", height = 2.4, size = 1.2, label = "Pista", prompt = "Examinar" },
	objective = { color = "Warning", height = 2, size = 1.6, label = "Objetivo", prompt = nil },
	trap = { color = "Danger", height = 2, size = 2.4, label = "Ponto de Armadilha", prompt = "Montar armadilha" },
	trap_part = { color = "Gold", height = 1.6, size = 1, label = "Peça", prompt = "Pegar peça" },
	exit = { color = "MysteryGreen", height = 1.4, size = 3, label = "Saída", prompt = "Voltar para a van" },
	npc = { color = "MysteryBlue", height = 0.6, size = 1.4, label = "NPC", prompt = nil },
	monster = { color = "Purple", height = 0.5, size = 1.5, label = "Spawn", prompt = nil },
	spawn = { color = "Text", height = 0.4, size = 2.4, label = "Spawn", prompt = nil },
	portal = { color = "Purple", height = 0.4, size = 3, label = "Portal", prompt = "Entrar no caso" },
	interact = { color = "Warning", height = 0.5, size = 1.6, label = "Interagir", prompt = "Usar" },
	test = { color = "Accent", height = 0.4, size = 2, label = "Teste", prompt = nil },
	prop = { color = "Text", height = 0.4, size = 1, label = "Prop", prompt = nil },
}

local function buildMarkers(map, mapModel, folder, nav)
	local markers = {}
	local markersFolder = ensureFolder(folder, "Markers")
	local interactables = {}

	for _, marker in ipairs(map.markers) do
		local style = MARKER_STYLES[marker.kind] or MARKER_STYLES.interact
		local position = Locations.markerPosition(map, marker.id)
		if position then
			local part = PartKit.part({
				name = "M_" .. marker.id,
				size = { style.size, 0.4, style.size },
				color = style.color,
				material = Enum.Material.Neon,
				transparency = marker.kind == "spawn" and 1 or 0.45,
				canCollide = false,
				canQuery = marker.kind ~= "monster" and marker.kind ~= "spawn",
				castShadow = false,
				parent = markersFolder,
			})
			part.Position = Vector3.new(position.X, (map.origin and map.origin.y or 0) + 0.25, position.Z)

			part:SetAttribute("MarkerId", marker.id)
			part:SetAttribute("MarkerKind", marker.kind)
			part:SetAttribute("MarkerRoom", marker.room)

			if marker.kind ~= "spawn" then
				local pillar = PartKit.part({
					name = "Beacon",
					size = { style.size * 0.35, style.height, style.size * 0.35 },
					color = style.color,
					material = Enum.Material.Neon,
					transparency = 0.6,
					canCollide = false,
					canQuery = false,
					castShadow = false,
					parent = markersFolder,
				})
				pillar.Position =
					Vector3.new(position.X, (map.origin and map.origin.y or 0) + style.height / 2, position.Z)
			end

			local stylePrompt = style.prompt
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = stylePrompt or "Examinar"
			prompt.ObjectText = style.label
			prompt.HoldDuration = marker.kind == "clue" and Config.Clues.INTERACT_TIME or 0.4
			prompt.MaxActivationDistance = Config.Players.INTERACT_RANGE
			prompt.RequiresLineOfSight = false
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
			prompt.Enabled = marker.kind ~= "spawn" and marker.kind ~= "monster"
			prompt.Parent = part

			markers[marker.id] = {
				id = marker.id,
				kind = marker.kind,
				room = marker.room,
				position = part.Position,
				part = part,
				prompt = prompt,
				offset = marker.offset,
			}

			if prompt.Enabled then
				table.insert(interactables, markers[marker.id])
			end
		else
			warn(("[MapBuilder] Marker sem posição: %s (%s)"):format(marker.id, map.id))
		end
	end

	-- pontos de patrulha para a IA (células marcadas como patrulha)
	local patrolPoints = {}
	for _, room in ipairs(Locations.roomTagged(map, "patrol")) do
		local centre = roomWorldCentre(map, room)
		table.insert(patrolPoints, Vector3.new(centre.X, (map.origin and map.origin.y or 0), centre.Z))
	end
	for tag in pairs({
		pier = true,
		lighthouse = true,
		hotel_floor3 = true,
		circus_ring = true,
		factory_floor = true,
		road = true,
		farm = true,
		mansion_hall = true,
	}) do
		for _, room in ipairs(Locations.roomTagged(map, tag)) do
			local centre = roomWorldCentre(map, room)
			table.insert(patrolPoints, Vector3.new(centre.X, (map.origin and map.origin.y or 0), centre.Z))
		end
	end

	-- marcas de props que bloqueiam movimento entram na grade de navegação
	for _, descendant in ipairs(mapModel:GetDescendants()) do
		if descendant:IsA("Model") and descendant:GetAttribute("BlocksMovement") then
			local pivot = descendant:GetPivot()
			local cx, cz = nav:WorldToCell(pivot.Position)
			if cx and cz then
				nav:SetBlocked(cx, cz, true)
			end
		end
	end

	return markers, interactables, patrolPoints
end

-- ==========================================================
-- BUILD PRINCIPAL
-- ==========================================================
local builtMaps = {}

function MapBuilder.build(mapId)
	if builtMaps[mapId] then
		return builtMaps[mapId]
	end

	local map = Locations.getMap(mapId)
	local root = getRoot()

	local existing = root:FindFirstChild("MAP_" .. mapId)
	if existing then
		existing:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = "MAP_" .. mapId

	local geometry = ensureFolder(model, "Geometry")
	local props = ensureFolder(model, "Props")

	local nav = buildNav(map)
	buildGround(map, geometry)
	local roomInfo = buildRooms(map, nav, geometry)

	-- Props declarados
	local mapPropsFolder = ensureFolder(props, "Declared")
	for _, propSpec in ipairs(map.props or {}) do
		local position = nil
		if propSpec.marker then
			position = Locations.markerPosition(map, propSpec.marker)
		elseif propSpec.room then
			local room = Locations.getRoom(map, propSpec.room)
			if room then
				local centre = roomWorldCentre(map, room)
				local offset = propSpec.offset or { x = 0, z = 0 }
				position = Vector3.new(centre.X + offset.x, centre.Y, centre.Z + offset.z)
			end
		end
		if position then
			local height = propSpec.height
			if height then
				position = Vector3.new(position.X, position.Y + height, position.Z)
			end
			PartKit.buildProp(
				propSpec.type,
				Props.Library,
				PartKit.originCFrame(position, propSpec.rotY or 0),
				mapPropsFolder,
				{ scale = propSpec.scale, episode = propSpec.episode }
			)
		else
			warn(("[MapBuilder] Prop %s sem posição no mapa %s"):format(propSpec.type, mapId))
		end
	end

	-- Decoração automática por tipo de sala
	Decorator.decorate(map, model, roomInfo, props)

	model.Parent = root

	local markers, interactables, patrolPoints = buildMarkers(map, model, model, nav)

	-- Teleportes (links tipo elevador)
	local links = {}
	for _, link in ipairs(map.links or {}) do
		local from = Locations.markerPosition(map, link.from)
		local to = Locations.markerPosition(map, link.to)
		if from and to then
			table.insert(links, { id = link.id, from = from, to = to, cost = link.cost or 1 })
		end
	end

	local built = {
		id = mapId,
		data = map,
		model = model,
		nav = nav,
		markers = markers,
		interactables = interactables,
		patrolPoints = patrolPoints,
		links = links,
		rooms = roomInfo,
		origin = map.origin or { x = 0, y = 0, z = 0 },
	}

	builtMaps[mapId] = built
	return built
end

function MapBuilder.getBuilt(mapId)
	return builtMaps[mapId]
end

function MapBuilder.buildAll()
	for mapId in pairs(Locations.Maps) do
		MapBuilder.build(mapId)
	end
end

function MapBuilder.markerPosition(mapId, markerId)
	local built = MapBuilder.getBuilt(mapId)
	if not built then
		return nil
	end
	local marker = built.markers[markerId]
	if marker then
		return marker.position, marker
	end
	-- fallback: id pode ser uma sala
	return Locations.markerPosition(built.data, markerId)
end

function MapBuilder.getMarker(mapId, markerId)
	local built = MapBuilder.getBuilt(mapId)
	if not built then
		return nil
	end
	return built.markers[markerId]
end

function MapBuilder.roomCentre(mapId, roomId)
	local built = MapBuilder.getBuilt(mapId)
	if not built then
		return nil
	end
	local room = built.rooms[roomId]
	if room then
		return room.centre
	end
	return nil
end

return MapBuilder
