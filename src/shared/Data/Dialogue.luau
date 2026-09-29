--[[
	Dialogue.luau
	Árvores de diálogo do jogo. Cada nó tem falas, escolhas e efeitos.

	Estrutura de um nó:
		text      = fala do NPC
		emote     = expressão (happy, worried, scared, thinking, angry, neutral, celebrate)
		sfx       = som opcional
		next      = próximo nó (diálogo linear)
		choices   = { { text, next, role, effect } } (diálogo com escolhas)
		effect    = { clue = "ID", points = 100, flag = "nome", reveal = "texto", objective = "ID" }
		camera    = "close" | "wide" | "over" (dica de câmera para o cliente)

	`Dialogue.buildLine(speakerId, kind)` gera falas de reação rápidas fora da
	árvore (o monstro apareceu, o jogador achou uma pista, etc.), respeitando o
	estilo de fala de cada personagem em Cast.luau.
]]

local Dialogue = {}

Dialogue.Nodes = {}

-- ==========================================================
-- LOBBY / TUTORIAL
-- ==========================================================
Dialogue.Nodes.Lobby_Scooby = {
	id = "Lobby_Scooby",
	title = "Scooby-Doo",
	speaker = "Scooby",
	start = "n1",
	nodes = {
		n1 = {
			text = "Scooby-Dooby-Doo! Ronde ru ramos hoje, Raggy?",
			emote = "happy",
			sfx = "Ping",
			choices = {
				{ text = "(Fred) Temos oito casos no quadro. Vamos começar pelo farol.", next = "n2" },
				{ text = "(Velma) Scooby, sente alguma coisa estranha aqui na sede?", next = "n3" },
				{ text = "(Salsicha) Onde você escondeu os biscoitos? Confessa, Scooby.", next = "n4" },
			},
		},
		n2 = {
			text = "Rarol? Rom ru raria de ropar ruma rassombração. Ru ru ro ro reguro!",
			emote = "excited",
			effect = { points = 30 },
			next = "n5",
		},
		n3 = {
			text = "Rnif... rnif... Ram cera no ranfiteirão. Ralguém reve um ronvite re cera...",
			emote = "thinking",
			effect = { clue = "PRO_C1", points = 40 },
			next = "n5",
		},
		n4 = {
			text = "Ru? Ru?! Ro biscoito? Ru rão sei ro nde rão os riscoitos... (ele está com a boca cheia)",
			emote = "happy",
			effect = { points = 20, flag = "scoobyConfessou" },
			next = "n5",
		},
		n5 = {
			text = "Rento, re ragente? Ru ro ronto ro rimeiro raso?",
			emote = "neutral",
			onEnd = { objective = "PRO_2", points = 60 },
		},
	},
}

Dialogue.Nodes.Lobby_Gang = {
	id = "Lobby_Gang",
	title = "A Turma",
	speaker = "Fred",
	start = "n1",
	nodes = {
		n1 = {
			text = "Seis cidades, seis monstros e a mesma assinatura: C². A gente resolve os casos, e depois resolve o mistério.",
			emote = "happy",
			choices = {
				{ text = "(Velma) Como funcionam os papéis do grupo?", next = "roles" },
				{ text = "(Fred) Como a gente prende os monstros?", next = "traps" },
				{ text = "(Daphne) E se eu quiser jogar só com meus amigos?", next = "friends" },
				{ text = "(Salsicha) E se eu quiser só correr? Pergunta séria.", next = "run" },
			},
		},
		roles = {
			text = "Velma: 'Quatro papéis, uma habilidade ativa cada: Fred arma, Daphne convence, eu analiso e o Salsicha distrai.'",
			emote = "thinking",
			next = "roles2",
		},
		roles2 = {
			text = "Velma: 'Com um jogador só, quem entrou primeiro escolhe o papel; o Scooby entra sempre como NPC companheiro.'",
			emote = "neutral",
			next = "n1",
		},
		traps = {
			text = "Fred: 'Três peças de armadilha, uma montagem, uma isca e um puxão. Toda armadilha funciona igual. Sempre.'",
			emote = "excited",
			effect = { points = 30 },
			next = "traps2",
		},
		traps2 = {
			text = "Fred: 'E se o monstro te pegar, você fica assustado por alguns segundos. Nada de perder a partida por causa disso.'",
			emote = "happy",
			next = "n1",
		},
		friends = {
			text = "Daphne: 'No painel da turma dá para deixar a sala em SOMENTE AMIGOS. Aí só os seus amigos do Roblox entram.'",
			emote = "happy",
			next = "n1",
		},
		run = {
			text = "Salsicha: 'Tipo assim, correr é uma estratégia! Eu chamo de reconhecimento de longo prazo.'",
			emote = "scared",
			effect = { points = 20 },
			next = "n1",
		},
	},
}

-- ==========================================================
-- EPISÓDIO 1
-- ==========================================================
Dialogue.Nodes.EP01_Keeper = {
	id = "EP01_Keeper",
	title = "Faroleiro Barnaby",
	speaker = "EP01_Keeper",
	start = "n1",
	nodes = {
		n1 = {
			text = "Quarenta anos acendendo essa luz, garoto. Quarenta! E agora ela acende sozinha... e apaga sozinha.",
			emote = "worried",
			sfx = "Water",
			next = "n2",
		},
		n2 = {
			text = "Foi na terça. Três da manhã. Eu vi o vulto subir a escada de ferro... e depois ele estava no topo, sem ter subido.",
			emote = "scared",
			next = "n3",
		},
		n3 = {
			text = "Perguntem o que quiserem. Eu só quero essa luz quieta de novo.",
			emote = "neutral",
			choices = {
				{
					text = "(Velma) A senhora viu a mão dele? Tinha luva?",
					next = "n4",
					effect = { clue = "EP01_C1", points = 40 },
				},
				{ text = "(Fred) Ele já apareceu com a luz acesa?", next = "n5" },
				{ text = "(Daphne) Alguém esteve no farol antes do fantasma aparecer?", next = "n6", role = "Daphne" },
			},
		},
		n4 = {
			text = "Luva não. Mas vi a bota. Bota de trabalho, com aquela sola quadriculada de quem anda em convés. Pescador de sardinha não usa isso.",
			emote = "thinking",
			effect = { points = 30 },
			next = "n7",
		},
		n5 = {
			text = "Nunca! Com a luz acesa ele não aparece. É como se ele precisasse do escuro... ou de uma desculpa para apagar tudo.",
			emote = "neutral",
			next = "n7",
		},
		n6 = {
			text = "Apareceram dois homens de terno medindo o píer. Um deles tinha um sorriso que não combinava com o lugar.",
			emote = "thinking",
			effect = { clue = "EP01_C4", points = 50 },
			next = "n7",
		},
		n7 = {
			text = "Cuidado lá em cima. Aquela escada é traiçoeira. Até para fantasma.",
			emote = "worried",
			onEnd = { objective = "EP01_C1_OB2", points = 60 },
		},
	},
}

Dialogue.Nodes.EP01_Lucille = {
	id = "EP01_Lucille",
	title = "Lucille Prado",
	speaker = "EP01_Lucille",
	start = "n1",
	nodes = {
		n1 = {
			text = "Pousada cheia em plena terça-feira! Só que os hóspedes são todos do consórcio. E ninguém toma café da manhã.",
			emote = "happy",
			choices = {
				{ text = "(Daphne) Consórcio? Que consórcio?", next = "n2" },
				{ text = "(Velma) A senhora guarda recibos? Eu preciso de datas.", next = "n3", role = "Velma" },
				{ text = "(Salsicha) Tem lanche? É para... vigilância.", next = "n4" },
			},
		},
		n2 = {
			text = "O do resort novo. Compraram metade do píer e agora estão atrás do farol. Estão pagando em dinheiro, minha filha.",
			emote = "thinking",
			next = "n5",
		},
		n3 = {
			text = "Recibos? Eu guardo tudo, minha filha. Olha aqui: barco grande alugado por três noites, devolvido limpo demais.",
			emote = "happy",
			effect = { clue = "EP01_C4", points = 60, objective = "EP01_C2_OB1" },
			next = "n5",
		},
		n4 = {
			text = "Lanche tem sempre! Mas quem paga o lanche é quem não foge quando o vulto passa. Combinado?",
			emote = "happy",
			effect = { flag = "lancheDeGraca", points = 20 },
			next = "n5",
		},
		n5 = {
			text = "Se eu fosse vocês, eu começava pelas botas. Ninguém entra num píer de terno e sapato de festa.",
			emote = "neutral",
			onEnd = { points = 40 },
		},
	},
}

