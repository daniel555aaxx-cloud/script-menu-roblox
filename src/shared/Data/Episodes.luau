--[[
	Episodes.luau
	================= HISTÓRIA COMPLETA (MODO CAMPANHA) =================
	6 episódios x 4 capítulos + prólogo + capítulo final do Colecionador.
	Total: 26 capítulos jogáveis divididos em 4 fases cada um
	(investigação -> suspeitos -> armadilha -> revelação).

	Cada capítulo é declarativo: o servidor lê estes dados e monta
	objetivos, pistas, armadilhas, diálogos, IA do monstro e recompensas.

	Campos importantes de um capítulo:
		id, name, phase, location, mood, timeLimit, brief, objectives,
		clues, deductions, monster (overrides), trapSpots, reveal, rewards,
		npcs, requires (capítulos anteriores), achievements.
]]

local Episodes = {}

-- ==========================================================
-- CONFIGURAÇÃO GERAL DA CAMPANHA
-- ==========================================================
Episodes.Season = {
	id = "S1",
	title = "Arquivos do Mistério — Temporada 1",
	subtitle = "Seis sustos, uma assinatura: C²",
	tagline = "A turma do Mistério S.A. cruza o país atrás de fantasmas... e descobre que todos eles têm o mesmo patrão.",
	order = { "EP01", "EP02", "EP03", "EP04", "EP05", "EP06", "FINAL" },
}

-- ==========================================================
-- FASE DE ABERTURA (PRÓLOGO)
-- ==========================================================
Episodes.Prologue = {
	id = "PROLOGUE",
	name = "Prólogo — Um Recado na Caixa de Correio",
	phase = "investigacao",
	location = "Lobby",
	mood = "Lobby",
	timeLimit = 600,
	brief = "A Mystery Machine está estacionada em frente à sede do Mistério S.A. "
		.. "Sobre o capô, uma fita cassete com um selo de cera marcado 'C²'. "
		.. "Aperte PLAY e escute o convite: seis cidades, seis monstros, um colecionador.",
	objectives = {
		{
			id = "PRO_1",
			kind = "search",
			label = "Ouça a fita cassete no capô da Mystery Machine",
			marker = "Lobby_Fita",
			points = 60,
		},
		{
			id = "PRO_2",
			kind = "talk",
			label = "Fale com o Scooby e escolha o próximo caso",
			npc = "Lobby_Scooby",
			points = 60,
		},
		{
			id = "PRO_3",
			kind = "reach",
			label = "Escolha um episódio no Quadro de Casos",
			marker = "Lobby_Quadro",
			points = 60,
		},
	},
	clues = {
		{
			id = "PRO_C1",
			name = "Fita cassete com selo 'C²'",
			text = "A voz está modificada por um modulador de rádio antigo. No fim da fita, um estalo: alguém desliga o gravador com o dedo.",
			detail = "Selo de cera vermelho, marca de anel no lacre. Quem gravou usa anel de sinete.",
			reveals = "Todas as seis gravações ouvidas nos episódios seguintes têm o mesmo estalo final.",
		},
	},
	reward = { points = 200 },
	nextChapter = { "EP01", "EP02" },
}

-- ==========================================================
-- EPISÓDIO 1 — O FANTASMA DO FAROL
-- ==========================================================
Episodes.List = {}

Episodes.List.EP01 = {
	id = "EP01",
	number = 1,
	title = "O Fantasma do Farol",
	subtitle = "Farol de Pedra — litoral de Coolsville",
	color = "MysteryTeal",
	unlock = nil,
	location = "FarolEP1",
	mood = "EP01_Farol",
	monsterId = "EP01_Fantasma",
	tagline = "Um vulto luminoso apaga o farol para afundar barcos — e a vila está à venda.",
	synopsis = "A vila de Porto Pedra vive do farol e da pesca. Nas últimas duas semanas, "
		.. "um fantasma fluorescente apaga a luz principal às 3 da manhã e um barco de turismo "
		.. "quase partiu nas pedras. Os pescadores querem vender tudo e ir embora. "
		.. "A turma chega com a Mystery Machine justamente na noite em que o farol pisca três vezes seguidas.",
	acts = {
		"Investigando a doca e a base do farol, a turma encontra pegadas de bota que saem do mar.",
		"A luz revela um comprador de terrenos, uma bióloga e um faroleiro que 'viu tudo'.",
		"Salsicha descobre que o fantasma não sobe a escada de metal — ele simplesmente reaparece no topo.",
		"A armadilha com rede de pesca no píer captura o vulto, e a máscara cai: Cole Vanterpool queria o farol desvalorizado.",
	},
	npcs = { "EP01_Keeper", "EP01_Lucille", "EP01_Duarte", "EP01_Bea", "EP01_Suspeito_Cole", "EP01_Suspeito_Marta" },
	chapters = { "EP01_C1", "EP01_C2", "EP01_C3", "EP01_C4" },
}

-- ---------- EP01 - Capítulo 1 ----------
Episodes.Chapters = {}

Episodes.Chapters.EP01_C1 = {
	id = "EP01_C1",
	episode = "EP01",
	index = 1,
	name = "Capítulo 1 — Três Piscadas de Madrugada",
	phase = "investigacao",
	location = "FarolEP1",
	mood = "EP01_Farol",
	timeLimit = 900,
	brief = "A vila está vazia, o portão do píer está aberto e a luz do farol pisca sozinha. "
		.. "Fred quer a planta do lugar, Velma quer as pegadas, Daphne quer conversar e Salsicha quer sair daqui.",
	intro = {
		title = "Três Piscadas de Madrugada",
		subtitle = "Episódio 1 · Capítulo 1 de 4",
		narrator = "Fred",
		slides = {
			{
				speaker = "Fred",
				text = "Coolsville para Porto Pedra: 186 quilômetros e um pneu cantando.",
				emote = "happy",
				sfx = "MysteryMachineHorn",
			},
			{
				speaker = "Daphne",
				text = "Olha o mar! Tá lindo... e olha aquele vulto no topo do farol. Tá lindo não, tá assustador.",
				emote = "worried",
			},
			{
				speaker = "Velma",
				text = "Jinkies. O farol pisca em intervalos de 12 segundos. Esse último foi de 3. Alguém está no comando.",
				emote = "thinking",
			},
			{
				speaker = "Salsicha",
				text = "Tipo assim, tem uma lanchonete aberta aí? Porque correr de fantasma dá fome.",
				emote = "scared",
			},
			{ speaker = "Scooby", text = "Scooby-Dooby-Doo! Ran ran! Ran tem rossa de ristério!", emote = "excited" },
		},
	},
	objectives = {
		{
			id = "EP01_C1_OB1",
			kind = "reach",
			label = "Chegue à entrada da vila e veja a luz piscar",
			marker = "Farol_Entrada",
			points = 40,
		},
		{
			id = "EP01_C1_OB2",
			kind = "talk",
			label = "Fale com o Faroleiro Barnaby na base do farol",
			npc = "EP01_Keeper",
			points = 60,
		},
		{
			id = "EP01_C1_OB3",
			kind = "clue",
			label = "Examine as pegadas de bota lubrificada na doca",
			clue = "EP01_C1",
			marker = "Doca_Pegadas",
			points = 70,
		},
		{
			id = "EP01_C1_OB4",
			kind = "clue",
			label = "Olhe o quadro elétrico do farol (tem fio novo demais)",
			clue = "EP01_C2",
			marker = "Farol_Quadro",
			points = 70,
		},
		{
			id = "EP01_C1_OB5",
			kind = "search",
			label = "Reviste o galpão de barcos atrás de um rastro de lama",
			clue = "EP01_C3",
			marker = "Galpao_Mesa",
			points = 70,
		},
		{
			id = "EP01_C1_OB6",
			kind = "deduce",
			label = "Monte a primeira dedução no Quadro de Pistas",
			deduction = "EP01_D1",
			points = 120,
		},
	},
	clues = {
		{
			id = "EP01_C1",
			name = "Pegada de bota com graxa de motor",
			text = "Marca de sola quadriculada, tamanho 46, com graxa azul de motor de barco. Vem do mar e termina no píer, sem voltar.",
			detail = "Sola quadriculada = bota de convés, usada por quem trabalha em barco grande, não por pescador de sardinha.",
			reveals = "Quem invadiu a doca chegou de barco — e a vila não tem barco grande.",
		},
		{
			id = "EP01_C2",
			name = "Fiação elétrica nova no quadro do farol",
			text = "Cabos de cobre brilhando, fita isolante preta nova e um controlador sem marca de fábrica.",
			detail = "O material é de painel solar industrial — caro, e a vila não tem verba. Alguém instalou isso.",
			reveals = "O 'fantasma' tem controle remoto da luz. Não é sobrenatural: é eletricidade.",
		},
		{
			id = "EP01_C3",
			name = "Rastro de lama calcária no galpão",
			text = "Pegadas molhadas que secam em pó branco até sumirem. Duas cores de barro diferentes: um escuro do mar e um claro do cimento.",
			detail = "O barro claro vem do canteiro de obras novo — o futuro resort.",
			reveals = "O vulto passou pelo canteiro antes de vir ao píer.",
		},
		{
			id = "EP01_C4",
			name = "Posto de gasolina e um aluguel de barco",
			text = "A dona da pousada guarda recibos: um barco grande foi alugado por 3 noites e devolvido limpo demais.",
			detail = "Quem aluga um barco e devolve sem cheiro de peixe está escondendo o que fez com ele.",
			reveals = "Existe um barco grande na região: o 'Lady Anabela', do consórcio de cruzeiros.",
		},
	},
	deductions = {
		{
			id = "EP01_D1",
			question = "Como o vulto chega ao topo do farol sem usar a escada?",
			options = {
				{ text = "Ele voa, óbvio.", correct = false, feedback = "Velma: 'Voo não deixa marca de graxa.'" },
				{
					text = "Existe uma passagem de serviço: o elevador de carga do canteiro.",
					correct = true,
					feedback = "Velma: 'Os cabos novos do quadro elétrico alimentam um elevador de obra. É isso!'",
				},
				{
					text = "Ele mora no farol.",
					correct = false,
					feedback = "Velma: 'Se morasse, usaria a cozinha. Ninguém usou a cozinha.'",
				},
			},
			logic = "Cabos industriais novos + poeira de cimento + pegadas que somem = elevador de carga escondido na parede do farol.",
			points = 120,
		},
	},
	trapSpots = {
		{ id = "Farol_TrapA", label = "Píer principal (rede de pesca)", room = "Doca_Pier", needsParts = 3 },
		{ id = "Farol_TrapB", label = "Base do farol (rede de arrasto)", room = "Farol_Base", needsParts = 3 },
	},
	monsterIntro = {
		trigger = "afterObjective",
		objective = "EP01_C1_OB3",
		text = "O vulto passa entre os barrancos, deixa um rastro de luz na água e desaparece atrás do galpão.",
		sfx = "GhostMoan",
	},
	reveal = {
		unmaskedNpc = "EP01_Suspeito_Cole",
		dialogue = "EP01_Reveal",
		quote = "Você estava certo, Fred. Ele só queria o farol valendo nada.",
	},
	npcs = { "EP01_Keeper", "EP01_Duarte", "EP01_Bea" },
	rewards = { points = 550, snacks = 3, achievement = nil },
	nextChapter = "EP01_C2",
}

-- ---------- EP01 - Capítulo 2 ----------
Episodes.Chapters.EP01_C2 = {
	id = "EP01_C2",
	episode = "EP01",
	index = 2,
	name = "Capítulo 2 — Quem Quer um Farol Apagado",
	phase = "suspeitos",
	location = "FarolEP1",
	mood = "EP01_Farol",
	timeLimit = 900,
	brief = "Três pessoas ganham algo com o farol desligado: o comprador de terrenos, a bióloga contratada e o faroleiro "
		.. "que assinou um abaixo-assinado de venda. Hora de conversar — e de anotar contradições.",
	intro = {
		title = "Quem Quer um Farol Apagado",
		subtitle = "Episódio 1 · Capítulo 2 de 4",
		narrator = "Velma",
		slides = {
			{
				speaker = "Velma",
				text = "Lista de suspeitos pronta. Três nomes, três motivos, três álibis para checar.",
				emote = "thinking",
			},
			{
				speaker = "Fred",
				text = "Dividam-se: Daphne pega os recibos da pousada, eu vou no canteiro, Salsicha... não fuja.",
				emote = "happy",
			},
			{ speaker = "Salsicha", text = "Eu não fujo, eu faço reconhecimento... de longe.", emote = "scared" },
		},
	},
	objectives = {
		{
			id = "EP01_C2_OB1",
			kind = "talk",
			label = "Interrogue Lucille na pousada sobre o barco alugado",
			npc = "EP01_Lucille",
			clue = "EP01_C4",
			points = 70,
		},
		{
			id = "EP01_C2_OB2",
			kind = "talk",
			label = "Interrogue Cole Vanterpool no hotel de vendas",
			npc = "EP01_Suspeito_Cole",
			points = 70,
		},
		{
			id = "EP01_C2_OB3",
			kind = "talk",
			label = "Interrogue Marta Kellerman no laboratório",
			npc = "EP01_Suspeito_Marta",
			points = 70,
		},
		{
			id = "EP01_C2_OB4",
			kind = "clue",
			label = "Encontre a prancha do canteiro com a planta do elevador",
			clue = "EP01_C5",
			marker = "Canteiro_Prancha",
			points = 80,
		},
		{
			id = "EP01_C2_OB5",
			kind = "clue",
			label = "Compare as botas no vestiário do canteiro",
			clue = "EP01_C6",
			marker = "Canteiro_Botas",
			points = 80,
		},
		{
			id = "EP01_C2_OB6",
			kind = "deduce",
			label = "Dedução 2: quem tem bota 46 e barco grande?",
			deduction = "EP01_D2",
			points = 130,
		},
		{
			id = "EP01_C2_OB7",
			kind = "survive",
			label = "Sobreviva ao primeiro ataque no píer (não deixe ser pego)",
			seconds = 60,
			points = 90,
			optional = true,
		},
	},
	clues = {
		{
			id = "EP01_C5",
			name = "Prancha do canteiro: elevador de serviço",
			text = "Planta do resort com um elevador de carga externo. Detalhe a lápis: 'instalar antes da vistoria'.",
			detail = "A vistoria foi adiada justamente na semana em que o fantasma apareceu.",
			reveals = "O elevador existe, está instalado e não consta no projeto aprovado.",
		},
		{
			id = "EP01_C6",
			name = "Par de botas de convés — tamanho 46",
			text = "Botas com graxa azul, sola quadriculada e areia clara dentro. Só um par foi escondido no fundo do armário.",
			detail = "Sola quadriculada idêntica à pegada da doca.",
			reveals = "As botas escondidas são a prova material do disfarce.",
		},
	},
	deductions = {
		{
			id = "EP01_D2",
			question = "Quem tem acesso ao elevador, às botas e ao barco grande?",
			options = {
				{
					text = "Marta, a bióloga — ela vive no mar.",
					correct = false,
					feedback = "Velma: 'Marta usa bota de neoprene. Não deixa sola quadriculada.'",
				},
				{
					text = "Barnaby, o faroleiro — ele tem a chave.",
					correct = false,
					feedback = "Fred: 'Ele mal sobe a escada. E as botas são novas.'",
				},
				{
					text = "Cole Vanterpool — o consórcio dele alugou o barco e paga o canteiro.",
					correct = true,
					feedback = "Daphne: 'E ele foi o único que sorriu quando o farol apagou.'",
				},
			},
			logic = "Barco alugado pelo consórcio + botas de convés no vestiário do canteiro do consórcio + elevador de obra = o fantasma trabalha com dinheiro de resort.",
			points = 130,
		},
		{
			id = "EP01_D3",
			question = "O que o fantasma NÃO sabia fazer?",
			options = {
				{
					text = "Subir escada de metal.",
					correct = true,
					feedback = "Salsicha: 'Tipo assim, eu vi! Ele passou a mão no corrimão e não subiu. Fantasma com medo de altura!'",
				},
				{ text = "Nadar.", correct = false, feedback = "Velma: 'Ele saiu do mar. Sabia nadar bem.'" },
				{
					text = "Assobiar.",
					correct = false,
					feedback = "Daphne: 'Assobiava desafinado. Anotado, mas não é a chave.'",
				},
			},
			logic = "A escada de metal é o único caminho do térreo ao topo. Não usá-la indica que ele entra por outro lugar — o elevador.",
			points = 110,
		},
	},
	trapSpots = {
		{ id = "Farol_TrapA", label = "Píer principal (rede de pesca)", room = "Doca_Pier", needsParts = 3 },
	},
	monsterIntro = {
		trigger = "onStart",
		text = "Um assobio desafinado vem da água. O Fantasma do Farol está patrulhando o píer.",
		sfx = "GhostMoan",
	},
	reveal = { unmaskedNpc = "EP01_Suspeito_Cole", dialogue = "EP01_Reveal" },
	npcs = { "EP01_Lucille", "EP01_Suspeito_Cole", "EP01_Suspeito_Marta" },
	rewards = { points = 600, snacks = 3 },
	nextChapter = "EP01_C3",
}

-- ---------- EP01 - Capítulo 3 ----------
Episodes.Chapters.EP01_C3 = {
	id = "EP01_C3",
	episode = "EP01",
	index = 3,
	name = "Capítulo 3 — A Rede, o Sanduíche e o Farol",
	phase = "armadilha",
	location = "FarolEP1",
	mood = "EP01_Farol",
	timeLimit = 900,
	brief = "A turma precisa de três peças para montar a armadilha de rede no píer: corda de arrasto, "
		.. "contrapeso do guindaste e um anzol grande. Salsicha é a isca — com um sanduíche de sardinha.",
	intro = {
		title = "A Rede, o Sanduíche e o Farol",
		subtitle = "Episódio 1 · Capítulo 3 de 4",
		narrator = "Fred",
		slides = {
			{
				speaker = "Fred",
				text = "Plano novo: ele sai do elevador às 3 da manhã e vem para o píer checar a luz.",
				emote = "excited",
			},
			{
				speaker = "Fred",
				text = "Se a rede cair entre o elevador e a doca, ele não tem para onde correr.",
				emote = "happy",
			},
			{
				speaker = "Salsicha",
				text = "E eu faço o quê? Nada de ficar parado com sanduíche na mão na frente do fantasma, né?",
				emote = "scared",
			},
			{
				speaker = "Scooby",
				text = "Ramduíche de rardinha! Rom nom! ...Rra rossa rarmadilha, Raggy?",
				emote = "excited",
			},
		},
	},
	objectives = {
		{
			id = "EP01_C3_OB1",
			kind = "trap_part",
			label = "Pegue a corda de arrasto no galpão",
			clue = "EP01_PART1",
			marker = "Galpao_Corda",
			points = 60,
		},
		{
			id = "EP01_C3_OB2",
			kind = "trap_part",
			label = "Pegue o contrapeso do guindaste na doca",
			clue = "EP01_PART2",
			marker = "Doca_Contrapeso",
			points = 60,
		},
		{
			id = "EP01_C3_OB3",
			kind = "trap_part",
			label = "Pegue o anzol grande na loja do porto",
			clue = "EP01_PART3",
			marker = "Porto_Anzol",
			points = 60,
		},
		{
			id = "EP01_C3_OB4",
			kind = "build_trap",
			label = "Monte a armadilha de rede no Píer Principal",
			marker = "Farol_TrapA",
			points = 150,
		},
		{
			id = "EP01_C3_OB5",
			kind = "bait_trap",
			label = "Coloque o sanduíche de sardinha como isca",
			marker = "Farol_TrapA",
			points = 90,
		},
		{
			id = "EP01_C3_OB6",
			kind = "defend",
			label = "Defenda a armadilha por 45 segundos (sons, cordas e coragem)",
			seconds = 45,
			points = 120,
		},
	},
	clues = {
		{
			id = "EP01_C7",
			name = "Lanterna de LED no capacho do elevador",
			text = "Uma lanterna de mergulho com bateria de lítio, ainda quente. Fica num capacho que diz 'RESORT PORTO PEDRA — VISITANTES'.",
			detail = "A bateria estava carregada há menos de uma hora.",
			reveals = "O vulto trocou a lanterna minutos antes de a turma chegar — ou seja, estava ali.",
		},
	},
	deductions = {
		{
			id = "EP01_D4",
			question = "Por que o fantasma brilha tanto se é só um lençol?",
			options = {
				{
					text = "Tecido com tinta fosforescente e lanternas de LED por dentro.",
					correct = true,
					feedback = "Velma: 'Fosforescente + LED + neblina = susto garantido. Clássico.'",
				},
				{
					text = "É radiação, gente.",
					correct = false,
					feedback = "Velma: 'Radiação não assobia afinado.'",
				},
				{
					text = "Gasolina queimando.",
					correct = false,
					feedback = "Fred: 'Se fosse fogo, o lençol tinha virado tocha.'",
				},
			},
			logic = "Brilho constante, cor uniforme e um zumbido elétrico baixinho: são lanternas de LED dentro do disfarce.",
			points = 110,
		},
	},
	trapSpots = {
		{ id = "Farol_TrapA", label = "Píer principal (rede de pesca)", room = "Doca_Pier", needsParts = 3 },
		{ id = "Farol_TrapB", label = "Base do farol (rede de arrasto)", room = "Farol_Base", needsParts = 3 },
	},
	monsterIntro = {
		trigger = "onStart",
		text = "O fantasma desce do elevador de serviço e caminha direto para o píer. Ele sabe que vocês estão aqui.",
		sfx = "GhostMoan",
	},
	reveal = { unmaskedNpc = "EP01_Suspeito_Cole", dialogue = "EP01_Reveal" },
	npcs = { "EP01_Keeper" },
	rewards = { points = 700, snacks = 4 },
	nextChapter = "EP01_C4",
}

