--[[
	CutsceneController.luau
	Cutscenes cinematográficas (o servidor manda os slides; aqui a câmera
	enquadra o cenário, com letterbox e legendas).

	Tipos: intro do capítulo, aparição do monstro, captura e revelação.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)

local UIKit = require(script.Parent.Parent.Modules.UIKit)

local CutsceneController = {}

local gui, letterboxTop, letterboxBottom, slidePanel, speakerLabel, slideText, titleLabel, subtitleLabel
local playing = false
local slideIndex = 1
local slides = {}

local function setLetterbox(open)
	local size = open and UDim2.fromScale(1, 0.12) or UDim2.fromScale(1, 0)
	letterboxTop.Size = UDim2.new(1, 0, 0, 0)
	letterboxBottom.Size = UDim2.new(1, 0, 0, 0)
	letterboxTop:TweenSize(
		UDim2.new(1, 0, open and 0.12 or 0, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quint,
		0.35,
		true
	)
	letterboxBottom:TweenSize(
		UDim2.new(1, 0, open and 0.12 or 0, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quint,
		0.35,
		true
	)
end

function CutsceneController.build()
	gui = Instance.new("ScreenGui")
	gui.Name = "MysteryCutscene"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 8
	gui.Parent = player:WaitForChild("PlayerGui")

	letterboxTop = UIKit.frame({
		name = "LetterboxTop",
		size = UDim2.new(1, 0, 0, 0),
		position = UDim2.fromScale(0, 0),
		color = Color3.new(0, 0, 0),
		parent = gui,
		zIndex = 10,
	})
	letterboxBottom = UIKit.frame({
		name = "LetterboxBottom",
		size = UDim2.new(1, 0, 0, 0),
		position = UDim2.fromScale(0, 1),
		anchor = Vector2.new(0, 1),
		color = Color3.new(0, 0, 0),
		parent = gui,
		zIndex = 10,
	})

	slidePanel = UIKit.frame({
		name = "SlidePanel",
		size = UDim2.fromOffset(820, 240),
		position = UDim2.new(0.5, 0, 0.78, 0),
		anchor = Vector2.new(0.5, 0.5),
		color = UIKit.Palette.Night,
		transparency = 0.15,
		corner = 14,
		parent = gui,
		visible = false,
		stroke = true,
		strokeColor = UIKit.Palette.Accent,
		zIndex = 11,
	})
	UIKit.padding(slidePanel, 18)

	titleLabel = UIKit.label({
		name = "Title",
		text = "",
		size = UDim2.new(1, 0, 0, 34),
		textColor = UIKit.Palette.Accent,
		font = UIKit.Fonts.bold,
		textSize = 24,
		xAlign = Enum.TextXAlignment.Center,
		parent = slidePanel,
		zIndex = 12,
	})
	subtitleLabel = UIKit.label({
		name = "Subtitle",
		text = "",
		size = UDim2.new(1, 0, 0, 20),
		position = UDim2.fromOffset(0, 32),
		textColor = UIKit.Palette.TextDim,
		textSize = 13,
		xAlign = Enum.TextXAlignment.Center,
		parent = slidePanel,
		zIndex = 12,
	})
	speakerLabel = UIKit.label({
		name = "Speaker",
		text = "",
		size = UDim2.new(1, 0, 0, 24),
		position = UDim2.fromOffset(0, 60),
		textColor = UIKit.Palette.Warning,
		font = UIKit.Fonts.bold,
		textSize = 16,
		xAlign = Enum.TextXAlignment.Center,
		parent = slidePanel,
		zIndex = 12,
	})
	slideText = UIKit.label({
		name = "SlideText",
		text = "",
		size = UDim2.new(1, 0, 1, -92),
		position = UDim2.fromOffset(0, 86),
		textColor = UIKit.Palette.Text,
		textSize = 17,
		xAlign = Enum.TextXAlignment.Center,
		yAlign = Enum.TextYAlignment.Top,
		parent = slidePanel,
		zIndex = 12,
	})

	-- botão de pular
	local skip = UIKit.button({
		name = "Skip",
		text = "Pular (P)",
		size = UDim2.fromOffset(120, 32),
		position = UDim2.new(1, -20, 0, 20),
		anchor = Vector2.new(1, 0),
		color = UIKit.Palette.Panel,
		parent = gui,
		zIndex = 12,
		onClick = function()
			Net.fireServer("GameSkipCutscene")
		end,
	})
	skip.Visible = false
	CutsceneController.SkipButton = skip
end

local function showSlide(index)
	local slide = slides[index]
	if not slide then
		return
	end
	speakerLabel.Text = slide.speaker or ""
	slideText.Text = slide.text or ""
	UIKit.popIn(slidePanel, UDim2.fromOffset(0, 18))
end

local function focusCamera(kind, payload)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable
	local origin = root.Position
	local target = origin
	local lookAt = origin

	if kind == "intro" then
		target = origin + Vector3.new(-14, 16, 22)
		lookAt = origin + Vector3.new(0, 4, 0)
	elseif kind == "monster" then
		local monster = workspace:FindFirstChild("MysteryMonsters")
		local model = monster and monster:GetChildren()[1]
		if model then
			local position = model:GetPivot().Position
			target = position + Vector3.new(16, 12, 16)
			lookAt = position + Vector3.new(0, 5, 0)
		end
	elseif kind == "reveal" or kind == "capture" then
		target = origin + Vector3.new(0, 8, 14)
		lookAt = origin + Vector3.new(0, 3, 0)
	end

	local startCFrame = camera.CFrame
	local goalCFrame = CFrame.lookAt(target, lookAt)
	local steps = 40
	task.spawn(function()
		for step = 1, steps do
			if not playing then
				break
			end
			local alpha = step / steps
			camera.CFrame = startCFrame:Lerp(goalCFrame, alpha)
			RunService.RenderStepped:Wait()
		end
	end)
end

function CutsceneController.start()
	CutsceneController.build()

	Net.Event("ClientCutscene").OnClientEvent:Connect(function(payload)
		if not payload then
			return
		end
		playing = true
		slideIndex = 1
		slides = payload.slides or {}
		CutsceneController.SkipButton.Visible = true
		setLetterbox(true)
		slidePanel.Visible = true
		titleLabel.Text = payload.title or ""
		subtitleLabel.Text = payload.subtitle or ""
		focusCamera(payload.kind, payload)

		if payload.sfx then
			Net.fireServer("ClientSfx", nil)
		end

		task.spawn(function()
			local duration = payload.duration or (#slides * 4)
			local perSlide = #slides > 0 and (duration / #slides) or duration
			for index = 1, math.max(1, #slides) do
				if not playing then
					break
				end
				showSlide(index)
				task.wait(perSlide)
			end
			if playing then
				CutsceneController.finish()
			end
		end)
	end)

	Net.Event("ClientCutsceneEnd").OnClientEvent:Connect(function()
		CutsceneController.finish()
	end)
end

function CutsceneController.finish()
	playing = false
	slidePanel.Visible = false
	CutsceneController.SkipButton.Visible = false
	setLetterbox(false)
	camera.CameraType = Enum.CameraType.Custom
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		camera.CameraSubject = humanoid
	end
end

function CutsceneController.isPlaying()
	return playing
end

return CutsceneController