Dialogue.Nodes.EP01_Duarte = {
	id = "EP01_Duarte",
	title = "Duarte, o caminhoneiro",
	speaker = "EP01_Duarte",
	start = "n1",
	nodes = {
		n1 = {
			text = "Cheguei às duas da manhã com dez caixas de material solar. Material solar! Nesta vila!",
			emote = "neutral",
			choices = {
				{ text = "(Fred) Quem assinou a entrega?", next = "n2" },
				{ text = "(Velma) O que tinha nas caixas, exatamente?", next = "n3" },
			},
		},
		n2 = {
			text = "Assinou um moço de capacete. Mas o carro dele era um sedã branco, sabe? Capacete de obra, carro de escritório.",
			emote = "thinking",
			effect = { clue = "EP01_C2", points = 50 },
			next = "n4",
		},
		n3 = {
			text = "Cabo grosso, controlador, fusível... e uma caixa comprida que eu não abri. Parecia trilho. Ou corrimão.",
			emote = "neutral",
			effect = { clue = "EP01_C2", points = 60, objective = "EP01_C1_OB4" },
			next = "n4",
		},
		n4 = {
			text = "Se eu passar de novo por aqui e ver fantasma, eu passo por cima. Avisando.",
			emote = "happy",
			onEnd = { points = 40 },
		},
	},
}

Dialogue.Nodes.EP01_Bea = {
	id = "EP01_Bea",
	title = "Bea, a menina do cais",
	speaker = "EP01_Bea",
	start = "n1",
	nodes = {
		n1 = {
			text = "O fantasma é meio bobo. Ele sempre erra a mesma coisa!",
			emote = "happy",
			choices = {
				{ text = "(Velma) Erra o quê, Bea?", next = "n2" },
				{ text = "(Salsicha) Ele é bobo como? Tipo assim, bobo de não assustar?", next = "n3" },
			},
		},
		n2 = {
			text = "Ele não sobe a escada! Eu fico olhando com o binóculo do meu pai. Ele aparece no topo do nada.",
			emote = "excited",
			effect = { clue = "EP01_C1", points = 70, objective = "EP01_C1_OB3" },
			next = "n4",
		},
		n3 = {
			text = "Bobo porque ele passa a mão no corrimão e não sobe! Fantasma não precisa de corrimão, né?",
			emote = "happy",
			effect = { clue = "EP01_C1", points = 70 },
			next = "n4",
		},
		n4 = {
			text = "Meu pai disse que se o farol apagar de novo, a gente se muda. Eu não quero me mudar.",
			emote = "worried",
			onEnd = { points = 50 },
		},
	},
}

Dialogue.Nodes.EP01_Cole = {
	id = "EP01_Cole",
	title = "Cole Vanterpool",
	speaker = "EP01_Suspeito_Cole",
	start = "n1",
	nodes = {
		n1 = {
			text = "Crianças, eu compro e vendo terrenos. Fantasma, para mim, é só um problema de avaliação.",
			emote = "neutral",
			choices = {
				{ text = "(Fred) E por acaso a avaliação caiu depois dos sustos?", next = "n2" },
				{ text = "(Velma) O senhor tem barco grande?", next = "n3" },
				{ text = "(Daphne) Quem paga o seu canteiro de obras?", next = "n4", role = "Daphne" },
			},
		},
		n2 = {
			text = "Caiu 40%. Mas isso é o mercado. Eu não controlo mercado... nem fantasma.",
			emote = "angry",
			effect = { clue = "EP01_C4", points = 50 },
			next = "n5",
		},
		n3 = {
			text = "Tenho três. Por quê? Alugar barco é crime agora?",
			emote = "angry",
			effect = { clue = "EP01_C4", points = 60, objective = "EP01_C2_OB2" },
			next = "n5",
		},
		n4 = {
			text = "Isso é informação privada. (Ele olha para o relógio de ouro — e o mostrador está parado.)",
			emote = "worried",
			effect = { clue = "EP01_C5", points = 70, flag = "coleNervoso" },
			next = "n5",
		},
		n5 = {
			text = "Sugiro que vocês foquem no problema e não em mim. Boa noite.",
			emote = "neutral",
			onEnd = { points = 50 },
		},
	},
}

Dialogue.Nodes.EP01_Marta = {
	id = "EP01_Marta",
	title = "Marta Kellerman",
	speaker = "EP01_Suspeito_Marta",
	start = "n1",
	nodes = {
		n1 = {
			text = "Eu estudo a colônia de mariscos do píer. A vila me contratou para provar que a obra não estava matando os animais.",
			emote = "neutral",
			choices = {
				{ text = "(Velma) E eles estão morrendo?", next = "n2" },
				{ text = "(Fred) O senhor viu alguém entrando na água na semana passada?", next = "n3" },
			},
		},
		n2 = {
			text = "Estão. E o interessante é que morrem em uma faixa retangular perfeita. Retangular! Natureza não faz retângulo.",
			emote = "thinking",
			effect = { clue = "EP01_C3", points = 60 },
			next = "n4",
		},
		n3 = {
			text = "Vi um barco de convés alto, sem luzes, por volta de uma da manhã. Fiquei com medo e voltei para o laboratório.",
			emote = "worried",
			effect = { clue = "EP01_C1", points = 60, objective = "EP01_C2_OB3" },
			next = "n4",
		},
		n4 = {
			text = "Levei seis meses para tirar minha licença. Se essa vila esvaziar, eu perco tudo. Não sou eu que quero o farol apagado.",
			emote = "neutral",
			onEnd = { points = 40 },
		},
	},
}

Dialogue.Nodes.EP01_Reveal = {
	id = "EP01_Reveal",
	title = "A Revelação — O Fantasma do Farol",
	speaker = "Velma",
	start = "n1",
	nodes = {
		n1 = {
			text = "Jinkies! Olhem só: Cole Vanterpool. O 'comprador de terrenos' que não tinha dinheiro para diesel.",
			emote = "excited",
			sfx = "UnmaskStinger",
			next = "n2",
		},
		n2 = {
			text = "Ele usou o elevador de carga do próprio canteiro para subir ao farol sem passar pela escada.",
			emote = "thinking",
			next = "n3",
		},
		n3 = {
			text = "E as botas de convés? Do barco que ele mesmo alugou. Estava tudo no projeto — literalmente.",
			emote = "happy",
			next = "n4",
		},
		n4 = {
			text = "...e o mais interessante: alguém PAGOU ele para fazer isso. Uma fita cassete com selo 'C²'. Lote 1 de 6.",
			emote = "worried",
			effect = { clue = "EP01_C8", points = 100 },
			next = "n5",
		},
		n5 = {
			text = "Fred: 'Então não era um fantasma. Era um funcionário. E o patrão ainda está solto.'",
			emote = "neutral",
			next = "n6",
		},
		n6 = {
			text = "Salsicha: 'Tipo assim... eu tô feliz e assustado ao mesmo tempo. É um sentimento novo.'",
			emote = "happy",
			next = "n7",
		},
		n7 = {
			text = "Scooby: 'Scooby-Dooby-DOOOO! Roma rambém!'",
			emote = "celebrate",
			onEnd = { points = 150 },
		},
	},
}

-- ==========================================================
-- EPISÓDIO 2
-- ==========================================================
Dialogue.Nodes.EP02_Gerente = {
	id = "EP02_Gerente",
	title = "Gerente Osório",
	speaker = "EP02_Gerente",
	start = "n1",
	nodes = {
		n1 = {
			text = "Bem-vindos! O Excelsior tem 41 quartos, três hóspedes e um problema de reputação. E o banco leiloa o prédio sexta.",
			emote = "worried",
			choices = {
				{ text = "(Fred) Quem está comprando o hotel?", next = "n2" },
				{ text = "(Velma) Quantas pessoas têm chave do 3º andar?", next = "n3" },
				{ text = "(Salsicha) O café da manhã está incluso?", next = "n4" },
			},
		},
		n2 = {
			text = "Uma fundação. Não me deram o nome do dono... mas o advogado deles veio com um selo de cera no envelope. Que ridículo.",
			emote = "neutral",
			effect = { clue = "EP02_C4", points = 50 },
			next = "n5",
		},
		n3 = {
			text = "Duas: a minha e a do maestro. A da condessa sumiu em 1962, se você acredita nessas coisas.",
			emote = "worried",
			effect = { clue = "EP02_C8", points = 70, objective = "EP02_C1_OB1" },
			next = "n5",
		},
		n4 = {
			text = "Incluso? Meu jovem, o hotel está quebrado. Aqui o café da manhã é uma história que se conta no almoço.",
			emote = "happy",
			effect = { flag = "semCafe", points = 20 },
			next = "n5",
		},
		n5 = {
			text = "Só peço uma coisa: não subam ao terceiro andar. Não é superstição — é a apólice do seguro.",
			emote = "worried",
			onEnd = { points = 40 },
		},
	},
}

