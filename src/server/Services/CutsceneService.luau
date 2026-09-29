--[[
	CutsceneService.luau
	Cinematográficas leves, controladas pelo servidor e reproduzidas no cliente
	(o cliente move a câmera; o servidor só diz o que mostrar).

	Tipos:
		* intro    -> slides do capítulo (Episodes.Chapters[].intro)
		* monster  -> aparição do monstro (pan + sting)
		* capture  -> monstro preso na armadilha
		* reveal   -> tira a máscara (o clássico "e o culpado é...")
		* episode  -> encerramento de episódio
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Cast = require(Shared.Data.Cast)
local Episodes = require(Shared.Data.Episodes)
local Net = require(Shared.Net)

local CutsceneService = {}

local skipped = {}
local activeCutscene = {}

function CutsceneService.playIntro(players, chapter)
	local intro = chapter.intro
	if not intro then
		return
	end
	local cutsceneId = chapter.id .. "_intro"
	for _, player in ipairs(players) do
		activeCutscene[player] = cutsceneId
		Net.fireClient(player, "ClientCutscene", {
			kind = "intro",
			id = cutsceneId,
			title = intro.title or chapter.name,
			subtitle = intro.subtitle or (chapter.episode .. " · " .. chapter.name),
			narrator = intro.narrator,
			slides = intro.slides or {},
			brief = chapter.brief,
			duration = math.max(4, #(intro.slides or {}) * 4),
		})
	end
end

function CutsceneService.playMonsterIntro(players, chapter, monster)
	if not monster then
		return
	end
	local cutsceneId = chapter.id .. "_monster"
	for _, player in ipairs(players) do
		Net.fireClient(player, "ClientCutscene", {
			kind = "monster",
			id = cutsceneId,
			title = monster.name,
			subtitle = monster.title,
			description = monster.description,
			duration = 4,
			sfx = "GhostMoan",
		})
	end
end

function CutsceneService.playReveal(players, chapter)
	local reveal = chapter.reveal
	if not reveal then
		return
	end
	local npc = reveal.unmaskedNpc and Cast.getNpc(reveal.unmaskedNpc)
	local monster = Cast.getMonster(chapter.episode)
	local dialogue = reveal.dialogue and require(Shared.Data.Dialogue).get(reveal.dialogue)

	local slides = {}
	if monster then
		table.insert(slides, {
			speaker = monster.name,
			text = "Vocês me pegaram... mas o farol era meu por direito!",
			emote = "defeated",
		})
	end
	if dialogue then
		-- usa os 4 primeiros nós da árvore de revelação
		local nodes = dialogue.nodes or dialogue
		local current = dialogue.start or "n1"
		for _ = 1, 4 do
			local node = nodes[current]
			if not node then
				break
			end
			table.insert(slides, {
				speaker = npc and (npc.name or npc.id) or "???",
				text = node.text,
				emote = node.emote,
			})
			current = node.next or (node.choices and node.choices[1] and node.choices[1].next)
		end
	end
	if reveal.quote then
		table.insert(slides, { speaker = "Fred", text = reveal.quote, emote = "happy" })
	end

	for _, player in ipairs(players) do
		Net.fireClient(player, "ClientCutscene", {
			kind = "reveal",
			id = chapter.id .. "_reveal",
			title = "E o culpado é...",
			subtitle = npc and (npc.name or npc.id) or "???",
			unmasked = npc and npc.id,
			slides = slides,
			duration = 12,
			sfx = "UnmaskStinger",
		})
	end
end

function CutsceneService.playCapture(players, chapter, monster)
	for _, player in ipairs(players) do
		Net.fireClient(player, "ClientCutscene", {
			kind = "capture",
			id = chapter.id .. "_capture",
			title = "Pegamos o fantasma!",
			subtitle = monster and monster.name or "???",
			slides = {
				{
					speaker = "Fred",
					text = "Caiu na armadilha! Ninguém escapa de um plano do Fred.",
					emote = "excited",
				},
				{ speaker = "Salsicha", text = "Tipo assim, eu ajudei, né? Eu ajudei MUITO.", emote = "scared" },
			},
			duration = 7,
			sfx = "TrapSpring",
		})
	end
end

function CutsceneService.skip(player)
	local id = activeCutscene[player]
	if id then
		skipped[player] = id
		Net.fireClient(player, "ClientCutsceneEnd", { id = id, skipped = true })
	end
end

function CutsceneService.wasSkipped(player, id)
	if skipped[player] == id then
		skipped[player] = nil
		return true
	end
	return false
end

function CutsceneService.endFor(player)
	activeCutscene[player] = nil
end

function CutsceneService.start()
	Net.Event("GameSkipCutscene").OnServerEvent:Connect(function(player)
		CutsceneService.skip(player)
	end)
end

return CutsceneService
