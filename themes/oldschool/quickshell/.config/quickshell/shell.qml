import Quickshell
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
    Launcher {}
    Osd {}
    Notifications {}
    Lock { id: lock; onLeaving: boot.reveal() }
    PowerMenu { lock: lock }
    Overview {}
    Boot { id: boot }
}
