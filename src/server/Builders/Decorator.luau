--[[
	Decorator.luau
	Decora cada sala do mapa de acordo com `Props.RoomThemes[room.kind]`.

	Regras:
		wall    = encosta nas 4 paredes da sala
		corner  = os 4 cantos
		center  = centro geométrico
		scatter = posições pseudo-aleatórias com semente fixa (determinístico:
		          o mapa é sempre igual para todos os jogadores)

	Também cria o "prop principal" de pistas (um objeto examinável) para os
	markers de pista que não têm prop declarado, para a interação ficar visual.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Props = require(Shared.Data.Props)

local PartKit = require(script.Parent.PartKit)

local Decorator = {}

local CLUE_PROPS = { "ammeter_case", "crate_stack_small", "barrel", "candidate_note" }

local function clamp(value, minimum, maximum)
	if value < minimum then
		return minimum
	end
	if value > maximum then
		return maximum
	end
	return value
end

-- Semente determinística por sala (mesmo mapa = mesma decoração em todos os servidores)
local function seedFor(text)
	local hash = 0
	for index = 1, #text do
		hash = (hash * 31 + string.byte(text, index)) % 2147483647
	end
	return hash
end

local function roomCentre(map, room)
	local cell = map.cellSize or 8
	local origin = map.origin or { x = 0, y = 0, z = 0 }
	return Vector3.new(
		origin.x + (room.x + room.w / 2 - 0.5) * cell,
		origin.y,
		origin.z + (room.z + room.d / 2 - 0.5) * cell
	),
		cell
end

local function placeAt(propType, position, rotY, parent, scale)
	return PartKit.buildProp(propType, Props.Library, PartKit.originCFrame(position, rotY), parent, {
		scale = scale,
	})
end

function Decorator.decorate(map, model, roomInfo, propsFolder)
	local folder = propsFolder:FindFirstChild("Themed")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Themed"
		folder.Parent = propsFolder
	end

	local RNG = Random.new(seedFor(map.id))

	for _, room in ipairs(map.rooms) do
		local roomTheme = Props.getTheme(room.kind)
		local centre, cell = roomCentre(map, room)
		local halfWidth = room.w * cell / 2
		local halfDepth = room.d * cell / 2

		local slotIndex = 0

		for _, entry in ipairs(roomTheme.props) do
			local count = entry.count or 1
			if count > 0 then
				for _ = 1, count do
					slotIndex += 1
					local position, rotY

					if entry.placement == "wall" then
						local side = slotIndex % 4
						local t = RNG:NextNumber(0.3, 0.7)
						if side == 0 then
							position =
								Vector3.new(centre.X - halfWidth + 4, centre.Y, centre.Z + (t - 0.5) * room.d * cell)
							rotY = 90
						elseif side == 1 then
							position =
								Vector3.new(centre.X + halfWidth - 4, centre.Y, centre.Z + (t - 0.5) * room.d * cell)
							rotY = -90
						elseif side == 2 then
							position =
								Vector3.new(centre.X + (t - 0.5) * room.w * cell, centre.Y, centre.Z - halfDepth + 4)
							rotY = 0
						else
							position =
								Vector3.new(centre.X + (t - 0.5) * room.w * cell, centre.Y, centre.Z + halfDepth - 4)
							rotY = 180
						end
					elseif entry.placement == "corner" then
						local corner = slotIndex % 4
						local offsetX = (corner == 0 or corner == 1) and -1 or 1
						local offsetZ = (corner == 0 or corner == 3) and -1 or 1
						position = Vector3.new(
							centre.X + offsetX * math.max(6, halfWidth - 6),
							centre.Y,
							centre.Z + offsetZ * math.max(6, halfDepth - 6)
						)
						rotY = RNG:NextInteger(0, 3) * 90
					elseif entry.placement == "center" then
						position = Vector3.new(centre.X, centre.Y, centre.Z)
						rotY = RNG:NextInteger(0, 3) * 90
					else
						-- scatter
						local spread = entry.spread or 0.7
						position = Vector3.new(
							centre.X + (RNG:NextNumber() - 0.5) * room.w * cell * spread,
							centre.Y,
							centre.Z + (RNG:NextNumber() - 0.5) * room.d * cell * spread
						)
						rotY = RNG:NextInteger(0, 3) * 90
					end

					placeAt(entry.type, position, rotY, folder, entry.scale)
				end
			end
		end
	end

	-- Props "examináveis" para markers de pista sem prop dedicado
	local clueFolder = propsFolder:FindFirstChild("Clues")
	if not clueFolder then
		clueFolder = Instance.new("Folder")
		clueFolder.Name = "Clues"
		clueFolder.Parent = propsFolder
	end

	for _, marker in ipairs(map.markers) do
		if marker.kind == "clue" then
			local position = require(Shared.Data.Locations).markerPosition(map, marker.id)
			if position then
				local propType = CLUE_PROPS[(seedFor(marker.id) % #CLUE_PROPS) + 1]
				local built = placeAt(
					propType,
					Vector3.new(position.X, position.Y, position.Z),
					RNG:NextInteger(0, 3) * 90,
					clueFolder
				)
				if built then
					built:SetAttribute("ClueMarker", marker.id)
					local interactPart = built:FindFirstChild("Parts")
						and built.Parts:FindFirstChildWhichIsA("BasePart")
					if interactPart then
						interactPart:SetAttribute("InteractKind", "clue")
						interactPart:SetAttribute("ClueMarker", marker.id)
						interactPart.Name = "InteractPart"
					end
					PartKit.highlight(built, "Accent", { fillTransparency = 0.85, outlineTransparency = 0.35 })
				end
			end
		end
	end
end

return Decorator
