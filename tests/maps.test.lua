local T = require("tests/runner")
local Locations = require("Locations")
local GridNav = require("GridNav")
local Episodes = require("Episodes")
local Cast = require("Cast")
local Props = require("Props")

local CELL = 8

-- Constrói o grafo de navegação de um mapa (mesma lógica do servidor)
local function buildNav(map)
	local origin = map.origin or { x = 0, y = 0, z = 0 }
	local nav = GridNav.new({
		width = map.width,
		depth = map.depth,
		cellSize = map.cellSize or CELL,
		origin = Vector3.new(origin.x, origin.y, origin.z),
	})
	nav:BlockAll()
	local function carve(rect)
		for x = rect.x, rect.x + rect.w - 1 do
			for z = rect.z, rect.z + rect.d - 1 do
				nav:SetCell(x, z, { walkable = true })
			end
		end
	end
	for _, room in ipairs(map.rooms) do
		carve(room)
	end
	for _, corridor in ipairs(map.corridors) do
		carve(corridor)
	end
	return nav
end

local function pathExists(nav, fromMarker, toMarker)
	local fromX, fromZ = nav:FindNearestWalkableWorld(fromMarker, 6)
	local toX, toZ = nav:FindNearestWalkableWorld(toMarker, 6)
	if not fromX or not toX then
		return false, "sem célula caminhável próxima"
	end
	local path = nav:FindPath(fromX, fromZ, toX, toZ)
	if #path == 0 then
		return false, "sem caminho"
	end
	return true
end

-- Validação estrutural
local ok, problems = Locations.validate()
T.check(ok, "Locations.validate() sem problemas" .. (ok and "" or (": " .. table.concat(problems, " | "))))

local propsOk, propProblems = Props.validate()
T.check(propsOk, "Props.validate() sem problemas" .. (propsOk and "" or (": " .. table.concat(propProblems, " | "))))

-- Cada mapa precisa ser jogável: spawn -> todos os markers -> saída
for mapId, map in pairs(Locations.Maps) do
	local nav = buildNav(map)
	local spawnPos, spawnMarker = Locations.markerPosition(map, map.spawns.players)
	T.check(spawnPos ~= nil, ("%s: marker de spawn do jogador existe (%s)"):format(mapId, tostring(map.spawns.players)))

	if spawnPos then
		local unreachable = {}
		for _, marker in ipairs(map.markers) do
			if marker.kind ~= "spawn" then
				local position = Locations.markerPosition(map, marker.id)
				if position then
					local reachable, reason = pathExists(nav, spawnPos, position)
					if not reachable then
						table.insert(unreachable, marker.id .. " (" .. tostring(reason) .. ")")
					end
				end
			end
		end
		T.check(#unreachable == 0, ("%s: todos os markers alcançáveis a pé (%d inalcançáveis%s)"):format(
			mapId,
			#unreachable,
			#unreachable > 0 and (": " .. table.concat(unreachable, ", ")) or ""
		))

		-- saída
		local exitPos = Locations.markerPosition(map, map.spawns.exit)
		if exitPos then
			local reachable = pathExists(nav, spawnPos, exitPos)
			T.check(reachable, mapId .. ": saída do mapa é alcançável")
		end

		-- spawn do monstro
		if map.spawns.monster then
			local monsterPos = Locations.markerPosition(map, map.spawns.monster)
			T.check(monsterPos ~= nil, mapId .. ": spawn do monstro existe")
			if monsterPos then
				T.check(pathExists(nav, spawnPos, monsterPos), mapId .. ": monstro nasce em área alcançável")
			end
		end
	end
end

