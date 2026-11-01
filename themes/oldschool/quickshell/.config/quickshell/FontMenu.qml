import QtQuick
import Quickshell
import Quickshell.Io

Strip {
    id: menu

    readonly property string script: Quickshell.env("HOME") + "/.config/hypr-theme/font"
    property var fonts: []
    readonly property var matches: fonts.filter(f => f.toLowerCase().includes(query.toLowerCase()))

    prompt: "font"
    space: "fontmenu"
    items: matches
    onChosen: i => {
        Quickshell.execDetached([script, matches[i]]);
        close();
    }

    Process {
        id: lister
        command: [menu.script, "--list"]
        stdout: StdioCollector {
            onStreamFinished: {
                menu.fonts = text.split("\n").filter(f => f);
                menu.current = Math.max(0, menu.fonts.indexOf(Theme.fontName));
            }
        }
    }

    IpcHandler {
        target: "font"
        function toggle(): void {
            if (menu.shown) {
                menu.close();
                return;
            }
            menu.open();
            lister.running = true;
        }
    }
}
