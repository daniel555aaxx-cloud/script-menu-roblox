--[[
	GridNav.luau
	Grafo de navegação em grade + A* puro (sem dependência de engine).
	É usado pelos NPCs, pelo monstro e pelo sistema de dicas.
	Como não usa PathfindingService, funciona igual no servidor e em testes offline.
]]

local GridNav = {}
GridNav.__index = GridNav

local DIRS_4 = {
	{ 1, 0 },
	{ -1, 0 },
	{ 0, 1 },
	{ 0, -1 },
}

local DIRS_8 = {
	{ 1, 0 },
	{ -1, 0 },
	{ 0, 1 },
	{ 0, -1 },
	{ 1, 1 },
	{ 1, -1 },
	{ -1, 1 },
	{ -1, -1 },
}

local SQRT2 = math.sqrt(2)

function GridNav.new(options)
	local self = setmetatable({}, GridNav)
	options = options or {}
	self.width = options.width or 40
	self.depth = options.depth or 40
	self.cellSize = options.cellSize or 8
	self.origin = options.origin or Vector3.new(0, 0, 0)
	self.cells = {}
	self.allowDiagonal = options.allowDiagonal ~= false
	self.tags = {} -- tag -> { "x,z", ... }
	return self
end

function GridNav:key(x, z)
	return x .. "," .. z
end

function GridNav:InBounds(x, z)
	return x >= 1 and x <= self.width and z >= 1 and z <= self.depth
end

function GridNav:GetCell(x, z)
	if not self:InBounds(x, z) then
		return nil
	end
	local cell = self.cells[self:key(x, z)]
	if not cell then
		cell = { walkable = true, cost = 1, tag = nil }
		self.cells[self:key(x, z)] = cell
	end
	return cell
end

function GridNav:IsWalkable(x, z)
	local cell = self:GetCell(x, z)
	return cell ~= nil and cell.walkable
end

function GridNav:SetCell(x, z, data)
	if not self:InBounds(x, z) then
		return
	end
	local cell = self:GetCell(x, z)
	if data.walkable ~= nil then
		cell.walkable = data.walkable
	end
	if data.cost then
		cell.cost = data.cost
	end
	if data.tag then
		cell.tag = data.tag
		self.tags[data.tag] = self.tags[data.tag] or {}
		table.insert(self.tags[data.tag], self:key(x, z))
	end
	if data.clearTag and cell.tag then
		local list = self.tags[cell.tag]
		if list then
			local index = table.find(list, self:key(x, z))
			if index then
				table.remove(list, index)
			end
		end
		cell.tag = nil
	end
end

function GridNav:SetBlocked(x, z, blocked)
	self:SetCell(x, z, { walkable = not blocked })
end

function GridNav:FillRect(x0, z0, x1, z1, data)
	for x = x0, x1 do
		for z = z0, z1 do
			self:SetCell(x, z, data)
		end
	end
end

-- Bloqueia tudo e depois abre corredores/salas (útil para mapas "escavados")
function GridNav:BlockAll()
	for x = 1, self.width do
		for z = 1, self.depth do
			self:GetCell(x, z).walkable = false
		end
	end
end

function GridNav:WorldToCell(position)
	local x = math.floor((position.X - self.origin.X) / self.cellSize) + 1
	local z = math.floor((position.Z - self.origin.Z) / self.cellSize) + 1
	return x, z
end

function GridNav:CellToWorld(x, z, yOffset)
	return Vector3.new(
		self.origin.X + (x - 0.5) * self.cellSize,
		self.origin.Y + (yOffset or 0),
		self.origin.Z + (z - 0.5) * self.cellSize
	)
end

function GridNav:FindNearestWalkable(x, z, maxRadius)
	maxRadius = maxRadius or 12
	if self:IsWalkable(x, z) then
		return x, z
	end
	for radius = 1, maxRadius do
		for _, dir in ipairs(DIRS_8) do
			local candidateX = x + dir[1] * radius
			local candidateZ = z + dir[2] * radius
			if self:IsWalkable(candidateX, candidateZ) then
				return candidateX, candidateZ
			end
		end
	end
	return nil
