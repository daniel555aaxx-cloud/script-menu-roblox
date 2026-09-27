-- ARENA FOOTBALL: original small-sided football prototype for Roblox.
-- Server-owned match, ball, score, goals, stamina and action validation.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local MATCH_SECONDS = 180
local HOME_NAME = "RUBRO FC"
local AWAY_NAME = "AZUL FC"
local HOME_SPEED = 18
local SPRINT_SPEED = 26
local STAMINA_DRAIN = 26
local STAMINA_RECOVER = 18

local remotes = ReplicatedStorage:FindFirstChild("FootballRemotes") or Instance.new("Folder")
remotes.Name = "FootballRemotes"
remotes.Parent = ReplicatedStorage

local actionEvent = remotes:FindFirstChild("Action") or Instance.new("RemoteEvent")
actionEvent.Name = "Action"
actionEvent.Parent = remotes
local sprintEvent = remotes:FindFirstChild("Sprint") or Instance.new("RemoteEvent")
sprintEvent.Name = "Sprint"
sprintEvent.Parent = remotes

local function makePart(parent, name, size, position, color, material, anchored, canCollide)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = anchored ~= false
	part.CanCollide = canCollide ~= false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeLine(parent, name, size, position)
	local line = makePart(parent, name, size, position, Color3.fromRGB(238, 246, 235), Enum.Material.SmoothPlastic, true, false)
	line.CastShadow = false
	return line
end

-- Build an original compact stadium and pitch.
local previous = workspace:FindFirstChild("ArenaFootball")
if previous then
	previous:Destroy()
end
local stadium = Instance.new("Folder")
stadium.Name = "ArenaFootball"
stadium.Parent = workspace

Lighting.ClockTime = 17.2
Lighting.Brightness = 2.2
Lighting.GlobalShadows = true
Lighting.EnvironmentDiffuseScale = 0.42
Lighting.EnvironmentSpecularScale = 0.55
Lighting.Ambient = Color3.fromRGB(115, 126, 145)
Lighting.OutdoorAmbient = Color3.fromRGB(140, 150, 165)
local atmosphere = Lighting:FindFirstChild("ArenaAtmosphere") or Instance.new("Atmosphere")
atmosphere.Name = "ArenaAtmosphere"
atmosphere.Density = 0.22
atmosphere.Offset = 0.08
atmosphere.Color = Color3.fromRGB(199, 217, 235)
atmosphere.Decay = Color3.fromRGB(102, 119, 147)
atmosphere.Glare = 0.12
atmosphere.Haze = 0.65
atmosphere.Parent = Lighting

makePart(stadium, "Pitch", Vector3.new(240, 2, 380), Vector3.new(0, -1, 0), Color3.fromRGB(34, 119, 58), Enum.Material.Grass, true, true)
-- Mowing bands give the playing surface depth without importing outside assets.
for index = 1, 16 do
	local stripeColor = index % 2 == 0 and Color3.fromRGB(39, 130, 63) or Color3.fromRGB(34, 119, 58)
	local stripe = makePart(stadium, ("MowingStripe_%02d"):format(index), Vector3.new(240, 0.025, 23.75), Vector3.new(0, 0.012, -190 + (index - 0.5) * 23.75), stripeColor, Enum.Material.Grass, true, false)
	stripe.CastShadow = false
end
makeLine(stadium, "CenterLine", Vector3.new(0.22, 0.08, 372), Vector3.new(0, 0.07, 0))
makeLine(stadium, "TouchlineNorth", Vector3.new(230, 0.08, 0.22), Vector3.new(0, 0.07, -184))
makeLine(stadium, "TouchlineSouth", Vector3.new(230, 0.08, 0.22), Vector3.new(0, 0.07, 184))
makeLine(stadium, "GoalLineWest", Vector3.new(0.22, 0.08, 368), Vector3.new(-116, 0.07, 0))
makeLine(stadium, "GoalLineEast", Vector3.new(0.22, 0.08, 368), Vector3.new(116, 0.07, 0))
local centerSpot = makePart(stadium, "CenterSpot", Vector3.new(0.08, 0.8, 0.8), Vector3.new(0, 0.08, 0), Color3.fromRGB(242, 246, 238), Enum.Material.SmoothPlastic, true, false)
centerSpot.Shape = Enum.PartType.Cylinder
centerSpot.CFrame = CFrame.new(0, 0.08, 0) * CFrame.Angles(0, 0, math.pi / 2)

