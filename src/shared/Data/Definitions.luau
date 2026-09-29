--[[
	Definitions.luau
	Itens da loja, conquistas, melhorias de lobby e definições de progressão.
]]

local Definitions = {}

-- ==========================================================
-- MOEDA: SCOOBY SNACKS
-- ==========================================================
Definitions.Currency = {
	name = "Scooby Snacks",
	icon = "🍪",
	description = "Ganhos resolvendo casos, achando pistas e prendendo monstros. Servem para comprar itens e dicas.",
}

-- ==========================================================
-- LOJA DA SEDE
-- effect é aplicado pelo LobbyService (dado -> comportamento)
-- ==========================================================
Definitions.Shop = {
	{
		id = "snack_basic",
		name = "Pacote de Scooby Snacks",
		price = 50,
		category = "consumivel",
		description = "5 usos: jogue um Snack para distrair o monstro por 6 segundos.",
		grants = { snackCharges = 5 },
		color = "MysteryOrange",
	},
	{
		id = "flashlight",
		name = "Lanterna de Mão",
		price = 150,
		category = "equipamento",
		description = "Aumenta o alcance da lanterna e revela pistas fracas (brilho) em 20 studs.",
		grants = { flashlightLevel = 1 },
	},
	{
		id = "rope",
		name = "Corda de Armar Armadilha",
		price = 220,
		category = "equipamento",
		description = "Começa cada capítulo com 1 peça de armadilha extra no inventário.",
		grants = { bonusTrapParts = 1 },
	},
	{
		id = "megaphone",
		name = "Megafone do Fred",
		price = 300,
		category = "equipamento",
		description = "Reúne o grupo: mostra a posição de todos os jogadores por 10s.",
		grants = { megaphone = true },
	},
	{
		id = "snack_deluxe",
		name = "Sanduíche Gigante do Salsicha",
		price = 450,
		category = "consumivel",
		description = "3 usos: atrai QUALQUER monstro para o ponto onde foi jogado, por 8 segundos.",
		grants = { megaSnackCharges = 3 },
	},
	{
		id = "detector",
		name = "Detector de Metais da Velma",
		price = 600,
		category = "equipamento",
		description = "Apita quando uma peça de armadilha está a menos de 40 studs.",
		grants = { trapDetector = true },
	},
	{
		id = "costume_extra",
		name = "Kit de Disfarce",
		price = 750,
		category = "cosmetico",
		description = "Desbloqueia disfarces extras para os jogadores da sua sala (cosmético).",
		grants = { costumes = true },
	},
	{
		id = "scooby_badge",
		name = "Coleira de Ouro do Scooby",
		price = 1200,
		category = "cosmetico",
		description = "Scooby usa coleira de ouro e ganha +20% de alcance no Sentido Scooby.",
		grants = { scoobySense = 1.2, cosmetic = "gold_collar" },
	},
	{
		id = "van_upgrade",
		name = "Melhoria da Mystery Machine",
		price = 2000,
		category = "melhoria",
		description = "+5 Slots de Snack no porta-luvas e +10% de pontos por pista em todos os capítulos.",
		grants = { snackSlots = 5, clueMultiplier = 1.1 },
	},
	{
		id = "trap_kit",
		name = "Kit de Armadilha Profissional",
		price = 2500,
		category = "melhoria",
		description = "Armadilhas armam 25% mais rápido e o monstro fica preso por 3s extra.",
		grants = { trapArmSpeed = 1.25, trapHoldBonus = 3 },
	},
	{
		id = "archive_access",
		name = "Acesso ao Arquivo do Mistério S.A.",
		price = 3000,
		category = "melhoria",
		description = "Libera o modo Arquivo: rejogue capítulos já resolvidos com pontuação dobrada.",
		grants = { archiveMode = true },
	},
	{
		id = "coolsville_trophy",
		name = "Troféu de Coolsville",
		price = 15000,
		category = "colecao",
		description = "Cosmético lendário: uma estátua da turma aparece no pátio da sede.",
		grants = { trophy = true },
	},
}

