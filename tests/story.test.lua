local T = require("tests/runner")

local Episodes = require("Episodes")
local Dialogue = require("Dialogue")
local Cast = require("Cast")
local Definitions = require("Definitions")
local Assets = require("Assets")

-- Episódios e capítulos
local ok, problems = Episodes.validate()
T.check(ok, "Episodes.validate() sem problemas" .. (ok and "" or (": " .. table.concat(problems, " | "))))
T.check(Episodes.chapterCount() >= 24, "campanha tem pelo menos 24 capítulos (tem " .. Episodes.chapterCount() .. ")")
T.check(Episodes.totalPoints() > 20000, "campanha dá mais de 20k pontos (" .. Episodes.totalPoints() .. ")")

-- Cada episódio tem monstro definido e capítulos com fases distintas
for _, episodeId in ipairs(Episodes.Season.order) do
	local episode = Episodes.getEpisode(episodeId)
	T.check(episode ~= nil, "episódio existe: " .. episodeId)
	if episode then
		T.check(Cast.getMonster(episodeId) ~= nil, "monstro definido para " .. episodeId)
		local chapters = Episodes.chapterList(episodeId)
		T.check(#chapters == #episode.chapters, "todos os capítulos de " .. episodeId .. " existem")
		local phases = {}
		for _, chapter in ipairs(chapters) do
			phases[chapter.phase] = true
			T.check(chapter.brief and #chapter.brief > 40, "capítulo " .. chapter.id .. " tem briefing")
			T.check(#chapter.clues > 0, "capítulo " .. chapter.id .. " tem pistas")
			T.check(chapter.mood ~= nil, "capítulo " .. chapter.id .. " tem clima (mood)")
		end
		T.check(phases["investigacao"] and phases["revelacao"], "episódio " .. episodeId .. " tem fases de investigação e revelação")
	end
end

-- Diálogos
local dialogOk, dialogProblems = Dialogue.validate()
T.check(dialogOk, "Dialogue.validate() sem problemas" .. (dialogOk and "" or (": " .. table.concat(dialogProblems, " | "))))
T.check(Dialogue.countLines() > 200, "mais de 200 falas/diálogos no jogo (" .. Dialogue.countLines() .. ")")

-- Todo NPC do elenco tem diálogo e casa válida
for _, npc in ipairs(Cast.Npcs) do
	T.check(Dialogue.Nodes[npc.dialogue] ~= nil, "NPC " .. npc.id .. " tem árvore de diálogo (" .. npc.dialogue .. ")")
	T.check(npc.brief ~= nil and #npc.brief > 20, "NPC " .. npc.id .. " tem brief")
	T.check(Cast.Monsters[npc.episode] ~= nil, "NPC " .. npc.id .. " pertence a episódio existente")
end

-- Heróis e Scooby
for _, roleId in ipairs({ "Fred", "Daphne", "Velma", "Shaggy" }) do
	T.check(Cast.Heroes[roleId] ~= nil, "herói definido: " .. roleId)
	T.check(Dialogue.VoiceLines[roleId] ~= nil, "voice lines definidas: " .. roleId)
end
T.check(Dialogue.VoiceLines["Scooby"] ~= nil, "voice lines do Scooby definidas")

-- Loja e conquistas
local defOk, defProblems = Definitions.validate()
T.check(defOk, "Definitions.validate() sem problemas" .. (defOk and "" or (": " .. table.concat(defProblems, " | "))))
T.check(#Definitions.Difficulty == 4, "4 níveis de dificuldade")
T.check(#Definitions.Shop >= 10, "loja tem pelo menos 10 itens")

-- Assets: sons embutidos existem
for name, path in pairs(Assets.Sfx) do
	T.check(type(path) == "string" and path:sub(1, 11) == "rbxasset://", "som embutido válido: " .. name)
end

local summary, failed = T.report()
if failed > 0 then
	error("story.test.lua: " .. summary)
end
return summary
