import QtQuick
import Quickshell
import Quickshell.Hyprland
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

    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: 56
    exclusiveZone: 48
    color: "transparent"
    WlrLayershell.namespace: "bar"

    SystemClock { id: clock; precision: SystemClock.Minutes }
    PwObjectTracker { objects: [bar.sink] }

    Row {
        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
        spacing: 14

        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: Hyprland.workspaces.values.filter(w => w.monitor === bar.monitor && w.id > 0)

                Scrap {
                    required property var modelData

                    seed: modelData.id
                    tilt: hovered ? 0 : [-6, 5, -3, 7][modelData.id % 4]
                    scale: modelData.focused ? 1.18 : 1
                    padX: 9
                    fill: modelData.focused ? Theme.accent : modelData.active ? Theme.surface : Theme.paper
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        text: modelData.id
                        color: modelData.active && !modelData.focused ? Theme.fg : Theme.ink
                        font.pixelSize: 15
                    }

                    onClicked: modelData.activate()
                }
            }
        }

        Scrap {
            visible: bar.title !== ""
            seed: 99
            tilt: -1.2
            tape: true
            fill: Theme.ink
            padX: 16
            anchors.verticalCenter: parent.verticalCenter

            Label {
                text: bar.title
                color: Theme.paper
                width: Math.min(implicitWidth, 460)
                elide: Text.ElideRight
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 6

        Scrap {
            seed: 7; tilt: -5; fill: Theme.accent; padX: 8; padY: 2
            anchors.verticalCenter: parent.verticalCenter
            Label { text: Qt.formatDateTime(clock.date, "HH"); font.pixelSize: 20 }
        }
        Scrap {
            seed: 8; tilt: 4; padX: 8; padY: 2
            anchors.verticalCenter: parent.verticalCenter
            Label { text: Qt.formatDateTime(clock.date, "mm"); font.pixelSize: 20 }
        }
        Scrap {
            seed: 9; tilt: -2; fill: Theme.ink; padX: 10
            anchors.verticalCenter: parent.verticalCenter
            Label { text: Qt.formatDateTime(clock.date, "ddd d MMM").toLowerCase(); color: Theme.paper }
        }
    }

    Row {
        anchors { right: parent.right; rightMargin: 24; verticalCenter: parent.verticalCenter }
        spacing: 10

        Scrap {
            visible: bar.player !== null
            seed: 21; tilt: 2.5
            anchors.verticalCenter: parent.verticalCenter
            Label {
                text: !bar.player ? "" : bar.player.isPlaying
                    ? `${bar.player.trackArtist} - ${bar.player.trackTitle}` : "paused"
                width: Math.min(implicitWidth, 280)
                elide: Text.ElideRight
            }
        }
        Scrap {
            seed: 22; tilt: -3; fill: Theme.panel
            anchors.verticalCenter: parent.verticalCenter
            Label {
                text: !bar.sink?.audio ? "vol -" : bar.sink.audio.muted ? "muted"
                    : `vol ${Math.round(bar.sink.audio.volume * 100)}%`
                color: bar.sink?.audio?.muted ? Theme.dim : Theme.fg
            }
            onClicked: bar.sink.audio.muted = !bar.sink.audio.muted
            onWheeled: event => bar.sink.audio.volume = Math.max(0, Math.min(1.5,
                bar.sink.audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05)))
        }
        Scrap {
            seed: 23; tilt: 4; fill: Theme.panel
            anchors.verticalCenter: parent.verticalCenter
            Label {
                text: `cpu ${Stats.cpu}%`
                color: Stats.cpu > 90 ? Theme.red : Stats.cpu > 70 ? Theme.accent : Theme.fg
            }
        }
        Scrap {
            seed: 24; tilt: -2; fill: Theme.panel
            anchors.verticalCenter: parent.verticalCenter
            Label {
                text: `mem ${Stats.mem}%`
                color: Stats.mem > 90 ? Theme.red : Stats.mem > 70 ? Theme.accent : Theme.fg
            }
        }
        Scrap {
            seed: 25; tilt: 3; fill: Theme.panel
            anchors.verticalCenter: parent.verticalCenter
            Label { text: `net ${Stats.net}`; color: Theme.fg }
        }
    }
}
