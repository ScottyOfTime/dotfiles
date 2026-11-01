import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// a reverse-video strip along the top of the focused window, shown only
// when another window shares the workspace
PanelWindow {
    id: focus

    required property var modelData
    readonly property var monitor: Hyprland.monitorFor(modelData)
    readonly property var window: Hyprland.activeToplevel
    readonly property var info: window?.lastIpcObject ?? null
    readonly property var workspace: monitor?.activeWorkspace ?? null

    screen: modelData
    anchors { top: true; left: true }
    margins {
        left: info?.at ? info.at[0] - monitor.x : 0
        top: info?.at ? info.at[1] - monitor.y : 0
    }
    implicitWidth: info?.size ? info.size[0] : 1
    implicitHeight: 3
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "focus"
    mask: Region {}
    color: Theme.fg
    visible: info?.at !== undefined && window.workspace === workspace
        && workspace.toplevels.values.length > 1 && !info.fullscreen

    // lastIpcObject is a snapshot; geometry changes don't refresh it
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (["openwindow", "closewindow", "movewindow", "movewindowv2", "activewindowv2",
                 "changefloatingmode", "fullscreen", "workspacev2", "resizewindow"].includes(event.name))
                Hyprland.refreshToplevels();
        }
    }
}