-- Thin segments form a clean painted center circle.
for i = 1, 64 do
	local angle = ((i - 0.5) / 64) * math.pi * 2
	local x = math.cos(angle) * 32
	local z = math.sin(angle) * 32
	local segment = makeLine(stadium, ("CenterCircle_%02d"):format(i), Vector3.new(0.22, 0.08, 3.2), Vector3.new(x, 0.07, z))
	segment.CFrame = CFrame.lookAt(Vector3.new(x, 0.07, z), Vector3.new(x - math.sin(angle), 0.07, z + math.cos(angle)))
end

local function drawBox(name, zCenter, depth, halfWidth)
	local innerZ = zCenter > 0 and zCenter - depth / 2 or zCenter + depth / 2
	local outerZ = zCenter > 0 and zCenter + depth / 2 or zCenter - depth / 2
	makeLine(stadium, name .. "_Left", Vector3.new(0.18, 0.08, depth), Vector3.new(-halfWidth, 0.07, zCenter))
	makeLine(stadium, name .. "_Right", Vector3.new(0.18, 0.08, depth), Vector3.new(halfWidth, 0.07, zCenter))
	makeLine(stadium, name .. "_Front", Vector3.new(halfWidth * 2, 0.08, 0.18), Vector3.new(0, 0.07, innerZ))
	makeLine(stadium, name .. "_Back", Vector3.new(halfWidth * 2, 0.08, 0.18), Vector3.new(0, 0.07, outerZ))
end

drawBox("NorthPenaltyArea", 160, 60, 70)
drawBox("SouthPenaltyArea", -160, 60, 70)
drawBox("NorthGoalArea", 174, 32, 33)
drawBox("SouthGoalArea", -174, 32, 33)
makePart(stadium, "NorthPenaltySpot", Vector3.new(1.2, 0.08, 1.2), Vector3.new(0, 0.08, 151), Color3.fromRGB(242, 246, 238), Enum.Material.SmoothPlastic, true, false).Shape = Enum.PartType.Ball
makePart(stadium, "SouthPenaltySpot", Vector3.new(1.2, 0.08, 1.2), Vector3.new(0, 0.08, -151), Color3.fromRGB(242, 246, 238), Enum.Material.SmoothPlastic, true, false).Shape = Enum.PartType.Ball

-- Corner flagpoles make the enlarged field easier to read at a distance.
for _, xSide in ipairs({-1, 1}) do
	for _, zSide in ipairs({-1, 1}) do
		local x, z = xSide * 116, zSide * 184
		makePart(stadium, ("CornerFlagPole_%d_%d"):format(xSide, zSide), Vector3.new(0.22, 6, 0.22), Vector3.new(x, 3, z), Color3.fromRGB(236, 238, 235), Enum.Material.Metal, true, false)
		local flag = makePart(stadium, ("CornerFlag_%d_%d"):format(xSide, zSide), Vector3.new(1.5, 0.9, 0.12), Vector3.new(x + xSide * 0.72, 5.45, z), zSide > 0 and Color3.fromRGB(206, 64, 58) or Color3.fromRGB(65, 142, 224), Enum.Material.Fabric, true, false)
		flag.CastShadow = false
	end
end