Dialogue.Nodes.EP02_Ester = {
	id = "EP02_Ester",
	title = "Ester, a camareira",
	speaker = "EP02_Mucama",
	start = "n1",
	nodes = {
		n1 = {
			text = "Trinta anos limpando este hotel. Eu sei quando um quarto está vazio e quando tem gente dentro, mesmo sem ver ninguém.",
			emote = "neutral",
			choices = {
				{ text = "(Daphne) E o 302 está vazio?", next = "n2" },
				{ text = "(Velma) A senhora tem a chave desse quarto?", next = "n3" },
				{ text = "(Fred) O piano toca toda noite?", next = "n4" },
			},
		},
		n2 = {
			text = "Vazio não está. A cama é arrumada todos os dias por alguém. E não sou eu.",
			emote = "worried",
			effect = { clue = "EP02_C5", points = 80, objective = "EP02_C2_OB1" },
			next = "n5",
		},
		n3 = {
			text = "Tenho uma cópia. Mas ela está dentro de uma caixa de charutos, junto com um algodão branco e um pó fino que parece gesso.",
			emote = "thinking",
			effect = { clue = "EP02_C8", points = 90 },
			next = "n5",
		},
		n4 = {
			text = "Toca quando o gerente está no escritório. E o choro que a gente ouve não vem do salão: vem do duto. Do duto!",
			emote = "scared",
			effect = { clue = "EP02_C5", points = 80 },
			next = "n5",
		},
		n5 = {
			text = "Falo isso porque o hotel é minha vida. Se fechar, eu não tenho para onde ir.",
			emote = "worried",
			onEnd = { points = 50 },
		},
	},
}

Dialogue.Nodes.EP02_Igor = {
	id = "EP02_Igor",
	title = "Maestro Igor Zappa",
	speaker = "EP02_Pianista",
	start = "n1",
	nodes = {
		n1 = {
			text = "Eu toquei neste piano por vinte anos. Vinte. E agora quem toca é... um fantasma de segunda categoria.",
			emote = "angry",
			choices = {
				{
					text = "(Velma) O senhor escreveu alguma coisa para o piano recentemente?",
					next = "n2",
					role = "Velma",
				},
				{ text = "(Daphne) Quem cancelou o seu contrato?", next = "n3", role = "Daphne" },
				{ text = "(Fred) Onde o senhor estava na terça às 3 da manhã?", next = "n4" },
			},
		},
		n2 = {
			text = "Uma valsa. 'Valsa do Hóspede'. Nunca foi tocada em público... e a partitura desapareceu daqui.",
			emote = "worried",
			effect = { clue = "EP02_C7", points = 90, objective = "EP02_C2_OB5" },
			next = "n5",
		},
		n3 = {
			text = "A fundação nova. Eles querem o prédio, e eu sou... inconveniente. Um músico inconveniente.",
			emote = "angry",
			effect = { clue = "EP02_C6", points = 70, objective = "EP02_C2_OB2" },
			next = "n5",
		},
		n4 = {
			text = "Eu estava na minha sala, transcrevendo partituras à mão. Como faço há vinte anos. À mão, criança. À mão.",
			emote = "neutral",
			effect = { clue = "EP02_C8", points = 60 },
			next = "n5",
		},
		n5 = {
			text = "Se você descobrir quem roubou a minha valsa, eu toco a sua vitória no piano. Sem cobrar.",
			emote = "happy",
			onEnd = { points = 50 },
		},
	},
}

Dialogue.Nodes.EP02_Wilhelmina = {
	id = "EP02_Wilhelmina",
	title = "Condessa Wilhelmina",
	speaker = "EP02_Convidada",
	start = "n1",
	nodes = {
		n1 = {
			text = "Esta é a minha suíte há 27 anos. E não, eu não vou me mudar. Nem por fantasma, nem por advogado, nem por você.",
			emote = "angry",
			choices = {
				{ text = "(Daphne) A senhora já viu o hóspede do 302? (Sim ou não?)", next = "n2" },
				{ text = "(Velma) A senhora coleciona porcelana, por acaso?", next = "n3" },
				{ text = "(Salsicha) A senhora tem comida aqui? (Pergunta séria.)", next = "n4" },
			},
		},
		n2 = {
			text = "Vi. Duas vezes. Na primeira, ele me cumprimentou com a cabeça. Na segunda, usava luvas de gesso.",
			emote = "thinking",
			effect = { clue = "EP02_C9", points = 90, objective = "EP02_C2_OB3" },
			next = "n5",
		},
		n3 = {
			text = "O jogo de 1962 está no depósito. Faltam um prato e uma taça. Alguém jantou com os meus serviços e não me convidou.",
			emote = "angry",
			effect = { clue = "EP02_C6", points = 90, objective = "EP02_C2_OB4" },
			next = "n5",
		},
		n4 = {
			text = "Tenho caviar e biscoitos de amêndoa. Não divido o caviar. O biscoito, talvez.",
			emote = "neutral",
			effect = { flag = "biscoitoDaCondessa", points = 20 },
			next = "n5",
		},
		n5 = {
			text = "Se aquele hotel fechar, eu perco as minhas cortinas. E as minhas cortinas são... importantes.",
			emote = "worried",
			onEnd = { points = 50 },
		},
	},
}

Dialogue.Nodes.EP02_Tiago = {
	id = "EP02_Tiago",
	title = "Tiago, o mensageiro",
	speaker = "EP02_Bellboy",
	start = "n1",
	nodes = {
		n1 = {
			text = "Eu sou o Tiago! Levo mala, subo escada, ouço reclamação o dia inteiro. E eu vi uma coisa esquisita!",
			emote = "excited",
			choices = {
				{ text = "(Fred) O que você viu, Tiago?", next = "n2" },
				{ text = "(Velma) Você mexeu no depósito de porcelana?", next = "n3" },
			},
		},
		n2 = {
			text = "A porta da cozinha bateu sozinha! Mas o segredo é: alguém levou três pratos e um vinho às 2h. Eu vi a bandeja passando pela porta de serviço!",
			emote = "scared",
			effect = { clue = "EP02_C3", points = 80, objective = "EP02_C1_OB4" },
			next = "n4",
		},
		n3 = {
			text = "Eu não mexo! A chave é do gerente e do maestro. Eles brigam por essa chave toda semana, sério.",
			emote = "neutral",
			effect = { clue = "EP02_C6", points = 70 },
			next = "n4",
		},
		n4 = {
			text = "Ah, e tem uma coisa: o elevador de serviço range às 3h. E o gerente dorme às 22h. Todo mundo aqui sabe disso.",
			emote = "thinking",
			effect = { clue = "EP02_C5", points = 60, objective = "EP02_C2_OB1" },
			onEnd = { points = 50 },
		},
	},
}

Dialogue.Nodes.EP02_Reveal = {
	id = "EP02_Reveal",
	title = "A Revelação — O Hóspede do 302",
	speaker = "Velma",
	start = "n1",
	nodes = {
		n1 = {
			text = "Mestre Igor Zappa! Ele tocou o piano por 20 anos e escreveu a própria 'malassombração'.",
			emote = "excited",
			sfx = "UnmaskStinger",
			next = "n2",
		},
		n2 = {
			text = "O fio de aço no teto é um sistema de palco. O riso, o piano, as luzes — tudo em um só canal.",
			emote = "thinking",
			next = "n3",
		},
		n3 = {
			text = "Mas o motivo dele era o hotel, não o dinheiro: ele não suportava ver o Excelsior ser vendido como 'terreno'.",
			emote = "neutral",
			next = "n4",
		},
		n4 = {
			text = "E ele não estava sozinho. A partitura de 1962 foi roubada — e a encomenda do roubo veio em uma fita. Lote 2 de 6.",
			emote = "worried",
			effect = { clue = "EP02_C10", points = 120 },
			next = "n5",
		},
		n5 = {
			text = "Daphne: 'O susto era o teatro. O que ele queria mesmo era a partitura original. E alguém pagou para ele fazer isso.'",
			emote = "thinking",
			next = "n6",
		},
		n6 = {
			text = "Scooby: 'Rramalhado! Ru ru rapaz de resolver ristério rom rarim!'",
			emote = "celebrate",
			onEnd = { points = 180 },
		},
	},
}

