import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland

// a solid strip: workspaces and the window title, then "key: value" modules
PanelWindow {
    id: bar

    required property var modelData
    readonly property var monitor: Hyprland.monitorFor(modelData)
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var player: Mpris.players.values.find(p => p.identity === "Spotify")
        ?? Mpris.players.values[0] ?? null
    readonly property string title: Hyprland.focusedMonitor === monitor && Hyprland.activeToplevel
        ? Hyprland.activeToplevel.title : ""

    function level(v) {
        return v > 90 ? Theme.red : v > 70 ? Theme.orange : Theme.fg;
    }

    component Module: Label {
        id: module
        property string key
        property string value
        property color tone: Theme.fg
        signal clicked()
        signal wheeled(var event)

        textFormat: Text.StyledText
        text: `<font color="${Theme.dim}">${key}:</font> <font color="${tone}">${value}</font>`
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            onClicked: module.clicked()
            onWheel: event => module.wheeled(event)
        }
    }

    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.bar
    exclusiveZone: Theme.bar
    color: Theme.panel
    WlrLayershell.namespace: "bar"

    SystemClock { id: clock; precision: SystemClock.Minutes }
    PwObjectTracker { objects: [bar.sink] }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.line
    }

    Row {
        height: parent.height

        Repeater {
            model: Hyprland.workspaces.values.filter(w => w.monitor === bar.monitor && w.id > 0)

            Rectangle {
                required property var modelData
                width: number.implicitWidth + 20
                height: parent.height
                color: modelData.focused ? Theme.blue : modelData.active ? Theme.surface : "transparent"

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
            leftPadding: 12
            text: bar.title
            color: Theme.dim
            width: Math.min(implicitWidth, bar.width / 2 - 200)
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
        height: parent.height
        spacing: 18

        Module {
            id: music
            visible: bar.player !== null
            key: "m"
            value: !bar.player ? "" : bar.player.isPlaying
                ? `${bar.player.trackArtist} - ${bar.player.trackTitle}` : "paused"
            width: Math.min(implicitWidth, 320)
            elide: Text.ElideRight
            onClicked: musicPopup.toggle()
        }
        Module {
            key: "v"
            value: !bar.sink?.audio ? "-" : bar.sink.audio.muted ? "muted"
                : `${Math.round(bar.sink.audio.volume * 100)}%`
            tone: bar.sink?.audio?.muted ? Theme.orange : Theme.fg
            onClicked: bar.sink.audio.muted = !bar.sink.audio.muted
            onWheeled: event => bar.sink.audio.volume = Math.max(0, Math.min(1.5,
                bar.sink.audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05)))
        }
        Module { key: "cpu"; value: `${Stats.cpu}%`; tone: bar.level(Stats.cpu) }
        Module { key: "mem"; value: `${Stats.mem}%`; tone: bar.level(Stats.mem) }
        Module { key: "net"; value: Stats.net }
        Module { key: "d"; value: Qt.formatDateTime(clock.date, "yyyy-MM-dd") }
        Module { key: "t"; value: Qt.formatDateTime(clock.date, "HH : mm") }
    }

    IpcHandler {
        target: "music"
        enabled: Hyprland.focusedMonitor === bar.monitor
        function toggle(): void { musicPopup.toggle(); }
    }

    MusicPopup {
        id: musicPopup
        player: bar.player
        anchorItem: music
    }
}
