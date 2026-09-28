#!/usr/bin/env python3
"""
Gera Parkour_ASMR.rbxlx — mapa de parkour para Roblox Studio
com checkpoints, moedas, obstáculos e sistema de ASMR de teclado.

Uso:   python3 build_parkour.py
Saida: Parkour_ASMR.rbxlx (abra no Studio: Arquivo > Abrir do arquivo)
"""

import math
import random
import uuid
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "src"
OUT = ROOT / "Parkour_ASMR.rbxlx"

# ---------------------------------------------------------------------------
# Materiais (Enum.Material) e cores
# ---------------------------------------------------------------------------
PLASTIC = 256
SMOOTH = 272
NEON = 288
WOOD = 512


def color_uint8(rgb):
    r, g, b = (max(0, min(255, int(round(c * 255)))) for c in rgb)
    return 0xFF000000 | (r << 16) | (g << 8) | b


SKY = (0.60, 0.84, 1.00)
MINT = (0.66, 0.96, 0.82)
LEMON = (1.00, 0.93, 0.62)
PEACH = (1.00, 0.78, 0.60)
LAV = (0.80, 0.72, 1.00)
PINK = (1.00, 0.72, 0.83)
CORAL = (1.00, 0.62, 0.58)
ICE = (0.78, 0.95, 1.00)
CP_GREEN = (0.25, 1.00, 0.55)
MOVER_YEL = (1.00, 0.90, 0.25)
FALL_BROWN = (0.76, 0.54, 0.32)
SPIN_RED = (1.00, 0.28, 0.25)
LAVA_RED = (1.00, 0.28, 0.10)
GOLD = (1.00, 0.84, 0.25)
WHITE = (1.00, 1.00, 1.00)
CYAN = (0.30, 0.95, 1.00)
LOBBY_BLUE = (0.68, 0.86, 1.00)
SPAWN_Y = (1.00, 0.95, 0.65)
PAD_STONE = (0.90, 0.93, 0.97)

# Pastas do mapa (caminho de itens)
F_LOBBY = ["ParkourMap", "Lobby"]
F_PLAT = ["ParkourMap", "Course", "Platforms"]
F_CP = ["ParkourMap", "Course", "Checkpoints"]
F_MOVER = ["ParkourMap", "Course", "Movers"]
F_FALL = ["ParkourMap", "Course", "FallingPlatforms"]
F_SPIN = ["ParkourMap", "Course", "Spinners"]
F_COIN = ["ParkourMap", "Course", "Coins"]
F_FINISH = ["ParkourMap", "Course"]
F_DECOR = ["ParkourMap", "Decor"]
F_HAZ = ["ParkourMap", "Hazards"]

rng = random.Random(20260928)
parts = []
movers_cfg = []
spinners_cfg = []
falling_names = []
counters = {"plat": 0, "coin": 0, "cp": 0}


def add(name, folder, center, size, color, mat=SMOOTH, yaw=0.0,
        transparency=0.0, can_collide=True, cls="Part"):
    parts.append({
        "name": name, "folder": folder, "center": center, "size": size,
        "color": color, "mat": mat, "yaw": yaw, "transparency": transparency,
        "can_collide": can_collide, "cls": cls,
    })


def place_coin(x, y, z):
    counters["coin"] += 1
    add(f"Coin_{counters['coin']}", F_COIN, (x, y, z), (1.8, 1.8, 0.5),
        GOLD, NEON, transparency=0.05, can_collide=False)


class Cursor:
    """Plataforma atual (de onde os pulos partem)."""

    def __init__(self, cx, top, cz, sx, sz):
        self.cx, self.top, self.cz, self.sx, self.sz = cx, top, cz, sx, sz


cur = Cursor(-16.0, 0.0, 0.0, 34.0, 34.0)


