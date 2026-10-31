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
        Bar { visible: root.barVisible }
    }
    Launcher {}
    Osd {}
    Notifications {}
    Lock {}
}