local postColor = Color3.fromRGB(242, 245, 240)
local function makeGoal(prefix, z)
	local goalHalfWidth = 13
	local goalHeight = 8.5
	local goalDepth = 14
	local backZ = z > 0 and z + goalDepth or z - goalDepth
	for _, side in ipairs({-1, 1}) do
		makePart(stadium, prefix .. "Post" .. side, Vector3.new(0.9, goalHeight, 0.9), Vector3.new(side * goalHalfWidth, goalHeight / 2, z), postColor, Enum.Material.Metal, true, true)
		makePart(stadium, prefix .. "NetSide" .. side, Vector3.new(0.16, goalHeight - 0.4, goalDepth), Vector3.new(side * goalHalfWidth, (goalHeight - 0.4) / 2, (z + backZ) / 2), Color3.fromRGB(210, 220, 225), Enum.Material.Fabric, true, false).Transparency = 0.62
	end
	makePart(stadium, prefix .. "Crossbar", Vector3.new(goalHalfWidth * 2 + 0.9, 0.9, 0.9), Vector3.new(0, goalHeight, z), postColor, Enum.Material.Metal, true, true)
	makePart(stadium, prefix .. "NetBack", Vector3.new(goalHalfWidth * 2, goalHeight - 0.4, 0.16), Vector3.new(0, (goalHeight - 0.4) / 2, backZ), Color3.fromRGB(210, 220, 225), Enum.Material.Fabric, true, false).Transparency = 0.62
	for i = -5, 5 do
		makeLine(stadium, prefix .. "NetCordX" .. i, Vector3.new(0.07, goalHeight - 0.5, 0.07), Vector3.new(i * 2.5, (goalHeight - 0.5) / 2, backZ - (z > 0 and 0.2 or -0.2)))
	end
	for i = 1, 4 do
		makeLine(stadium, prefix .. "NetCordY" .. i, Vector3.new(goalHalfWidth * 2, 0.07, 0.07), Vector3.new(0, i * 1.65, backZ - (z > 0 and 0.2 or -0.2)))
	end

	local goalTrigger = makePart(stadium, prefix .. "GoalTrigger", Vector3.new(goalHalfWidth * 2 - 1, goalHeight - 0.6, 7), Vector3.new(0, (goalHeight - 0.6) / 2, z + (z > 0 and 3.5 or -3.5)), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, true, false)
	goalTrigger.Transparency = 1
	goalTrigger.CanTouch = true
	return goalTrigger
end

-- Rubro attacks the north (+Z) goal; Azul attacks the south (-Z) goal.
local northGoal = makeGoal("NorthGoal", 190)
local southGoal = makeGoal("SouthGoal", -190)

-- Grandstands, several floodlight towers and invisible perimeter walls.
for _, side in ipairs({-1, 1}) do
	for row = 1, 3 do
		local x = side * (135 + row * 10)
		local stand = makePart(stadium, ("SideStand_%d_%d"):format(side, row), Vector3.new(16, 9 + row * 3, 340), Vector3.new(x, 3 + row * 2, 0), (row % 2 == 0) and Color3.fromRGB(36, 51, 76) or Color3.fromRGB(47, 63, 89), Enum.Material.Metal, true, true)
		stand.CastShadow = true
	end
	for _, lightZ in ipairs({-130, 130}) do
		local pole = makePart(stadium, ("FloodlightPole_%d_%d"):format(side, lightZ), Vector3.new(1.8, 48, 1.8), Vector3.new(side * 188, 24, lightZ), Color3.fromRGB(47, 54, 67), Enum.Material.Metal, true, true)
		local lamp = makePart(stadium, ("Floodlight_%d_%d"):format(side, lightZ), Vector3.new(18, 1.2, 5), Vector3.new(side * 188, 49, lightZ), Color3.fromRGB(255, 244, 203), Enum.Material.Neon, true, false)
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 3
		pointLight.Range = 220
		pointLight.Shadows = true
		pointLight.Color = Color3.fromRGB(255, 241, 208)
		pointLight.Parent = lamp
		pole.CastShadow = true
	end
end
for _, z in ipairs({-228, 228}) do
	for row = 1, 2 do
		local outward = (z > 0 and 1 or -1) * (row - 1) * 13
		makePart(stadium, "EndStand_" .. z .. "_" .. row, Vector3.new(270, 10, 10), Vector3.new(0, row * 5, z + outward), Color3.fromRGB(40, 55, 81), Enum.Material.Metal, true, true)
	end
end
makePart(stadium, "BoundaryWest", Vector3.new(1, 14, 420), Vector3.new(-126, 6, 0), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, true, true).Transparency = 1
makePart(stadium, "BoundaryEast", Vector3.new(1, 14, 420), Vector3.new(126, 6, 0), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, true, true).Transparency = 1
makePart(stadium, "BoundaryNorth", Vector3.new(260, 14, 1), Vector3.new(0, 6, 220), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, true, true).Transparency = 1
makePart(stadium, "BoundarySouth", Vector3.new(260, 14, 1), Vector3.new(0, 6, -220), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, true, true).Transparency = 1

