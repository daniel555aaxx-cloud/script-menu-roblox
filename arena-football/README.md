# ARENA FOOTBALL — Roblox Studio

Um protótipo original de futebol em terceira pessoa, com partida rápida em estádio gerado por código. É inspirado no gênero de simuladores de futebol, mas não usa nomes oficiais, escudos, uniformes, jogadores, músicas ou assets do FIFA/EA.

## Baixar e abrir

O arquivo [`ArenaFootball.rbxlx`](ArenaFootball.rbxlx) contém os scripts organizados e cria campo, gols, bola e estádio automaticamente quando você clica em **Executar**.

1. Baixe `ArenaFootball.rbxlx` ou o ZIP do projeto.
2. No Roblox Studio, selecione **Arquivo > Abrir do arquivo...** e escolha o `.rbxlx`.
3. Clique em **Executar** para jogar. Um jogador pode testar solo; use **Teste > Iniciar servidor** com 2+ jogadores para uma partida entre equipes.
4. Para publicar em sua conta, selecione **Arquivo > Publicar no Roblox como...** e crie uma experiência.

## Recursos incluídos

- Campo em escala grande (240 × 380 studs; aproximadamente 69 × 109 m usando 3,5 studs/m), com faixas de gramado, marcações, áreas, gols, redes, arquibancadas e refletores.
- Duas equipes balanceadas automaticamente: **Rubro FC** e **Azul FC**.
- Bola com malha/textura do Soccer Ball clássico publicado pela Roblox (IDs 28502053/28502119), colisão esférica separada, rotação proporcional à corrida e solda ao avatar durante o drible. A física usa atrito e quique reduzidos para a bola rolar de forma mais natural; o apoio foi aproximado 2 cm do jogador.
- Chutes com mira no retículo central: o servidor calcula a trajetória balística para a bola alcançar o ponto indicado, ajustando a velocidade quando necessário. Chutes e passes também dão rotação física à bola.
- Animações procedurais de condução, chute, passe e carrinho, reproduzidas para todos os jogadores sem exigir IDs de animação externos.
- Corrida com barra de fôlego; o fôlego é gasto correndo e recuperado ao caminhar.
- Placar, relógio de 3 minutos, aviso de gol e fim de jogo.
- Controles de toque criados automaticamente em celular/tablet.
- Animações padrão do avatar Roblox e giro físico da bola nos chutes. Assets de animação/áudio personalizados precisam ser criados e publicados por você.

## Controles

### PC

- **WASD:** mover.
- **Shift esquerdo:** correr enquanto estiver segurado.
- **Segurar botão esquerdo do mouse ou E:** carregar o chute; solte para chutar no ponto indicado pelo retículo central. Mire movendo a câmera.
- **Q:** passe para o companheiro melhor posicionado; sem opção, passe para frente.
- **F:** tentar desarmar um adversário próximo que esteja com a bola.

### Celular/tablet

Use o joystick e a câmera padrão do Roblox. Os botões **CHUTE** (segure para carregar), **PASSE**, **DESARME** e **CORRER** aparecem automaticamente no canto inferior direito.

## Ajustes rápidos

No começo de `ServerScriptService/Match.server.lua`, altere `MATCH_SECONDS`, `HOME_SPEED`, `SPRINT_SPEED`, `STAMINA_DRAIN` e `STAMINA_RECOVER`. O script também contém os valores de potência/elevação dos chutes, alcance de domínio, passe e desarme.

## Limites deste protótipo

É uma base jogável para você expandir, não uma reprodução completa de um jogo comercial: não inclui goleiros com IA, regras avançadas (impedimento/faltas/cartões), carreira, transferências, matchmaking, monetização, elenco/licenças, comentários ou animações profissionais. Para partidas competitivas, teste a física/latência em servidores Roblox e adicione validações/anti-cheat conforme necessário.
