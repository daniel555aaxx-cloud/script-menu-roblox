-- Cliente de Central do Caô: interface, voz opcional e transcrição local via APIs oficiais do Roblox.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("OfficeRemotes")
local actionRemote = remotes:WaitForChild("PlayerAction")
local clientRemote = remotes:WaitForChild("ClientUpdate")

local COLORS = {
	Background = Color3.fromRGB(11, 19, 29),
	Panel = Color3.fromRGB(20, 31, 44),
	PanelLight = Color3.fromRGB(29, 45, 61),
	Border = Color3.fromRGB(55, 78, 92),
	Mint = Color3.fromRGB(118, 222, 184),
	Teal = Color3.fromRGB(64, 170, 158),
	Gold = Color3.fromRGB(255, 197, 103),
	Coral = Color3.fromRGB(242, 133, 108),
	Text = Color3.fromRGB(242, 246, 245),
	Muted = Color3.fromRGB(163, 181, 189),
	DarkText = Color3.fromRGB(18, 31, 41),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CentralDoCaoUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 30
screenGui.Parent = player:WaitForChild("PlayerGui")

local function addCorner(target, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = target
	return corner
end

local function addStroke(target, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or COLORS.Border
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.Parent = target
	return stroke
end

local function makeText(parent, name, text, position, size, textSize, color, font)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = position
	label.Size = size
	label.Font = font or Enum.Font.Gotham
	label.Text = text or ""
	label.TextColor3 = color or COLORS.Text
	label.TextSize = textSize or 16
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	return label
end

local function makeButton(parent, name, text, position, size, background, foreground, textSize)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = background or COLORS.PanelLight
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamMedium
	button.Text = text or ""
	button.TextColor3 = foreground or COLORS.Text
	button.TextSize = textSize or 14
	button.TextWrapped = true
	button.TextXAlignment = Enum.TextXAlignment.Center
	button.TextYAlignment = Enum.TextYAlignment.Center
	button.Parent = parent
	addCorner(button, 9)
	addStroke(button, COLORS.Border, 1, 0.2)
	local normalColor = button.BackgroundColor3
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = normalColor:Lerp(Color3.new(1, 1, 1), 0.09)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = normalColor}):Play()
	end)
	return button
end

-- HUD: saldo/reputação e ranking persistente.
local hud = Instance.new("Frame")
hud.Name = "StatsHUD"
hud.Position = UDim2.new(0, 18, 0, 18)
hud.Size = UDim2.new(0, 245, 0, 84)
hud.BackgroundColor3 = COLORS.Panel
hud.BackgroundTransparency = 0.04
hud.BorderSizePixel = 0
hud.Parent = screenGui
addCorner(hud, 14)
addStroke(hud, COLORS.Border, 1, 0.15)

local hudAccent = Instance.new("Frame")
hudAccent.Size = UDim2.new(0, 5, 1, -22)
hudAccent.Position = UDim2.new(0, 0, 0, 11)
hudAccent.BackgroundColor3 = COLORS.Mint
hudAccent.BorderSizePixel = 0
hudAccent.Parent = hud
addCorner(hudAccent, 3)

makeText(hud, "GameTitle", "CENTRAL DO CAÔ", UDim2.new(0, 17, 0, 8), UDim2.new(1, -28, 0, 20), 14, COLORS.Gold, Enum.Font.GothamBlack)
local moneyLabel = makeText(hud, "Money", "Saldo: 0 Créditos", UDim2.new(0, 17, 0, 32), UDim2.new(1, -28, 0, 20), 15, COLORS.Text, Enum.Font.GothamBold)
local reputationLabel = makeText(hud, "Reputation", "Reputação: 100  •  Ligações: 0", UDim2.new(0, 17, 0, 56), UDim2.new(1, -28, 0, 18), 12, COLORS.Muted, Enum.Font.Gotham)

