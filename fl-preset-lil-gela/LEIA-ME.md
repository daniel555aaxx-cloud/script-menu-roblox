# Preset vocal "GELA" — emo trap BR (lilgiela33 / Lil Gela) para FL Studio

> Pacote completo: análise do estilo + cadeia de efeitos com valores + script que
> salva/aplica a sua cadeia como preset permanente.
> Feito para **FL Studio 20/21/24/25 (Windows ou Mac)**. Nada de plugin pago é obrigatório.

---

## 0. O que tem nesta pasta

| Arquivo | Para que serve |
|---|---|
| `LEIA-ME.md` | Este documento: análise + preset + como instalar no FL |
| `colinha-vocal-lilgela.txt` | Só os números, formato texto (abre no celular enquanto grava) |
| `fl_chain_tool.py` | Script Python que roda **dentro** do FL Studio: salva a sua cadeia num arquivo de texto e reaplica em qualquer projeto/PC (`dump()` / `apply()`) |
| `test_fl_chain_tool.py` | Teste offline do script (simula a API do FL). Se você não programa, ignore. |

**Sobre "o arquivo":** o FL Studio **não** importa preset de plugin de áudio escrito à mão — os
formatos (`Maximus`, `Fruity Limiter`, VST de terceiros) são binários/proprietários. Os "packs de
preset" que circulam por aí são projetos `.fst`/`.zip` cheios de lixo. Então este pacote faz o
caminho certo: **a receita abaixo + o `fl_chain_tool.py`**, que gera um preset de verdade com os
SEUS valores e pode transferi-lo entre projetos. A seção 6 tem o passo a passo.

---

## 1. Análise: como é o vocal do Lil Gela

Contexto confirmado: **lilgiela33** (Lil Gela), rapper underground de **Brasília**, uma das
referências do **emo trap nacional**; comparado o tempo todo a **Lil Peep** pela mistura de hip hop
+ rock alternativo + estética de internet. Discografia citada nas fontes: *Desordem* (2023),
*Tanto Faz* (2024), *33 / 33 Pt.2*, *HATE THIS ALBUM* (2026); faixas mais tocadas: "Merdas
Acontecem", "Última Vez", "Mesma Pessoa", "Amigos", "Eu Te Esqueci Garota", "Gaap", "Catfish",
"KPeruana", "Junky", "Deseja minha m\*rte", "Emozinhas boas". Circula com akao.47, Nick Ghost,
Sobenk, King Kondi, Petrus, Joloswagboy, SR S7V3N, yung vegan, Caio Ocean; produção de peedzh,
BEATPLUGGZ etc. Temas: solidão, dependência, excesso, conflitos internos.

### 1.1 Dados duros do catálogo (tom / BPM)

Do banco de análise do Spotify (via SongBPM/Tunebat), nas faixas que eles indexam:

| Faixa | Tom | BPM | Obs |
|---|---|---|---|
| Merdas Acontecem | **B menor** | 150 (ou 75 half-time) | prod. peedzh, 2:46 |
| Catfish | G♯/A♭ | 108 | 2:37 |
| Amigo da Onça | G♯/A♭ | 120 | 1:46 |
| Beyblade | A♯/B♭ | 103 | |
| Columbine | A♯/B♭ | 117 | |
| Casaco de Couro | C | 117 | |
| Chorando Mais... | F♯/G♭ | 132 | |
| Amigos | D♯/E♭ | 166 | |
| Eu Quase Desisti de Mim | C♯ menor | 147 | |
| Não Amo Mais Ela | F♯ menor | 140 | |
| Emozinhas Boas | C **maior** | 76 | rara exceção maior |

**O que isso significa na prática, e é isso que muda o preset:**

1. **Quase tudo é menor.** Escala padrão do afinador: **Natural Minor**. Trocar pra Major só em
   faixa clara/pra cima (tipo "Emozinhas Boas"). Errar a escala é o motivo nº 1 de autotune soar
   ruim — e com tanta música em A♭/B♭/B/C♯, "usar o tom do projeto" (AutoKey / Key do Beat) vale
   mais que qualquer EQ.
