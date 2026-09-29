#!/usr/bin/env node
/**
 * tools/lua_test.js
 * Executa os testes Luau (puros) do projeto fora do Roblox, usando wasmoon (Lua 5.4).
 * Uso: node tools/lua_test.js
 */
const fs = require("fs");
const path = require("path");
const { LuaFactory } = require("/tmp/luatools/node_modules/wasmoon");

const ROOT = path.resolve(__dirname, "..");
const SRC = path.join(ROOT, "src");
const WASMOON = "/tmp/luatools/node_modules/wasmoon";

async function main() {
  const factory = new LuaFactory();
  const lua = await factory.createEngine();

  // leitor de arquivos para o require em Lua
  // Downlevel mínimo de sintaxe Luau -> Lua 5.4 (apenas para os testes rodarem fora do Roblox).
  // Cobre atribuições compostas (a += b, a ..= b), que é a única extensão usada nos
  // módulos "puros" (GridNav, Util, Data/*).
  const COMPOUND = /^(\s*)([A-Za-z_][A-Za-z0-9_]*(?:\[[^\]]*\])*)\s*(\+|-|\*|\/|%|\.\.)=\s*(.+)$/;

  function downlevel(source) {
    return source
      .split("\n")
      .map((line) => {
        const match = COMPOUND.exec(line);
        if (!match) return line;
        const indent = match[1];
        const target = match[2];
        const operator = match[3];
        const value = match[4];
        return `${indent}${target} = ${target} ${operator} (${value})`;
      })
      .join("\n");
  }

  lua.global.set("__readSource", (relative) => {
    const full = path.join(ROOT, relative);
    if (!fs.existsSync(full)) return "";
    return downlevel(fs.readFileSync(full, "utf8"));
  });

  await lua.doString(`
    local loaded = {}
    local loading = {}
    local searchPaths = {
      "src/shared/", "src/shared/Data/", "src/server/", "src/server/Services/",
      "src/server/Builders/", "src/client/", "src/client/Controllers/", "src/client/UI/",
      "tests/", "",
    }

    function require(name)
      if loaded[name] ~= nil then return loaded[name] end
      if loading[name] then error("dependência circular em " .. name) end
      local source = nil
      for _, prefix in ipairs(searchPaths) do
        local candidate = prefix .. name .. ".luau"
        local text = __readSource(candidate)
        if text ~= nil and text ~= "" then
          source = text
          break
        end
      end
      if not source then
        error("módulo não encontrado: " .. name)
      end
      loading[name] = true
      local chunk = assert(load(source, "@" .. name, "t"))
      local result = chunk()
      loading[name] = nil
      loaded[name] = result
      return result
    end
  `);

  // stubs
  await lua.doString(fs.readFileSync(path.join(ROOT, "tests", "stubs.lua"), "utf8"));

  // runner
  const tests = fs.readdirSync(path.join(ROOT, "tests")).filter((f) => f.endsWith(".test.lua")).sort();
  let failures = 0;
  for (const testFile of tests) {
    const code = downlevel(fs.readFileSync(path.join(ROOT, "tests", testFile), "utf8"));
    try {
      const results = await lua.doString(code);
      console.log(`\n=== ${testFile} ===`);
      if (typeof results === "string") {
        console.log(results);
      } else if (Array.isArray(results)) {
        for (const line of results) console.log(line);
      } else if (results && typeof results === "object") {
        console.log(JSON.stringify(results));
      }
    } catch (error) {
      failures += 1;
      console.error(`\n[FALHA] ${testFile}: ${error.message}`);
    }
  }
  lua.global.close();
  if (failures > 0) {
    console.error(`\n${failures} arquivo(s) de teste falharam.`);
    process.exit(1);
  }
  console.log("\nTodos os testes passaram.");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
