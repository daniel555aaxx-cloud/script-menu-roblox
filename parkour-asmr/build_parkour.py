#!/usr/bin/env python3
"""
Gera Parkour_ASMR.rbxlx — mapa de parkour para Roblox Studio
com 42 níveis em 7 mundos, ASMR de teclado e progresso salvo.

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

TOTAL_WORLDS = 7
LEVELS_PER_WORLD = 6
TOTAL_LEVELS = TOTAL_WORLDS * LEVELS_PER_WORLD  # 42

Z_LIMIT = 12      # faixa lateral máxima do percurso
TOP_CEILING = 52  # altura máxima do percurso (ajusta descidas)


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
SAND = (0.96, 0.87, 0.62)
JADE = (0.55, 0.93, 0.74)
TEAL = (0.45, 0.85, 0.88)
STEEL = (0.78, 0.81, 0.86)
ORANGE = (1.00, 0.72, 0.35)
ROYAL = (0.98, 0.95, 0.85)
CP_GREEN = (0.25, 1.00, 0.55)
MOVER_YEL = (1.00, 0.90, 0.25)
FALL_BROWN = (0.76, 0.54, 0.32)
SPIN_RED = (1.00, 0.28, 0.25)
LAVA_RED = (1.00, 0.28, 0.10)
GOLD = (1.00, 0.84, 0.25)
WHITE = (1.00, 1.00, 1.00)
CYAN = (0.30, 0.95, 1.00)
VIOLET = (0.72, 0.45, 1.00)
LOBBY_BLUE = (0.68, 0.86, 1.00)
SPAWN_Y = (1.00, 0.95, 0.65)
PAD_STONE = (0.90, 0.93, 0.97)
VANISH_CYAN = (0.55, 0.95, 1.00)
BEAM_WHITE = (0.94, 0.96, 1.00)

# Pastas do mapa
F_LOBBY = ["ParkourMap", "Lobby"]
F_PLAT = ["ParkourMap", "Course", "Platforms"]
F_CP = ["ParkourMap", "Course", "Checkpoints"]
F_MOVER = ["ParkourMap", "Course", "Movers"]
F_FALL = ["ParkourMap", "Course", "FallingPlatforms"]
F_VANISH = ["ParkourMap", "Course", "VanishPlatforms"]
F_SPIN = ["ParkourMap", "Course", "Spinners"]
F_COIN = ["ParkourMap", "Course", "Coins"]
F_PADS = ["ParkourMap", "Course", "Pads"]
F_FINISH = ["ParkourMap", "Course"]
F_DECOR = ["ParkourMap", "Decor"]
F_HAZ = ["ParkourMap", "Hazards"]

rng = random.Random(20260928)
parts = []
movers_cfg = []
spinners_cfg = []
falling_names = []
vanish_cfg = []
boosts_cfg = []
speedpads_cfg = []
world_signs = []      # placas dos mundos (x, y, z, título, subtítulo)
worlds_hud = []       # primeiro nível de cada mundo (para o HUD)
counters = {"plat": 0, "coin": 0, "cp": 0, "pad": 0, "spinner": 0}
PAL = [SKY, MINT, LEMON]


def pal(i):
    return PAL[i % len(PAL)]


def add(name, folder, center, size, color, mat=SMOOTH, yaw=0.0,
        transparency=0.0, can_collide=True, cls="Part", special=None):
    p = {
        "name": name, "folder": folder, "center": center, "size": size,
        "color": color, "mat": mat, "yaw": yaw, "transparency": transparency,
        "can_collide": can_collide, "cls": cls, "special": special,
    }
    parts.append(p)
    return p


def place_coin(x, y, z):
    counters["coin"] += 1
    add(f"Coin_{counters['coin']}", F_COIN, (x, y, z), (1.8, 1.8, 0.5),
        GOLD, NEON, transparency=0.05, can_collide=False)


class Cursor:
    """Plataforma atual (de onde os pulos partem)."""

    def __init__(self, cx, top, cz, sx, sz):
        self.cx, self.top, self.cz, self.sx, self.sz = cx, top, cz, sx, sz


cur = Cursor(-16.0, 0.0, 0.0, 34.0, 34.0)


def clamp_z(z):
    return max(-Z_LIMIT, min(Z_LIMIT, z))


def clamp_dy(dy, exempt=False):
    """Mantém o percurso dentro da faixa de altura (descida gradual)."""
    if exempt:
        return dy
    if cur.top + dy > TOP_CEILING:
        over = cur.top + dy - TOP_CEILING
        dy = max(dy - over * 0.6, -4.5)  # no máximo ~4.5 studs por degrau
    if cur.top + dy < 2:
        dy = max(dy, 2 - cur.top)
    return dy


def clamp_jump(gap, dz, special=None):
    """Limita o pulo a ~7.3 studs horizontais (descontando o deslocamento
    lateral), exceto nas pistas de velocidade (14 studs)."""
    if special == "speed":
        return gap, dz
    eff = math.hypot(max(gap, 0.0), dz)
    if eff <= 7.3:
        return gap, dz
    if abs(dz) > 6.4:
        dz = math.copysign(6.4, dz)
    gap = max(3.4, math.sqrt(max(7.3 ** 2 - dz ** 2, 4.0)))
    return gap, dz


def link(size, gap, dz=0.0, dy=0.0, size_z=None, color=SKY, mat=SMOOTH,
         yaw=0.0, coin=False, coin_dz=0.0, coin_rise=2.4, name=None,
         folder=None, sy=1.0, special=None):
    """Coloca uma plataforma à frente do cursor e avança o cursor."""
    sz = size if size_z is None else size_z
    prev_edge = cur.cx + cur.sx / 2
    cz = clamp_z(cur.cz + dz)
    gap, dz_off = clamp_jump(gap, cz - cur.cz, special)
    cz = clamp_z(cur.cz + dz_off)
    dy = clamp_dy(dy, exempt=(special == "boost"))
    cx = prev_edge + gap + size / 2
    top = cur.top + dy
    if name is None:
        counters["plat"] += 1
        name = f"Plat_{counters['plat']}"
    add(name, folder or F_PLAT, (cx, top - sy / 2, cz), (size, sy, sz),
        color, mat, yaw=yaw, special=special)
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
    cz = clamp_z(cur.cz + dz_pos)
    gap2, dz2 = clamp_jump(gap, cz - cur.cz)
    cz = clamp_z(cur.cz + dz2)
    cx = prev_edge + gap2 + size / 2
    top = cur.top + clamp_dy(y_offset)
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


def vanish_link(size, gap, dz=0.0, dy=0.0, coin=False):
    counters["pad"] += 1
    name = f"Vanish_{counters['pad']}"
    idx = len(vanish_cfg)
    link(size, gap, dz=dz, dy=dy, color=VANISH_CYAN, mat=NEON,
         name=name, folder=F_VANISH, coin=coin)
    vanish_cfg.append({
        "name": name, "cycle": 4.0, "phase": round(idx * 0.5, 3),
    })
    return name


def spinner_pad(gap=4.5, speed=0.95, bars=1, pad_size=15.0, pad_z=12.0,
                bar_len=16.0, color=PAD_STONE):
    link(pad_size, gap, size_z=pad_z, color=color)
    for b in range(bars):
        counters["spinner"] += 1
        name = f"Spinner_{counters['spinner']}"
        yaw = 90.0 if b % 2 == 1 else 0.0
        add(name, F_SPIN, (cur.cx, cur.top + 1.15, cur.cz),
            (bar_len, 1.6, 1.6), SPIN_RED, NEON, yaw=yaw)
        spinners_cfg.append({"name": name, "speed": speed, "phase": 0.0})


def place_boost_pad(platform_top, cx, cz, sx, sz, power):
    counters["pad"] += 1
    name = f"Boost_{counters['pad']}"
    w = min(sx - 0.6, 6.5)
    d = min(sz - 0.6, 5.5)
    add(name, F_PADS, (cx, platform_top + 0.22, cz), (w, 0.44, d),
        VIOLET, NEON, can_collide=False)
    boosts_cfg.append({"name": name, "power": power})
    return name


def place_speed_pad(platform_top, cx, cz, sx, sz):
    counters["pad"] += 1
    name = f"Speed_{counters['pad']}"
    w = min(sx - 0.6, 11.0)
    d = min(sz - 0.4, 3.8)
    add(name, F_PADS, (cx, platform_top + 0.2, cz), (w, 0.4, d),
        ORANGE, NEON, can_collide=False)
    speedpads_cfg.append({"name": name, "speed": 28, "duration": 2.6})
    return name


def center_pull(spread):
    return rng.uniform(-spread, spread) - 0.35 * cur.cz


# ---------------------------------------------------------------------------
# Segmentos de fase (cada um termina com um checkpoint)
# ---------------------------------------------------------------------------
def seg_chain(n=5, gap=(4.5, 5.5), size=(8, 7), spread=3.0, dy=(0, 1.5),
              coins=(), yaw_range=0.0):
    for i in range(n):
        s = rng.uniform(*size)
        dyy = clamp_dy(rng.uniform(*dy))
        yaw = rng.uniform(-yaw_range, yaw_range) if yaw_range else 0.0
        link(s, rng.uniform(*gap), dz=center_pull(spread), dy=dyy,
             color=pal(i), yaw=yaw, coin=(i in coins))


def seg_stairs(n=5, rise=1.6, spread=3.2, coins=()):
    for i in range(n):
        side = spread if i % 2 == 0 else -spread
        dyy = clamp_dy(rise)
        link(6.5, 4.3, dz=side - 0.25 * cur.cz, dy=dyy, color=pal(i),
             coin=(i in coins))


def seg_precise(n=4, gap=(5.4, 6.4), size=(4.6, 3.6), spread=4.5,
                coins=(), yaw_range=8.0):
    for i in range(n):
        s = rng.uniform(*size)
        yaw = rng.uniform(-yaw_range, yaw_range)
        dyy = clamp_dy(rng.uniform(-1, 1.5))
        link(s, rng.uniform(*gap), dz=center_pull(spread), dy=dyy,
             color=pal(i), yaw=yaw, coin=(i in coins))


def seg_speedrun(gap=9.0):
    # pista com speed pad e salto longo
    link(12.0, 4.2, size_z=4.2, color=ORANGE)
    place_speed_pad(cur.top, cur.cx, cur.cz, cur.sx, cur.sz)
    link(7.5, gap, dz=center_pull(1.5), color=pal(1), special="speed")


def seg_ferry():
    mover_link(8, gap=2.5, amp=(2.5, 0, 0), speed=0.85, phase=-math.pi / 2)
    link(7, 2.5, color=pal(0))


def seg_elevator():
    link(6.5, 5, color=pal(1))
    counters["plat"] += 1
    mover_link(6, gap=2.5, amp=(0, 3.5, 0), speed=0.75, phase=-math.pi / 2,
               y_offset=3.5, name=f"Elevator_{counters['plat']}")
    link(6.5, 2.5, color=pal(2))  # mesma altura do elevador (cursor já subiu)


def seg_sidemover(coin=False):
    direction = -1.0 if cur.cz > 0 else 1.0
    mover_link(5, gap=0.5, amp=(0, 0, 4.5 * direction), speed=0.8,
               phase=-math.pi / 2, dz_pos=4.5 * direction, size_z=9,
               name=f"SideMover_{len(movers_cfg) + 1}")
    link(5.5, 0.5, dz=4.5 * direction, color=pal(0), coin=coin,
         coin_dz=-3 * direction)


def seg_falling(n=3, coins=()):
    link(6.5, 5, dz=center_pull(1.5), color=ICE)
    for i in range(n):
        falling_link(7, 5, coin=(i in coins), coin_dz=3)
    link(6.5, 5, color=ICE)


def seg_spinner(bars=1, gap=4.5, speed=0.95):
    spinner_pad(gap=gap, speed=speed, bars=bars)
    link(6, 4.5, dz=center_pull(2), color=CORAL)


def seg_vanish(n=3, coins=()):
    for i in range(n):
        vanish_link(6.2, 5.0, dz=center_pull(2.0), coin=(i in coins))


def seg_beam(with_spinner=False):
    link(16.0, 4.5, size_z=2.8, color=BEAM_WHITE)
    if with_spinner:
        spinner_pad(gap=4.5, speed=1.05, pad_size=12.0, pad_z=10.0,
                    bar_len=13.5)
        link(16.0, 4.5, size_z=2.8, color=BEAM_WHITE)
    else:
        link(9.0, 4.5, color=pal(1))


def seg_boost():
    # plataforma de entrada com boost pad -> alvo alto
    link(7.5, 4.2, color=pal(1))
    dy_target = 14.0 + rng.uniform(0, 4.0)
    power = math.sqrt(2 * 196.2 * (dy_target + 7))
    place_boost_pad(cur.top, cur.cx, cur.cz, cur.sx, cur.sz, round(power, 1))
    link(6.5, 6.0, dy=dy_target, color=pal(2), special="boost")
    link(7.0, 4.5, color=pal(0))


SEGMENTS = {
    "chain": seg_chain,
    "stairs": seg_stairs,
    "precise": seg_precise,
    "speedrun": seg_speedrun,
    "ferry": seg_ferry,
    "elevator": seg_elevator,
    "sidemover": seg_sidemover,
    "falling": seg_falling,
    "spinner": seg_spinner,
    "vanish": seg_vanish,
    "beam": seg_beam,
    "boost": seg_boost,
}

# ---------------------------------------------------------------------------
# Programação dos 7 mundos (6 níveis cada = 42 níveis)
# ---------------------------------------------------------------------------
WORLD_SCHEDULE = [
    {
        "name": "Praia Inicial",
        "palette": [SKY, MINT, LEMON],
        "segs": [
            ("chain", dict(n=5, gap=(4.0, 5.0), size=(8, 7.5), spread=2.0, dy=(0, 1))),
            ("chain", dict(n=5, gap=(4.2, 5.2), size=(8, 7), spread=3.0, dy=(0, 1.5), coins=[2])),
            ("stairs", dict(n=5, rise=1.5, spread=3.0)),
            ("speedrun", dict(gap=8.5)),
            ("ferry", dict()),
            ("chain", dict(n=6, gap=(4.5, 5.4), size=(7.5, 6.5), spread=3.0, dy=(0, 2), coins=[3])),
        ],
    },
    {
        "name": "Jardins Verdes",
        "palette": [MINT, (0.62, 0.9, 0.66), LEMON],
        "segs": [
            ("chain", dict(n=6, gap=(4.5, 5.5), size=(7.5, 6.5), spread=3.5, dy=(0, 2), coins=[4])),
            ("stairs", dict(n=6, rise=1.7, spread=3.4)),
            ("vanish", dict(n=3)),
            ("chain", dict(n=5, gap=(5, 5.8), size=(7, 6), spread=4.0, dy=(0, 2))),
            ("spinner", dict(bars=1, speed=0.9)),
            ("ferry", dict()),
        ],
    },
    {
        "name": "Deserto Dourado",
        "palette": [LEMON, PEACH, SAND],
        "segs": [
            ("precise", dict(n=4, gap=(5.2, 6.0), size=(4.8, 4.0), spread=4.5, coins=[2])),
            ("speedrun", dict(gap=9.5)),
            ("chain", dict(n=6, gap=(5, 5.8), size=(7, 6.5), spread=4.0, dy=(0, 2), yaw_range=6)),
            ("elevator", dict()),
            ("chain", dict(n=6, gap=(5.2, 6), size=(6.5, 5.5), spread=4.5, dy=(0, 2), coins=[4])),
            ("vanish", dict(n=3)),
        ],
    },
    {
        "name": "Caverna de Jade",
        "palette": [JADE, TEAL, ICE],
        "segs": [
            ("ferry", dict()),
            ("chain", dict(n=6, gap=(5.2, 6), size=(6.5, 5.5), spread=4.5, dy=(0, 2), yaw_range=6)),
            ("falling", dict(n=3, coins=[1])),
            ("stairs", dict(n=6, rise=1.8, spread=3.8, coins=[4])),
            ("precise", dict(n=5, gap=(5.5, 6.3), size=(4.4, 3.8), spread=5.0)),
            ("boost", dict()),
        ],
    },
    {
        "name": "Fábrica de Ferro",
        "palette": [STEEL, ORANGE, (0.7, 0.72, 0.78)],
        "segs": [
            ("speedrun", dict(gap=10.0)),
            ("beam", dict(with_spinner=True)),
            ("vanish", dict(n=4, coins=[2])),
            ("elevator", dict()),
            ("chain", dict(n=6, gap=(5.4, 6.2), size=(6.5, 5.5), spread=5.0, dy=(0, 2.5), yaw_range=8)),
            ("sidemover", dict()),
        ],
    },
    {
        "name": "Névoa Rubra",
        "palette": [CORAL, PINK, LAV],
        "segs": [
            ("precise", dict(n=5, gap=(5.6, 6.5), size=(4.4, 3.8), spread=5.5, coins=[3])),
            ("falling", dict(n=3, coins=[1])),
            ("ferry", dict()),
            ("chain", dict(n=6, gap=(5.5, 6.4), size=(6.5, 5.5), spread=5.0, dy=(0, 2.5), coins=[5])),
            ("spinner", dict(bars=2, speed=1.0, gap=4.0)),
            ("vanish", dict(n=4)),
        ],
    },
    {
        "name": "Céu Real",
        "palette": [GOLD, ROYAL, ICE],
        "segs": [
            ("boost", dict()),
            ("precise", dict(n=6, gap=(5.8, 6.6), size=(4.2, 3.5), spread=6.0, coins=[3])),
            ("sidemover", dict(coin=True)),
            ("vanish", dict(n=4, coins=[2])),
            ("falling", dict(n=4, coins=[2])),
            ("chain", dict(n=7, gap=(5.5, 6.5), size=(6.5, 5.5), spread=5.5, dy=(0, 2.5), yaw_range=8)),
        ],
    },
]


def build_course():
    """Gera os mundos, um checkpoint ao final de cada fase."""
    first_level = 1
    for wi, world in enumerate(WORLD_SCHEDULE):
        PAL[:] = world["palette"]
        # âncora da placa do mundo (no ponto onde o mundo começa)
        anchor = (round(cur.cx + 6, 1), round(cur.top + 10, 1),
                  round(clamp_z(cur.cz), 1))
        end_level = first_level + LEVELS_PER_WORLD - 1
        world_signs.append({
            "x": anchor[0], "y": anchor[1], "z": anchor[2],
            "title": f"MUNDO {wi + 1} — {world['name']}",
            "subtitle": f"Níveis {first_level}–{end_level}",
        })
        worlds_hud.append({"first": first_level, "name": world["name"]})

        for seg_name, kwargs in world["segs"]:
            SEGMENTS[seg_name](**kwargs)
            checkpoint(4.2)
            assert counters["cp"] <= TOTAL_LEVELS, "passou dos níveis!"

        first_level = end_level + 1

    assert counters["cp"] == TOTAL_LEVELS, \
        f"esperava {TOTAL_LEVELS} níveis, gerou {counters['cp']}"


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

build_course()

# ---------------------------------------------------------------------------
# Chegada e lava
# ---------------------------------------------------------------------------
link(7, 5, dy=0, color=GOLD, mat=NEON)
finish_cx, finish_top, finish_cz = link(
    14, 4, size_z=14, color=GOLD, mat=NEON, name="Finish", folder=F_FINISH)

lava_x0, lava_x1 = 1.0, finish_cx + 7
add("Lava_Floor", F_HAZ,
    ((lava_x0 + lava_x1) / 2, -14, 0),
    ((lava_x1 - lava_x0) + 80, 2, 170),
    LAVA_RED, NEON, transparency=0.12)

course_end = finish_cx
n_coins = counters["coin"]

# ---------------------------------------------------------------------------
# Auditoria de alcançabilidade (pulos do percurso)
# ---------------------------------------------------------------------------
CHAIN_FOLDERS = {tuple(F_PLAT), tuple(F_CP), tuple(F_MOVER), tuple(F_FALL),
                 tuple(F_VANISH), tuple(F_FINISH)}


def audit_chain():
    chain = [p for p in parts if tuple(p["folder"]) in CHAIN_FOLDERS]
    problems = []
    effs = []
    for a, b in zip(chain, chain[1:]):
        top_a = a["center"][1] + a["size"][1] / 2
        top_b = b["center"][1] + b["size"][1] / 2
        edge_gap = ((b["center"][0] - b["size"][0] / 2)
                    - (a["center"][0] + a["size"][0] / 2))
        dz = b["center"][2] - a["center"][2]
        dy = top_b - top_a
        eff = math.hypot(max(edge_gap, 0), dz)
        effs.append(eff)
        special = b.get("special")
        max_gap = 14.0 if special == "speed" else 7.8
        if edge_gap < -0.6:
            problems.append(f"sobreposição {a['name']}->{b['name']}")
        if eff > max_gap:
            problems.append(
                f"gap {eff:.1f} {a['name']}->{b['name']} (special={special})")
        if dy > 4.2 and special != "boost":
            problems.append(
                f"subida {dy:.1f} {a['name']}->{b['name']}")
        if dy < -14:
            problems.append(f"queda {dy:.1f} {a['name']}->{b['name']}")
    tops = [p["center"][1] + p["size"][1] / 2 for p in chain]
    stats = {
        "chain": len(chain),
        "avg_eff": sum(effs) / len(effs),
        "max_eff": max(effs),
        "min_top": min(tops),
        "max_top": max(tops),
    }
    return problems, stats


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
# Config Lua dos obstáculos e mundos
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


def lua_vanish_config():
    return "\n".join(
        '\t{ name = "%s", cycle = %s, phase = %s },'
        % (c["name"], lua_num(c["cycle"]), lua_num(c["phase"]))
        for c in vanish_cfg
    )


def lua_boosts_config():
    return "\n".join(
        '\t{ name = "%s", power = %s },' % (c["name"], lua_num(c["power"]))
        for c in boosts_cfg
    )


def lua_speedpads_config():
    return "\n".join(
        '\t{ name = "%s", speed = %s, duration = %s },'
        % (c["name"], lua_num(c["speed"]), lua_num(c["duration"]))
        for c in speedpads_cfg
    )


def lua_worlds_signs():
    return "\n".join(
        '\t{ x = %s, y = %s, z = %s, title = "%s", subtitle = "%s" },'
        % (lua_num(w["x"]), lua_num(w["y"]), lua_num(w["z"]),
           w["title"], w["subtitle"])
        for w in world_signs
    )


def lua_worlds_hud():
    return "\n".join(
        '\t{ first = %d, name = "%s" },' % (w["first"], w["name"])
        for w in worlds_hud
    )


# ---------------------------------------------------------------------------
# Montagem final + validação
# ---------------------------------------------------------------------------
def main():
    gamecore = (SRC / "gamecore.lua").read_text(encoding="utf-8")
    mapsetup = (SRC / "mapsetup.lua").read_text(encoding="utf-8")
    asmr = (SRC / "asmr.lua").read_text(encoding="utf-8")
    hud = (SRC / "hud.lua").read_text(encoding="utf-8")

    for ph in ("__MOVERS_CONFIG__", "__SPINNERS_CONFIG__", "__FALLING_CONFIG__",
               "__VANISH_CONFIG__", "__BOOSTS_CONFIG__", "__SPEEDPADS_CONFIG__"):
        assert ph in gamecore, f"placeholder ausente no GameCore: {ph}"
    gamecore = (gamecore
                .replace("__MOVERS_CONFIG__", lua_movers_config())
                .replace("__SPINNERS_CONFIG__", lua_spinners_config())
                .replace("__FALLING_CONFIG__", lua_falling_config())
                .replace("__VANISH_CONFIG__", lua_vanish_config())
                .replace("__BOOSTS_CONFIG__", lua_boosts_config())
                .replace("__SPEEDPADS_CONFIG__", lua_speedpads_config()))
    assert "__CONFIG__" not in gamecore

    assert "__WORLDS_CONFIG__" in mapsetup and "__WORLDS_CONFIG__" in hud
    mapsetup = mapsetup.replace("__WORLDS_CONFIG__", lua_worlds_signs())
    hud = hud.replace("__WORLDS_CONFIG__", lua_worlds_hud())
    assert "__WORLDS_CONFIG__" not in mapsetup
    assert "__WORLDS_CONFIG__" not in hud

    # --- auditoria de alcance ------------------------------------------
    problems, audit = audit_chain()
    assert not problems, "problemas de alcance:\n" + "\n".join(problems)

    # --- montagem -------------------------------------------------------
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

    # --- validação do XML ----------------------------------------------
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

    part_names = set()
    for it in root.iter("Item"):
        if it.get("class") in ("Part", "SpawnLocation"):
            for prop in it.find("Properties"):
                if prop.get("name") == "Name":
                    part_names.add(prop.text)
    for i in range(1, TOTAL_LEVELS + 1):
        assert f"Checkpoint_{i}" in part_names, f"falta Checkpoint_{i}"
    assert "Finish" in part_names and "Lava_Floor" in part_names
    assert "SpawnLocation" in part_names
    for name in falling_names:
        assert name in part_names
    for cfg in (movers_cfg + spinners_cfg + vanish_cfg + boosts_cfg
                + speedpads_cfg):
        assert cfg["name"] in part_names, cfg["name"]

    OUT.write_text(xml_text, encoding="utf-8")

    print(f"Arquivo gerado: {OUT}")
    print(f"  tamanho............ {OUT.stat().st_size / 1024:.1f} KB")
    print(f"  níveis............. {counters['cp']} (7 mundos)")
    print(f"  plataformas........ {counters['plat']}")
    print(f"  moedas............. {n_coins}")
    print(f"  móveis............. {len(movers_cfg)}")
    print(f"  giratórias......... {len(spinners_cfg)}")
    print(f"  que-caem........... {len(falling_names)}")
    print(f"  desaparecem........ {len(vanish_cfg)}")
    print(f"  boost/speed pads... {len(boosts_cfg)}/{len(speedpads_cfg)}")
    print(f"  placas de mundo.... {len(world_signs)}")
    print(f"  fim do percurso.... x = {course_end:.0f} studs")
    print(f"  altura do curso.... {audit['min_top']:.0f} .. {audit['max_top']:.0f}")
    print(f"  pulo efetivo....... médio {audit['avg_eff']:.1f}, "
          f"máx {audit['max_eff']:.1f}")
    print(f"  itens XML.......... {len(referents)}")
    print("  auditoria.......... 0 problemas de alcance")


if __name__ == "__main__":
    main()