def link(size, gap, dz=0.0, dy=0.0, size_z=None, color=SKY, mat=SMOOTH,
         yaw=0.0, coin=False, coin_dz=0.0, coin_rise=2.4, name=None,
         folder=None, sy=1.0):
    """Coloca uma plataforma à frente do cursor e avança o cursor."""
    sz = size if size_z is None else size_z
    prev_edge = cur.cx + cur.sx / 2
    cx = prev_edge + gap + size / 2
    cz = cur.cz + dz
    top = cur.top + dy
    if name is None:
        counters["plat"] += 1
        name = f"Plat_{counters['plat']}"
    add(name, folder or F_PLAT, (cx, top - sy / 2, cz), (size, sy, sz),
        color, mat, yaw=yaw)
    if coin:
        mid_x = (prev_edge + (cx - size / 2)) / 2
        mid_z = (cur.cz + cz) / 2 + coin_dz
        place_coin(mid_x, top + coin_rise, mid_z)
    cur.cx, cur.top, cur.cz, cur.sx, cur.sz = cx, top, cz, size, sz
    return cx, top, cz


def checkpoint(gap=4.0):
    counters["cp"] += 1
    link(9.0, gap, color=CP_GREEN, mat=NEON,
         name=f"Checkpoint_{counters['cp']}", folder=F_CP)


def mover_link(size, gap, amp, speed, phase, dz_pos=0.0, y_offset=0.0,
               size_z=None, color=MOVER_YEL, name=None):
    """Plataforma móvel: posiciona e registra o movimento (amplitudes)."""
    sz = size if size_z is None else size_z
    prev_edge = cur.cx + cur.sx / 2
    cx = prev_edge + gap + size / 2
    cz = cur.cz + dz_pos
    top = cur.top + y_offset
    counters["plat"] += 1
    name = name or f"Mover_{counters['plat']}"
    add(name, F_MOVER, (cx, top - 0.5, cz), (size, 1.0, sz), color, NEON)
    movers_cfg.append({
        "name": name, "dx": amp[0], "dy": amp[1], "dz": amp[2],
        "speed": speed, "phase": phase,
    })
    cur.cx, cur.top, cur.cz, cur.sx, cur.sz = cx, top, cz, size, sz
    return cx, top, cz


def falling_link(size, gap, dz=0.0, color=FALL_BROWN, coin=False, coin_dz=0.0):
    name = f"Fall_{len(falling_names) + 1}"
    falling_names.append(name)
    link(size, gap, dz=dz, color=color, mat=WOOD, name=name, folder=F_FALL,
         coin=coin, coin_dz=coin_dz)
    return name


def spinner_pad(gap=4.5, speed=0.95, name="Spinner_1"):
    link(15.0, gap, size_z=12.0, color=PAD_STONE)
    add(name, F_SPIN, (cur.cx, cur.top + 1.15, cur.cz), (16.0, 1.6, 1.6),
        SPIN_RED, NEON)
    spinners_cfg.append({"name": name, "speed": speed, "phase": 0.0})


# ---------------------------------------------------------------------------
# LOBBY
# ---------------------------------------------------------------------------
add("LobbyBase", F_LOBBY, (-16, -0.5, 0), (34, 1, 34), LOBBY_BLUE, SMOOTH)
add("TrimN", F_LOBBY, (-16, 0.22, -16.5), (34, 0.44, 1), WHITE, NEON)
add("TrimS", F_LOBBY, (-16, 0.22, 16.5), (34, 0.44, 1), CYAN, NEON)
add("TrimW", F_LOBBY, (-32.5, 0.22, 0), (1, 0.44, 34), WHITE, NEON)
add("StartLine", F_LOBBY, (0.5, 0.22, 0), (1, 0.44, 34), GOLD, NEON)
add("SpawnLocation", F_LOBBY, (-26, 0.3, 0), (8, 0.6, 8), SPAWN_Y, SMOOTH,
    cls="SpawnLocation")

# ---------------------------------------------------------------------------
# S1 — Aquecimento (fácil, plano)
# ---------------------------------------------------------------------------
s1_sizes = [8, 8, 7.5, 7.5, 7, 7]
s1_gaps = [4.5, 4.5, 5, 4.5, 5]
s1_colors = [SKY, MINT, LEMON]
for i, (sz, gp) in enumerate(zip(s1_sizes, s1_gaps)):
    link(sz, gp, dz=rng.uniform(-2, 2), color=s1_colors[i % 3],
         coin=(i == 2))
