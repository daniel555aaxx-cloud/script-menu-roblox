# Mistério S.A. — Arquivos do Mistério 🐕‍🦺🔎

Jogo completo de **Scooby-Doo para Roblox**: modo história com lobby que puxa a
partida, turmas de **1 a 4 jogadores** (com opção de **somente amigos**), NPCs
com fala, monstros com IA, armadilhas clássicas da turma e um final em que
você tira a máscara do vilão.

> **Temporada 1 — "Seis sustos, uma assinatura: C²"**
> Prólogo na sede + **6 episódios** (4 capítulos cada) + **final em 3 capítulos**
> = **27 capítulos**, ~30 mil pontos de campanha, 26 NPCs e 7 monstros.

---

## Como rodar

1. **Instale o Rojo** (`aftman install` ou `cargo install rojo`).
2. No terminal, dentro desta pasta:

   ```bash
   rojo serve
   ```

3. No Roblox Studio: **Plugins → Rojo → Connect** (localhost:34872).
4. Aperte **Play**: você nasce na sede do Mistério S.A. Aparece o lobby (tecla `L`).

Sem Rojo? Copie manualmente:

| Pasta do repositório | Destino no Studio  |
|----------------------|--------------------|
| `src/shared`         | `ReplicatedStorage.Shared` (ModuleScripts) |
| `src/server`         | `ServerScriptService.Server` (Script `init.server`) |
| `src/client`         | `StarterPlayer.StarterPlayerScripts.Client` (LocalScript `init.client`) |

Detalhes em [`docs/COMO-RODAR.md`](docs/COMO-RODAR.md).

---

## Controles

| Tecla | Ação |
|-------|------|
| `L` | Abre/fecha o painel de **turma** (party) |
| `E` | Interagir (pistas, peças de armadilha, NPCs, portas) |
| `Q` | Quadro de pistas |
| `H` | Dica da Velma (custa Scooby Snacks) |
| `T` | Provocar o fantasma (isca) |
| `F` | Lanterna |
| `SHIFT` | Correr (com estamina) |
| `P` | Pular cutscene |

---

## O que o jogo tem

### Modo história com lobby que puxa a partida
- Turmas **1–4 jogadores** com **4 níveis de privacidade**: pública,
  **somente amigos** (valida amizade no servidor), somente convite e fechada.
- O líder escolhe o caso, todos marcam "pronto" e a contagem regressiva puxa a
  partida automaticamente. A turma inteira vai junta para o mapa.
- Vários grupos jogam ao mesmo tempo no mesmo servidor (lobby compartilhado,
  partidas independentes).

### Casos do desenho e do filme
Cada episódio é um "caso de fantasma" com truque explicável — o clássico
"não era fantasma, era alguém querendo algo":

| EP | Caso | Cenário | Monstro | Culpado |
|----|------|---------|---------|---------|
| 1 | O Fantasma do Farol | Porto Pedra | Phantom Lightkeeper | Cole, o especulador |
| 2 | O Hóspede do Quarto 13 | Hotel Bella Vista | O Hóspede | Igor Zappa, o mágico |
| 3 | O Palhaço Sem Riso | Circo Risonho | Palhaço Sem Riso | Bibo, o trapezista |
| 4 | A Fábrica Assombrada | Fábrica Kraft | Operário Sombrio | Sônia Kraft, a dona |
| 5 | O Cavaleiro do KM 13 | Estrada Velha | Cavaleiro Caolho | Seu Otávio, o mecânico |
| 6 | A Maldição de Blackwood | Mansão Blackwood | A Dama de Preto | Curador Anselmo |
| F | O Colecionador | Penhasco de Coolsville | O Colecionador | (o vilão da temporada) |

### NPCs com falas
- **26 NPCs** com árvore de diálogo própria (`Dialogue.luau`, ~300 nós),
  escolhas por personagem (algumas falas são exclusivas do Fred, da Daphne, da
  Velma ou do Salsicha), efeitos de pista, objetivo, pontos e flags.
