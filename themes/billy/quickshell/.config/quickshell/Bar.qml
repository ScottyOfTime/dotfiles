import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland

// a strip of gaffer tape across the top, written on in paint marker; the
// focused workspace is circled in pink, one shown elsewhere underlined
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
    implicitHeight: 46
    exclusiveZone: 46
    color: "transparent"
    WlrLayershell.namespace: "bar"

    SystemClock { id: clock; precision: SystemClock.Minutes }
    PwObjectTracker { objects: [bar.sink] }

    component Sep: Marker { text: "x"; color: Qt.alpha(Theme.paper, 0.4); font.pixelSize: 13; anchors.verticalCenter: parent?.verticalCenter }

    Gaffer {
        anchors { fill: parent; topMargin: 4; bottomMargin: 6; leftMargin: 2; rightMargin: 2 }
        seed: bar.modelData.x

        Row {
            anchors { left: parent.left; leftMargin: 26; verticalCenter: parent.verticalCenter }
            spacing: 14

            Row {
                spacing: 16
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: Hyprland.workspaces.values.filter(w => w.monitor === bar.monitor && w.id > 0)

                    Item {
                        required property var modelData
                        width: num.implicitWidth
                        height: num.implicitHeight
                        anchors.verticalCenter: parent.verticalCenter

                        Scribble {
                            anchors.centerIn: parent
                            width: parent.width + 20
                            height: parent.height + 4
                            visible: drawn > 0
                            drawn: parent.modelData.focused ? 1 : 0
                        }
                        Marker {
                            id: num
                            text: parent.modelData.id
                            font.pixelSize: 19
                        }
                        Rectangle {
                            visible: parent.modelData.active && !parent.modelData.focused
                            x: -2; y: parent.height - 3
                            width: parent.width + 4; height: 2.5
                            radius: 1
                            rotation: -4
                            color: Qt.alpha(Theme.paper, 0.6)
                        }
                        MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: parent.modelData.activate() }
                    }
                }
            }

            Sep { visible: bar.title !== "" }

            Marker {
                visible: bar.title !== ""
                text: bar.title.toLowerCase()
                color: Qt.alpha(Theme.paper, 0.8)
                width: Math.min(implicitWidth, 440)
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 12

            Marker {
                text: Qt.formatDateTime(clock.date, "HH:mm")
                color: Theme.accent
                font.pixelSize: 21
                anchors.verticalCenter: parent.verticalCenter
            }
            Marker {
                text: Qt.formatDateTime(clock.date, "ddd d MMM").toLowerCase()
                color: Qt.alpha(Theme.paper, 0.6)
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            anchors { right: parent.right; rightMargin: 28; verticalCenter: parent.verticalCenter }
            spacing: 12

            Marker {
                id: music
                visible: bar.player !== null
                text: !bar.player ? "" : bar.player.isPlaying
                    ? `${bar.player.trackArtist} - ${bar.player.trackTitle}`.toLowerCase() : "paused"
                width: Math.min(implicitWidth, 280)
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
                MouseArea { anchors.fill: parent; onClicked: musicPopup.toggle() }
            }
            Sep { visible: music.visible }
            Marker {
                text: !bar.sink?.audio ? "vol -" : bar.sink.audio.muted ? "muted"
                    : `vol ${Math.round(bar.sink.audio.volume * 100)}`
                color: bar.sink?.audio?.muted ? Qt.alpha(Theme.paper, 0.5) : Theme.paper
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: bar.sink.audio.muted = !bar.sink.audio.muted
                    onWheel: event => bar.sink.audio.volume = Math.max(0, Math.min(1.5,
                        bar.sink.audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05)))
                }
            }
            Sep {}
            Marker { text: `cpu ${Stats.cpu}`; color: bar.load(Stats.cpu); anchors.verticalCenter: parent.verticalCenter }
            Sep {}
            Marker { text: `mem ${Stats.mem}`; color: bar.load(Stats.mem); anchors.verticalCenter: parent.verticalCenter }
            Sep {}
            Marker { text: `net ${Stats.net}`.toLowerCase(); anchors.verticalCenter: parent.verticalCenter }
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
