import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    id: root
    property bool barVisible: true
    // one handler, not one per bar: a handler per screen registers twice
    property int musicToggles: 0
    readonly property var windowEvents: new Set(["openwindow", "closewindow", "movewindow", "movewindowv2",
        "activewindowv2", "changefloatingmode", "fullscreen", "workspacev2", "resizewindow"])

    IpcHandler {
        target: "bar"
        function toggle(): void { root.barVisible = !root.barVisible; }
    }
    Binding { target: Stats; property: "active"; value: root.barVisible }
    IpcHandler {
        target: "music"
        function toggle(): void { root.musicToggles++; }
    }

    Variants {
        model: Quickshell.screens
        Wallpaper {}
    }
    Variants {
        model: Quickshell.screens
        Bar { visible: root.barVisible; musicToggles: root.musicToggles }
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
            if (root.windowEvents.has(event.name)) Hyprland.refreshToplevels();
        }
    }
    Launcher {}
    Osd {}
    Notifications {}
    // the lock surface lingers 250ms after a successful unlock (Lock.qml)
    Lock { id: lock; onLeaving: reveal.play(320) }
    PowerMenu { lock: lock }
    FontMenu {}
    Overview {}
    Reveal { id: reveal }
    Special { reveal: reveal }
}
