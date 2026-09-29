# Arquitetura

## Visão geral

```
CLIENTE                             SERVIDOR
┌────────────────────────┐          ┌──────────────────────────────────────┐
│ init.client.luau       │          │ init.server.luau (bootstrap)         │
│  HudController         │◄─remotes─┤  ProfileService   PartyService       │
│  DialogueController    │          │  MapService       MatchService       │
│  CutsceneController    │          │  ClueService      TrapService        │
│  EffectsController     │          │  MonsterService   DialogueService    │
│  LobbyController       │          │  InteractionService CharacterService │
│  InputController       │          │  Shop/Achievement/Audio/Cutscene     │
└────────────────────────┘          └──────────────────────────────────────┘
         ▲                                        │
         └────────── ReplicatedStorage.Shared ────┘
                (Config, Net, GridNav, Graphics,
                 Roles, Assets, Data/*)
```

**Regra de ouro:** o servidor é a única fonte de verdade (pistas, pontos,
armadilhas, captura). O cliente só desenha e pede ações.

## Fluxo de uma partida

```
Lobby (sede)
  └─ PartyService: turma 1–4, privacidade, convites
       └─ líder escolhe episódio → contagem 8s → PartyStarted
            └─ MatchService.startMatch
                 └─ startChapter (por capítulo)
                      ├─ MapService.teleportTo  (turma inteira para o mapa)
                      ├─ DialogueService.spawnChapter (NPCs na sala certa)
                      ├─ CutsceneService.playIntro (slides do capítulo)
                      ├─ InteractionService.refreshMap (liga prompts do capítulo)
                      └─ fase Playing → objetivos
                           ├─ ClueService.collect → quadro de pistas
                           ├─ MatchService.resolveDeduction (deduções)
                           ├─ TrapService (peças → montar → iscar → armar)
                           ├─ MonsterService (IA: patrulha/visão/isca/captura)
                           └─ todos objetivos concluídos → finishChapter
                                └─ CutsceneService.playReveal (máscara fora)
                                     └─ próximo capítulo | fim do episódio
                                          └─ returnToLobby → escolher o próximo caso
```

## Mapas em grade

* Cada célula tem **8 studs** (`Config.Grid.CELL`).
* `Locations.luau` descreve **salas e corredores** (retângulos) + **markers**
  (pistas, NPCs, armadilhas, saídas). O `MapBuilder` escava essas áreas na grade,
  gera paredes nas divisas (com mesclagem de segmentos por material) e tetos.
* `GridNav` faz A* puro com custo por tag, linha de visão e conversão
  mundo↔célula; o `MonsterService` patrulha/persegue por ele — **sem
  PathfindingService**, o que deixa a IA determinística e barata.
* `Props.luau` tem ~80 props e **temas por tipo de sala** (`Props.RoomThemes`);
  o `Decorator` distribui os props por `placement` (wall/corner/center/scatter)
  com semente fixa: o mapa é **igual em todos os servidores**.

## Serviços do servidor (resumo)

| Serviço | Responsabilidade |
|---|---|
| `ProfileService` | perfil, Scooby Snacks, conquistas, progresso, DataStore com fallback |
| `PartyService` | turmas, privacidade (inclui **somente amigos**), convites, lobby |
| `MatchService` | máquina de estados dos capítulos, objetivos, pontos, revelação |
| `MapService` | construir/reusar mapas, teleportar turmas, aplicar humor visual |
| `ClueService` | coleta de pistas, quadro de evidências, dicas pagas |
| `TrapService` | peças, montagem, isca, armar, captura, validação remota |
| `MonsterService` | IA (patrol/search/chase/lured/captured), sustos, captura |
| `DialogueService` | spawn de NPCs + motor de diálogo com efeitos |
| `InteractionService` | roteia todos os `ProximityPrompt` por tipo |
| `CharacterService` | papéis, spawn/respawn, modelos clássicos ou avatar |
| `ShopService` | loja da van e aplicação dos grants |
| `AchievementService` | conquistas e notificações |
| `AudioService` | música/atmosfera por humor |
| `CutsceneService` | intros, aparição do monstro, captura e revelação |

## Rede (`Net.luau`)

* `Net.Events` (~40) — eventos fire-and-forget nos dois sentidos.
* `Net.Functions` — `GetLobbyState`, `GetEvidence`, `GetParty`, `ValidateTrapStep`.
* `Net.bootstrap()` cria tudo no servidor antes de qualquer serviço rodar; o
  cliente usa `WaitForChild`, então não há corrida de inicialização.

## Como estender

* **Novo capítulo**: adicione em `Episodes.Chapter[*]` (objetivos, pistas,
  deduções, trapSpots, reveal) e ajuste `nextChapter`. Nada mais.
* **Novo NPC**: `Cast.Npcs` (com `homeRoom` e `dialogue`) + árvore em
  `Dialogue.Nodes` + marker `kind = "npc"` no mapa.
* **Novo prop**: `Props.Library` + entrada no tema da sala (`Props.RoomThemes`).
* **Novo monstro**: `Cast.Monsters[EPxx]` com `model.parts` (spec 3D) e `ai`.