2. **BPM 100–170, mas o flow mora no half-time** (52–85 batidas reais). Frases longas, arrastadas,
   terminando escorregando o pitch pra baixo. Consequência: o autotune precisa de **ataque rápido
   mas release um pouco mais lento**, senão ele "engole" o final da frase que é justamente onde
   está a emoção do estilo.
3. **Faixas curtas (1:46–2:46) com refrão repetido 3–4x.** A voz é tratada como **textura**, não
   como performance acústica: pode ser mais comprimida, mais suja e mais encharcada de reverb do que
   o "bom senso" de mix de rap tradicional diz.
4. **Estética "quarto pequeno / gravação de celular".** Isso quer dizer: sibilância alta, mid-range
   embolado com 808, ar artificial, e um certo "chiado" bonito. O preset abaixo **simula** essa
   sujeira controlada — não tenta corrigir tudo.

### 1.2 Assinatura sonora (o alvo do preset)

* Lead **nasal e melódico**, com pitch travado (hard tune) mas vibrato aparecendo no fim das frases.
* **Dobras/stacking** no refrão — 2 ou 4 vozes, pan fechado, todas com o mesmo tuning.
* **Ad-libs** mais gritadas, mais sujas, mais pano de reverb, muitas vezes deslocadas de pan e até
  de oitava.
* Reverb **longo e escuro** (não brillante), delay **marcado** (3/16), e ambos **duckados** pela voz:
  o efeito "respira" entre as frases — é o que dá a sensação de solidão.
* Leve saturação de fita/driver em tudo, inclusive no que "não deveria" distorcer.

### 1.3 Limite honesto desta análise

Eu analisei **o catálogo** — tons, BPMs, estrutura das faixas e a linhagem estética
Lil Peep → emo trap BR — e não os masterizados dele, que não estão acessíveis aqui.
Então: as **decisões** da cadeia e as faixas de frequência são bem fundamentadas; os números
exatos de cada knob são **ponto de partida calibrado para o gênero** (keys/BPM reais do catálogo +
as escolhas típicas dessa cena). Trate como "90% do caminho", não como telepatia: tudo que está em
faixa ("22–28%") ou marcado com `~` é pra você decidir de ouvido em 2 minutos com A/B.

---

## 2. Antes do plugin: setup de gravação (vale mais que o preset)

* **24 bit / 44.1 kHz** (48 se o beat já é 48). Nunca 16 bit.
* Grave com **pico em −6 dBFS** (−10 se você grita). Nada de clipar: saturação de clip não tem
  conserto aqui.
* **Latência abaixo de 10 ms** no buffer (ASIO4ALL não vale; use driver do interface). Com
  latência alta o canto sai atrás da afinação e o autotune vira loteria.
* **Monitore com o preset ligado, mas grave a voz SEM reverb/delay** (os sends ficam com botão de
  "solo-safe": não grave o retorno). No FL: armar a track com o botão de gravação e deixar os
  sends sem "record" ligado.
* Mic a **10–15 cm**, girado **20–30° fora do eixo** → mata metade da sibilância antes de qualquer
  de-esser.
* Um cobertor/travesseiro atrás do mic vale mais que qualquer EQ de "room". Grave no closet, se não
  tiver tratamento — é literalmente a estética dele.
* **Grave 2 takes completas** sempre: uma é o lead, a outra vira a dobrada (não duplicar/copiar o
  mesmo clipe — a dobrada tem que ser *outra* performance, senão vira flanger e não vira refrão).

---

## 3. Roteamento (esqueleto da cadeia)

```
Track 12  LAGERTA LEAD     ──slots 0..7──►  Send A (16) GELA REVERB  ─► Master
                                      └───►  Send B (17) GELA DELAY  ─► Master
Track 13  DOBLAS           ──slots 0..4──►  Send A / Send B (envio mais alto)
Track 14  ADLIBS           ──slots 0..4──►  Send A (bem mais alto)
```

Como fazer no FL:

1. `Ctrl+T` (ou botão direito no mixer → *Insert track*) para criar as 5 tracks acima; renomeie com
   `F2`. A nomenclatura importa quando você for salvar o preset.
