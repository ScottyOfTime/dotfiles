import QtQuick
import Quickshell
import Quickshell.Io

// the wallpaper: a test chamber wall laid out on a 2560x1440 canvas, scaled
// to fill, with the clock and system widgets on top at screen scale. The
// tiles flip into place, then the portals open and the widgets swing out.
Rectangle {
    id: chamber

    property int number: 1
    property bool telemetry: true

    color: Qt.tint(Theme.bg, Qt.alpha(Theme.line, 0.5))

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
                property real settle: 0

                x: col * 160 + 2
                y: row * 160 + 2
                width: 156
                height: 156
                radius: 2
                color: Theme.bg
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

        Portal { x: 960; y: 400; colour: Theme.blue; delay: 700 }
        Portal { x: 1620; y: 460; colour: Theme.orange; delay: 950 }
    }

    Chrono {
        x: 28
        y: 76
        delay: 500
        workspace: chamber.number
    }

    Telemetry {
        visible: chamber.telemetry
        anchors { right: parent.right; rightMargin: 28 }
        y: 76
        delay: 600
        host: hostname.text().trim()
    }
}
