"""Build BhopStarter.rbxlx from the Luau source files using only Python stdlib."""
from pathlib import Path
from uuid import uuid4
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parent


def ref():
    return "RBX" + uuid4().hex.upper()


def item(class_name, name, properties="", children=""):
    props = f'<string name="Name">{escape(name)}</string>{properties}'
    return (
        f'<Item class="{class_name}" referent="{ref()}">'
        f"<Properties>{props}</Properties>{children}</Item>"
    )


def script(class_name, name, source):
    # CDATA is the XML representation of Roblox's ProtectedString source.
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
        props = properties + f'<string name="Name">{escape(name)}</string>'
        return (
            f'<Item class="{class_name}" referent="{ref()}">'
            f"<Properties>{props}</Properties>{children}</Item>"
        )
    return item(class_name, name, children=children)


server_script = script(
    "Script",
    "BhopGame",
    (ROOT / "ServerScriptService/BhopGame.server.lua").read_text(encoding="utf-8"),
)
client_scripts = []
for name, filename in (
    ("BhopController", "BhopController.client.lua"),
    ("BhopHUD", "BhopHUD.client.lua"),
    ("MovementFX", "MovementFX.client.lua"),
    ("BhopAnimations", "BhopAnimations.client.lua"),
):
    client_scripts.append(
        script(
            "LocalScript",
            name,
            (ROOT / "StarterPlayerScripts" / filename).read_text(encoding="utf-8"),
        )
    )

starter_scripts = service(
    "StarterPlayerScripts", "StarterPlayerScripts", "".join(client_scripts)
)
first_person_properties = (
    '<float name="CameraMaxZoomDistance">0.5</float>'
    '<float name="CameraMinZoomDistance">0.5</float>'
    '<token name="CameraMode">1</token>'
)

services = [
    service("Workspace", "Workspace"),
    service("Players", "Players"),
    service("Lighting", "Lighting"),
    service("ReplicatedFirst", "ReplicatedFirst"),
    service("ReplicatedStorage", "ReplicatedStorage"),
    service("ServerScriptService", "ServerScriptService", server_script),
    service("ServerStorage", "ServerStorage"),
    service("StarterGui", "StarterGui"),
    service("StarterPack", "StarterPack"),
    service(
        "StarterPlayer",
        "StarterPlayer",
        starter_scripts + service("StarterCharacterScripts", "StarterCharacterScripts"),
        first_person_properties,
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
(ROOT / "BhopStarter.rbxlx").write_text(xml, encoding="utf-8")
print(f"Created {ROOT / 'BhopStarter.rbxlx'}")