end

function GridNav:FindNearestWalkableWorld(position, maxRadius)
	local x, z = self:WorldToCell(position)
	return self:FindNearestWalkable(x, z, maxRadius)
end

function GridNav:Neighbors(x, z)
	local list = {}
	local dirs = self.allowDiagonal and DIRS_8 or DIRS_4
	for _, dir in ipairs(dirs) do
		local nx, nz = x + dir[1], z + dir[2]
		if self:IsWalkable(nx, nz) then
			if dir[1] ~= 0 and dir[2] ~= 0 then
				-- evita "cortar quina" na diagonal
				if self:IsWalkable(x + dir[1], z) and self:IsWalkable(x, z + dir[2]) then
					table.insert(list, { x = nx, z = nz, diagonal = true })
				end
			else
				table.insert(list, { x = nx, z = nz, diagonal = false })
			end
		end
	end
	return list
end

local function octile(ax, az, bx, bz)
	local dx = math.abs(ax - bx)
	local dz = math.abs(az - bz)
	return (dx + dz) + (SQRT2 - 2) * math.min(dx, dz)
end

function GridNav:FindPath(startX, startZ, goalX, goalZ, maxIterations, avoidTags)
	maxIterations = maxIterations or (self.width * self.depth * 4)
	avoidTags = avoidTags or {}

	if type(startX) ~= "number" or type(startZ) ~= "number" or type(goalX) ~= "number" or type(goalZ) ~= "number" then
		return {}
	end
	if not self:InBounds(startX, startZ) or not self:InBounds(goalX, goalZ) then
		return {}
	end

	local function blockedByTag(x, z)
		local cell = self:GetCell(x, z)
		if not cell or not cell.walkable then
			return true
		end
		for _, tag in ipairs(avoidTags) do
			if cell.tag == tag then
				return true
			end
		end
		return false
	end

	if blockedByTag(startX, startZ) then
		local fixedX, fixedZ = self:FindNearestWalkable(startX, startZ, 6)
		if not fixedX then
			return {}
		end
		startX, startZ = fixedX, fixedZ
	end
	if blockedByTag(goalX, goalZ) then
		local fixedX, fixedZ = self:FindNearestWalkable(goalX, goalZ, 6)
		if not fixedX then
			return {}
		end
		goalX, goalZ = fixedX, fixedZ
	end

	local startKey = self:key(startX, startZ)
	local goalKey = self:key(goalX, goalZ)
	if startKey == goalKey then
		return { { x = startX, z = startZ } }
	end

	local open = {}
	local openLookup = {}
	local cameFrom = {}
	local gScore = { [startKey] = 0 }
	local fScore = { [startKey] = octile(startX, startZ, goalX, goalZ) }

	local function push(node)
		table.insert(open, node)
		openLookup[node.key] = true
		local index = #open
		while index > 1 do
			local parent = math.floor(index / 2)
			if open[parent].f <= open[index].f then
				break
			end
			open[parent], open[index] = open[index], open[parent]
			index = parent
		end
	end

	local function pop()
		local root = open[1]
		local last = table.remove(open)
		openLookup[root.key] = nil
		if #open > 0 and last then
			open[1] = last
			local index = 1
			while true do
				local left, right = index * 2, index * 2 + 1
				local smallest = index
				if left <= #open and open[left].f < open[smallest].f then
					smallest = left
				end
				if right <= #open and open[right].f < open[smallest].f then
					smallest = right
				end
				if smallest == index then
					break
				end
				open[index], open[smallest] = open[smallest], open[index]
				index = smallest
			end
		end
		return root
	end

	push({ key = startKey, x = startX, z = startZ, f = fScore[startKey], g = 0 })

	local iterations = 0
	local found = false
	while #open > 0 do
		iterations += 1
		if iterations > maxIterations then
			break
		end
		local current = pop()
		if current.key == goalKey then
			found = true
			break
		end

		for _, neighbor in ipairs(self:Neighbors(current.x, current.z)) do
			local neighborKey = self:key(neighbor.x, neighbor.z)
			if not blockedByTag(neighbor.x, neighbor.z) then
				local cell = self:GetCell(neighbor.x, neighbor.z)
				local stepCost = (neighbor.diagonal and SQRT2 or 1) * (cell.cost or 1)
				local tentative = (gScore[current.key] or math.huge) + stepCost
				if tentative < (gScore[neighborKey] or math.huge) then
					cameFrom[neighborKey] = current
					gScore[neighborKey] = tentative
					fScore[neighborKey] = tentative + octile(neighbor.x, neighbor.z, goalX, goalZ) * 1.001
					if not openLookup[neighborKey] then
						push({
							key = neighborKey,
							x = neighbor.x,
							z = neighbor.z,
							f = fScore[neighborKey],
							g = tentative,
						})
					end
				end
			end
		end
	end

	if not found then
		return {}
	end

	local path = {}
	local cursor = { key = goalKey, x = goalX, z = goalZ }
	while cursor do
		table.insert(path, 1, { x = cursor.x, z = cursor.z })
		cursor = cameFrom[cursor.key]
	end
	return path
