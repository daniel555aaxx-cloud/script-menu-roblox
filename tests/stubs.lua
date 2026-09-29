-- Stubs mínimos para rodar os módulos de dados fora do Roblox (Node + wasmoon)
Vector3 = {}
Vector3.__index = Vector3
function Vector3.new(x, y, z)
	return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, Vector3)
end
function Vector3.__add(a, b) return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
function Vector3.__sub(a, b) return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
function Vector3.__eq(a, b) return a.X == b.X and a.Y == b.Y and a.Z == b.Z end
function Vector3.__tostring(v) return string.format("(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z) end
function Vector3.__mul(a, s)
	if type(a) == "number" then return Vector3.new(a * s.X, a * s.Y, a * s.Z) end
	return Vector3.new(a.X * s, a.Y * s, a.Z * s)
end

Color3 = {}
function Color3.fromRGB(r, g, b) return { R = (r or 0) / 255, G = (g or 0) / 255, B = (b or 0) / 255, r = r or 0, g = g or 0, b = b or 0 } end
function Color3.new(r, g, b) return { R = r or 0, G = g or 0, B = b or 0 } end

Random = {}
Random.__index = Random
function Random.new(seed)
	local self = setmetatable({}, Random)
	if seed then math.randomseed(seed) end
	return self
end
function Random:NextInteger(minimum, maximum) return math.random(minimum, maximum) end
function Random:NextNumber(minimum, maximum)
	minimum = minimum or 0
	maximum = maximum or 1
	return minimum + math.random() * (maximum - minimum)
end
function Random:Clone() return Random.new() end

typeof = function(value)
	if type(value) == "table" and getmetatable(value) == Vector3 then return "Vector3" end
	if type(value) == "table" and getmetatable(value) == Color3 then return "Color3" end
	return type(value)
end

-- task/utility stubs (os módulos de dados não usam, mas o GridNav usa Random)
task = { spawn = function(fn, ...) fn(...) end, wait = function() end, defer = function(fn) fn() end }
os.clock = os.clock or function() return 0 end
