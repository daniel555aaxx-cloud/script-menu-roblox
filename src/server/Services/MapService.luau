--[[
	MapService.luau
	Dono dos mapas em execução. Constrói tudo no boot (lobby + 7 mapas), guarda
	as instâncias construídas e move jogadores entre elas.

	Teleporte de personagem: como os mapas ficam a milhares de studs de distância,
	o serviço move o HumanoidRootPart direto (mais confiável que TeleportService).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Locations = require(Shared.Data.Locations)
local Graphics = require(Shared.Graphics)
local Net = require(Shared.Net)

local Builders = script.Parent.Parent.Builders
local MapBuilder = require(Builders.MapBuilder)

local MapService = {}

MapService.CurrentMap = {}

local START_MUSIC = "rbxasset://sounds/electronicpingshort.wav"

function MapService.start()
	MapBuilder.buildAll()

	-- streaming: mantém os mapas vivos (o servidor constrói tudo de uma vez)
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain.WaterWaveSize = 0.2
		terrain.WaterWaveSpeed = 8
		terrain.WaterTransparency = 0.35
	end

	Graphics.serverBaseLighting()
end

function MapService.getBuilt(mapId)
	return MapBuilder.getBuilt(mapId)
end

function MapService.setMood(mapId)
	local map = Locations.getMap(mapId)
	if map and map.mood then
		Graphics.applyMood(map.mood)
		Net.fireAll("ClientEffects", { mood = map.mood })
	end
end

-- ==========================================================
-- TELEPORTE
-- ==========================================================
function MapService.teleportTo(player, mapId, position, options)
	options = options or {}
	local character = player.Character
	if not character then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end

	local target = position
	if typeof(target) ~= "Vector3" then
		local markerId = target or Locations.getMap(mapId).spawns.players
		local markerPosition = MapBuilder.markerPosition(mapId, markerId)
		target = markerPosition or Vector3.new(0, 8, 0)
	end

	-- o mapa guarda o Y do "chão" em origin.y
	local map = Locations.getMap(mapId)
	local groundY = (map.origin and map.origin.y or 0)
	local offset = options.height or 4

	character:PivotTo(CFrame.new(target.X, groundY + offset, target.Z))
	root.AssemblyLinearVelocity = Vector3.zero

	MapService.CurrentMap[player] = mapId
	player:SetAttribute("CurrentMap", mapId)

	if options.mood ~= false then
		MapService.setMood(mapId)
	end
	return true
end

function MapService.teleportToRoom(player, mapId, roomId, options)
	local room = Locations.getRoom(mapId, roomId)
	if not room then
		return false
	end
	local built = MapBuilder.getBuilt(mapId)
	local centre = built and built.rooms[roomId] and built.rooms[roomId].centre
	if not centre then
		local locationMap = Locations.getMap(mapId)
		centre = Locations.roomCenter(locationMap, room)
	end
	return MapService.teleportTo(player, mapId, centre, options)
end

function MapService.teleportParty(party, mapId, markerId, options)
	for _, member in ipairs(party) do
		MapService.teleportTo(member, mapId, markerId, options)
	end
end

function MapService.getMapOf(player)
	return MapService.CurrentMap[player]
end

-- ==========================================================
-- RESPAWN
-- ==========================================================
function MapService.respawn(player, mapId, markerId)
	local map = Locations.getMap(mapId)
	local spawnMarker = markerId or map.spawns.players
	MapService.teleportTo(player, mapId, spawnMarker)
end

return MapService
