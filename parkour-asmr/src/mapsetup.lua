--[[
	Parkour ASMR — MapSetup (servidor)
	Placas, luzes dos checkpoints, brasas da lava e confete da chegada.
]]

local MODEL = workspace:WaitForChild("ParkourMap")
local course = MODEL:WaitForChild("Course")

------------------------------------------------------------------
-- Placa flutuante (parte invisível + BillboardGui)
local function makeSign(anchorPos, width, height, title, subtitle)
	local holder = Instance.new("Part")
	holder.Name = "SignAnchor"
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanTouch = false
	holder.CanQuery = false
	holder.Transparency = 1
	holder.Size = Vector3.new(1, 1, 1)
	holder.CFrame = CFrame.new(anchorPos)
	holder.Parent = MODEL:WaitForChild("Decor")

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Sign"
	billboard.Size = UDim2.fromOffset(width, height)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = 300
	billboard.LightInfluence = 0
	billboard.Parent = holder

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
	frame.BackgroundTransparency = 0.22
	frame.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2.5
	stroke.Color = Color3.fromRGB(0, 240, 255)
	stroke.Transparency = 0.15
	stroke.Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -24, 0, height * 0.5)
	titleLabel.Position = UDim2.new(0, 12, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Parent = frame

	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, -24, 0, height * 0.34)
	subLabel.Position = UDim2.new(0, 12, 0, height * 0.56)
	subLabel.BackgroundTransparency = 1
	subLabel.Font = Enum.Font.Gotham
	subLabel.Text = subtitle
	subLabel.TextColor3 = Color3.fromRGB(170, 235, 255)
	subLabel.TextScaled = true
	subLabel.TextWrapped = true
	subLabel.Parent = frame

	return holder
end

------------------------------------------------------------------
-- Placa da boas-vindas (sobre o spawn)
local lobby = MODEL:WaitForChild("Lobby")
local spawnLocation = lobby:WaitForChild("SpawnLocation")
makeSign(
	spawnLocation.Position + Vector3.new(0, 16, 0),
	760,
	180,
	"PARKOUR ASMR",
	"WASD = andar   •   ESPAÇO = pular   •   K = ligar/desligar o som ASMR"
)

------------------------------------------------------------------
-- Placa da chegada
local finish = course:WaitForChild("Finish")
makeSign(
	finish.Position + Vector3.new(0, 13, 0),
	680,
	160,
	"CHEGADA!",
	"Você terminou o parkour ASMR — jogou demais!"
)

------------------------------------------------------------------
-- Rótulo + luz nos checkpoints
local checkFolder = course:WaitForChild("Checkpoints")
for _, pad in ipairs(checkFolder:GetChildren()) do
	local idx = string.match(pad.Name, "Checkpoint_(%d+)")
	if idx then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "Label"
		billboard.Size = UDim2.fromOffset(250, 54)
		billboard.StudsOffset = Vector3.new(0, 5.5, 0)
		billboard.MaxDistance = 220
		billboard.LightInfluence = 0
		billboard.Parent = pad

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.Text = "CHECKPOINT " .. idx
		label.TextColor3 = Color3.fromRGB(110, 255, 170)
		label.TextStrokeTransparency = 0.45
		label.TextScaled = true
		label.Parent = billboard

		local light = Instance.new("PointLight")
		light.Name = "CheckpointGlow"
		light.Color = Color3.fromRGB(90, 255, 160)
		light.Brightness = 1.5
		light.Range = 16
		light.Shadows = false
		light.Parent = pad
	end
end

------------------------------------------------------------------
-- Brasas subindo da lava
local hazards = MODEL:WaitForChild("Hazards")
for _, part in ipairs(hazards:GetChildren()) do
	if part:IsA("BasePart") and string.find(part.Name, "Lava") then
		local embers = Instance.new("ParticleEmitter")
		embers.Name = "Brasas"
		embers.Rate = 22
		embers.Speed = NumberRange.new(3, 6)
		embers.Lifetime = NumberRange.new(1.8, 3)
		embers.Acceleration = Vector3.new(0, 5, 0)
		embers.SpreadAngle = Vector2.new(45, 45)
		embers.Color = ColorSequence.new(
			Color3.fromRGB(255, 150, 40),
			Color3.fromRGB(255, 60, 20)
		)
		embers.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(1, 1),
		})
		embers.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.55),
			NumberSequenceKeypoint.new(1, 0.1),
		})
		embers.LightEmission = 0.9
		embers.RotSpeed = NumberRange.new(-120, 120)
		embers.Parent = part
	end
end

------------------------------------------------------------------
-- Confete da chegada (disparado pelo GameCore ao tocar o pad)
local confetti = Instance.new("ParticleEmitter")
confetti.Name = "Confetti"
confetti.Rate = 0
confetti.Speed = NumberRange.new(16, 26)
confetti.Lifetime = NumberRange.new(1.4, 2.4)
confetti.Acceleration = Vector3.new(0, -38, 0)
confetti.SpreadAngle = Vector2.new(80, 80)
confetti.Color = ColorSequence.new({
	NumberSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 130)),
	NumberSequenceKeypoint.new(0.25, Color3.fromRGB(255, 225, 90)),
	NumberSequenceKeypoint.new(0.5, Color3.fromRGB(90, 255, 165)),
	NumberSequenceKeypoint.new(0.75, Color3.fromRGB(100, 175, 255)),
	NumberSequenceKeypoint.new(1, Color3.fromRGB(225, 130, 255)),
})
confetti.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.7),
	NumberSequenceKeypoint.new(1, 0.2),
})
confetti.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.05),
	NumberSequenceKeypoint.new(0.8, 0.25),
	NumberSequenceKeypoint.new(1, 1),
})
confetti.LightEmission = 0.7
confetti.RotSpeed = NumberRange.new(-220, 220)
confetti.Parent = finish