-- ==========================================================
-- EPISÓDIO 3
-- ==========================================================
Dialogue.Nodes.EP03_Romanelli = {
	id = "EP03_Romanelli",
	title = "Mestre Romanelli",
	speaker = "EP03_Dono",
	start = "n1",
	nodes = {
		n1 = {
			text = "Quarenta anos de circo, minha gente. Quarenta! E um riso de mentira está espantando o público.",
			emote = "worried",
			choices = {
				{ text = "(Fred) Quem ganha se o circo fechar?", next = "n2" },
				{ text = "(Velma) Quem tem acesso à cabine de som?", next = "n3" },
				{ text = "(Daphne) Por que Bibo foi tirado do número principal?", next = "n4", role = "Daphne" },
			},
		},
		n2 = {
			text = "Uma imobiliária. Eles querem o terreno e me deram 15 dias para desmontar as lonas. Quinze dias!",
			emote = "angry",
			effect = { clue = "EP03_C1", points = 70, objective = "EP03_C1_OB1" },
			next = "n5",
		},
		n3 = {
			text = "Eu, o Bibo e o técnico de som. Mas o técnico foi embora no mês passado, então sobram dois.",
			emote = "neutral",
			effect = { clue = "EP03_C4", points = 70 },
			next = "n5",
		},
		n4 = {
			text = "Porque o número dele não funciona mais, ué. Público não ri. Não é crueldade, é... é circo.",
			emote = "neutral",
			effect = { clue = "EP03_C5", points = 80, objective = "EP03_C1_OB5" },
			next = "n5",
		},
		n5 = {
			text = "Vão lá. E se encontrarem o palhaço, digam que o contrato dele foi cancelado.",
			emote = "neutral",
			onEnd = { points = 50 },
		},
	},
}

Dialogue.Nodes.EP03_Iara = {
	id = "EP03_Iara",
	title = "Iara, a trapezista",
	speaker = "EP03_Trapezista",
	start = "n1",
	nodes = {
		n1 = {
			text = "Eu treino 6 horas por dia. Se o circo fechar, eu viro professora de dança. Não sei se quero isso.",
			emote = "neutral",
			choices = {
				{ text = "(Daphne) Você ouviu alguém na passarela de madrugada?", next = "n2" },
				{ text = "(Fred) Você viu o palhaço de perto?", next = "n3" },
				{ text = "(Salsicha) Você me ensina a dar mortal? (Pergunta de vida ou morte.)", next = "n4" },
			},
		},
		n2 = {
			text = "Ouvi. Duas da manhã. Alguém subiu na passarela com um saco grande, ouvindo a gravação do riso no fone. Eu jurei que era o Bibo.",
			emote = "worried",
			effect = { clue = "EP03_C6", points = 90, objective = "EP03_C2_OB1" },
			next = "n5",
		},
		n3 = {
			text = "De perto não. Mas quando ele passou embaixo do refletor, eu vi a sombra das pernas. Era fina demais para ser perna de gente.",
			emote = "thinking",
			effect = { clue = "EP03_C9", points = 90 },
			next = "n5",
		},
		n4 = {
			text = "Mortal? Você não consegue nem subir a escada do camarim. Mas eu te ensino a cair bonito.",
			emote = "happy",
			effect = { flag = "aulaDeMortal", points = 20 },
			next = "n5",
		},
		n5 = {
			text = "Eu só quero que alguém acredite em mim. Aqui dentro, ninguém acredita em nada.",
			emote = "worried",
			onEnd = { points = 50 },
		},
	},
}

Dialogue.Nodes.EP03_Bibo = {
	id = "EP03_Bibo",
	title = "Bibo, o palhaço triste",
	speaker = "EP03_PalhacoTriste",
	start = "n1",
	nodes = {
		n1 = {
			text = "Vocês... vieram me acusar, né? Todos vêm me acusar. Eu sou o palhaço, então eu sou o suspeito.",
			emote = "angry",
			choices = {
				{ text = "(Velma) Se você for inocente, mostre o seu camarim.", next = "n2" },
				{ text = "(Fred) Quem te procurou depois que cortaram o seu número?", next = "n3" },
				{ text = "(Daphne) Você costurou essa fantasia nova? É bonita.", next = "n4", role = "Daphne" },
			},
		},
		n2 = {
			text = "Fica à vontade. Só não mexe nas pernas de pau vermelhas. Aquelas são... são minhas.",
			emote = "worried",
			effect = { clue = "EP03_C9", points = 100, objective = "EP03_C2_OB5" },
			next = "n5",
		},
		n3 = {
			text = "Ninguém. NA-QUIN-GUÉM! Só... só um homem que deixou um envelope. Com dinheiro. E uma fita.",
			emote = "scared",
			effect = { clue = "EP03_C10", points = 120, objective = "EP03_C2_OB2" },
			next = "n5",
		},
		n4 = {
			text = "Costurei. Levei três semanas. Ela é minha volta ao picadeiro... ou era. (Ele chora de verdade. Palhaço de circo, chorando.)",
			emote = "worried",
			effect = { clue = "EP03_C10", points = 90, flag = "biboChorou" },
			next = "n5",
		},
		n5 = {
			text = "Ninguém me chama de 'artista' desde que meu número caiu. Nem o Romanelli.",
			emote = "neutral",
			onEnd = { points = 60 },
		},
	},
}

Dialogue.Nodes.EP03_Zeca = {
	id = "EP03_Zeca",
	title = "Zeca Pipoca",
	speaker = "EP03_Feirante",
	start = "n1",
	nodes = {
		n1 = {
			text = "Pipoca quentinha! Dois reais! Ei, vocês são os do Mistério S.A., né? Vi vocês na TV!",
			emote = "excited",
			choices = {
				{ text = "(Fred) Você trabalha aqui até que hora?", next = "n2" },
				{ text = "(Velma) Alguém pagou para você não olhar nada?", next = "n3", role = "Velma" },
			},
		},
		n2 = {
			text = "Até meia-noite! E na quarta eu vi uma luz na passarela do picadeiro. Luz de lanterna pequena, sabe?",
			emote = "neutral",
			effect = { clue = "EP03_C3", points = 70, objective = "EP03_C1_OB3" },
			next = "n4",
		},
		n3 = {
			text = "...eu não devia falar isso. Mas um homem de terno me comprou 200 pipocas e pagou o dobro pra eu não ver nada.",
			emote = "worried",
			effect = { clue = "EP03_C7", points = 100, objective = "EP03_C2_OB3" },
			next = "n4",
		},
		n4 = {
			text = "Se vocês pegarem o palhaço, o circo fica, e eu continuo vendendo pipoca. Todo mundo sai ganhando. Principalmente eu.",
			emote = "happy",
			onEnd = { points = 50 },
		},
	},
}

Dialogue.Nodes.EP03_Reveal = {
	id = "EP03_Reveal",
	title = "A Revelação — O Palhaço Sem Riso",
	speaker = "Fred",
	start = "n1",
	nodes = {
		n1 = {
			text = "Bibo! O palhaço que ia voltar a ser a estrela do circo — do jeito errado.",
			emote = "excited",
			sfx = "UnmaskStinger",
			next = "n2",
		},
		n2 = {
			text = "As pernas de pau presas dentro do figurino faziam 2,7 metros. E o confete no chão escondia as marcas da bengala.",
			emote = "thinking",
			next = "n3",
		},
		n3 = {
			text = "O riso era gravação. E a gravação estava com uma etiqueta nova: 'LOTE 3 DE 6 — C²'.",
			emote = "worried",
			effect = { clue = "EP03_C11", points = 130 },
			next = "n4",
		},
		n4 = {
			text = "Daphne: 'Ele quase chorou quando viu o programa novo sem o nome dele. Aquele era o motivo verdadeiro.'",
			emote = "worried",
			next = "n5",
		},
		n5 = {
			text = "Scooby: 'Ru rabia! Rogora ru riquei ro rirco! Rramalhado!'",
			emote = "celebrate",
			onEnd = { points = 200 },
		},
	},
}

