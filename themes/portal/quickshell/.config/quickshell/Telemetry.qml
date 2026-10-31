import QtQuick
import Quickshell

// the system widget: processor, memory, storage and network cards
Panel {
    id: root

    property string host: ""

    radius: 10
    padX: 14
    padY: 14

    component Card: Rectangle {
        default property alias content: body.data
        width: 272
        height: body.height + 24
        radius: 6
        color: Qt.alpha(Theme.panel, 0.5)
        border.color: Qt.alpha(Theme.line, 0.7)
        Column {
            id: body
            x: 12; y: 12
            width: parent.width - 24
            spacing: 10
        }
    }

    Column {
        spacing: 10

        Readout { width: 272; title: "system"; meta: root.host }

        Card {
            Readout { width: parent.width; title: "processor"; meta: `${Stats.freq.toFixed(2)} ghz` }
            Row {
                spacing: 16
                Ring { fraction: Stats.cpu / 100; text: `${Stats.cpu}%`; size: 60 }
                Column {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    Row { spacing: 8; Caps { text: "temp"; width: 36 } Label { text: `${Stats.temp}°c`; font.pixelSize: 12 } }
                    Row { spacing: 8; Caps { text: "load"; width: 36 } Label { text: Stats.load; font.pixelSize: 12 } }
                }
            }
            Sparkline { width: parent.width; height: 26; values: Stats.cpuHistory; ceiling: 100 }
        }

        Card {
            Readout { width: parent.width; title: "memory"; meta: `${Stats.gib(Stats.memUsed)} / ${Stats.gib(Stats.memTotal)} g` }
            Meter { width: parent.width; label: "ram"; value: `${Stats.mem}%`; fraction: Stats.mem / 100 }
            Meter { width: parent.width; label: "swap"; value: `${Stats.swap}%`; fraction: Stats.swap / 100 }
        }

        Card {
            Readout { width: parent.width; title: "storage"; meta: "/" }
            Meter {
                width: parent.width
                label: `${Stats.gib(Stats.diskUsed)} / ${Stats.gib(Stats.diskTotal)} g`
                value: `${Math.round(100 * Stats.diskUsed / Math.max(1, Stats.diskTotal))}%`
                fraction: Stats.diskUsed / Math.max(1, Stats.diskTotal)
            }
        }

        Card {
            Readout { width: parent.width; title: "network"; meta: "all links" }
            Row {
                spacing: 18
                Row { spacing: 6; Caps { text: "down" } Label { text: Stats.down; font.pixelSize: 12 } }
                Row { spacing: 6; Caps { text: "up" } Label { text: Stats.up; font.pixelSize: 12 } }
            }
            Sparkline { width: parent.width; height: 26; values: Stats.downHistory; colour: Theme.orange }
        }
    }
}
