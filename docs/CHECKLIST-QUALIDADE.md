# Checklist de qualidade e testes

## Testes automáticos (rodam sem Roblox)

```bash
node tools/lua_test.js        # Lua puro (wasmoon): navegação, mapas, história
node tools/check_project.js   # validação estática: remotes, módulos, JSON
```

O que já é verificado:

| Área | Checagens |
|---|---|
| Navegação (A*) | caminho diagonal, contorno de parede, sem caminho, linha de visão, simplificação, tags, mundo↔célula |
| Mapas | todos os markers alcançáveis a pé, spawn do jogador/monstro válido, saída acessível, área mínima, cobertura |
| História | 27 capítulos, >30k pontos, objetivos com markers existentes, pistas por capítulo, deduções com exatamente 1 resposta certa, pontos de armadilha válidos, spawn do monstro, recompensas, `nextChapter` existente |
| Elenco | 5 heróis, Scooby, 26 NPCs com brief e árvore de diálogo, 7 monstros, NPC pertence a episódio existente |
| Diálogo | árvores válidas, ~300 nós, >200 falas, voice lines dos 5 personagens |
| Props | todos os `type` usados existem na biblioteca, temas por tipo de sala |
| Definições | loja com 12 itens, 10 conquistas, 4 dificuldades, skins |
| Assets | todos os SFX usam `rbxasset://` (sem upload necessário) |
| Remotes | todo evento usado no código existe em `Net.luau` |
| Higiene | nenhum módulo vazio, nenhum `chave: valor` (erro de sintaxe) |

**Estado atual:** 13 + 708 + 936 = **1.657 checagens, 0 falhas**
(`node tools/lua_test.js`) e `check_project: tudo certo ✔`.

## Checklist manual no Studio (roteiro de QA, ~12 min)

1. **Boot** — Play: sem erro no Output; a sede aparece com a van e o quadro de
   casos; o HUD abre no canto superior esquerdo.
2. **Lobby (L)** — criar turma, alternar privacidade até *SOMENTE AMIGOS*,
   convidar (aparece "convite enviado"), listar turmas abertas.
3. **Prólogo** — andar até a fita (`E`), conversar com o Scooby; objetivos
   marcando ✓ e pontos subindo.
4. **Início de partida** — escolher EP01, contagem regressiva, teleporte para
   Porto Pedra, cutscene de abertura com letterbox e slides (P pula).
5. **Pistas** — examinar pistas (`E`), abrir o quadro (`Q`), pedir dica (`H`,
   desconta 25 snacks), ver a marcação no HUD.
6. **Dedução** — completar as pistas do capítulo e responder a dedução (o
   capítulo seguinte deve destravar).
7. **NPC** — falar com um NPC: caixa de diálogo digita o texto, escolhas com
   indicação de papel aparecem, linhas bloqueadas ficam esmaecidas.
8. **Monstro** — após o objetivo marcado, o monstro aparece com aviso; ao ser
   visto, aparece o banner "ELE ESTÁ VINDO" e a música de perseguição começa.
9. **Armadilha** — coletar 3 peças (badge 🧰 x/3), montar, iscar, armar;
   o monstro é atraído e preso; notificação de captura.
10. **Revelação** — cutscene tira a máscara; o próximo capítulo inicia sozinho.
11. **Fim de episódio** — tela de resultado, retorno ao lobby, próximo caso
    disponível; conquistas notificadas.
12. **Multiplayer** — dois clientes no mesmo servidor: turmas separadas,
    cada um com sua partida; entrar na turma do outro e ver o teleporte junto.

## Problemas conhecidos / próximos passos

* Os modelos são procedurais (blocos com proporções fiéis). Para o realismo do
  filme, importe modelos próprios — o caminho está pronto em
  `ServerStorage.CustomModels` (ver `docs/ASSETS-E-GRAFICOS.md`).
* Áudio usa apenas sons embutidos do cliente; os slots de música estão prontos
  em `Assets.Sounds` (não suba material protegido por direitos autorais).
* Progresso persistente exige jogo publicado (DataStore). Em Studio o serviço
  cai para memória — comportamento esperado.
* `CharacterService.forceClassic = true` troca o avatar do jogador pelos modelos
  do desenho (útil para screenshots/trailers).