2. Roteamento: **arraste o "cabinho" na base da track de origem até a track de destino**. Isso cria um
   **send** (não muda o volume da voz, só derrete o efeito). Dê dois cliques no botãozinho do send
   para ajustar o nível (comece em −18 dB no lead, −12 dB nas dobras, −8 dB nos adlibs).
3. Lead, dobras e adlibs todos **rotinados para Master** também (send não substitui o dry).
4. Se quiser um bus de voz para "colar" tudo: crie `VOZ (15)`, mande as três para lá e `VOZ →
   Master`, com um `Fruity Limiter` no `VOZ`.

---

## 4. A cadeia (LEAD) — valores por slot

Ordem não é decorativa: **EQ cirúrgico → compressor → afinador → de-esser → drive → proteção**.
Compressão antes do afinador ajuda a prender as notas (menos variação = menos erro de detecção);
de-esser **depois** do afinador, porque o tuning exagera sibilância.

### SLOT 0 — `Fruity Parametric EQ 2` (pré-EQ, cirúrgico)

| Banda | Tipo | Freq | Gain | Q |
|---|---|---|---|---|
| 1 | High Pass (24 dB/oct) | **100 Hz** | — | 0.35 |
| 2 | Bell | **315 Hz** | **−3.0 dB** | 1.20 |
| 3 | Bell | **850 Hz** | −1.5 dB | 1.00 |
| 4 | Bell | **2.4 kHz** | +1.0 dB | 0.80 |
| 5 | Bell | 4.3 kHz | −2.0 dB | 2.00 |
| 6 | High Shelf | **11 kHz** | +2.0 dB | 0.70 |

`Output −1.5 dB` · Oversampling `4x` (liga em *Settings/Global*, se disponível na sua versão).
Banda 2 é a que "abre" o vocal do 808; banda 3 tira o "papelão de celular"; banda 5 é o ataque feio
que some quando o drive entra. Se a sua voz for muito escura, jogue a banda 3 para 1.2 kHz.

### SLOT 1 — `Fruity Compressor` (segurador de pico, 1ª etapa)

| Parâmetro | Valor |
|---|---|
| Type/Mode | Compressor |
| Ratio | **8:1** |
| Threshold | **−18 dB** |
| Attack | **0.5 ms** |
| Release | 45 ms (ou Auto: on) |
| Knee | Hard |
| Make-up / Amp | +4 dB |
| Stereo linking | on |

Meta: **5–7 dB de redução só nos picos** (grito/final de frase). Se a palavra do meio some, suba o
threshold, não o make-up.

### SLOT 2 — afinador (escolha 1)

| Plugin | Ajustes |
|---|---|
| **MAutoPitch** (grátis, Melda) — melhor custo zero | Scale: **Natural Minor** + Key da faixa; **Hard Tune: ON**; Depth 100%; Attack/Retune **0–2**; Release **10–14**; Max pitch shift ±12; **Formant: 0** |
| **Antares Auto-Tune** (Pro/Artist/EFX) | Retune Speed **0–4**; Humanize **0–10**; Target **Basic** (use Graph só p/ consertar palavra específica); Key/Scale da faixa (ou AutoKey); Simple mode ON |
| **Waves Tune Real-Time** | Speed **1–3**; Release **18–25**; Input type: Male/Female correto; Key/Scale da faixa; Vibrato: keep |
| **FL `Pitcher`** (nativo, Producer/Signature) | Key/Scale da faixa; **Speed no máximo** (hard-tune) ou "medium" pra versão mais suave; **Formant** deixe em 0; Amount 100% |
| **FL `newTone`** (nativo, offline) | melhor resultado: *botão direito no clipe → "Edit pitch / Newtone"*, escala = Minor, **Centre → direita, Variation → esquerda**, renderizar de volta. Lento e bom. |

> Na estética dele o tuning é **visível** (robótico) no lead e **ainda mais duro** nas dobras.
> Se você quer a versão "chorando mas natural" (tipo "Última Vez"): Retune 12–20, Humanize 25.

