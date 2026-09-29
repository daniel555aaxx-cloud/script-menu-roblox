--[[
	Util.luau
	Funções utilitárias puras (sem dependências de serviços) compartilhadas
	entre cliente e servidor. Mantidas "testáveis" de propósito.
]]

local Util = {}

function Util.clamp(value, minimum, maximum)
	if value < minimum then
		return minimum
	elseif value > maximum then
		return maximum
	end
	return value
end

function Util.round(value, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(value * mult + 0.5) / mult
end

function Util.lerp(a, b, alpha)
	return a + (b - a) * alpha
end

function Util.inverseLerp(a, b, value)
	if a == b then
		return 0
	end
	return Util.clamp((value - a) / (b - a), 0, 1)
end

function Util.formatClock(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	local minutes = math.floor(seconds / 60)
	local rest = seconds % 60
	return string.format("%02d:%02d", minutes, rest)
end

function Util.titleCase(text)
	return (text:gsub("(%a)([%w']*)", function(first, rest)
		return first:upper() .. rest:lower()
	end))
end

function Util.deepCopy(value, seen)
	seen = seen or {}
	if type(value) ~= "table" then
		return value
	end
	if seen[value] then
		return seen[value]
	end
	local copy = {}
	seen[value] = copy
	for key, item in pairs(value) do
		copy[Util.deepCopy(key, seen)] = Util.deepCopy(item, seen)
	end
	return setmetatable(copy, getmetatable(value))
end

function Util.deepMerge(target, source)
	for key, value in pairs(source) do
		if type(value) == "table" and type(target[key]) == "table" then
			Util.deepMerge(target[key], value)
		else
			target[key] = Util.deepCopy(value)
		end
	end
	return target
end

function Util.count(tbl)
	local total = 0
	for _ in pairs(tbl) do
		total += 1
	end
	return total
end

function Util.keys(tbl)
	local list = {}
	for key in pairs(tbl) do
		table.insert(list, key)
	end
	table.sort(list, function(a, b)
		return tostring(a) < tostring(b)
	end)
	return list
end

function Util.contains(list, value)
	for _, item in ipairs(list) do
		if item == value then
			return true
		end
	end
	return false
end

function Util.indexOf(list, value)
	for index, item in ipairs(list) do
		if item == value then
			return index
		end
	end
	return nil
end

function Util.filter(list, predicate)
	local result = {}
	for _, item in ipairs(list) do
		if predicate(item) then
			table.insert(result, item)
		end
	end
	return result
end

function Util.map(list, mapper)
	local result = table.create(#list)
	for index, item in ipairs(list) do
		result[index] = mapper(item, index)
	end
	return result
end

function Util.shuffle(list, rng)
	rng = rng or Random.new()
	for index = #list, 2, -1 do
		local swap = rng:NextInteger(1, index)
		list[index], list[swap] = list[swap], list[index]
	end
	return list
end

function Util.newRandom(seed)
	if seed then
		return Random.new(seed)
	end
	return Random.new(os.time() + math.floor(os.clock() * 1000))
end

function Util.weightedPick(entries, rng)
	-- entries: { { weight = number, value = any }, ... }
	rng = rng or Random.new()
	local total = 0
	for _, entry in ipairs(entries) do
		total += entry.weight or 1
	end
	local roll = rng:NextNumber() * total
	local accumulated = 0
	for _, entry in ipairs(entries) do
		accumulated += entry.weight or 1
		if roll <= accumulated then
			return entry.value
		end
	end
	return entries[#entries] and entries[#entries].value
end

function Util.makeId(prefix, length)
	local charset = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	local rng = Random.new()
	local buffer = {}
	for _ = 1, (length or 5) do
		local index = rng:NextInteger(1, #charset)
		table.insert(buffer, charset:sub(index, index))
	end
	return (prefix or "") .. table.concat(buffer)
end

function Util.newGuid()
	local rng = Random.new()
	local parts = {}
	for index = 1, 4 do
		parts[index] = string.format("%04x", rng:NextInteger(0, 0xFFFF))
	end
	return table.concat(parts, "-")
end

function Util.truncate(text, limit)
	if #text <= limit then
		return text
	end
	return text:sub(1, limit - 1) .. "…"
end

function Util.split(text, separator)
	local parts = {}
	for piece in string.gmatch(text, "([^" .. (separator or ",") .. "]+)") do
		table.insert(parts, piece)
	end
	return parts
end

function Util.startsWith(text, prefix)
	return text:sub(1, #prefix) == prefix
end

function Util.between(value, minimum, maximum)
	return value >= minimum and value <= maximum
end

function Util.horizontalDistance(a, b)
	local deltaX = a.X - b.X
	local deltaZ = a.Z - b.Z
	return math.sqrt(deltaX * deltaX + deltaZ * deltaZ)
end

function Util.flatVector(vector)
	return Vector3.new(vector.X, 0, vector.Z)
end

-- Converte um mundo (Vector3) em chave de célula "x,z"
function Util.cellKey(x, z)
	return x .. "," .. z
end

return Util
