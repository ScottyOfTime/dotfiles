import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property var modelData

    screen: modelData
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"

    Collage { anchors.fill: parent }
}
