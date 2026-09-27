#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build_rbxlx.py

Gera um arquivo .rbxlx (formato XML de "place" do Roblox, aberto diretamente
pelo Roblox Studio via File > Open — não precisa de Rojo nem de nenhum plugin)
a partir dos arquivos-fonte em src/, seguindo a mesma estrutura de
default.project.json:

  - arquivo "Foo.lua"          -> ModuleScript "Foo"
  - arquivo "Foo.server.lua"   -> Script "Foo"
  - arquivo "Foo.client.lua"   -> LocalScript "Foo"
  - pastas normais             -> Folder

O mapa do jogo inteiro é construído em tempo de execução pelo próprio script
do servidor (MapBuilder.lua), então este .rbxlx não precisa "assar" nenhuma
parte do cenário — só precisa conter os scripts certos nos serviços certos.
Basta abrir o arquivo no Studio e apertar Play.

Uso:
    python3 tools/build_rbxlx.py
Gera: dist/GatoParkourEnigmasFelinos.rbxlx
"""

import os
import xml.sax.saxutils as sx

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "src")
OUT_DIR = os.path.join(ROOT, "dist")
OUT_FILE = os.path.join(OUT_DIR, "GatoParkourEnigmasFelinos.rbxlx")

_referent_counter = [0]


def next_referent():
    _referent_counter[0] += 1
    return f"RBX{_referent_counter[0]}"


def esc(text):
    return sx.escape(text, {'"': "&quot;"})


def script_class_and_name(filename):
    """Decide a classe da Instance a partir do sufixo do arquivo."""
    if filename.endswith(".server.lua"):
        return "Script", filename[: -len(".server.lua")]
    if filename.endswith(".client.lua"):
        return "LocalScript", filename[: -len(".client.lua")]
    if filename.endswith(".lua"):
        return "ModuleScript", filename[: -len(".lua")]
    return None, None


def render_source_item(class_name, name, source_text):
    referent = next_referent()
    return (
        f'<Item class="{class_name}" referent="{referent}">\n'
        f'  <Properties>\n'
        f'    <string name="Name">{esc(name)}</string>\n'
        f'    <ProtectedString name="Source"><![CDATA[{source_text}]]></ProtectedString>\n'
        f'  </Properties>\n'
        f'</Item>\n'
    )


def render_folder_open(name):
    referent = next_referent()
    return referent, (
        f'<Item class="Folder" referent="{referent}">\n'
        f'  <Properties>\n'
        f'    <string name="Name">{esc(name)}</string>\n'
        f'  </Properties>\n'
    )


def render_remote_event(name):
    referent = next_referent()
    return (
        f'<Item class="RemoteEvent" referent="{referent}">\n'
        f'  <Properties>\n'
        f'    <string name="Name">{esc(name)}</string>\n'
        f'  </Properties>\n'
        f'</Item>\n'
    )


REMOTE_NAMES = [
    "SequenceState",
    "KeypadSubmit",
    "KeypadFeedback",
    "CheckpointReached",
    "WaterSplash",
    "RaceFinished",
    "CollectibleGrabbed",
    "RequestReset",
    "RequestFullReset",
]


def build_dir_children(path):
    """Gera os <Item> filhos (scripts e subpastas) de um diretório do src/."""
    out = []
    entries = sorted(os.listdir(path))
    for entry in entries:
        full = os.path.join(path, entry)
        if os.path.isdir(full):
            _, open_tag = render_folder_open(entry)
            out.append(open_tag)
            out.append(build_dir_children(full))
            out.append("</Item>\n")
        elif entry.endswith(".lua"):
            class_name, name = script_class_and_name(entry)
            with open(full, "r", encoding="utf-8") as f:
                source_text = f.read()
            out.append(render_source_item(class_name, name, source_text))
    return "".join(out)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    parts = []
    parts.append('<?xml version="1.0" encoding="utf-8"?>\n')
    parts.append(
        '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n'
    )
    parts.append("<External>null</External>\n<External>nil</External>\n")

    # ===== Workspace =====
    ws_ref = next_referent()
    parts.append(f'<Item class="Workspace" referent="{ws_ref}">\n')
    parts.append("<Properties>\n")
    parts.append('<string name="Name">Workspace</string>\n')
    parts.append('<float name="Gravity">130</float>\n')
    parts.append("</Properties>\n")
    parts.append("</Item>\n")

    # ===== ReplicatedStorage =====
    rs_ref = next_referent()
    parts.append(f'<Item class="ReplicatedStorage" referent="{rs_ref}">\n')
    parts.append('<Properties><string name="Name">ReplicatedStorage</string></Properties>\n')

    shared_ref, shared_open = render_folder_open("Shared")
    parts.append(shared_open)
    parts.append(build_dir_children(os.path.join(SRC, "ReplicatedStorage", "Shared")))
    parts.append("</Item>\n")

    remotes_ref, remotes_open = render_folder_open("Remotes")
    parts.append(remotes_open)
    for remote_name in REMOTE_NAMES:
        parts.append(render_remote_event(remote_name))
    parts.append("</Item>\n")

    parts.append("</Item>\n")  # fim ReplicatedStorage

    # ===== ServerScriptService =====
    sss_ref = next_referent()
    parts.append(f'<Item class="ServerScriptService" referent="{sss_ref}">\n')
    parts.append('<Properties><string name="Name">ServerScriptService</string></Properties>\n')

    server_ref, server_open = render_folder_open("Server")
    parts.append(server_open)
    parts.append(build_dir_children(os.path.join(SRC, "ServerScriptService", "Server")))
    parts.append("</Item>\n")

    parts.append("</Item>\n")  # fim ServerScriptService

    # ===== StarterPlayer =====
    sp_ref = next_referent()
    parts.append(f'<Item class="StarterPlayer" referent="{sp_ref}">\n')
    parts.append('<Properties><string name="Name">StarterPlayer</string></Properties>\n')

    # StarterPlayerScripts: os scripts vão DIRETO dentro do serviço (sem subpasta "Folder"),
    # exatamente como o default.project.json mapeia ($path aponta direto pro serviço).
    sps_ref = next_referent()
    parts.append(f'<Item class="StarterPlayerScripts" referent="{sps_ref}">\n')
    parts.append('<Properties><string name="Name">StarterPlayerScripts</string></Properties>\n')
    parts.append(build_dir_children(os.path.join(SRC, "StarterPlayer", "StarterPlayerScripts")))
    parts.append("</Item>\n")

    scs_ref = next_referent()
    parts.append(f'<Item class="StarterCharacterScripts" referent="{scs_ref}">\n')
    parts.append('<Properties><string name="Name">StarterCharacterScripts</string></Properties>\n')
    parts.append(build_dir_children(os.path.join(SRC, "StarterPlayer", "StarterCharacterScripts")))
    parts.append("</Item>\n")

    parts.append("</Item>\n")  # fim StarterPlayer

    # ===== StarterGui =====
    sg_ref = next_referent()
    parts.append(f'<Item class="StarterGui" referent="{sg_ref}">\n')
    parts.append('<Properties><string name="Name">StarterGui</string></Properties>\n')
    parts.append("</Item>\n")

    parts.append("</roblox>\n")

    with open(OUT_FILE, "w", encoding="utf-8") as f:
        f.write("".join(parts))

    print(f"Gerado: {OUT_FILE}")


if __name__ == "__main__":
    main()
