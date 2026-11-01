import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    id: root
    property bool barVisible: true

    IpcHandler {
        target: "bar"
        function toggle(): void { root.barVisible = !root.barVisible; }
    }

    Variants {
        model: Quickshell.screens
        Wallpaper {}
    }
    Variants {
        model: Quickshell.screens
        Bar { visible: root.barVisible }
    }
    Variants {
        model: Quickshell.screens
        Focus {}
    }
    // a toplevel's lastIpcObject (Focus, Overview) is a snapshot; geometry
    // changes don't refresh it, so refresh once per window event here
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (["openwindow", "closewindow", "movewindow", "movewindowv2", "activewindowv2",
                 "changefloatingmode", "fullscreen", "workspacev2", "resizewindow"].includes(event.name))
                Hyprland.refreshToplevels();
        }
    }
    Launcher {}
    Osd {}
    Notifications {}
    Lock { id: lock; onLeaving: boot.reveal() }
    PowerMenu { lock: lock }
    Overview {}
    Boot { id: boot }
}