### SLOT 3 — `Fruity Limiter` em modo **COMP** (2ª etapa, serial — o truque do gênero)

| Parâmetro | Valor |
|---|---|
| Mode | **COMP** |
| Ratio | 4:1 |
| Threshold | −12 dB |
| Attack | 3 ms |
| Release | 80 ms (Auto off) |
| Gain | +2 dB |
| LIMIT side (ceiling) | deixe **−1.0 dB**, "Gain" em 0 |

Dois compressores leves em série soam mais "grandes" que um pesado. É o que faz a voz ficar na
cara sem morrer.

### SLOT 4 — de-esser

* Com de-esser (Melda `MDeEsser` grátis, Waves Sibilance, Nectar): **6.5–7.5 kHz**, range **−6 dB**,
  modo split-band, escute o "lisp" sumir e pare 1 dB antes de soar enrolado.
* Sem de-esser, use **`Fruity Maximus`**: crossover `Band 3` em **5.5 kHz**; na banda do meio/alta
  (a de cima) `Ratio 4:1`, `Threshold −30 dB`, `Attack 0.3 ms`, `Release 40 ms`, `Gain −2 dB`.
  As duas bandas de baixo: **bypass/mute dos knobs de comp** (só passam). Isso é um de-esser
  multibanda disfarçado.

### SLOT 5 — drive / "casca"

* **Rápido:** `Soundgoodizer` modo **A**, **12–18%**. Só. Dá o "quase-errado-de-celular" sem fritar.
* **Mais sujo (adlibs / refrão raivoso):** `Fruity Fast Dist` com **Distortion 8–12%**, `Mix ~30%`
  (ou `Fruity Blood Overdrive`: Pre-amp baixo, Color 1.5).
* Dica de estilo: o drive no **bus de dobras/adlibs**, não no lead — mantém o lead inteligível e a
  textura fica no fundo.

### SLOT 6 — `Fruity Parametric EQ 2` nº2 (pós-drive, opcional)

| Banda | Tipo | Freq | Gain | Q |
|---|---|---|---|---|
| 1 | Bell | 180 Hz | −1.0 dB | 0.9 |
| 2 | High Shelf | 12 kHz | −1.5 dB | 0.7 |

Segura o barranco quando você empilhar 4 vozes e tira o "chiado" que o drive cria no topo.

### SLOT 7 — `Fruity Limiter` (proteção final da track)

`LIMIT`: **Ceiling −1.0 dB**, Release 60 ms, Gain 0. Deve **quase nunca** trabalhar; se o LED pisca
em toda sílaba, o problema é nos slots 1/3.

---

## 5. Os sends (é aqui que mora o "som do Lil Gela")

### SEND A — `GELA REVERB` (track 16)

1. `Fruity Parametric EQ 2` **antes** do reverb: High Pass **350 Hz**, Low Shelf **−3 dB @ 5 kHz** —
   reverb sem corpo é reverb que não embola.
2. `Fruity Reeverb 2` (ou VintageVerb / Valhalla / RC-24 / OrilRiv):
   * **Size/Decay: ~2.0–2.4 s** (longo — é o estilo)
   * **Pre-delay: 32 ms** (se a voz "sumir", suba para 48–60 ms: isso separa cauda da palavra)
   * Low cut 350 Hz · High cut **5.2 kHz**
   * Damping/mod: **8–12%** (dá aquele "plate velho" do emo trap)
   * Stereo separation: 40–50% · **Wet 100% / Dry 0%**
3. `Fruity Limiter` (modo COMP) com **sidechain da track do lead**: Threshold −22 dB, Ratio 4:1,
   Attack 2 ms, Release 110 ms. No FL: clique no ícone de sidechain do slot → escolha a track
   `LAGERTA LEAD`. **Isso** é o respiro entre as frases.
4. Nível do send: lead **−18 dB**, dobras **−14 dB**, adlibs **−8 dB**.

### SEND B — `GELA DELAY` (track 17)

