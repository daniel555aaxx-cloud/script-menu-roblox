--[[
	Parkour ASMR — GameCore (servidor)
	• Checkpoints com reaparecimento automático
	• Moedas colecionáveis
	• Lava e giratórias matam ao toque
	• Plataformas móveis, que caem e giratórias
	• Placa de chegada + confete
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- RemoteEvent usado pelos clientes para tocar os sons ASMR
local fx = Instance.new("RemoteEvent")
fx.Name = "ParkourFX"
fx.Parent = ReplicatedStorage

local MODEL = workspace:WaitForChild("ParkourMap")

-- Configuração gerada pelo build do mapa (não editar à mão)
local MOVERS = {
__MOVERS_CONFIG__
}

local SPINNERS = {
__SPINNERS_CONFIG__
}

local FALLING = {
__FALLING_CONFIG__
}

local checkpoints = {}

local function playerFromHit(hit)
	local parent = hit.Parent
	if not parent then
		return nil
	end
	local player = Players:GetPlayerFromCharacter(parent)
	if player then
		return player
	end
	-- acessórios (chapéus, mochilas) têm o personagem como avô
	local humanoid = parent:FindFirstChildOfClass("Humanoid")
	if humanoid then
		return Players:GetPlayerFromCharacter(parent.Parent)
	end
	return nil
end

------------------------------------------------------------------
-- Checkpoints
local function setupCheckpoints()
	local folder = MODEL.Course:WaitForChild("Checkpoints")
	for _, pad in ipairs(folder:GetChildren()) do
		local idx = tonumber(string.match(pad.Name, "Checkpoint_(%d+)"))
		if idx then
			checkpoints[idx] = pad
			pad.Touched:Connect(function(hit)
				local player = playerFromHit(hit)
				if not player then
					return
				end
				local current = player:GetAttribute("Checkpoint") or 0
				if idx > current then
					player:SetAttribute("Checkpoint", idx)
					fx:FireClient(player, "checkpoint", idx)
				end
			end)
		end
	end
end

------------------------------------------------------------------
-- Perigos (lava e giratórias) matam ao toque
local function makeLethal(part)
	part.Touched:Connect(function(hit)
		local player = playerFromHit(hit)
		if not player or not player.Character then
			return
		end
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end)
end

local function setupHazards()
	local folder = MODEL:WaitForChild("Hazards")
	for _, part in ipairs(folder:GetChildren()) do
		if part:IsA("BasePart") then
			makeLethal(part)
		end
	end
end

------------------------------------------------------------------
-- Moedas
local function setupCoins()
	local folder = MODEL.Course:WaitForChild("Coins")
	for _, coin in ipairs(folder:GetChildren()) do
		coin.Touched:Connect(function(hit)
			local player = playerFromHit(hit)
			if not player or not coin.Parent then
				return
			end
			local total = (player:GetAttribute("Coins") or 0) + 1
			player:SetAttribute("Coins", total)
			fx:FireClient(player, "coin", total)
			coin:Destroy()
		end)
	end
end

------------------------------------------------------------------
-- Plataformas que tremem e caem
local function setupFalling()
	local folder = MODEL.Course:WaitForChild("FallingPlatforms")
	for _, name in ipairs(FALLING) do
		local part = folder:FindFirstChild(name)
		if part then
			local busy = false
			part.Touched:Connect(function(hit)
				if busy then
					return
				end
				if not playerFromHit(hit) then
					return
				end
				busy = true
				task.spawn(function()
					local base = part.CFrame
					for _ = 1, 8 do
						part.CFrame = base * CFrame.new((math.random() - 0.5) * 0.6, 0, (math.random() - 0.5) * 0.6)
						task.wait(0.05)
					end
					part.CFrame = base
					part.Anchored = false
					task.wait(2.2)
					if part.Parent then
						part.Anchored = true
						part.CFrame = base
					end
					busy = false
				end)
			end)
		end
	end
end

------------------------------------------------------------------
-- Móveis, giratórias e moedas girando
local movers = {}
local spinners = {}

local function setupObstacles()
	local course = MODEL.Course

	for _, cfg in ipairs(MOVERS) do
		local part = course.Movers:FindFirstChild(cfg.name)
		if part then
			table.insert(movers, {
				part = part,
				base = part.CFrame,
				dx = cfg.dx,
				dy = cfg.dy,
				dz = cfg.dz,
				speed = cfg.speed,
				phase = cfg.phase,
			})
		end
	end

	for _, cfg in ipairs(SPINNERS) do
		local part = course.Spinners:FindFirstChild(cfg.name)
		if part then
			makeLethal(part)
			table.insert(spinners, {
				part = part,
				base = part.CFrame,
				speed = cfg.speed,
				phase = cfg.phase,
			})
		end
	end

	-- moedas giram no próprio eixo
	for _, coin in ipairs(course.Coins:GetChildren()) do
		table.insert(spinners, {
			part = coin,
			base = coin.CFrame,
			speed = 2.4,
			phase = math.random() * 6.28,
		})
	end
end

local elapsed = 0
RunService.Stepped:Connect(function(_, delta)
	elapsed = elapsed + delta
	for _, m in ipairs(movers) do
		if m.part.Parent then
			local s = math.sin(elapsed * m.speed + m.phase)
			m.part.CFrame = m.base * CFrame.new(m.dx * s, m.dy * s, m.dz * s)
		end
	end
	for _, sp in ipairs(spinners) do
		if sp.part.Parent then
			sp.part.CFrame = sp.base * CFrame.Angles(0, elapsed * sp.speed + sp.phase, 0)
		end
	end
end)

------------------------------------------------------------------
-- Chegada
local function setupFinish()
	local finish = MODEL.Course:WaitForChild("Finish")
	finish.Touched:Connect(function(hit)
		local player = playerFromHit(hit)
		if not player or player:GetAttribute("Finished") then
			return
		end
		player:SetAttribute("Finished", true)
		local confetti = finish:FindFirstChild("Confetti")
		if confetti then
			confetti:Emit(140)
		end
		fx:FireClient(player, "finish", player:GetAttribute("Coins") or 0)
	end)
end

------------------------------------------------------------------
-- Reaparecer no último checkpoint
local function onCharacter(player, character)
	local idx = player:GetAttribute("Checkpoint") or 0
	local pad = checkpoints[idx]
	if not pad then
		return
	end
	task.spawn(function()
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if not root or not character.Parent then
			return
		end
		task.wait(0.15)
		character:PivotTo(pad.CFrame * CFrame.new(0, 4.5, 0))
		if root.Parent then
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end)
end

local function onPlayer(player)
	player:SetAttribute("Checkpoint", 0)
	player:SetAttribute("Coins", 0)
	player.CharacterAdded:Connect(function(character)
		onCharacter(player, character)
	end)
	if player.Character then
		onCharacter(player, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayer(player)
end

------------------------------------------------------------------
setupCheckpoints()
setupHazards()
setupCoins()
setupFalling()
setupObstacles()
setupFinish()