-- ==========================================================
-- EPISÓDIO 4
-- ==========================================================
Dialogue.Nodes.EP04_Sonia = {
	id = "EP04_Sonia",
	title = "Engenheira Sônia Kraft",
	speaker = "EP04_Engenheira",
	start = "n1",
	nodes = {
		n1 = {
			text = "Vocês entraram numa área técnica interditada. Isso é violação de segurança industrial, sabiam?",
			emote = "angry",
			choices = {
				{
					text = "(Velma) E quem mantém a linha 4 funcionando numa fábrica sem energia?",
					next = "n2",
					role = "Velma",
				},
				{
					text = "(Daphne) A senhora foi demitida duas semanas antes dos sustos. Coincidência?",
					next = "n3",
					role = "Daphne",
				},
				{ text = "(Fred) A senhora tem crachá de acesso ainda?", next = "n4" },
			},
		},
		n2 = {
			text = "O gerador auxiliar. Diesel. Qualquer técnico competente saberia disso sem precisar perguntar.",
			emote = "neutral",
			effect = { clue = "EP04_C3", points = 80, objective = "EP04_C1_OB3" },
			next = "n5",
		},
		n3 = {
			text = "Coincidência é o que a diretoria chama de 'reestruturação'. Eu chamo de 'reestruturação', também. Sempre fui diplomática.",
			emote = "angry",
			effect = { clue = "EP04_C1", points = 80, objective = "EP04_C2_OB1" },
			next = "n5",
		},
		n4 = {
			text = "Tenho. Ainda não conseguiram desativar o meu. Um detalhe técnico... do projeto que EU assinei.",
			emote = "happy",
			effect = { clue = "EP04_C5", points = 90, objective = "EP04_C1_OB5" },
			next = "n5",
		},
		n5 = {
			text = "Se vocês estragarem qualquer coisa aqui dentro, o laudo de segurança vira laudo de acidente. Pensem nisso.",
			emote = "neutral",
			onEnd = { points = 60 },
		},
	},
}

Dialogue.Nodes.EP04_Amaral = {
	id = "EP04_Amaral",
	title = "Vigia Amaral",
	speaker = "EP04_Seguranca",
	start = "n1",
	nodes = {
		n1 = {
			text = "Eu fiquei três horas trancado nesse vestiário. Três horas! Com uma lanterna e um sanduíche de mortadela.",
			emote = "scared",
			choices = {
				{ text = "(Fred) O robô tentou entrar?", next = "n2" },
				{ text = "(Velma) Você escutou alguma coisa além do robô?", next = "n3" },
			},
		},
		n2 = {
			text = "Tentou não. Ele passou três vezes na frente da porta. Três. Como se estivesse fazendo ronda. Ronda, gente!",
			emote = "scared",
			effect = { clue = "EP04_C2", points = 80, objective = "EP04_C1_OB2" },
			next = "n4",
		},
		n3 = {
			text = "Escutei cheiro de café. Cafeteira ligada, sabe? E uma voz de mulher falando 'mais devagar, mais devagar'.",
			emote = "thinking",
			effect = { clue = "EP04_C1", points = 110, objective = "EP04_C1_OB2" },
			next = "n4",
		},
		n4 = {
			text = "Amanhã eu peço demissão. Se eu sobreviver a hoje, eu peço demissão amanhã.",
			emote = "worried",
			onEnd = { points = 60 },
		},
	},
}

Dialogue.Nodes.EP04_Nando = {
	id = "EP04_Nando",
	title = "Nando, o estagiário",
	speaker = "EP04_Estagiario",
	start = "n1",
	nodes = {
		n1 = {
			text = "Eu só queria aprender manutenção elétrica, cara. Aí me pedem para religar um disjuntor às 3 da manhã. E me dão trezentos reais.",
			emote = "happy",
			choices = {
				{ text = "(Velma) Quem te pediu?", next = "n2", role = "Velma" },
				{ text = "(Fred) Como era essa pessoa?", next = "n3" },
				{ text = "(Salsicha) Você aceitou, né? Eu também aceitaria. Comida é caro.", next = "n4" },
			},
		},
		n2 = {
			text = "Um macacão cinza. Voz de quem manda e sabe que sabe. Nem olhou na minha cara.",
			emote = "neutral",
			effect = { clue = "EP04_C6", points = 90, objective = "EP04_C2_OB2" },
			next = "n5",
		},
		n3 = {
			text = "Ela tinha um caderninho com desenhos técnicos. E um crachá antigo. Eu vi o nome! 'KRAFT'!",
			emote = "excited",
			effect = { clue = "EP04_C5", points = 110, objective = "EP04_C1_OB5" },
			next = "n5",
		},
		n4 = {
			text = "Cara, trezentos reais! Eu aceitei, é claro. Não sabia que o dinheiro vinha de um fantasma robô.",
			emote = "happy",
			effect = { flag = "nandoAceitou", points = 20 },
			next = "n5",
		},
		n5 = {
			text = "Se você me perguntar se o robô é de verdade... eu respondo: ele me cumprimentou com a mão. Máquina não cumprimenta.",
			emote = "thinking",
			onEnd = { points = 60 },
		},
	},
}

Dialogue.Nodes.EP04_Cida = {
	id = "EP04_Cida",
	title = "Dona Cida, da cantina",
	speaker = "EP04_Dona",
	start = "n1",
	nodes = {
		n1 = {
			text = "A fábrica fechou, mas a minha janela nunca fechou. Eu vendo café desde 1978 e não vou parar por causa de robô.",
			emote = "happy",
			choices = {
				{ text = "(Daphne) Quem aparece na sua janela de madrugada?", next = "n2" },
				{ text = "(Velma) Toda sexta? No mesmo horário?", next = "n3" },
				{ text = "(Salsicha) O pão na chapa é bom mesmo?", next = "n4" },
			},
		},
		n2 = {
			text = "Uma pessoa de macacão. Pede um pão na chapa e um café. Diz 'bom trabalho' e vai embora. Educada, sabe?",
			emote = "neutral",
			effect = { clue = "EP04_C7", points = 110, objective = "EP04_C2_OB3" },
			next = "n5",
		},
		n3 = {
			text = "Toda sexta, das 2h às 5h. E paga com nota nova, sempre. Nota de cem que nunca vi na vida.",
			emote = "thinking",
			effect = { clue = "EP04_C7", points = 110, objective = "EP04_C2_OB3" },
			next = "n5",
		},
		n4 = {
			text = "Bom?! Meu pão na chapa é patrimônio cultural desta zona industrial! Senta ali e espera.",
			emote = "happy",
			effect = { flag = "paoNaChapa", points = 30 },
			next = "n5",
		},
		n5 = {
			text = "E olha: se for prender alguém por causa disso, deixa ela tomar um café antes. Todo mundo merece um café.",
			emote = "neutral",
			onEnd = { points = 60 },
		},
	},
}

Dialogue.Nodes.EP04_Reveal = {
	id = "EP04_Reveal",
	title = "A Revelação — O Robô da Linha 4",
	speaker = "Velma",
	start = "n1",
	nodes = {
		n1 = {
			text = "Engenheira Sônia Kraft! Demitida duas semanas antes da primeira aparição do MK-4.",
			emote = "excited",
			sfx = "UnmaskStinger",
			next = "n2",
		},
		n2 = {
			text = "Ela projetou o robô, conhece cada corredor e pagava o diesel com uma empresa de fachada: K-BRASIL CONSULTORIA.",
			emote = "thinking",
			next = "n3",
		},
		n3 = {
			text = "O truque era o laudo: 'fábrica insegura'. Um parecer negativo derrubava o valor do prédio e ela comprava tudo de volta barato.",
			emote = "neutral",
			next = "n4",
		},
		n4 = {
			text = "E no painel do robô, a quarta fita: 'LOTE 4 DE 6'. A mesma assinatura. Sempre o mesmo patrão.",
			emote = "worried",
			effect = { clue = "EP04_C11", points = 140 },
			next = "n5",
		},
		n5 = {
			text = "Salsicha: 'Tipo assim, era só uma engenheira de mau humor! Podia ser só uma engenheira de mau humor, gente.'",
			emote = "happy",
			next = "n6",
		},
		n6 = {
			text = "Scooby: 'Ru ru ru já rabia! Ru rão rosto de robô! Ran ran!'",
			emote = "celebrate",
			onEnd = { points = 220 },
		},
	},
}