1. `Fruity Delay 3` (ou EchoBoy/Delay 2):
   * **Sync: ON**, tempo **3/16** (o 3/16 sobre o half-time é o bounce do gênero; em frase curta
     use 1/8)
   * **Ping-pong: ON**
   * Feedback **22–28%**
   * High pass **550 Hz**, Low pass **3.2 kHz**
   * Colour/saturation: 15–25%
   * **Wet 100% / Dry 0%**
2. Mesmo sidechain/duck do reverb.
3. **Throw automatizado:** no fim de cada 8º compasso (a "resposta" da frase), suba o send de
   −24 para −10 dB por ~1 s. É a coisa mais barata que existe pra deixar um refrão de emo trap
   grande — desenhe a automação no send, não no delay.

### DOBRAS (track 13)

* Take **alternativa** do refrão/última linha, 2x (uma pan −35%, outra +35%).
* Cadeia mais simples: pré-EQ (slot 0) + afinador **com o mesmo Key/Scale** + compressor mais forte
  (Ratio 12:1) + `Soundgoodizer` C em 20%.
* **Menos reverb, mais curto:** send −16 dB e, se possível, um segundo reverb de 0.8 s.
* Nível geral **−3 a −4 dB abaixo do lead**. Dobra tem que ser sentida, não ouvida.
* Haas: com snaps desligados (`Alt` ao arrastar), empurre uma das duas em **15–25 ms**. Alargamento
  grátis, mono-compatível.

### ADLIBS (track 14)

* Pan **±60%**, mais drive (Soundgoodizer C 28–32%), High Pass **200 Hz**, Ratio 12:1, mais
  delay/throw.
* **Oitava:** no clipe de áudio → seção *Time stretching* → `Mode: Stretch/Resample`, **Pitch −12**
  (voz de "porão") ou **+12** (voz aguda/anjo) em caudas de refrão. Use com moderação: 1 vez a cada
  8 compassos.

---

## 6. Transformar em PRESET permanente (a parte do "arquivo")

Faça a cadeia **uma** vez, depois:

**A. Track preset do mixer (recomendado — carrega em 2 cliques em qualquer projeto)**
1. Selecione `LAGERTA LEAD` → botão de menu do canal (seta/cantinho do título da track) →
   **Save mixer track state as…** (presente no FL 21+; em versões antigues, use B).
