#!/usr/bin/env node
/*
	check_project.js — validação estática do projeto (roda sem Roblox):
	  1. default.project.json coerente com as pastas
	  2. todo remote usado no código existe na lista do Net.luau
	  3. todo serviço/builder/controller exporta as funções esperadas
	  4. nenhum arquivo vazio / nenhuma sintaxe de tabela suspeita

	Use: node tools/check_project.js
*/

const fs = require("fs");
const path = require("path");

const root = process.cwd();
let failures = 0;
const log = (ok, message) => {
	console.log(`  [${ok ? "ok" : "FALHOU"}] ${message}`);
	if (!ok) failures++;
};

const read = (p) => fs.readFileSync(path.join(root, p), "utf8");
const walk = (dir, filter, out = []) => {
	for (const entry of fs.readdirSync(path.join(root, dir), { withFileTypes: true })) {
		const rel = path.join(dir, entry.name);
		if (entry.isDirectory()) walk(rel, filter, out);
		else if (filter(rel)) out.push(rel);
	}
	return out;
};

console.log("=== default.project.json ===");
const project = JSON.parse(read("default.project.json"));
const tree = project.tree ?? {};
log(tree.$className === "DataModel", "arvore raiz e um DataModel");
log(tree.ReplicatedStorage?.Shared?.$path === "src/shared", "ReplicatedStorage.Shared -> src/shared");
log(tree.ServerScriptService?.Server?.$path === "src/server", "ServerScriptService.Server -> src/server");
log(
	(tree.StarterPlayer?.StarterPlayerScripts?.Client?.$path ?? "").startsWith("src/client"),
	"StarterPlayerScripts.Client -> src/client"
);
log(fs.existsSync(path.join(root, "src/server/init.server.luau")), "init.server.luau existe");
log(fs.existsSync(path.join(root, "src/client/init.client.luau")), "init.client.luau existe");

console.log("=== Net.luau vs uso real ===");
const net = read("src/shared/Net.luau");
const declared = new Set();
for (const block of net.matchAll(/Net\.(?:Events|Functions)\s*=\s*\{([\s\S]*?)\n\}/g)) {
	for (const m of block[1].matchAll(/"([A-Za-z][A-Za-z0-9]*)"/g)) declared.add(m[1]);
}
log(declared.size >= 40, `Net declara ${declared.size} remotes`);

const luauFiles = walk("src", (p) => p.endsWith(".luau"));
const used = new Set();
for (const file of luauFiles) {
	const source = read(file);
	for (const m of source.matchAll(/Net\.(?:Event|Function|fireClient|fireAll|fireServer|invokeServer)\(\s*(?:player\s*,\s*)?"([A-Za-z][A-Za-z0-9]*)"/g)) {
		used.add(m[1]);
	}
}
const missing = [...used].filter((name) => !declared.has(name));
log(missing.length === 0, `todos os ${used.size} remotes usados existem no Net.luau${missing.length ? ` (faltando: ${missing.join(", ")})` : ""}`);

console.log("=== Serviços e builders ===");
const services = walk("src/server", (p) => p.endsWith(".luau"));
for (const file of services) {
	const source = read(file);
	if (file.endsWith("init.server.luau")) continue;
	const isService = file.includes("Services");
	const name = path.basename(file);
	if (isService) {
		log(/function\s+\w+\.start\s*\(/.test(source), `${name} expõe .start()`);
	}
	log(source.trim().endsWith("return " + path.basename(file, ".luau")), `${name} retorna o próprio módulo`);
}

console.log("=== Controllers (cliente) ===");
for (const file of walk("src/client", (p) => p.endsWith(".luau"))) {
	const source = read(file);
	const name = path.basename(file, ".luau");
	if (name === "init.client" || name === "UIKit") continue;
	log(/function\s+\w+\.start\s*\(/.test(source), `${name} expõe .start()`);
}

console.log("=== Higiene de código ===");
let suspicious = [];
for (const file of luauFiles) {
	const source = read(file);
	// erros clássicos de heredoc: `chave: valor` fora de string de tipo
	const badColonValue = source.match(/\b(points|count|size|price|seconds|level|index)\s*:\s*[0-9]/g);
	if (badColonValue) suspicious.push(`${file}: ${badColonValue.join(", ")}`);
	log(source.split("\n").length > 5, `${path.basename(file)} tem conteúdo`);
}
log(suspicious.length === 0, `nenhuma tabela com ':' no lugar de '='${suspicious.length ? ` (${suspicious.join(" | ")})` : ""}`);

console.log("");
if (failures === 0) {
	console.log("check_project: tudo certo ✔");
	process.exit(0);
} else {
	console.log(`check_project: ${failures} problema(s) ✘`);
	process.exit(1);
}
