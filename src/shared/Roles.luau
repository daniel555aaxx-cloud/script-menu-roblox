--[[
	Roles.luau
	A turma do Mistério S.A. Cada jogador escolhe (ou recebe) um papel com uma
	habilidade ativa e um bônus passivo. O Scooby é sempre um NPC companheiro
	que auxilia o grupo, independente do número de jogadores.
]]

local Roles = {}

Roles.Order = { "Fred", "Daphne", "Velma", "Shaggy" }

Roles.List = {
	Fred = {
		id = "Fred",
		displayName = "Fred Jones",
		title = "O Líder",
		color = "Fred",
		hairColor = "FredHair",
		tagline = "Sempre tem um plano — e um pedaço de corda no bolso.",
		description = "Especialista em armadilhas. Monta armadilhas com uma etapa a menos e "
			.. "reconhece pontos de emboscada no mapa.",
		passive = "Armadilhas exigem 1 peça a menos e ficam armadas mais rápido.",
		active = {
			name = "Plano do Líder",
			description = "Marca no mapa os pontos de armadilha e aumenta a velocidade do grupo por 12s.",
			cooldown = 45,
			duration = 12,
		},
		perks = {
			trapPartsNeeded = -1,
			trapArmSpeed = 1.35,
			partySpeedBonus = 1.12,
		},
	},
	Daphne = {
		id = "Daphne",
		displayName = "Daphne Blake",
		title = "A Persuasiva",
		color = "Daphne",
		hairColor = "DaphneHair",
		tagline = "Ela sempre encontra uma porta destrancada — ou uma fofoca reveladora.",
		description = "Consegue arrancar informações extras dos NPCs e abre passagens trancadas.",
		passive = "NPCs dão uma fala secreta adicional (+pontos) e portas trancadas abrem mais rápido.",
		active = {
			name = "Charme Investigativo",
			description = "Revela o próximo objetivo no minimapa e acalma o medo do grupo.",
			cooldown = 50,
			duration = 10,
		},
		perks = {
			extraDialogue = true,
			unlockSpeed = 1.5,
			fearRelief = 40,
		},
	},
	Velma = {
		id = "Velma",
		displayName = "Velma Dinkley",
		title = "O Cérebro",
		color = "Velma",
		hairColor = "VelmaHair",
		tagline = "Jinkies! As pistas nunca mentem — só as pessoas.",
		description = "Analisa pistas à distância e deduz mais rápido. Fundamental para desmontar álibis.",
		passive = "Escaneia pistas em um raio grande e recebe +1 combo de dedução.",
		active = {
			name = "Análise Forense",
			description = "Escaneia a área e destaca todas as pistas próximas por 20s.",
			cooldown = 40,
			duration = 20,
		},
		perks = {
			scanRadius = 55,
			deductionBonus = 1,
			clueSpeed = 1.4,
		},
	},
	Shaggy = {
		id = "Shaggy",
		displayName = "Salsicha Rogers",
		title = "A Isca (por acidente)",
		color = "Shaggy",
		hairColor = "ShaggyHair",
		tagline = "Tipo assim, eu prefiro um sanduíche gigante a um fantasma... mas tá bom.",
		description = "Especialista em distrações com comidas. Corre rápido quando está com medo.",
		passive = "Começa com 3 Scooby Snacks extras e corre mais rápido em pânico.",
		active = {
			name = "Sanduíche Distrativo",
			description = "Joga um lanche gigante que atrai NPCs e monstros por alguns segundos.",
			cooldown = 35,
			duration = 8,
		},
		perks = {
			extraSnacks = 3,
			panicSpeed = 1.2,
			distractRadius = 26,
		},
	},
}

Roles.Scooby = {
	id = "Scooby",
	displayName = "Scooby-Doo",
	title = "O Melhor Amigo",
	description = "NPC companheiro que segue o grupo. Dá dicas de 'Sentido Scooby' quando algo "
		.. "está perto, late para avisar do monstro e adora um Scooby Snack.",
	perks = {
		senseRadius = 45,
		warnRadius = 34,
		snackAffinity = 1.5,
	},
}

function Roles.get(id)
	return Roles.List[id] or Roles.List.Fred
end

function Roles.isValid(id)
	return Roles.List[id] ~= nil
end

-- Distribui papéis automaticamente quando há menos jogadores que papéis.
function Roles.assign(playerIds, preferred)
	local assignment = {}
	local taken = {}
	for _, playerId in ipairs(playerIds) do
		local choice = preferred and preferred[playerId] or nil
		if choice and Roles.isValid(choice) and not taken[choice] then
			assignment[playerId] = choice
			taken[choice] = true
		end
	end
	for _, playerId in ipairs(playerIds) do
		if not assignment[playerId] then
			for _, roleId in ipairs(Roles.Order) do
				if not taken[roleId] then
					assignment[playerId] = roleId
					taken[roleId] = true
					break
				end
			end
		end
		-- com mais jogadores que papéis (não acontece com 4), libera o papel
		if not assignment[playerId] then
			assignment[playerId] = Roles.Order[1]
		end
	end
	return assignment
end

return Roles