checkpoint(4)

# ---------------------------------------------------------------------------
# S2 — Subida (fácil, ganhando altura)
# ---------------------------------------------------------------------------
s2_sizes = [7.5, 7, 7, 6.5, 6.5, 6]
s2_gaps = [4.5, 5, 5, 5, 5.5]
s2_dy = [1.5, 2, 1.5, 2.5, 2]
s2_colors = [MINT, LEMON, SKY]
for i, (sz, gp, dy) in enumerate(zip(s2_sizes, s2_gaps, s2_dy)):
    link(sz, gp, dz=rng.uniform(-3, 3), dy=dy, color=s2_colors[i % 3],
         coin=(i == 3))
checkpoint(4)

# ---------------------------------------------------------------------------
# S3 — Balsa (plataforma móvel no eixo X)
# ---------------------------------------------------------------------------
mover_link(8, gap=2.5, amp=(2.5, 0, 0), speed=0.85, phase=-math.pi / 2)
link(7, 2.5, color=PEACH)
checkpoint(4)

# ---------------------------------------------------------------------------
# S4 — Ilhas médias
# ---------------------------------------------------------------------------
s4_sizes = [6.5, 6, 6, 5.5, 5.5, 5.5]
s4_gaps = [5.5, 6, 5.5, 6, 6]
s4_dy = [0, 1.5, -1, 2, -1.5]
s4_colors = [PEACH, LAV, PINK]
for i, (sz, gp, dy) in enumerate(zip(s4_sizes, s4_gaps, s4_dy)):
    yaw = rng.uniform(-8, 8) if i == 2 else 0.0
    link(sz, gp, dz=rng.uniform(-4, 4), dy=dy, color=s4_colors[i % 3],
         yaw=yaw, coin=(i in (1, 4)))
checkpoint(4)

# ---------------------------------------------------------------------------
# S5 — Ponte que cai
# ---------------------------------------------------------------------------
link(6.5, 5, dz=rng.uniform(-1, 1), color=ICE)
falling_link(7, 5)
falling_link(7, 5, coin=True, coin_dz=3)
falling_link(7, 5)
link(6.5, 5, color=ICE)
checkpoint(4)

# ---------------------------------------------------------------------------
# S6 — Giratória
# ---------------------------------------------------------------------------
spinner_pad(gap=4.5, speed=0.95, name="Spinner_1")
link(6, 4.5, dz=2, color=CORAL)
checkpoint(4)

# ---------------------------------------------------------------------------
# S7 — Elevador (móvel vertical)
# ---------------------------------------------------------------------------
link(6.5, 5, color=LAV)
mover_link(6, gap=2.5, amp=(0, 3.5, 0), speed=0.75, phase=-math.pi / 2,
           y_offset=3.5, name="Elevator_1")
link(6.5, 2.5, dy=3.5, color=LAV)
checkpoint(4)

# ---------------------------------------------------------------------------
# S8 — Precisão (plataformas pequenas)
# ---------------------------------------------------------------------------
s8_sizes = [4.5, 4, 4, 3.6, 3.6, 3.4]
s8_gaps = [5.5, 6, 6, 6.2, 6.3]
s8_dy = [1, 1.5, -1, 2, 1]
s8_colors = [CORAL, ICE, LAV]
for i, (sz, gp, dy) in enumerate(zip(s8_sizes, s8_gaps, s8_dy)):
    yaw = rng.uniform(-10, 10) if i in (1, 4) else 0.0
    extra = 7 if i == 2 else 0
    link(sz, gp, dz=rng.uniform(-5, 5), dy=dy, color=s8_colors[i % 3],
         yaw=yaw, coin=(i == 2),
         coin_dz=(extra if rng.random() < 0.5 else -extra))
checkpoint(4)