local rankingPanel = Instance.new("Frame")
rankingPanel.Name = "RankingPanel"
rankingPanel.AnchorPoint = Vector2.new(1, 0)
rankingPanel.Position = UDim2.new(1, -18, 0, 18)
rankingPanel.Size = UDim2.new(0, 235, 0, 205)
rankingPanel.BackgroundColor3 = COLORS.Panel
rankingPanel.BackgroundTransparency = 0.04
rankingPanel.BorderSizePixel = 0
rankingPanel.Parent = screenGui
addCorner(rankingPanel, 14)
addStroke(rankingPanel, COLORS.Border, 1, 0.15)
makeText(rankingPanel, "RankingTitle", "🏆  TOP AGENTES", UDim2.new(0, 15, 0, 12), UDim2.new(1, -30, 0, 25), 15, COLORS.Gold, Enum.Font.GothamBlack)
makeText(rankingPanel, "RankingSubtitle", "CRÉDITOS FICTÍCIOS GANHOS", UDim2.new(0, 15, 0, 39), UDim2.new(1, -30, 0, 18), 9, COLORS.Muted, Enum.Font.GothamMedium)
local rankingRows = makeText(rankingPanel, "RankingRows", "Carregando...", UDim2.new(0, 15, 0, 64), UDim2.new(1, -30, 1, -76), 13, COLORS.Text, Enum.Font.GothamMedium)
rankingRows.TextYAlignment = Enum.TextYAlignment.Top
rankingRows.TextXAlignment = Enum.TextXAlignment.Left

-- Toast curto para mensagens de estado.
local toast = Instance.new("TextLabel")
toast.Name = "Toast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 22)
toast.Size = UDim2.new(0.9, 0, 0, 44)
toast.BackgroundColor3 = COLORS.PanelLight
toast.BackgroundTransparency = 1
toast.BorderSizePixel = 0
toast.Font = Enum.Font.GothamMedium
toast.Text = ""
toast.TextColor3 = COLORS.Text
toast.TextSize = 14
toast.TextWrapped = true
toast.TextTransparency = 1
toast.Visible = false
toast.ZIndex = 20
toast.Parent = screenGui
local toastConstraint = Instance.new("UISizeConstraint")
toastConstraint.MinSize = Vector2.new(250, 44)
toastConstraint.MaxSize = Vector2.new(380, 44)
toastConstraint.Parent = toast
addCorner(toast, 12)
addStroke(toast, COLORS.Teal, 1, 0.2)
local toastSequence = 0

local function showToast(message, tone)
	toastSequence += 1
	local sequence = toastSequence
	toast.Text = tostring(message or "")
	toast.Visible = true
	local tint = tone == "success" and COLORS.Mint or (tone == "warning" and COLORS.Gold or COLORS.Teal)
	local stroke = toast:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = tint
	end
	TweenService:Create(toast, TweenInfo.new(0.18), {
		BackgroundTransparency = 0.04,
		TextTransparency = 0,
	}):Play()
	task.delay(3, function()
		if sequence ~= toastSequence then
			return
		end
		local out = TweenService:Create(toast, TweenInfo.new(0.25), {
			BackgroundTransparency = 1,
			TextTransparency = 1,
		})
		out:Play()
		out.Completed:Connect(function()
			if sequence == toastSequence then
				toast.Visible = false
			end
		end)
	end)
end

-- Janela de atendimento.
local backdrop = Instance.new("Frame")
backdrop.Name = "CallBackdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(4, 9, 14)
backdrop.BackgroundTransparency = 0.32
backdrop.BorderSizePixel = 0
backdrop.Visible = false
backdrop.Parent = screenGui