-- ---------- EP01 - Capítulo 4 ----------
Episodes.Chapters.EP01_C4 = {
	id = "EP01_C4",
	episode = "EP01",
	index = 4,
	name = "Capítulo 4 — A Máscara Cai no Píer",
	phase = "revelacao",
	location = "FarolEP1",
	mood = "EP01_Farol",
	timeLimit = 720,
	brief = "O vulto está preso na rede. Falta puxar a máscara, ouvir a confissão e descobrir por que "
		.. "alguém paga uma fortuna por seis sustos seguidos.",
	intro = {
		title = "A Máscara Cai no Píer",
		subtitle = "Episódio 1 · Capítulo 4 de 4",
		narrator = "Daphne",
		slides = {
			{ speaker = "Fred", text = "Puxem! Puxem! A rede tá firme!", emote = "excited" },
			{ speaker = "Daphne", text = "E agora? Quem está por baixo dessa máscara?", emote = "thinking" },
			{ speaker = "Velma", text = "Jinkies... olha a fita no bolso dele. Outro selo 'C²'.", emote = "thinking" },
		},
	},
	objectives = {
		{
			id = "EP01_C4_OB1",
			kind = "capture",
			label = "Prenda o Fantasma do Farol na armadilha",
			marker = "Farol_TrapA",
			points = 200,
		},
		{
			id = "EP01_C4_OB2",
			kind = "unmask",
			label = "Tire a máscara do vulto",
			marker = "Farol_TrapA",
			points = 150,
		},
		{
			id = "EP01_C4_OB3",
			kind = "talk",
			label = "Ouça a confissão e a fita número 2",
			npc = "EP01_Suspeito_Cole",
			points = 80,
		},
		{
			id = "EP01_C4_OB4",
			kind = "reach",
			label = "Volte para a Mystery Machine com o farol aceso",
			marker = "Farol_Saida",
			points = 60,
		},
	},
	clues = {
		{
			id = "EP01_C8",
			name = "Recibo digital: 'susto profissional'",
			text = "No bolso do suspeito, um recibo impresso sem cabeçalho: 'SERVIÇO CONTRATADO — LOTE 1/6. PAGAMENTO EM ESPÉCIE. NÃO HAVERÁ DEVOLUÇÃO.'",
			detail = "O cliente paga por sustos. Ele não escolhe a cidade — só recebe o lote.",
			reveals = "Existe uma central de sustos. Os seis casos são encomendas.",
		},
	},
	deductions = {
		{
			id = "EP01_D5",
			question = "Se o suspeito é rico, por que ele mesmo fez o trabalho?",
			options = {
				{
					text = "Porque estava quebrado e precisava do dinheiro do cliente.",
					correct = true,
					feedback = "Daphne: 'O iate dele estava com o combustível cortado. Ele está sem dinheiro!'",
				},
				{
					text = "Porque ama fantasias.",
					correct = false,
					feedback = "Fred: 'Ninguém ama fantasia a ponto de pegar pneumonia no píer.'",
				},
				{
					text = "Porque o cliente é o próprio faroleiro.",
					correct = false,
					feedback = "Velma: 'O faroleiro tem alibi de 3 testemunhas.'",
				},
			},
			logic = "Um acusado com aparência de milionário, mas sem combustível, é o suspeito perfeito: ele corre atrás do pagamento.",
			points = 130,
		},
	},
	trapSpots = {
		{ id = "Farol_TrapA", label = "Píer principal (rede de pesca)", room = "Doca_Pier", needsParts = 3 },
	},
	monsterIntro = {
		trigger = "onStart",
		text = "Encurralado, o fantasma corre em círculos. Uma última investida e o caso está fechado.",
		sfx = "JumpscareScream",
	},
	reveal = { unmaskedNpc = "EP01_Suspeito_Cole", dialogue = "EP01_Reveal" },
	npcs = { "EP01_Suspeito_Cole", "EP01_Keeper", "EP01_Lucille" },
	rewards = { points = 900, snacks = 6, achievement = "primeiro_caso" },
	nextChapter = nil,
	episodeEnd = true,
}

-- ==========================================================
-- EPISÓDIO 2 — O HÓSPEDE DO QUARTO 302
-- ==========================================================
Episodes.List.EP02 = {
	id = "EP02",
	number = 2,
	title = "O Hóspede do Quarto 302",
	subtitle = "Hotel Excelsior — capital",
	color = "Purple",
	unlock = "EP01",
	location = "HotelEP2",
	mood = "EP02_Hotel",
	monsterId = "EP02_Fantasma",
	tagline = "Um hóspede que morreu em 1962 continua pedindo o jantar — e o piano toca sozinho às 3h.",
	synopsis = "O Hotel Excelsior é um monumento Art Déco com 41 quartos, 3 hóspedes e 1 fantasma. "
		.. "O piano de cauda do salão toca sozinho, a cozinha acende por conta própria e a Condessa Wilhelmina "
		.. "jura que viu o falecido pianista no espelho. O banco vai leiloar o prédio na sexta-feira. "
		.. "A turma chega com um convite falsificado — e sai com um caso verdadeiro.",
	acts = {
		"A recepção está coberta de poeira, mas o piano ainda tem as teclas limpas.",
		"Três suspeitos, três álibis: o gerente quebrado, o pianista substituído e a condessa que quer o prédio.",
		"Um fio de aço atravessa o teto do salão: o piano toca por controle remoto.",
		"A armadilha do elevador de serviço pega o hóspede, e o 'morto' de 1962 tem RG válido.",
	},
	npcs = { "EP02_Gerente", "EP02_Mucama", "EP02_Pianista", "EP02_Convidada", "EP02_Bellboy" },
	chapters = { "EP02_C1", "EP02_C2", "EP02_C3", "EP02_C4" },
}

