import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property var modelData

    screen: modelData
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.bg
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"

    Tty { id: tty }

    Label {
        x: 16
        y: Theme.bar + 14
        color: Theme.dim
        lineHeight: 1.3
        textFormat: Text.StyledText
        text: `${tty.host} · arch linux ${tty.kernel}<br>ready.<br>`
            + `<font color="${Theme.fg}">${tty.blink ? "█" : "&nbsp;"}</font>`
    }
}