local callPanel = Instance.new("Frame")
callPanel.Name = "CallPanel"
callPanel.AnchorPoint = Vector2.new(0.5, 0.5)
callPanel.Position = UDim2.fromScale(0.5, 0.5)
callPanel.Size = UDim2.new(0.9, 0, 0.86, 0)
callPanel.BackgroundColor3 = COLORS.Background
callPanel.BorderSizePixel = 0
callPanel.ClipsDescendants = true
callPanel.Parent = backdrop
addCorner(callPanel, 18)
addStroke(callPanel, COLORS.Border, 1.4, 0.05)
local callConstraint = Instance.new("UISizeConstraint")
callConstraint.MinSize = Vector2.new(320, 500)
callConstraint.MaxSize = Vector2.new(620, 620)
callConstraint.Parent = callPanel

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = COLORS.Panel
header.BorderSizePixel = 0
header.Parent = callPanel

local headerAccent = Instance.new("Frame")
headerAccent.Size = UDim2.new(0, 5, 1, -18)
headerAccent.Position = UDim2.new(0, 0, 0, 9)
headerAccent.BackgroundColor3 = COLORS.Coral
headerAccent.BorderSizePixel = 0
headerAccent.Parent = header
addCorner(headerAccent, 3)

makeText(header, "CallHeaderTitle", "LINHA DE ATENDIMENTO", UDim2.new(0, 18, 0, 0), UDim2.new(1, -145, 1, 0), 15, COLORS.Text, Enum.Font.GothamBlack)
local voiceOutButton = makeButton(header, "VoiceOutputToggle", "VOZ ON", UDim2.new(1, -119, 0, 10), UDim2.new(0, 68, 0, 32), COLORS.PanelLight, COLORS.Mint, 11)
local closeButton = makeButton(header, "CloseCall", "FECHAR", UDim2.new(1, -46, 0, 10), UDim2.new(0, 38, 0, 32), COLORS.PanelLight, COLORS.Muted, 10)

local customerLabel = makeText(callPanel, "CustomerLabel", "CLIENTE • LIGAÇÃO FICTÍCIA", UDim2.new(0, 18, 0, 58), UDim2.new(1, -36, 0, 24), 13, COLORS.Gold, Enum.Font.GothamBold)

local history = Instance.new("ScrollingFrame")
history.Name = "ConversationHistory"
history.Position = UDim2.new(0, 16, 0, 88)
history.Size = UDim2.new(1, -32, 0.245, 0)
history.BackgroundColor3 = COLORS.Panel
history.BackgroundTransparency = 0.04
history.BorderSizePixel = 0
history.ScrollBarThickness = 5
history.ScrollBarImageColor3 = COLORS.Teal
history.ScrollingDirection = Enum.ScrollingDirection.Y
history.AutomaticCanvasSize = Enum.AutomaticSize.Y
history.CanvasSize = UDim2.new(0, 0, 0, 0)
history.Parent = callPanel
addCorner(history, 12)
addStroke(history, COLORS.Border, 1, 0.35)
local historyPadding = Instance.new("UIPadding")
historyPadding.PaddingTop = UDim.new(0, 10)
historyPadding.PaddingBottom = UDim.new(0, 10)
historyPadding.PaddingLeft = UDim.new(0, 12)
historyPadding.PaddingRight = UDim.new(0, 12)
historyPadding.Parent = history
local historyLayout = Instance.new("UIListLayout")
historyLayout.SortOrder = Enum.SortOrder.LayoutOrder
historyLayout.Padding = UDim.new(0, 6)
historyLayout.Parent = history
local historyLabels = {}

local function clearHistory()
	for _, item in ipairs(historyLabels) do
		if item and item.Parent then
			item:Destroy()
		end
	end
	table.clear(historyLabels)
	history.CanvasPosition = Vector2.new(0, 0)
end

