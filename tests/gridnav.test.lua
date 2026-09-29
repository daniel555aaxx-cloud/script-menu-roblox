local T = require("tests/runner")
local GridNav = require("GridNav")

-- Grade 10x10 totalmente aberta
local nav = GridNav.new({ width = 10, depth = 10, cellSize = 8 })
local path = nav:FindPath(1, 1, 10, 10)
T.check(#path > 0, "A* encontra caminho na diagonal em grade aberta")
T.check(path[1].x == 1 and path[1].z == 1, "caminho começa no início")
T.check(path[#path].x == 10 and path[#path].z == 10, "caminho termina no objetivo")

-- Obstáculo com desvio
local nav2 = GridNav.new({ width = 12, depth = 6, cellSize = 8 })
for x = 2, 11 do
	nav2:SetBlocked(x, 3, true)
end
nav2:SetBlocked(11, 3, false)
local path2 = nav2:FindPath(1, 1, 11, 5)
T.check(#path2 > 0, "A* contorna parede com passagem")
local blockedCrossed = false
for _, node in ipairs(path2) do
	if node.x >= 2 and node.x <= 10 and node.z == 3 then
		blockedCrossed = true
	end
end
T.check(not blockedCrossed, "A* não atravessa bloco bloqueado")

-- Sem caminho
local nav3 = GridNav.new({ width = 5, depth = 5, cellSize = 8 })
for x = 1, 5 do
	nav3:SetBlocked(x, 3, true)
end
local path3 = nav3:FindPath(1, 1, 1, 5)
T.check(#path3 == 0, "A* retorna vazio quando não há caminho")

-- Linha de visão
T.check(nav2:HasLineOfSight(1, 1, 2, 1), "linha de visão livre em célula adjacente")
T.check(not nav2:HasLineOfSight(5, 2, 5, 4), "linha de visão bloqueada por parede")

-- Caminho simplificado sempre liga começo e fim
local simplified = nav:Simplify(nav:FindPath(1, 1, 10, 10))
T.check(#simplified >= 2, "simplificação mantém ao menos 2 pontos")
T.check(simplified[1].x == 1 and simplified[#simplified].x == 10, "simplificação preserva extremos")

-- Tags e busca por tag
local nav4 = GridNav.new({ width = 8, depth = 8, cellSize = 8 })
nav4:SetCell(4, 4, { tag = "patrol" })
nav4:SetCell(5, 5, { tag = "patrol" })
T.check(#nav4:GetTagged("patrol") == 2, "GetTagged retorna células marcadas")
local tx, tz = nav4:RandomWalkable(Random.new(7), "patrol")
T.check((tx == 4 or tx == 5) and (tz == 4 or tz == 5), "RandomWalkable respeita a tag")

-- Coordenadas de mundo
local nav5 = GridNav.new({ width = 10, depth = 10, cellSize = 8, origin = Vector3.new(100, 0, 200) })
local world = nav5:CellToWorld(2, 3, 0)
local cx, cz = nav5:WorldToCell(world)
T.check(cx == 2 and cz == 3, "conversão mundo <-> célula é consistente")

local summary, failed = T.report()
if failed > 0 then
	error("gridnav.test.lua: " .. summary)
end
return summary
