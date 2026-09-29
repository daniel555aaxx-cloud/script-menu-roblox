--[[
	HudController.luau
	HUD completo do jogo:
		* objetivos do capítulo (com estado concluído)
		* relógio do capítulo e pontos
		* barra de medo (fear) e aviso de perseguição
		* inventário de armadilha (peças)
		* notificações empilhadas
		* quadro de evidências (tecla Q)
		* lista de deduções para votar (clique escolhe a opção)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Episodes = require(Shared.Data.Episodes)
local Net = require(Shared.Net)

local UIKit = require(script.Parent.Parent.Modules.UIKit)

local HudController = {}

local gui, root
local widgets = {}

local state = {
	objectives = {},
	points = 0,
	chapter = nil,
	fear = 0,
	chasing = false,
	trap = { parts = 0, partsNeeded = Config.Traps.PARTS_NEEDED, built = 0, armed = 0 },
	timeLeft = 0,
	evidence = {},
}

-- ==========================================================
-- CONSTRUÇÃO
-- ==========================================================
function HudController.build()
	gui = Instance.new("ScreenGui")
	gui.Name = "MysteryHud"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	root = UIKit.frame({
		name = "Root",
		color = UIKit.Palette.Night,
		transparency = 1,
		size = UDim2.fromScale(1, 1),
		parent = gui,
		zIndex = 1,
	})

	-- ---------- OBJETIVOS (canto superior esquerdo) ----------
	local objectivesPanel = UIKit.frame({
		name = "Objectives",
		size = UDim2.fromOffset(330, 264),
		position = UDim2.fromOffset(18, 18),
		color = UIKit.Palette.Panel,
		corner = 14,
		parent = root,
		stroke = true,
		strokeColor = UIKit.Palette.PanelLight,
	})
	UIKit.padding(objectivesPanel, 12)
	widgets.objectives = objectivesPanel

	local chapterTitle = UIKit.label({
		name = "ChapterTitle",
		text = "Arquivos do Mistério",
		size = UDim2.new(1, 0, 0, 34),
		textColor = UIKit.Palette.Accent,
		font = UIKit.Fonts.bold,
		textSize = 17,
		parent = objectivesPanel,
	})
	widgets.chapterTitle = chapterTitle

	local phaseLabel = UIKit.label({
		name = "Phase",
		text = "",
		size = UDim2.new(1, 0, 0, 18),
		position = UDim2.fromOffset(0, 32),
		textColor = UIKit.Palette.TextDim,
		textSize = 13,
		parent = objectivesPanel,
	})
	widgets.phaseLabel = phaseLabel

	local listHolder, scroll, layout = UIKit.scrollingList({
		size = UDim2.new(1, 0, 1, -78),
		position = UDim2.fromOffset(0, 56),
		parent = objectivesPanel,
		gap = 6,
	})
	scroll.Name = "ObjectiveList"
	widgets.objectiveHolder = scroll
	widgets.objectiveLayout = layout

	-- ---------- RELÓGIO / PONTOS (topo centro) ----------
	local topBar = UIKit.frame({
		name = "TopBar",
		size = UDim2.fromOffset(360, 42),
		position = UDim2.new(0.5, 0, 0, 14),
		anchor = Vector2.new(0.5, 0),
		color = UIKit.Palette.Panel,
		corner = 12,
		parent = root,
		stroke = true,
	})
	widgets.topBar = topBar

	widgets.clockLabel = UIKit.label({
		name = "Clock",
		text = "00:00",
		size = UDim2.new(0.34, 0, 1, 0),
		position = UDim2.fromOffset(12, 0),
		textColor = UIKit.Palette.Text,
		font = UIKit.Fonts.bold,
		textSize = 20,
		parent = topBar,
	})

	widgets.pointsLabel = UIKit.label({
		name = "Points",
		text = "0 pts",
		size = UDim2.new(0.4, 0, 1, 0),
		position = UDim2.fromScale(0.36, 0),
		textColor = UIKit.Palette.Accent,
		font = UIKit.Fonts.bold,
		textSize = 18,
		xAlign = Enum.TextXAlignment.Center,
		parent = topBar,
	})

	widgets.trapBadge = UIKit.label({
		name = "TrapBadge",
		text = "🧰 0/3",
		size = UDim2.new(0.24, 0, 1, 0),
		position = UDim2.new(0.76, 0, 0, 0),
		textColor = UIKit.Palette.Gold,
		font = UIKit.Fonts.bold,
		textSize = 16,
		xAlign = Enum.TextXAlignment.Right,
		parent = topBar,
	})

	-- ---------- ALVO / MIRA (aviso de perseguição) ----------
	local chaseFrame = UIKit.frame({
		name = "ChaseWarning",
		size = UDim2.fromOffset(420, 54),
		position = UDim2.new(0.5, 0, 0.18, 0),
		anchor = Vector2.new(0.5, 0),
		color = UIKit.Palette.Danger,
		transparency = 0.25,
		corner = 12,
		parent = root,
		visible = false,
		stroke = true,
		strokeColor = UIKit.Palette.Danger,
	})
	widgets.chase = chaseFrame
	UIKit.label({
		name = "ChaseText",
		text = "ELE ESTÁ VINDO — CORRE!",
		size = UDim2.fromScale(1, 1),
		textColor = UIKit.Palette.Text,
		font = UIKit.Fonts.bold,
		textSize = 22,
		xAlign = Enum.TextXAlignment.Center,
		parent = chaseFrame,
	})

	-- ---------- BARRA DE MEDO ----------
	local fearHolder = UIKit.frame({
		name = "FearHolder",
		size = UDim2.fromOffset(280, 26),
		position = UDim2.new(0.5, 0, 1, -54),
		anchor = Vector2.new(0.5, 1),
		color = UIKit.Palette.Panel,
		corner = 8,
		parent = root,
		stroke = true,
	})
	widgets.fearHolder = fearHolder
	local fearFill = UIKit.frame({
		name = "Fill",
		size = UDim2.fromScale(0, 1),
		color = UIKit.Palette.Accent,
		corner = 8,
		parent = fearHolder,
	})
	widgets.fearFill = fearFill
	widgets.fearLabel = UIKit.label({
		name = "FearLabel",
		text = "TRANQUILO",
		size = UDim2.fromScale(1, 1),
		textColor = UIKit.Palette.Text,
		font = UIKit.Fonts.bold,
		textSize = 12,
		xAlign = Enum.TextXAlignment.Center,
		parent = fearHolder,
	})

	-- ---------- NOTIFICAÇÕES ----------
	local notifyHolder = UIKit.frame({
		name = "Notifications",
		size = UDim2.fromOffset(320, 400),
		position = UDim2.new(1, -18, 0, 18),
		anchor = Vector2.new(1, 0),
		color = UIKit.Palette.Night,
		transparency = 1,
		parent = root,
	})
	local notifyLayout = Instance.new("UIListLayout")
	notifyLayout.Padding = UDim.new(0, 8)
	notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notifyLayout.Parent = notifyHolder
	widgets.notifyHolder = notifyHolder
	widgets.notifyLayout = notifyLayout

	-- ---------- QUADRO DE EVIDÊNCIAS (painel lateral, tecla Q) ----------
	local evidencePanel = UIKit.frame({
		name = "Evidence",
		size = UDim2.fromOffset(420, 380),
		position = UDim2.new(0.5, 0, 0.5, 0),
		anchor = Vector2.new(0.5, 0.5),
		color = UIKit.Palette.Panel,
		corner = 16,
		parent = root,
		visible = false,
		stroke = true,
		strokeColor = UIKit.Palette.Accent,
	})
	UIKit.padding(evidencePanel, 16)
	widgets.evidence = evidencePanel
	UIKit.label({
		name = "Title",
		text = "QUADRO DE PISTAS",
		size = UDim2.new(1, 0, 0, 30),
		textColor = UIKit.Palette.Accent,
		font = UIKit.Fonts.bold,
		textSize = 20,
		parent = evidencePanel,
	})
	UIKit.label({
		name = "Hint",
		text = "Q para fechar · Clique numa pista para marcar",
		size = UDim2.new(1, 0, 0, 20),
		position = UDim2.fromOffset(0, 28),
		textColor = UIKit.Palette.TextDim,
		textSize = 12,
		parent = evidencePanel,
	})
	local _, evidenceScroll = UIKit.scrollingList({
		size = UDim2.new(1, 0, 1, -56),
		position = UDim2.fromOffset(0, 50),
		parent = evidencePanel,
		gap = 6,
	})
	widgets.evidenceList = evidenceScroll

	-- ---------- MINIMAPA / RODAPÉ ----------
	local footer = UIKit.label({
		name = "Footer",
		text = "L turma · Q pistas · H dica · T provocar fantasma · SHIFT correr",
		size = UDim2.new(0.7, 0, 0, 22),
		position = UDim2.new(0.5, 0, 1, -14),
		anchor = Vector2.new(0.5, 1),
		textColor = UIKit.Palette.TextDim,
		textSize = 12,
		xAlign = Enum.TextXAlignment.Center,
		parent = root,
	})
	widgets.footer = footer

	-- ---------- TELA DE RESULTADO ----------
	local resultPanel = UIKit.frame({
		name = "Result",
		size = UDim2.fromOffset(560, 320),
		position = UDim2.fromScale(0.5, 0.5),
		anchor = Vector2.new(0.5, 0.5),
		color = UIKit.Palette.Panel,
		corner = 18,
		parent = root,
		visible = false,
		stroke = true,
		strokeColor = UIKit.Palette.Gold,
	})
	UIKit.padding(resultPanel, 20)
	widgets.result = resultPanel
	widgets.resultTitle = UIKit.label({
		name = "Title",
		text = "",
		size = UDim2.new(1, 0, 0, 40),
		textColor = UIKit.Palette.Gold,
		font = UIKit.Fonts.bold,
		textSize = 28,
		xAlign = Enum.TextXAlignment.Center,
		parent = resultPanel,
	})
	widgets.resultText = UIKit.label({
		name = "Text",
		text = "",
		size = UDim2.new(1, 0, 1, -80),
		position = UDim2.fromOffset(0, 46),
		textColor = UIKit.Palette.Text,
		textSize = 16,
		yAlign = Enum.TextYAlignment.Top,
		parent = resultPanel,
	})
	local closeButton = UIKit.button({
		name = "Close",
		text = "Continuar",
		size = UDim2.fromOffset(180, 40),
		position = UDim2.new(0.5, 0, 1, -38),
		anchor = Vector2.new(0.5, 0),
		color = UIKit.Palette.Accent,
		textColor = UIKit.Palette.Night,
		parent = resultPanel,
		onClick = function()
			resultPanel.Visible = false
		end,
	})
	widgets.resultClose = closeButton

	return gui
end

-- ==========================================================
-- ATUALIZAÇÕES
-- ==========================================================
local function rebuildObjectives()
	for _, child in ipairs(widgets.objectiveHolder:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	for index, objective in ipairs(state.objectives) do
		local row = UIKit.frame({
			name = "Objective" .. index,
			size = UDim2.new(1, -8, 0, 34),
			color = objective.done and UIKit.Palette.PanelLight or UIKit.Palette.Panel,
			corner = 8,
			parent = widgets.objectiveHolder,
			transparency = objective.done and 0.35 or 0,
		})
		UIKit.label({
			name = "Mark",
			text = objective.done and "✓" or "○",
			size = UDim2.fromOffset(24, 34),
			position = UDim2.fromOffset(6, 0),
			textColor = objective.done and UIKit.Palette.Accent or UIKit.Palette.TextDim,
			font = UIKit.Fonts.bold,
			textSize = 16,
			xAlign = Enum.TextXAlignment.Center,
			parent = row,
		})
		UIKit.label({
			name = "Text",
			text = objective.label or objective.id,
			size = UDim2.new(1, -40, 1, 0),
			position = UDim2.fromOffset(32, 0),
			textColor = objective.done and UIKit.Palette.TextDim or UIKit.Palette.Text,
			textSize = 13,
			parent = row,
		})
	end
end

function HudController.setObjectives(payload)
	state.objectives = payload.objectives or {}
	state.chapter = payload.chapter
	if payload.phase == "intro" then
		widgets.phaseLabel.Text = "INTRODUÇÃO — se prepare"
	elseif payload.phase == "playing" then
		widgets.phaseLabel.Text = "INVESTIGAÇÃO"
	elseif payload.phase == "reveal" then
		widgets.phaseLabel.Text = "REVELAÇÃO"
	end
	local chapter = payload.chapter and Episodes.getChapter(payload.chapter)
	if chapter then
		widgets.chapterTitle.Text = chapter.name or payload.chapter
		local episode = Episodes.getEpisode(chapter.episode)
		if episode then
			widgets.phaseLabel.Text = ("%s · %s"):format(episode.name, widgets.phaseLabel.Text)
		end
	end
	rebuildObjectives()
end

function HudController.setHud(payload)
	if payload.points then
		state.points = payload.points
		widgets.pointsLabel.Text = UIKit.formatNumber(payload.points) .. " pts"
		if payload.gain then
			HudController.notify({
				title = "PONTOS",
				text = ("+%d (%s)"):format(payload.gain, payload.reason or ""),
				kind = "success",
				silent = true,
			})
		end
	end
	if payload.trap then
		state.trap = payload.trap
		widgets.trapBadge.Text = ("🧰 %d/%d%s"):format(
			payload.trap.parts,
			payload.trap.partsNeeded,
			payload.trap.armed > 0 and " ⚙" or ""
		)
		widgets.trapBadge.TextColor3 = payload.trap.captured and UIKit.Palette.Accent or UIKit.Palette.Gold
	end
end

function HudController.setFear(value)
	state.fear = math.clamp(value or 0, 0, Config.Fear.MAX)
	local ratio = state.fear / Config.Fear.MAX
	widgets.fearFill.Size = UDim2.fromScale(ratio, 1)
	if ratio < 0.35 then
		widgets.fearFill.BackgroundColor3 = UIKit.Palette.Accent
		widgets.fearLabel.Text = "TRANQUILO"
	elseif ratio < 0.7 then
		widgets.fearFill.BackgroundColor3 = UIKit.Palette.Warning
		widgets.fearLabel.Text = "APREENSIVO"
	else
		widgets.fearFill.BackgroundColor3 = UIKit.Palette.Danger
		widgets.fearLabel.Text = "PÂNICO!"
	end
end

function HudController.setChasing(chasing, monsterName)
	state.chasing = chasing
	widgets.chase.Visible = chasing
	if chasing and monsterName then
		widgets.chase.ChaseText.Text = ("%s ESTÁ VINDO — CORRE!"):format(string.upper(monsterName))
	end
end

function HudController.setClock(seconds)
	state.timeLeft = seconds
	widgets.clockLabel.Text = UIKit.formatTime(seconds)
	widgets.clockLabel.TextColor3 = seconds < 120 and UIKit.Palette.Danger or UIKit.Palette.Text
end

function HudController.toggleEvidence()
	widgets.evidence.Visible = not widgets.evidence.Visible
end

function HudController.setEvidence(payload)
	state.evidence = payload.entries or {}
	widgets.evidenceList:ClearAllChildren()
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = widgets.evidenceList

	for index, entry in ipairs(state.evidence) do
		local row = UIKit.frame({
			name = "Clue" .. index,
			size = UDim2.new(1, -8, 0, 58),
			color = UIKit.Palette.PanelLight,
			corner = 8,
			parent = widgets.evidenceList,
		})
		UIKit.label({
			name = "Label",
			text = "• " .. (entry.label or entry.id),
			size = UDim2.new(1, -12, 0, 22),
			position = UDim2.fromOffset(8, 4),
			textColor = UIKit.Palette.Accent,
			font = UIKit.Fonts.bold,
			textSize = 13,
			parent = row,
		})
		UIKit.label({
			name = "Text",
			text = entry.text or "",
			size = UDim2.new(1, -12, 0, 28),
			position = UDim2.fromOffset(8, 26),
			textColor = UIKit.Palette.TextDim,
			textSize = 11,
			parent = row,
		})
	end

	if #state.evidence == 0 then
		UIKit.label({
			name = "Empty",
			text = "Nenhuma pista ainda. Explore o cenário e converse com os NPCs.",
			size = UDim2.new(1, -12, 0, 40),
			textColor = UIKit.Palette.TextDim,
			textSize = 12,
			parent = widgets.evidenceList,
		})
	end
end

function HudController.notify(payload)
	local card = UIKit.frame({
		name = "Notify",
		size = UDim2.fromOffset(300, payload.text and 76 or 52),
		color = UIKit.Palette.Panel,
		corner = 10,
		parent = widgets.notifyHolder,
		stroke = true,
		strokeColor = UIKit.notifyColor(payload.kind),
	})
	UIKit.padding(card, 8)
	UIKit.label({
		name = "Title",
		text = payload.title or "Aviso",
		size = UDim2.new(1, 0, 0, 20),
		textColor = UIKit.notifyColor(payload.kind),
		font = UIKit.Fonts.bold,
		textSize = 14,
		parent = card,
	})
	UIKit.label({
		name = "Text",
		text = payload.text or "",
		size = UDim2.new(1, 0, 0, 40),
		position = UDim2.fromOffset(0, 22),
		textColor = UIKit.Palette.Text,
		textSize = 12,
		yAlign = Enum.TextYAlignment.Top,
		parent = card,
	})

	UIKit.popIn(card, UDim2.fromOffset(30, 0))

	task.delay(payload.duration or 5, function()
		if card.Parent then
			local tween = TweenService:Create(card, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
			tween:Play()
			for _, child in ipairs(card:GetDescendants()) do
				if child:IsA("TextLabel") then
					TweenService:Create(child, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
				elseif child:IsA("UIStroke") then
					TweenService:Create(child, TweenInfo.new(0.3), { Transparency = 1 }):Play()
				end
			end
			task.wait(0.35)
			card:Destroy()
		end
	end)
end

function HudController.showResult(payload)
	widgets.result.Visible = true
	widgets.resultTitle.Text = payload.title or "Resultado"
	widgets.resultText.Text = payload.text or ""
	widgets.resultTitle.TextColor3 = payload.kind == "fail" and UIKit.Palette.Danger or UIKit.Palette.Gold
	if payload.points then
		widgets.resultText.Text ..= ("\n\nPontuação da turma: %s"):format(UIKit.formatNumber(payload.points))
	end
	UIKit.popIn(widgets.result)
end

function HudController.showUnlock(payload)
	HudController.notify({
		title = payload.kind == "achievement" and "CONQUISTA DESBLOQUEADA" or "NOVO ITEM",
		text = ("%s — %s%s"):format(
			payload.name or payload.id,
			payload.description or "",
			payload.reward and (" (+" .. payload.reward .. " snacks)") or ""
		),
		kind = "hint",
		duration = 7,
	})
end

-- ==========================================================
-- LOOP (relógio local + medo)
-- ==========================================================
function HudController.start()
	HudController.build()

	local clockAccumulator = 0
	RunService.Heartbeat:Connect(function(deltaTime)
		clockAccumulator += deltaTime
		if clockAccumulator >= 1 then
			clockAccumulator = 0
			if state.timeLeft > 0 then
				HudController.setClock(state.timeLeft - 1)
			end
		end
		local fear = player:GetAttribute("Fear") or 0
		HudController.setFear(fear)
	end)
end

HudController.State = state

return HudController