local function appendHistory(role, text)
	local roleColor = role == "VOCÊ" and COLORS.Mint or (role == "SISTEMA" and COLORS.Gold or COLORS.Text)
	local label = Instance.new("TextLabel")
	label.Name = "ConversationLine"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Size = UDim2.new(1, -4, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Font = role == "VOCÊ" and Enum.Font.GothamMedium or Enum.Font.Gotham
	label.Text = string.format("%s  ·  %s", role, tostring(text or ""))
	label.TextColor3 = roleColor
	label.TextSize = 14
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.LayoutOrder = #historyLabels + 1
	label.Parent = history
	table.insert(historyLabels, label)
	while #historyLabels > 12 do
		local oldest = table.remove(historyLabels, 1)
		if oldest and oldest.Parent then
			oldest:Destroy()
		end
	end
	task.defer(function()
		history.CanvasPosition = Vector2.new(0, math.max(0, historyLayout.AbsoluteContentSize.Y))
	end)
end

makeText(callPanel, "OptionsHeading", "COMO VOCÊ RESPONDE?", UDim2.new(0, 18, 0.42, 0), UDim2.new(1, -36, 0, 19), 11, COLORS.Muted, Enum.Font.GothamBold)
local choicesFrame = Instance.new("ScrollingFrame")
choicesFrame.Name = "ResponseChoices"
choicesFrame.Position = UDim2.new(0, 16, 0.46, 0)
choicesFrame.Size = UDim2.new(1, -32, 0.32, 0)
choicesFrame.BackgroundTransparency = 1
choicesFrame.BorderSizePixel = 0
choicesFrame.ScrollBarThickness = 4
choicesFrame.ScrollBarImageColor3 = COLORS.Teal
choicesFrame.ScrollingDirection = Enum.ScrollingDirection.Y
choicesFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
choicesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
choicesFrame.Parent = callPanel
local choicesLayout = Instance.new("UIListLayout")
choicesLayout.SortOrder = Enum.SortOrder.LayoutOrder
choicesLayout.Padding = UDim.new(0, 5)
choicesLayout.Parent = choicesFrame
local choiceButtons = {}
local callActive = false
local micEnabled = false
local voiceOutputEnabled = true

local function clearChoices()
	for _, button in ipairs(choiceButtons) do
		if button and button.Parent then
			button:Destroy()
		end
	end
	table.clear(choiceButtons)
	choicesFrame.CanvasPosition = Vector2.new(0, 0)
end

local function showChoices(choices)
	clearChoices()
	for index, choice in ipairs(choices or {}) do
		local button = makeButton(
			choicesFrame,
			"Choice_" .. tostring(index),
			choice.label or "Responder",
			UDim2.new(0, 0, 0, 0),
			UDim2.new(1, -8, 0, 32),
			index == 1 and Color3.fromRGB(41, 91, 83) or COLORS.PanelLight,
			COLORS.Text,
			13
		)
		button.LayoutOrder = index
		button.Activated:Connect(function()
			if not callActive then
				return
			end
			actionRemote:FireServer("choice", tostring(choice.id))
		end)
		table.insert(choiceButtons, button)
	end
	choicesFrame.CanvasPosition = Vector2.new(0, 0)
end

local inputRow = Instance.new("Frame")
inputRow.Name = "InputRow"
inputRow.Position = UDim2.new(0, 16, 0.80, 0)
inputRow.Size = UDim2.new(1, -32, 0, 42)
inputRow.BackgroundTransparency = 1
inputRow.Parent = callPanel

local textInput = Instance.new("TextBox")
textInput.Name = "PlayerMessage"
textInput.Position = UDim2.new(0, 0, 0, 0)
textInput.Size = UDim2.new(1, -166, 1, 0)
textInput.BackgroundColor3 = COLORS.PanelLight
textInput.BorderSizePixel = 0
textInput.ClearTextOnFocus = false
textInput.MultiLine = false
textInput.PlaceholderText = "Fale ou digite uma resposta..."
textInput.PlaceholderColor3 = COLORS.Muted
textInput.Font = Enum.Font.Gotham
textInput.Text = ""
textInput.TextColor3 = COLORS.Text
textInput.TextSize = 13
textInput.TextXAlignment = Enum.TextXAlignment.Left
textInput.Parent = inputRow
addCorner(textInput, 9)
addStroke(textInput, COLORS.Border, 1, 0.25)
local inputPadding = Instance.new("UIPadding")
inputPadding.PaddingLeft = UDim.new(0, 11)
inputPadding.PaddingRight = UDim.new(0, 8)
inputPadding.Parent = textInput

local sendButton = makeButton(inputRow, "SendMessage", "ENVIAR", UDim2.new(1, -160, 0, 0), UDim2.new(0, 76, 1, 0), COLORS.Teal, COLORS.DarkText, 11)
local micButton = makeButton(inputRow, "MicToggle", "MIC OFF", UDim2.new(1, -78, 0, 0), UDim2.new(0, 78, 1, 0), COLORS.PanelLight, COLORS.Muted, 10)

local privacyNote = makeText(
	callPanel,
	"SafetyNote",
	"FICÇÃO • SÓ NPCs E CRÉDITOS DO JOGO. Não compartilhe dados pessoais. Microfone opcional; a transcrição não é guardada nem transmitida a outros jogadores.",
	UDim2.new(0, 18, 0.88, 0),
	UDim2.new(1, -36, 0.1, 0),
	11,
	COLORS.Muted,
	Enum.Font.Gotham
)
privacyNote.TextYAlignment = Enum.TextYAlignment.Top

local function setMicButton()
	if micEnabled then
		micButton.Text = "MIC ON"
		micButton.TextColor3 = COLORS.Mint
		micButton.BackgroundColor3 = Color3.fromRGB(35, 81, 73)
	else
		micButton.Text = "MIC OFF"
		micButton.TextColor3 = COLORS.Muted
		micButton.BackgroundColor3 = COLORS.PanelLight
	end
end

local function setVoiceButton()
	voiceOutButton.Text = voiceOutputEnabled and "VOZ ON" or "VOZ OFF"
	voiceOutButton.TextColor3 = voiceOutputEnabled and COLORS.Mint or COLORS.Muted
end

local FILTERED_INPUT_PLACEHOLDER = "Fala recebida."
local speechInput
local speechToText
local speechWire

local function ensureSpeechToText()
	if speechToText and speechToText.Parent then
		return true
	end
	local success, err = pcall(function()
		speechInput = player:FindFirstChildWhichIsA("AudioDeviceInput")
		if not speechInput then
			speechInput = Instance.new("AudioDeviceInput")
			speechInput.Name = "OfficeMicrophoneInput"
			speechInput.Parent = player
		end
		speechInput.Player = player

		speechToText = Instance.new("AudioSpeechToText")
		speechToText.Name = "OfficeSpeechToText"
		speechToText.Enabled = false
		speechToText.Parent = player

		speechWire = Instance.new("Wire")
		speechWire.Name = "OfficeSpeechWire"
		speechWire.SourceInstance = speechInput
		speechWire.TargetInstance = speechToText
		speechWire.Parent = speechToText

		speechToText:GetPropertyChangedSignal("Text"):Connect(function()
			if not speechToText or not speechToText.Parent then
				return
			end
			local recognizedText = speechToText.Text
			if recognizedText == "" then
				return
			end
			speechToText.Text = ""
			if micEnabled and callActive then
				actionRemote:FireServer("say", recognizedText)
			end
		end)
	end)
	if not success then
		warn("Central do Caô: reconhecimento de voz indisponível: " .. tostring(err))
		return false
	end
	return true
end

local function disableMic()
	micEnabled = false
	if speechToText and speechToText.Parent then
		pcall(function()
			speechToText.Enabled = false
		end)
	end
	setMicButton()
end

local function toggleMic()
	if micEnabled then
		disableMic()
		showToast("Microfone desligado. Você também pode digitar ou usar os botões.", "info")
		return
	end
	if not ensureSpeechToText() then
		showToast("Voz indisponível. Use os botões ou digite sua resposta.", "warning")
		return
	end
	micEnabled = true
	local success = pcall(function()
		speechToText.Enabled = true
	end)
	if not success then
		micEnabled = false
		showToast("Não foi possível ativar o microfone. Confira as permissões de voz do Roblox.", "warning")
	else
		showToast("Microfone ligado só para esta conversa. Toque de novo para desligar.", "success")
	end
	setMicButton()
end

local speechGenerator
local speechOutput
local speechOutputWire

local function ensureTextToSpeech()
	if speechGenerator and speechGenerator.Parent and speechOutput and speechOutput.Parent then
		return true
	end
	local success, err = pcall(function()
		speechOutput = SoundService:FindFirstChildWhichIsA("AudioDeviceOutput")
		if not speechOutput then
			speechOutput = Instance.new("AudioDeviceOutput")
			speechOutput.Name = "OfficeAudioOutput"
			speechOutput.Parent = SoundService
		end

		speechGenerator = Instance.new("AudioTextToSpeech")
		speechGenerator.Name = "OfficeNPCVoice"
		speechGenerator.VoiceId = Config.PortugueseVoiceId
		speechGenerator.Volume = 1.25
		speechGenerator.Speed = 1
		speechGenerator.Parent = SoundService

		speechOutputWire = Instance.new("Wire")
		speechOutputWire.Name = "OfficeNPCVoiceWire"
		speechOutputWire.SourceInstance = speechGenerator
		speechOutputWire.TargetInstance = speechOutput
		speechOutputWire.Parent = speechGenerator
	end)
	if not success then
		warn("Central do Caô: texto para voz indisponível: " .. tostring(err))
		return false
	end
	return true
end

local function speakNpc(text)
	if not voiceOutputEnabled then
		return
	end
	if not ensureTextToSpeech() then
		return
	end
	local safeText = tostring(text or "")
	if #safeText > 300 then
		safeText = string.sub(safeText, 1, 300)
	end
	pcall(function()
		if speechGenerator.IsPlaying then
			speechGenerator:Pause()
		end
		speechGenerator.Text = safeText
		speechGenerator.VoiceId = Config.PortugueseVoiceId
		speechGenerator.TimePosition = 0
		speechGenerator:Play()
	end)
end

local function closeCallPanel()
	callActive = false
	disableMic()
	backdrop.Visible = false
	textInput.Text = ""
end

local function submitText()
	if not callActive then
		return
	end
	local text = textInput.Text
	textInput.Text = ""
	if text and string.gsub(text, "%s", "") ~= "" then
		actionRemote:FireServer("say", text)
	end
end

sendButton.Activated:Connect(submitText)
textInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		submitText()
	end
end)
micButton.Activated:Connect(toggleMic)
voiceOutButton.Activated:Connect(function()
	voiceOutputEnabled = not voiceOutputEnabled
	if not voiceOutputEnabled and speechGenerator and speechGenerator.Parent then
		pcall(function()
			speechGenerator:Pause()
		end)
	end
	setVoiceButton()
end)
closeButton.Activated:Connect(function()
	if callActive then
		actionRemote:FireServer("choice", "end")
		task.delay(1.2, function()
			if backdrop.Visible and not callActive then
				closeCallPanel()
			end
		end)
	else
		closeCallPanel()
	end
end)

