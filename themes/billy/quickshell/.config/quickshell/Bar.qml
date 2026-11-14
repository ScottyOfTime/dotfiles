import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland

// no bar as such: label-maker strips stuck straight onto the wall
PanelWindow {
    id: bar

    required property var modelData
    // by name, re-resolved: monitorFor keeps a dead object after the screens
    // sleep and come back, and its workspaces stop matching
    readonly property var monitor: Hyprland.monitors.values.find(m => m.name === modelData.name) ?? null
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var player: Mpris.players.values.find(p => p.identity === "Spotify")
        ?? Mpris.players.values[0] ?? null
    readonly property string title: Hyprland.focusedMonitor === monitor && Hyprland.activeToplevel
        ? Hyprland.activeToplevel.title : ""

    function load(n) { return n > 90 ? Theme.red : n > 70 ? Theme.accent : Theme.paper; }

    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: 50
    exclusiveZone: 42
    color: "transparent"
    WlrLayershell.namespace: "bar"

    SystemClock { id: clock; precision: SystemClock.Minutes }
    PwObjectTracker { objects: [bar.sink] }

    Row {
        anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
        spacing: 12

        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: Hyprland.workspaces.values.filter(w => w.monitor === bar.monitor && w.id > 0)

                Dymo {
                    required property var modelData

                    text: String(modelData.id).padStart(2, "0")
                    seed: modelData.id
                    hot: modelData.focused
                    tilt: [-2, 1.5, -1, 2.5][modelData.id % 4]
                    tape: modelData.focused ? Theme.ink : modelData.active ? Theme.surface : Theme.ink
                    letters: modelData.focused ? Theme.accent : modelData.active ? Theme.fg : Theme.paper
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: modelData.activate()
                }
            }
        }

        Dymo {
            visible: bar.title !== ""
            text: bar.title
            maxWidth: 420
            seed: 99
            tilt: -0.8
            tape: Theme.paper
            letters: Theme.ink
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Dymo {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            size: 17
            seed: 7
            tilt: -1.5
            tape: Theme.accent
            letters: Theme.ink
            anchors.verticalCenter: parent.verticalCenter
        }
        Dymo {
            text: Qt.formatDateTime(clock.date, "ddd d MMM")
            seed: 8
            tilt: 1
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
        spacing: 8

        Dymo {
            id: music
            visible: bar.player !== null
            text: !bar.player ? "" : bar.player.isPlaying
                ? `${bar.player.trackArtist} - ${bar.player.trackTitle}` : "paused"
            maxWidth: 260
            seed: 21
            tilt: hovered ? 0 : 1.2
            tape: Theme.paper
            letters: Theme.ink
            anchors.verticalCenter: parent.verticalCenter
            onClicked: musicPopup.toggle()
        }
        Dymo {
            text: !bar.sink?.audio ? "vol -" : bar.sink.audio.muted ? "muted"
                : `vol ${Math.round(bar.sink.audio.volume * 100)}`
            seed: 22; tilt: -1.5
            letters: bar.sink?.audio?.muted ? Theme.dim : Theme.paper
            anchors.verticalCenter: parent.verticalCenter
            onClicked: bar.sink.audio.muted = !bar.sink.audio.muted
            onWheeled: event => bar.sink.audio.volume = Math.max(0, Math.min(1.5,
                bar.sink.audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05)))
        }
        Dymo {
            text: `cpu ${Stats.cpu}`
            seed: 23; tilt: 2
            letters: bar.load(Stats.cpu)
            anchors.verticalCenter: parent.verticalCenter
        }
        Dymo {
            text: `mem ${Stats.mem}`
            seed: 24; tilt: -1
            letters: bar.load(Stats.mem)
            anchors.verticalCenter: parent.verticalCenter
        }
        Dymo {
            text: `net ${Stats.net}`
            seed: 25; tilt: 1.5
            anchors.verticalCenter: parent.verticalCenter
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
