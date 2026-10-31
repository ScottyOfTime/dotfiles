import QtQuick
import Quickshell
import Quickshell.Hyprland

// a glossy blue player: round buttons beside a dark lcd screen
PopupWindow {
    id: popup

    required property var player
    required property Item anchorItem
    property bool shown: false
    readonly property color deep: Qt.darker(Theme.blue, 1.9)

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

    component Gloss: Rectangle {
        id: button
        property string icon
        property real iconSize: 18
        signal pressed()
        readonly property bool hovered: area.containsMouse

        width: 44
        height: width
        radius: width / 2
        border.color: Qt.darker(Theme.blue, 1.4)
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.tint(Theme.blue, Qt.alpha(Theme.glint, button.hovered ? 0.6 : 0.45)) }
            GradientStop { position: 0.55; color: Theme.blue }
            GradientStop { position: 1; color: Qt.darker(Theme.blue, 1.3) }
        }
        scale: area.pressed ? 0.92 : 1
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

        Rectangle {
            x: parent.width * 0.18
            y: 2
            width: parent.width * 0.64
            height: parent.height * 0.42
            radius: height / 2
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.alpha(Theme.glint, 0.75) }
                GradientStop { position: 1; color: Qt.alpha(Theme.glint, 0) }
            }
        }
        Pictogram {
            anchors.centerIn: parent
            path: button.icon
            size: button.iconSize
            colour: Theme.glint
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: button.pressed()
        }
    }

    visible: false
    color: "transparent"
    implicitWidth: 560
    implicitHeight: 240
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

    Item {
        x: (popup.width - width) / 2
        y: 8
        width: 520
        height: 180
        opacity: popup.shown ? 1 : 0
        scale: popup.shown ? 1 : 0.92
        transformOrigin: Item.Top
        Behavior on opacity { NumberAnimation { duration: 140 } }
        Behavior on scale { NumberAnimation { duration: popup.shown ? 260 : 140; easing.type: popup.shown ? Easing.OutBack : Easing.InCubic } }

        Rectangle {
            anchors.fill: parent
            radius: 26
            border.color: Qt.darker(Theme.blue, 1.5)
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.tint(Theme.blue, Qt.alpha(Theme.glint, 0.35)) }
                GradientStop { position: 0.5; color: Theme.blue }
                GradientStop { position: 1; color: Qt.darker(Theme.blue, 1.35) }
            }
        }
        Rectangle {
            x: 20
            y: 3
            width: parent.width - 40
            height: parent.height * 0.4
            radius: 22
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.alpha(Theme.glint, 0.5) }
                GradientStop { position: 1; color: Qt.alpha(Theme.glint, 0) }
            }
        }

        Column {
            x: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            Gloss { icon: Icons.previous; onPressed: popup.player?.previous(); opacity: popup.player?.canGoPrevious ? 1 : 0.5 }
            Gloss { icon: popup.player?.isPlaying ? Icons.pause : Icons.play; onPressed: popup.player?.togglePlaying() }
            Gloss { icon: Icons.next; onPressed: popup.player?.next(); opacity: popup.player?.canGoNext ? 1 : 0.5 }
        }

        Rectangle {
            id: screen
            x: 84
            y: 18
            width: parent.width - x - 18
            height: parent.height - 36
            radius: 14
            color: popup.deep
            border.color: Qt.alpha(Theme.glint, 0.25)

            Column {
                x: 16
                y: 14
                width: parent.width - 32
                spacing: 10

                Item {
                    width: parent.width
                    height: tag.height
                    Caps { id: tag; text: popup.player?.identity ?? "no player"; color: Qt.alpha(Theme.glint, 0.75) }
                    Caps { anchors.right: parent.right; text: popup.player?.isPlaying ? "playing" : "standby"; color: Qt.alpha(Theme.glint, 0.75) }
                }

                Row {
                    spacing: 14

                    Rectangle {
                        width: 64
                        height: 64
                        radius: 6
                        color: Qt.alpha(Theme.glint, 0.1)
                        clip: true
                        Image {
                            anchors.fill: parent
                            source: popup.player?.trackArtUrl ?? ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                            mipmap: true
                        }
                    }

                    Column {
                        width: screen.width - 32 - 78
                        spacing: 3
                        anchors.verticalCenter: parent.verticalCenter
                        Label {
                            text: popup.player?.trackTitle || "no disc"
                            color: Theme.glint
                            font.pixelSize: 15
                            width: parent.width
                            elide: Text.ElideRight
                        }
                        Label {
                            text: popup.player?.trackArtist ?? ""
                            color: Qt.alpha(Theme.glint, 0.75)
                            font.bold: false
                            width: parent.width
                            elide: Text.ElideRight
                        }
                        Label {
                            text: `${popup.time(popup.player?.position ?? 0)} / ${popup.time(popup.player?.length ?? 0)}`
                            color: Qt.alpha(Theme.glint, 0.75)
                            font.pixelSize: 11
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 3
                    color: Qt.alpha(Theme.glint, 0.18)

                    Rectangle {
                        height: parent.height
                        radius: 3
                        width: parent.width * Math.min(1, (popup.player?.position ?? 0) / Math.max(1, popup.player?.length ?? 1))
                        color: Theme.glint
                        Behavior on width { NumberAnimation { duration: 200 } }
                    }
                }
            }
        }
    }
}