# ---------------------------------------------------------------------------
# S9 — Coroação (movel lateral + queda + subida final)
# ---------------------------------------------------------------------------
link(6, 5.5, color=PINK)
mover_link(5, gap=0.5, amp=(0, 0, 4.5), speed=0.8, phase=-math.pi / 2,
           dz_pos=4.5, size_z=9, name="SideMover_1")
link(5.5, 0.5, dz=4.5, color=PINK, coin=True, coin_dz=-4.5)
falling_link(6, 5)
link(5, 5, dy=2, color=CORAL)
checkpoint(4)

# ---------------------------------------------------------------------------
# S10 — Chegada
# ---------------------------------------------------------------------------
link(7, 5, color=GOLD, mat=NEON)
finish_cx, finish_top, finish_cz = link(
    14, 4, size_z=14, color=GOLD, mat=NEON, name="Finish", folder=F_FINISH)

# ---------------------------------------------------------------------------
# Lava embaixo de tudo
# ---------------------------------------------------------------------------
lava_x0, lava_x1 = 1.0, finish_cx + 7
add("Lava_Floor", F_HAZ,
    ((lava_x0 + lava_x1) / 2, -14, 0),
    ((lava_x1 - lava_x0) + 80, 2, 140),
    LAVA_RED, NEON, transparency=0.12)

course_end = finish_cx
n_coins = counters["coin"]

# ---------------------------------------------------------------------------
# Serialização RBXLX (XML v4)
# ---------------------------------------------------------------------------
def fmt(x):
    x = float(x)
    if abs(x) < 1e-9:
        return "0"
    if abs(x - round(x)) < 1e-9 and abs(x) < 1e15:
        return str(int(round(x)))
    return repr(round(x, 6))


def esc(text):
    return (str(text).replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace('"', "&quot;"))


class Item:
    def __init__(self, cls, props):
        self.cls = cls
        self.referent = "RBX" + uuid.uuid4().hex.upper()
        self.props = props  # [(nome_attr, corpo_xml)]
        self.children = []

    def render(self, depth):
        pad = "\t" * depth
        lines = [f'{pad}<Item class="{self.cls}" referent="{self.referent}">']
        lines.append(f"{pad}\t<Properties>")
        for _, body in sorted(self.props, key=lambda p: p[0]):
            lines.append(f"{pad}\t\t{body}")
        lines.append(f"{pad}\t</Properties>")
        for child in self.children:
            lines.append(child.render(depth + 1))
        lines.append(f"{pad}</Item>")
        return "\n".join(lines)


def uid_props(name):
    return [
        ("AttributesSerialize",
         '<BinaryString name="AttributesSerialize"></BinaryString>'),
        ("HistoryId",
         '<UniqueId name="HistoryId">00000000000000000000000000000000</UniqueId>'),
        ("Name", f'<string name="Name">{esc(name)}</string>'),
        ("SourceAssetId", '<int64 name="SourceAssetId">-1</int64>'),
        ("Tags", '<BinaryString name="Tags"></BinaryString>'),
        ("UniqueId", f'<UniqueId name="UniqueId">{uuid.uuid4().hex}</UniqueId>'),
    ]


def basic_item(cls, name, extra=None, children=None):
    props = uid_props(name)
    if extra:
        props += extra
    item = Item(cls, props)
    if children:
        item.children = list(children)
    return item


def cframe_prop(x, y, z, rot=(1, 0, 0, 0, 1, 0, 0, 0, 1)):
    r00, r01, r02, r10, r11, r12, r20, r21, r22 = rot
    body = (
        '<CoordinateFrame name="CFrame">'
        f"<X>{fmt(x)}</X><Y>{fmt(y)}</Y><Z>{fmt(z)}</Z>"
        f"<R00>{fmt(r00)}</R00><R01>{fmt(r01)}</R01><R02>{fmt(r02)}</R02>"
        f"<R10>{fmt(r10)}</R10><R11>{fmt(r11)}</R11><R12>{fmt(r12)}</R12>"
        f"<R20>{fmt(r20)}</R20><R21>{fmt(r21)}</R21><R22>{fmt(r22)}</R22>"
        "</CoordinateFrame>"
    )
    return ("CFrame", body)


