import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// a boot log over every screen, once per login (a flag in the runtime dir);
// `qs ipc call boot replay` replays it, a click skips it
Scope {
    id: boot

    property bool shown: false
    property int count: 0

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
        shown = true;
        step.start();
    }

    Tty { id: tty }
    FileView { id: cpuinfo; path: "/proc/cpuinfo"; blockLoading: true }
    FileView { id: meminfo; path: "/proc/meminfo"; blockLoading: true }

    Process {
        running: true
        command: ["sh", "-c", 'f="$XDG_RUNTIME_DIR/oldschool-booted"; [ -e "$f" ] || { touch "$f"; echo first; }']
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
    Timer { id: done; interval: 900; onTriggered: boot.shown = false }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: boot.shown
            color: Theme.bg
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "boot"

            MouseArea {
                anchors.fill: parent
                onClicked: { step.stop(); done.stop(); boot.shown = false; }
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
        }
    }
}