local ball = Instance.new("Part")
ball.Name = "MatchBall"
ball.Shape = Enum.PartType.Ball
ball.Size = Vector3.new(1.4, 1.4, 1.4)
ball.Position = Vector3.new(0, 0.75, 0)
ball.Color = Color3.fromRGB(248, 248, 236)
ball.Material = Enum.Material.SmoothPlastic
-- Roblox's classic Soccer Ball gear mesh/texture (the Part remains a round collision shell).
local ballMesh = Instance.new("SpecialMesh")
ballMesh.Name = "ClassicRobloxSoccerBallVisual"
ballMesh.MeshType = Enum.MeshType.FileMesh
ballMesh.MeshId = "rbxassetid://28502053"
ballMesh.TextureId = "rbxassetid://28502119"
ballMesh.Scale = Vector3.new(1.4, 1.4, 1.4)
ballMesh.Parent = ball
ball.CustomPhysicalProperties = PhysicalProperties.new(0.72, 0.46, 0.42, 1, 1)
ball.Anchored = false
ball.CanCollide = true
ball.CanTouch = true
ball.Parent = stadium
ball:SetAttribute("PossessorUserId", 0)
ball:SetNetworkOwner(nil)

-- Teams.
for _, name in ipairs({"RUBRO FC", "AZUL FC"}) do
	local oldTeam = Teams:FindFirstChild(name)
	if oldTeam then oldTeam:Destroy() end
end
local homeTeam = Instance.new("Team")
homeTeam.Name = HOME_NAME
homeTeam.TeamColor = BrickColor.new("Bright red")
homeTeam.AutoAssignable = false
homeTeam.Parent = Teams
local awayTeam = Instance.new("Team")
awayTeam.Name = AWAY_NAME
awayTeam.TeamColor = BrickColor.new("Bright blue")
awayTeam.AutoAssignable = false
awayTeam.Parent = Teams

local function addTeamSpawn(name, team, position)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = name
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = position
	spawn.Anchored = true
	spawn.Neutral = false
	spawn.TeamColor = team.TeamColor
	spawn.Duration = 0
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.CanQuery = false
	spawn.Parent = stadium
end
addTeamSpawn("RubroSpawn", homeTeam, Vector3.new(0, 0.5, -95))
addTeamSpawn("AzulSpawn", awayTeam, Vector3.new(0, 0.5, 95))

workspace:SetAttribute("HomeName", HOME_NAME)
workspace:SetAttribute("AwayName", AWAY_NAME)
workspace:SetAttribute("HomeScore", 0)
workspace:SetAttribute("AwayScore", 0)
workspace:SetAttribute("MatchDuration", MATCH_SECONDS)
workspace:SetAttribute("MatchStartedAt", 0)
workspace:SetAttribute("MatchEnded", false)
workspace:SetAttribute("BallCarrierUserId", 0)
workspace:SetAttribute("LastGoalMessage", "")
workspace:SetAttribute("GoalSequence", 0)

local possessor = nil
local pickupBlockedUntil = 0
local goalDebounceUntil = 0
local actionCooldowns = {}
local sprintRequested = {}
local stamina = {}
local playerSpawnSequence = 0

local function getRoot(player)
	local character = player.Character
	if not character then return nil end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root then return nil end
	return root
end

local dribbleWeld = nil
local positionBallAtFeet

local function setPossessor(player)
	if dribbleWeld then
		dribbleWeld:Destroy()
		dribbleWeld = nil
	end

	possessor = player
	ball:SetAttribute("PossessorUserId", player and player.UserId or 0)
	workspace:SetAttribute("BallCarrierUserId", player and player.UserId or 0)
	if player then
		local root = getRoot(player)
		if not root then
			possessor = nil
			ball:SetAttribute("PossessorUserId", 0)
			workspace:SetAttribute("BallCarrierUserId", 0)
			return
		end

		ball.Anchored = false
		ball.CanCollide = false
		ball.Massless = true
		ball.AssemblyLinearVelocity = Vector3.zero
		ball.AssemblyAngularVelocity = Vector3.zero
		positionBallAtFeet(player, root)

		-- Weld into the player's character assembly while dribbling. This makes the
		-- ball follow locally with the carrier instead of lagging behind server CFrames.
		local weld = Instance.new("Weld")
		weld.Name = "BallDribbleWeld"
		weld.Part0 = root
		weld.Part1 = ball
		weld.C0 = root.CFrame:ToObjectSpace(ball.CFrame)
		weld.C1 = CFrame.new()
		weld.Parent = root
		dribbleWeld = weld
		pcall(function() ball:SetNetworkOwner(player) end)
	else
		ball.Anchored = false
		ball.CanCollide = true
		ball.Massless = false
		pcall(function() ball:SetNetworkOwner(nil) end)
	end