- **Voice lines** dinâmicas: a turma reage a sustos, pistas, perseguição e
  revelação (`Dialogue.buildLine`).

### Gráficos e modelos 3D fiéis
- Cada monstro tem **spec 3D declarativa** em `Cast.luau` (peças, cores,
  materiais, emissivos, animação de flutuação, partículas) — o `CharacterBuilder`
  monta tudo em código.
- A turma tem modelos clássicos (Fred de camisa azul e cachecol laranja, Daphne
  de roxo, Velma de suéter laranja, Salsicha de verde, Scooby com coleira azul e
  medalha).
- Iluminação cinematográfica com **5 presets** (Baixo → Cinema), atmosfera por
  episódio (`Graphics.Moods`), sombras, luzes com flicker e PBR opcional
  (`PartKit.surfaceAppearance`).
- Para usar **modelos próprios** (do filme/desenho): coloque-os em
  `ServerStorage.CustomModels` e ligue `Assets.hasCustomModel` — veja
  `docs/ASSETS-E-GRAFICOS.md`.

### Gameplay
- **Investigação:** explore, examine pistas, converse, monte deduções no quadro.
- **Armadilha em 3 partes:** encontre as peças → monte → isque → arme →
  capture o monstro (rede, contrapeso, corda…).
- **IA do monstro:** patrulha com A* próprio (sem PathfindingService), detecta
  por visão/audição, persegue, é atraído por isca e fica preso na armadilha.
- **Medo, estamina, lanterna, Scooby Snacks** (moeda), loja, conquistas,
  4 dificuldades e skins.

---

## Estrutura

```
src/
  shared/            -- roda nos dois lados
    Config.luau      -- constantes de balanceamento
    GridNav.luau     -- grade + A* + linha de visão
    Net.luau         -- ~40 eventos + 4 RemoteFunctions
    Graphics.luau    -- presets de gráfico e humores por episódio
    Roles.luau       -- papéis (ativo + passivo + perks) da turma
    Data/
      Cast.luau      -- heróis, Scooby, 26 NPCs, 7 monstros (spec 3D)
      Episodes.luau  -- prólogo + EP01–EP06 + FINAL (27 capítulos)
      Dialogue.luau  -- árvores de diálogo + voice lines
      Locations.luau -- 8 mapas em grade (sala/corredor/markers)
      Props.luau     -- biblioteca de ~80 props + temas por tipo de sala
      Definitions.luau -- loja, conquistas, skins, dificuldades
      Assets.luau    -- sons embutidos + slots de upload opcionais
  server/
    init.server.luau -- bootstrap (13 serviços)
    Services/        -- Match, Party, Profile, Map, Clue, Trap, Monster,
                        Dialogue, Interaction, Character, Shop, Achievement,
                        Audio, Cutscene
    Builders/        -- PartKit, MapBuilder, Decorator, CharacterBuilder
  client/
    init.client.luau -- bootstrap
    Controllers/     -- Hud, Dialogue, Cutscene, Effects, Lobby, Input
    Modules/UIKit    -- biblioteca de UI (tema Arquivos do Mistério)
tests/               -- testes Lua puros (rodam fora do Roblox)
tools/               -- runners de teste e checagem estática
docs/                -- documentação
```

---

## Testes (rodam sem Roblox)

```bash
node tools/lua_test.js     # 1.657 checagens: navegação, mapas, história, elenco
node tools/check_project.js # validação estática do projeto e dos remotes
```

Os testes cobrem: A* e linha de visão, **todos os markers de todos os mapas
alcançáveis a pé**, coerência capítulo↔mapa↔NPC↔pista↔dedução↔armadilha,
diálogos (nós órfãos, falas), elenco, loja e assets.

---

## Licença / aviso

Projeto de fã, feito como demonstração técnica. *Scooby-Doo* e seus personagens
são marcas da Warner Bros. Discovery — use com responsabilidade e sem fins
comerciais.