def vec3_prop(name, v):
    body = (f'<Vector3 name="{name}">'
            f"<X>{fmt(v[0])}</X><Y>{fmt(v[1])}</Y><Z>{fmt(v[2])}</Z>"
            "</Vector3>")
    return (name, body)


def color3_prop(name, rgb):
    body = (f'<Color3 name="{name}">'
            f"<R>{fmt(rgb[0])}</R><G>{fmt(rgb[1])}</G><B>{fmt(rgb[2])}</B>"
            "</Color3>")
    return (name, body)


def rot_y(yaw_deg):
    t = math.radians(yaw_deg)
    c, s = math.cos(t), math.sin(t)
    return (c, 0, s, 0, 1, 0, -s, 0, c)


def part_item(p):
    props = [
        ("Anchored", '<bool name="Anchored">true</bool>'),
        ("AttributesSerialize",
         '<BinaryString name="AttributesSerialize"></BinaryString>'),
        ("CanCollide",
         f'<bool name="CanCollide">{"true" if p["can_collide"] else "false"}</bool>'),
        cframe_prop(*p["center"], rot=rot_y(p["yaw"])),
        ("Color3uint8",
         f'<Color3uint8 name="Color3uint8">{color_uint8(p["color"])}</Color3uint8>'),
        ("Material", f'<token name="Material">{p["mat"]}</token>'),
        ("Name", f'<string name="Name">{esc(p["name"])}</string>'),
        ("SourceAssetId", '<int64 name="SourceAssetId">-1</int64>'),
        ("Tags", '<BinaryString name="Tags"></BinaryString>'),
        ("UniqueId", f'<UniqueId name="UniqueId">{uuid.uuid4().hex}</UniqueId>'),
        vec3_prop("size", p["size"]),
    ]
    if p["transparency"] > 0:
        props.append(("Transparency",
                      f'<float name="Transparency">{fmt(p["transparency"])}</float>'))
    if p["cls"] == "SpawnLocation":
        props += [
            ("Duration", '<int name="Duration">0</int>'),
            ("Enabled", '<bool name="Enabled">true</bool>'),
            ("Neutral", '<bool name="Neutral">true</bool>'),
        ]
    return Item(p["cls"], props)


def script_item(cls, name, source):
    assert "]]>" not in source, f"sequência CDATA inválida em {name}"
    props = uid_props(name) + [
        ("Source",
         f'<ProtectedString name="Source"><![CDATA[{source}]]></ProtectedString>'),
    ]
    return Item(cls, props)


# ---------------------------------------------------------------------------
# Árvore de pastas a partir da lista de peças
# ---------------------------------------------------------------------------
def build_tree():
    root = {}
    for p in parts:
        node = root
        path = p["folder"]
        for i, seg in enumerate(path):
            if seg not in node:
                node[seg] = {
                    "cls": "Model" if seg == "ParkourMap" else "Folder",
                    "kids": {},
                    "parts": [],
                }
            current = node[seg]
            if i == len(path) - 1:
                current["parts"].append(p)
            node = current["kids"]
    # a pasta Decor é preenchida em runtime pelo MapSetup — precisa existir
    decor = root["ParkourMap"]["kids"].setdefault(
        "Decor", {"cls": "Folder", "kids": {}, "parts": []})
    assert decor["cls"] == "Folder"
    return root


def attach_tree(item, node):
    for p in node["parts"]:
        item.children.append(part_item(p))
    for sub_name, sub in node["kids"].items():
        sub_item = basic_item(sub["cls"], sub_name)
        attach_tree(sub_item, sub)
        item.children.append(sub_item)


def map_item():
    tree = build_tree()
    assert set(tree) == {"ParkourMap"}, tree.keys()
    node = tree["ParkourMap"]
    item = basic_item("Model", "ParkourMap")
    attach_tree(item, node)
    return item