Episodes.Chapters.EP02_C1 = {
	id = "EP02_C1",
	episode = "EP02",
	index = 1,
	name = "Capítulo 1 — Check-in no Quarto 302",
	phase = "investigacao",
	location = "HotelEP2",
	mood = "EP02_Hotel",
	timeLimit = 900,
	brief = "A turma entra como 'hóspedes'. A regra da casa: ninguém sobe ao terceiro andar depois das 22h. "
		.. "Objetivo: descobrir como o piano toca sozinho e por que a 302 está sempre trancada.",
	intro = {
		title = "Check-in no Quarto 302",
		subtitle = "Episódio 2 · Capítulo 1 de 4",
		narrator = "Daphne",
		slides = {
			{
				speaker = "Daphne",
				text = "Mármore, lustre e teia de aranha. Esse hotel era maravilhoso em 1962.",
				emote = "thinking",
			},
			{
				speaker = "Gerente Osório",
				text = "Bem-vindos ao Excelsior! Não subam ao terceiro andar. Nem ao segundo. Nem ao primeiro, se possível.",
				emote = "worried",
			},
			{
				speaker = "Velma",
				text = "Interessante: o piano está desafinado em três notas específicas. Alguém tocou por muito tempo.",
				emote = "thinking",
			},
			{ speaker = "Salsicha", text = "Tem quarto com frigobar? É pra... pesquisa.", emote = "happy" },
		},
	},
	objectives = {
		{
			id = "EP02_C1_OB1",
			kind = "talk",
			label = "Faça o check-in com o Gerente Osório",
			npc = "EP02_Gerente",
			points = 50,
		},
		{
			id = "EP02_C1_OB2",
			kind = "clue",
			label = "Inspecione o piano de cauda do salão",
			clue = "EP02_C1",
			marker = "Hotel_Piano",
			points = 80,
		},
		{
			id = "EP02_C1_OB3",
			kind = "clue",
			label = "Encontre o fio de aço no teto do salão",
			clue = "EP02_C2",
			marker = "Hotel_Teto_Salao",
			points = 80,
		},
		{
			id = "EP02_C1_OB4",
			kind = "search",
			label = "Reviste a cozinha: alguém jantou aqui ontem",
			clue = "EP02_C3",
			marker = "Hotel_Cozinha",
			points = 80,
		},
		{
			id = "EP02_C1_OB5",
			kind = "clue",
			label = "Leia o livro de registro do quarto 302",
			clue = "EP02_C4",
			marker = "Hotel_Registro",
			points = 80,
		},
		{
			id = "EP02_C1_OB6",
			kind = "deduce",
			label = "Dedução 1: o piano é mecânico ou sobrenatural?",
			deduction = "EP02_D1",
			points = 130,
		},
	},
	clues = {
		{
			id = "EP02_C1",
			name = "Teclas limpas em um piano empoeirado",
			text = "Só três oitavas estão limpas — exatamente as notas de uma valsa. O resto do piano tem uma camada de poeira de 10 anos.",
			detail = "Alguém toca sempre a mesma música, sempre na mesma parte do teclado.",
			reveals = "O 'fantasma' tem repertório fixo — e toca ao vivo, não por magia.",
		},
		{
			id = "EP02_C2",
			name = "Fio de aço de 0,8 mm no teto",
			text = "Um cabo fino desce do forro até a cauda do piano e segue por um duto até o elevador de serviço.",
			detail = "O fio está engraxado. Sem graxa, ele cantaria ao puxar.",
			reveals = "O piano é operado de outro andar: existe um operador.",
		},
		{
			id = "EP02_C3",
			name = "Jantar servido e intocado",
			text = "Sopa de cebola, vinho e um prato de cordeiro. Duas pessoas comeram: um prato tem garfo à direita, o outro foi empurrado para o lado.",
			detail = "O serviço é de 1962 — porcelana com o brasão antigo, guardada a sete chaves.",
			reveals = "Alguém tem acesso ao depósito de porcelana antiga. Não é um hóspede qualquer.",
		},
		{
			id = "EP02_C4",
			name = "Registro do 302: mesmo nome desde 1962",
			text = "'Sr. A. Blackwood — hóspede permanente.' A letra é a mesma de 60 anos atrás e a tinta é nova.",
			detail = "Ninguém assina por 60 anos sem tremer a mão. Alguém está imitando a caligrafia.",
			reveals = "O hóspede-fantasma tem nome emprestado — e alguém coleciona a história dele.",
		},
	},
	deductions = {
		{
			id = "EP02_D1",
			question = "Como o piano toca sem ninguém sentado nele?",
			options = {
				{
					text = "É um fantasma, Velma. Aceita.",
					correct = false,
					feedback = "Velma: 'Aceito quando o fantasma explicar a graxa no fio.'",
				},
				{
					text = "Um fio de aço puxa as teclas a partir de outro andar.",
					correct = true,
					feedback = "Fred: 'Então quem toca está no terceiro andar. E o terceiro andar está interditado!'",
				},
				{
					text = "Vibração do elevador.",
					correct = false,
					feedback = "Velma: 'Vibração não toca valsa. Toca... vibração.'",
				},
			},
			logic = "Fio engraxado + teclas limpas + forro aberto = operador humano por controle remoto ou por fio.",
			points = 130,
		},
	},
	trapSpots = {
		{
			id = "Hotel_TrapA",
			label = "Elevador de serviço (contrapeso + rede)",
			room = "Hotel_Elevador",
			needsParts = 3,
		},
		{
			id = "Hotel_TrapB",
			label = "Corredor do 3º andar (lustre + cortina)",
			room = "Hotel_Corredor3",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "afterObjective",
		objective = "EP02_C1_OB2",
		text = "As teclas do piano afundam sozinhas. Do fundo do corredor, alguém aplaude com luvas.",
		sfx = "GhostMoan",
	},
	reveal = { unmaskedNpc = "EP02_Pianista", dialogue = "EP02_Reveal" },
	npcs = { "EP02_Gerente", "EP02_Mucama", "EP02_Bellboy" },
	rewards = { points = 650, snacks = 3 },
	nextChapter = "EP02_C2",
}

Episodes.Chapters.EP02_C2 = {
	id = "EP02_C2",
	episode = "EP02",
	index = 2,
	name = "Capítulo 2 — O Hóspede Que Não Paga Conta",
	phase = "suspeitos",
	location = "HotelEP2",
	mood = "EP02_Hotel",
	timeLimit = 900,
	brief = "O gerente quer o hotel vendido. O pianista quer seu emprego de volta. A condessa quer a suíte 302 só para ela. "
		.. "E a camareira quer contar uma coisa que ninguém mais quer ouvir.",
	intro = {
		title = "O Hóspede Que Não Paga Conta",
		subtitle = "Episódio 2 · Capítulo 2 de 4",
		narrator = "Shaggy",
		slides = {
			{
				speaker = "Shaggy",
				text = "Tipo assim, eu contei três pessoas nesta recepção e uma delas tem olhar de quem já perdeu o emprego.",
				emote = "thinking",
			},
			{
				speaker = "Velma",
				text = "Regra de investigação: quem reclama mais alto normalmente tem álibi mais fino.",
				emote = "thinking",
			},
			{
				speaker = "Daphne",
				text = "E quem fala menos tem o armário mais interessante. Eu vejo os sapatos.",
				emote = "happy",
			},
		},
	},
	objectives = {
		{
			id = "EP02_C2_OB1",
			kind = "talk",
			label = "Converse com Ester, a camareira, no corredor do 2º andar",
			npc = "EP02_Mucama",
			clue = "EP02_C5",
			points = 70,
		},
		{
			id = "EP02_C2_OB2",
			kind = "talk",
			label = "Ouça o Maestro Igor Zappa reclamar do contrato",
			npc = "EP02_Pianista",
			points = 70,
		},
		{
			id = "EP02_C2_OB3",
			kind = "talk",
			label = "Peça licença na suíte da Condessa Wilhelmina",
			npc = "EP02_Convidada",
			points = 70,
		},
		{
			id = "EP02_C2_OB4",
			kind = "clue",
			label = "Reviste o depósito de porcelana antiga",
			clue = "EP02_C6",
			marker = "Hotel_Deposito",
			points = 80,
		},
		{
			id = "EP02_C2_OB5",
			kind = "clue",
			label = "Ache a partitura rasgada no duto do 3º andar",
			clue = "EP02_C7",
			marker = "Hotel_Duto",
			points = 90,
		},
		{
			id = "EP02_C2_OB6",
			kind = "deduce",
			label = "Dedução 2: quem imita a caligrafia de 1962?",
			deduction = "EP02_D2",
			points = 140,
		},
		{
			id = "EP02_C2_OB7",
			kind = "survive",
			label = "Sobreviva ao ataque no corredor do 3º andar",
			seconds = 75,
			points = 100,
			optional = true,
		},
	},
	clues = {
		{
			id = "EP02_C5",
			name = "Depoimento de Ester: 'o piano chora'",
			text = "Ester diz que o piano só toca quando o gerente está no escritório do 1º andar — e que o choro vem do duto, não do salão.",
			detail = "O duto liga o salão ao quarto 302 e ao escritório.",
			reveals = "Existe alguém escondido entre o 302 e o escritório, usando o duto como esconderijo.",
		},
		{
			id = "EP02_C6",
			name = "Porcelana de 1962 — um prato faltando",
			text = "O jogo completo do serviço antigo está guardado, exceto um prato e uma taça. Sem poeira na prateleira: retirados há pouco.",
			detail = "Só duas pessoas têm a chave do depósito: o gerente e o maestro.",
			reveals = "O jantar do fantasma saiu daqui. Foi servido por alguém com chave.",
		},
		{
			id = "EP02_C7",
			name = "Partitura rasgada — 'Valsa do Hóspede'",
			text = "Metade da partitura, com anotações em vermelho: 'puxar no compasso 12'. Assinatura no canto: I. ZAPPA.",
			detail = "A partitura foi rasgada na mesma noite em que o piano começou a tocar sozinho.",
			reveals = "O maestro escreveu a mecânica do susto. Ele é o autor técnico.",
		},
		{
			id = "EP02_C8",
			name = "Chave-mestra do 3º andar",
			text = "Uma chave-mestra dentro de uma caixa de charutos, junto com um chumaço de algodão e um pouco de gesso em pó.",
			detail = "Gesso em pó é o que sobra de máscaras. Alguém está consertando o disfarce aqui dentro.",
			reveals = "O disfarce é montado no hotel, em um quarto fechado do 3º andar.",
		},
	},
	deductions = {
		{
			id = "EP02_D2",
			question = "Quem assinaria o livro de registro imitando a caligrafia de 1962?",
			options = {
				{
					text = "A condessa, para valorizar a suíte.",
					correct = false,
					feedback = "Daphne: 'Ela assina com perfume. E escreve com pressa, não com paciência de falsária.'",
				},
				{
					text = "O maestro, que passou 20 anos copiando partituras antigas à mão.",
					correct = true,
					feedback = "Velma: 'Copiar música antiga é treinar caligrafia antiga. Ele treinou por duas décadas!'",
				},
				{
					text = "O mensageiro Tiago.",
					correct = false,
					feedback = "Fred: 'O Tiago tem 19 anos. A letra dele é de 19 anos.'",
				},
			},
			logic = "Caligrafia antiga exige prática. Um copista de partituras tem essa habilidade e o motivo: o hotel está sendo vendido sem ele.",
			points = 140,
		},
	},
	trapSpots = {
		{
			id = "Hotel_TrapA",
			label = "Elevador de serviço (contrapeso + rede)",
			room = "Hotel_Elevador",
			needsParts = 3,
		},
		{
			id = "Hotel_TrapB",
			label = "Corredor do 3º andar (lustre + cortina)",
			room = "Hotel_Corredor3",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "Passos de sapato social ecoam no corredor do 3º andar. O Hóspede do 302 está acordado.",
		sfx = "GhostMoan",
	},
	reveal = { unmaskedNpc = "EP02_Pianista", dialogue = "EP02_Reveal" },
	npcs = { "EP02_Mucama", "EP02_Pianista", "EP02_Convidada" },
	rewards = { points = 700, snacks = 3 },
	nextChapter = "EP02_C3",
}

Episodes.Chapters.EP02_C3 = {
	id = "EP02_C3",
	episode = "EP02",
	index = 3,
	name = "Capítulo 3 — O Elevador Que Range Falso",
	phase = "armadilha",
	location = "HotelEP2",
	mood = "EP02_Hotel",
	timeLimit = 900,
	brief = "O hóspede usa o elevador de serviço para subir sem ser visto. Transforme o elevador na armadilha: "
		.. "três peças, um contra-peso e muita paciência de camareira.",
	intro = {
		title = "O Elevador Que Range Falso",
		subtitle = "Episódio 2 · Capítulo 3 de 4",
		narrator = "Velma",
		slides = {
			{
				speaker = "Velma",
				text = "O elevador range em um ritmo matemático. É sinal de que está sendo usado à mão, sem motor.",
				emote = "thinking",
			},
			{
				speaker = "Fred",
				text = "Então prendemos o contrapeso e ele fica entre dois andares. Simples e clássico.",
				emote = "excited",
			},
			{
				speaker = "Daphne",
				text = "E eu fico na recepção com a condessa, para ela não atrapalhar... e para ela soltar mais alguma coisa.",
				emote = "happy",
			},
		},
	},
	objectives = {
		{
			id = "EP02_C3_OB1",
			kind = "trap_part",
			label = "Pegue o cabo de aço no depósito do porão",
			clue = "EP02_PART1",
			marker = "Hotel_Cabos",
			points = 60,
		},
		{
			id = "EP02_C3_OB2",
			kind = "trap_part",
			label = "Pegue o contrapeso de ferro do ginásio do hotel",
			clue = "EP02_PART2",
			marker = "Hotel_Ginasio",
			points = 60,
		},
		{
			id = "EP02_C3_OB3",
			kind = "trap_part",
			label = "Pegue a rede de cortina de brocado do salão",
			clue = "EP02_PART3",
			marker = "Hotel_Salao",
			points = 60,
		},
		{
			id = "EP02_C3_OB4",
			kind = "build_trap",
			label = "Monte a armadilha do elevador de serviço",
			marker = "Hotel_TrapA",
			points = 150,
		},
		{
			id = "EP02_C3_OB5",
			kind = "bait_trap",
			label = "Deixe a porcelana de 1962 como isca",
			marker = "Hotel_TrapA",
			points = 90,
		},
		{
			id = "EP02_C3_OB6",
			kind = "defend",
			label = "Mantenha o fio de aço esticado por 50 segundos",
			seconds = 50,
			points = 130,
		},
	},
	clues = {
		{
			id = "EP02_C9",
			name = "Manchas de gesso no corrimão do elevador",
			text = "Pegadas de luva branca impressas em gesso fresco. O mesmo gesso da máscara.",
			detail = "Quem montou a máscara subiu por aqui carregando peso.",
			reveals = "O disfarce completo está em um quarto do 3º andar — provavelmente o 302.",
		},
	},
	deductions = {
		{
			id = "EP02_D3",
			question = "Por que o hóspede nunca sai do hotel para o lado de fora?",
			options = {
				{
					text = "Porque o figurino é pesado e não passa na porta giratória.",
					correct = true,
					feedback = "Fred: 'A porta giratória tem 70 cm. Aquele chapéu não passa nem de lado!'",
				},
				{
					text = "Porque fantasma tem medo de sol.",
					correct = false,
					feedback = "Velma: 'Ele aparece às 3 da manhã. O sol já era.'",
				},
				{
					text = "Porque a chave dele é só do 3º andar.",
					correct = false,
					feedback = "Daphne: 'Chave-mestra abre tudo, eu vi no chaveiro.'",
				},
			},
			logic = "O figurino é grande e rígido. Todo o trajeto dele precisa caber dentro do hotel — e o elevador de serviço liga tudo.",
			points = 130,
		},
	},
	trapSpots = {
		{
			id = "Hotel_TrapA",
			label = "Elevador de serviço (contrapeso + rede)",
			room = "Hotel_Elevador",
			needsParts = 3,
		},
		{
			id = "Hotel_TrapB",
			label = "Corredor do 3º andar (lustre + cortina)",
			room = "Hotel_Corredor3",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "O elevador começa a subir sozinho. Alguém respira atrás da porta de metal.",
		sfx = "Metal",
	},
	reveal = { unmaskedNpc = "EP02_Pianista", dialogue = "EP02_Reveal" },
	npcs = { "EP02_Gerente", "EP02_Bellboy" },
	rewards = { points = 780, snacks = 4 },
	nextChapter = "EP02_C4",
}

Episodes.Chapters.EP02_C4 = {
	id = "EP02_C4",
	episode = "EP02",
	index = 4,
	name = "Capítulo 4 — A Valsa do Hóspede",
	phase = "revelacao",
	location = "HotelEP2",
	mood = "EP02_Hotel",
	timeLimit = 720,
	brief = "Com o elevador travado, o hóspede está encurralado entre o 2º e o 3º andar. "
		.. "Hora de ver quem está dentro do figurino de brocado — e de escutar a segunda fita do Colecionador.",
	intro = {
		title = "A Valsa do Hóspede",
		subtitle = "Episódio 2 · Capítulo 4 de 4",
		narrator = "Fred",
		slides = {
			{ speaker = "Fred", text = "Trava! Trava! Ele está preso entre os andares!", emote = "excited" },
			{
				speaker = "Velma",
				text = "E olha o bolso do casaco: um envelope com o selo de cera. Vermelho. 'C²'.",
				emote = "thinking",
			},
			{
				speaker = "Salsicha",
				text = "Tipo assim, eu sabia que era gente! Eu falei! (eu não falei)",
				emote = "happy",
			},
		},
	},
	objectives = {
		{
			id = "EP02_C4_OB1",
			kind = "capture",
			label = "Prenda o Hóspede do 302 na armadilha do elevador",
			marker = "Hotel_TrapA",
			points = 200,
		},
		{
			id = "EP02_C4_OB2",
			kind = "unmask",
			label = "Tire a máscara de gesso e a cartola",
			marker = "Hotel_TrapA",
			points = 150,
		},
		{
			id = "EP02_C4_OB3",
			kind = "talk",
			label = "Ouça a confissão no salão ao lado do piano",
			npc = "EP02_Pianista",
			points = 80,
		},
		{
			id = "EP02_C4_OB4",
			kind = "reach",
			label = "Volte para a Mystery Machine com a valsa gravada",
			marker = "Hotel_Saida",
			points = 60,
		},
	},
	clues = {
		{
			id = "EP02_C10",
			name = "Envelope com selo 'C²' — lote 2/6",
			text = "Dentro do envelope: metade de uma partitura original de 1962 e uma nota: 'O LOTE 2 TEM QUE VALER MAIS QUE O 1. FAÇA MELHOR.'",
			detail = "O cliente compara os sustos como colecionador compara peças.",
			reveals = "Existe um mercado de sustos encomendados. Cada cidade é um número da coleção.",
		},
	},
	deductions = {
		{
			id = "EP02_D4",
			question = "Para que serve a partitura original de 1962?",
			options = {
				{
					text = "É o valor real da coleção — não o susto.",
					correct = true,
					feedback = "Velma: 'O fantasma era o teatro. O prêmio era a partitura. Ele usou o susto para esconder o roubo!'",
				},
				{
					text = "Para decorar o restaurante.",
					correct = false,
					feedback = "Daphne: 'Ninguém rouba decoração com selo de cera.'",
				},
				{
					text = "Para vender no leilão do hotel.",
					correct = false,
					feedback = "Fred: 'O leilão é do prédio, não dos objetos.'",
				},
			},
			logic = "O susto é a cortina de fumaça. O que se rouba é o item raro que ninguém percebe que faltou.",
			points = 150,
		},
	},
	trapSpots = {
		{
			id = "Hotel_TrapA",
			label = "Elevador de serviço (contrapeso + rede)",
			room = "Hotel_Elevador",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "A valsa começa a tocar do nada. O hóspede desce as escadas, decidido a acabar com a festa.",
		sfx = "ChaseMusic",
	},
	reveal = { unmaskedNpc = "EP02_Pianista", dialogue = "EP02_Reveal" },
	npcs = { "EP02_Pianista", "EP02_Gerente", "EP02_Convidada" },
	rewards = { points = 1000, snacks = 6 },
	nextChapter = nil,
	episodeEnd = true,
	achievements = { "sem_levar_susto" },
}

-- ==========================================================
-- EPISÓDIO 3 — O CIRCO ASSOMBRADO
-- ==========================================================
Episodes.List.EP03 = {
	id = "EP03",
	number = 3,
	title = "O Circo Assombrado",
	subtitle = "Circo Romanelli — beira da estrada",
	color = "Danger",
	unlock = "EP02",
	location = "CircoEP3",
	mood = "EP03_Circo",
	monsterId = "EP03_Fantasma",
	tagline = "Um palhaço gigante ri na madrugada e a bilheteria amanhece vazia.",
	synopsis = "O Circo Romanelli está há 40 anos na estrada. Nesta semana, um palhaço gigante aparece "
		.. "no picadeiro depois do fechamento, ri alto e faz o público ir embora. "
		.. "O dono ameaça fechar as portas e vender os leões de lona. "
		.. "O Mistério S.A. chega na hora do espetáculo — e sai de lá com confete na roupa e um caso resolvido.",
	acts = {
		"Confete, riso gravado e uma pisada pesada demais: o palhaço deixou rastro no picadeiro.",
		"Um palhaço substituído, uma trapezista que quer sair e um dono que quer vender tudo.",
		"O riso vem de um alto-falante e as pernas de pau deixam marcas de bengala no chão.",
		"A armadilha de trapézio prende o palhaço no ar — e Bibo confessa que queria voltar a ser a estrela.",
	},
	npcs = { "EP03_Dono", "EP03_Trapezista", "EP03_PalhacoTriste", "EP03_Feirante" },
	chapters = { "EP03_C1", "EP03_C2", "EP03_C3", "EP03_C4" },
}

Episodes.Chapters.EP03_C1 = {
	id = "EP03_C1",
	episode = "EP03",
	index = 1,
	name = "Capítulo 1 — Confete na Madrugada",
	phase = "investigacao",
	location = "CircoEP3",
	mood = "EP03_Circo",
	timeLimit = 900,
	brief = "O picadeiro está coberto de confete úmido e as cadeiras da primeira fila foram derrubadas. "
		.. "Fred quer medir pegadas, Velma quer o som, Daphne quer a bilheteria e Salsicha quer pipoca de graça.",
	intro = {
		title = "Confete na Madrugada",
		subtitle = "Episódio 3 · Capítulo 1 de 4",
		narrator = "Fred",
		slides = {
			{
				speaker = "Fred",
				text = "Circo Romanelli. 40 anos de estrada e o cheiro de pipoca mais forte do estado.",
				emote = "happy",
			},
			{
				speaker = "Mestre Romanelli",
				text = "Vocês vêm resolver o 'riso'? Eu pago o que for preciso. Amanhã eu perco a lona.",
				emote = "worried",
			},
			{
				speaker = "Salsicha",
				text = "Tipo assim, se ninguém quiser essa pipoca, eu conheço uma pessoa responsável.",
				emote = "happy",
			},
			{ speaker = "Scooby", text = "Ripoca! Ripoca! ...Ran? Ronde está riso?", emote = "excited" },
		},
	},
	objectives = {
		{
			id = "EP03_C1_OB1",
			kind = "talk",
			label = "Fale com Mestre Romanelli no escritório da lona",
			npc = "EP03_Dono",
			clue = "EP03_C1",
			points = 60,
		},
		{
			id = "EP03_C1_OB2",
			kind = "clue",
			label = "Coleta o confete úmido do picadeiro",
			clue = "EP03_C2",
			marker = "Circo_Confete",
			points = 80,
		},
		{
			id = "EP03_C1_OB3",
			kind = "clue",
			label = "Ache a marca de bengala de perna de pau",
			clue = "EP03_C3",
			marker = "Circo_Pegadas",
			points = 80,
		},
		{
			id = "EP03_C1_OB4",
			kind = "search",
			label = "Reviste a cabine de som atrás da arquibancada",
			clue = "EP03_C4",
			marker = "Circo_Som",
			points = 90,
		},
		{
			id = "EP03_C1_OB5",
			kind = "clue",
			label = "Leia a escala de números da semana passada",
			clue = "EP03_C5",
			marker = "Circo_Escala",
			points = 70,
		},
		{
			id = "EP03_C1_OB6",
			kind = "deduce",
			label = "Dedução 1: o riso é ao vivo ou gravado?",
			deduction = "EP03_D1",
			points = 130,
		},
	},
	clues = {
		{
			id = "EP03_C1",
			name = "Contrato de compra do terreno",
			text = "Uma imobiliária oferece 3x o valor do terreno — mas quer as lonas desmontadas em 15 dias. Contrato com data assinada.",
			detail = "O prazo aperta justamente na semana do fantasma.",
			reveals = "Alguém tem pressa: assustar o público é mais rápido que negociar.",
		},
		{
			id = "EP03_C2",
			name = "Confete úmido e marcado",
			text = "Confete com cheiro de tinta fresca e marcas de sapatos por cima. Foi espalhado no chão, não jogado do alto.",
			detail = "Confete de circo cai do trapézio. Este está alinhado como um rastro.",
			reveals = "O confete é cenografia: alguém montou um caminho para parecer efeito sobrenatural.",
		},
		{
			id = "EP03_C3",
			name = "Marca de bengala + fita adesiva",
			text = "Buracos pequenos a cada 90 cm — e restos de fita crepe no chão, como se algo tivesse sido preso antes.",
			detail = "Perna de pau deixa exatamente esse padrão. E a fita serviu para prender algo ao chão.",
			reveals = "O palhaço é um boneco mecânico guiado por fios — ou uma pessoa em pernas de pau.",
		},
		{
			id = "EP03_C4",
			name = "Cabine de som com gravação em loop",
			text = "Um aparelho de karaokê modificado toca uma faixa de 40 segundos em loop: risada, tambor e aplauso.",
			detail = "A fita está etiquetada à mão: 'RISO 3 — MAIS ALTO NO FINAL'.",
			reveals = "O riso é gravado. Alguém aperta PLAY escondido.",
		},
		{
			id = "EP03_C5",
			name = "Escala da semana passada",
			text = "O número principal ('Palhaço Bibo e os Malabares') foi riscado e trocado por 'Duo Iara e Léo'. Anotação na margem: 'ele não aceitou bem'.",
			detail = "Quem perdeu o posto principal tinha motivo e habilidade técnica para armá-lo.",
			reveals = "Bibo, o palhaço, é o suspeito mais óbvio — e o mais vigiado.",
		},
	},
	deductions = {
		{
			id = "EP03_D1",
			question = "O riso vem do fantasma ou de outro lugar?",
			options = {
				{
					text = "De um alto-falante da cabine de som, com gravação em loop.",
					correct = true,
					feedback = "Velma: 'A acústica do riso é estereofônica e o loop repete em 40 segundos exatos.'",
				},
				{
					text = "Do próprio palhaço, que tem voz grave.",
					correct = false,
					feedback = "Fred: 'A boca do palhaço nem abre. É máscara!'",
				},
				{ text = "Da plateia.", correct = false, feedback = "Daphne: 'A plateia é vazia, gente. Eu contei.'" },
			},
			logic = "Loop perfeito + acústica + cabine de som = efeito gravado para impressionar o público.",
			points = 130,
		},
	},
	trapSpots = {
		{
			id = "Circo_TrapA",
			label = "Trapézio central (rede + contrapeso)",
			room = "Circo_Picadeiro",
			needsParts = 3,
		},
		{ id = "Circo_TrapB", label = "Entrada da jaula (portão + lona)", room = "Circo_Jaulas", needsParts = 3 },
	},
	monsterIntro = {
		trigger = "afterObjective",
		objective = "EP03_C1_OB4",
		text = "A gravação dispara sozinha. O palhaço está parado no alto do picadeiro, olhando para vocês.",
		sfx = "JumpscareScream",
	},
	reveal = { unmaskedNpc = "EP03_PalhacoTriste", dialogue = "EP03_Reveal" },
	npcs = { "EP03_Dono", "EP03_Feirante" },
	rewards = { points = 700, snacks = 3 },
	nextChapter = "EP03_C2",
}

Episodes.Chapters.EP03_C2 = {
	id = "EP03_C2",
	episode = "EP03",
	index = 2,
	name = "Capítulo 2 — Três Verdades e uma Pirueta",
	phase = "suspeitos",
	location = "CircoEP3",
	mood = "EP03_Circo",
	timeLimit = 900,
	brief = "Iara quer dançar fora do circo. Zeca Pipoca quer vender a barraca. Romanelli quer dinheiro. "
		.. "E Bibo passa os dias costurando uma fantasia que ninguém pediu.",
	intro = {
		title = "Três Verdades e uma Pirueta",
		subtitle = "Episódio 3 · Capítulo 2 de 4",
		narrator = "Daphne",
		slides = {
			{
				speaker = "Daphne",
				text = "Circo é a profissão perfeita para esconder um disfarce: ninguém estranha um palhaço andando de madrugada.",
				emote = "thinking",
			},
			{
				speaker = "Velma",
				text = "Vou medir a altura do vulto pelo ponto de fixação dos fios. Se for maior que 2 metros, é perna de pau.",
				emote = "thinking",
			},
		},
	},
	objectives = {
		{
			id = "EP03_C2_OB1",
			kind = "talk",
			label = "Converse com Iara, a trapezista, no camarim alto",
			npc = "EP03_Trapezista",
			clue = "EP03_C6",
			points = 70,
		},
		{
			id = "EP03_C2_OB2",
			kind = "talk",
			label = "Pressione Bibo, o palhaço, no camarim das fantasias",
			npc = "EP03_PalhacoTriste",
			points = 80,
		},
		{
			id = "EP03_C2_OB3",
			kind = "talk",
			label = "Compre uma pipoca e escute Zeca no portão",
			npc = "EP03_Feirante",
			clue = "EP03_C7",
			points = 70,
		},
		{
			id = "EP03_C2_OB4",
			kind = "clue",
			label = "Encontre o alto-falante escondido atrás da lona",
			clue = "EP03_C8",
			marker = "Circo_Lona",
			points = 90,
		},
		{
			id = "EP03_C2_OB5",
			kind = "clue",
			label = "Achado no camarim: pernas de pau pintadas",
			clue = "EP03_C9",
			marker = "Circo_Camarim",
			points = 90,
		},
		{
			id = "EP03_C2_OB6",
			kind = "deduce",
			label = "Dedução 2: quem é grande o suficiente para o figurino?",
			deduction = "EP03_D2",
			points = 140,
		},
		{
			id = "EP03_C2_OB7",
			kind = "survive",
			label = "Sobreviva à perseguição do picadeiro às escuras",
			seconds = 60,
			points = 110,
			optional = true,
		},
	},
	clues = {
		{
			id = "EP03_C6",
			name = "Depoimento de Iara",
			text = "Iara viu Bibo subindo na passarela às 2h com um saco grande e ouvindo a gravação do riso em fones.",
			detail = "Ele dizia que estava 'ensaiando o novo número' — mas o número dele foi cortado.",
			reveals = "Bibo estava montando algo na passarela, de madrugada, sozinho.",
		},
		{
			id = "EP03_C7",
			name = "Depoimento de Zeca: barraca comprada",
			text = "Um homem de terno comprou 200 pipocas e pagou o dobro para que Zeca 'não visse nada' naquela noite.",
			detail = "O homem de terno voltou três vezes na semana. Sempre à noite.",
			reveals = "Alguém de fora paga para o circo fechar. Não é só um artista revoltado.",
		},
		{
			id = "EP03_C8",
			name = "Alto-falante com controle remoto",
			text = "Caixa acústica presa atrás da lona com fita, ligada a um receptor pequeno. Alcance: 80 metros.",
			detail = "Quem controla o riso pode estar a 80 metros de distância — fora do picadeiro.",
			reveals = "É possível acionar o susto de longe. O suspeito tem álibi enquanto o circo grita.",
		},
		{
			id = "EP03_C9",
			name = "Pernas de pau pintadas de vermelho",
			text = "Três pares de pernas de pau no camarim. Um deles está com tinta fresca e saltos gastos de forma diferente dos outros.",
			detail = "O par gasto é o que anda mais — e foi usado recentemente.",
			reveals = "Alguém da trupe usa pernas de pau para alcançar 2,7 m de altura.",
		},
	},
	deductions = {
		{
			id = "EP03_D2",
			question = "O vulto tem 2,7 m. Como um artista normal alcança essa altura?",
			options = {
				{
					text = "Pernas de pau presas dentro do figurino.",
					correct = true,
					feedback = "Salsicha: 'Tipo assim, eu vi a marca da bengala! Isso é truque de circo, e eu sou especialista em truques de fuga.'",
				},
				{
					text = "É um gigante de verdade.",
					correct = false,
					feedback = "Velma: 'Gigantes não deixam parafusos no chão. Olha aqui, um parafuso.'",
				},
				{
					text = "Ele flutua.",
					correct = false,
					feedback = "Fred: 'Se flutuasse, não precisaria de fita crepe na lona.'",
				},
			},
			logic = "Pernas de pau + marcas de bengala + confete para esconder as pegadas = simulação de altura impossível.",
			points = 140,
		},
	},
	trapSpots = {
		{
			id = "Circo_TrapA",
			label = "Trapézio central (rede + contrapeso)",
			room = "Circo_Picadeiro",
			needsParts = 3,
		},
		{ id = "Circo_TrapB", label = "Entrada da jaula (portão + lona)", room = "Circo_Jaulas", needsParts = 3 },
	},
	reveal = { unmaskedNpc = "EP03_PalhacoTriste", dialogue = "EP03_Reveal" },
	npcs = { "EP03_Trapezista", "EP03_PalhacoTriste", "EP03_Feirante" },
	rewards = { points = 760, snacks = 3 },
	nextChapter = "EP03_C3",
}

Episodes.Chapters.EP03_C3 = {
	id = "EP03_C3",
	episode = "EP03",
	index = 3,
	name = "Capítulo 3 — A Rede Acima do Picadeiro",
	phase = "armadilha",
	location = "CircoEP3",
	mood = "EP03_Circo",
	timeLimit = 900,
	brief = "O palhaço só aparece no picadeiro central, onde a plateia é obrigada a vê-lo. "
		.. "Então é lá que a armadilha vai: rede de trapézio, contrapeso de leão e um saco de pipoca bem no meio.",
	intro = {
		title = "A Rede Acima do Picadeiro",
		subtitle = "Episódio 3 · Capítulo 3 de 4",
		narrator = "Fred",
		slides = {
			{
				speaker = "Fred",
				text = "Pegamos a rede de segurança do trapézio, o contrapeso da gaiola e a corda do mastro.",
				emote = "excited",
			},
			{
				speaker = "Daphne",
				text = "E eu vou ficar na arquibancada. Se ele olhar para cima, eu grito — é o combinado.",
				emote = "happy",
			},
			{ speaker = "Scooby", text = "Ru rou rentar ro rirco inteiro? Ru! Ronde tem ripoca?", emote = "excited" },
		},
	},
	objectives = {
		{
			id = "EP03_C3_OB1",
			kind = "trap_part",
			label = "Pegue a rede de segurança do trapézio",
			clue = "EP03_PART1",
			marker = "Circo_Rede",
			points = 60,
		},
		{
			id = "EP03_C3_OB2",
			kind = "trap_part",
			label = "Pegue o contrapeso da jaula dos leões",
			clue = "EP03_PART2",
			marker = "Circo_Contrapeso",
			points = 60,
		},
		{
			id = "EP03_C3_OB3",
			kind = "trap_part",
			label = "Pegue a corda do mastro principal",
			clue = "EP03_PART3",
			marker = "Circo_Corda",
			points = 60,
		},
		{
			id = "EP03_C3_OB4",
			kind = "build_trap",
			label = "Monte a armadilha de trapézio no picadeiro",
			marker = "Circo_TrapA",
			points = 160,
		},
		{
			id = "EP03_C3_OB5",
			kind = "bait_trap",
			label = "Use o saco de pipoca como isca no centro do picadeiro",
			marker = "Circo_TrapA",
			points = 90,
		},
		{
			id = "EP03_C3_OB6",
			kind = "defend",
			label = "Apague as luzes e mantenha a armadilha por 55 segundos",
			seconds = 55,
			points = 140,
		},
	},
	clues = {
		{
			id = "EP03_C10",
			name = "Programa do espetáculo impresso em novo papel",
			text = "A nova temporada já tem programa impresso — com a foto de Bibo substituída e um selo de patrocínio: 'C² COLLECTION'.",
			detail = "O patrocinador novo entrou na mesma semana dos sustos.",
			reveals = "O 'colecionador' patrocina o circo que ele mesmo está sabotando.",
		},
	},
	deductions = {
		{
			id = "EP03_D3",
			question = "Por que o fantasma nunca aparece com as luzes acesas?",
			options = {
				{
					text = "Porque a gravação e os fios só funcionam no escuro, e no claro dá para ver a lona e as cordas.",
					correct = true,
					feedback = "Velma: 'Com 100% de luz, dá para ver o fio do riso e a fita no chão. É tudo cenografia!'",
				},
				{
					text = "Porque fantasma não gosta de lâmpada.",
					correct = false,
					feedback = "Salsicha: 'Tipo assim, isso é o que EU diria pra não trabalhar.'",
				},
				{
					text = "Porque a plateia é cega.",
					correct = false,
					feedback = "Daphne: 'A plateia enxerga. É ela que paga.'",
				},
			},
			logic = "Cenografia sobrevive no escuro. Luz é a arma contra o palhaço.",
			points = 140,
		},
	},
	trapSpots = {
		{
			id = "Circo_TrapA",
			label = "Trapézio central (rede + contrapeso)",
			room = "Circo_Picadeiro",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "Todas as luzes do picadeiro apagam de uma vez. O riso começa em 3, 2, 1...",
		sfx = "JumpscareScream",
	},
	reveal = { unmaskedNpc = "EP03_PalhacoTriste", dialogue = "EP03_Reveal" },
	npcs = { "EP03_Dono" },
	rewards = { points = 820, snacks = 4 },
	nextChapter = "EP03_C4",
}

Episodes.Chapters.EP03_C4 = {
	id = "EP03_C4",
	episode = "EP03",
	index = 4,
	name = "Capítulo 4 — O Riso Que Caiu do Trapézio",
	phase = "revelacao",
	location = "CircoEP3",
	mood = "EP03_Circo",
	timeLimit = 720,
	brief = "Suspenso na rede do trapézio, o palhaço não tem para onde correr. "
		.. "É hora de descobrir quem estava dentro do figurino — e para quem ele estava trabalhando.",
	intro = {
		title = "O Riso Que Caiu do Trapézio",
		subtitle = "Episódio 3 · Capítulo 4 de 4",
		narrator = "Velma",
		slides = {
			{
				speaker = "Fred",
				text = "Puxa! Ele tá preso a 6 metros! Não tem jeito de escapar!",
				emote = "excited",
			},
			{
				speaker = "Velma",
				text = "E o receptor do alto-falante está com uma etiqueta. Lote 3 de 6.",
				emote = "thinking",
			},
			{ speaker = "Scooby", text = "Ru rabia! Ru ru rabia que era gente! Rramalhado!", emote = "celebrate" },
		},
	},
	objectives = {
		{
			id = "EP03_C4_OB1",
			kind = "capture",
			label = "Prenda o Palhaço Sem Riso na rede do trapézio",
			marker = "Circo_TrapA",
			points = 200,
		},
		{
			id = "EP03_C4_OB2",
			kind = "unmask",
			label = "Tire a máscara de riso pintado",
			marker = "Circo_TrapA",
			points = 150,
		},
		{
			id = "EP03_C4_OB3",
			kind = "talk",
			label = "Ouça Bibo no meio do picadeiro",
			npc = "EP03_PalhacoTriste",
			points = 80,
		},
		{
			id = "EP03_C4_OB4",
			kind = "reach",
			label = "Leve o programa do circo para a Mystery Machine",
			marker = "Circo_Saida",
			points = 60,
		},
	},
	clues = {
		{
			id = "EP03_C11",
			name = "Terceira fita — lote 3/6",
			text = "Fita cassete com a voz modificada: 'O LOTE 3 ESTÁ ABAIXO DO ESPERADO. VOCÊ TEM ATÉ O FIM DO MÊS. — C²'",
			detail = "O cliente nunca aparece. Ele manda fitas e dinheiro em espécie.",
			reveals = "O contratante fala de seis LOTES. Faltam três.",
		},
	},
	deductions = {
		{
			id = "EP03_D4",
			question = "Se Bibo queria voltar ao número principal, por que sabotar o circo inteiro?",
			options = {
				{
					text = "Porque foi o cliente quem pagou: ele queria a lona desmontada, não o posto de volta.",
					correct = true,
					feedback = "Daphne: 'Ele chorou quando viu o programa impresso sem o nome dele. Naquele momento eu entendi.'",
				},
				{
					text = "Porque odeia pipoca.",
					correct = false,
					feedback = "Salsicha: 'Odeia pipoca? Isso não existe.'",
				},
				{
					text = "Porque o dono pediu.",
					correct = false,
					feedback = "Fred: 'O Romanelli quer o circo vivo, não falido.'",
				},
			},
			logic = "O motivo pessoal é o susto, mas o motivo real é o dinheiro do cliente. Quem paga manda.",
			points = 150,
		},
	},
	trapSpots = {
		{
			id = "Circo_TrapA",
			label = "Trapézio central (rede + contrapeso)",
			room = "Circo_Picadeiro",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "O palhaço desce a passarela com passos pesados de perna de pau. Última investida.",
		sfx = "ChaseMusic",
	},
	reveal = { unmaskedNpc = "EP03_PalhacoTriste", dialogue = "EP03_Reveal" },
	npcs = { "EP03_PalhacoTriste", "EP03_Trapezista", "EP03_Dono" },
	rewards = { points = 1050, snacks = 6 },
	nextChapter = nil,
	episodeEnd = true,
}

-- ==========================================================
-- EPISÓDIO 4 — A LINHA FANTASMA
-- ==========================================================
Episodes.List.EP04 = {
	id = "EP04",
	number = 4,
	title = "A Linha Fantasma",
	subtitle = "Fábrica Kraft — zona industrial",
	color = "Gold",
	unlock = "EP03",
	location = "FabricaEP4",
	mood = "EP04_Fabrica",
	monsterId = "EP04_Fantasma",
	tagline = "Um robô de 3 metros caminha na linha 4 de uma fábrica que não tem mais energia.",
	synopsis = "A Fábrica Kraft fechou as portas há dois anos. Mesmo assim, vizinhos juram que a linha de montagem "
		.. "4 liga sozinha às sextas-feiras e que um robô-patrulha anda pelos corredores. "
		.. "Uma engenheira demitida, um vigia trancado e uma cantina que nunca fechou: "
		.. "o Mistério S.A. entra pelas grades para descobrir quem está movendo uma fábrica morta.",
	acts = {
		"Pegadas de chapa de metal e óleo fresco provam que alguém mantém a linha 4 funcionando.",
		"A engenheira demitida, o vigia assustado e a estagiária que viu um macacão.",
		"O robô não é autônomo: tem um operador em uma sala de controle com vista para tudo.",
		"A armadilha de esteira prende o robô, e o macacão escondia a engenheira Sônia Kraft.",
	},
	npcs = { "EP04_Engenheira", "EP04_Seguranca", "EP04_Estagiario", "EP04_Dona" },
	chapters = { "EP04_C1", "EP04_C2", "EP04_C3", "EP04_C4" },
}

Episodes.Chapters.EP04_C1 = {
	id = "EP04_C1",
	episode = "EP04",
	index = 1,
	name = "Capítulo 1 — A Linha 4 Liga Sozinha",
	phase = "investigacao",
	location = "FabricaEP4",
	mood = "EP04_Fabrica",
	timeLimit = 900,
	brief = "A cerca tem um buraco do tamanho de uma pessoa educada que quer entrar sem chamar atenção. "
		.. "Lá dentro: esteiras paradas, um cheiro de óleo novo e um painel piscando.",
	intro = {
		title = "A Linha 4 Liga Sozinha",
		subtitle = "Episódio 4 · Capítulo 1 de 4",
		narrator = "Shaggy",
		slides = {
			{
				speaker = "Shaggy",
				text = "Tipo assim, eu não entendo robô. Robô não tem moral, não tem conversa, não tem lanche.",
				emote = "scared",
			},
			{
				speaker = "Velma",
				text = "Fábrica parada há 2 anos. Se há óleo novo na esteira, há manutenção nova.",
				emote = "thinking",
			},
			{
				speaker = "Fred",
				text = "E se tem manutenção, tem alguém pagando por ela. Acho que já sabemos o caminho.",
				emote = "happy",
			},
		},
	},
	objectives = {
		{
			id = "EP04_C1_OB1",
			kind = "talk",
			label = "Fale com o vigia Amaral no vestiário",
			npc = "EP04_Seguranca",
			clue = "EP04_C1",
			points = 70,
		},
		{
			id = "EP04_C1_OB2",
			kind = "clue",
			label = "Examine as pegadas de chapa metálica no piso da linha 4",
			clue = "EP04_C2",
			marker = "Fabrica_Pegadas",
			points = 80,
		},
		{
			id = "EP04_C1_OB3",
			kind = "clue",
			label = "Leia o quadro de energia com o fusível novo",
			clue = "EP04_C3",
			marker = "Fabrica_Painel",
			points = 80,
		},
		{
			id = "EP04_C1_OB4",
			kind = "search",
			label = "Reviste a sala de controle no mezanino",
			clue = "EP04_C4",
			marker = "Fabrica_SalaControle",
			points = 90,
		},
		{
			id = "EP04_C1_OB5",
			kind = "clue",
			label = "Encontre o crachá perdido perto da esteira",
			clue = "EP04_C5",
			marker = "Fabrica_Cracha",
			points = 80,
		},
		{
			id = "EP04_C1_OB6",
			kind = "deduce",
			label = "Dedução 1: o robô é autônomo?",
			deduction = "EP04_D1",
			points = 140,
		},
	},
	clues = {
		{
			id = "EP04_C1",
			name = "Relato de Amaral: 3 horas trancado",
			text = "O vigia trancou a si mesmo no vestiário quando viu o 'robô'. Ele descreve um zumbido de servo-motor — e um cheiro de café.",
			detail = "Máquina não toma café. Mas um operador em turno noturno sim.",
			reveals = "Existe alguém comendo e bebendo dentro da fábrica durante a madrugada.",
		},
		{
			id = "EP04_C2",
			name = "Pegadas de chapa com rebites",
			text = "Marcas retangulares com rebites, peso estimado de 400 kg. As pegadas entram e saem do mesmo ponto: a sala de controle.",
			detail = "Nada que pesa 400 kg entra em uma sala de controle por vontade própria sem deixar rastro.",
			reveals = "O caminho do robô é sempre o mesmo — logo, alguém o guia.",
		},
		{
			id = "EP04_C3",
			name = "Fusível de cobre novo em painel antigo",
			text = "Três fusíveis novos e um disjuntor religado com etiqueta 'NÃO DESLIGAR'. A energia da linha 4 vem de um gerador auxiliar.",
			detail = "O gerador consome diesel — e o tanque está quase cheio.",
			reveals = "Alguém compra diesel para manter a linha 4 viva. Custa dinheiro.",
		},
		{
			id = "EP04_C4",
			name = "Sala de controle: cadeira quente e rádio ligado",
			text = "Três monitores ligados, uma caneca ainda morna e um rádio na frequência 87.9 — a rádio da cidade.",
			detail = "A cadeira está na posição de quem passa horas ali. E há marcas de cotovelo na mesa.",
			reveals = "O 'robô' é operado daqui. Quem opera conhece a planta perfeitamente.",
		},
		{
			id = "EP04_C5",
			name = "Crachá antigo de acesso 'ENG. S. KRAFT'",
			text = "Crachá de acesso com foto e um adesivo: 'DESLIGADA POR REESTRUTURAÇÃO'. Está limpo, sem poeira.",
			detail = "Um crachá desativado há dois anos não fica limpo.",
			reveals = "Alguém usa o crachá antigo. E é a ex-engenheira.",
		},
	},
	deductions = {
		{
			id = "EP04_D1",
			question = "Uma fábrica sem energia não move um robô. O que mantém a linha 4 funcionando?",
			options = {
				{
					text = "Um gerador auxiliar alimentado com diesel comprado por alguém.",
					correct = true,
					feedback = "Velma: 'Tanque quase cheio, disjuntor religado e compras de diesel. É uma operação paga!'",
				},
				{
					text = "Energia sobrenatural.",
					correct = false,
					feedback = "Fred: 'Energia sobrenatural não emite nota fiscal de diesel.'",
				},
				{
					text = "A própria rede da cidade.",
					correct = false,
					feedback = "Velma: 'O relógio de luz está lacrado. Sem passagem, sem energia.'",
				},
			},
			logic = "Consumo de combustível + manutenção elétrica = alguém investe dinheiro para manter o susto vivo.",
			points = 140,
		},
	},
	trapSpots = {
		{
			id = "Fabrica_TrapA",
			label = "Esteira da linha 4 (roletes + cabo)",
			room = "Fabrica_Linha4",
			needsParts = 3,
		},
		{
			id = "Fabrica_TrapB",
			label = "Prensa principal (contrapeso + grade)",
			room = "Fabrica_Prensa",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "afterObjective",
		objective = "EP04_C1_OB2",
		text = "Um servo-motor zumbe no fundo do galpão. As luzes da linha 4 acendem em sequência.",
		sfx = "Metal",
	},
	reveal = { unmaskedNpc = "EP04_Engenheira", dialogue = "EP04_Reveal" },
	npcs = { "EP04_Seguranca", "EP04_Estagiario", "EP04_Dona" },
	rewards = { points = 750, snacks = 3 },
	nextChapter = "EP04_C2",
}

Episodes.Chapters.EP04_C2 = {
	id = "EP04_C2",
	episode = "EP04",
	index = 2,
	name = "Capítulo 2 — Quem Paga o Diesel",
	phase = "suspeitos",
	location = "FabricaEP4",
	mood = "EP04_Fabrica",
	timeLimit = 900,
	brief = "Diesel não é barato. Alguém está financiando uma fábrica morta por dois anos. "
		.. "A turma vai atrás das notas de compra, do estagiário e da cantina que nunca fechou.",
	intro = {
		title = "Quem Paga o Diesel",
		subtitle = "Episódio 4 · Capítulo 2 de 4",
		narrator = "Fred",
		slides = {
			{
				speaker = "Fred",
				text = "Seguinte: ninguém mantém uma fábrica fantasma de graça. Vamos seguir o dinheiro.",
				emote = "excited",
			},
			{
				speaker = "Daphne",
				text = "E eu vou na cantina. Cantina de fábrica ouve tudo, sempre.",
				emote = "happy",
			},
		},
	},
	objectives = {
		{
			id = "EP04_C2_OB1",
			kind = "talk",
			label = "Ouça a Engenheira Sônia na sala de controle",
			npc = "EP04_Engenheira",
			points = 80,
		},
		{
			id = "EP04_C2_OB2",
			kind = "talk",
			label = "Converse com Nando, o estagiário, no painel elétrico",
			npc = "EP04_Estagiario",
			clue = "EP04_C6",
			points = 70,
		},
		{
			id = "EP04_C2_OB3",
			kind = "talk",
			label = "Tome um café com Dona Cida na cantina",
			npc = "EP04_Dona",
			clue = "EP04_C7",
			points = 70,
		},
		{
			id = "EP04_C2_OB4",
			kind = "clue",
			label = "Encontre as notas de diesel no escritório do almoxarifado",
			clue = "EP04_C8",
			marker = "Fabrica_Almox",
			points = 90,
		},
		{
			id = "EP04_C2_OB5",
			kind = "clue",
			label = "Compare o macacão do armário com a fita do vídeo",
			clue = "EP04_C9",
			marker = "Fabrica_Armario",
			points = 90,
		},
		{
			id = "EP04_C2_OB6",
			kind = "deduce",
			label = "Dedução 2: quem conhece a fábrica bem o suficiente para guiar o robô?",
			deduction = "EP04_D2",
			points = 150,
		},
		{
			id = "EP04_C2_OB7",
			kind = "survive",
			label = "Sobreviva ao vapor da prensa por 60 segundos",
			seconds = 60,
			points = 120,
			optional = true,
		},
	},
	clues = {
		{
			id = "EP04_C6",
			name = "Depoimento de Nando",
			text = "Nando religou o disjuntor a pedido de alguém 'de macacão, com voz de quem manda'. Ele recebeu R$ 300 em espécie.",
			detail = "O pagamento foi em dinheiro, sem nota — igual ao diesel.",
			reveals = "A operação paga em espécie, como os outros casos.",
		},
		{
			id = "EP04_C7",
			name = "Depoimento de Dona Cida",
			text = "Toda sexta-feira, entre 2h e 5h, alguém pede um pão na chapa e um café na janela da cantina. Sempre paga com nota nova.",
			detail = "O horário coincide com os avistamentos do robô.",
			reveals = "O operador do robô está na fábrica toda sexta, das 2h às 5h.",
		},
		{
			id = "EP04_C8",
			name = "Notas de diesel e recibo de empresa fantasma",
			text = "Seis notas de diesel no nome de 'K-BRASIL CONSULTORIA', CNPJ aberto há 8 meses — exatamente quando os sustos começaram.",
			detail = "A empresa não tem sócios listados, só um procurador: alguém com registro profissional de engenharia.",
			reveals = "A empresa de fachada serve para comprar combustível sem chamar atenção.",
		},
		{
			id = "EP04_C9",
			name = "Macacão com graxa de servo-motor",
			text = "No armário feminino do vestiário, um macacão cinza com graxa de servo. Bolso: um manual com anotações de torque.",
			detail = "A letra é técnica, com correções de engenharia em caneta vermelha.",
			reveals = "O macacão pertence a quem projetou o sistema — e as anotações são de quem sabe exatamente o limite das máquinas.",
		},
	},
	deductions = {
		{
			id = "EP04_D2",
			question = "Quem guia o robô pelas passagens mais estreitas da fábrica?",
			options = {
				{
					text = "Alguém que conhece a planta de cor: a engenheira que projetou a linha 4.",
					correct = true,
					feedback = "Velma: 'O robô passa a 15 cm da parede em todos os corredores. Só quem desenhou o layout faria isso.'",
				},
				{
					text = "O vigia, que trabalha ali há anos.",
					correct = false,
					feedback = "Fred: 'O vigia se trancou no vestiário. Ele tem medo da própria fábrica.'",
				},
				{
					text = "O robô é autônomo mesmo.",
					correct = false,
					feedback = "Velma: 'Autônomo não come pão na chapa às 3 da manhã.'",
				},
			},
			logic = "Precisão milimétrica em corredores apertados revela quem tem a planta na cabeça.",
			points = 150,
		},
	},
	trapSpots = {
		{
			id = "Fabrica_TrapA",
			label = "Esteira da linha 4 (roletes + cabo)",
			room = "Fabrica_Linha4",
			needsParts = 3,
		},
		{
			id = "Fabrica_TrapB",
			label = "Prensa principal (contrapeso + grade)",
			room = "Fabrica_Prensa",
			needsParts = 3,
		},
	},
	reveal = { unmaskedNpc = "EP04_Engenheira", dialogue = "EP04_Reveal" },
	npcs = { "EP04_Engenheira", "EP04_Estagiario", "EP04_Dona" },
	rewards = { points = 820, snacks = 3 },
	nextChapter = "EP04_C3",
}

Episodes.Chapters.EP04_C3 = {
	id = "EP04_C3",
	episode = "EP04",
	index = 3,
	name = "Capítulo 3 — A Esteira Que Vai Fechar o Caso",
	phase = "armadilha",
	location = "FabricaEP4",
	mood = "EP04_Fabrica",
	timeLimit = 900,
	brief = "O robô passa pela linha 4 em intervalos regulares, como se estivesse de plantão. "
		.. "Roletes, cabo de aço e uma grade de prensa: a armadilha industrial está montada no papel. Falta montar na esteira.",
	intro = {
		title = "A Esteira Que Vai Fechar o Caso",
		subtitle = "Episódio 4 · Capítulo 3 de 4",
		narrator = "Velma",
		slides = {
			{
				speaker = "Velma",
				text = "O robô passa a cada 6 minutos e 20 segundos. Precisão mecânica é a maior fraqueza de quem opera uma máquina.",
				emote = "thinking",
			},
			{
				speaker = "Fred",
				text = "Então prendemos os roletes e ele perde o chão. Robô de 400 kg não corre atrás de ninguém.",
				emote = "excited",
			},
			{ speaker = "Salsicha", text = "Tipo assim, e se ele tiver um botão de 'modo raiva'?", emote = "scared" },
		},
	},
	objectives = {
		{
			id = "EP04_C3_OB1",
			kind = "trap_part",
			label = "Pegue o cabo de aço de 12 mm no almoxarifado",
			clue = "EP04_PART1",
			marker = "Fabrica_Cabo",
			points = 60,
		},
		{
			id = "EP04_C3_OB2",
			kind = "trap_part",
			label = "Pegue os roletes da esteira parada",
			clue = "EP04_PART2",
			marker = "Fabrica_Roletes",
			points = 60,
		},
		{
			id = "EP04_C3_OB3",
			kind = "trap_part",
			label = "Pegue a grade de proteção da prensa",
			clue = "EP04_PART3",
			marker = "Fabrica_Grade",
			points = 60,
		},
		{
			id = "EP04_C3_OB4",
			kind = "build_trap",
			label = "Monte a armadilha de esteira na Linha 4",
			marker = "Fabrica_TrapA",
			points = 160,
		},
		{
			id = "EP04_C3_OB5",
			kind = "bait_trap",
			label = "Use o pão na chapa como isca (ele vem toda sexta!)",
			marker = "Fabrica_TrapA",
			points = 100,
		},
		{
			id = "EP04_C3_OB6",
			kind = "defend",
			label = "Segure o disjuntor ligado por 60 segundos sem sobrecarga",
			seconds = 60,
			points = 140,
		},
	},
	clues = {
		{
			id = "EP04_C10",
			name = "Contrato de consultoria rasgado",
			text = "Um contrato no lixo: 'K-BRASIL CONSULTORIA prestará serviços de auditoria de risco na Fábrica Kraft — condição: parecer NEGATIVO de segurança'.",
			detail = "O parecer negativo valorizava a fábrica para venda a preço de banana.",
			reveals = "O objetivo nunca foi o susto: era o laudo técnico que desvaloriza o prédio.",
		},
	},
	deductions = {
		{
			id = "EP04_D3",
			question = "Por que o robô nunca ataca ninguém de verdade?",
			options = {
				{
					text = "Porque um acidente real mudaria o caso de 'assombração' para 'polícia' — e destruiria o plano.",
					correct = true,
					feedback = "Daphne: 'Ele só quer que a fábrica pareça perigosa. Não quer manchete de tragédia.'",
				},
				{
					text = "Porque o robô é gentil.",
					correct = false,
					feedback = "Salsicha: 'Gentil?! Ele me perseguiu por 3 corredores!'",
				},
				{
					text = "Porque a bateria acaba.",
					correct = false,
					feedback = "Velma: 'Ele está ligado no gerador. Bateria não é o problema.'",
				},
			},
			logic = "O susto é controlado: quem opera precisa manter a história 'assombrada', não 'mortal'.",
			points = 150,
		},
	},
	trapSpots = {
		{
			id = "Fabrica_TrapA",
			label = "Esteira da linha 4 (roletes + cabo)",
			room = "Fabrica_Linha4",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "O servo-motor zumbe ao longe e as luzes da linha 4 acendem em sequência. Ele está vindo.",
		sfx = "Metal",
	},
	reveal = { unmaskedNpc = "EP04_Engenheira", dialogue = "EP04_Reveal" },
	npcs = { "EP04_Seguranca" },
	rewards = { points = 880, snacks = 4 },
	nextChapter = "EP04_C4",
}

Episodes.Chapters.EP04_C4 = {
	id = "EP04_C4",
	episode = "EP04",
	index = 4,
	name = "Capítulo 4 — O Parafuso Solto do MK-4",
	phase = "revelacao",
	location = "FabricaEP4",
	mood = "EP04_Fabrica",
	timeLimit = 720,
	brief = "Com os roletes travados, o robô perdeu o equilíbrio e está preso entre a esteira e a prensa. "
		.. "A quarta fita do Colecionador está no painel de controle — e o caso só fecha com a confissão.",
	intro = {
		title = "O Parafuso Solto do MK-4",
		subtitle = "Episódio 4 · Capítulo 4 de 4",
		narrator = "Fred",
		slides = {
			{ speaker = "Fred", text = "Ele travou! A esteira segurou o trem de roletes!", emote = "excited" },
			{
				speaker = "Velma",
				text = "Mesmo preso, ele pode sobrecarregar. Ninguém atrás da prensa, por favor!",
				emote = "worried",
			},
			{ speaker = "Scooby", text = "Rapaz! Ru ru ru quero rer ro robô!", emote = "scared" },
		},
	},
	objectives = {
		{
			id = "EP04_C4_OB1",
			kind = "capture",
			label = "Prenda o Robô da Linha 4 na esteira",
			marker = "Fabrica_TrapA",
			points = 220,
		},
		{
			id = "EP04_C4_OB2",
			kind = "unmask",
			label = "Abra o painel do robô e encontre o operador",
			marker = "Fabrica_TrapA",
			points = 150,
		},
		{
			id = "EP04_C4_OB3",
			kind = "talk",
			label = "Ouça Sônia Kraft na sala de controle",
			npc = "EP04_Engenheira",
			points = 90,
		},
		{
			id = "EP04_C4_OB4",
			kind = "reach",
			label = "Volte à Mystery Machine com o laudo assinado",
			marker = "Fabrica_Saida",
			points = 60,
		},
	},
	clues = {
		{
			id = "EP04_C11",
			name = "Quarta fita — lote 4/6",
			text = "A voz modificada: 'OS TRÊS PRIMEIROS LOTES FORAM VENDIDOS. A COLEÇÃO PRECISA DOS TRÊS ÚLTIMOS. NÃO FALHE.'",
			detail = "A fita tem um ruído de fundo reconhecível: uma transmissão de rádio AM.",
			reveals = "O contratante tem uma estação de rádio. Coolsville tem exatamente duas.",
		},
	},
	deductions = {
		{
			id = "EP04_D4",
			question = "Se o cliente quer a coleção completa, por que ele manda as fitas?",
			options = {
				{
					text = "Ele quer que os 'artistas' saibam que fazem parte de algo maior — vaidade de colecionador.",
					correct = true,
					feedback = "Daphne: 'Ele não é só um cliente. Ele é um curador. Quer uma coleção de sustos assinada.'",
				},
				{
					text = "Porque não tem telefone.",
					correct = false,
					feedback = "Salsicha: 'Tipo assim, eu também não tenho e ninguém me manda fita.'",
				},
				{
					text = "Para assustar os próprios funcionários.",
					correct = false,
					feedback = "Velma: 'O susto é o produto. A fita é o contrato.'",
				},
			},
			logic = "Colecionadores catalogam. Cada fita é uma etiqueta de acervo — e cada vilão é uma peça.",
			points = 160,
		},
	},
	trapSpots = {
		{
			id = "Fabrica_TrapA",
			label = "Esteira da linha 4 (roletes + cabo)",
			room = "Fabrica_Linha4",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "As luzes da linha 4 piscam. O MK-4 vem pela esteira com os braços abertos.",
		sfx = "ChaseMusic",
	},
	reveal = { unmaskedNpc = "EP04_Engenheira", dialogue = "EP04_Reveal" },
	npcs = { "EP04_Engenheira", "EP04_Seguranca", "EP04_Dona" },
	rewards = { points = 1100, snacks = 6 },
	nextChapter = nil,
	episodeEnd = true,
}

-- ==========================================================
-- EPISÓDIO 5 — O CAVALEIRO DO KM 13
-- ==========================================================
Episodes.List.EP05 = {
	id = "EP05",
	number = 5,
	title = "O Cavaleiro do KM 13",
	subtitle = "Estrada Nebulosa — quilômetro 13",
	color = "Night",
	unlock = "EP04",
	location = "EstradaEP5",
	mood = "EP05_Estrada",
	monsterId = "EP05_Fantasma",
	tagline = "Na neblina, um cavaleiro sem cabeça galopa e mata motores por onde passa.",
	synopsis = "A estrada velha do KM 13 é o atalho que ninguém mais usa. Nas últimas semanas, "
		.. "um cavaleiro sem cabeça apareceu na neblina, apagou motores e assustou três caminhoneiros. "
		.. "A nova rodovia ia passar pelas terras do Seu Otávio — que agora se recusa a vender. "
		.. "A turma estaciona a Mystery Machine justamente no trecho onde o asfalto novo termina.",
	acts = {
		"A neblina tem cheiro de óleo queimado e o asfalto tem marcas de casco que não são de cavalo.",
		"Um fazendeiro que perde tudo com a rodovia nova, uma mecânica honesta e uma jornalista com fotos de 1987.",
		"O 'cavalo' é um trator pequeno coberto de feltro. O motor obedece a um controle remoto.",
		"A armadilha de guincho fecha o KM 13, e Seu Otávio confessa — mas quem pagou a conta foi o Colecionador.",
	},
	npcs = { "EP05_Mecanico", "EP05_Motorista", "EP05_Fazendeiro", "EP05_Jornalista" },
	chapters = { "EP05_C1", "EP05_C2", "EP05_C3", "EP05_C4" },
}

Episodes.Chapters.EP05_C1 = {
	id = "EP05_C1",
	episode = "EP05",
	index = 1,
	name = "Capítulo 1 — Neblina com Cheiro de Óleo",
	phase = "investigacao",
	location = "EstradaEP5",
	mood = "EP05_Estrada",
	timeLimit = 900,
	brief = "O posto fechou às 22h. A lanchonete continua aberta e a neblina está subindo do rio. "
		.. "Objetivo: entender por que os motores morrem exatamente no KM 13.",
	intro = {
		title = "Neblina com Cheiro de Óleo",
		subtitle = "Episódio 5 · Capítulo 1 de 4",
		narrator = "Velma",
		slides = {
			{
				speaker = "Velma",
				text = "Neblina, farol baixo e uma estrada com 13 quilômetros de curvas. Estatisticamente perfeito para um susto.",
				emote = "thinking",
			},
			{
				speaker = "Daphne",
				text = "E tem uma lanchonete com luz acesa. Finalmente um lugar onde eu posso sentar.",
				emote = "happy",
			},
			{ speaker = "Salsicha", text = "Lanche! Digo... investigação! Tudo pela ciência.", emote = "excited" },
		},
	},
	objectives = {
		{
			id = "EP05_C1_OB1",
			kind = "talk",
			label = "Fale com Zulmira, a mecânica, no posto",
			npc = "EP05_Mecanico",
			clue = "EP05_C1",
			points = 70,
		},
		{
			id = "EP05_C1_OB2",
			kind = "clue",
			label = "Examine as marcas de casco no asfalto",
			clue = "EP05_C2",
			marker = "Estrada_Casco",
			points = 80,
		},
		{
			id = "EP05_C1_OB3",
			kind = "clue",
			label = "Ache o cabo cortado no poste do KM 13",
			clue = "EP05_C3",
			marker = "Estrada_Poste",
			points = 90,
		},
		{
			id = "EP05_C1_OB4",
			kind = "search",
			label = "Reviste o celeiro abandonado ao lado da estrada",
			clue = "EP05_C4",
			marker = "Estrada_Celeiro",
			points = 90,
		},
		{
			id = "EP05_C1_OB5",
			kind = "clue",
			label = "Olhe a placa da obra da rodovia nova",
			clue = "EP05_C5",
			marker = "Estrada_Placa",
			points = 70,
		},
		{
			id = "EP05_C1_OB6",
			kind = "deduce",
			label = "Dedução 1: por que os motores morrem no KM 13?",
			deduction = "EP05_D1",
			points = 150,
		},
	},
	clues = {
		{
			id = "EP05_C1",
			name = "Relato de Zulmira: três motores mortos na mesma curva",
			text = "Três veículos pararam no mesmo ponto. Em todos, o problema foi o mesmo: cabo de vela arrancado — arrancado, não queimado.",
			detail = "Queimado é desgaste. Arrancado é ação humana.",
			reveals = "Alguém interrompe os veículos manualmente antes de aparecer.",
		},
		{
			id = "EP05_C2",
			name = "Marca de 'casco' com esteira",
			text = "As marcas de casco têm 40 cm de largura e um padrão reto demais para um animal. Por baixo, uma faixa fina de esteira.",
			detail = "Existe um veículo com esteira disfarçado de cavalo.",
			reveals = "O cavalo do cavaleiro é um trator pequeno coberto de feltro.",
		},
		{
			id = "EP05_C3",
			name = "Cabo elétrico cortado com alicate",
			text = "O poste do KM 13 tem o cabo cortado de forma limpa. O gerador do celeiro próximo está com combustível novo.",
			detail = "O gerador alimenta uma luz que ninguém deveria ver de longe.",
			reveals = "Usam energia própria na estrada para operar equipamentos.",
		},
		{
			id = "EP05_C4",
			name = "Armadura de couro e abóbora de plástico",
			text = "No celeiro: uma armadura de couro coberta de fuligem, uma abóbora de plástico com lâmpada dentro e um controle remoto de 4 canais.",
			detail = "O controle tem dois canais queimados de uso. Alguém usa isso há semanas.",
			reveals = "O figurino é caseiro e caro ao mesmo tempo: couro, lâmpada e eletrônica de rádio-controle.",
		},
		{
			id = "EP05_C5",
			name = "Placa da obra: 'RODOVIA NOVA — LOTE 5/6'",
			text = "Placa de obra com um selo discreto: 'C² INFRA'. O mesmo padrão de selo do farol e do hotel.",
			detail = "As obras são da mesma holding que aparece em todos os outros casos.",
			reveals = "O cliente compra terras baratas depois que o susto assusta os moradores.",
		},
	},
	deductions = {
		{
			id = "EP05_D1",
			question = "Por que o KM 13 apaga motores com tanta facilidade?",
			options = {
				{
					text = "Alguém arranca o cabo de vela manualmente enquanto o motorista está distraído com o 'cavaleiro'.",
					correct = true,
					feedback = "Fred: 'O susto distrai, o comparsa arranca o cabo. Trabalho em dupla!'",
				},
				{
					text = "Interferência magnética sobrenatural.",
					correct = false,
					feedback = "Velma: 'Nenhum campo magnético arranca cabo. Só mão humana.'",
				},
				{
					text = "Os motores são velhos.",
					correct = false,
					feedback = "Salsicha: 'A van da gente é velha e nunca morreu. Quer dizer... morre às vezes.'",
				},
			},
			logic = "O susto é a distração. A sabotagem é o trabalho — e exige um segundo par de mãos.",
			points = 150,
		},
	},
	trapSpots = {
		{
			id = "Estrada_TrapA",
			label = "Curva do KM 13 (cabo de guincho + lona)",
			room = "Estrada_Curva",
			needsParts = 3,
		},
		{ id = "Estrada_TrapB", label = "Ponte de madeira (cordas + tábuas)", room = "Estrada_Ponte", needsParts = 3 },
	},
	monsterIntro = {
		trigger = "afterObjective",
		objective = "EP05_C1_OB2",
		text = "Um galope ecoa na neblina. O farol da Mystery Machine pisca e apaga.",
		sfx = "GhostMoan",
	},
	reveal = { unmaskedNpc = "EP05_Fazendeiro", dialogue = "EP05_Reveal" },
	npcs = { "EP05_Mecanico", "EP05_Motorista", "EP05_Jornalista" },
	rewards = { points = 800, snacks = 3 },
	nextChapter = "EP05_C2",
}

Episodes.Chapters.EP05_C2 = {
	id = "EP05_C2",
	episode = "EP05",
	index = 2,
	name = "Capítulo 2 — A Fazenda Contra a Rodovia",
	phase = "suspeitos",
	location = "EstradaEP5",
	mood = "EP05_Estrada",
	timeLimit = 900,
	brief = "Seu Otávio perde a fazenda se a rodovia passar. Rita Fontes tem fotos do cavaleiro de 1987. "
		.. "Bigode tem o para-brisa quebrado. E Zulmira tem as notas do conserto de um trator muito estranho.",
	intro = {
		title = "A Fazenda Contra a Rodovia",
		subtitle = "Episódio 5 · Capítulo 2 de 4",
		narrator = "Daphne",
		slides = {
			{
				speaker = "Daphne",
				text = "Essa história tem 40 anos. Será que o cavaleiro de 1987 era o mesmo? Ou alguém copiou a lenda?",
				emote = "thinking",
			},
			{
				speaker = "Velma",
				text = "Copiar uma lenda antiga é a estratégia preferida de quem quer intimidar sem aparecer.",
				emote = "thinking",
			},
		},
	},
	objectives = {
		{
			id = "EP05_C2_OB1",
			kind = "talk",
			label = "Converse com Seu Otávio no celeiro",
			npc = "EP05_Fazendeiro",
			points = 80,
		},
		{
			id = "EP05_C2_OB2",
			kind = "talk",
			label = "Escute o caminhoneiro Bigode na lanchonete",
			npc = "EP05_Motorista",
			clue = "EP05_C6",
			points = 70,
		},
		{
			id = "EP05_C2_OB3",
			kind = "talk",
			label = "Veja as fotos antigas com Rita, a jornalista",
			npc = "EP05_Jornalista",
			clue = "EP05_C7",
			points = 90,
		},
		{
			id = "EP05_C2_OB4",
			kind = "clue",
			label = "Encontre a nota do conserto do 'trator pequeno'",
			clue = "EP05_C8",
			marker = "Estrada_Notas",
			points = 90,
		},
		{
			id = "EP05_C2_OB5",
			kind = "clue",
			label = "Ache o gravador com a voz modificada no posto",
			clue = "EP05_C9",
			marker = "Estrada_Gravador",
			points = 100,
		},
		{
			id = "EP05_C2_OB6",
			kind = "deduce",
			label = "Dedução 2: quem ganha com a rodovia parada?",
			deduction = "EP05_D2",
			points = 160,
		},
		{
			id = "EP05_C2_OB7",
			kind = "survive",
			label = "Sobreviva à carga do cavaleiro na ponte",
			seconds = 70,
			points = 130,
			optional = true,
		},
	},
	clues = {
		{
			id = "EP05_C6",
			name = "Vidro quebrado com massa de metal",
			text = "No vidro do caminhão, um pedaço de ferro fundido — não pedra. O cavaleiro bate com algo de metal.",
			detail = "O peso e o formato combinam com uma ferramenta agrícola.",
			reveals = "Quem atacou o caminhão tem acesso a ferramentas de fazenda.",
		},
		{
			id = "EP05_C7",
			name = "Foto de 1987: um cavaleiro, dois cavaleiros",
			text = "A foto antiga mostra a lenda original. Comparando com o 'cavaleiro' atual, a silhueta do cavalo tem 30 cm de diferença e um escapamento visível.",
			detail = "A lenda moderna tem peças mecânicas expostas. A antiga não.",
			reveals = "O cavaleiro atual é uma produção nova, inspirada na lenda de 1987.",
		},
		{
			id = "EP05_C8",
			name = "Nota fiscal de peças agrícolas",
			text = "Compra de lona de caminhão, feltro, tinta preta e dois faróis auxiliares. Pago em dinheiro, retirado na sexta.",
			detail = "O comprador assinou: O. FERRAGEM (nome do celeiro).",
			reveals = "O figurino foi montado no celeiro do Seu Otávio.",
		},
		{
			id = "EP05_C9",
			name = "Gravador com voz modificada — lote 5/6",
			text = "'ÚLTIMO LOTE ANTES DO GRANDE FINAL. FAÇA O CAVALEIRO PARECER ANTIGO. EU QUERO O ORIGINAL DE 1987 NA MINHA COLEÇÃO.'",
			detail = "O cliente está colecionando uma lenda específica — e exige 'autenticidade'.",
			reveals = "O objetivo final é o próprio colecionador: ele vai expor os seis sustos.",
		},
	},
	deductions = {
		{
			id = "EP05_D2",
			question = "Quem tem oficina, trator e motivo para impedir a rodovia?",
			options = {
				{
					text = "Seu Otávio, dono do celeiro onde o figurino foi montado.",
					correct = true,
					feedback = "Fred: 'Feltro, lona, tinta e ferramenta agrícola. Tudo isso existe em um só lugar: o celeiro dele.'",
				},
				{
					text = "Zulmira, a mecânica.",
					correct = false,
					feedback = "Daphne: 'A Zulmira foi a primeira a nos entregar as notas. Quem esconde não entrega.'",
				},
				{
					text = "Rita, a jornalista.",
					correct = false,
					feedback = "Velma: 'Rita chegou aqui dois dias antes de nós, com credencial e tudo.'",
				},
			},
			logic = "Recursos materiais + motivo econômico + acesso ao local = suspeito principal.",
			points = 160,
		},
	},
	trapSpots = {
		{
			id = "Estrada_TrapA",
			label = "Curva do KM 13 (cabo de guincho + lona)",
			room = "Estrada_Curva",
			needsParts = 3,
		},
		{ id = "Estrada_TrapB", label = "Ponte de madeira (cordas + tábuas)", room = "Estrada_Ponte", needsParts = 3 },
	},
	reveal = { unmaskedNpc = "EP05_Fazendeiro", dialogue = "EP05_Reveal" },
	npcs = { "EP05_Fazendeiro", "EP05_Motorista", "EP05_Jornalista" },
	rewards = { points = 880, snacks = 3 },
	nextChapter = "EP05_C3",
}

Episodes.Chapters.EP05_C3 = {
	id = "EP05_C3",
	episode = "EP05",
	index = 3,
	name = "Capítulo 3 — Guincho na Curva",
	phase = "armadilha",
	location = "EstradaEP5",
	mood = "EP05_Estrada",
	timeLimit = 900,
	brief = "O cavaleiro só corre na curva do KM 13, onde a neblina é mais fechada. "
		.. "Guincho, lona e tábuas da ponte: monta-se a armadilha onde a estrada estreita.",
	intro = {
		title = "Guincho na Curva",
		subtitle = "Episódio 5 · Capítulo 3 de 4",
		narrator = "Fred",
		slides = {
			{
				speaker = "Fred",
				text = "Cabo de guincho atravessado na curva. Ele vem correndo, o cavalo tropeça, e cai a cabeça... quer dizer, a abóbora.",
				emote = "excited",
			},
			{
				speaker = "Salsicha",
				text = "Tipo assim, essa é a primeira vez que eu gosto de um plano seu, Fred.",
				emote = "happy",
			},
			{ speaker = "Scooby", text = "Re rois! Re rois rão ronseguir!", emote = "excited" },
		},
	},
	objectives = {
		{
			id = "EP05_C3_OB1",
			kind = "trap_part",
			label = "Pegue o cabo de guincho na oficina de Zulmira",
			clue = "EP05_PART1",
			marker = "Estrada_Guincho",
			points = 60,
		},
		{
			id = "EP05_C3_OB2",
			kind = "trap_part",
			label = "Pegue a lona de caminhão na lanchonete",
			clue = "EP05_PART2",
			marker = "Estrada_Lona",
			points = 60,
		},
		{
			id = "EP05_C3_OB3",
			kind = "trap_part",
			label = "Pegue as tábuas da ponte velha",
			clue = "EP05_PART3",
			marker = "Estrada_Tabuas",
			points = 60,
		},
		{
			id = "EP05_C3_OB4",
			kind = "build_trap",
			label = "Monte a armadilha de guincho na curva do KM 13",
			marker = "Estrada_TrapA",
			points = 170,
		},
		{
			id = "EP05_C3_OB5",
			kind = "bait_trap",
			label = "Acenda dois faróis auxiliares como isca",
			marker = "Estrada_TrapA",
			points = 100,
		},
		{
			id = "EP05_C3_OB6",
			kind = "defend",
			label = "Mantenha os faróis ligados por 60 segundos na neblina",
			seconds = 60,
			points = 150,
		},
	},
	clues = {
		{
			id = "EP05_C10",
			name = "Segundo controle remoto, sem dono",
			text = "Um segundo controle, idêntico, é encontrado na caixa de correio do posto. Alguém devolveu — ou perdeu — o controle reserva.",
			detail = "O modelo é de rádio-controle de brinquedo, mas com alcance estendido.",
			reveals = "Não é um operador só: existe um parceiro que ajuda a sabotar os motores.",
		},
	},
	deductions = {
		{
			id = "EP05_D3",
			question = "Como o cavaleiro aparece sempre no exato momento em que um carro para?",
			options = {
				{
					text = "Porque o comparsa avisa por rádio quando o motor morre.",
					correct = true,
					feedback = "Velma: 'O controle remoto tem dois canais de rádio. Um para o cavalo, outro para o comparsa!'",
				},
				{
					text = "Porque ele adivinha.",
					correct = false,
					feedback = "Salsicha: 'Tipo assim, se adivinhasse, ele adivinhava que eu ia correr.'",
				},
				{
					text = "Porque o cavalo é rápido.",
					correct = false,
					feedback = "Fred: 'Trator não é rápido. Nunca.'",
				},
			},
			logic = "Duas pessoas, dois rádios: um executa o susto, o outro prepara a cena.",
			points = 160,
		},
	},
	trapSpots = {
		{
			id = "Estrada_TrapA",
			label = "Curva do KM 13 (cabo de guincho + lona)",
			room = "Estrada_Curva",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "A neblina fecha de repente. Um galope pesado vem do norte, reto para a curva.",
		sfx = "ChaseMusic",
	},
	reveal = { unmaskedNpc = "EP05_Fazendeiro", dialogue = "EP05_Reveal" },
	npcs = { "EP05_Mecanico" },
	rewards = { points = 940, snacks = 4 },
	nextChapter = "EP05_C4",
}

Episodes.Chapters.EP05_C4 = {
	id = "EP05_C4",
	episode = "EP05",
	index = 4,
	name = "Capítulo 4 — Quem Perdeu a Cabeça",
	phase = "revelacao",
	location = "EstradaEP5",
	mood = "EP05_Estrada",
	timeLimit = 720,
	brief = "O cavalo de feltro está caído no meio da pista e a abóbora rolou para o acostamento. "
		.. "Falta só tirar a armadura — e entender quem financiou essa lenda.",
	intro = {
		title = "Quem Perdeu a Cabeça",
		subtitle = "Episódio 5 · Capítulo 4 de 4",
		narrator = "Shaggy",
		slides = {
			{
				speaker = "Shaggy",
				text = "A cabeça caiu! Tipo assim, a cabeça CAIU! Eu vou ter pesadelo com isso por um ano!",
				emote = "scared",
			},
			{
				speaker = "Daphne",
				text = "Olha o bolso da armadura: uma carta com selo vermelho. Outro 'C²'.",
				emote = "thinking",
			},
			{
				speaker = "Velma",
				text = "Cinco lotes. Cinco cidades. E o sexto... o sexto é a nossa.",
				emote = "worried",
			},
		},
	},
	objectives = {
		{
			id = "EP05_C4_OB1",
			kind = "capture",
			label = "Prenda o Cavaleiro Sem Cabeça no KM 13",
			marker = "Estrada_TrapA",
			points = 220,
		},
		{
			id = "EP05_C4_OB2",
			kind = "unmask",
			label = "Tire a armadura e a abóbora iluminada",
			marker = "Estrada_TrapA",
			points = 160,
		},
		{
			id = "EP05_C4_OB3",
			kind = "talk",
			label = "Escute Seu Otávio e o comparsa no acostamento",
			npc = "EP05_Fazendeiro",
			points = 90,
		},
		{
			id = "EP05_C4_OB4",
			kind = "reach",
			label = "Volte à Mystery Machine com a fita do lote 5",
			marker = "Estrada_Saida",
			points = 60,
		},
	},
	clues = {
		{
			id = "EP05_C11",
			name = "Quinta fita — convite para o leilão",
			text = "'PARABÉNS PELA ESTRÉIA NA COLEÇÃO. O LOTE FINAL SERÁ NA MANSÃO BLACKWOOD. TRAJE A RIGOR. — C²'",
			detail = "A fita não é mais uma ordem: é um convite. O cliente quer a turma presente no final.",
			reveals = "O sexto caso é pessoal: o Colecionador quer o Mistério S.A. como última peça.",
		},
	},
	deductions = {
		{
			id = "EP05_D4",
			question = "Por que o Colecionador convida a turma em vez de esconder o endereço?",
			options = {
				{
					text = "Porque a coleção não vale nada sem alguém capaz de desmontar os truques.",
					correct = true,
					feedback = "Daphne: 'Ele não quer só os monstros. Ele quer a plateia que entende o truque.'",
				},
				{
					text = "Porque ele é descuidado.",
					correct = false,
					feedback = "Velma: 'Descuidado não compra seis cidades em segredo por meses.'",
				},
				{
					text = "Porque ele quer ajuda para montar o susto.",
					correct = false,
					feedback = "Fred: 'Ele já tem os artistas dele. O que ele quer é o público.'",
				},
			},
			logic = "Vaidade de colecionador: um acervo precisa de especialistas para reconhecê-lo.",
			points = 170,
		},
	},
	trapSpots = {
		{
			id = "Estrada_TrapA",
			label = "Curva do KM 13 (cabo de guincho + lona)",
			room = "Estrada_Curva",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "O trator-cavalo dá a última arrancada, com a abóbora acesa balançando no gancho.",
		sfx = "ChaseMusic",
	},
	reveal = { unmaskedNpc = "EP05_Fazendeiro", dialogue = "EP05_Reveal" },
	npcs = { "EP05_Fazendeiro", "EP05_Mecanico", "EP05_Jornalista" },
	rewards = { points = 1200, snacks = 6 },
	nextChapter = nil,
	episodeEnd = true,
}

-- ==========================================================
-- EPISÓDIO 6 — A MALDIÇÃO DE BLACKWOOD
-- ==========================================================
Episodes.List.EP06 = {
	id = "EP06",
	number = 6,
	title = "A Maldição de Blackwood",
	subtitle = "Mansão Blackwood — colina de Coolsville",
	color = "DeepPurple",
	unlock = "EP05",
	location = "MansaoEP6",
	mood = "EP06_Mansao",
	monsterId = "EP06_Fantasma",
	tagline = "A Dama de Preto do espelho do salão não é a primeira — mas vai ser a última.",
	synopsis = "A Mansão Blackwood virou museu particular do último herdeiro. Nas últimas semanas, "
		.. "visitantes viram uma dama de véu nos espelhos e um elevador de carga que sobe sem ordem. "
		.. "Além disso, uma pintura 'A Dama de Preto' mudou de lugar três vezes em uma noite. "
		.. "A turma sobe a colina sabendo que o sexto lote é deles — e que o cliente vai estar esperando.",
	acts = {
		"Os espelhos da galeria estão forrados com lençóis — menos um, sempre o mesmo.",
		"O curador que 'descobriu' a maldição, a restauradora que achou uma pintura embaixo da outra e o zelador que conhece os túneis.",
		"O elevador de carga liga o túnel ao porão: por ali passa o vulto, e por ali passa a coleção.",
		"A armadilha dos túneis fecha o ciclo, e Anselmo Blackwood é preso — mas o Colecionador já estava dentro de casa.",
	},
	npcs = { "EP06_Advogado", "EP06_Curador", "EP06_Restauradora", "EP06_Fotografo", "EP06_Zelador" },
	chapters = { "EP06_C1", "EP06_C2", "EP06_C3", "EP06_C4" },
}

Episodes.Chapters.EP06_C1 = {
	id = "EP06_C1",
	episode = "EP06",
	index = 1,
	name = "Capítulo 1 — A Dama Que Muda de Lugar",
	phase = "investigacao",
	location = "MansaoEP6",
	mood = "EP06_Mansao",
	timeLimit = 900,
	brief = "Todo espelho da galeria está coberto com um lençol — menos um. "
		.. "E a pintura 'A Dama de Preto' está no lugar errado da parede, com poeira nova em volta.",
	intro = {
		title = "A Dama Que Muda de Lugar",
		subtitle = "Episódio 6 · Capítulo 1 de 4",
		narrator = "Daphne",
		slides = {
			{
				speaker = "Daphne",
				text = "Lençol em todos os espelhos. Isso não é decoração: alguém tem medo de uma coisa específica.",
				emote = "thinking",
			},
			{
				speaker = "Velma",
				text = "A poeira embaixo do quadro está desenhada na diagonal. A pintura foi arrastada, não carregada.",
				emote = "thinking",
			},
			{
				speaker = "Salsicha",
				text = "Tipo assim, museu de assombração. Tem lojinha? Porque eu preciso de um amuleto.",
				emote = "scared",
			},
			{ speaker = "Scooby", text = "Ran ran! Respelho! Rão roldem re olhar rer ro eu!", emote = "scared" },
		},
	},
	objectives = {
		{
			id = "EP06_C1_OB1",
			kind = "talk",
			label = "Fale com o Curador Anselmo na galeria",
			npc = "EP06_Curador",
			points = 80,
		},
		{
			id = "EP06_C1_OB2",
			kind = "clue",
			label = "Examine a pintura 'A Dama de Preto' fora do lugar",
			clue = "EP06_C1",
			marker = "Mansao_Quadro",
			points = 90,
		},
		{
			id = "EP06_C1_OB3",
			kind = "clue",
			label = "Levante o lençol do espelho grande e veja as marcas",
			clue = "EP06_C2",
			marker = "Mansao_Espelho",
			points = 90,
		},
		{
			id = "EP06_C1_OB4",
			kind = "search",
			label = "Reviste o ateliê de restauro",
			clue = "EP06_C3",
			marker = "Mansao_Atelie",
			points = 90,
		},
		{
			id = "EP06_C1_OB5",
			kind = "clue",
			label = "Encontre o livro-razão do museu na biblioteca",
			clue = "EP06_C4",
			marker = "Mansao_Biblioteca",
			points = 90,
		},
		{
			id = "EP06_C1_OB6",
			kind = "deduce",
			label = "Dedução 1: para que serve o espelho forrado?",
			deduction = "EP06_D1",
			points = 160,
		},
	},
	clues = {
		{
			id = "EP06_C1",
			name = "Poeira arrastada e um parafuso novo",
			text = "O quadro tem dois parafusos antigos, enferrujados, e um novo, brilhando. A moldura foi reaberta recentemente.",
			detail = "Quem maneja uma peça de museu sem luva deixa marca de dedo no verniz.",
			reveals = "A pintura é usada como esconderijo — não como obra de arte.",
		},
		{
			id = "EP06_C2",
			name = "Espelho com fita crepe no chão",
			text = "O espelho grande tem marca de fita no piso, indicando a posição exata. O vidro não é original — é uma película refletiva nova.",
			detail = "Película refletiva é o truque de palco mais antigo para criar fantasmas.",
			reveals = "O espelho foi preparado para projetar uma imagem. É uma tela, não um reflexo.",
		},
		{
			id = "EP06_C3",
			name = "Solvente e pincel com tinta preta",
			text = "No ateliê, um pincel com tinta preta ainda úmida e um frasco de solvente aberto. As luvas de restauro estão limpas demais.",
			detail = "A restauradora trabalha com tons de verniz, não com preto puro.",
			reveals = "Alguém está pintando o vulto à mão, por cima de tecido, para as aparições noturnas.",
		},
		{
			id = "EP06_C4",
			name = "Livro-razão: peças 'emprestadas'",
			text = "O livro-razão registra saídas de peças para 'exposição externa' — todas sem assinatura de retirada, todas nas noites dos avistamentos.",
			detail = "Nenhuma das peças saiu do país. Elas saíram da mansão por um túnel.",
			reveals = "O museu está sendo esvaziado pelas noites, por baixo dos visitantes.",
		},
	},
	deductions = {
		{
			id = "EP06_D1",
			question = "Por que cobrir todos os espelhos, menos um?",
			options = {
				{
					text = "Porque o único descoberto é o que precisa refletir a imagem do fantasma — é um truque de palco.",
					correct = true,
					feedback = "Velma: 'Película refletiva + luz baixa + vulto atrás = aparição. É física, não maldição!'",
				},
				{
					text = "Porque os funcionários são supersticiosos.",
					correct = false,
					feedback = "Daphne: 'Superstição não deixa fita crepe no chão marcando posição.'",
				},
				{
					text = "Porque o espelho é mais bonito.",
					correct = false,
					feedback = "Fred: 'Se fosse por beleza, não teriam coberto todos os outros.'",
				},
			},
			logic = "Aparência de maldição + preparação técnica = alguém montou a cena e protegeu o equipamento.",
			points = 160,
		},
	},
	trapSpots = {
		{
			id = "Mansao_TrapA",
			label = "Elevador de carga dos túneis (contrapeso + corrente)",
			room = "Mansao_Tuneis",
			needsParts = 3,
		},
		{
			id = "Mansao_TrapB",
			label = "Salão de espelhos (lençol + cabos)",
			room = "Mansao_Galeria",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "afterObjective",
		objective = "EP06_C1_OB3",
		text = "O lençol escorrega sozinho do espelho. Por um segundo, tem alguém atrás de vocês — só no reflexo.",
		sfx = "GhostMoan",
	},
	reveal = { unmaskedNpc = "EP06_Curador", dialogue = "EP06_Reveal" },
	npcs = { "EP06_Advogado", "EP06_Curador", "EP06_Restauradora", "EP06_Fotografo" },
	rewards = { points = 900, snacks = 4 },
	nextChapter = "EP06_C2",
}

Episodes.Chapters.EP06_C2 = {
	id = "EP06_C2",
	episode = "EP06",
	index = 2,
	name = "Capítulo 2 — Herança, Tinta e Renda",
	phase = "suspeitos",
	location = "MansaoEP6",
	mood = "EP06_Mansao",
	timeLimit = 900,
	brief = "O advogado quer vender. O curador quer manter o museu fechado. A restauradora achou uma pintura embaixo da outra. "
		.. "E o fotógrafo tem o negativo da noite do fantasma.",
	intro = {
		title = "Herança, Tinta e Renda",
		subtitle = "Episódio 6 · Capítulo 2 de 4",
		narrator = "Fred",
		slides = {
			{
				speaker = "Fred",
				text = "Cuidado, pessoal. Esse caso é nosso. O convite veio com o nosso nome.",
				emote = "worried",
			},
			{
				speaker = "Velma",
				text = "E é o único caso em que o suspeito principal é também o anfitrião. Isso é... estatisticamente ruim.",
				emote = "thinking",
			},
		},
	},
	objectives = {
		{
			id = "EP06_C2_OB1",
			kind = "talk",
			label = "Ouça o advogado Peixoto na biblioteca",
			npc = "EP06_Advogado",
			clue = "EP06_C5",
			points = 80,
		},
		{
			id = "EP06_C2_OB2",
			kind = "talk",
			label = "Converse com Nina, a restauradora, no ateliê",
			npc = "EP06_Restauradora",
			clue = "EP06_C6",
			points = 90,
		},
		{
			id = "EP06_C2_OB3",
			kind = "talk",
			label = "Revele o negativo com Hal, o fotógrafo, no salão",
			npc = "EP06_Fotografo",
			clue = "EP06_C7",
			points = 90,
		},
		{
			id = "EP06_C2_OB4",
			kind = "talk",
			label = "Peça a Aníbal a planta dos túneis na cozinha",
			npc = "EP06_Zelador",
			clue = "EP06_C8",
			points = 100,
		},
		{
			id = "EP06_C2_OB5",
			kind = "clue",
			label = "Ache a segunda pintura embaixo da primeira",
			clue = "EP06_C9",
			marker = "Mansao_Atelie_Fundo",
			points = 100,
		},
		{
			id = "EP06_C2_OB6",
			kind = "deduce",
			label = "Dedução 2: quem tem acesso ao túnel e à coleção?",
			deduction = "EP06_D2",
			points = 170,
		},
		{
			id = "EP06_C2_OB7",
			kind = "survive",
			label = "Sobreviva à perseguição nos túneis por 75 segundos",
			seconds = 75,
			points = 140,
			optional = true,
		},
	},
	clues = {
		{
			id = "EP06_C5",
			name = "Testamento com cláusula de 'maldição'",
			text = "O testamento dos Blackwood diz: 'A casa não pode ser vendida enquanto a Dama de Preto for vista.' A cláusula foi escrita há 60 anos.",
			detail = "Quem invoca a maldição impede a venda — exatamente o que o curador quer.",
			reveals = "A maldição tem função jurídica: bloqueia a venda da mansão.",
		},
		{
			id = "EP06_C6",
			name = "Pintura embaixo da pintura",
			text = "Uma segunda tela embaixo da 'Dama de Preto': o retrato de um homem com um selo 'C²' gravado no anel.",
			detail = "A pintura original foi substituída por outra, feita recentemente.",
			reveals = "O selo C² aparece na própria mansão — o Colecionador já esteve aqui, e não é de hoje.",
		},
		{
			id = "EP06_C7",
			name = "Negativo da noite do fantasma",
			text = "No negativo, a 'Dama de Preto' está diante do espelho — e o reflexo mostra o elevador de carga aberto.",
			detail = "O reflexo denuncia o truque: o vulto é uma silhueta pintada, e o ator vem pelo elevador.",
			reveals = "O vulto entra pelos túneis, sobe no elevador de carga e aparece no espelho preparado.",
		},
		{
			id = "EP06_C8",
			name = "Planta dos túneis com um ciclo",
			text = "Os túneis formam um circuito. Há três saídas e uma câmara no centro, sem ventilação adequada. A câmara está com porta nova.",
			detail = "Porta nova em um túnel de 150 anos significa uso recente e frequente.",
			reveals = "A câmara central guarda a coleção do Colecionador.",
		},
	},
	deductions = {
		{
			id = "EP06_D2",
			question = "Quem tem chave, mapa e tempo para usar os túneis nas noites dos avistamentos?",
			options = {
				{
					text = "O curador Anselmo, que mora na casa e conhece cada porta.",
					correct = true,
					feedback = "Daphne: 'E ele foi o único que não se assustou quando a dama apareceu na nossa frente.'",
				},
				{
					text = "O zelador, que conhece os túneis melhor.",
					correct = false,
					feedback = "Velma: 'O Aníbal entregou a planta por conta própria. Quem esconde, não entrega.'",
				},
				{
					text = "A restauradora, que trabalha com tinta preta.",
					correct = false,
					feedback = "Fred: 'Ela tem acesso à tinta, mas não tem a chave do elevador de carga.'",
				},
			},
			logic = "Chave + moradia + conhecimento + ausência de medo = o anfitrião.",
			points = 170,
		},
	},
	trapSpots = {
		{
			id = "Mansao_TrapA",
			label = "Elevador de carga dos túneis (contrapeso + corrente)",
			room = "Mansao_Tuneis",
			needsParts = 3,
		},
		{
			id = "Mansao_TrapB",
			label = "Salão de espelhos (lençol + cabos)",
			room = "Mansao_Galeria",
			needsParts = 3,
		},
	},
	reveal = { unmaskedNpc = "EP06_Curador", dialogue = "EP06_Reveal" },
	npcs = { "EP06_Advogado", "EP06_Restauradora", "EP06_Fotografo", "EP06_Zelador" },
	rewards = { points = 980, snacks = 4 },
	nextChapter = "EP06_C3",
}

Episodes.Chapters.EP06_C3 = {
	id = "EP06_C3",
	episode = "EP06",
	index = 3,
	name = "Capítulo 3 — O Ciclo dos Túneis",
	phase = "armadilha",
	location = "MansaoEP6",
	mood = "EP06_Mansao",
	timeLimit = 900,
	brief = "Os túneis são um circuito fechado: o vulto entra, sobe no elevador e volta sempre pelo mesmo caminho. "
		.. "Tranque o ciclo com corrente, contrapeso e um lençol — sim, um lençol.",
	intro = {
		title = "O Ciclo dos Túneis",
		subtitle = "Episódio 6 · Capítulo 3 de 4",
		narrator = "Velma",
		slides = {
			{
				speaker = "Velma",
				text = "Circuito fechado é o plano perfeito para uma armadilha. Ele não vai ter para onde fugir.",
				emote = "thinking",
			},
			{
				speaker = "Fred",
				text = "Prendemos o contrapeso do elevador, esticamos a corrente e a rede de lençóis fecha o corredor!",
				emote = "excited",
			},
			{ speaker = "Scooby", text = "Ralhar o relvador! ...Ru risse ragora?", emote = "happy" },
		},
	},
	objectives = {
		{
			id = "EP06_C3_OB1",
			kind = "trap_part",
			label = "Pegue a corrente do portão da mansão",
			clue = "EP06_PART1",
			marker = "Mansao_Corrente",
			points = 70,
		},
		{
			id = "EP06_C3_OB2",
			kind = "trap_part",
			label = "Pegue o contrapeso do elevador de carga",
			clue = "EP06_PART2",
			marker = "Mansao_Contrapeso",
			points = 70,
		},
		{
			id = "EP06_C3_OB3",
			kind = "trap_part",
			label = "Pegue os lençóis de forro da galeria",
			clue = "EP06_PART3",
			marker = "Mansao_Lencois",
			points = 70,
		},
		{
			id = "EP06_C3_OB4",
			kind = "build_trap",
			label = "Monte a armadilha dos túneis no elevador de carga",
			marker = "Mansao_TrapA",
			points = 180,
		},
		{
			id = "EP06_C3_OB5",
			kind = "bait_trap",
			label = "Reponha o quadro 'Dama de Preto' como isca",
			marker = "Mansao_TrapA",
			points = 110,
		},
		{
			id = "EP06_C3_OB6",
			kind = "defend",
			label = "Proteja a câmara central por 70 segundos",
			seconds = 70,
			points = 160,
		},
	},
	clues = {
		{
			id = "EP06_C10",
			name = "Câmara central: uma coleção catalogada",
			text = "Prateleiras com seis caixas etiquetadas: FAROL, HOTEL, CIRCO, FÁBRICA, ESTRADA — e uma vazia: BLACKWOOD. A caixa vazia tem um laço dourado.",
			detail = "A sexta caixa espera o susto da mansão. E há espaço para uma sétima.",
			reveals = "O Colecionador cataloga os sustos. Ele já escolheu a próxima cidade: Coolsville.",
		},
	},
	deductions = {
		{
			id = "EP06_D3",
			question = "Por que a caixa de Blackwood é a única com laço dourado?",
			options = {
				{
					text = "Porque é a peça principal da coleção — o caso em que o Mistério S.A. participa.",
					correct = true,
					feedback = "Daphne: 'Ele embrulhou o nosso caso. A gente é o presente.'",
				},
				{
					text = "Porque é a mais caro.",
					correct = false,
					feedback = "Velma: 'O valor está no cenário, não na caixa.'",
				},
				{
					text = "Porque o curador pediu.",
					correct = false,
					feedback = "Fred: 'O curador é um funcionário dessa coleção, não o dono.'",
				},
			},
			logic = "As caixas são o acervo. A com laço é a última peça — e o Mistério S.A. faz parte dela.",
			points = 180,
		},
	},
	trapSpots = {
		{
			id = "Mansao_TrapA",
			label = "Elevador de carga dos túneis (contrapeso + corrente)",
			room = "Mansao_Tuneis",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "A dama desce dos túneis. Desta vez ela não está no espelho — está entre vocês.",
		sfx = "ChaseMusic",
	},
	reveal = { unmaskedNpc = "EP06_Curador", dialogue = "EP06_Reveal" },
	npcs = { "EP06_Zelador" },
	rewards = { points = 1050, snacks = 5 },
	nextChapter = "EP06_C4",
}

Episodes.Chapters.EP06_C4 = {
	id = "EP06_C4",
	episode = "EP06",
	index = 4,
	name = "Capítulo 4 — O Colecionador Espera",
	phase = "revelacao",
	location = "MansaoEP6",
	mood = "EP06_Mansao",
	timeLimit = 720,
	brief = "Anselmo está preso no elevador de carga. Mas a caixa com laço dourado já não está na câmara — "
		.. "e um bilhete com selo C² diz: 'OBRIGADO PELO ESPETÁCULO. ATÉ COOLSVILLE.'",
	intro = {
		title = "O Colecionador Espera",
		subtitle = "Episódio 6 · Capítulo 4 de 4",
		narrator = "Daphne",
		slides = {
			{ speaker = "Fred", text = "Conseguimos! A dama está presa!", emote = "excited" },
			{
				speaker = "Velma",
				text = "Esperem... a caixa com o laço não está mais aqui. E a poeira na prateleira está fresca.",
				emote = "worried",
			},
			{ speaker = "Scooby", text = "RUH-ROH! Ralguém reve ra rosta!", emote = "scared" },
		},
	},
	objectives = {
		{
			id = "EP06_C4_OB1",
			kind = "capture",
			label = "Prenda a Dama de Preto no elevador de carga",
			marker = "Mansao_TrapA",
			points = 240,
		},
		{ id = "EP06_C4_OB2", kind = "unmask", label = "Tire o véu de renda", marker = "Mansao_TrapA", points = 170 },
		{
			id = "EP06_C4_OB3",
			kind = "talk",
			label = "Ouça a confissão de Anselmo Blackwood",
			npc = "EP06_Curador",
			points = 100,
		},
		{
			id = "EP06_C4_OB4",
			kind = "search",
			label = "Persiga a sombra do Colecionador pelo corredor leste",
			marker = "Mansao_Corredor_Leste",
			points = 150,
			optional = true,
		},
		{
			id = "EP06_C4_OB5",
			kind = "reach",
			label = "Volte àMystery Machine e prepare-se para o final",
			marker = "Mansao_Saida",
			points = 80,
		},
	},
	clues = {
		{
			id = "EP06_C11",
			name = "Sexta fita — o convite final",
			text = "'SEIS LOTES, SEIS SUSTOS, UMA COLEÇÃO. FALTA O GRANDE FINAL: A CIDADE QUE INVENTOU A PALAVRA MISTÉRIO. COOLSVILLE, PENHASCO, MEIA-NOITE. — C²'",
			detail = "O papel da fita tem marca d'água de um jornal de Coolsville.",
			reveals = "O Colecionador tem ligação com um jornal local — e com a história da própria turma.",
		},
	},
	deductions = {
		{
			id = "EP06_D4",
			question = "Por que Coolsville? Por que a cidade da turma?",
			options = {
				{
					text = "Porque o acervo precisa da origem: o Mistério S.A. começou ali.",
					correct = true,
					feedback = "Velma: 'Ele não está colecionando monstros. Está colecionando as pessoas que resolvem mistérios.'",
				},
				{
					text = "Porque a cidade é barata.",
					correct = false,
					feedback = "Salsicha: 'Coolsville não é barata. Aluguel lá é caro!'",
				},
				{
					text = "Porque ele mora lá.",
					correct = false,
					feedback = "Daphne: 'Se ele morasse, teria se apresentado quando a gente era criança.'",
				},
			},
			logic = "Um colecionador busca a peça inaugural. Coolsville é onde o Mistério S.A. nasceu.",
			points = 190,
		},
	},
	trapSpots = {
		{
			id = "Mansao_TrapA",
			label = "Elevador de carga dos túneis (contrapeso + corrente)",
			room = "Mansao_Tuneis",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "A Dama de Preto avança pelos túneis com a pressa de quem sabe que o tempo dela acabou.",
		sfx = "ChaseMusic",
	},
	reveal = { unmaskedNpc = "EP06_Curador", dialogue = "EP06_Reveal" },
	npcs = { "EP06_Curador", "EP06_Zelador", "EP06_Advogado" },
	rewards = { points = 1500, snacks = 8, achievement = "craque_de_coolsville" },
	nextChapter = "FINAL_C1",
	episodeEnd = true,
}

-- ==========================================================
-- ARCO FINAL — O COLECIONADOR (2 capítulos + desfecho)
-- ==========================================================
Episodes.List.FINAL = {
	id = "FINAL",
	number = 7,
	title = "O Colecionador",
	subtitle = "Penhasco de Coolsville — meia-noite",
	color = "Gold",
	unlock = "EP06",
	location = "PenhascoFinal",
	mood = "EP06_Mansao",
	monsterId = "EP07_Colecionador",
	tagline = "Seis lotes, seis sustos, uma coleção. A última peça é a cidade que inventou o mistério.",
	synopsis = "A Mystery Machine sobe o penhasco de Coolsville com as seis fitas no porta-luvas. "
		.. "No armazém antigo da estrada, o Colecionador montou uma exposição particular com os seis "
		.. "figurinos dos casos resolvidos — todos acesos, todos em seus cenários, todos esperando. "
		.. "Ele não quer dinheiro. Quer que a turma veja a coleção completa. E quer ficar com a última peça: eles.",
	acts = {
		"O armazém tem seis cenários montados, um para cada caso — e um sétimo espaço vazio.",
		"O Colecionador usou todos os vilões como funcionários: cada um recebeu fitas, dinheiro e ordens.",
		"A turma desliga os seis cenários, um a um, usando o que aprendeu em cada capítulo.",
		"A armadilha final prende o Colecionador entre os próprios cenários — e a cidade inteira assiste à revelação.",
	},
	npcs = { "EP06_Zelador", "EP01_Keeper", "EP02_Gerente", "EP03_Dono", "EP04_Dona", "EP05_Jornalista" },
	chapters = { "FINAL_C1", "FINAL_C2", "FINAL_C3" },
}

Episodes.Chapters.FINAL_C1 = {
	id = "FINAL_C1",
	episode = "FINAL",
	index = 1,
	name = "Capítulo Final 1 — A Exposição",
	phase = "investigacao",
	location = "PenhascoFinal",
	mood = "EP06_Mansao",
	timeLimit = 1200,
	brief = "O armazém no penhasco está aberto. Lá dentro, seis cenários montados com os figurinos dos casos "
		.. "que vocês desmontaram. Um bilhete na entrada: 'POR FAVOR, NÃO TOQUE NAS PEÇAS'.",
	intro = {
		title = "A Exposição",
		subtitle = "Arco Final · Capítulo 1 de 3",
		narrator = "Fred",
		slides = {
			{
				speaker = "Fred",
				text = "Pessoal... isso aqui é o farol. Igualzinho. E ali é o hotel. Ele reconstruiu tudo.",
				emote = "worried",
			},
			{
				speaker = "Daphne",
				text = "Tem placa em cada cenário. 'LOTE 1 — FAROL DE PEDRA. ADQUIRIDO POR C².'",
				emote = "thinking",
			},
			{
				speaker = "Velma",
				text = "Jinkies. Ele não é um vilão contratando artistas. Ele é um curador contratando sustos.",
				emote = "thinking",
			},
			{
				speaker = "Salsicha",
				text = "Tipo assim, tem um sétimo espaço vazio e uma placa com o nosso nome. Eu NÃO quero ser peça de museu!",
				emote = "scared",
			},
		},
	},
	objectives = {
		{
			id = "FINAL_C1_OB1",
			kind = "search",
			label = "Leia o catálogo na mesa de entrada",
			clue = "FINAL_C1",
			marker = "Penhasco_Catalogo",
			points = 120,
		},
		{
			id = "FINAL_C1_OB2",
			kind = "clue",
			label = "Examine o cenário 1 (farol) e ache o gerador de névoa",
			clue = "FINAL_C2",
			marker = "Penhasco_Cenario1",
			points = 120,
		},
		{
			id = "FINAL_C1_OB3",
			kind = "clue",
			label = "Examine o cenário 3 (circo) e o alto-falante mestre",
			clue = "FINAL_C3",
			marker = "Penhasco_Cenario3",
			points = 120,
		},
		{
			id = "FINAL_C1_OB4",
			kind = "clue",
			label = "Examine o cenário 6 (mansão) e o espelho de palco",
			clue = "FINAL_C4",
			marker = "Penhasco_Cenario6",
			points = 120,
		},
		{
			id = "FINAL_C1_OB5",
			kind = "deduce",
			label = "Dedução: como desligar os seis cenários de uma vez?",
			deduction = "FINAL_D1",
			points = 200,
		},
		{
			id = "FINAL_C1_OB6",
			kind = "defend",
			label = "Resista à primeira investida do Colecionador",
			seconds = 60,
			points = 180,
		},
	},
	clues = {
		{
			id = "FINAL_C1",
			name = "Catálogo da coleção",
			text = "Um livro encadernado em couro, com seis fichas escritas à mão. Cada ficha tem o nome do episódio, "
				.. "o número do lote, o valor pago — e uma observação cruel: 'RESOLVIDO POR: MISTÉRIO S.A.'",
			detail = "Na última página, uma ficha em branco: 'LOTE 7 — ??? — VALOR: A DEFINIÇÃO DA PALAVRA MISTÉRIO'.",
			reveals = "O Colecionador paga para que um mistério seja criado, e anota quem o resolveu. A turma é parte do acervo.",
		},
		{
			id = "FINAL_C2",
			name = "Gerador de névoa do cenário 1",
			text = "Uma máquina de névoa de palco, com reservatório cheio e um timer para meia-noite. Todos os cenários têm o mesmo timer.",
			detail = "Todos vão ligar ao mesmo tempo — é um espetáculo programado.",
			reveals = "Existe um momento marcado: meia-noite. É quando o Colecionador quer a apresentação.",
		},
		{
			id = "FINAL_C3",
			name = "Alto-falante mestre do cenário 3",
			text = "Uma mesa de som conectada a seis cenários. Cada canal tem uma etiqueta: FAROL, HOTEL, CIRCO, FÁBRICA, ESTRADA, MANSÃO.",
			detail = "Os canais têm ganho independente. Um deles, o sétimo, está sem etiqueta e com o volume no máximo.",
			reveals = "O sétimo canal é o cenário da turma. Ele já está ligado.",
		},
		{
			id = "FINAL_C4",
			name = "Espelho de palco do cenário 6",
			text = "Um espelho grande com película refletiva, igual ao da mansão. Atrás dele, um trilho de câmera e um figurino vazio com o véu da Dama.",
			detail = "O figurino está limpo e sem poeira: foi usado há pouco tempo.",
			reveals = "O Colecionador usa os próprios figurinos. Ele não é só o patrão: ele é o sétimo artista.",
		},
	},
	deductions = {
		{
			id = "FINAL_D1",
			question = "Como desligar seis cenários de uma vez?",
			options = {
				{
					text = "Desligando a mesa de som mestre — todos os efeitos passam por ela.",
					correct = true,
					feedback = "Velma: 'Seis canais, uma mesa. Se a mesa cai, o espetáculo inteiro cai com ela!'",
				},
				{
					text = "Quebrando os figurinos um por um.",
					correct = false,
					feedback = "Fred: 'Sobreviventes dos outros casos já provaram que quebrar peça não resolve nada.'",
				},
				{
					text = "Chamando a polícia.",
					correct = false,
					feedback = "Daphne: 'A polícia chega em 20 minutos. Ele quer a apresentação em 5.'",
				},
			},
			logic = "Cenários compartilhados, controle único: a mesa de som é o coração da coleção.",
			points = 200,
		},
	},
	trapSpots = {
		{
			id = "Penhasco_TrapA",
			label = "Palco central (holofotes + contrapeso + seis cabos)",
			room = "Penhasco_Palco",
			needsParts = 3,
		},
		{
			id = "Penhasco_TrapB",
			label = "Saída do armazém (portão de carga)",
			room = "Penhasco_Portao",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "As luzes dos seis cenários acendem uma por uma. Uma voz amplificada: 'BEM-VINDOS À ÚLTIMA PEÇA DA COLEÇÃO.'",
		sfx = "UnmaskStinger",
	},
	reveal = { unmaskedNpc = nil, dialogue = "FINAL_Reveal" },
	npcs = {},
	rewards = { points = 1800, snacks = 10 },
	nextChapter = "FINAL_C2",
}

Episodes.Chapters.FINAL_C2 = {
	id = "FINAL_C2",
	episode = "FINAL",
	index = 2,
	name = "Capítulo Final 2 — Seis Cenários, Uma Mesa",
	phase = "armadilha",
	location = "PenhascoFinal",
	mood = "EP06_Mansao",
	timeLimit = 1200,
	brief = "A mesa de som está atrás do palco, protegida por seis cenários que voltaram à vida. "
		.. "Cada jogador precisa desativar um cenário usando a fraqueza que descobriu no capítulo correspondente.",
	intro = {
		title = "Seis Cenários, Uma Mesa",
		subtitle = "Arco Final · Capítulo 2 de 3",
		narrator = "Velma",
		slides = {
			{
				speaker = "Velma",
				text = "Seis cenários, seis fraquezas que a gente já conhece. Isso não é um ataque, é uma prova final.",
				emote = "thinking",
			},
			{
				speaker = "Fred",
				text = "Então vamos dividir: cada um pega o cenário que já derrotou. Eu começo pelo farol.",
				emote = "excited",
			},
			{ speaker = "Scooby", text = "Ru reho ro rirco! Ru rorei ro ralhaço! Rramalhado!", emote = "excited" },
		},
	},
	objectives = {
		{
			id = "FINAL_C2_OB1",
			kind = "trap_part",
			label = "Pegue os cabos mestres da mesa de som",
			clue = "FINAL_PART1",
			marker = "Penhasco_Cabos",
			points = 90,
		},
		{
			id = "FINAL_C2_OB2",
			kind = "trap_part",
			label = "Pegue o contrapeso do palco central",
			clue = "FINAL_PART2",
			marker = "Penhasco_Contrapeso",
			points = 90,
		},
		{
			id = "FINAL_C2_OB3",
			kind = "trap_part",
			label = "Pegue os holofotes quebrados do depósito",
			clue = "FINAL_PART3",
			marker = "Penhasco_Holofote",
			points = 90,
		},
		{
			id = "FINAL_C2_OB4",
			kind = "build_trap",
			label = "Monte a armadilha final no palco central",
			marker = "Penhasco_TrapA",
			points = 200,
		},
		{
			id = "FINAL_C2_OB5",
			kind = "bait_trap",
			label = "Atraia o Colecionador com a caixa vazia de Blackwood",
			marker = "Penhasco_TrapA",
			points = 150,
		},
		{
			id = "FINAL_C2_OB6",
			kind = "defend",
			label = "Mantenha os seis canais desligados por 90 segundos",
			seconds = 90,
			points = 250,
		},
	},
	clues = {
		{
			id = "FINAL_C5",
			name = "Ficha de pagamento dos seis artistas",
			text = "Seis recibos, mesma assinatura de aprovador: 'C²'. Cada artista recebeu fitas, dinheiro e uma cláusula: "
				.. "'O SUSTO SERÁ DESMONTADO POR PROFISSIONAIS. NÃO HAVERÁ VIOLÊNCIA.'",
			detail = "O Colecionador queria que os mistérios fossem resolvidos. Era parte do jogo.",
			reveals = "O plano nunca foi assustar a turma: era fazer a turma resolver, para que o acervo tivesse um selo de autenticidade.",
		},
	},
	deductions = {
		{
			id = "FINAL_D2",
			question = "Por que ele proíbe violência nos contratos?",
			options = {
				{
					text = "Porque peça danificada perde valor — e porque a coleção precisa continuar criando mistérios.",
					correct = true,
					feedback = "Daphne: 'Ele não é um criminoso violento. É pior: é um colecionador que quer a coleção viva.'",
				},
				{
					text = "Porque ele é gentil.",
					correct = false,
					feedback = "Salsicha: 'Gentil?! Ele colocou um robô de 3 metros atrás de mim!'",
				},
				{
					text = "Porque a polícia estava perto.",
					correct = false,
					feedback = "Velma: 'Em seis cidades, seis polícias diferentes? Não.'",
				},
			},
			logic = "A coleção só tem valor se continuar sendo alimentada com novos mistérios — e novos resolvedores.",
			points = 210,
		},
	},
	trapSpots = {
		{
			id = "Penhasco_TrapA",
			label = "Palco central (holofotes + contrapeso + seis cabos)",
			room = "Penhasco_Palco",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "O Colecionador desce pelo elevador de palco com o véu da Dama na mão. 'MOSTRE-ME O QUE APRENDERAM.'",
		sfx = "ChaseMusic",
	},
	reveal = { unmaskedNpc = nil, dialogue = "FINAL_Reveal" },
	npcs = {},
	rewards = { points = 2200, snacks = 12 },
	nextChapter = "FINAL_C3",
}

Episodes.Chapters.FINAL_C3 = {
	id = "FINAL_C3",
	episode = "FINAL",
	index = 3,
	name = "Capítulo Final 3 — Coolsville Meia-Noite",
	phase = "revelacao",
	location = "PenhascoFinal",
	mood = "Lobby",
	timeLimit = 900,
	brief = "Os seis cenários estão desligados, o sétimo está vazio e a cidade inteira subiu o penhasco atrás de vocês. "
		.. "Só falta uma coisa: tirar a máscara do último vilão — na frente de todos.",
	intro = {
		title = "Coolsville Meia-Noite",
		subtitle = "Arco Final · Capítulo 3 de 3",
		narrator = "Fred",
		slides = {
			{
				speaker = "Fred",
				text = "A mesa está morta e os seis cenários apagados. Ele não tem mais espetáculo.",
				emote = "excited",
			},
			{
				speaker = "Velma",
				text = "E olha quem subiu o penhasco: o jornal, a rádio... e a turma inteira de Coolsville.",
				emote = "happy",
			},
			{
				speaker = "Salsicha",
				text = "Tipo assim, agora eu quero MUITO ver quem está por baixo dessa máscara.",
				emote = "excited",
			},
			{ speaker = "Scooby", text = "Scooby-Dooby-DOOOO! Ru ru rerei rar a ráscara!", emote = "celebrate" },
		},
	},
	objectives = {
		{
			id = "FINAL_C3_OB1",
			kind = "capture",
			label = "Prenda o Colecionador no palco central",
			marker = "Penhasco_TrapA",
			points = 300,
		},
		{
			id = "FINAL_C3_OB2",
			kind = "unmask",
			label = "Tire a máscara de porcelana na frente da cidade",
			marker = "Penhasco_TrapA",
			points = 250,
		},
		{
			id = "FINAL_C3_OB3",
			kind = "talk",
			label = "Ouça a confissão do Colecionador",
			npc = "EP06_Peixoto",
			points = 150,
			optional = true,
		},
		{
			id = "FINAL_C3_OB4",
			kind = "reach",
			label = "Volte para a Mystery Machine — e feche o arquivo",
			marker = "Penhasco_Saida",
			points = 200,
		},
	},
	clues = {
		{
			id = "FINAL_C6",
			name = "A sétima ficha, escrita na hora",
			text = "No catálogo, a ficha do lote 7 não está mais em branco. A letra é tremida, escrita com pressa: "
				.. "'LOTE 7 — COOLSVILLE — RESOLVIDO POR: MISTÉRIO S.A. — VALOR: NÃO ESTIMADO.'",
			detail = "A última linha é diferente: 'NÃO ESTIMADO' — porque um mistério resolvido por amigos vale mais que qualquer peça.",
			reveals = "O Colecionador perdeu a coleção, mas ganhou a única coisa que nunca conseguiu catalogar.",
		},
	},
	deductions = {
		{
			id = "FINAL_D3",
			question = "Quem é o Colecionador, depois de tudo isso?",
			options = {
				{
					text = "Alguém que passou a vida colecionando sustos porque nunca teve uma turma para dividir o medo.",
					correct = true,
					feedback = "Daphne: 'Ele colecionava medo porque ninguém ficava para ver o final com ele.'",
				},
				{
					text = "Um milionário entediado.",
					correct = false,
					feedback = "Fred: 'Ele pagava em espécie e dormia em armazém. Não é tédio.'",
				},
				{
					text = "Um fantasma de verdade.",
					correct = false,
					feedback = "Velma: 'Fantasma não assina contrato de trabalho.'",
				},
			},
			logic = "O mistério nunca foi o dinheiro: era a solidão de um colecionador sem plateia.",
			points = 250,
		},
	},
	trapSpots = {
		{
			id = "Penhasco_TrapA",
			label = "Palco central (holofotes + contrapeso + seis cabos)",
			room = "Penhasco_Palco",
			needsParts = 3,
		},
	},
	monsterIntro = {
		trigger = "onStart",
		text = "'ISSO NÃO É O FINAL! UM MISTÉRIO NUNCA ACABA!' — a voz vem de todos os alto-falantes ao mesmo tempo.",
		sfx = "ChaseMusic",
	},
	reveal = { unmaskedNpc = nil, dialogue = "FINAL_Reveal" },
	-- A multidão de Coolsville entra como figurantes (CutsceneService), não como NPCs fixos.
	npcs = {},
	rewards = { points = 5000, snacks = 30, achievement = "detetive_relampago" },
	nextChapter = nil,
	episodeEnd = true,
	seasonEnd = true,
}

-- ==========================================================
-- HELPERS
-- ==========================================================
function Episodes.getEpisode(id)
	return Episodes.List[id]
end

function Episodes.getChapter(id)
	return Episodes.Chapters[id]
end

function Episodes.chapterList(episodeId)
	local episode = Episodes.List[episodeId]
	if not episode then
		return {}
	end
	local list = {}
	for _, chapterId in ipairs(episode.chapters) do
		local chapter = Episodes.Chapters[chapterId]
		if chapter then
			table.insert(list, chapter)
		end
	end
	return list
end

function Episodes.allChapters()
	local list = {}
	for _, episodeId in ipairs(Episodes.Season.order) do
		for _, chapter in ipairs(Episodes.chapterList(episodeId)) do
			table.insert(list, chapter)
		end
	end
	return list
end

function Episodes.chapterCount()
	return #Episodes.allChapters()
end

-- Capítulos liberados para um jogador, dado o progresso salvo
function Episodes.availableFor(progress)
	local unlocked = {}
	progress = progress or {}
	local completed = progress.completedChapters or {}
	local episodesCompleted = progress.completedEpisodes or {}

	for _, episodeId in ipairs(Episodes.Season.order) do
		local episode = Episodes.List[episodeId]
		local requirement = episode.unlock
		local allowed = true
		if requirement then
			allowed = episodesCompleted[requirement] == true
		end
		if allowed then
			for _, chapterId in ipairs(episode.chapters) do
				local chapter = Episodes.Chapters[chapterId]
				if chapter then
					local previousOk = true
					-- capítulos dentro do episódio são sequenciais
					local index = table.find(episode.chapters, chapterId) or 1
					if index > 1 then
						previousOk = completed[episode.chapters[index - 1]] == true
					end
					if previousOk then
						local clone = {}
						for key, value in pairs(chapter) do
							clone[key] = value
						end
						clone.locked = false
						table.insert(unlocked, clone)
					end
				end
			end
		end
	end
	return unlocked
end

function Episodes.totalPoints()
	local total = 0
	for _, chapter in ipairs(Episodes.allChapters()) do
		total += (chapter.rewards and chapter.rewards.points) or 0
	end
	return total
end

function Episodes.validate()
	-- Checagem de integridade usada pelos testes automáticos (tests/)
	local problems = {}
	local seenChapters = {}

	for _, episodeId in ipairs(Episodes.Season.order) do
		local episode = Episodes.List[episodeId]
		if not episode then
			table.insert(problems, "Episódio ausente: " .. episodeId)
		else
			if #episode.chapters == 0 then
				table.insert(problems, "Episódio sem capítulos: " .. episodeId)
			end
			for _, chapterId in ipairs(episode.chapters) do
				local chapter = Episodes.Chapters[chapterId]
				if not chapter then
					table.insert(problems, "Capítulo inexistente: " .. chapterId)
				else
					if seenChapters[chapterId] then
						table.insert(problems, "Capítulo duplicado: " .. chapterId)
					end
					seenChapters[chapterId] = true
					if not chapter.name or chapter.name == "" then
						table.insert(problems, "Capítulo sem nome: " .. chapterId)
					end
					if not chapter.objectives or #chapter.objectives < 3 then
						table.insert(problems, "Capítulo com poucos objetivos: " .. chapterId)
					end
					for _, objective in ipairs(chapter.objectives or {}) do
						if not objective.label or objective.label == "" then
							table.insert(problems, "Objetivo sem label em " .. chapterId)
						end
						if not objective.points or objective.points <= 0 then
							table.insert(problems, "Objetivo sem pontos em " .. chapterId)
						end
					end
				end
			end
		end
	end

	return #problems == 0, problems
end

return Episodes