-- Todo capítulo precisa de capítulos anteriores coerentes e markers existentes no mapa
for _, chapter in ipairs(Episodes.allChapters()) do
	local map = Locations.getMap(chapter.location)
	T.check(map ~= nil and map.id == chapter.location, "capítulo " .. chapter.id .. " aponta para mapa existente (" .. chapter.location .. ")")

	if map then
		for _, objective in ipairs(chapter.objectives) do
			if objective.marker then
				local position = Locations.markerPosition(map, objective.marker)
				T.check(position ~= nil, ("capítulo %s: marker %s existe em %s"):format(chapter.id, objective.marker, chapter.location))
			end
		end
		for _, spot in ipairs(chapter.trapSpots or {}) do
			local room = Locations.getRoom(map, spot.room)
			T.check(room ~= nil or Locations.markerPosition(map, spot.room) ~= nil,
				("capítulo %s: ponto de armadilha %s existe"):format(chapter.id, spot.room))
		end
		for _, npcId in ipairs(chapter.npcs or {}) do
			local npc = Cast.getNpc(npcId)
			T.check(npc ~= nil, ("capítulo %s: NPC %s existe no elenco"):format(chapter.id, npcId))
			if npc then
				local home = Locations.getRoom(map, npc.homeRoom)
				T.check(home ~= nil, ("capítulo %s: casa do NPC %s existe no mapa (%s)"):format(chapter.id, npc.id, npc.homeRoom))
			end
		end
	end
end

-- O lobby precisa ter os marcadores usados no prólogo
local lobby = Locations.Maps.Lobby
for _, markerId in ipairs({ "Lobby_Fita", "Lobby_Quadro", "Lobby_Scooby", "Lobby_Van" }) do
	T.check(Locations.markerPosition(lobby, markerId) ~= nil, "lobby tem o marker " .. markerId)
end

-- Área caminhável mínima por mapa (mapas pequenos demais indicam erro de autoria)
for mapId, map in pairs(Locations.Maps) do
	local coverage = Locations.coveragePercent(map)
	T.check(coverage >= 8, ("%s: área caminhável suficiente (%.1f%%)"):format(mapId, coverage))
end

-- Capítulos: deduções, pontos de armadilha, monstro e recompensas
for _, chapter in ipairs(Episodes.allChapters()) do
	local map = Locations.getMap(chapter.location)

	-- deduções: exatamente uma opção correta e feedback em todas
	for _, deduction in ipairs(chapter.deductions or {}) do
		local correct = 0
		for _, option in ipairs(deduction.options or {}) do
			if option.correct then
				correct += 1
			end
			T.check(option.feedback ~= nil, ("%s/%s: opção tem feedback"):format(chapter.id, deduction.id))
		end
		T.equal(correct, 1, ("%s/%s tem exatamente uma resposta correta"):format(chapter.id, deduction.id))
		T.check(deduction.points and deduction.points > 0, ("%s/%s vale pontos"):format(chapter.id, deduction.id))
	end

	-- pontos de armadilha: precisam existir no mapa (marker ou sala)
	for _, spot in ipairs(chapter.trapSpots or {}) do
		local markerPosition = map and Locations.markerPosition(map, spot.id)
		local room = map and Locations.getRoom(map, spot.room or spot.id)
		T.check(markerPosition ~= nil or room ~= nil,
			("%s: ponto de armadilha %s existe no mapa"):format(chapter.id, spot.id))
	end

	-- os objetivos de armadilha devem apontar para markers que existem
	for _, objective in ipairs(chapter.objectives or {}) do
		if objective.marker and map then
			T.check(Locations.markerPosition(map, objective.marker) ~= nil,
				("%s: marker do objetivo %s existe"):format(chapter.id, objective.id))
		end
	end

	-- monstro do episódio nasce em um lugar válido
	local monster = Cast.getMonster(chapter.episode)
	if monster and monster.ai and map then
		T.check(Locations.markerPosition(map, monster.ai.spawnPoint) ~= nil,
			("%s: spawn do monstro %s existe no mapa"):format(chapter.id, monster.ai.spawnPoint))
	end

	-- monstro aparece depois de um objetivo existente
	if chapter.monsterIntro and chapter.monsterIntro.objective then
		local found = false
		for _, objective in ipairs(chapter.objectives or {}) do
			if objective.id == chapter.monsterIntro.objective then
				found = true
			end
		end
		T.check(found, ("%s: monstro aparece depois de objetivo válido"):format(chapter.id))
	end

	-- recompensas e próximo capítulo
	T.check(chapter.rewards ~= nil, ("%s: tem recompensas"):format(chapter.id))
	if chapter.nextChapter then
		T.check(Episodes.getChapter(chapter.nextChapter) ~= nil,
			("%s: próximo capítulo %s existe"):format(chapter.id, chapter.nextChapter))
	end
end

local summary, failed = T.report()
if failed > 0 then
	error("maps.test.lua:\n" .. summary)
end
return summary
