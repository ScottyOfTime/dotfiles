import QtQuick
import Quickshell
import Quickshell.Hyprland

// the track, a text progress bar and [prev] [play] [next]
PopupWindow {
    id: popup

    required property var player
    required property Item anchorItem

    function toggle() {
        visible = !visible;
    }

    function time(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
    }

    component Button: Label {
        id: button
        property string name
        signal pressed()
        text: `[${name}]`
        color: hover.containsMouse ? Theme.blue : Theme.fg
        MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true; onClicked: button.pressed() }
    }

    visible: false
    color: "transparent"
    implicitWidth: box.width
    implicitHeight: box.height
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 6

    HyprlandFocusGrab {
        windows: [popup]
        active: popup.visible
        onCleared: popup.visible = false
    }

    // mpris doesn't push position updates, so ask for them while open
    Timer {
        running: popup.visible && popup.player?.isPlaying
        interval: 1000
        repeat: true
        onTriggered: popup.player.positionChanged()
    }

    Box {
        id: box
        width: 360
        height: info.implicitHeight + 20
        edge: Theme.blue

        Column {
            id: info
            x: 10
            y: 10
            width: parent.width - 20
            spacing: 4

            Label {
                text: popup.player?.trackTitle || "nothing playing"
                font.bold: true
                width: parent.width
                elide: Text.ElideRight
            }
            Label {
                text: [popup.player?.trackArtist, popup.player?.trackAlbum].filter(s => s).join(" · ")
                color: Theme.dim
                width: parent.width
                elide: Text.ElideRight
            }
            Row {
                visible: popup.player?.lengthSupported ?? false
                spacing: 8
                topPadding: 4
                Meter {
                    cells: 22
                    fraction: (popup.player?.position ?? 0) / Math.max(1, popup.player?.length ?? 1)
                    color: Theme.blue
                }
                Label {
                    text: `${popup.time(popup.player?.position ?? 0)}/${popup.time(popup.player?.length ?? 0)}`
                    color: Theme.dim
                }
            }
            Row {
                spacing: 10
                topPadding: 4
                Button { name: "prev"; onPressed: popup.player?.previous() }
                Button { name: popup.player?.isPlaying ? "pause" : "play"; onPressed: popup.player?.togglePlaying() }
                Button { name: "next"; onPressed: popup.player?.next() }
            }
        }
    }
}
