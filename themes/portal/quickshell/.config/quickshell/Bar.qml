import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland

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

    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: 56
    exclusiveZone: 46
    color: "transparent"
    WlrLayershell.namespace: "bar"

    SystemClock { id: clock; precision: SystemClock.Minutes }
    PwObjectTracker { objects: [bar.sink] }

    Row {
        anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
        spacing: 6

        Panel {
            padX: 10; padY: 9
            fill: hovered ? Theme.surface : Theme.panel
            anchors.verticalCenter: parent.verticalCenter
            onClicked: Quickshell.execDetached(["qs", "ipc", "call", "launcher", "toggle"])
            PortalMark { size: 16 }
        }

        Repeater {
            model: Hyprland.workspaces.values.filter(w => w.monitor === bar.monitor && w.id > 0)

            Panel {
                required property var modelData
                required property int index

                delay: 40 + index * 40
                padX: 10; padY: 7
                fill: modelData.focused ? Theme.blue : hovered ? Theme.surface : Theme.panel
                edge: modelData.focused ? Theme.blue : modelData.active ? Theme.orange : "transparent"
                glow: modelData.focused
                anchors.verticalCenter: parent.verticalCenter
                onClicked: modelData.activate()

                Label {
                    text: String(modelData.id).padStart(2, "0")
                    color: modelData.focused ? Theme.onLit : Theme.fg
                    font.pixelSize: 14
                    font.weight: Font.ExtraBold
                }
            }
        }

        Item { width: 6; height: 1 }

        Panel {
            visible: bar.title !== ""
            delay: 200
            padX: 12; padY: 8
            edge: Theme.blue
            edgeLeft: true
            anchors.verticalCenter: parent.verticalCenter

            Label {
                text: bar.title
                width: Math.min(implicitWidth, 520)
                elide: Text.ElideRight
            }
        }
    }

    Panel {
        anchors.centerIn: parent
        delay: 120
        padX: 14; padY: 5

        Row {
            spacing: 12
            Label {
                text: Qt.formatDateTime(clock.date, "HH:mm")
                font.pixelSize: 20
                font.weight: Font.ExtraBold
                anchors.verticalCenter: parent.verticalCenter
            }
            Rectangle { width: 1; height: 22; color: Theme.line; anchors.verticalCenter: parent.verticalCenter }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Caps { text: Qt.formatDateTime(clock.date, "dddd"); color: Theme.fg }
                Caps { text: Qt.formatDateTime(clock.date, "d MMM yyyy") }
            }
        }
    }

    Row {
        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
        spacing: 6

        Panel {
            id: music
            visible: bar.player !== null
            delay: 160
            padY: 8
            fill: hovered ? Theme.surface : Theme.panel
            edge: bar.player?.isPlaying ? Theme.orange : "transparent"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: musicPopup.toggle()

            Row {
                spacing: 8
                Caps { text: "audio"; anchors.verticalCenter: parent.verticalCenter }
                Label {
                    text: !bar.player ? "" : bar.player.isPlaying
                        ? `${bar.player.trackArtist} - ${bar.player.trackTitle}` : "paused"
                    width: Math.min(implicitWidth, 280)
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Repeater {
            model: [
                { key: "vol", value: () => !bar.sink?.audio ? "-" : bar.sink.audio.muted ? "muted"
                    : `${Math.round(bar.sink.audio.volume * 100)}%`,
                  colour: () => bar.sink?.audio?.muted ? Theme.orange : Theme.fg },
                { key: "cpu", value: () => `${Stats.cpu}%`, colour: () => bar.level(Stats.cpu) },
                { key: "mem", value: () => `${Stats.mem}%`, colour: () => bar.level(Stats.mem) },
                { key: "net", value: () => Stats.net, colour: () => Theme.fg },
            ]

            Panel {
                required property var modelData
                required property int index
                readonly property bool volume: modelData.key === "vol"

                delay: 200 + index * 40
                padY: 8
                fill: volume && hovered ? Theme.surface : Theme.panel
                anchors.verticalCenter: parent.verticalCenter
                onClicked: if (volume) bar.sink.audio.muted = !bar.sink.audio.muted
                onWheeled: event => {
                    if (volume) bar.sink.audio.volume = Math.max(0, Math.min(1.5,
                        bar.sink.audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05)));
                }

                Row {
                    spacing: 7
                    Caps { text: modelData.key; anchors.verticalCenter: parent.verticalCenter }
                    Label {
                        text: modelData.value()
                        color: modelData.colour()
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
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