local function updateStats(payload)
	if type(payload) ~= "table" then
		return
	end
	local money = tonumber(payload.money) or 0
	local reputation = tonumber(payload.reputation) or 0
	local calls = tonumber(payload.calls) or 0
	moneyLabel.Text = "Saldo: " .. tostring(money) .. " Créditos"
	reputationLabel.Text = string.format("Reputação: %d  •  Ligações: %d", reputation, calls)
end

local function updateRanking(rows)
	if type(rows) ~= "table" or #rows == 0 then
		rankingRows.Text = "Ainda sem resultados.\nAtenda sua primeira ligação!"
		return
	end
	local lines = {}
	for index = 1, math.min(6, #rows) do
		local row = rows[index]
		local name = tostring(row.name or "Agente")
		if #name > 16 then
			name = string.sub(name, 1, 15) .. "…"
		end
		table.insert(lines, string.format("%02d  %-16s  %s", index, name, tostring(tonumber(row.value) or 0)))
	end
	rankingRows.Text = table.concat(lines, "\n")
end

local function applyResponsiveLayout()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	if viewport.X < 640 then
		hud.Size = UDim2.new(0, 220, 0, 80)
		rankingPanel.AnchorPoint = Vector2.new(0, 0)
		rankingPanel.Position = UDim2.new(0, 18, 0, 108)
		rankingPanel.Size = UDim2.new(0, 220, 0, 176)
		rankingRows.TextSize = 12
	else
		hud.Size = UDim2.new(0, 245, 0, 84)
		rankingPanel.AnchorPoint = Vector2.new(1, 0)
		rankingPanel.Position = UDim2.new(1, -18, 0, 18)
		rankingPanel.Size = UDim2.new(0, 235, 0, 205)
		rankingRows.TextSize = 13
	end
	if viewport.Y < 520 then
		callConstraint.MinSize = Vector2.new(300, 455)
	else
		callConstraint.MinSize = Vector2.new(300, 500)
	end
end

local function beginCall(payload)
	callActive = true
	backdrop.Visible = true
	clearHistory()
	textInput.Text = ""
	local stationNumber = tonumber(payload.station)
	local stationPrefix = stationNumber and ("ESTAÇÃO " .. string.format("%02d", stationNumber) .. "  •  ") or ""
	customerLabel.Text = stationPrefix .. "CLIENTE  •  " .. tostring(payload.product or "CASO FICTÍCIO")
	appendHistory(tostring(payload.name or "CLIENTE"), tostring(payload.text or "Olá!"))
	showChoices(payload.choices)
	speakNpc(payload.text)
end

clientRemote.OnClientEvent:Connect(function(eventName, payload)
	if eventName == "toast" then
		showToast(payload and payload.message or "", payload and payload.tone)
	elseif eventName == "stats" then
		updateStats(payload)
	elseif eventName == "ranking" then
		updateRanking(payload)
	elseif eventName == "callStart" then
		beginCall(payload or {})
	elseif eventName == "npcLine" then
		local name = payload and payload.name or "CLIENTE"
		local text = payload and payload.text or ""
		appendHistory(tostring(name), tostring(text))
		showChoices(payload and payload.choices)
		speakNpc(text)
	elseif eventName == "playerLine" then
		appendHistory("VOCÊ", payload and payload.text or FILTERED_INPUT_PLACEHOLDER)
	elseif eventName == "finishCall" then
		callActive = false
		disableMic()
		appendHistory(tostring(payload and payload.name or "CLIENTE"), tostring(payload and payload.text or "Ligação encerrada."))
		clearChoices()
		if payload and payload.stats then
			updateStats(payload.stats)
		end
		if payload and payload.reward and payload.reward > 0 then
			showToast("Venda de brincadeira concluída: +" .. tostring(payload.reward) .. " Créditos fictícios.", "success")
		end
		speakNpc(payload and payload.text or "Ligação encerrada.")
	end
end)

-- Fallback para um respawn sem perder a interface nem deixar o microfone ativo.
player.CharacterAdded:Connect(function()
	if micEnabled then
		disableMic()
	end
end)

applyResponsiveLayout()
local currentCamera = workspace.CurrentCamera
if currentCamera then
	currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = workspace.CurrentCamera
	if newCamera then
		newCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
	end
	applyResponsiveLayout()
end)

setMicButton()
setVoiceButton()
actionRemote:FireServer("ready")
task.delay(1.5, function()
	showToast("Bem-vindo! Vá a uma mesa e pressione E para atender um NPC. Só há créditos fictícios.", "info")
end)