# ---------------------------------------------------------------------------
# Câmera olhando para o percurso
# ---------------------------------------------------------------------------
def look_at(pos, target):
    look = [target[i] - pos[i] for i in range(3)]
    length = math.sqrt(sum(v * v for v in look))
    look = [v / length for v in look]
    back = [-v for v in look]
    right = [back[2], 0.0, -back[0]]
    rlen = math.hypot(right[0], right[2])
    right = [right[0] / rlen, 0.0, right[2] / rlen]
    up = [
        back[1] * right[2] - back[2] * right[1],
        back[2] * right[0] - back[0] * right[2],
        back[0] * right[1] - back[1] * right[0],
    ]
    return (
        right[0], up[0], back[0],
        right[1], up[1], back[1],
        right[2], up[2], back[2],
    )


CAM_POS = (-52, 26, 40)
CAM_TARGET = (70, 6, 0)


def workspace_item(map_item_obj):
    cam = basic_item("Camera", "Camera", [
        ("FieldOfView", '<float name="FieldOfView">70</float>'),
        cframe_prop(*CAM_POS, rot=look_at(CAM_POS, CAM_TARGET)),
        ("Focus",
         '<CoordinateFrame name="Focus">'
         f"<X>{fmt(CAM_TARGET[0])}</X><Y>{fmt(CAM_TARGET[1])}</Y>"
         f"<Z>{fmt(CAM_TARGET[2])}</Z>"
         "<R00>1</R00><R01>0</R01><R02>0</R02>"
         "<R10>0</R10><R11>1</R11><R12>0</R12>"
         "<R20>0</R20><R21>0</R21><R22>1</R22>"
         "</CoordinateFrame>"),
    ])
    props = [
        ("AttributesSerialize",
         '<BinaryString name="AttributesSerialize"></BinaryString>'),
        ("CurrentCamera", f'<Ref name="CurrentCamera">{cam.referent}</Ref>'),
        ("FallenPartsDestroyHeight",
         '<float name="FallenPartsDestroyHeight">-500</float>'),
        ("Name", '<string name="Name">Workspace</string>'),
        ("SourceAssetId", '<int64 name="SourceAssetId">-1</int64>'),
        ("StreamingEnabled", '<bool name="StreamingEnabled">false</bool>'),
        ("Tags", '<BinaryString name="Tags"></BinaryString>'),
        ("UniqueId", f'<UniqueId name="UniqueId">{uuid.uuid4().hex}</UniqueId>'),
    ]
    ws = Item("Workspace", props)
    ws.children = [cam, map_item_obj]
    return ws


