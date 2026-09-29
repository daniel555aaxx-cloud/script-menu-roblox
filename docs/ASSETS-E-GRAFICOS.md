# Assets e gráficos (como chegar no visual do desenho e do filme)

O jogo **roda 100% sem nenhum upload**: os sons usam a biblioteca embutida do
cliente (`rbxasset://sounds/...`) e os modelos são construídos em código. Para
elevar a fidelidade ao material original, use os "slots" abaixo.

## 1. Modelos 3D personalizados

Os personagens e monstros são montados por `CharacterBuilder` a partir de specs
declarativas. Você pode substituir por modelos próprios (importados do desenho
ou esculpidos por você):

1. Importe o modelo no Studio (`.fbx`/`.obj` → rig R15 ou pacote rígido).
2. Coloque dentro de `ServerStorage.CustomModels`, com o nome exato do id:
   * `MONSTER_EP01_Fantasma`, `MONSTER_EP02_Hospede`, ..., `MONSTER_EP07_Colecionador`
   * `HERO_Fred`, `HERO_Daphne`, `HERO_Velma`, `HERO_Shaggy`, `HERO_Scooby`
   * `NPC_EP01_Keeper`, `NPC_EP01_Duarte`, ... (veja `Cast.Npcs` para a lista)
3. Pronto: `CharacterBuilder` detecta e usa o modelo customizado; se não existir,
   cai no procedural — **o jogo nunca quebra por falta de asset**.

Requisitos: o modelo precisa de uma `BasePart` primária (o builder usa
`Model.PrimaryPart`) e escala aproximada de **5–7 studs** de altura para humanos
e **10–14** para monstros.

## 2. Texturas e decais (paredes, pistas, quadros)

`Assets.Textures` e `Assets.Decals` aceitam IDs (`rbxassetid://NUMERO`).
Sugestões de uso:
* papel de parede do hotel, madeira do circo, azulejo da fábrica;
* retratos e pistas (fotos, cartas, bilhetes) — aparecem nos props de pista;
* placas de "Bem-vindo a Coolsville", cartazes do circo, gibis.

```lua
-- src/shared/Assets.luau
Assets.Textures.HotelWallpaper = 123456789
Assets.Decals.CluePhoto = 987654321
```

## 3. Materiais realistas (PBR)

`PartKit.surfaceAppearance(part, { albedo = ..., normal = ..., roughness = ..., metalness = ... })`
aplica um `SurfaceAppearance` em qualquer peça. Onde usar:
* madeira envelhecida do píer, ferro fundido do farol, mármore do hotel;
* tecido do vestido da Daphne, lã do suéter da Velma, pelo do Scooby.

## 4. Iluminação

`Graphics.Moods` define o humor de cada episódio (névoa, cor ambiente, brilho do
sol/lua, exposição). `Graphics.applyMood(nome)` é chamado pelo `MapService` na
troca de mapa e replicado ao cliente. Presets de qualidade:

| Preset | Para quem | O que muda |
|---|---|---|
| Baixo | celular | sombras desligadas, sem partículas extras |
| Médio | padrão | sombras básicas |
| Alto | PC | sombras + PBR + partículas + luz volumétrica simulada |
| Ultra | PC forte | tudo + distância de render maior |
| Cinema | criadores/trailers | DOF, bloom forte, cor cinematográfica |

O preset é aplicado por jogador: `Graphics.applyClientPreset(player, "Ultra")`.

## 5. Trilha sonora

`Assets.Sounds.*` tem slots para: `ThemeMusic`, `LobbyMusic`, `ChaseMusic`,
`RevealMusic`, `SuspenseMusic`, `MysteryMachineHorn`, `ScoobySnackCrunch`,
`GhostMoan`, `Heartbeat`, `TrapSpring`, `UnmaskStinger`, `Flashlight`.

Enquanto o slot for `0`, o jogo usa o som embutido correspondente
(`Assets.Sfx`) ou silêncio — nunca falha.

> ⚠️ **Direitos autorais:** não suba músicas ou artes oficiais da Warner sem
> licença. Prefira trilha original, SFX gratuitos ou criação própria. Este
> projeto é um tributo técnico e deve ficar fora de monetização.

## 6. Fidelidade visual recomendada (checklist rápido)

* [ ] Rostos: use `Decal` no `Head` dos heróis (`Cast.Heroes[x].faces`).
* [ ] Cores: mantenha a paleta clássica (`Config.Palette`) — é o que "vende" o
      reconhecimento do desenho.
* [ ] Escala dos monstros: 10–14 studs (assustadores sem inviabilizar a fuga).
* [ ] Névoa por episódio: farol com névoa densa, mansão com névoa leve e
      partículas de poeira.
* [ ] Fontes de luz pontuais com flicker nas cenas de perseguição
      (`Config.Monster.REVEAL_TAUNT_CHANCE`).