end

local function getDribbleDirection(root)
	local velocity = root.AssemblyLinearVelocity
	local movement = Vector3.new(velocity.X, 0, velocity.Z)
	local facing = root.CFrame.LookVector
	local flatFacing = Vector3.new(facing.X, 0, facing.Z)
	if flatFacing.Magnitude > 0.05 then
		flatFacing = flatFacing.Unit
		if movement.Magnitude > 2.5 and movement.Unit:Dot(flatFacing) > 0.25 then
			local blended = movement.Unit * 0.7 + flatFacing * 0.3
			return blended.Unit, movement.Magnitude
		end
		return flatFacing, movement.Magnitude
	end
	return Vector3.new(0, 0, -1), movement.Magnitude
end

local function getGroundY(character, root, humanoid)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character, ball }
	local result = workspace:Raycast(root.Position + Vector3.new(0, 1, 0), Vector3.new(0, -8, 0), params)
	if result then
		return result.Position.Y
	end
	return root.Position.Y - humanoid.HipHeight - root.Size.Y * 0.5
end

positionBallAtFeet = function(player, root)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local direction, speed = getDribbleDirection(root)
	-- Lead the ball slightly in the actual travel direction, rather than trailing behind
	-- the avatar's root orientation while it turns or accelerates.
	local lead = 2.1 + math.clamp(speed * 0.035, 0, 0.85)
	local groundY = getGroundY(character, root, humanoid)
	if root.Position.Y - groundY > 3.5 then
		groundY = root.Position.Y - humanoid.HipHeight - root.Size.Y * 0.5
	end
	local target = root.Position + direction * lead
	target = Vector3.new(target.X, groundY + ball.Size.Y * 0.5 + 0.06, target.Z)
	ball.CFrame = CFrame.lookAt(target, target + direction)
end

local function detachBall()
	if dribbleWeld then
		dribbleWeld:Destroy()
		dribbleWeld = nil
	end
	possessor = nil
	ball:SetAttribute("PossessorUserId", 0)
	workspace:SetAttribute("BallCarrierUserId", 0)
	ball.Anchored = false
	ball.CanCollide = true
	ball.Massless = false
	pcall(function() ball:SetNetworkOwner(nil) end)
end

local function findPassTarget(player)
	local root = getRoot(player)
	if not root then return nil end
	local forward = root.CFrame.LookVector
	local bestPlayer, bestScore = nil, -math.huge
	for _, candidate in ipairs(Players:GetPlayers()) do
		if candidate ~= player and candidate.Team == player.Team then
			local targetRoot = getRoot(candidate)
			if targetRoot then
				local offset = targetRoot.Position - ball.Position
				local distance = offset.Magnitude
				if distance <= 125 and distance > 1 then
					local alignment = forward:Dot(offset.Unit)
					local score = alignment * 36 - distance * 0.22
					if alignment > -0.05 and score > bestScore then
						bestPlayer, bestScore = candidate, score
					end
				end
			end
		end
	end
	return bestPlayer
end

local function validAim(aim)
	if typeof(aim) ~= "Vector3" or aim.Magnitude < 0.1 then return nil end
	local horizontal = Vector3.new(aim.X, 0, aim.Z)
	if horizontal.Magnitude < 0.1 then return nil end
	return horizontal.Unit, math.clamp(aim.Y, -0.2, 0.7)
end

local function releaseShot(player, aim, charge)
	local root = getRoot(player)
	local direction, lift = validAim(aim)
	if not root or not direction then return end
	charge = typeof(charge) == "number" and math.clamp(charge, 0, 1) or 0.25

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local groundY = getGroundY(character, root, humanoid)
	local origin = root.Position + direction * 2.8
	origin = Vector3.new(origin.X, groundY + ball.Size.Y * 0.5 + 0.1, origin.Z)
	detachBall()
	ball.CFrame = CFrame.new(origin)
	ball.AssemblyLinearVelocity = direction * (82 + charge * 82) + Vector3.new(0, 12 + charge * 26 + lift * 14, 0)
	ball.AssemblyAngularVelocity = Vector3.new(12, 18, -9)
	pickupBlockedUntil = os.clock() + 0.55