# ---------------------------------------------------------------------------
# Serviços
# ---------------------------------------------------------------------------
def lighting_item():
    props = uid_props("Lighting") + [
        color3_prop("Ambient", (0.38, 0.38, 0.42)),
        ("Brightness", '<float name="Brightness">3</float>'),
        ("ClockTime", '<float name="ClockTime">15.4</float>'),
        color3_prop("FogColor", (0.72, 0.8, 0.9)),
        ("FogEnd", '<float name="FogEnd">1600</float>'),
        ("FogStart", '<float name="FogStart">0</float>'),
        ("GlobalShadows", '<bool name="GlobalShadows">true</bool>'),
        color3_prop("OutdoorAmbient", (0.5, 0.5, 0.55)),
        ("ShadowSoftness", '<float name="ShadowSoftness">0.25</float>'),
        ("TimeOfDay", '<string name="TimeOfDay">15:24:00</string>'),
    ]
    item = Item("Lighting", props)

    sky = basic_item("Sky", "Sky", [
        ("CelestialBodiesShown",
         '<bool name="CelestialBodiesShown">true</bool>'),
        ("SkyboxBk",
         '<Content name="SkyboxBk"><url>rbxassetid://6444884337</url></Content>'),
        ("SkyboxDn",
         '<Content name="SkyboxDn"><url>rbxassetid://6444884785</url></Content>'),
        ("SkyboxFt",
         '<Content name="SkyboxFt"><url>rbxassetid://6444884337</url></Content>'),
        ("SkyboxLf",
         '<Content name="SkyboxLf"><url>rbxassetid://6444884337</url></Content>'),
        ("SkyboxRt",
         '<Content name="SkyboxRt"><url>rbxassetid://6444884337</url></Content>'),
        ("SkyboxUp",
         '<Content name="SkyboxUp"><url>rbxassetid://6412503613</url></Content>'),
        ("StarCount", '<int name="StarCount">3000</int>'),
    ])
    colorcc = basic_item("ColorCorrectionEffect", "ColorCorrection", [
        ("Brightness", '<float name="Brightness">0.01</float>'),
        ("Contrast", '<float name="Contrast">0.06</float>'),
        ("Enabled", '<bool name="Enabled">true</bool>'),
        ("Saturation", '<float name="Saturation">0.12</float>'),
        color3_prop("TintColor", (1.0, 0.995, 0.985)),
    ])
    bloom = basic_item("BloomEffect", "Bloom", [
        ("Enabled", '<bool name="Enabled">true</bool>'),
        ("Intensity", '<float name="Intensity">0.7</float>'),
        ("Size", '<float name="Size">32</float>'),
        ("Threshold", '<float name="Threshold">1.1</float>'),
    ])
    rays = basic_item("SunRaysEffect", "SunRays", [
        ("Enabled", '<bool name="Enabled">true</bool>'),
        ("Intensity", '<float name="Intensity">0.04</float>'),
        ("Spread", '<float name="Spread">0.12</float>'),
    ])
    atmos = basic_item("Atmosphere", "Atmosphere", [
        color3_prop("Color", (0.78, 0.79, 0.82)),
        color3_prop("Decay", (0.42, 0.44, 0.49)),
        ("Density", '<float name="Density">0.28</float>'),
        ("Glare", '<float name="Glare">0.1</float>'),
        ("Haze", '<float name="Haze">1.2</float>'),
        ("Offset", '<float name="Offset">0.25</float>'),
    ])
    item.children = [sky, colorcc, bloom, rays, atmos]
    return item


def players_item():
    return basic_item("Players", "Players", [
        ("CharacterAutoLoads", '<bool name="CharacterAutoLoads">true</bool>'),
        ("RespawnTime", '<float name="RespawnTime">4</float>'),
    ])


# ---------------------------------------------------------------------------
# Config Lua dos obstáculos
# ---------------------------------------------------------------------------
def lua_num(v):
    return f"{v:.6g}"


def lua_movers_config():
    return "\n".join(
        '\t{ name = "%s", dx = %s, dy = %s, dz = %s, speed = %s, phase = %s },'
        % (c["name"], lua_num(c["dx"]), lua_num(c["dy"]), lua_num(c["dz"]),
           lua_num(c["speed"]), lua_num(c["phase"]))
        for c in movers_cfg
    )


def lua_spinners_config():
    return "\n".join(
        '\t{ name = "%s", speed = %s, phase = %s },'
        % (c["name"], lua_num(c["speed"]), lua_num(c["phase"]))
        for c in spinners_cfg
    )


def lua_falling_config():
    return "\n".join(f'\t"{name}",' for name in falling_names)


