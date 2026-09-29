--[[
	UIKit.luau
	Mini-biblioteca de UI (tema "Arquivos do Mistério"): painéis escuros,
	destaques verde-neon e laranja, tipografia Gotham e animações de entrada.

	Todo o HUD/lobby/diálogo do jogo é montado por aqui — nada de arquivos .rbxmx,
	tudo em código (dá para versionar no Git).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)

local UIKit = {}

UIKit.Palette = {
	Night = Color3.fromRGB(14, 12, 24),
	Panel = Color3.fromRGB(26, 22, 44),
	PanelLight = Color3.fromRGB(40, 34, 64),
	Accent = Color3.fromRGB(140, 255, 130),
	Warning = Color3.fromRGB(255, 176, 62),
	Danger = Color3.fromRGB(255, 78, 78),
	Text = Color3.fromRGB(238, 236, 250),
	TextDim = Color3.fromRGB(168, 164, 196),
	Purple = Color3.fromRGB(126, 71, 168),
	Gold = Color3.fromRGB(247, 202, 84),
}

UIKit.Fonts = {
	bold = Enum.Font.GothamBold,
	medium = Enum.Font.GothamMedium,
	regular = Enum.Font.Gotham,
	mono = Enum.Font.Code,
}

function UIKit.corner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = parent
	return corner
end

function UIKit.stroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or UIKit.Palette.PanelLight
	stroke.Thickness = thickness or 1.5
	stroke.Transparency = transparency or 0.25
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

function UIKit.gradient(parent, colorA, colorB, rotation)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(colorA, colorB)
	gradient.Rotation = rotation or 90
	gradient.Parent = parent
	return gradient
end

function UIKit.padding(parent, all)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, all)
	padding.PaddingBottom = UDim.new(0, all)
	padding.PaddingLeft = UDim.new(0, all)
	padding.PaddingRight = UDim.new(0, all)
	padding.Parent = parent
	return padding
end

function UIKit.shadow(parent, transparency)
	local shadow = Instance.new("UIStroke")
	shadow.Color = Color3.new(0, 0, 0)
	shadow.Thickness = 3
	shadow.Transparency = transparency or 0.6
	shadow.Parent = parent
	return shadow
end

-- ==========================================================
-- COMPONENTES
-- ==========================================================
function UIKit.frame(props)
	local frame = Instance.new("Frame")
	frame.Name = props.name or "Frame"
	frame.BackgroundColor3 = props.color or UIKit.Palette.Panel
	frame.BackgroundTransparency = props.transparency or 0
	frame.BorderSizePixel = 0
	frame.Size = props.size or UDim2.fromOffset(200, 100)
	frame.Position = props.position or UDim2.fromScale(0, 0)
	frame.AnchorPoint = props.anchor or Vector2.new(0, 0)
	frame.ZIndex = props.zIndex or 1
	frame.Visible = props.visible ~= false
	frame.ClipsDescendants = props.clip == true
	frame.Parent = props.parent
	if props.corner then
		UIKit.corner(frame, props.corner)
	end
	if props.stroke then
		UIKit.stroke(frame, props.strokeColor, props.strokeThickness, props.strokeTransparency)
	end
	if props.gradient then
		UIKit.gradient(frame, props.gradient[1], props.gradient[2], props.gradientRotation)
	end
	return frame
end

function UIKit.label(props)
	local label = Instance.new("TextLabel")
	label.Name = props.name or "Label"
	label.BackgroundColor3 = props.color or UIKit.Palette.Panel
	label.BackgroundTransparency = props.backgroundTransparency or 1
	label.BorderSizePixel = 0
	label.Size = props.size or UDim2.fromScale(1, 1)
	label.Position = props.position or UDim2.fromScale(0, 0)
	label.AnchorPoint = props.anchor or Vector2.new(0, 0)
	label.Font = props.font or UIKit.Fonts.medium
	label.Text = props.text or ""
	label.TextSize = props.textSize or 16
	label.TextColor3 = props.textColor or UIKit.Palette.Text
	label.TextXAlignment = props.xAlign or Enum.TextXAlignment.Left
	label.TextYAlignment = props.yAlign or Enum.TextYAlignment.Center
	label.TextWrapped = props.wrapped ~= false
	label.RichText = props.rich == true
	label.ZIndex = props.zIndex or (props.parent and (props.parent.ZIndex + 1)) or 2
	label.Parent = props.parent
	if props.corner then
		UIKit.corner(label, props.corner)
	end
	return label
