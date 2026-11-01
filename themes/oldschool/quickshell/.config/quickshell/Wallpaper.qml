import QtQuick
import Quickshell
import Quickshell.Wayland

// dark is the bare tube; light is tractor-feed printer paper, banded with
// sprocket holes down both edges
PanelWindow {
    id: wall

    required property var modelData
    readonly property bool paper: Theme.mode === "light"

    screen: modelData
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.bg
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"

    Tty { id: tty }

    Column {
        visible: wall.paper
        y: Theme.bar
        Repeater {
            model: Math.ceil(wall.height / 54)
            Rectangle {
                required property int index
                width: wall.width
                height: 54
                color: index % 2 ? Theme.bg : Theme.surface
            }
        }
    }

    Repeater {
        model: wall.paper ? [12, wall.width - 24] : []
        Column {
            required property real modelData
            x: modelData
            y: Theme.bar + 12
            spacing: 24
            Repeater {
                model: Math.ceil(wall.height / 36)
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: Theme.panel
                    border.color: Theme.line
                    border.width: 2
                }
            }
        }
    }

    Label {
        x: wall.paper ? 48 : 16
        y: Theme.bar + 14
        color: Theme.dim
        lineHeight: 1.3
        textFormat: Text.StyledText
        text: `${tty.host} · arch linux ${tty.kernel}<br>ready.<br>`
            + `<font color="${Theme.fg}">${tty.blink ? "█" : "&nbsp;"}</font>`
    }
}
