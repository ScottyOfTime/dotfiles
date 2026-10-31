import QtQuick
import Quickshell
import Quickshell.Hyprland

// enrichment audio: album art in a frame, the track and controls beside it
PopupWindow {
    id: popup

    required property var player
    required property Item anchorItem
    property bool shown: false

    function toggle() {
        if (shown) {
            shown = false;
            hide.restart();
        } else {
            hide.stop();
            visible = true;
            shown = true;
        }
    }

    function time(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
    }

    visible: false
    color: "transparent"
    implicitWidth: 540
    implicitHeight: 260
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 8

    HyprlandFocusGrab {
        windows: [popup]
        active: popup.shown
        onCleared: popup.toggle()
    }

    Timer { id: hide; interval: 160; onTriggered: popup.visible = false }

    // mpris doesn't push position updates, so ask for them while open
    Timer {
        running: popup.shown && popup.player?.isPlaying
        interval: 1000
        repeat: true
        onTriggered: popup.player.positionChanged()
    }

    Panel {
        x: (popup.width - width) / 2
        y: 6
        out: popup.shown
        padX: 18
        padY: 18
        edge: Theme.orange

        Row {
            spacing: 20

            Rectangle {
                width: 168
                height: 168
                color: Theme.bg
                border.color: Theme.line
                border.width: 1
                radius: 3

                Image {
                    anchors { fill: parent; margins: 6 }
                    source: popup.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    mipmap: true
                }
            }

            Column {
                width: 300
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    spacing: 8
                    PortalMark { size: 11; anchors.verticalCenter: parent.verticalCenter }
                    Caps { text: "enrichment audio"; anchors.verticalCenter: parent.verticalCenter }
                }

                Item { width: 1; height: 2 }

                Label {
                    text: popup.player?.trackTitle || "no audio scheduled"
                    font.pixelSize: 17
                    width: parent.width
                    elide: Text.ElideRight
                }
                Label {
                    text: popup.player?.trackArtist ?? ""
                    font.bold: false
                    width: parent.width
                    elide: Text.ElideRight
                }
                Label {
                    visible: text !== ""
                    text: popup.player?.trackAlbum ?? ""
                    color: Theme.dim
                    font.bold: false
                    font.pixelSize: 12
                    width: parent.width
                    elide: Text.ElideRight
                }

                Item { width: 1; height: 6 }

                Rectangle {
                    visible: popup.player?.lengthSupported ?? false
                    width: parent.width
                    height: 6
                    radius: 3
                    color: Theme.surface

                    Rectangle {
                        height: parent.height
                        radius: 3
                        width: parent.width * Math.min(1, (popup.player?.position ?? 0) / Math.max(1, popup.player?.length ?? 1))
                        color: Theme.blue
                        Behavior on width { NumberAnimation { duration: 200 } }
                    }
                }
                Caps {
                    visible: popup.player?.lengthSupported ?? false
                    text: `${popup.time(popup.player?.position ?? 0)} / ${popup.time(popup.player?.length ?? 0)}`
                }

                Row {
                    spacing: 6
                    topPadding: 6

                    Panel {
                        padX: 12; padY: 5
                        fill: hovered ? Theme.surface : Theme.panel
                        opacity: popup.player?.canGoPrevious ? 1 : 0.4
                        onClicked: popup.player.previous()
                        Caps { text: "prev"; color: Theme.fg }
                    }
                    Panel {
                        padX: 14; padY: 5
                        fill: Theme.blue
                        glow: hovered
                        edge: Theme.blue
                        onClicked: popup.player.togglePlaying()
                        Caps { text: popup.player?.isPlaying ? "pause" : "play"; color: Theme.onLit }
                    }
                    Panel {
                        padX: 12; padY: 5
                        fill: hovered ? Theme.surface : Theme.panel
                        opacity: popup.player?.canGoNext ? 1 : 0.4
                        onClicked: popup.player.next()
                        Caps { text: "next"; color: Theme.fg }
                    }
                }
            }
        }
    }
}
