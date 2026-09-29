--[[
	Config.luau
	Constantes globais do jogo "Mystery Machine: Arquivos do Mistério".
	Tudo que é número mágico do gameplay vive aqui para facilitar balanceamento.
]]

local Config = {}

Config.GAME_NAME = "Mistério S.A. — Arquivos do Mistério"
Config.VERSION = "1.0.0"
Config.SEASON = 1

-- ==========================================================
-- GRID / MAPAS
-- ==========================================================
Config.Grid = {
	CELL = 8, -- tamanho de 1 célula de navegação em studs
	WALL_HEIGHT = 13,
	WALL_THICK = 1,
	FLOOR_Y = 0,
	MAP_MARGIN = 40, -- espaço entre o lobby e os mapas de episódio
	MAP_SPACING = 1400, -- distância entre mapas de episódios diferentes
}

-- ==========================================================
-- PARTIDA / SALA
-- ==========================================================
Config.Match = {
	MIN_PLAYERS = 1,
	MAX_PLAYERS = 4,
	LOBBY_COUNTDOWN = 8, -- segundos de aviso antes de começar
	CHAPTER_TIME_LIMIT = 900, -- 15 min por capítulo
	INTERMISSION = 12, -- pausa entre capítulos
	RESPAWN_DELAY = 4,
	CAUGHT_COOLDOWN = 6, -- tempo "assustado" após ser pego
	CHAPTER_RETRY_PENALTY = 0.9, -- multiplicador de pontuação ao rejogar capítulo
	VOTE_TIME = 20,
}

Config.Players = {
	WALK_SPEED = 16,
	SPRINT_SPEED = 23,
	SPRINT_STAMINA = 100,
	SPRINT_DRAIN = 18,
	SPRINT_REGEN = 12,
	SCARED_WALK_SPEED = 13,
	JUMP_HEIGHT = 6,
	INTERACT_RANGE = 12,
	HINT_COOLDOWN = 25,
}

-- ==========================================================
-- MONSTROS / IA
-- ==========================================================
Config.Monster = {
	PATROL_SPEED = 12,
	SEARCH_SPEED = 16,
	CHASE_SPEED = 21,
	CHASE_SPEED_SOLO = 19.5, -- um pouco mais lento com 1 jogador (jogo solo justo)
	DETECT_RADIUS = 30,
	DETECT_FOV = 115,
	HEAR_RADIUS = 22,
	CATCH_DISTANCE = 4.5,
	LOSE_INTEREST_TIME = 9,
	LURE_TIME = 8,
	REVEAL_TAUNT_CHANCE = 0.35,
	HEARTBEAT_NEAR = 55,
	HEARTBEAT_CHASE = 30,
}

Config.Fear = {
	MAX = 100,
	NEAR_RATE = 9, -- aumenta perto do monstro (por segundo)
	CHASE_RATE = 22,
	DECAY = 7,
	PANIC_THRESHOLD = 70, -- acima disso começa a "tremer a câmera"
	SANITY_FLOOR = 25, -- medidor do Shaggy/Scooby
}

-- ==========================================================
-- PISTAS / DEDUÇÃO
-- ==========================================================
Config.Clues = {
	INTERACT_TIME = 1.4,
	VELMA_SCAN_RADIUS = 55,
	VELMA_SCAN_COOLDOWN = 30,
	SCOOBY_SENSE_RADIUS = 45,
	SCOOBY_SNACK_LURE_RADIUS = 14,
	DISTRACT_RANGE = 26,
	DEDUCTION_REWARD = 120,
	BASE_CLUE_REWARD = 60,
	HINT_COST = 25, -- Scooby Snacks (moeda) por dica paga
}

Config.Traps = {
	PARTS_NEEDED = 3,
	BUILD_STEP_TIME = 1.1,
	BAIT_TIME = 2.2,
	CAPTURE_HOLD_TIME = 2.5,
	ARM_TIME = 4,
}

-- ==========================================================
-- RECOMPENSAS
-- ==========================================================
Config.Rewards = {
	CLUE = 60,
	DEDUCTION = 120,
	NPC_INFO = 40,
	TRAP_PART = 35,
	TRAP_SPRING = 250,
	CAPTURE_MONSTER = 500,
	CHAPTER_COMPLETE = 350,
	EPISODE_COMPLETE = 1200,
	NO_CAUGHT_BONUS = 400,
	TIME_BONUS_MAX = 600,
	COIN_PER_POINT = 0.1, -- conversão de pontos em Scooby Snacks (moeda)
}

Config.Achievements = {
	FIRST_CASE = "primeiro_caso",
	NO_SPOILERS = "sem_levar_susto",
	SPEEDRUNNER = "detetive_relampago",
	SNACK_MASTER = "amigo_do_scooby",
	FULL_HOUSE = "turma_completa",
	ALL_TWELVE = "craque_de_coolsville",
}

-- ==========================================================
-- PALETA (usada no 3D e na UI)
-- ==========================================================
Config.Palette = {
	-- Identidade visual do desenho clássico
	MysteryBlue = Color3.fromRGB(43, 122, 168),
	MysteryTeal = Color3.fromRGB(84, 187, 189),
	MysteryOrange = Color3.fromRGB(233, 137, 51),
	MysteryGreen = Color3.fromRGB(120, 190, 74),
	Purple = Color3.fromRGB(126, 71, 168),
	DeepPurple = Color3.fromRGB(38, 24, 66),
	Night = Color3.fromRGB(16, 14, 30),
	Panel = Color3.fromRGB(28, 24, 48),
	PanelLight = Color3.fromRGB(46, 40, 74),
	Accent = Color3.fromRGB(140, 255, 130),
	Warning = Color3.fromRGB(255, 176, 62),
	Danger = Color3.fromRGB(255, 78, 78),
	Text = Color3.fromRGB(238, 236, 250),
	TextDim = Color3.fromRGB(168, 164, 196),
	Gold = Color3.fromRGB(247, 202, 84),

	-- Personagens
	Fred = Color3.fromRGB(60, 110, 200),
	FredHair = Color3.fromRGB(240, 214, 120),
	Daphne = Color3.fromRGB(150, 96, 190),
	DaphneHair = Color3.fromRGB(233, 148, 74),
	Velma = Color3.fromRGB(226, 120, 54),
	VelmaHair = Color3.fromRGB(138, 88, 52),
	Shaggy = Color3.fromRGB(112, 176, 84),
	ShaggyHair = Color3.fromRGB(184, 138, 78),
	Scooby = Color3.fromRGB(160, 108, 62),
	ScoobyDark = Color3.fromRGB(120, 76, 42),
	Skin = Color3.fromRGB(238, 197, 160),
}

-- ==========================================================
-- CAPÍTULOS: TIPOS DE OBJETIVO (usados pelo Story e pela UI)
-- ==========================================================
Config.ObjectiveKind = {
	Clue = "clue",
	Deduce = "deduce",
	Talk = "talk",
	Reach = "reach",
	TrapPart = "trap_part",
	BuildTrap = "build_trap",
	BaitTrap = "bait_trap",
	Survive = "survive",
	Capture = "capture",
	Unmask = "unmask",
	Defend = "defend",
	Search = "search",
}

Config.ChapterPhase = {
	Investigate = "investigacao",
	Suspects = "suspeitos",
	Trap = "armadilha",
	Reveal = "revelacao",
}

Config.PartyPrivacy = {
	Public = "publica",
	FriendsOnly = "somente_amigos",
	InviteOnly = "somente_convite",
	Closed = "fechada",
}

return Config
