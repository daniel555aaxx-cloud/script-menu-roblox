# Como rodar

## 1. Rojo (recomendado)

```bash
# instalar (uma vez)
aftman install          # ou: cargo install rojo

# na raiz do repositório
rojo serve
```

No Studio: **Plugins → Rojo → Connect**. O `default.project.json` já cria:

* `ReplicatedStorage.Shared` → `src/shared`
* `ReplicatedStorage.Remotes` (pasta vazia — os remotes são criados em runtime)
* `ServerScriptService.Server` → `src/server`
* `StarterPlayer.StarterPlayerScripts.Client` → `src/client`
* `ServerStorage.CustomModels` (para modelos próprios)

## 2. Sem Rojo (manual)

Crie ModuleScripts com o conteúdo dos arquivos:

| Arquivo do repo | Nome no Studio | Tipo | Local |
|---|---|---|---|
| `src/shared/*.luau` | mesmo nome | ModuleScript | `ReplicatedStorage.Shared` |
| `src/shared/Data/*.luau` | mesmo nome | ModuleScript | `ReplicatedStorage.Shared.Data` |
| `src/server/Services/*.luau` | mesmo nome | ModuleScript | `ServerScriptService.Server.Services` |
| `src/server/Builders/*.luau` | mesmo nome | ModuleScript | `ServerScriptService.Server.Builders` |
| `src/server/init.server.luau` | `Server` | Script | `ServerScriptService` |
| `src/client/Controllers/*.luau` | mesmo nome | ModuleScript | `StarterPlayer…Client.Controllers` |
| `src/client/Modules/UIKit.luau` | `UIKit` | ModuleScript | `StarterPlayer…Client.Modules` |
| `src/client/init.client.luau` | `Client` | LocalScript | `StarterPlayerScripts` |

> A configuração do `default.project.json` já deixa `CharacterAutoLoads = false`
> e `Workspace.StreamingEnabled = false`; se você montar manualmente, ative
> `StreamingEnabled` **desligado** e `Lighting.Technology = Future`.

## 3. Ajustes recomendados no Studio

* **Game Settings → Avatar**: R15 (o jogo usa o avatar do jogador; os modelos
  clássicos continuam disponíveis via `CharacterService.forceClassic = true`).
* **Game Settings → Options**: `MaxPlayers` 4–24 (padrão 24; cada turma tem sua
  própria partida).
* **Lighting**: sombras ligadas, `EnvironmentSpecularScale` alto para o visual
  "cinematográfico" (`Graphics.serverBaseLighting()` já aplica o básico).
* **DataStores**: publique o jogo para o progresso salvar (em Studio o serviço
  cai para memória automaticamente e tudo continua funcionando).

## 4. Publicando

```bash
rojo build -o MysteryMachine.rbxlx   # gera o lugar pronto
```

Depois abra o `.rbxlx`, publique em **File → Publish to Roblox** e ative
`Enable Studio Access to API Services` em Game Settings → Security (para o
DataStore de perfil).