-- ==========================================================
-- CONQUISTAS
-- ==========================================================
Definitions.Achievements = {
	primeiro_caso = {
		id = "primeiro_caso",
		name = "Primeiro Caso Fechado",
		description = "Complete o Capítulo 1 do episódio do Farol.",
		snacks = 150,
	},
	sem_levar_susto = {
		id = "sem_levar_susto",
		name = "Nem um Arrepio",
		description = "Complete um capítulo inteiro sem ser pego nenhuma vez.",
		snacks = 300,
	},
	detetive_relampago = {
		id = "detetive_relampago",
		name = "Detetive Relâmpago",
		description = "Complete o episódio final em menos da metade do tempo limite.",
		snacks = 1000,
	},
	amigo_do_scooby = {
		id = "amigo_do_scooby",
		name = "Amigo do Scooby",
		description = "Dê 10 Scooby Snacks para o Scooby em uma única partida.",
		snacks = 250,
	},
	turma_completa = {
		id = "turma_completa",
		name = "Turma Completa",
		description = "Complete um episódio com 4 jogadores, cada um com um papel diferente.",
		snacks = 500,
	},
	craque_de_coolsville = {
		id = "craque_de_coolsville",
		name = "Craque de Coolsville",
		description = "Resolva os 6 episódios da temporada.",
		snacks = 2500,
	},
	-- conquistas extras (progressão livre)
	todos_os_cenarios = {
		id = "todos_os_cenarios",
		name = "Curador de Circo",
		description = "Desligue os 6 cenários do armazém do Colecionador.",
		snacks = 800,
	},
	mestre_das_pistas = {
		id = "mestre_das_pistas",
		name = "Mestre das Pistas",
		description = "Ache 100 pistas na temporada.",
		snacks = 700,
	},
	heroi_do_farol = {
		id = "heroi_do_farol",
		name = "Luz Acesa",
		description = "Resolva o episódio 1 com o farol funcionando.",
		snacks = 200,
	},
	voz_do_bairro = {
		id = "voz_do_bairro",
		name = "Voz do Bairro",
		description = "Converse com todos os NPCs de um episódio.",
		snacks = 350,
	},
}

-- ==========================================================
-- PERSONAGENS JOGÁVEIS / TRAJES
-- ==========================================================
Definitions.Skins = {
	classico = { id = "classico", name = "Clássico (1969)", unlocked = true, tint = nil },
	moderno = { id = "moderno", name = "Redesign Moderno", unlocked = false, tint = "vivid" },
	filme = { id = "filme", name = "Live-Action (filme)", unlocked = false, tint = "muted" },
	neo_noir = { id = "neo_noir", name = "Mistério Noir", unlocked = false, tint = "dark" },
}

-- ==========================================================
-- DIFICULDADE (o líder da sala escolhe)
-- ==========================================================
Definitions.Difficulty = {
	{
		id = "turista",
		name = "Turista Assustado",
		description = "Monstro mais lento, pistas brilhando, sem penalidade de tempo.",
		monsterSpeedMult = 0.85,
		clueHighlight = true,
		timeMult = 1.4,
		pointMult = 0.8,
	},
	{
		id = "detetive",
		name = "Detetive de Coolsville",
		description = "Experiência equilibrada — o padrão do Mistério S.A.",
		monsterSpeedMult = 1,
		clueHighlight = false,
		timeMult = 1,
		pointMult = 1,
	},
	{
		id = "veterano",
		name = "Investigador Veterano",
		description = "Monstro rápido, menos tempo e pistas escondidas de verdade.",
		monsterSpeedMult = 1.12,
		clueHighlight = false,
		timeMult = 0.85,
		pointMult = 1.35,
	},
	{
		id = "salsicha",
		name = "Pesadelo do Salsicha",
		description = "Monstro implacável, tempo curto e o dobro de pontos. Boa sorte.",
		monsterSpeedMult = 1.25,
		clueHighlight = false,
		timeMult = 0.7,
		pointMult = 2,
	},
}

function Definitions.getDifficulty(id)
	for _, entry in ipairs(Definitions.Difficulty) do
		if entry.id == id then
			return entry
		end
	end
	return Definitions.Difficulty[2]
end

function Definitions.getItem(itemId)
	for _, item in ipairs(Definitions.Shop) do
		if item.id == itemId then
			return item
		end
	end
	return nil
end

function Definitions.getAchievement(achievementId)
	return Definitions.Achievements[achievementId]
end

function Definitions.validate()
	local problems = {}
	for _, item in ipairs(Definitions.Shop) do
		if not item.id or not item.name then
			table.insert(problems, "Item de loja sem id/nome")
		end
		if type(item.price) ~= "number" or item.price <= 0 then
			table.insert(problems, ("Item %s com preço inválido"):format(tostring(item.id)))
		end
		if not item.grants then
			table.insert(problems, ("Item %s sem efeito (grants)"):format(tostring(item.id)))
		end
	end
	for id, achievement in pairs(Definitions.Achievements) do
		if not achievement.name or not achievement.description then
			table.insert(problems, ("Conquista %s incompleta"):format(id))
		end
	end
	return #problems == 0, problems
end

return Definitions