end

local function scoreGoal(scoringTeam)
	if os.clock() < goalDebounceUntil or workspace:GetAttribute("MatchEnded") then return end
	goalDebounceUntil = os.clock() + 2.2
	if scoringTeam == homeTeam then
		workspace:SetAttribute("HomeScore", (workspace:GetAttribute("HomeScore") or 0) + 1)
		workspace:SetAttribute("LastGoalMessage", "GOL DO RUBRO FC!")
	else
		workspace:SetAttribute("AwayScore", (workspace:GetAttribute("AwayScore") or 0) + 1)
		workspace:SetAttribute("LastGoalMessage", "GOL DO AZUL FC!")
	end
	workspace:SetAttribute("GoalSequence", (workspace:GetAttribute("GoalSequence") or 0) + 1)

	setPossessor(nil)
	ball.Anchored = true
	ball.CanCollide = false
	ball.CFrame = CFrame.new(0, 0.75, 0)
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
	pickupBlockedUntil = os.clock() + 1.4
	task.delay(1.25, function()
		if ball and ball.Parent and not workspace:GetAttribute("MatchEnded") then
			ball.Anchored = false
			ball.CanCollide = true
			pcall(function() ball:SetNetworkOwner(nil) end)
		end
	end)
end

northGoal.Touched:Connect(function(hit)
	if hit == ball then scoreGoal(homeTeam) end
end)
southGoal.Touched:Connect(function(hit)
	if hit == ball then scoreGoal(awayTeam) end
end)

local function assignTeam(player)
	local homeCount, awayCount = 0, 0
	for _, member in ipairs(Players:GetPlayers()) do
		if member ~= player then
			if member.Team == homeTeam then homeCount += 1 end
			if member.Team == awayTeam then awayCount += 1 end
		end
	end
	player.Team = homeCount <= awayCount and homeTeam or awayTeam
end

local function setupPlayer(player)
	assignTeam(player)
	stamina[player] = 100
	sprintRequested[player] = false
	player:SetAttribute("Stamina", 100)
	player:SetAttribute("ShotCharge", 0)

	local function setupCharacter(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.WalkSpeed = HOME_SPEED
		humanoid.UseJumpPower = true
		humanoid.JumpPower = 38
		playerSpawnSequence += 1
		local sequence = playerSpawnSequence
		task.wait(0.1)
		local x = ((sequence - 1) % 5 - 2) * 5
		local isHome = player.Team == homeTeam
		local z = isHome and -95 or 95
		local yaw = isHome and math.pi or 0
		if character.Parent then
			character:PivotTo(CFrame.new(x, 3, z) * CFrame.Angles(0, yaw, 0))
		end
	end
	player.CharacterAdded:Connect(setupCharacter)
	if player.Character then
		task.spawn(setupCharacter, player.Character)
	end

	if workspace:GetAttribute("MatchStartedAt") == 0 then
		workspace:SetAttribute("MatchStartedAt", workspace:GetServerTimeNow())
	end
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
	if possessor == player then
		setPossessor(nil)
	end
	actionCooldowns[player] = nil
	sprintRequested[player] = nil
	stamina[player] = nil
end)

sprintEvent.OnServerEvent:Connect(function(player, active)
	if typeof(active) == "boolean" then
		sprintRequested[player] = active
	end
end)

