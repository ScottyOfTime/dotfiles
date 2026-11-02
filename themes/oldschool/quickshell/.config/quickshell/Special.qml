import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// scratchpads warm up like the desktop on login. The screen is blanked
// before the toggle is dispatched, so the window never shows at full
// brightness first; hiding one stays instant
Scope {
    id: special

    required property var reveal
    // monitor name -> the special workspace shown on it
    property var shown: ({})
    property string pending

    function dispatch(name) {
        Hyprland.dispatch(`hl.dsp.workspace.toggle_special("${name}")`);
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name !== "activespecialv2")
                return;
            const parts = event.data.split(",");
            special.shown[parts[2]] = parts[1];
        }
    }

    Timer {
        id: blanked
        interval: 40
        onTriggered: special.dispatch(special.pending)
    }

    IpcHandler {
        target: "special"
        function toggle(name: string): void {
            const monitor = Hyprland.focusedMonitor?.name ?? "";
            if (special.shown[monitor] === "special:" + name) {
                special.dispatch(name);
                return;
            }
            special.pending = name;
            special.reveal.play(80, monitor, 260);
            blanked.restart();
        }
    }
}