# ---------------------------------------------------------------------------
# Montagem final + validação
# ---------------------------------------------------------------------------
def main():
    gamecore = (SRC / "gamecore.lua").read_text(encoding="utf-8")
    for placeholder in ("__MOVERS_CONFIG__", "__SPINNERS_CONFIG__",
                        "__FALLING_CONFIG__"):
        assert placeholder in gamecore, f"placeholder ausente: {placeholder}"
    gamecore = gamecore.replace("__MOVERS_CONFIG__", lua_movers_config())
    gamecore = gamecore.replace("__SPINNERS_CONFIG__", lua_spinners_config())
    gamecore = gamecore.replace("__FALLING_CONFIG__", lua_falling_config())
    assert "__MOVERS" not in gamecore and "__FALLING" not in gamecore

    mapsetup = (SRC / "mapsetup.lua").read_text(encoding="utf-8")
    asmr = (SRC / "asmr.lua").read_text(encoding="utf-8")
    hud = (SRC / "hud.lua").read_text(encoding="utf-8")

    services = []

    ws = workspace_item(map_item())
    services.append(ws.render(1))
    services.append(lighting_item().render(1))
    services.append(basic_item("SoundService", "SoundService").render(1))
    services.append(players_item().render(1))
    services.append(basic_item("ReplicatedStorage", "ReplicatedStorage").render(1))

    sss = basic_item("ServerScriptService", "ServerScriptService", children=[
        script_item("Script", "GameCore", gamecore),
        script_item("Script", "MapSetup", mapsetup),
    ])
    services.append(sss.render(1))

    sps = basic_item("StarterPlayerScripts", "StarterPlayerScripts", children=[
        script_item("LocalScript", "ASMRKeyboard", asmr),
        script_item("LocalScript", "ParkourHUD", hud),
    ])
    sp = basic_item("StarterPlayer", "StarterPlayer", children=[
        sps,
        basic_item("StarterCharacterScripts", "StarterCharacterScripts"),
    ])
    services.append(sp.render(1))

    header = (
        '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" '
        'version="4">\n'
        "\t<External>null</External>\n"
        "\t<External>nil</External>\n"
    )
    xml_text = header + "\n".join(services) + "</roblox>\n"

    # --- validação ---------------------------------------------------------
    root = ET.fromstring(xml_text)
    assert root.tag == "roblox" and root.get("version") == "4"
    referents = [it.get("referent") for it in root.iter("Item")]
    assert len(referents) == len(set(referents)), "referentes duplicados"
    assert None not in referents
    for it in root.iter("Item"):
        props = it.find("Properties")
        assert props is not None and len(list(props)) >= 1, \
            f"Item sem Properties: {it.get('class')}"
    for vec in root.iter("Vector3"):
        assert {c.tag for c in vec} == {"X", "Y", "Z"}, "Vector3 malformado"
    for cf in root.iter("CoordinateFrame"):
        tags = [c.tag for c in cf]
        assert tags == ["X", "Y", "Z", "R00", "R01", "R02", "R10", "R11",
                        "R12", "R20", "R21", "R22"], "CFrame malformado"

    script_names = set()
    for it in root.iter("Item"):
        if it.get("class") in ("Script", "LocalScript"):
            props = it.find("Properties")
            src = props.find("ProtectedString")
            assert src is not None and src.text and len(src.text) > 500
            for prop in props:
                if prop.get("name") == "Name":
                    script_names.add(prop.text)
    assert script_names == {"GameCore", "MapSetup", "ASMRKeyboard", "ParkourHUD"}, \
        script_names

    # conferências de jogo
    part_names = set()
    for it in root.iter("Item"):
        if it.get("class") in ("Part", "SpawnLocation"):
            for prop in it.find("Properties"):
                if prop.get("name") == "Name":
                    part_names.add(prop.text)
    for i in range(1, counters["cp"] + 1):
        assert f"Checkpoint_{i}" in part_names
    assert "Finish" in part_names and "Lava_Floor" in part_names
    assert "SpawnLocation" in part_names
    for name in falling_names:
        assert name in part_names
    for cfg in movers_cfg + spinners_cfg:
        assert cfg["name"] in part_names, cfg["name"]

    OUT.write_text(xml_text, encoding="utf-8")

    print(f"Arquivo gerado: {OUT}")
    print(f"  tamanho............ {OUT.stat().st_size / 1024:.1f} KB")
    print(f"  plataformas........ {counters['plat']}")
    print(f"  checkpoints........ {counters['cp']}")
    print(f"  moedas............. {n_coins}")
    print(f"  movers............. {len(movers_cfg)}")
    print(f"  giratorias......... {len(spinners_cfg)}")
    print(f"  que-caem........... {len(falling_names)}")
    print(f"  fim do percurso.... x = {course_end:.0f} studs")
    print(f"  itens XML.......... {len(referents)}")


if __name__ == "__main__":
    main()
