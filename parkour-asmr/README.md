# 🏃‍♂️ Parkour ASMR — 42 Níveis em 7 Mundos

Mapa de parkour para **Roblox Studio** com **mais de 40 fases**, sons de teclado
ASMR satisfatórios, progresso salvo e HUD completa em português.

**Arquivo para importar:** [`Parkour_ASMR.rbxlx`](./Parkour_ASMR.rbxlx)

![Prévia do mapa](./preview_mapa.png)

---

## ⬇️ Como importar no Roblox Studio

1. Baixe o arquivo `Parkour_ASMR.rbxlx` (botão *Download* do GitHub).
2. Abra o **Roblox Studio** e vá em **Arquivo → Abrir do projeto…** (ou `Ctrl+O`).
3. Navegue até a pasta baixada e selecione `Parkour_ASMR.rbxlx`.
4. Aperte **F5** (ou ▶ *Play*) para testar. Pronto — é só jogar!

> Não é necessário copiar scripts manualmente: todo o jogo (mapa, sons, HUD e
> progresso) já vem dentro do arquivo.

---

## 🎮 Controles

| Tecla | Ação |
|---|---|
| **W A S D** | Andar |
| **ESPAÇO** | Pular |
| **SHIFT** | Correr |
| **K** | Ligar / desligar o som ASMR |
| **R** | Reiniciar a tentativa (volta ao último nível) |

---

## 🗺️ O que tem no mapa

### 42 níveis — 7 mundos
1. **Praia Inicial** (níveis 1–6) — tutoriais suaves: correntes, escadaria, pista de velocidade e balsa.
2. **Jardins Verdes** (7–12) — primeiroas plataformas que somem e giratória.
3. **Deserto Dourado** (13–18) — pulos precisos, elevador e corrida rápida.
4. **Caverna de Jade** (19–24) — placas que caem, escadaria longa e **boost**.
5. **Fábrica de Ferro** (25–30) — feixes estreitos, plataforma lateral e pistas de velocidade.
6. **Névoa Rubra** (31–36) — desafio avançado: **giratória de 2 barras** e quedas.
7. **Céu Real** (37–42) — alta altitude, boost, placas que somem e o pulo final.

### Mecânicas
- **Pads de boost** (roxo) — lançamento vertical para alcançar plataformas altas.
- **Pads de velocidade** (laranja) — `WalkSpeed` temporário para vãos longos.
- **Plataformas que somem** (ciano) — aparecem e desaparecem em ciclo; pisca antes de sumir.
- **Plataformas que caem** — treme ao tocar e despenca.
- **Balsas e elevadores** — movimentos horizontais e verticais.
- **Plataformas laterais** e **feixes estreitos**.
- **Giratórias** — 1 ou 2 barras girando (encoste = respawn).
- **Pilares de luz** marcam cada checkpoint de longe.
- **Lava** embaixo de todo o percurso; **placas de mundo** na entrada de cada fase.

### Progresso
- **DataStore** (salva automático): último nível e moedas — continua de onde parou.
- **HUD**: nome do mundo, `NÍVEL x / 42`, barra de progresso, **moedas**, **cronômetro** e **contador de mortes**.
- Ao terminar: tela de comemoração com **tempo da tentativa**, mortes e confete.

---

## 🔊 Sobre o som ASMR

O jogo toca sons de teclado (tecla, espaço, enter, moeda…) em ritmo de jogo.
Aperte **K** para ligar/desligar a qualquer momento.

- Os áudios usam IDs públicos no estilo "sound packs" de teclado.
- **Aviso (política de áudio do Roblox, pós-2022):** áudios só tocam no Studio
  se a conta que abrir o place tiver permissão sobre eles. Os IDs foram escolhidos
  para funcionar no máximo de cenários possível, mas se algum não tocar na sua
  conta, troque o ID em `ASMRKeyboard` (clique com botão direito no script →
  *View Connections* não se aplica; é só editar a lista `KEY_SOUNDS`) por um áudio
  que você tenha licença.
- Todos os textos do jogo são em português.

---

## 🧩 Estrutura do place

```
Workspace
└─ ParkourMap
   ├─ Lobby            (spawn + boas-vindas)
   ├─ Course
   │  ├─ Platforms           plataformas comuns
   │  ├─ Checkpoints         Checkpoint_1 … Checkpoint_42
   │  ├─ Movers              balsas, elevadores, laterais
   │  ├─ FallingPlatforms    que caem ao tocar
   │  ├─ VanishPlatforms     que somem em ciclo
   │  ├─ Pads                boost e velocidade
   │  ├─ Spinners            barras giratórias
   │  ├─ Coins               colecione para a contagem
   │  └─ Finish
   ├─ Decor            (placas, pilares de luz — criados pelo MapSetup)
   └─ Hazards          (lava)
Lighting               (céu, névoa, bloom, color correction)
SoundService
ReplicatedStorage       (RemoteEvent ParkourFX, criado em runtime)
ServerScriptService
   ├─ GameCore         checkpoints, moedas, pads, DataStore, obstáculos
   └─ MapSetup         placas dos mundos, pilares, brasas, confete
StarterPlayer
   ├─ StarterPlayerScripts
   │  ├─ ASMRKeyboard      sons de teclado (LocalScript)
   │  └─ ParkourHUD        HUD em português (LocalScript)
   └─ StarterCharacterScripts
```

---

## 🔧 Regenerar o arquivo (opcional)

O `.rbxlx` é gerado por código — assim dá para balancear e reconstruir:

```bash
cd parkour-asmr
python3 build_parkour.py     # regenera Parkour_ASMR.rbxlx
```

- Os scripts de jogo ficam em `src/*.lua` e são embutidos na hora do build
  (edite o `.lua` e rode o build de novo).
- O build **valida sozinho**: XML bem-formado, 42 checkpoints, todos os
  obstáculos referenciados e **auditoria de alcance** (todo pulo ≤ 7,3 studs,
  exceto pistas de velocidade, e descidas ≤ 4,5 studs).

---

## ❓Problemas comuns

| Problema | Solução |
|---|---|
| Botão Play desabilitado | Ative com *Test → Clients and Servers* ou clique em ▶ normalmente |
| Som não toca | Veja o aviso de áudio acima; teste com a conta dona do place |
| Progresso não salva no Studio | Game Settings → *Security* → **Enable Studio Access to API Services** |
| Quer testar sozinho | *Test → Clients and Servers → 1 Player* |
| Quer mudar a dificuldade | Ajuste `WORLD_SCHEDULE` no `build_parkour.py` e rebuild |
