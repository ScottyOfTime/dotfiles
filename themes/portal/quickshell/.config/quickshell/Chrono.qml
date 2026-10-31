import QtQuick
import Quickshell

// the clock widget: time, the workspace beside it, date and day counters
Panel {
    id: root

    property int workspace: 1
    readonly property date now: clock.date
    readonly property int offset: -now.getTimezoneOffset() / 60

    function dayOfYear(d) {
        return Math.floor((d - new Date(d.getFullYear(), 0, 0)) / 86400000);
    }
    function week(d) {
        const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
        t.setUTCDate(t.getUTCDate() + 4 - (t.getUTCDay() || 7));
        return Math.ceil(((t - Date.UTC(t.getUTCFullYear(), 0, 1)) / 86400000 + 1) / 7);
    }

    radius: 10
    padX: 20
    padY: 16

    SystemClock { id: clock; precision: SystemClock.Seconds }

    Column {
        width: 340
        spacing: 10

        Readout {
            width: parent.width
            title: "time"
            meta: `local · utc${root.offset >= 0 ? "+" : ""}${root.offset}`
        }

        Row {
            spacing: 10
            Label {
                id: time
                text: Qt.formatDateTime(root.now, "HH:mm")
                font.pixelSize: 64
                font.weight: Font.Light
            }
            Label {
                text: String(root.workspace).padStart(2, "0")
                color: Theme.blue
                font.pixelSize: 18
                anchors.baseline: time.baseline
            }
        }

        Label {
            text: Qt.formatDateTime(root.now, "dddd · d MMMM yyyy")
            font.bold: false
        }

        Row {
            spacing: 18
            Caps { text: `day ${root.dayOfYear(root.now)}` }
            Caps { text: `week ${root.week(root.now)}` }
            Caps { text: `up ${Stats.since(Stats.uptime)}` }
        }
    }
}