end

function GridNav:HasLineOfSight(ax, az, bx, bz)
	-- Bresenham na grade: retorna false se algum bloco estiver fechado
	local dx = math.abs(bx - ax)
	local dz = math.abs(bz - az)
	local sx = ax < bx and 1 or -1
	local sz = az < bz and 1 or -1
	local err = dx - dz
	local x, z = ax, az
	local guard = 0
	while guard < 4096 do
		guard += 1
		if x == bx and z == bz then
			return true
		end
		if not (x == ax and z == az) and not self:IsWalkable(x, z) then
			return false
		end
		local e2 = err * 2
		if e2 > -dz then
			err -= dz
			x += sx
		end
		if e2 < dx then
			err += dx
			z += sz
		end
	end
	return false
end

function GridNav:GetTagged(tag)
	local list = {}
	for _, cellKey in ipairs(self.tags[tag] or {}) do
		local xText, zText = cellKey:match("(%-?%d+),(%-?%d+)")
		if xText then
			local cell = self.cells[cellKey]
			if cell and cell.walkable then
				table.insert(list, { x = tonumber(xText), z = tonumber(zText), cell = cell })
			end
		end
	end
	return list
end

function GridNav:RandomWalkable(rng, tag)
	rng = rng or Random.new()
	local candidates = tag and self:GetTagged(tag) or nil
	if candidates and #candidates > 0 then
		local pick = candidates[rng:NextInteger(1, #candidates)]
		return pick.x, pick.z
	end
	for _ = 1, 200 do
		local x = rng:NextInteger(1, self.width)
		local z = rng:NextInteger(1, self.depth)
		if self:IsWalkable(x, z) then
			return x, z
		end
	end
	return nil
end

function GridNav:CountWalkable()
	local total = 0
	for _, cell in pairs(self.cells) do
		if cell.walkable then
			total += 1
		end
	end
	return total
end

-- Reduz um caminho em grade a uma lista de "waypoints" de canto (menos nós = movimento suave)
function GridNav:Simplify(path)
	if #path <= 2 then
		return path
	end
	local result = { path[1] }
	local index = 1
	while index < #path do
		local anchor = path[index]
		local furthest = index + 1
		for candidate = index + 2, #path do
			if self:HasLineOfSight(anchor.x, anchor.z, path[candidate].x, path[candidate].z) then
				furthest = candidate
			else
				break
			end
		end
		table.insert(result, path[furthest])
		index = furthest
	end
	return result
end

return GridNav
