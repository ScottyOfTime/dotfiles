import QtQuick
import Quickshell
import Quickshell.Wayland

// the bare tube with the distro's logo burned in: big, centred and barely
// brighter than the glass
PanelWindow {
    id: wall

    required property var modelData

    screen: modelData
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.bg
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"

    Label {
        anchors.centerIn: parent
        // about 60% of the screen's height, whatever the logo's line count
        // (in points, as Label sizes in points: 0.75pt per px)
        font.pointSize: Math.max(1, Math.round(wall.height * 0.6 / Math.max(1, text.split("\n").length)) * 0.75)
        lineHeight: 1.0
        textFormat: Text.PlainText
        color: Theme.line
        text: Tty.logo
    }
}