actionEvent.OnServerEvent:Connect(function(player, action, aim, charge)
	if typeof(action) ~= "string" or workspace:GetAttribute("MatchEnded") then return end
	local now = os.clock()
	if actionCooldowns[player] and now - actionCooldowns[player] < 0.18 then return end

	if action == "Shoot" then
		if possessor ~= player then return end
		actionCooldowns[player] = now
		releaseShot(player, aim, charge)
	elseif action == "Pass" then
		if possessor ~= player then return end
		local root = getRoot(player)
		if not root then return end
		actionCooldowns[player] = now
		local target = findPassTarget(player)
		local direction
		if target and getRoot(target) then
			direction = (getRoot(target).Position - ball.Position).Unit
		else
			direction = root.CFrame.LookVector
		end
		local flatDirection = Vector3.new(direction.X, 0, direction.Z)
		if flatDirection.Magnitude < 0.1 then
			flatDirection = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
		end
		flatDirection = flatDirection.Unit
		local groundY = getGroundY(player.Character, root, player.Character:FindFirstChildOfClass("Humanoid"))
		local origin = root.Position + flatDirection * 2.7
		origin = Vector3.new(origin.X, groundY + ball.Size.Y * 0.5 + 0.1, origin.Z)
		detachBall()
		ball.CFrame = CFrame.new(origin)
		ball.AssemblyLinearVelocity = flatDirection * 72 + Vector3.new(0, 8, 0)
		ball.AssemblyAngularVelocity = Vector3.new(7, 10, -5)
		pickupBlockedUntil = now + 0.35
	elseif action == "Tackle" then
		if possessor == player or not possessor or player.Team == possessor.Team then return end
		local root = getRoot(player)
		local targetRoot = getRoot(possessor)
		if root and targetRoot and (root.Position - ball.Position).Magnitude <= 8 then
			actionCooldowns[player] = now
			local direction = root.CFrame.LookVector
			setPossessor(player)
			pickupBlockedUntil = now + 0.15
		end
	end
end)

RunService.Heartbeat:Connect(function(deltaTime)
	-- Server-maintained sprint stamina.
	for player, currentStamina in pairs(stamina) do
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			if sprintRequested[player] and currentStamina > 0 then
				currentStamina = math.max(0, currentStamina - STAMINA_DRAIN * deltaTime)
				humanoid.WalkSpeed = SPRINT_SPEED
				if currentStamina <= 0 then sprintRequested[player] = false end
			else
				currentStamina = math.min(100, currentStamina + STAMINA_RECOVER * deltaTime)
				humanoid.WalkSpeed = HOME_SPEED
			end
			stamina[player] = currentStamina
			player:SetAttribute("Stamina", currentStamina)
		end
	end

	-- While possessed, a weld carries the ball with the avatar's physics assembly.
	-- Only repair missing/invalid welds here; don't server-step the ball behind the client.
	if possessor then
		local root = getRoot(possessor)
		if not root then
			setPossessor(nil)
		elseif not dribbleWeld or dribbleWeld.Part0 ~= root then
			setPossessor(possessor)
		end
	elseif os.clock() >= pickupBlockedUntil and ball.Parent then
		local speed = ball.AssemblyLinearVelocity.Magnitude
		if speed < 42 then
			local bestPlayer, bestDistance = nil, 4.8
			for _, player in ipairs(Players:GetPlayers()) do
				local root = getRoot(player)
				if root then
					local distance = (root.Position - ball.Position).Magnitude
					if distance < bestDistance then
						bestPlayer, bestDistance = player, distance
					end
				end
			end
			if bestPlayer then setPossessor(bestPlayer) end
		end
	end

	if ball.Position.Y < -10 or math.abs(ball.Position.X) > 145 or math.abs(ball.Position.Z) > 245 then
		setPossessor(nil)
		ball.Anchored = true
		ball.CanCollide = false
		ball.CFrame = CFrame.new(0, 0.75, 0)
		ball.AssemblyLinearVelocity = Vector3.zero
		task.delay(0.5, function()
			if ball and ball.Parent then
				ball.Anchored = false
				ball.CanCollide = true
				pickupBlockedUntil = os.clock() + 0.7
			end
		end)
	end
end)

task.spawn(function()
	while true do
		task.wait(0.25)
		local startTime = workspace:GetAttribute("MatchStartedAt") or 0
		if startTime > 0 and not workspace:GetAttribute("MatchEnded") then
			if workspace:GetServerTimeNow() - startTime >= MATCH_SECONDS then
				workspace:SetAttribute("MatchEnded", true)
				local homeScore = workspace:GetAttribute("HomeScore") or 0
				local awayScore = workspace:GetAttribute("AwayScore") or 0
				local result = homeScore == awayScore and "EMPATE!" or (homeScore > awayScore and "RUBRO FC VENCEU!" or "AZUL FC VENCEU!")
				workspace:SetAttribute("LastGoalMessage", "FIM DE JOGO — " .. result)
				if possessor then setPossessor(nil) end
			end
		end
	end
end)

print("ARENA FOOTBALL carregado: partida, campo, bola e comandos prontos.")
