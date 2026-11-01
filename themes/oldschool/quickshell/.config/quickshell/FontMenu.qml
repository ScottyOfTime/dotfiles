import QtQuick
import Quickshell
import Quickshell.Io

Strip {
    id: menu

    readonly property var fonts: ["terminus", "jetbrains"]

    prompt: "font"
    space: "fontmenu"
    searchable: false
    items: ["terminus", "jetbrains mono"]
    onChosen: i => {
        close();
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr-theme/font", fonts[i]]);
    }

    IpcHandler {
        target: "font"
        function toggle(): void {
            if (menu.shown) {
                menu.close();
                return;
            }
            menu.open();
            menu.current = Math.max(0, menu.fonts.indexOf(Theme.fontName));
        }
    }
}
