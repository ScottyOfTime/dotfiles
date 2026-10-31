import QtQuick
import Quickshell
import Quickshell.Hyprland

// album art pasted on like a photo, with the track and controls beside it
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
    implicitWidth: 560
    implicitHeight: 300
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 10

    HyprlandFocusGrab {
        windows: [popup]
        active: popup.shown
        onCleared: popup.toggle()
    }

    Timer { id: hide; interval: 140; onTriggered: popup.visible = false }

    // mpris doesn't push position updates, so ask for them while open
    Timer {
        running: popup.shown && popup.player?.isPlaying
        interval: 1000
        repeat: true
        onTriggered: popup.player.positionChanged()
    }

    Scrap {
        id: card
        x: (popup.width - width) / 2
        y: popup.shown ? 14 : -30
        opacity: popup.shown ? 1 : 0
        Behavior on y { NumberAnimation { duration: popup.shown ? 220 : 120; easing.type: popup.shown ? Easing.OutBack : Easing.InCubic } }
        Behavior on opacity { NumberAnimation { duration: 120 } }

        seed: 61
        tilt: 1.5
        fill: Theme.panel
        ragged: 5
        shadow: 5
        padX: 20
        padY: 18

        Row {
            spacing: 22

            // the photo: paper border, art, a strip of tape across the top
            Item {
                width: 172
                height: 172
                rotation: -4

                Rectangle { x: 5; y: 5; width: parent.width; height: parent.height; color: Theme.ink; antialiasing: true }
                Rectangle {
                    anchors.fill: parent
                    color: Theme.paper
                    antialiasing: true

                    Image {
                        anchors { fill: parent; margins: 8 }
                        source: popup.player?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                        mipmap: true
                    }
                }
                Rectangle {
                    width: 70; height: 18
                    x: 50; y: -8
                    rotation: 6
                    antialiasing: true
                    color: Qt.alpha(Theme.accent, 0.75)
                }
            }

            Column {
                width: 290
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    text: popup.player?.trackTitle || "nothing playing"
                    color: Theme.fg
                    font.pixelSize: 17
                    width: parent.width
                    elide: Text.ElideRight
                }
                Label {
                    text: popup.player?.trackArtist ?? ""
                    color: Theme.fg
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

                Item { width: 1; height: 4 }

                Item {
                    visible: popup.player?.lengthSupported ?? false
                    width: parent.width
                    height: 10
                    rotation: -1

                    Rectangle { anchors.fill: parent; color: Theme.ink; antialiasing: true }
                    Rectangle {
                        x: 2; y: 2
                        height: parent.height - 4
                        width: (parent.width - 4) * Math.min(1, (popup.player?.position ?? 0) / Math.max(1, popup.player?.length ?? 1))
                        color: Theme.accent
                        antialiasing: true
                        Behavior on width { NumberAnimation { duration: 200 } }
                    }
                }
                Label {
                    visible: popup.player?.lengthSupported ?? false
                    text: `${popup.time(popup.player?.position ?? 0)} / ${popup.time(popup.player?.length ?? 0)}`
                    color: Theme.dim
                    font.pixelSize: 11
                }

                Row {
                    spacing: 12
                    topPadding: 4

                    Scrap {
                        seed: 62; tilt: -3; padX: 10; padY: 3
                        opacity: popup.player?.canGoPrevious ? 1 : 0.4
                        onClicked: popup.player.previous()
                        Label { text: "prev" }
                    }
                    Scrap {
                        seed: 63; tilt: 2; padX: 12; padY: 3
                        fill: Theme.accent
                        onClicked: popup.player.togglePlaying()
                        Label { text: popup.player?.isPlaying ? "pause" : "play" }
                    }
                    Scrap {
                        seed: 64; tilt: -2; padX: 10; padY: 3
                        opacity: popup.player?.canGoNext ? 1 : 0.4
                        onClicked: popup.player.next()
                        Label { text: "next" }
                    }
                }
            }
        }
    }
}