-- ==========================================================
-- EPISÓDIO 5
-- ==========================================================
Dialogue.Nodes.EP05_Zulmira = {
	id = "EP05_Zulmira",
	title = "Zulmira, a mecânica",
	speaker = "EP05_Mecanico",
	start = "n1",
	nodes = {
		n1 = {
			text = "Treze anos de oficina nesta curva. Eu já vi de tudo: pneu estourado, capivara na estrada, caminhão de carga viva. Mas cavaleiro sem cabeça, não.",
			emote = "neutral",
			choices = {
				{
					text = "(Fred) Três carros pararam aqui na semana passada. Estavam com o mesmo problema?",
					next = "n2",
				},
				{ text = "(Velma) Qual motor morreu primeiro?", next = "n3", role = "Velma" },
				{ text = "(Salsicha) Você tem lanche no balcão? (Eu pago.)", next = "n4" },
			},
		},
		n2 = {
			text = "Exatamente o mesmo: cabo de vela arrancado. Arrancado, com força. E o caminhoneiro jurou que ninguém subiu no capô.",
			emote = "thinking",
			effect = { clue = "EP05_C1", points = 90, objective = "EP05_C1_OB1" },
			next = "n5",
		},
		n3 = {
			text = "O do meio. Sempre o segundo carro da fila. É como se alguém contasse quantos vêm antes de agir.",
			emote = "thinking",
			effect = { clue = "EP05_C1", points = 110, objective = "EP05_C1_OB1" },
			next = "n5",
		},
		n4 = {
			text = "Tenho mortadela e café. O café é de ontem, mas a coragem é de hoje.",
			emote = "happy",
			effect = { flag = "cafeDeOntem", points = 20 },
			next = "n5",
		},
		n5 = {
			text = "E olha: se vocês pegarem o cavaleiro, eu quero tirar foto. Pra pendurar na parede da oficina. Já pensou?",
			emote = "excited",
			onEnd = { points = 60 },
		},
	},
}

Dialogue.Nodes.EP05_Bigode = {
	id = "EP05_Bigode",
	title = "Caminhoneiro Bigode",
	speaker = "EP05_Motorista",
	start = "n1",
	nodes = {
		n1 = {
			text = "Eu tenho 22 anos de estrada, criança. E ontem eu rezei. REZEI! Eu não sei rezar!",
			emote = "scared",
			choices = {
				{ text = "(Fred) O que exatamente bateu no seu para-brisa?", next = "n2" },
				{ text = "(Daphne) Ele falou alguma coisa?", next = "n3" },
			},
		},
		n2 = {
			text = "Um pedaço de ferro, desses com rebite. Deixei na lanchonete. Parece... parece uma ferramenta de fazenda.",
			emote = "thinking",
			effect = { clue = "EP05_C6", points = 100, objective = "EP05_C2_OB2" },
			next = "n4",
		},
		n3 = {
			text = "Falou não, mas o motor dele batia forte. Um barulho pesado de máquina, não de casco de cavalo. Eu trabalho com motor, eu sei.",
			emote = "thinking",
			effect = { clue = "EP05_C2", points = 110 },
			next = "n4",
		},
		n4 = {
			text = "Estou descarregando em Coolsville amanhã. Se eu ver esse cavaleiro de novo, eu vou de ré. A ré é minha única arma.",
			emote = "happy",
			onEnd = { points = 60 },
		},
	},
}

Dialogue.Nodes.EP05_Ottavio = {
	id = "EP05_Ottavio",
	title = "Seu Otávio",
	speaker = "EP05_Fazendeiro",
	start = "n1",
	nodes = {
		n1 = {
			text = "Minha família está nesta terra desde 1912. A rodovia nova vai partir a fazenda no meio. Meio! Eu não vendo.",
			emote = "angry",
			choices = {
				{ text = "(Fred) O senhor tem trator? Porque as marcas no asfalto...", next = "n2" },
				{ text = "(Velma) Quem fez essa compra de feltro e tinta preta?", next = "n3", role = "Velma" },
				{ text = "(Daphne) O que o senhor perde se a rodovia passar?", next = "n4", role = "Daphne" },
			},
		},
		n2 = {
			text = "Tenho um trator pequeno. Azul. (Ele olha para o celeiro. O portão está novo. As dobradiças estão novas.)",
			emote = "worried",
			effect = { clue = "EP05_C4", points = 110, objective = "EP05_C1_OB4" },
			next = "n5",
		},
		n3 = {
			text = "A nota é minha, sim. Feltro para cobrir fardo, tinta para pintar cerca. Fazenda usa essas coisas, menina.",
			emote = "angry",
			effect = { clue = "EP05_C8", points = 120, objective = "EP05_C2_OB4" },
			next = "n5",
		},
		n4 = {
			text = "Perco o pasto, a casa e a minha... a minha memória inteira. Cortam o caminho onde eu aprendi a andar de bicicleta.",
			emote = "worried",
			effect = { clue = "EP05_C5", points = 100 },
			next = "n5",
		},
		n5 = {
			text = "Vão embora. E se voltarem, não passem pelo celeiro depois do pôr do sol.",
			emote = "neutral",
			onEnd = { points = 70 },
		},
	},
}

Dialogue.Nodes.EP05_Rita = {
	id = "EP05_Rita",
	title = "Rita Fontes",
	speaker = "EP05_Jornalista",
	start = "n1",
	nodes = {
		n1 = {
			text = "Eu cobri o 'Cavaleiro do 13' em 1987. Quatro páginas, uma manchete e um erro que eu levo até hoje.",
			emote = "thinking",
			choices = {
				{ text = "(Velma) Qual foi o erro?", next = "n2" },
				{ text = "(Daphne) Você tem as fotos originais?", next = "n3" },
				{ text = "(Fred) Por que voltar aqui agora?", next = "n4" },
			},
		},
		n2 = {
			text = "Eu escrevi 'sobrenatural'. Era um fazendeiro com um trator e uma abóbora. Ele tinha um motivo que ninguém quis entender.",
			emote = "worried",
			effect = { clue = "EP05_C7", points = 110, objective = "EP05_C2_OB3" },
			next = "n5",
		},
		n3 = {
			text = "Tenho. E comparando com o de hoje: a silhueta do cavalo mudou 30 cm e tem um escapamento aparecendo. É outro cavalo.",
			emote = "excited",
			effect = { clue = "EP05_C7", points = 130, objective = "EP05_C2_OB3" },
			next = "n5",
		},
		n4 = {
			text = "Porque alguém está pagando para reviver a minha matéria. E eu não repito o erro de 1987. Desta vez eu conto a verdade inteira.",
			emote = "neutral",
			effect = { clue = "EP05_C9", points = 100 },
			next = "n5",
		},
		n5 = {
			text = "Ei, crianças: quando vocês resolverem isso, eu quero a entrevista. Manchete de capa. Vocês merecem.",
			emote = "happy",
			onEnd = { points = 60 },
		},
	},
}

Dialogue.Nodes.EP05_Reveal = {
	id = "EP05_Reveal",
	title = "A Revelação — O Cavaleiro do KM 13",
	speaker = "Fred",
	start = "n1",
	nodes = {
		n1 = {
			text = "Seu Otávio! O trator pequeno com feltro e a abóbora de plástico estavam no celeiro dele.",
			emote = "excited",
			sfx = "UnmaskStinger",
			next = "n2",
		},
		n2 = {
			text = "O 'cavalo' era o trator. A 'cabeça' era uma abóbora com lâmpada. E o galope era um motor de 1 cilindro batendo.",
			emote = "thinking",
			next = "n3",
		},
		n3 = {
			text = "Ele tinha um comparsa: alguém que arrancava os cabos de vela enquanto os motoristas olhavam para o cavaleiro.",
			emote = "neutral",
			next = "n4",
		},
		n4 = {
			text = "E o comparsa recebia ordens por rádio. A quinta fita: 'LOTE 5 DE 6'. Cada vez mais perto do final.",
			emote = "worried",
			effect = { clue = "EP05_C11", points = 150 },
			next = "n5",
		},
		n5 = {
			text = "Daphne: 'A fita não é uma ordem dessa vez. É um convite. Ele quer que a gente veja a coleção.'",
			emote = "thinking",
			next = "n6",
		},
		n6 = {
			text = "Scooby: 'Ru rão rostro re rassombração nenhuma! Ru ro rrei! Rramalhado!'",
			emote = "celebrate",
			onEnd = { points = 240 },
		},
	},
}

-- ==========================================================
-- EPISÓDIO 6
-- ==========================================================
Dialogue.Nodes.EP06_Peixoto = {
	id = "EP06_Peixoto",
	title = "Advogado Peixoto",
	speaker = "EP06_Advogado",
	start = "n1",
	nodes = {
		n1 = {
			text = "Eu represento o espólio da família Blackwood há 22 anos. E, sinceramente, eu preferia estar representando um condomínio.",
			emote = "neutral",
			choices = {
				{
					text = "(Velma) Existe alguma cláusula sobre a 'maldição' no testamento?",
					next = "n2",
					role = "Velma",
				},
				{ text = "(Fred) Quem são os herdeiros?", next = "n3" },
				{ text = "(Daphne) O senhor já recebeu alguma proposta de compra?", next = "n4", role = "Daphne" },
			},
		},
		n2 = {
			text = "Cláusula 14: 'A propriedade não será alienada enquanto a Dama de Preto for vista na casa'. Está escrita em 1963. Em latim, inclusive.",
			emote = "thinking",
			effect = { clue = "EP06_C5", points = 120, objective = "EP06_C2_OB1" },
			next = "n5",
		},
		n3 = {
			text = "Um herdeiro só: Anselmo. Ele transformou a casa em 'museu' para não pagar imposto. Genial e desagradável.",
			emote = "neutral",
			effect = { clue = "EP06_C5", points = 100 },
			next = "n5",
		},
		n4 = {
			text = "Três. Todas recusadas com a mesma frase: 'a casa não está à venda enquanto a maldição não for resolvida'.",
			emote = "worried",
			effect = { clue = "EP06_C5", points = 120 },
			next = "n5",
		},
		n5 = {
			text = "Vou entregar os documentos para você. Mas se isso virar processo, eu não conheço nenhum de vocês.",
			emote = "neutral",
			onEnd = { points = 70 },
		},
	},
}

