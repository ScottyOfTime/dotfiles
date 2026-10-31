import QtQuick
import Quickshell
import Quickshell.Io

// the wallpaper: a test chamber wall laid out on a 2560x1440 canvas, scaled
// to fill. The tiles flip into place, then the sign swings out and the
// portals open. The sign shows `number` as the chamber.
Rectangle {
    id: chamber

    property int number: 1

    color: Theme.line

    FileView { id: hostname; path: "/etc/hostname"; blockLoading: true }

    Item {
        width: 2560
        height: 1440
        anchors.centerIn: parent
        scale: Math.max(chamber.width / width, chamber.height / height)

        Repeater {
            model: 16 * 9

            Rectangle {
                id: tile
                required property int index
                readonly property int col: index % 16
                readonly property int row: Math.floor(index / 16)
                readonly property real grain: {
                    const x = Math.sin(index * 12.9898) * 43758.5453;
                    return x - Math.floor(x);
                }
                property real settle: 0

                x: col * 160 + 2
                y: row * 160 + 2
                width: 156
                height: 156
                radius: 2
                color: Qt.tint(Theme.bg, Qt.alpha(Theme.panel, [0, 0.3, 0.55][Math.floor(grain * 3)]))
                opacity: settle
                transform: Rotation {
                    origin.x: 78
                    origin.y: 78
                    axis { x: 0; y: 1; z: 0 }
                    angle: (1 - tile.settle) * 90
                }
                Behavior on settle { NumberAnimation { duration: 420; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
                Timer { running: true; interval: 60 + (tile.col + tile.row) * 30; onTriggered: tile.settle = 1 }
            }
        }

        Hazard {
            x: 0
            y: 1302
            width: 2560
            height: 36
            stripe: 22
            base: Theme.panel
            colour: Theme.ink
            opacity: 0
            Component.onCompleted: opacity = 1
            Behavior on opacity { NumberAnimation { duration: 400 } }
        }

        Sign {
            x: 250
            y: 230
            delay: 650
            number: chamber.number
            host: hostname.text().trim()
        }

        Portal { x: 1140; y: 380; colour: Theme.blue; delay: 1000 }
        Portal { x: 1930; y: 440; colour: Theme.orange; delay: 1250 }
    }
}
