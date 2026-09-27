# Bhop Starter para Roblox Studio

Um protótipo original de **bunny hop / air-strafe / speedrun** para Roblox Studio. A referência é o gênero: pular em sequência, controlar a direção no ar, ganhar/administrar velocidade e completar pistas com checkpoints e cronômetro. A pista deste pacote é gerada por código e não copia mapas, personagens, interfaces ou assets do Bhop Pro.

## Arquivo pronto para abrir

O arquivo [`BhopStarter.rbxlx`](BhopStarter.rbxlx) é um projeto Roblox Studio com os scripts já organizados nos serviços certos. Abra o Studio e use **Arquivo > Abrir do arquivo...** (ou *File > Open from File...*), selecione esse arquivo e clique em **Executar** para testar. Para enviar à sua conta, use **Arquivo > Publicar no Roblox como...** e crie/selecione uma experiência. Abrir o arquivo não publica automaticamente o jogo.

Também é possível reconstruir o `.rbxlx` a partir das pastas de código com Rojo usando `default.project.json`, se você já utiliza essa ferramenta.

## O que vem pronto

- Pista de treino em zigue-zague gerada no servidor, com 24 plataformas.
- Bunny hop ao segurar Espaço e aceleração direcional no ar.
- Checkpoints verdes, início azul, chegada amarela e retorno ao último checkpoint ao cair.
- Cronômetro de tentativa, velocidade, checkpoint e recorde da sessão no HUD.
- Botão **RESET** e tecla **R**.
- Feedback visual procedural de velocidade (FOV e balanço leve da câmera).
- Suporte opcional a animações de salto/aterrissagem criadas e publicadas por você.

> O recorde atual fica na sessão e não é salvo entre sessões. A física é um ponto de partida: teste e ajuste os valores para o ritmo que você quer.

## Como instalar no Roblox Studio

1. Crie uma experiência nova no Roblox Studio (o modelo **Baseplate** serve). Para abrir o **Explorador**, procure a opção **Janela > Explorador** ou o botão **Explorador** na aba **Início**. Para mostrar o painel de erros, procure **Janela > Saída**. Dependendo da versão/idioma, esses itens podem aparecer como *Window*, *Explorer* e *Output*.
2. No **Explorador**, apague a peça `Baseplate` para ela não ficar sob a pista. O script cria o próprio ponto de spawn. Os nomes dos serviços e pastas do Roblox, como `ServerScriptService` e `StarterPlayer`, normalmente continuam em inglês.
3. No **Explorador**, encontre `ServerScriptService`, passe o mouse sobre ele e clique no botão **+**. Insira um **Script**, renomeie para `BhopGame` e cole o conteúdo de [`ServerScriptService/BhopGame.server.lua`](ServerScriptService/BhopGame.server.lua).
4. Encontre `StarterPlayer > StarterPlayerScripts`. Clique no **+** de `StarterPlayerScripts` e insira três **Scripts locais** (podem aparecer como *LocalScript*), com estes nomes e conteúdos:
   - `BhopController` ← [`StarterPlayerScripts/BhopController.client.lua`](StarterPlayerScripts/BhopController.client.lua)
   - `BhopHUD` ← [`StarterPlayerScripts/BhopHUD.client.lua`](StarterPlayerScripts/BhopHUD.client.lua)
   - `MovementFX` ← [`StarterPlayerScripts/MovementFX.client.lua`](StarterPlayerScripts/MovementFX.client.lua)
5. Clique no botão **Executar** (ícone ▶; em algumas versões ainda aparece como *Play*). A pista será criada automaticamente. Use WASD, mouse e Espaço. Toque na faixa azul para iniciar o tempo; R/RESET retorna ao checkpoint.
6. Para testar com várias pessoas, abra a aba **Teste** e escolha **Iniciar** ou **Iniciar servidor** com 2 ou mais jogadores (o texto pode variar um pouco entre versões). A pista é compartilhada; cada jogador tem seu próprio tempo e checkpoint.

### Controles

- **WASD:** mover; mouse: orientar a câmera.
- **Espaço segurado:** pulo automático ao tocar o chão.
- **A/D no ar + virar a câmera:** controlar air-strafe e momentum.
- **R** ou botão **RESET:** voltar ao último checkpoint.
- No celular/tablet, os controles padrão do Roblox continuam ativos; use o botão de pulo padrão e o botão RESET da interface.

## Animações próprias (opcional)

O Roblox já aplica animações padrão de avatar. O arquivo `MovementFX` dá sensação de velocidade, mas não é um asset de animação corporal. Para usar animações de salto/aterrissagem suas:

1. No Studio, abra a aba **Avatar** e escolha **Editor de Animação** (pode aparecer como *Animation Editor*), selecione um rig R15/R6 compatível e crie as animações de salto e aterrissagem.
2. Publique cada animação pela sua conta/grupo proprietário da experiência e copie os IDs numéricos.
3. Crie um quarto **LocalScript** em `StarterPlayer > StarterPlayerScripts` usando [`StarterPlayerScripts/BhopAnimations.client.lua`](StarterPlayerScripts/BhopAnimations.client.lua).
4. No início desse arquivo, preencha `JUMP_ANIMATION_ID` e `LAND_ANIMATION_ID` com os IDs publicados, sem o prefixo `rbxassetid://`. Deixe `""` para manter a animação padrão correspondente.
5. Teste com o mesmo tipo de rig usado para criar a animação e confirme que ela tem permissão de uso para a experiência.

Não incluí IDs fictícios: animações publicadas são assets vinculados à conta/grupo e precisam ser criadas/publicadas pelo desenvolvedor.

## Ajustes de dificuldade

Em `BhopGame.server.lua`, altere `COURSE_PARTS` e `SPACING` para mudar a extensão e os vãos da pista. Em `BhopController.client.lua`, os valores `AIR_ACCELERATION`, `MAX_AIR_SPEED`, `BASE_WALK_SPEED` e `MAX_WALK_SPEED` controlam aceleração e velocidade. `MovementFX.client.lua` controla o FOV e o balanço visual.

## Observações

- Este conteúdo é para **Roblox Studio e uma experiência que você desenvolve**, não para executor ou exploração de jogos de terceiros.
- A física de personagem do Roblox varia com escala, rig e configurações da experiência. Ajuste os parâmetros no modo Play e observe o **Output** para depurar.
- A validação de tempo ocorre no servidor, mas a movimentação de personagem ainda depende da física replicada pelo Roblox. Para um jogo competitivo publicado, acrescente validação de movimento e persistência de recordes no servidor.

## Referências de gênero

As descrições públicas consultadas apresentam Bhop Pro como um jogo de movimento em primeira pessoa com bunny hop/air-strafe, velocidade, pistas e desafios de tempo; este starter recria apenas ideias gerais do gênero com código e pista próprios:

- [Bhop Pro — descrição e funcionalidades](https://mwm.ai/apps/bhop-pro/1215690243)
- [Bhop — Roblox (StrafesNET), referência pública de bunny hop](https://www.roblox.com/games/5315046213/bhop)
