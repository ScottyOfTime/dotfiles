import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland

// volume follows pipewire; brightness arrives over ipc from the hyprland binds
PanelWindow {
    id: osd

    property string kind: "vol"
    property real value: 0
    property bool muted: false
    property bool ready: false
    readonly property var sink: Pipewire.defaultAudioSink

    function show(k, v, m) {
        kind = k;
        value = v;
        muted = m;
        if (!visible) {
            scrap.scale = 0.7;
            visible = true;
        }
        scrap.scale = 1;
        hide.restart();
    }

    visible: false
    color: "transparent"
    anchors.top: true
    margins.top: 70
    implicitWidth: 360
    implicitHeight: 110
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "osd"

    PwObjectTracker { objects: [osd.sink] }

    // skip the volume pipewire reports while connecting at startup
    Timer { interval: 1500; running: true; onTriggered: osd.ready = true }
    Timer { id: hide; interval: 1300; onTriggered: osd.visible = false }

    Connections {
        target: osd.sink?.audio ?? null
        function onVolumeChanged() { if (osd.ready) osd.show("vol", osd.sink.audio.volume, osd.sink.audio.muted); }
        function onMutedChanged() { if (osd.ready) osd.show("vol", osd.sink.audio.volume, osd.sink.audio.muted); }
    }

    IpcHandler {
        target: "osd"
        function brightness(percent: int): void { osd.show("light", percent / 100, false); }
    }

    Scrap {
        id: scrap
        anchors.centerIn: parent
        seed: 31
        tilt: -2
        padX: 16
        padY: 10

        Row {
            spacing: 14

            Label {
                text: osd.muted ? "muted" : osd.kind
                width: 52
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: 200
                height: 16
                rotation: 1.5
                anchors.verticalCenter: parent.verticalCenter

                Rectangle { anchors.fill: parent; color: Theme.ink; antialiasing: true }
                Rectangle {
                    x: 2; y: 2
                    height: parent.height - 4
                    width: (parent.width - 4) * Math.min(1, osd.muted ? 0 : osd.value)
                    color: osd.value > 1 ? Theme.red : Theme.accent
                    antialiasing: true
                    Behavior on width { NumberAnimation { duration: 90 } }
                }
            }

            Label {
                text: Math.round(osd.value * 100)
                width: 34
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
