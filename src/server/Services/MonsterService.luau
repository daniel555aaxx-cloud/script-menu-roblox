--[[
	MonsterService.luau
	IA do monstro do episódio.

	Estados:
		PATROL  -> anda entre pontos de patrulha (usa o A* do GridNav)
		SEARCH  -> foi até a última posição conhecida do jogador
		CHASE   -> persegue o alvo visível
		LURED   -> foi atraído por uma isca (Scooby Snack / distração)
		CAPTURED/STUNNED -> preso na armadilha (fim do capítulo)

	Toda a movimentação é feita movendo o modelo rígido construído pelo
	CharacterBuilder (seta HumanoidRootPart.CFrame ao longo do caminho).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Cast = require(Shared.Data.Cast)
local Dialogue = require(Shared.Data.Dialogue)
local Net = require(Shared.Net)
local Signal = require(Shared.Signal)
local Util = require(Shared.Util)

local Builders = script.Parent.Parent.Builders
local CharacterBuilder = require(Builders.CharacterBuilder)

local Services = script.Parent
local MapService = require(Services.MapService)
local TrapService = require(Services.TrapService)

local MonsterService = {}

MonsterService.StateChanged = Signal.new()
MonsterService.PlayerCaught = Signal.new()

-- runtime[chapterId] = { model, joints, monster, state, target, path, position, ... }
local runtime = {}

local STATE = {
	Patrol = "patrol",
	Search = "search",
	Chase = "chase",
	Lured = "lured",
	Stunned = "stunned",
	Captured = "captured",
	Idle = "idle",
}

MonsterService.States = STATE

-- ==========================================================
-- SPAWN / DESPAWN
-- ==========================================================
function MonsterService.spawn(chapterId, episodeId, mapId)
	local monster = Cast.getMonster(episodeId)
	if not monster then
		warn("[MonsterService] monstro não encontrado para " .. tostring(episodeId))
		return nil
	end

	MonsterService.despawn(chapterId)

	local model, joints = CharacterBuilder.buildMonster(monster.id, monster)
	if not model then
		return nil
	end

	local spawnMarker = monster.ai and monster.ai.spawnPoint
	local position = require(Shared.Data.Locations).markerPosition(mapId, spawnMarker)
		or require(Shared.Data.Locations).markerPosition(
			mapId,
			require(Shared.Data.Locations).getMap(mapId).spawns.monster
		)

	local folder = workspace:FindFirstChild("MysteryMonsters")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "MysteryMonsters"
		folder.Parent = workspace
	end
	model.Parent = folder

	if position then
		model:PivotTo(CFrame.new(position.X, position.Y + 2, position.Z))
	end

	local ai = monster.ai or {}
	runtime[chapterId] = {
		chapterId = chapterId,
		episodeId = episodeId,
		mapId = mapId,
		monster = monster,
		model = model,
		joints = joints,
		state = STATE.Patrol,
		target = nil,
		path = {},
		pathIndex = 1,
		lastKnown = nil,
		lureUntil = 0,
		stunUntil = 0,
		speed = ai.patrolSpeed or Config.Monster.PATROL_SPEED,
		chaseSpeed = ai.chaseSpeed or Config.Monster.CHASE_SPEED,
		detectRadius = ai.detectRadius or Config.Monster.DETECT_RADIUS,
		hearRadius = ai.hearRadius or Config.Monster.HEAR_RADIUS,
		caughtCooldown = {},
		bobPhase = 0,
	}

	Net.fireAll("ClientNotify", {
		title = monster.name or "Algo se move...",
		text = monster.description or "Um vulto apareceu no cenário.",
		kind = "danger",
		sound = "Bass",
	})

	return runtime[chapterId]
end

function MonsterService.despawn(chapterId)
	local state = runtime[chapterId]
	if state and state.model then
		state.model:Destroy()
	end
	runtime[chapterId] = nil
end

function MonsterService.get(chapterId)
	return runtime[chapterId]
end

function MonsterService.getForPlayer(player)
	local chapterId = player:GetAttribute("ChapterId")
	return chapterId and runtime[chapterId] or nil
end

-- ==========================================================
-- NAVEGAÇÃO
-- ==========================================================
local function buildPath(state, fromPosition, toPosition)
	local built = MapService.getBuilt(state.mapId)
	if not built then
		return {}
	end
	local nav = built.nav
	local fromX, fromZ = nav:WorldToCell(fromPosition)
	local toX, toZ = nav:WorldToCell(toPosition)
	if not fromX or not toX then
		return {}
	end
	fromX, fromZ = nav:FindNearestWalkable(fromX, fromZ, 4) or fromX, fromZ
	toX, toZ = nav:FindNearestWalkable(toX, toZ, 4) or toX, toZ
	local cells = nav:FindPath(fromX, fromZ, toX, toZ)
	local points = {}
	for _, cell in ipairs(cells) do
		local world = nav:CellToWorld(cell.x, cell.z)
		table.insert(points, Vector3.new(world.X, fromPosition.Y, world.Z))
	end
	if #points == 0 then
		table.insert(points, toPosition)
	end
	return points
end

local function moveAlong(state, deltaTime)
	local points = state.path
	if #points == 0 then
		return false
	end
	local model = state.model
	local pivot = model:GetPivot()
	local target = points[state.pathIndex]
	local toTarget = Vector3.new(target.X - pivot.Position.X, 0, target.Z - pivot.Position.Z)
	local distance = toTarget.Magnitude

	if distance < 2 then
		state.pathIndex += 1
		if state.pathIndex > #points then
			return false
		end
		return true
	end

	local direction = toTarget.Unit
	local speed = state.speed
	local step = speed * deltaTime
	local newPosition = pivot.Position + direction * math.min(step, distance)
	newPosition = Vector3.new(newPosition.X, pivot.Position.Y, newPosition.Z)

	local facing = CFrame.lookAt(newPosition, newPosition + direction)
	local bob = math.sin(state.bobPhase)
		* ((state.monster.model and state.monster.model.anim and state.monster.model.anim.bobAmplitude) or 0.4)
	state.bobPhase += deltaTime * 4

	model:PivotTo(facing * CFrame.new(0, bob, 0))
	return true
end

local function setPath(state, toPosition)
	state.path = buildPath(state, state.model:GetPivot().Position, toPosition)
	state.pathIndex = 1
end

-- ==========================================================
-- PERCEPÇÃO
-- ==========================================================
local function nearestVisiblePlayer(state, radius)
	local monsterPosition = state.model:GetPivot().Position
	local best, bestDistance = nil, radius
	for _, player in ipairs(Players:GetPlayers()) do
		if player:GetAttribute("CurrentMap") == state.mapId then
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if root and humanoid and humanoid.Health > 0 then
				local distance = Util.horizontalDistance(monsterPosition, root.Position)
				if distance < bestDistance then
					-- se o jogador está se escondendo (agachado na armadilha/pânico), reduz a detecção
					local hiding = player:GetAttribute("Hiding") == true
					local effective = hiding and distance * 1.6 or distance
					if effective < bestDistance then
						best = player
						bestDistance = effective
					end
				end
			end
		end
	end
	return best, bestDistance
end

local function isCaptured(state)
	return state.state == STATE.Captured
end

-- ==========================================================
-- LOOP
-- ==========================================================
local function catchPlayer(state, player)
	local now = os.clock()
	state.caughtCooldown[player] = now + Config.Match.CAUGHT_COOLDOWN

	player:SetAttribute("Fear", Config.Fear.MAX)
	player:SetAttribute("Caught", true)
	Net.fireClient(player, "ClientChase", { caught = true, monster = state.monster.name })
	Net.fireClient(player, "ClientSfx", { sound = "Hit", volume = 0.9 })
	Net.fireClient(player, "ClientNotify", {
		title = "Você levou um susto!",
		text = (Dialogue.buildLine("Shaggy", "caught", Random.new()) or "Caramba! Ele me pegou!"),
		kind = "danger",
		sound = "Bass",
	})

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Health = 0
	end

	MonsterService.PlayerCaught:Fire(player, state)
end

function MonsterService.update(state, deltaTime)
	if isCaptured(state) then
		return
	end

	local now = os.clock()
	if state.state == STATE.Stunned then
		if now >= state.stunUntil then
			state.state = STATE.Patrol
			state.path = {}
		else
			return
		end
	end

	-- armadilha armada? o monstro é atraído para lá
	local chapterId = state.chapterId
	local trapState = TrapService.getState(chapterId)
	local armedSpot = nil
	for spotId, spot in pairs(trapState.spots) do
		if spot.armed and not spot.captured then
			armedSpot = spot
			break
		end
	end

	local visible, distance = nearestVisiblePlayer(state, state.detectRadius)
	local heard = false
	if not visible then
		local nearest, hearDistance = nearestVisiblePlayer(state, state.hearRadius)
		if nearest and hearDistance then
			visible = nearest
			distance = hearDistance
			heard = true
		end
	end

	if visible and not heard then
		-- perseguição
		if state.state ~= STATE.Chase then
			state.state = STATE.Chase
			state.speed = state.chaseSpeed
			Net.fireAll("ClientChase", { chasing = true, monster = state.monster.name })
		end
		state.target = visible
		local root = visible.Character and visible.Character:FindFirstChild("HumanoidRootPart")
		if root then
			state.lastKnown = root.Position
			if
				#state.path == 0
				or state.pathIndex >= #state.path
				or (state.path[state.pathIndex] - root.Position).Magnitude > 10
			then
				setPath(state, root.Position)
			end
			if distance and distance < Config.Monster.CATCH_DISTANCE then
				if (state.caughtCooldown[visible] or 0) < now then
					catchPlayer(state, visible)
				end
			end
		end
	else
		if state.state == STATE.Chase then
			state.state = STATE.Search
			state.speed = state.chaseSpeed * 0.8
			Net.fireAll("ClientChase", { chasing = false })
			if state.lastKnown then
				setPath(state, state.lastKnown)
			end
		end

		if armedSpot and armedSpot.model and armedSpot.model.PrimaryPart then
			-- isca ativa: vai para a armadilha
			local baitPosition = armedSpot.model.PrimaryPart.Position
			if state.state ~= STATE.Lured or #state.path == 0 then
				state.state = STATE.Lured
				state.speed = state.chaseSpeed * 0.85
				setPath(state, baitPosition)
			end
		elseif state.state == STATE.Search and #state.path > 0 then
			-- continua até a última posição conhecida
		elseif state.state ~= STATE.Patrol and #state.path == 0 then
			state.state = STATE.Patrol
			state.speed = (state.monster.ai and state.monster.ai.patrolSpeed) or Config.Monster.PATROL_SPEED
		end

		if state.state == STATE.Patrol and #state.path == 0 then
			local built = MapService.getBuilt(state.mapId)
			local points = built and built.patrolPoints or {}
			if #points > 0 then
				local pick = points[math.random(1, #points)]
				setPath(state, pick)
			else
				-- última alternativa: patrulha aleatória pelas células caminháveis
				local nav = built and built.nav
				if nav then
					local cell = nav:RandomWalkable(Random.new())
					if cell then
						local world = nav:CellToWorld(cell.x, cell.z)
						setPath(state, Vector3.new(world.X, state.model:GetPivot().Position.Y, world.Z))
					end
				end
			end
		end
	end

	moveAlong(state, deltaTime)

	-- armadilha: o monstro pisa nela?
	if armedSpot and armedSpot.model then
		local captured, spotId = TrapService.tryCapture(state.model, chapterId)
		if captured then
			state.state = STATE.Captured
			state.path = {}
			Net.fireAll("ClientNotify", {
				title = "Armadilha funcionou!",
				text = ("%s ficou preso em %s! Agora é hora de tirar a máscara."):format(state.monster.name, spotId),
				kind = "success",
				sound = "TrapSpring",
			})
			local _, _ = Net.fireAll("ClientCutscene", { kind = "capture", monster = state.monster.id })
		end
	end
end

function MonsterService.stun(chapterId, duration)
	local state = runtime[chapterId]
	if not state then
		return
	end
	state.state = STATE.Stunned
	state.stunUntil = os.clock() + (duration or 5)
	state.path = {}
end

function MonsterService.lure(chapterId, duration)
	local state = runtime[chapterId]
	if not state then
		return
	end
	state.lureUntil = os.clock() + (duration or Config.Monster.LURE_TIME)
	state.state = STATE.Search
	state.path = {}
end

function MonsterService.unmask(chapterId)
	local state = runtime[chapterId]
	if not state then
		return nil
	end
	state.state = STATE.Captured
	local monster = state.monster
	-- tira a "máscara": remove a aura e troca a cor para revelar a pessoa
	for _, part in ipairs(state.joints.parts) do
		part.Transparency = 0.15
	end
	if state.joints.head then
		state.joints.head.Material = Enum.Material.SmoothPlastic
	end
	return monster
end

function MonsterService.start()
	RunService.Heartbeat:Connect(function(deltaTime)
		for _, state in pairs(runtime) do
			MonsterService.update(state, deltaTime)
		end
	end)
end

return MonsterService
