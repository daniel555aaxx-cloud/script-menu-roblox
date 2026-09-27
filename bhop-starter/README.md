# Bhop Starter para Roblox Studio

Um protótipo original de **bunny hop / air-strafe / speedrun** para Roblox Studio. A referência é o gênero: pular em sequência, controlar a direção no ar, ganhar/administrar velocidade e completar pistas com checkpoints e cronômetro. A pista deste pacote é gerada por código e não copia mapas, personagens, interfaces ou assets do Bhop Pro.

## Arquivo pronto para abrir

O arquivo [`BhopStarter.rbxlx`](BhopStarter.rbxlx) é um projeto Roblox Studio com os scripts já organizados nos serviços certos. Abra o Studio e use **Arquivo > Abrir do arquivo...** (ou *File > Open from File...*), selecione esse arquivo e clique em **Executar** para testar. Para enviar à sua conta, use **Arquivo > Publicar no Roblox como...** e crie/selecione uma experiência. Abrir o arquivo não publica automaticamente o jogo.

Também é possível reconstruir o `.rbxlx` a partir das pastas de código com Rojo usando `default.project.json`, se você já utiliza essa ferramenta.

## O que vem pronto

- Pista de treino em zigue-zague gerada no servidor, com 24 plataformas.
- Câmera travada em primeira pessoa, com mira central discreta.
- Movimento bhop com atrito/aceleração no chão, air-strafe, momentum, pulo automático e buffer de pulo.
- Física de surf habilitável em rampas marcadas com o atributo `SurfSurface = true` ou `MovementSurface = "Surf"`.
- Checkpoints verdes, início azul, chegada amarela e retorno ao último checkpoint ao cair.
- Cronômetro de tentativa, velocidade, checkpoint e recorde da sessão no HUD.
- Botão **RESET** e tecla **R**.
- Feedback visual procedural de velocidade (FOV e balanço leve da câmera).
- Suporte opcional a animações de salto/aterrissagem criadas e publicadas por você.

> O recorde atual fica na sessão e não é salvo entre sessões. O foco é reproduzir a sensação central de movimento (primeira pessoa, bhop, air-strafe e momentum) com física própria; não é uma cópia integral de menus, mapas, cosméticos ou progressão do Bhop Pro. A física precisa ser testada e ajustada no Roblox Studio.

## Como abrir e testar

1. No Studio, escolha **Arquivo > Abrir do arquivo...** e selecione `BhopStarter.rbxlx`.
2. Clique em **Executar** (ícone ▶; pode aparecer como *Play*). A câmera fica travada em primeira pessoa e a pista é criada ao iniciar.
3. Corra até a faixa azul para iniciar o cronômetro. Segure Espaço para encadear pulos e use A/D junto com a rotação do mouse para fazer air-strafe.
4. Para testar com várias pessoas, abra a aba **Teste** e escolha **Iniciar** ou **Iniciar servidor** com 2 ou mais jogadores.
5. Para publicar na sua conta, escolha **Arquivo > Publicar no Roblox como...** e crie/selecione uma experiência.

### Instalação manual (alternativa)

Se preferir inserir os scripts em uma experiência existente, abra **Janela > Explorador** (ou o botão **Explorador** na aba **Início**) e **Janela > Saída**. Em algumas versões/idiomas, esses itens podem aparecer como *Window*, *Explorer* e *Output*.

- Em `ServerScriptService`, crie um **Script** chamado `BhopGame` e cole [`ServerScriptService/BhopGame.server.lua`](ServerScriptService/BhopGame.server.lua).
- Em `StarterPlayer > StarterPlayerScripts`, crie **Scripts locais** para `BhopController`, `BhopHUD` e `MovementFX`, usando os arquivos correspondentes em [`StarterPlayerScripts`](StarterPlayerScripts).
- Para usar animações próprias, adicione também `BhopAnimations` conforme a seção abaixo.
- Os nomes dos serviços e pastas, como `ServerScriptService` e `StarterPlayer`, normalmente continuam em inglês no Explorador.

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

## Física e rampas de surf

Em `BhopController.client.lua`, os valores `GROUND_MAX_SPEED`, `GROUND_ACCEL`, `GROUND_FRICTION`, `AIR_ACCEL`, `AIR_WISH_SPEED_CAP`, `JUMP_SPEED` e `MAX_SPEED` definem a sensação do movimento. Segurar Espaço conserva o momentum ao aterrissar; A/D e a rotação da câmera mudam a direção do air-strafe.

Para marcar uma rampa como superfície de surf, selecione a peça no **Explorador**, abra **Propriedades > Atributos**, adicione um atributo booleano `SurfSurface` com valor `true` (ou um atributo string `MovementSurface` com valor `Surf`). Use uma rampa inclinada; a física projeta gravidade e direção de controle sobre o plano da superfície enquanto o jogador está sobre ela.

Em `BhopGame.server.lua`, altere `COURSE_PARTS` e `SPACING` para mudar a extensão e os vãos da pista. `MovementFX.client.lua` controla o FOV e o balanço visual.

## Observações

- Este conteúdo é para **Roblox Studio e uma experiência que você desenvolve**, não para executor ou exploração de jogos de terceiros.
- A física de personagem do Roblox varia com escala, rig e configurações da experiência. Ajuste os parâmetros no modo Play e observe o **Output** para depurar.
- A validação de tempo ocorre no servidor, mas a movimentação de personagem ainda depende da física replicada pelo Roblox. Para um jogo competitivo publicado, acrescente validação de movimento e persistência de recordes no servidor.

## Referências de gênero

As descrições públicas consultadas apresentam Bhop Pro como um jogo de movimento em primeira pessoa com bunny hop/air-strafe, velocidade, pistas e desafios de tempo; este starter recria apenas ideias gerais do gênero com código e pista próprios:

- [Bhop Pro — descrição e funcionalidades](https://mwm.ai/apps/bhop-pro/1215690243)
- [Bhop — Roblox (StrafesNET), referência pública de bunny hop](https://www.roblox.com/games/5315046213/bhop)
