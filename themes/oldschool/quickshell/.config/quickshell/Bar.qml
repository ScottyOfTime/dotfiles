import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Wayland

// a classic status line: workspaces | focused title ... modules | date | time
PanelWindow {
    id: bar

    required property var modelData
    readonly property var monitor: Hyprland.monitorFor(modelData)
    readonly property var sink: Pipewire.defaultAudioSink
    // laptops only: the desktop's displayDevice is no laptop battery
    readonly property var battery: UPower.displayDevice?.isLaptopBattery && UPower.displayDevice.isPresent
        ? UPower.displayDevice : null
    readonly property var player: Mpris.players.values.find(p => p.identity === "Spotify")
        ?? Mpris.players.values[0] ?? null
    readonly property string title: Hyprland.focusedMonitor === monitor && Hyprland.activeToplevel
        ? Hyprland.activeToplevel.title : ""

    function level(v) {
        return v > 90 ? Theme.red : v > 70 ? Theme.bright : Theme.fg;
    }

    component Module: Label {
        id: module
        property string key
        property string value
        property color tone: Theme.fg
        signal clicked()
        signal wheeled(var event)

        textFormat: Text.StyledText
        text: key ? `<font color="${Theme.dim}">${key}</font> <font color="${tone}">${value}</font>`
            : `<font color="${tone}">${value}</font>`
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            onClicked: module.clicked()
            onWheel: event => module.wheeled(event)
        }
    }

    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.whole(Theme.bar, devicePixelRatio)
    exclusiveZone: implicitHeight
    color: Theme.panel
    WlrLayershell.namespace: "bar"

    SystemClock { id: clock; precision: SystemClock.Minutes }
    PwObjectTracker { objects: [bar.sink] }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: Theme.px(1, bar.devicePixelRatio)
        color: Theme.line
    }

    component Sep: Label {
        text: "|"
        color: Theme.line
        anchors.verticalCenter: parent.verticalCenter
    }

    Row {
        height: parent.height
        leftPadding: 4

        Repeater {
            model: Hyprland.workspaces.values.filter(w => w.monitor === bar.monitor && w.id > 0)

            Rectangle {
                required property var modelData
                width: number.implicitWidth + 12
                height: parent.height
                color: modelData.focused ? Theme.fg : modelData.active ? Theme.surface : "transparent"

                Label {
                    id: number
                    anchors.centerIn: parent
                    text: modelData.id
                    color: modelData.focused ? Theme.onLit : Theme.fg
                    font.bold: modelData.focused
                }
                MouseArea { anchors.fill: parent; onClicked: modelData.activate() }
            }
        }

        Label {
            leftPadding: 8
            textFormat: Text.StyledText
            text: bar.title ? `<font color="${Theme.line}">|</font>&nbsp;&nbsp;<font color="${Theme.bright}">&gt;</font> ${bar.title.replace(/&/g, "&amp;").replace(/</g, "&lt;")}` : ""
            color: Theme.fg
            width: Math.min(implicitWidth, bar.width / 2 - 200)
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
        height: parent.height
        spacing: 8

        Module {
            id: music
            visible: bar.player !== null
            key: "mus"
            value: !bar.player ? "" : bar.player.isPlaying
                ? `${bar.player.trackArtist} - ${bar.player.trackTitle}` : "paused"
            width: Math.min(implicitWidth, 320)
            elide: Text.ElideRight
            onClicked: musicPopup.toggle()
        }
        Sep { visible: music.visible }
        Module {
            key: "vol"
            value: !bar.sink?.audio ? "-" : bar.sink.audio.muted ? "muted"
                : `${Math.round(bar.sink.audio.volume * 100)}%`
            tone: bar.sink?.audio?.muted ? Theme.dim : Theme.fg
            onClicked: bar.sink.audio.muted = !bar.sink.audio.muted
            onWheeled: event => bar.sink.audio.volume = Math.max(0, Math.min(1.5,
                bar.sink.audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05)))
        }
        Sep { visible: bar.battery !== null }
        Module {
            visible: bar.battery !== null
            key: "bat"
            readonly property int percent: Math.round((bar.battery?.percentage ?? 0) * 100)
            readonly property bool charging: bar.battery?.state === UPowerDeviceState.Charging
                || bar.battery?.state === UPowerDeviceState.FullyCharged
            value: `${percent}%${charging ? "+" : ""}`
            tone: !charging && percent <= 15 ? Theme.red : !charging && percent <= 30 ? Theme.bright : Theme.fg
        }
        Sep {}
        Module { key: "cpu"; value: `${Stats.cpu}%`; tone: bar.level(Stats.cpu) }
        Sep {}
        Module { key: "mem"; value: `${Stats.mem}%`; tone: bar.level(Stats.mem) }
        Sep {}
        Module { key: "net"; value: Stats.net }
        Sep {}
        Module { value: Qt.formatDateTime(clock.date, "yyyy-MM-dd") }
        Sep {}
        Module { value: Qt.formatDateTime(clock.date, "HH:mm"); tone: Theme.bright }
    }

    required property int musicToggles
    // shell.qml owns the one `music` ipc handler and counts toggles; the
    // focused monitor's bar opens its popup
    onMusicTogglesChanged: if (Hyprland.focusedMonitor === bar.monitor) musicPopup.toggle()

    MusicPopup {
        id: musicPopup
        player: bar.player
        anchorItem: music
    }
}
