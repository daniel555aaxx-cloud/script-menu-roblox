--[[
	DialogueController.luau
	Caixa de diálogo estilo HQ: retrato do falante, texto que aparece letra por
	letra, opções de resposta (com indicação do papel que pode falar) e
	"bark" rápido para provocações do Salsicha/Scooby.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Cast = require(Shared.Data.Cast)
local Net = require(Shared.Net)

local UIKit = require(script.Parent.Parent.Modules.UIKit)

local DialogueController = {}

local gui, box, nameLabel, textLabel, choicesHolder, portrait, barkBox, barkText

local typing = nil
local fullText = ""
local choices = {}
local open = false

local function speakerColor(speakerId)
	local palette = {
		Fred = UIKit.Palette.Purple,
		Daphne = Color3.fromRGB(180, 110, 210),
		Velma = Color3.fromRGB(226, 130, 60),
		Shaggy = Color3.fromRGB(112, 176, 84),
		Scooby = Color3.fromRGB(160, 108, 62),
	}
	return palette[speakerId] or UIKit.Palette.Accent
end

function DialogueController.build()
	gui = Instance.new("ScreenGui")
	gui.Name = "MysteryDialogue"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 5
	gui.Parent = player:WaitForChild("PlayerGui")

	box = UIKit.frame({
		name = "DialogueBox",
		size = UDim2.fromOffset(760, 190),
		position = UDim2.new(0.5, 0, 1, -30),
		anchor = Vector2.new(0.5, 1),
		color = UIKit.Palette.Panel,
		corner = 16,
		parent = gui,
		visible = false,
		stroke = true,
		strokeColor = UIKit.Palette.Accent,
	})
	UIKit.padding(box, 14)

	portrait = UIKit.frame({
		name = "Portrait",
		size = UDim2.fromOffset(96, 96),
		color = UIKit.Palette.PanelLight,
		corner = 12,
		parent = box,
		stroke = true,
	})

	nameLabel = UIKit.label({
		name = "Name",
		text = "",
		size = UDim2.new(1, -110, 0, 26),
		position = UDim2.fromOffset(108, 2),
		textColor = UIKit.Palette.Accent,
		font = UIKit.Fonts.bold,
		textSize = 18,
		parent = box,
	})

	textLabel = UIKit.label({
		name = "Text",
		text = "",
		size = UDim2.new(1, -116, 0, 96),
		position = UDim2.fromOffset(108, 26),
		textColor = UIKit.Palette.Text,
		textSize = 16,
		yAlign = Enum.TextYAlignment.Top,
		parent = box,
	})

	choicesHolder = UIKit.frame({
		name = "Choices",
		size = UDim2.new(1, 0, 0, 74),
		position = UDim2.fromOffset(0, 116),
		color = UIKit.Palette.Night,
		transparency = 1,
		parent = box,
	})
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Parent = choicesHolder

	-- bark (falas rápidas no rodapé)
	barkBox = UIKit.frame({
		name = "Bark",
		size = UDim2.fromOffset(560, 46),
		position = UDim2.new(0.5, 0, 1, -100),
		anchor = Vector2.new(0.5, 1),
		color = UIKit.Palette.Night,
		transparency = 0.2,
		corner = 10,
		parent = gui,
		visible = false,
		stroke = true,
		strokeColor = UIKit.Palette.Purple,
	})
	barkText = UIKit.label({
		name = "Text",
		text = "",
		size = UDim2.new(1, -16, 1, 0),
		position = UDim2.fromOffset(8, 0),
		textColor = UIKit.Palette.Text,
		textSize = 14,
		xAlign = Enum.TextXAlignment.Center,
		parent = barkBox,
	})
end

local function stopTyping()
	if typing then
		typing:Disconnect()
		typing = nil
	end
end

local function typeText(text)
	fullText = text or ""
	textLabel.Text = ""
	stopTyping()
	local index = 0
	typing = game:GetService("RunService").Heartbeat:Connect(function(dt)
		index += math.max(1, math.floor(dt * 45))
		if index >= #fullText then
			textLabel.Text = fullText
			stopTyping()
		else
			textLabel.Text = string.sub(fullText, 1, index)
		end
	end)
end

local function clearChoices()
	for _, child in ipairs(choicesHolder:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

local function showChoices(list)
	clearChoices()
	choices = list or {}
	if #choices == 0 then
		local hint = UIKit.button({
			name = "Advance",
			text = "[E] continuar",
			size = UDim2.fromOffset(160, 32),
			color = UIKit.Palette.PanelLight,
			parent = choicesHolder,
			onClick = function()
				Net.fireServer("GameDialogueAdvance")
			end,
		})
		return
	end

	local roleId = player:GetAttribute("RoleId")
	for _, choice in ipairs(choices) do
		local isLocked = choice.role ~= nil and roleId ~= nil and choice.role ~= roleId
		local button = UIKit.button({
			name = "Choice" .. choice.index,
			text = choice.text,
			size = UDim2.fromOffset(238, 34),
			color = isLocked and UIKit.Palette.Panel or UIKit.Palette.PanelLight,
			textColor = isLocked and UIKit.Palette.TextDim or UIKit.Palette.Text,
			textSize = 12,
			parent = choicesHolder,
			stroke = choice.role ~= nil,
			strokeColor = choice.role and speakerColor(choice.role) or nil,
			onClick = function()
				Net.fireServer("GameDialogueChoice", choice.index)
			end,
		})
		button.TextTruncate = Enum.TextTruncate.AtEnd
		if choice.role then
			button.Text = ("%s (%s)"):format(choice.text, choice.role)
		end
	end
end

function DialogueController.start()
	DialogueController.build()

	Net.Event("ClientDialogue").OnClientEvent:Connect(function(payload)
		if not payload then
			return
		end

		if payload.action == "bark" then
			barkBox.Visible = true
			barkText.Text = (payload.title and (payload.title .. ": ") or "") .. (payload.text or "")
			task.delay(4, function()
				if barkBox.Parent then
					barkBox.Visible = false
				end
			end)
			return
		end

		open = true
		box.Visible = true
		UIKit.popIn(box, UDim2.fromOffset(0, 30))

		local npc = payload.npcId and Cast.getNpc(payload.npcId)
		local speakerName = payload.title or (npc and npc.name) or "???"
		nameLabel.Text = speakerName
		nameLabel.TextColor3 = speakerColor(payload.npcId)
		portrait.BackgroundColor3 = speakerColor(payload.npcId)

		typeText(payload.text or "")
		showChoices(payload.choices)

		if payload.camera then
			-- foca a câmera levemente no NPC (feito pelo CutsceneController)
			Net.fireServer("ClientNotify", nil)
		end
	end)

	Net.Event("ClientDialogueEnd").OnClientEvent:Connect(function()
		open = false
		clearChoices()
		local tween = TweenService:Create(box, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
		tween:Play()
		task.delay(0.3, function()
			box.Visible = false
			box.BackgroundTransparency = 0
		end)
	end)

	-- clicar na caixa adianta a digitação / avança
	box.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if #choices == 0 then
				Net.fireServer("GameDialogueAdvance")
			end
		end
	end)
end

function DialogueController.isOpen()
	return open
end

return DialogueController