Dialogue.Nodes.EP06_Anselmo = {
	id = "EP06_Anselmo",
	title = "Curador Anselmo Blackwood",
	speaker = "EP06_Curador",
	start = "n1",
	nodes = {
		n1 = {
			text = "Bem-vindos ao Museu Blackwood. Não fotografem as peças, não toquem em nada e não fiquem no salão de espelhos depois das 23h.",
			emote = "neutral",
			choices = {
				{ text = "(Daphne) Por que os espelhos estão cobertos?", next = "n2", role = "Daphne" },
				{
					text = "(Velma) A pintura 'A Dama de Preto' está no lugar errado. Quem moveu?",
					next = "n3",
					role = "Velma",
				},
				{ text = "(Fred) O senhor mora aqui sozinho?", next = "n4" },
			},
		},
		n2 = {
			text = "Questões de conservação. A película dos espelhos é sensível à luz. Nada mais.",
			emote = "neutral",
			effect = { clue = "EP06_C2", points = 120, objective = "EP06_C1_OB3" },
			next = "n5",
		},
		n3 = {
			text = "O quadro está exatamente onde eu deixei. Vocês, detetives, precisam de óculos melhores.",
			emote = "angry",
			effect = { clue = "EP06_C1", points = 120, objective = "EP06_C1_OB2" },
			next = "n5",
		},
		n4 = {
			text = "Sozinho? Eu tenho a melhor companhia do mundo: a minha coleção. Vocês vão entender.",
			emote = "happy",
			effect = { clue = "EP06_C4", points = 110, flag = "anselmorSorriu" },
			next = "n5",
		},
		n5 = {
			text = "Uma dica de curador para vocês: museus nunca contam a história inteira. Só a parte que está pronta para ser vista.",
			emote = "neutral",
			onEnd = { points = 80 },
		},
	},
}

Dialogue.Nodes.EP06_Nina = {
	id = "EP06_Nina",
	title = "Nina, a restauradora",
	speaker = "EP06_Restauradora",
	start = "n1",
	nodes = {
		n1 = {
			text = "Eu restauro há 11 anos. E, nesses 11 anos, nunca vi uma tela ser coberta com tinta preta em um mês. Nunca.",
			emote = "angry",
			choices = {
				{ text = "(Velma) Tinta preta? Quem usa isso numa restauração?", next = "n2" },
				{ text = "(Daphne) A senhora encontrou alguma coisa embaixo da pintura?", next = "n3" },
			},
		},
		n2 = {
			text = "Ninguém! Nós usamos verniz, solvente, retoque com paciência de monge. Preto puro é pintura de cenário de teatro.",
			emote = "angry",
			effect = { clue = "EP06_C3", points = 130, objective = "EP06_C1_OB4" },
			next = "n4",
		},
		n3 = {
			text = "Sim. Um retrato de um homem com um anel, e no anel uma marca: 'C²'. A pintura original estava embaixo.",
			emote = "thinking",
			effect = { clue = "EP06_C6", points = 150, objective = "EP06_C2_OB5" },
			next = "n4",
		},
		n4 = {
			text = "Isso me deixa indignada. Não é maldição, é... é uma vergonha profissional!",
			emote = "angry",
			onEnd = { points = 70 },
		},
	},
}

Dialogue.Nodes.EP06_Hal = {
	id = "EP06_Hal",
	title = "Hal, o fotógrafo",
	speaker = "EP06_Fotografo",
	start = "n1",
	nodes = {
		n1 = {
			text = "Ensaio de moda em uma mansão mal-assombrada. Foi a melhor ideia da minha vida profissional e a pior da minha vida pessoal.",
			emote = "happy",
			choices = {
				{ text = "(Velma) Você fotografou o fantasma?", next = "n2" },
				{ text = "(Fred) Em que posição o vulto estava?", next = "n3" },
				{ text = "(Salsicha) Você tem água? E um lanche? E uma escada pra eu sair daqui?", next = "n4" },
			},
		},
		n2 = {
			text = "Fotografei por acidente. Flash disparou no momento errado. E o negativo tem uma coisa... estranha.",
			emote = "excited",
			effect = { clue = "EP06_C7", points = 130, objective = "EP06_C2_OB3" },
			next = "n5",
		},
		n3 = {
			text = "Em frente ao espelho grande. Sempre em frente ao espelho. Como se... precisasse ser refletido para funcionar.",
			emote = "thinking",
			effect = { clue = "EP06_C7", points = 150, objective = "EP06_C2_OB3" },
			next = "n5",
		},
		n4 = {
			text = "Água eu tenho. Lanche, não. Escada... você está a cinco minutos da porta da cozinha, meu amigo.",
			emote = "happy",
			effect = { flag = "halApontouPorta", points = 20 },
			next = "n5",
		},
		n5 = {
			text = "Se isso tudo virar matéria, eu quero crédito. Antes, durante e depois do susto.",
			emote = "happy",
			onEnd = { points = 70 },
		},
	},
}

Dialogue.Nodes.EP06_Anibal = {
	id = "EP06_Anibal",
	title = "Zelador Aníbal",
	speaker = "EP06_Zelador",
	start = "n1",
	nodes = {
		n1 = {
			text = "Quarenta anos nesta casa. Eu era menino quando o velho Blackwood ainda usava monóculo de verdade.",
			emote = "neutral",
			choices = {
				{ text = "(Fred) Como a gente chega nos túneis?", next = "n2" },
				{
					text = "(Velma) A senhora... perdão, o senhor já viu alguém usar a câmara central?",
					next = "n3",
					role = "Velma",
				},
				{ text = "(Daphne) Tem alguma coisa que ninguém te perguntou ainda?", next = "n4", role = "Daphne" },
			},
		},
		n2 = {
			text = "Pela cozinha. Tem uma porta atrás da despensa, escondida por um armário. Cuidado: os túneis dão voltas. É um ciclo.",
			emote = "worried",
			effect = { clue = "EP06_C8", points = 150, objective = "EP06_C2_OB4" },
			next = "n5",
		},
		n3 = {
			text = "Vi. Uma vez. Um homem de casaco escuro levando caixas. Ele tinha uma chave que não era da casa. Não era das nossas.",
			emote = "scared",
			effect = { clue = "EP06_C8", points = 150 },
			next = "n5",
		},
		n4 = {
			text = "Tem. Ninguém pergunta por que eu ainda trabalho aqui. É porque a casa é a única coisa que eu tenho. Igual ao Senhor Anselmo.",
			emote = "worried",
			effect = { clue = "EP06_C5", points = 130, flag = "anibalSabio" },
			next = "n5",
		},
		n5 = {
			text = "E olha: eu não vou acender as luzes do salão de espelhos. Nem que me paguem. Aquilo é coisa de teatro, não de casa.",
			emote = "neutral",
			onEnd = { points = 80 },
		},
	},
}

Dialogue.Nodes.EP06_Reveal = {
	id = "EP06_Reveal",
	title = "A Revelação — A Maldição de Blackwood",
	speaker = "Daphne",
	start = "n1",
	nodes = {
		n1 = {
			text = "Anselmo Blackwood! O curador que descobriu a maldição... e o único que ganhava com ela.",
			emote = "excited",
			sfx = "UnmaskStinger",
			next = "n2",
		},
		n2 = {
			text = "Ele cobriu os espelhos para esconder o truque, mas deixou um descoberto para as aparições.",
			emote = "thinking",
			next = "n3",
		},
		n3 = {
			text = "E a maldição tinha função jurídica: com a cláusula do testamento, nenhuma proposta de compra valia nada.",
			emote = "neutral",
			next = "n4",
		},
		n4 = {
			text = "Mas o túnel não é dele. A câmara central tem uma caixa por cidade... e alguém já levou a nossa. A caixa com laço dourado.",
			emote = "worried",
			effect = { clue = "EP06_C11", points = 200 },
			next = "n5",
		},
		n5 = {
			text = "Velma: 'Seis lotes. Seis casos. E o sétimo é Coolsville. Ele está nos chamando para o grande final.'",
			emote = "worried",
			next = "n6",
		},
		n6 = {
			text = "Scooby: 'RUH-ROH... Ru racho que rogora é ra sério.'",
			emote = "scared",
			onEnd = { points = 260 },
		},
	},
}

