import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// login as a crt powering on: a beam opens to the full screen, the boot log
// prints, then the screen rolls down off the desktop. Once per hyprland
// session (the runtime dir outlives a logout, so the flag holds the instance
// signature); `qs ipc call boot replay` replays it, a click skips it
Scope {
    id: boot

    property bool shown: false
    property int count: 0
    property real beamWidth: 0
    property real beamHeight: 0
    property real beamOpacity: 1
    property real roll: 0

    readonly property string cpu: (cpuinfo.text().match(/model name\s*:\s*(.*)/) ?? ["", "cpu"])[1]
    readonly property string mem: Math.round(parseInt((meminfo.text().match(/MemTotal:\s*(\d+)/) ?? ["", "0"])[1]) / 1024) + "M"
    readonly property var lines: [
        `[    0.000000] Linux version ${tty.kernel}`,
        `[    0.000000] BIOS-provided physical RAM map: ${mem} usable`,
        `[    0.031337] smpboot: CPU0: ${cpu}`,
        `[    0.118702] PCI: Using configuration type 1 for base access`,
        `[    0.402119] Freeing unused kernel image memory`,
        `[    1.024000] Run /sbin/init as init process`,
        `[  OK  ] Mounted /`,
        `[  OK  ] Reached target Local File Systems.`,
        `[  OK  ] Started Network Manager.`,
        `[  OK  ] Reached target Sound Card.`,
        `[  OK  ] Started Hyprland.`,
        `[  OK  ] Reached target Graphical Interface.`,
        ``,
        `${tty.host} login: ${tty.user}`,
        `ready.`,
    ]

    function show() {
        count = 0;
        beamWidth = 0;
        beamHeight = 0;
        beamOpacity = 1;
        roll = 0;
        shown = true;
        powerOn.restart();
    }

    function skip() {
        powerOn.stop();
        step.stop();
        done.stop();
        rollOff.stop();
        shown = false;
    }

    SequentialAnimation {
        id: powerOn
        PauseAnimation { duration: 150 }
        NumberAnimation { target: boot; property: "beamWidth"; to: 1; duration: 140; easing.type: Easing.OutQuad }
        NumberAnimation { target: boot; property: "beamHeight"; to: 1; duration: 200; easing.type: Easing.InQuad }
        ScriptAction { script: step.start() }
        NumberAnimation { target: boot; property: "beamOpacity"; to: 0; duration: 300 }
    }

    SequentialAnimation {
        id: rollOff
        NumberAnimation { target: boot; property: "roll"; to: 1; duration: 450; easing.type: Easing.InQuad }
        ScriptAction { script: boot.shown = false }
    }

    Tty { id: tty }
    FileView { id: cpuinfo; path: "/proc/cpuinfo"; blockLoading: true }
    FileView { id: meminfo; path: "/proc/meminfo"; blockLoading: true }

    Process {
        running: true
        command: ["sh", "-c", 'f="$XDG_RUNTIME_DIR/oldschool-booted"; [ "$(cat "$f" 2>/dev/null)" = "$HYPRLAND_INSTANCE_SIGNATURE" ] || { echo "$HYPRLAND_INSTANCE_SIGNATURE" > "$f"; echo first; }']
        stdout: StdioCollector { onStreamFinished: if (text.trim() === "first") boot.show() }
    }

    IpcHandler {
        target: "boot"
        function replay(): void { boot.show(); }
    }

    Timer {
        id: step
        interval: 70
        repeat: true
        onTriggered: {
            boot.count++;
            if (boot.count >= boot.lines.length) {
                stop();
                done.start();
            }
        }
    }
    Timer { id: done; interval: 700; onTriggered: rollOff.start() }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: boot.shown
            color: "transparent"
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "boot"

            MouseArea {
                anchors.fill: parent
                onClicked: boot.skip()
            }

            Rectangle {
                id: tube
                width: parent.width
                height: parent.height
                y: Math.round(parent.height * boot.roll)
                color: Theme.bg

                Rectangle {
                    width: parent.width
                    height: 3
                    visible: boot.roll > 0
                    color: Theme.fg
                }

                Column {
                    x: 16
                    y: 14
                    Repeater {
                        model: boot.lines.slice(0, boot.count)
                        Label {
                            required property string modelData
                            // styled text collapses runs of spaces, which the log aligns with
                            readonly property string spaced: modelData.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/ /g, "&nbsp;")
                            textFormat: Text.StyledText
                            text: modelData.startsWith("[  OK  ]")
                                ? `[&nbsp;&nbsp;<font color="${Theme.bright}">OK</font>&nbsp;&nbsp;]${spaced.slice(spaced.indexOf("]") + 1)}`
                                : spaced || "&nbsp;"
                            color: modelData.startsWith("[ ") && !modelData.startsWith("[  OK") ? Theme.dim : Theme.fg
                        }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.round(parent.width * boot.beamWidth)
                    height: Math.max(3, Math.round(parent.height * boot.beamHeight))
                    opacity: boot.beamOpacity
                    color: Theme.fg
                }
            }
        }
    }
}