2. Salve com o nome `LilGela_vocal_emotrap` **dentro de**
   `Documentos\Image-Line\FL Studio\Presets\Mixer\` (crie a pasta `Mixer` se não existir).
3. Aparece no Browser → em qualquer projeto novo: botão direito na track →
   *Load mixer track state from* (ou arraste do Browser, e com várias tracks selecionadas o FL
   carrega o preset em todas).
4. Repita para `GELA REVERB` e `GELA DELAY`.

**B. Template de projeto (leve o roteamento e os sends juntos)**
`File → Export → Project as template (.fst)` → na próxima sessão:
`File → New from template`. (Se você quiser que *todo* projeto novo abra já com isso, use
`File → Save as default project` — `Ctrl+Alt+P`. Isso muda seu `Default.fst`, então salve antes
uma cópia do seu template atual.)

**C. Com o script desta pasta (`fl_chain_tool.py`) — para passar a cadeia entre projetos e PCs**

Ele lê os valores reais dos knobs (inclusive de VST pago) e grava em texto puro; depois aplica de
volta. Roda dentro do FL, não precisa de Python instalado:

```python
# no console de script do FL (View > Script output, ou Tools > Scripting no FL 2024+)
exec(open(r"C:\Users\SEU_USUARIO\Documents\fl_gela\fl_chain_tool.py").read()); scan()   # confere a track
exec(open(r"C:\Users\SEU_USUARIO\Documents\fl_gela\fl_chain_tool.py").read()); dump()   # salva
exec(open(r"C:\Users\SEU_USUARIO\Documents\fl_gela\fl_chain_tool.py").read()); apply()  # reaplica
```

`scan()` mostra o que ele achou, `dump()` escreve `Documents\fl_gela\fl_gela_chain.txt`, `diff()`
conta o que está fora do lugar, `apply()` conserta. Ele casa os plugins **pelo nome**, então a ordem
dos slots pode mudar. Se o console não existir na sua versão, use o modo *MIDI script* (instruções
no topo do arquivo: pasta `Settings\Hardware\fl_gela\device_fl_chain_tool.py`, e as notas
C3/C#3/D3 disparam scan/dump/apply).

**D. Guarde o preset de cada plugin também** (bom para versionar/compartilhar): no canto superior do
plugin, o menu `▼`/disquete → *Save as* — vai para
`Documents\Image-Line\FL Studio\Presets\<nome do plugin>\` e aparece no Browser.

> **Não existe** arquivo `.xml`/`.txt` de preset de vocal que o FL importe magicamente para plugins
> nativos. Quem "vende preset" nesse formato está entregando um projeto `.fst`. A rota A+B+C acima é
> exatamente o que um engenheiro entrega, só que sem o risco de abrir um `.fst` de origem duvidosa.

---

## 7. Números de referência / medidores

| O quê | Alvo |
|---|---|
| Pico na gravação | −6 dBFS |
| Pico no fim da cadeia do lead | −3 dBFS |
| RMS/curto prazo do vocal | −14 a −12 dBFS |
| Vocal vs. beat | voz **3 a 5 dB** acima do pico do beat no medidor da track; se ela precisa de mais que isso pra aparecer, o erro está no beat (200–500 Hz), não na voz |
| Master para streaming | **−9 a −8 LUFS** integrado, true peak ≤ −1.0 dBTP (o normalizador da plataforma joga para −14) |

---

## 8. Diagnóstico rápido (é assim que se afina, não por tabela)

| Sintoma | Causa provável | Move o quê |
|---|---|---|
| Voz embolada com o 808 | conflito 200–400 Hz | −2 dB em 315 Hz no **vocal** e −2 dB em 250 Hz no **beat** (não suba a voz) |
| Sibilância machucando | drive antes do de-esser / mic no eixo | de-esser antes do drive; mic 25° fora do eixo; −2 dB em 7 kHz |
| Autotune errando notas | escala/tom errados, bleed de fone no mic, canto macio | confirme Key/Scale da faixa (tabela 1.1); monitore com menos beat; Retune 10–15 |
| Notas "pulando oitava" | range do afinador, input type errado | Input type Male/Female; Max shift ±6; menos grave no corte (HP 100 → 120 Hz) |
| Reverb engolindo a letra | pre-delay curto demais, sem sidechain | Pre-delay 48–60 ms; liga o duck (send A item 3) |
| Cansativa no repeat | excesso de 2–5 kHz | −2 dB na banda 4 do pré-EQ (2.4 kHz) e drive pela metade |
| Fraca/espetada | high shelf sem corpo | −1 dB em 11 kHz, +1 dB em 200 Hz |
| Sem "vibe de quarto" | mix limpo demais | Soundgoodizer A 18% no bus das dobras + BitCrusher (12 bits) com Mix 15% só nas adlibs |

### 3 sabores (mesma estrutura, muda 3 botões)

| | Reverb send | Drive | Tuning | EQ banda 6 (ar) |
|---|---|---|---|---|
| **A — padrão** (ref. "Merdas Acontecem") | −18 dB | 12% | Retune 0–4 | +2 dB |
| **B — quarto/demo acústica** | −12 dB, decay 2.8 s | 0% | Retune 15, Humanize 30 | −1 dB, Low-pass 8 kHz |
| **C — raivosa/screamo** | −22 dB, decay 0.9 s | Fast Dist 15%, Mix 45% | Retune 0 | +3.5 dB |

---

## 9. Quer que eu ajuste os números pra VOCÊ?

Mande **um dry vocal seu em WAV** (20–30 s do refrão, 16 ou 24 bit — sem MP3, que eu não consigo
decodificar aqui) + o tom da faixa. Aí dá pra medir de verdade: fundamental média (pra checar se o
HP de 100 Hz está comendo nota), a região real de sibilância, e as ressonâncias do seu quarto.
Depois eu devolvo as faixas de corte certas e o `fl_gela_chain.txt` fechado pra sua voz. O preset acima é o ponto de partida da cena; esse segundo passo é o que
faz ele virar *seu*.
