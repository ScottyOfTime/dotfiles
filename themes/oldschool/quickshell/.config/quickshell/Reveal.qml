import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// the desktop warms up like a tube: it shows at once at a third, then two
// thirds, then full brightness. On login (once per hyprland session: the
// runtime dir outlives a logout, so the flag holds the instance signature)
// and after unlocking
Scope {
    id: reveal

    property bool shown: false
    property real warm: 0

    // a blank tube first, then the warm-up after delay ms
    function play(delay) {
        warmUp.stop();
        warm = 0;
        shown = true;
        wait.interval = delay;
        wait.restart();
    }

    Timer { id: wait; onTriggered: warmUp.start() }

    SequentialAnimation {
        id: warmUp
        NumberAnimation { target: reveal; property: "warm"; from: 0; to: 1; duration: 330 }
        ScriptAction { script: reveal.shown = false }
    }

    Process {
        running: true
        command: ["sh", "-c", 'f="$XDG_RUNTIME_DIR/oldschool-revealed"; [ "$(cat "$f" 2>/dev/null)" = "$HYPRLAND_INSTANCE_SIGNATURE" ] || { echo "$HYPRLAND_INSTANCE_SIGNATURE" > "$f"; echo first; }']
        stdout: StdioCollector { onStreamFinished: if (text.trim() === "first") reveal.play(400) }
    }

    IpcHandler {
        target: "reveal"
        function replay(): void { reveal.play(300); }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: reveal.shown
            color: "transparent"
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "reveal"
            mask: Region {}

            Rectangle {
                anchors.fill: parent
                color: Theme.bg
                opacity: Math.max(0, 1 - Math.ceil(reveal.warm * 3) / 3)
            }
        }
    }
}
