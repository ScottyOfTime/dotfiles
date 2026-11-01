import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// login as a crt powering on: a burst of snow, a dot that stretches into a
// line and opens to a full flash, which collapses back to the centre as the
// boot log types out; then the desktop dithers in. Once per hyprland session
// (the runtime dir outlives a logout, so the flag holds the instance
// signature); `qs ipc call boot replay` replays it, a click skips it.
// Unlocking plays just the dither (`reveal`)
Scope {
    id: boot

    property bool shown: false
    // "snow", "beam", "log" or "" (a blank tube, before a reveal)
    property string phase: ""
    property int snow: 0
    property real across: 0
    property real down: 0
    property real glow: 1
    property int typed: 0
    // 0 is a solid tube, 16 fully dissolved (one step of a 4x4 bayer matrix)
    property int dissolve: 0

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

    readonly property int total: lines.join("\n").length

    // the lines typed so far, the last one cut off mid-way
    readonly property var shownLines: {
        const out = [];
        let left = typed;
        for (const line of lines) {
            if (left <= 0) break;
            out.push(line.slice(0, left));
            left -= line.length + 1;
        }
        return out;
    }

    function reset() {
        powerOn.stop();
        typer.stop();
        done.stop();
        revealDelay.stop();
        fadeIn.stop();
        phase = "";
        snow = 0;
        across = 0;
        down = 0;
        glow = 1;
        typed = 0;
        dissolve = 0;
    }

    function show() {
        reset();
        shown = true;
        powerOn.start();
    }

    // after unlocking: a blank tube already up when the lock surface goes,
    // then the dither off the desktop
    function reveal() {
        reset();
        shown = true;
        revealDelay.restart();
    }

    function skip() {
        reset();
        shown = false;
    }

    SequentialAnimation {
        id: powerOn
        PauseAnimation { duration: 120 }
        ScriptAction { script: boot.phase = "snow" }
        NumberAnimation { target: boot; property: "snow"; from: 0; to: 6; duration: 300 }
        ScriptAction { script: boot.phase = "beam" }
        PauseAnimation { duration: 110 }
        NumberAnimation { target: boot; property: "across"; to: 1; duration: 160 }
        NumberAnimation { target: boot; property: "down"; to: 1; duration: 200 }
        ScriptAction { script: { boot.phase = "log"; typer.start(); } }
        ParallelAnimation {
            NumberAnimation { target: boot; property: "down"; to: 0; duration: 380 }
            NumberAnimation { target: boot; property: "glow"; to: 0; duration: 380 }
        }
    }

    Timer {
        id: typer
        interval: 16
        repeat: true
        onTriggered: {
            boot.typed += 7;
            if (boot.typed >= boot.total) {
                stop();
                done.start();
            }
        }
    }
    Timer { id: done; interval: 600; onTriggered: fadeIn.start() }

    // the lock surface lingers 250ms after a successful unlock (Lock.qml)
    Timer { id: revealDelay; interval: 320; onTriggered: fadeIn.start() }

    SequentialAnimation {
        id: fadeIn
        NumberAnimation { target: boot; property: "dissolve"; from: 0; to: 16; duration: 400 }
        ScriptAction { script: boot.skip() }
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

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: tube
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
                anchors.fill: parent
                visible: boot.dissolve === 0
                color: Theme.bg
            }

            // the desktop comes through an ordered dither, two levels a step;
            // low-res and scaled without smoothing, so the cells stay square
            Canvas {
                id: dither
                readonly property int cell: 4
                readonly property int level: Math.floor(boot.dissolve / 2) * 2
                width: Math.ceil(parent.width / cell)
                height: Math.ceil(parent.height / cell)
                visible: boot.dissolve > 0
                smooth: false
                transform: Scale { xScale: dither.cell; yScale: dither.cell }
                onLevelChanged: if (level > 0) requestPaint()
                // putImageData draws nothing in this qt; fillRect is fast enough
                onPaint: {
                    const bayer = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5];
                    const ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.fillStyle = Theme.bg;
                    for (let y = 0; y < height; y++)
                        for (let x = 0; x < width; x++)
                            if (bayer[(y % 4) * 4 + x % 4] >= level)
                                ctx.fillRect(x, y, 1, 1);
                }
            }

            Canvas {
                id: noise
                readonly property int cell: 6
                width: Math.ceil(parent.width / cell)
                height: Math.ceil(parent.height / cell)
                visible: boot.phase === "snow"
                smooth: false
                transform: Scale { xScale: noise.cell; yScale: noise.cell }
                Connections {
                    target: boot
                    function onSnowChanged() { if (boot.phase === "snow") noise.requestPaint(); }
                }
                onPaint: {
                    const shades = [Theme.line, Theme.dim, Theme.fg, Theme.bright];
                    const ctx = getContext("2d");
                    ctx.fillStyle = Theme.bg;
                    ctx.fillRect(0, 0, width, height);
                    for (let y = 0; y < height; y++)
                        for (let x = 0; x < width; x++) {
                            const r = Math.floor(Math.random() * 6) - 2;
                            if (r < 0) continue;
                            ctx.fillStyle = shades[r];
                            ctx.fillRect(x, y, 1, 1);
                        }
                }
            }

            Column {
                x: 16
                y: 14
                visible: boot.phase === "log" && boot.dissolve === 0
                Repeater {
                    model: boot.shownLines
                    Label {
                        required property string modelData
                        required property int index
                        readonly property bool last: index === boot.shownLines.length - 1 && boot.typed < boot.total
                        // styled text collapses runs of spaces, which the log aligns with
                        readonly property string spaced: modelData.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/ /g, "&nbsp;")
                        textFormat: Text.StyledText
                        text: (modelData.startsWith("[  OK  ]")
                                ? `[&nbsp;&nbsp;<font color="${Theme.bright}">OK</font>&nbsp;&nbsp;]${spaced.slice(spaced.indexOf("]") + 1)}`
                                : spaced || "&nbsp;") + (last ? "█" : "")
                        color: modelData.startsWith("[ ") && !modelData.startsWith("[  OK") ? Theme.dim : Theme.fg
                    }
                }
            }

            Beam {
                visible: boot.phase === "beam" || (boot.phase === "log" && boot.glow > 0)
                across: boot.across
                down: boot.down
                glow: boot.glow
            }
        }
    }
}