end

function UIKit.button(props)
	local button = Instance.new("TextButton")
	button.Name = props.name or "Button"
	button.BackgroundColor3 = props.color or UIKit.Palette.PanelLight
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Size = props.size or UDim2.fromOffset(140, 40)
	button.Position = props.position or UDim2.fromScale(0, 0)
	button.AnchorPoint = props.anchor or Vector2.new(0, 0)
	button.Font = props.font or UIKit.Fonts.bold
	button.Text = props.text or "Botão"
	button.TextSize = props.textSize or 14
	button.TextColor3 = props.textColor or UIKit.Palette.Text
	button.ZIndex = props.zIndex or 3
	button.Parent = props.parent
	UIKit.corner(button, props.corner or 8)
	if props.stroke then
		UIKit.stroke(
			button,
			props.strokeColor or UIKit.Palette.Accent,
			props.strokeThickness or 1.2,
			props.strokeTransparency or 0.4
		)
	end
	if props.onClick then
		button.MouseButton1Click:Connect(props.onClick)
	end
	return button
end

function UIKit.scrollingList(props)
	local frame = UIKit.frame({
		name = props.name or "ScrollingFrame",
		color = props.color or UIColor3(),
		transparency = props.transparency or 1,
		size = props.size,
		position = props.position,
		anchor = props.anchor,
		parent = props.parent,
		zIndex = props.zIndex,
	})

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Scroll"
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollBarThickness = 5
	scroll.ScrollBarImageColor3 = UIKit.Palette.Accent
	scroll.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, props.gap or 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.Parent = scroll

	return frame, scroll, layout
end

function UIColor3()
	return Color3.fromRGB(20, 18, 34)
end

-- Anima entrada (fade + slide)
function UIKit.popIn(guiObject, fromOffset)
	local originalPosition = guiObject.Position
	local offset = fromOffset or UDim2.fromOffset(0, 24)
	if guiObject:IsA("GuiObject") then
		guiObject.Position = originalPosition + offset
		guiObject.BackgroundTransparency = 1
		guiObject.Visible = true
	end
	local info = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local target = { Position = originalPosition }
	if guiObject:IsA("GuiObject") and guiObject.BackgroundTransparency < 1 then
		target.BackgroundTransparency = guiObject:GetAttribute("BaseTransparency") or 0
	end
	local tween = TweenService:Create(guiObject, info, target)
	tween:Play()
	return tween
end

function UIKit.fadeOut(guiObject, duration)
	local tween = TweenService:Create(guiObject, TweenInfo.new(duration or 0.25), {
		BackgroundTransparency = 1,
	})
	tween:Play()
	return tween
end

function UIKit.notifyColor(kind)
	if kind == "success" then
		return UIKit.Palette.Accent
	elseif kind == "warn" then
		return UIKit.Palette.Warning
	elseif kind == "danger" then
		return UIKit.Palette.Danger
	elseif kind == "hint" then
		return UIKit.Palette.Gold
	elseif kind == "episode" or kind == "season" then
		return UIKit.Palette.Purple
	end
	return UIKit.Palette.Text
end

function UIKit.formatNumber(value)
	local text = tostring(math.floor(value or 0))
	local formatted = text:reverse():gsub("(%d%d%d)", "%1.")
	return formatted:reverse():gsub("^%.", "")
end

function UIKit.formatTime(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	return ("%02d:%02d"):format(math.floor(seconds / 60), seconds % 60)
end

return UIKit
