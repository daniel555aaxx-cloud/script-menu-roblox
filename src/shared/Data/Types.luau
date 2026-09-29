--[[
	Types.luau
	Tipos compartilhados (usados como documentação + autocomplete no Studio).
	Não tem custo em runtime.
]]

export type ChapterId = string
export type EpisodeId = string
export type RoleId = "Fred" | "Daphne" | "Velma" | "Shaggy"
export type Privacy = "publica" | "somente_amigos" | "somente_convite" | "fechada"

export type Objective = {
	id: string,
	kind: string,
	label: string,
	points: number,
	optional: boolean?,
	npc: string?,
	clue: string?,
	marker: string?,
	deduction: string?,
	seconds: number?,
	count: number?,
}

export type Clue = {
	id: string,
	name: string,
	text: string,
	detail: string?,
	reveals: string?,
	evidence: boolean?,
}

export type Deduction = {
	id: string,
	question: string,
	options: { { text: string, correct: boolean, feedback: string } },
	logic: string,
	points: number,
}

export type Room = {
	id: string,
	label: string,
	kind: string,
	x: number,
	z: number,
	w: number,
	d: number,
	outdoor: boolean?,
	height: number?,
	tags: { string }?,
	floor: { material: string, color: string }?,
	wall: { material: string, color: string }?,
	ceiling: { material: string, color: string }?,
	light: { color: string, brightness: number, count: number }?,
}

export type Marker = {
	id: string,
	room: string,
	offset: { x: number, z: number }?,
	kind: string,
}

export type PlayerProfile = {
	userId: number,
	name: string,
	snacks: number,
	pontos: number,
	completedChapters: { [string]: boolean },
	completedEpisodes: { [string]: boolean },
	achievements: { [string]: boolean },
	owned: { [string]: boolean },
	equipped: { [string]: any },
	stats: { [string]: number },
}

export type PartyState = {
	id: string,
	leader: number,
	privacy: Privacy,
	members: { number },
	episodeId: string,
	chapterId: string,
	difficulty: string,
	state: "lobby" | "starting" | "in_match" | "finished",
}

return {}
