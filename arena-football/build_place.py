"""Generate ArenaFootball.rbxlx from the current Luau source (Python stdlib only)."""
from pathlib import Path
from uuid import uuid4
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parent


def ref():
    return "RBX" + uuid4().hex.upper()


def instance(class_name, name, properties="", children=""):
    props = f'<string name="Name">{escape(name)}</string>{properties}'
    return (
        f'<Item class="{class_name}" referent="{ref()}">'
        f"<Properties>{props}</Properties>{children}</Item>"
    )


def script(class_name, name, source):
    source = source.replace("]]>", "]]]]><![CDATA[>")
    return (
        f'<Item class="{class_name}" referent="{ref()}"><Properties>'
        f'<bool name="Disabled">false</bool>'
        f'<string name="Name">{escape(name)}</string>'
        f"<ProtectedString name=\"Source\"><![CDATA[{source}]]></ProtectedString>"
        "</Properties></Item>"
    )


def service(class_name, name, children="", properties=""):
    if properties:
        return (
            f'<Item class="{class_name}" referent="{ref()}">'
            f"<Properties>{properties}<string name=\"Name\">{escape(name)}</string></Properties>"
            f"{children}</Item>"
        )
    return instance(class_name, name, children=children)


server_script = script(
    "Script",
    "Match",
    (ROOT / "ServerScriptService/Match.server.lua").read_text(encoding="utf-8"),
)
client_scripts = []
for name, filename in (
    ("FootballClient", "FootballClient.client.lua"),
    ("FootballHUD", "FootballHUD.client.lua"),
    ("FootballAnimations", "FootballAnimations.client.lua"),
):
    client_scripts.append(
        script(
            "LocalScript",
            name,
            (ROOT / "StarterPlayerScripts" / filename).read_text(encoding="utf-8"),
        )
    )

starter_player_scripts = service(
    "StarterPlayerScripts", "StarterPlayerScripts", "".join(client_scripts)
)

starter_props = (
    '<float name="CameraMaxZoomDistance">18</float>'
    '<float name="CameraMinZoomDistance">9</float>'
    '<token name="CameraMode">0</token>'
)
services = [
    service("Workspace", "Workspace"),
    service("Players", "Players"),
    service("Lighting", "Lighting"),
    service("ReplicatedStorage", "ReplicatedStorage"),
    service("ServerScriptService", "ServerScriptService", server_script),
    service("ServerStorage", "ServerStorage"),
    service("StarterGui", "StarterGui"),
    service(
        "StarterPlayer",
        "StarterPlayer",
        starter_player_scripts,
        starter_props,
    ),
    service("Teams", "Teams"),
    service("SoundService", "SoundService"),
    service("TextChatService", "TextChatService"),
]

xml = (
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
    'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
    'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n'
    "<External>null</External><External>nil</External>\n"
    + "\n".join(services)
    + "\n</roblox>\n"
)
output = ROOT / "ArenaFootball.rbxlx"
output.write_text(xml, encoding="utf-8")
print(f"Created {output}")
