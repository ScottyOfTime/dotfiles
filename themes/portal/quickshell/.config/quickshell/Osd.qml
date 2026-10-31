import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland

// volume follows pipewire; brightness arrives over ipc from the hyprland binds
PanelWindow {
    id: osd

    property string kind: "volume"
    property real value: 0
    property bool muted: false
    property bool ready: false
    property bool shown: false
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int cells: 20

    function show(k, v, m) {
        kind = k;
        value = v;
        muted = m;
        hide.stop();
        visible = true;
        shown = true;
        linger.restart();
    }

    visible: false
    color: "transparent"
    anchors.top: true
    margins.top: 64
    implicitWidth: 460
    implicitHeight: 110
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "osd"

    PwObjectTracker { objects: [osd.sink] }

    // skip the volume pipewire reports while connecting at startup
    Timer { interval: 1500; running: true; onTriggered: osd.ready = true }
    Timer { id: linger; interval: 1300; onTriggered: { osd.shown = false; hide.restart(); } }
    Timer { id: hide; interval: 160; onTriggered: osd.visible = false }

    Connections {
        target: osd.sink?.audio ?? null
        function onVolumeChanged() { if (osd.ready) osd.show("volume", osd.sink.audio.volume, osd.sink.audio.muted); }
        function onMutedChanged() { if (osd.ready) osd.show("volume", osd.sink.audio.volume, osd.sink.audio.muted); }
    }

    IpcHandler {
        target: "osd"
        function brightness(percent: int): void { osd.show("brightness", percent / 100, false); }
    }

    Panel {
        anchors.centerIn: parent
        out: osd.shown
        padX: 16
        padY: 12
        edge: osd.muted ? Theme.orange : Theme.blue

        Column {
            spacing: 8

            Row {
                width: cellRow.width
                Caps {
                    text: osd.muted ? "audio suspended" : osd.kind
                    color: osd.muted ? Theme.orange : Theme.dim
                    width: parent.width - number.width
                }
                Caps {
                    id: number
                    text: osd.muted ? "--" : `${Math.round(osd.value * 100)} / 100`
                    color: osd.value > 1 ? Theme.orange : Theme.fg
                }
            }

            Row {
                id: cellRow
                spacing: 4

                Repeater {
                    model: osd.cells
                    Rectangle {
                        required property int index
                        readonly property bool lit: !osd.muted && index < Math.round(Math.min(1, osd.value) * osd.cells)
                        width: 16
                        height: 18
                        radius: 2
                        color: lit ? (osd.value > 1 ? Theme.orange : Theme.blue) : Theme.surface
                        Behavior on color { ColorAnimation { duration: 80 } }
                    }
                }
            }
        }
    }
}
