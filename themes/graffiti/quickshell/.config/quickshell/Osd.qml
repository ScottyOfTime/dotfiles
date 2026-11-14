import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland

// volume and brightness as tally marks in paint marker on gaffer tape,
// one per 5%;
// volume follows pipewire, brightness arrives over ipc from the binds
PanelWindow {
    id: osd

    property string kind: "vol"
    property real value: 0
    property bool muted: false
    property bool ready: false
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int marks: osd.muted ? 0 : Math.round(Math.min(1, osd.value) * 20)

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
    margins.top: 70
    implicitWidth: 420
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

    Gaffer {
        anchors.centerIn: parent
        width: 380
        height: 60
        seed: 31

        Marker {
            x: 22
            anchors.verticalCenter: parent.verticalCenter
            text: osd.muted ? "muted" : osd.kind === "vol" ? "vol" : "light"
            width: 70
        }

        Row {
            x: 110
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Repeater {
                model: 4
                Item {
                    id: group
                    required property int index
                    width: 40
                    height: 30

                    Repeater {
                        model: 4
                        Rectangle {
                            required property int index
                            x: 3 + index * 9
                            width: 3.5
                            height: 30
                            radius: 2
                            rotation: (index % 2 ? 3 : -2)
                            antialiasing: true
                            color: group.index * 5 + index < osd.marks
                                ? (osd.value > 1 ? Theme.red : Theme.paper) : Qt.alpha(Theme.paper, 0.1)
                        }
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        width: 3.5
                        height: 46
                        radius: 2
                        rotation: 62
                        antialiasing: true
                        color: group.index * 5 + 4 < osd.marks
                            ? (osd.value > 1 ? Theme.red : Theme.accent) : Qt.alpha(Theme.paper, 0.1)
                    }
                }
            }
        }
    }
}
