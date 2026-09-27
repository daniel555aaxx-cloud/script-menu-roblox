-- Bhop Starter: gera uma pista original, checkpoints e cronômetro no servidor.
-- Coloque em ServerScriptService como Script.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local COURSE_NAME = "BhopCourse"
local COURSE_PARTS = 24
local SPACING = 22

local resetEvent = ReplicatedStorage:FindFirstChild("BhopReset")
if not resetEvent then
	resetEvent = Instance.new("RemoteEvent")
	resetEvent.Name = "BhopReset"
	resetEvent.Parent = ReplicatedStorage
end

local oldCourse = workspace:FindFirstChild(COURSE_NAME)
if oldCourse then
	oldCourse:Destroy()
end

local course = Instance.new("Folder")
course.Name = COURSE_NAME
course.Parent = workspace

local function makePart(name, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = course
	return part
end

local function playerFromHit(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return nil
	end
	return Players:GetPlayerFromCharacter(character)
end

local checkpointForPlayer = {}
local touchCooldown = {}
local resetCooldown = {}
local function canTouch(player, key)
	local now = os.clock()
	local bucket = touchCooldown[player]
	if not bucket then
		bucket = {}
		touchCooldown[player] = bucket
	end
	if bucket[key] and now - bucket[key] < 0.8 then
		return false
	end
	bucket[key] = now
	return true
end

local function addTouchPad(name, position, color, onTouch)
	local pad = makePart(name, Vector3.new(7, 0.35, 7), position, color, Enum.Material.Neon)
	pad.CanCollide = false
	pad.CanTouch = true
	pad.Touched:Connect(function(hit)
		local player = playerFromHit(hit)
		if player then
			onTouch(player, pad)
		end
	end)
	return pad
end

-- Plataforma inicial e ponto de renascimento.
makePart("StartPlatform", Vector3.new(30, 2, 30), Vector3.new(0, 0, 8), Color3.fromRGB(37, 43, 58), Enum.Material.Slate)
local spawn = Instance.new("SpawnLocation")
spawn.Name = "BhopSpawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, 1.5, 8)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.AllowTeamChangeOnTouch = false
spawn.Parent = course

local startPoint = CFrame.new(0, 4, 8)
addTouchPad("StartPad", Vector3.new(0, 1.1, -1), Color3.fromRGB(0, 210, 255), function(player)
	if not canTouch(player, "start") then
		return
	end
	checkpointForPlayer[player] = startPoint
	player:SetAttribute("Checkpoint", 0)
	player:SetAttribute("RunStartTime", workspace:GetServerTimeNow())
	player:SetAttribute("RunActive", true)
	player:SetAttribute("RunFinished", false)
end)

-- Plataformas em zigue-zague: layout próprio, feito para servir de pista de treino.
for index = 1, COURSE_PARTS do
	local z = 8 - (index * SPACING)
	local x = math.sin(index * 0.72) * 8
	local y = math.floor((index - 1) / 6) * 2
	local platform = makePart(
		("Platform_%02d"):format(index),
		Vector3.new(16, 2, 14),
		Vector3.new(x, y, z),
		(index % 2 == 0) and Color3.fromRGB(67, 83, 110) or Color3.fromRGB(53, 67, 92),
		Enum.Material.Slate
	)
	platform:SetAttribute("CourseIndex", index)

	if index % 4 == 0 then
		local checkpointIndex = index
		addTouchPad(
			("Checkpoint_%02d"):format(index),
			Vector3.new(x, y + 1.1, z),
			Color3.fromRGB(70, 255, 150),
			function(player)
				if not canTouch(player, "checkpoint_" .. checkpointIndex) then
					return
				end
				checkpointForPlayer[player] = CFrame.new(x, y + 5, z)
				player:SetAttribute("Checkpoint", checkpointIndex)
			end
		)
	end
end

local finishZ = 8 - ((COURSE_PARTS + 1) * SPACING)
local finishY = math.floor((COURSE_PARTS - 1) / 6) * 2
local finishX = math.sin((COURSE_PARTS + 1) * 0.72) * 8
makePart("FinishPlatform", Vector3.new(28, 2, 24), Vector3.new(finishX, finishY, finishZ), Color3.fromRGB(37, 43, 58), Enum.Material.Slate)
addTouchPad("FinishPad", Vector3.new(finishX, finishY + 1.1, finishZ), Color3.fromRGB(255, 194, 55), function(player)
	if not canTouch(player, "finish") or not player:GetAttribute("RunActive") then
		return
	end

	local startTime = player:GetAttribute("RunStartTime")
	if typeof(startTime) ~= "number" then
		return
	end

	local elapsed = math.max(0, workspace:GetServerTimeNow() - startTime)
	player:SetAttribute("RunActive", false)
	player:SetAttribute("RunFinished", true)
	player:SetAttribute("LastRunTime", elapsed)

	local best = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("BestTime")
	if best and (best.Value == 0 or elapsed < best.Value) then
		best.Value = elapsed
		player:SetAttribute("BestTime", elapsed)
	end
end)

-- Uma base abaixo da pista evita quedas infinitas e facilita os testes.
local killPlane = makePart("ResetPlane", Vector3.new(600, 2, 1200), Vector3.new(0, -45, finishZ / 2), Color3.fromRGB(32, 35, 45), Enum.Material.Slate)
killPlane.Transparency = 0.35
killPlane.Touched:Connect(function(hit)
	local player = playerFromHit(hit)
	if not player or not canTouch(player, "fallreset") then
		return
	end
	local character = player.Character
	if character then
		character:PivotTo(checkpointForPlayer[player] or startPoint)
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end
end)

local function setupPlayer(player)
	if player:FindFirstChild("leaderstats") then
		return
	end
	player:SetAttribute("Checkpoint", 0)
	player:SetAttribute("RunActive", false)
	player:SetAttribute("RunFinished", false)
	player:SetAttribute("LastRunTime", 0)
	player:SetAttribute("BestTime", 0)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local best = Instance.new("NumberValue")
	best.Name = "BestTime"
	best.Value = 0
	best.Parent = leaderstats

	player.CharacterAdded:Connect(function(character)
		task.wait(0.2)
		if not checkpointForPlayer[player] then
			checkpointForPlayer[player] = startPoint
		end
		-- A cada nova vida, volta ao último checkpoint alcançado.
		if player:GetAttribute("Checkpoint") and player:GetAttribute("Checkpoint") > 0 then
			character:PivotTo(checkpointForPlayer[player])
		end
	end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in Players:GetPlayers() do
	setupPlayer(player)
end

resetEvent.OnServerEvent:Connect(function(player)
	local now = os.clock()
	if resetCooldown[player] and now - resetCooldown[player] < 1 then
		return
	end
	resetCooldown[player] = now

	local character = player.Character
	local checkpoint = checkpointForPlayer[player] or startPoint
	if not character or not character.Parent then
		return
	end

	character:PivotTo(checkpoint)
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
end)

Players.PlayerRemoving:Connect(function(player)
	checkpointForPlayer[player] = nil
	touchCooldown[player] = nil
	resetCooldown[player] = nil
end)

print(("Bhop Starter: pista criada com %d plataformas."):format(COURSE_PARTS))
