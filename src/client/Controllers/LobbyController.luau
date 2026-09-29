--[[
	LobbyController.luau
	A tela de turma (tecla L):
		* lista de turmas abertas no servidor (entrar)
		* sua turma: membros, prontidão, líder
		* privacidade: PÚBLICA / SOMENTE AMIGOS / SOMENTE CONVITE / FECHADA
		* convite de amigos que estão no servidor
		* escolha do episódio (líder) + começar caso (contagem regressiva)
		* loja de Scooby Snacks
		* escolha de personagem (Fred, Daphne, Velma, Salsinha, Scooby)
		* conquistas e progresso da temporada
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Cast = require(Shared.Data.Cast)
local Definitions = require(Shared.Data.Definitions)
local Episodes = require(Shared.Data.Episodes)
local Roles = require(Shared.Roles)
local Net = require(Shared.Net)

local UIKit = require(script.Parent.Parent.Modules.UIKit)

local LobbyController = {}

local gui, panel, partyList, memberList, shopList, privacyLabel, episodeLabel
local state = { party = nil, parties = {}, profile = nil, selectedEpisode = "EP01" }
local open = false
local countdownLabel

local PRIVACY_LABEL = {
	publica = "PÚBLICA",
	somente_amigos = "SOMENTE AMIGOS",
	somente_convite = "SOMENTE CONVITE",
	fechada = "FECHADA",
}

local PRIVACY_ORDER = { "publica", "somente_amigos", "somente_convite", "fechada" }

-- ==========================================================
-- CONSTRUÇÃO
-- ==========================================================
local function buildMemberRows(parent, members)
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	for index, member in ipairs(members or {}) do
		local row = UIKit.frame({
			name = "Member" .. index,
			size = UDim2.new(1, -8, 0, 34),
			color = UIKit.Palette.PanelLight,
			corner = 8,
			parent = parent,
		})
		UIKit.label({
			name = "Name",
			text = ("%s%s"):format(member.name, member.isLeader and "  👑 líder" or ""),
			size = UDim2.new(0.55, 0, 1, 0),
			position = UDim2.fromOffset(10, 0),
			textColor = member.isLeader and UIKit.Palette.Gold or UIKit.Palette.Text,
			font = UIKit.Fonts.bold,
			textSize = 13,
			parent = row,
		})
		UIKit.label({
			name = "Role",
			text = member.role or "?",
			size = UDim2.new(0.25, 0, 1, 0),
			position = UDim2.fromScale(0.56, 0),
			textColor = UIKit.Palette.Accent,
			textSize = 12,
			parent = row,
		})
		UIKit.label({
			name = "Ready",
			text = member.isLeader and "—" or (member.ready and "PRONTO" or "esperando"),
			size = UDim2.new(0.19, 0, 1, 0),
			position = UDim2.fromScale(0.81, 0),
			textColor = member.ready and UIKit.Palette.Accent or UIKit.Palette.TextDim,
			textSize = 11,
			xAlign = Enum.TextXAlignment.Right,
			parent = row,
		})
	end
	if #(members or {}) == 0 then
		UIKit.label({
			name = "EmptyMembers",
			text = "Você ainda não está numa turma. Crie uma para puxar a partida!",
			size = UDim2.new(1, -12, 0, 32),
			textColor = UIKit.Palette.TextDim,
			textSize = 12,
			parent = parent,
		})
	end
end

local function buildPartyRows(parties)
	partyList:ClearAllChildren()
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = partyList

	if #parties == 0 then
		UIKit.label({
			name = "None",
			text = "Nenhuma turma aberta. Crie a sua!",
			size = UDim2.new(1, -12, 0, 30),
			textColor = UIKit.Palette.TextDim,
			textSize = 12,
			parent = partyList,
		})
		return
	end

	for _, entry in ipairs(parties) do
		local row = UIKit.frame({
			name = entry.id,
			size = UDim2.new(1, -8, 0, 52),
			color = UIKit.Palette.PanelLight,
			corner = 8,
			parent = partyList,
		})
		UIKit.label({
			name = "Info",
			text = ("%s · %d/%d\n%s"):format(
				entry.leaderName,
				entry.size,
				entry.maxSize,
				PRIVACY_LABEL[entry.privacy] or entry.privacy
			),
			size = UDim2.new(0.7, 0, 1, 0),
			position = UDim2.fromOffset(10, 0),
			textColor = UIKit.Palette.Text,
			textSize = 12,
			parent = row,
		})
		UIKit.button({
			name = "Join",
			text = entry.joinable and "ENTRAR" or "—",
			size = UDim2.fromOffset(90, 30),
			position = UDim2.new(1, -98, 0.5, -15),
			color = entry.joinable and UIKit.Palette.Accent or UIKit.Palette.Panel,
			textColor = entry.joinable and UIKit.Palette.Night or UIKit.Palette.TextDim,
			parent = row,
			onClick = function()
				if entry.joinable then
					Net.fireServer("PartyJoin", entry.id)
				end
			end,
		})
	end
end

local function buildShop()
	shopList:ClearAllChildren()
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = shopList

	for _, item in ipairs(Definitions.Shop) do
		local row = UIKit.frame({
			name = item.id,
			size = UDim2.new(1, -8, 0, 62),
			color = UIKit.Palette.PanelLight,
			corner = 8,
			parent = shopList,
		})
		UIKit.label({
			name = "Name",
			text = item.name,
			size = UDim2.new(1, -110, 0, 22),
			position = UDim2.fromOffset(10, 4),
			textColor = UIKit.Palette.Text,
			font = UIKit.Fonts.bold,
			textSize = 13,
			parent = row,
		})
		UIKit.label({
			name = "Desc",
			text = item.description,
			size = UDim2.new(1, -110, 0, 30),
			position = UDim2.fromOffset(10, 26),
			textColor = UIKit.Palette.TextDim,
			textSize = 11,
			parent = row,
		})
		UIKit.button({
			name = "Buy",
			text = ("🍪 %d"):format(item.price),
			size = UDim2.fromOffset(96, 32),
			position = UDim2.new(1, -104, 0.5, -16),
			color = UIKit.Palette.Gold,
			textColor = UIKit.Palette.Night,
			parent = row,
			onClick = function()
				Net.fireServer("LobbyBuyItem", item.id)
			end,
		})
	end
end

local function buildCharacters()
	for _, child in ipairs(LobbyController.CharacterRow:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	local layout = LobbyController.CharacterRow:FindFirstChildOfClass("UIListLayout")
	if not layout then
		layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 6)
		layout.Parent = LobbyController.CharacterRow
	end

	local function addCharacter(id, name, color)
		UIKit.button({
			name = id,
			text = name,
			size = UDim2.fromOffset(112, 34),
			color = color,
			parent = LobbyController.CharacterRow,
			onClick = function()
				Net.fireServer("LobbySelectCharacter", id)
			end,
		})
	end

	addCharacter("Fred", "Fred", UIKit.Palette.Purple)
	addCharacter("Daphne", "Daphne", Color3.fromRGB(180, 110, 210))
	addCharacter("Velma", "Velma", Color3.fromRGB(226, 130, 60))
	addCharacter("Shaggy", "Salsicha", Color3.fromRGB(112, 176, 84))
	addCharacter("Scooby", "Scooby", Color3.fromRGB(160, 108, 62))
end

function LobbyController.build()
	gui = Instance.new("ScreenGui")
	gui.Name = "MysteryLobby"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 6
	gui.Parent = player:WaitForChild("PlayerGui")

	local backdrop = UIKit.frame({
		name = "Backdrop",
		size = UDim2.fromScale(1, 1),
		color = UIKit.Palette.Night,
		transparency = 0.4,
		parent = gui,
		visible = false,
	})
	LobbyController.Backdrop = backdrop

	panel = UIKit.frame({
		name = "Panel",
		size = UDim2.fromOffset(1040, 620),
		position = UDim2.fromScale(0.5, 0.5),
		anchor = Vector2.new(0.5, 0.5),
		color = UIKit.Palette.Panel,
		corner = 18,
		parent = gui,
		visible = false,
		stroke = true,
		strokeColor = UIKit.Palette.Accent,
	})
	UIKit.padding(panel, 16)
	LobbyController.Panel = panel

	local title = UIKit.label({
		name = "Title",
		text = "ARQUIVOS DO MISTÉRIO — MONTAGEM DE TURMA",
		size = UDim2.new(1, 0, 0, 34),
		textColor = UIKit.Palette.Accent,
		font = UIKit.Fonts.bold,
		textSize = 22,
		parent = panel,
	})
	UIKit.label({
		name = "Sub",
		text = "1 a 4 jogadores · a partida começa quando o líder decidir · L fecha",
		size = UDim2.new(1, 0, 0, 20),
		position = UDim2.fromOffset(0, 32),
		textColor = UIKit.Palette.TextDim,
		textSize = 12,
		parent = panel,
	})

	-- Coluna esquerda: sua turma
	local left = UIKit.frame({
		name = "Left",
		size = UDim2.fromOffset(420, 470),
		position = UDim2.fromOffset(0, 60),
		color = UIKit.Palette.Night,
		corner = 12,
		parent = panel,
		stroke = true,
	})
	UIKit.padding(left, 12)
	UIKit.label({
		name = "LeftTitle",
		text = "SUA TURMA",
		size = UDim2.new(1, 0, 0, 24),
		textColor = UIKit.Palette.Text,
		font = UIKit.Fonts.bold,
		textSize = 15,
		parent = left,
	})

	local memberHolder = UIKit.frame({
		name = "Members",
		size = UDim2.new(1, 0, 0, 190),
		position = UDim2.fromOffset(0, 28),
		color = UIKit.Palette.Night,
		transparency = 1,
		parent = left,
	})
	local memberLayout = Instance.new("UIListLayout")
	memberLayout.Padding = UDim.new(0, 6)
	memberLayout.Parent = memberHolder
	memberList = memberHolder

	-- Botões de turma
	UIKit.button({
		name = "Create",
		text = "CRIAR TURMA",
		size = UDim2.fromOffset(130, 34),
		position = UDim2.fromOffset(0, 224),
		color = UIKit.Palette.Accent,
		textColor = UIKit.Palette.Night,
		parent = left,
		onClick = function()
			Net.fireServer("PartyCreate", state.party and state.party.privacy or "publica")
		end,
	})
	UIKit.button({
		name = "Leave",
		text = "SAIR",
		size = UDim2.fromOffset(90, 34),
		position = UDim2.fromOffset(138, 224),
		color = UIKit.Palette.PanelLight,
		parent = left,
		onClick = function()
			Net.fireServer("PartyLeave")
		end,
	})
	UIKit.button({
		name = "Ready",
		text = "ESTOU PRONTO",
		size = UDim2.fromOffset(130, 34),
		position = UDim2.fromOffset(236, 224),
		color = UIKit.Palette.Warning,
		textColor = UIKit.Palette.Night,
		parent = left,
		onClick = function()
			Net.fireServer("PartyCreate", "publica") -- garante turma
			task.wait(0.2)
			-- prontidão é enviada em conjunto com a escolha de personagem
			Net.fireServer("PartyStartMatch")
		end,
	})

	privacyLabel = UIKit.label({
		name = "Privacy",
		text = "PRIVACIDADE: —",
		size = UDim2.new(1, 0, 0, 24),
		position = UDim2.fromOffset(0, 264),
		textColor = UIKit.Palette.Warning,
		font = UIKit.Fonts.bold,
		textSize = 14,
		parent = left,
	})
	UIKit.button({
		name = "PrivacyCycle",
		text = "ALTERNAR PRIVACIDADE",
		size = UDim2.fromOffset(200, 30),
		position = UDim2.fromOffset(0, 288),
		color = UIKit.Palette.PanelLight,
		parent = left,
		onClick = function()
			local current = state.party and state.party.privacy or "publica"
			local index = table.find(PRIVACY_ORDER, current) or 1
			local next_ = PRIVACY_ORDER[(index % #PRIVACY_ORDER) + 1]
			Net.fireServer("PartySetPrivacy", next_)
		end,
	})

	UIKit.label({
		name = "InviteHint",
		text = "Convide amigos que estão no servidor:",
		size = UDim2.new(1, 0, 0, 20),
		position = UDim2.fromOffset(0, 322),
		textColor = UIKit.Palette.TextDim,
		textSize = 12,
		parent = left,
	})
	local inviteRow = UIKit.frame({
		name = "InviteRow",
		size = UDim2.new(1, 0, 0, 36),
		position = UDim2.fromOffset(0, 344),
		color = UIKit.Palette.Night,
		transparency = 1,
		parent = left,
	})
	local inviteLayout = Instance.new("UIListLayout")
	inviteLayout.FillDirection = Enum.FillDirection.Horizontal
	inviteLayout.Padding = UDim.new(0, 6)
	inviteLayout.Parent = inviteRow
	LobbyController.InviteRow = inviteRow

	UIKit.label({
		name = "CharTitle",
		text = "SEU PERSONAGEM:",
		size = UDim2.new(1, 0, 0, 20),
		position = UDim2.fromOffset(0, 386),
		textColor = UIKit.Palette.TextDim,
		textSize = 12,
		parent = left,
	})
	local characterRow = UIKit.frame({
		name = "CharacterRow",
		size = UDim2.new(1, 0, 0, 40),
		position = UDim2.fromOffset(0, 408),
		color = UIKit.Palette.Night,
		transparency = 1,
		parent = left,
	})
	LobbyController.CharacterRow = characterRow

	-- Coluna do meio: casos
	local middle = UIKit.frame({
		name = "Middle",
		size = UDim2.fromOffset(300, 470),
		position = UDim2.fromOffset(432, 60),
		color = UIKit.Palette.Night,
		corner = 12,
		parent = panel,
		stroke = true,
	})
	UIKit.padding(middle, 12)
	UIKit.label({
		name = "MiddleTitle",
		text = "CASOS DA TEMPORADA",
		size = UDim2.new(1, 0, 0, 24),
		textColor = UIKit.Palette.Text,
		font = UIKit.Fonts.bold,
		textSize = 15,
		parent = middle,
	})
	local caseHolder, caseScroll = UIKit.scrollingList({
		size = UDim2.new(1, 0, 1, -110),
		position = UDim2.fromOffset(0, 28),
		parent = middle,
		gap = 6,
	})
	for _, episodeId in ipairs(Episodes.Season.order) do
		local episode = Episodes.getEpisode(episodeId)
		local row = UIKit.frame({
			name = episodeId,
			size = UDim2.new(1, -8, 0, 56),
			color = UIKit.Palette.PanelLight,
			corner = 8,
			parent = caseScroll,
		})
		UIKit.label({
			name = "Name",
			text = episode.name,
			size = UDim2.new(1, -12, 0, 22),
			position = UDim2.fromOffset(8, 4),
			textColor = UIKit.Palette.Text,
			font = UIKit.Fonts.bold,
			textSize = 12,
			parent = row,
		})
		UIKit.label({
			name = "Where",
			text = ("%s · %d capítulos"):format(episode.locationName or episode.location or "?", #episode.chapters),
			size = UDim2.new(1, -12, 0, 22),
			position = UDim2.fromOffset(8, 26),
			textColor = UIKit.Palette.TextDim,
			textSize = 11,
			parent = row,
		})
		row.Active = true
		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				state.selectedEpisode = episodeId
				Net.fireServer("PartySetEpisode", episodeId)
				episodeLabel.Text = "CASO: " .. episode.name
			end
		end)
	end

	episodeLabel = UIKit.label({
		name = "Episode",
		text = "CASO: EP01",
		size = UDim2.new(1, 0, 0, 22),
		position = UDim2.new(0, 0, 1, -74),
		textColor = UIKit.Palette.Accent,
		font = UIKit.Fonts.bold,
		textSize = 13,
		parent = middle,
	})
	UIKit.button({
		name = "Start",
		text = "COMEÇAR O CASO",
		size = UDim2.new(1, 0, 0, 42),
		position = UDim2.new(0, 0, 1, -46),
		color = UIKit.Palette.Accent,
		textColor = UIKit.Palette.Night,
		parent = middle,
		onClick = function()
			Net.fireServer("PartyStartMatch")
		end,
	})
	UIKit.button({
		name = "Invite",
		text = "CONVIDAR AMIGO (lista)",
		size = UDim2.new(1, 0, 0, 24),
		position = UDim2.new(0, 0, 1, -72),
		color = UIKit.Palette.Purple,
		textSize = 11,
		parent = middle,
		onClick = function()
			LobbyController.inviteEveryoneInServer()
		end,
	})

	-- Coluna direita: loja + turmas abertas
	local right = UIKit.frame({
		name = "Right",
		size = UDim2.fromOffset(276, 470),
		position = UDim2.fromOffset(744, 60),
		color = UIKit.Palette.Night,
		corner = 12,
		parent = panel,
		stroke = true,
	})
	UIKit.padding(right, 12)
	UIKit.label({
		name = "RightTitle",
		text = "LOJA DA VAN (SCOOBY SNACKS)",
		size = UDim2.new(1, 0, 0, 24),
		textColor = UIKit.Palette.Gold,
		font = UIKit.Fonts.bold,
		textSize = 13,
		parent = right,
	})
	local _, shopScroll = UIKit.scrollingList({
		size = UDim2.new(1, 0, 1, -190),
		position = UDim2.fromOffset(0, 26),
		parent = right,
		gap = 6,
	})
	shopList = shopScroll

	UIKit.label({
		name = "OpenTitle",
		text = "TURMAS ABERTAS",
		size = UDim2.new(1, 0, 0, 22),
		position = UDim2.new(0, 0, 1, -156),
		textColor = UIKit.Palette.Text,
		font = UIKit.Fonts.bold,
		textSize = 13,
		parent = right,
	})
	local partyHolder, partyScroll = UIKit.scrollingList({
		size = UDim2.new(1, 0, 0, 130),
		position = UDim2.new(0, 0, 1, -132),
		parent = right,
		gap = 6,
	})
	partyList = partyScroll

	-- Contagem regressiva
	countdownLabel = UIKit.label({
		name = "Countdown",
		text = "",
		size = UDim2.fromScale(1, 1),
		textColor = UIKit.Palette.Accent,
		font = UIKit.Fonts.bold,
		textSize = 96,
		xAlign = Enum.TextXAlignment.Center,
		parent = gui,
		visible = false,
	})
	LobbyController.Countdown = countdownLabel

	return gui
end

-- ==========================================================
-- ABRIR / FECHAR
-- ==========================================================
function LobbyController.toggle(force)
	local shouldOpen = force ~= nil and force or not open
	open = shouldOpen
	LobbyController.Backdrop.Visible = open
	panel.Visible = open
	if open then
		Net.fireServer("LobbyRequestState")
		UIKit.popIn(panel, UDim2.fromOffset(0, 30))
	end
end

function LobbyController.isOpen()
	return open
end

function LobbyController.inviteEveryoneInServer()
	local party = state.party
	if not party then
		Net.fireServer("PartyCreate", "publica")
		task.wait(0.3)
	end
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			Net.fireServer("PartyInviteFriend", other.UserId)
			task.wait(0.15)
		end
	end
end

-- ==========================================================
-- ATUALIZAÇÕES
-- ==========================================================
function LobbyController.applyParty(payload)
	state.party = payload.party
	state.parties = payload.parties or state.parties
	state.profile = payload.profile or state.profile

	if payload.party then
		buildMemberRows(memberList, payload.party.members)
		privacyLabel.Text = "PRIVACIDADE: " .. (PRIVACY_LABEL[payload.party.privacy] or payload.party.privacy)
		episodeLabel.Text = "CASO: " .. (payload.party.episode or "EP01")
		state.selectedEpisode = payload.party.episode or state.selectedEpisode
	else
		buildMemberRows(memberList, {})
		privacyLabel.Text = "PRIVACIDADE: — (sem turma)"
	end
end

function LobbyController.applyLobby(payload)
	if payload.parties then
		state.parties = payload.parties
		buildPartyRows(payload.parties)
	end
	if payload.profile then
		state.profile = payload.profile
	end
	if payload.shop then
		buildShop()
	end
	if payload.party then
		state.party = payload.party
		buildMemberRows(memberList, payload.party.members)
	end
end

function LobbyController.applyVote(payload)
	if payload.phase == "countdown" then
		countdownLabel.Visible = true
		countdownLabel.Text = tostring(payload.seconds)
		if payload.seconds <= 1 then
			task.delay(1, function()
				countdownLabel.Visible = false
			end)
		end
	end
end

function LobbyController.start()
	LobbyController.build()
	buildShop()
	buildCharacters()

	Net.Event("ClientLobby").OnClientEvent:Connect(function(payload)
		if payload then
			LobbyController.applyLobby(payload)
		end
	end)

	Net.Event("ClientParty").OnClientEvent:Connect(function(payload)
		if payload then
			LobbyController.applyParty(payload)
			if payload.extra and payload.extra.joined then
				UIKit.popIn(panel, UDim2.fromOffset(0, 12))
			end
		end
	end)

	Net.Event("ClientVote").OnClientEvent:Connect(function(payload)
		if payload then
			LobbyController.applyVote(payload)
		end
	end)

	Net.Event("ClientChapterStart").OnClientEvent:Connect(function(payload)
		LobbyController.toggle(false)
		countdownLabel.Visible = false
	end)

	-- pede o estado quando o jogador entra
	task.delay(3, function()
		Net.fireServer("LobbyRequestState")
	end)
end

return LobbyController
