import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland

// volume follows pipewire; brightness arrives over ipc from the hyprland binds
PanelWindow {
    id: osd

    property string kind: "v"
    property real value: 0
    property bool muted: false
    property bool ready: false
    readonly property var sink: Pipewire.defaultAudioSink

    function show(k, v, m) {
        kind = k;
        value = v;
        muted = m;
        visible = true;
        hide.restart();
    }

    visible: false
    color: "transparent"
    anchors.top: true
    margins.top: Theme.bar + 8
    implicitWidth: box.width
    implicitHeight: box.height
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "osd"

    PwObjectTracker { objects: [osd.sink] }

    // skip the volume pipewire reports while connecting at startup
    Timer { interval: 1500; running: true; onTriggered: osd.ready = true }
    Timer { id: hide; interval: 1200; onTriggered: osd.visible = false }

    Connections {
        target: osd.sink?.audio ?? null
        function onVolumeChanged() { if (osd.ready) osd.show("v", osd.sink.audio.volume, osd.sink.audio.muted); }
        function onMutedChanged() { if (osd.ready) osd.show("v", osd.sink.audio.volume, osd.sink.audio.muted); }
    }

    IpcHandler {
        target: "osd"
        function brightness(percent: int): void { osd.show("b", percent / 100, false); }
    }

    Box {
        id: box
        width: row.implicitWidth + 24
        height: row.implicitHeight + 16
        edge: osd.muted ? Theme.dim : Theme.bright

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 10
            Label {
                text: `${osd.kind}: ${osd.muted ? "muted" : Math.round(osd.value * 100) + "%"}`
            }
            Meter {
                fraction: osd.muted ? 0 : osd.value
                color: osd.value > 1 ? Theme.red : Theme.fg
            }
        }
    }
}
