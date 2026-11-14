import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

// a mixtape: the track written on the cassette's label, the art stuck on
// it, reels that tick round while it plays, label-tape buttons underneath
PopupWindow {
    id: popup

    required property var player
    required property Item anchorItem
    property bool shown: false
    property real spin: 0

    function toggle() {
        if (shown) {
            shown = false;
            visible = false;
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
    implicitWidth: 500
    implicitHeight: 360
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 10

    HyprlandFocusGrab {
        windows: [popup]
        active: popup.shown
        onCleared: popup.toggle()
    }

    // mpris doesn't push position updates, so ask for them while open
    Timer {
        running: popup.shown && popup.player?.isPlaying
        interval: 1000
        repeat: true
        onTriggered: popup.player.positionChanged()
    }

    NumberAnimation on spin {
        running: popup.shown && (popup.player?.isPlaying ?? false)
        from: 0; to: 360
        duration: 2400
        loops: Animation.Infinite
    }

    Item {
        id: tape
        x: (popup.width - width) / 2
        y: 14
        width: 440
        height: 270

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Theme.surface
            border.color: Theme.ink
            border.width: 3
        }
        Repeater {
            model: [[14, 14], [412, 14], [14, 242], [412, 242], [213, 242]]
            Rectangle {
                required property var modelData
                x: modelData[0]; y: modelData[1]
                width: 14; height: 14; radius: 7
                color: Theme.dim
                border.color: Theme.ink
                border.width: 2
                Rectangle { anchors.centerIn: parent; width: 8; height: 2; rotation: 30; color: Theme.ink }
            }
        }

        Rectangle {
            x: 30; y: 26
            width: 380; height: 170
            radius: 4
            color: Theme.paper

            Rectangle { width: parent.width; height: 24; color: Theme.accent }
            Repeater {
                model: 3
                Rectangle {
                    required property int index
                    x: 12; y: 58 + index * 22
                    width: parent.width - 24; height: 1
                    color: Qt.alpha(Theme.ink, 0.25)
                }
            }

            Text {
                x: 14; y: 26
                width: 260
                text: popup.player?.trackTitle || "nothing playing"
                color: Theme.ink
                elide: Text.ElideRight
                font.family: Theme.marker
                font.italic: true
                font.weight: Font.Black
                font.pixelSize: 24
            }
            Text {
                x: 14; y: 56
                width: 260
                text: popup.player?.trackArtist ?? ""
                color: Theme.ink
                elide: Text.ElideRight
                font.family: Theme.marker
                font.italic: true
                font.bold: true
                font.pixelSize: 17
            }

            Rectangle {
                x: 70; y: 92
                width: 240; height: 66
                radius: 33
                color: Theme.ink

                Repeater {
                    model: [44, 196]
                    Item {
                        required property var modelData
                        x: modelData - 26; y: 7
                        width: 52; height: 52
                        rotation: Math.round(popup.spin / 30) * 30

                        Rectangle { anchors.fill: parent; radius: 26; color: Theme.paper }
                        Rectangle { anchors.centerIn: parent; width: 22; height: 22; radius: 11; color: Theme.ink }
                        Repeater {
                            model: 6
                            Rectangle {
                                required property int index
                                x: 24; y: 15
                                width: 4; height: 7
                                color: Theme.paper
                                transform: Rotation { origin.x: 2; origin.y: 11; angle: index * 60 }
                            }
                        }
                    }
                }
            }

            ClippingRectangle {
                x: 290; y: 30
                width: 76; height: 76
                color: Theme.ink
                Image {
                    anchors.fill: parent
                    source: popup.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    mipmap: true
                }
            }
        }

        Text {
            x: 30; y: 206
            visible: popup.player?.lengthSupported ?? false
            text: `side a   ${popup.time(popup.player?.position ?? 0)} / ${popup.time(popup.player?.length ?? 0)}`
            color: Theme.fg
            font.family: Theme.font
            font.bold: true
            font.pixelSize: 13
            font.capitalization: Font.AllUppercase
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: tape.y + tape.height + 22
        spacing: 12

        Dymo {
            text: "<<"; seed: 62
            opacity: popup.player?.canGoPrevious ? 1 : 0.4
            onClicked: popup.player.previous()
        }
        Dymo {
            text: popup.player?.isPlaying ? "pause" : "play"
            seed: 63
            tape: Theme.accent
            letters: Theme.ink
            onClicked: popup.player.togglePlaying()
        }
        Dymo {
            text: ">>"; seed: 64
            opacity: popup.player?.canGoNext ? 1 : 0.4
            onClicked: popup.player.next()
        }
    }
}