-- ==========================================================
-- ARCO FINAL
-- ==========================================================
Dialogue.Nodes.FINAL_Reveal = {
	id = "FINAL_Reveal",
	title = "O Grande Final — Coolsville Meia-Noite",
	speaker = "Velma",
	start = "n1",
	nodes = {
		n1 = {
			text = "A máscara... é de porcelana. E embaixo dela, um rosto que a cidade inteira conhece.",
			emote = "excited",
			sfx = "UnmaskStinger",
			next = "n2",
		},
		n2 = {
			text = "Ele comprava sustos como se comprassem selos. Seis lotes, seis cidades, seis artistas pagos em dinheiro.",
			emote = "thinking",
			next = "n3",
		},
		n3 = {
			text = "Nunca foi sobre dinheiro. Era sobre ter uma coleção que ninguém mais tinha: as pessoas que resolvem mistérios.",
			emote = "neutral",
			next = "n4",
		},
		n4 = {
			text = "E ele quase conseguiu. Se não fosse a única coisa que ele nunca soube comprar: uma turma de amigos.",
			emote = "happy",
			effect = { clue = "FINAL_C6", points = 300 },
			next = "n5",
		},
		n5 = {
			text = "Fred: 'Pessoal... o sol está nascendo atrás do penhasco. Vamos para casa?'",
			emote = "happy",
			next = "n6",
		},
		n6 = {
			text = "Salsicha: 'Tipo assim, casa, sim. Mas primeiro: lanche. Eu salvei o mundo de novo e estou faminto.'",
			emote = "happy",
			next = "n7",
		},
		n7 = {
			text = "Scooby: 'SCOOBY-DOOBY-DOOOO! Ran ran! Ru ru rer ralvar o rundo ra rovo!'",
			emote = "celebrate",
			onEnd = { points = 500 },
		},
	},
}

-- ==========================================================
-- VOICE LINES (falas dinâmicas por personagem)
-- ==========================================================
Dialogue.VoiceLines = {
	["Fred"] = {
		match = {
			"Pessoal, sigam o meu plano!",
			"Isso, juntos! Ninguém solta ninguém.",
			"A armadilha está armada. Falta ele pisar.",
			"Corram! Eu fico atrás dando cobertura!",
			"Mais uma pista e o caso fecha!",
		},
		monster = {
			"Ele veio! Todo mundo pelos lados, vamos separar!",
			"Ninguém corra em linha reta, ele corta caminho!",
			"Eu vou atrair ele para a armadilha. Confiem em mim!",
		},
		clue = {
			"Escutem, isso aqui não é natural. Anotem, Velma!",
			"Boa! Mais um pedaço do quebra-cabeça.",
			"É isso que eu chamo de pista boa!",
		},
	},
	["Daphne"] = {
		match = {
			"Eu acho que descobri alguma coisa!",
			"Reparem nos detalhes. Sempre estão nos detalhes.",
			"Essa pessoa está mentindo. Eu sinto.",
			"Fiquem perto de mim, eu não vou rasgar esse vestido por nada.",
			"Gente, olha isso! Que achado!",
		},
		monster = {
			"Não! Não vou correr de... tá bom, eu vou correr!",
			"Ele olhou pra mim! Alguém viu que ele olhou pra mim?!",
			"Vamos pelos fundos, é mais rápido!",
		},
		clue = {
			"Olha o estado disso. É recente, aposto a minha bolsa.",
			"Interessante... isso não estava aí antes.",
			"Perfeito. Agora eu quero ver quem explica isso.",
		},
	},
	["Velma"] = {
		match = {
			"Jinkies!",
			"As pistas estão fechando o caso.",
			"Isso é estatisticamente impossível... e, portanto, interessante.",
			"Preciso de um minuto para pensar. E de mais um ângulo.",
			"Dados atualizados. Mudei minha hipótese!",
		},
		monster = {
			"Padrão de perseguição previsível. Precisamos de corredores estreitos!",
			"A velocidade dele é maior que a nossa. Não corram em linha reta!",
			"Ele tem um ponto cego nessa rota. Vamos usar isso!",
		},
		clue = {
			"A composição dessa poeira indica... datação recente. Muito recente.",
			"Eu preciso medir duas coisas: o tempo e a distância.",
			"Elementar. Isso resolve metade do problema.",
		},
	},
	["Shaggy"] = {
		match = {
			"Tipo assim, eu não tô nem aí pra fantasma... eu tô MUITO aí.",
			"Eu só vim pela viagem, gente. Pela viagem e pelo lanche.",
			"Ninguém acredita em mim, mas eu sou bom nisso. De vez em quando.",
			"Se a gente resolver, tem lanche? Combina antes!",
			"Caramba! Tipo assim, CARAMBA!",
		},
		monster = {
			"SOCORRO! SOCORRO! Alguém, por favor, alguém!",
			"Não, não, não! Eu não quero ser fantasma de nada!",
			"Corre, Scooby, corre! Leva o sanduíche com a gente!",
		},
		clue = {
			"Tipo assim, isso aqui parece... isso aqui parece comida? Não? Tá.",
			"Eu achei! Eu! O Salsicha! Anota a data, Fred!",
			"Deixa eu ver de longe. De MUITO longe.",
		},
	},
	["Scooby"] = {
		match = {
			"Scooby-Dooby-Doo!",
			"Ruh-roh! Ran ran!",
			"Rnif... rnif... Rossa pista rem cheiro de ristério!",
			"Ru ro ro rontar! Ru ro ro rontar!",
			"Ran! Ralgo está pertinho!",
		},
		monster = {
			"RUH-ROH! Roi ran re rui ror aqui!",
			"Rui! Rui! Rai fora! Raguei ro ragou o Rnack!",
			"Ru re rarto rer ro ro? Ru rão ro ro rarto!",
		},
		clue = {
			"Ran! Ran! Rolha isso, Raggy!",
			"Rnif... isso ri rosto de reeente... ro rera ro ri!",
			"Ralando! Ralando! Ro raro!",
		},
	},
}

-- ==========================================================
-- HELPERS
-- ==========================================================
function Dialogue.get(id)
	return Dialogue.Nodes[id]
end

function Dialogue.getStartNode(id)
	local tree = Dialogue.Nodes[id]
	if not tree then
		return nil, nil
	end
	return tree, tree.nodes[tree.start]
end

-- Retorna uma fala aleatória do personagem na categoria pedida.
-- kinds válidos: match, monster, clue (ou nil = match)
function Dialogue.buildLine(characterId, kind, rng)
	local style = Dialogue.VoiceLines[characterId]
	if not style then
		return nil
	end
	local pool = style[kind or "match"]
	if not pool or #pool == 0 then
		pool = style.match
	end
	if not pool then
		return nil
	end
	local random = rng or Random.new()
	return pool[random:NextInteger(1, #pool)]
end

function Dialogue.countLines()
	local total = 0
	for _, tree in pairs(Dialogue.Nodes) do
		for _, node in pairs(tree.nodes) do
			if node.text then
				total += 1
			end
			for _, choice in ipairs(node.choices or {}) do
				total += 1
			end
		end
	end
	for _, style in pairs(Dialogue.VoiceLines) do
		for _, pool in pairs(style) do
			total += #pool
		end
	end
	return total
end

function Dialogue.validate()
	local problems = {}
	for id, tree in pairs(Dialogue.Nodes) do
		if not tree.start then
			table.insert(problems, "Árvore sem nó inicial: " .. id)
		elseif not tree.nodes[tree.start] then
			table.insert(problems, "Nó inicial inexistente: " .. id)
		else
			for nodeId, node in pairs(tree.nodes) do
				local function checkTarget(target)
					if target and not tree.nodes[target] then
						table.insert(problems, ("Alvo de diálogo inexistente: %s.%s -> %s"):format(id, nodeId, target))
					end
				end
				checkTarget(node.next)
				for _, choice in ipairs(node.choices or {}) do
					checkTarget(choice.next)
				end
				if not node.next and not node.choices and not node.onEnd then
					table.insert(problems, ("Nó sem saída em %s.%s"):format(id, nodeId))
				end
			end
		end
	end
	return #problems == 0, problems
end

return Dialogue
