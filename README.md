# Central do Caô — jogo de atendimento fictício para Roblox

Projeto Luau para importar no Roblox Studio com Rojo. O servidor monta um escritório 3D procedural; os jogadores atendem clientes NPC, conversam por voz ou texto, ganham créditos fictícios e disputam um ranking persistente.

> **Ficção e segurança:** as ofertas são absurdas e inventadas, as conversas são apenas com NPCs e os créditos não têm valor real. O jogo não solicita nem armazena senhas, telefones, documentos ou dados de pagamento. Para persistência e ranking, guarda somente estatísticas de jogo ligadas ao UserId Roblox (saldo, reputação, atendimentos e total ganho); transcrições não são salvas nem compartilhadas. Não há golpe entre jogadores nem integração com serviços externos de IA.

## O que já está implementado

- **Escritório gerado por script:** recepção, seis estações com computador e telefone, sala de reunião, gerência, copa, bebedouro, cafeteira, máquina de lanches, impressora, sala de TI/servidores decorativa, banheiro, janelas, estacionamento, iluminação e placa física de ranking.
- **Atendimento jogável:** aproxime-se de um telefone e pressione **E** (ou use o prompt na tela) para iniciar uma ligação individual com um NPC.
- **NPC conversacional:** diálogo contextual em português com falas por perfil, perguntas, explicação honesta, oferta de pacote imaginário, encerramento e uma consequência de reputação para promessas impossíveis. A lógica é local e baseada em estados/intenção; não é um LLM externo.
- **Voz opcional:** APIs nativas do Roblox `AudioSpeechToText` e `AudioTextToSpeech`, com transcrição em português e voz portuguesa. O botão **MIC ON/OFF** habilita/desabilita a captura; o botão **VOZ ON/OFF** controla a fala do NPC. Botões de resposta e campo de texto permanecem como alternativa.
- **Dinheiro e ranking:** créditos, reputação, atendimentos e total ganho são atualizados no servidor. `leaderstats` mostra os placares, um painel no escritório mostra o top 10 e um `OrderedDataStore` mantém o ranking entre servidores.
- **Proteção:** escolhas e pagamentos são validados no servidor, há limite de frequência e verificação de proximidade da estação. As falas digitadas/transcritas passam pelo filtro de texto do Roblox antes de serem mostradas. A transcrição não é salva nem transmitida a outros jogadores.

## Abrir no Roblox Studio

### Abrir o place pronto (sem Rojo)

1. Abra o Roblox Studio.
2. Escolha **File → Open from File…**.
3. Selecione `CentralDoCao.rbxlx`, na raiz deste repositório.
4. Aguarde o place carregar e pressione **Play**. O escritório, os NPCs e os remotes são criados pelo servidor durante a execução.

O arquivo `.rbxlx` inclui os quatro scripts Luau e as configurações do projeto. Ele passou pela validação de XML e por um parser RBXLX externo; este ambiente não tem Roblox Studio instalado, então a abertura final no Studio ainda precisa ser confirmada.

### Desenvolver/atualizar com Rojo (opcional)

1. Instale o [Rojo](https://rojo.space/) e o plugin Rojo para Roblox Studio.
2. Na raiz deste repositório, execute `rojo serve default.project.json`.
3. No Studio, conecte o plugin ao servidor Rojo. A árvore será montada com os scripts nos serviços corretos.
4. Se preferir gerar novamente o place a partir dos fontes, execute `rojo build default.project.json -o CentralDoCao.rbxlx` e abra o arquivo no Studio.
5. Pressione **Play**. O mapa e os remotes são criados pelo servidor durante a execução.

### Voz no Studio/publicado

Para o microfone, publique uma cópia de teste e ajuste as configurações da experiência:

1. Em **Experience Settings → Communication**, habilite **Enable Microphone**.
2. O place pronto e o projeto Rojo já definem **VoiceChatService → UseAudioApi = Enabled** e **EnableDefaultVoice = false**. Confirme essas opções no Studio após sincronizar; manter a voz padrão desabilitada evita transmitir o áudio capturado ao restante do servidor.
3. Teste com uma conta/dispositivo elegível para voz. A disponibilidade do microfone depende das permissões e das regras atuais do Roblox; se a voz não estiver disponível, os botões e o campo de texto continuam funcionando.

A voz do NPC usa o TTS nativo do Roblox (VoiceId `1002`, português feminino). A primeira fala pode levar um instante para carregar. A captura só é ativada após o jogador tocar em **MIC ON**.

### Persistência e ranking global

- Publique uma **versão de teste** da experiência.
- Em **Experience Settings → Security**, habilite **Enable Studio Access to API Services** apenas nessa cópia de teste para verificar DataStores. Evite ligar essa opção em um Studio conectado aos dados de produção.
- A persistência usa `CentralDoCao_PlayerData_v1` e o ranking ordenado `CentralDoCao_Ranking_v1`. Sem acesso a DataStores, a partida ainda funciona; apenas não haverá persistência global.
- Não é necessário habilitar HTTP. Nenhuma chave de API ou credencial externa é usada.

## Arquivos

- `CentralDoCao.rbxlx` — place pronto para abrir diretamente no Roblox Studio.
- `default.project.json` — mapeamento Rojo.
- `src/ReplicatedStorage/Shared/GameConfig.lua` — textos, clientes, recompensas e limites.
- `src/ServerScriptService/WorldBuilder.lua` — construção procedural do escritório.
- `src/ServerScriptService/OfficeGame.server.lua` — conversas, salvamento, dinheiro, remotes e ranking.
- `src/StarterPlayer/StarterPlayerScripts/OfficeGame.client.lua` — interface, TTS e entrada opcional por voz.
