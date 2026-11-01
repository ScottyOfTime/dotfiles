import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

// session lock: the distro logo, the user and a masked password on the
// primary screen (the one at 0,0); other screens are left blank
Scope {
    id: lock

    property string password: ""
    property string status: ""
    property int attempts: 0
    property string logo: ""
    readonly property var primary: Quickshell.screens.find(s => s.x === 0 && s.y === 0)
        ?? Quickshell.screens[0]

    function lockNow() {
        password = "";
        status = "";
        session.locked = true;
    }

    function leave() {
        status = "ok";
        password = "";
        unlockAfterLeave.restart();
    }

    function submit() {
        if (password === "" || pam.active) return;
        status = "checking";
        pam.start();
    }

    IpcHandler {
        target: "lock"
        function lock(): void { lock.lockNow(); }
        // locks for six seconds then unlocks itself, to look at it safely
        function preview(): void { lock.lockNow(); previewEnd.restart(); }
    }

    Process {
        running: true
        command: ["fastfetch", "--pipe", "-s", "none"]
        stdout: StdioCollector { onStreamFinished: lock.logo = text.replace(/\s+$/, "") }
    }

    Timer { id: previewEnd; interval: 6000; onTriggered: lock.leave() }
    Timer { id: unlockAfterLeave; interval: 250; onTriggered: { session.locked = false; lock.status = ""; } }

    PamContext {
        id: pam
        // the system's login rules, as hyprlock uses; a custom config
        // directory would make their includes resolve there and fail
        config: "login"
        onResponseRequiredChanged: if (responseRequired) respond(lock.password)
        onCompleted: result => {
            lock.password = "";
            if (result === PamResult.Success) {
                lock.attempts = 0;
                lock.leave();
            } else if (result === PamResult.Failed) {
                lock.status = "failed";
                lock.attempts++;
            } else {
                lock.status = "broken";
            }
        }
        onError: lock.status = "broken"
    }

    WlSessionLock {
        id: session

        WlSessionLockSurface {
            id: surface
            color: Theme.bg

            Item {
                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
                    if (lock.status === "ok") return;
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        lock.submit();
                    } else if (event.key === Qt.Key_Backspace) {
                        lock.password = lock.password.slice(0, -1);
                    } else if (event.key === Qt.Key_Escape) {
                        lock.password = "";
                    } else if (event.text !== "" && !pam.active) {
                        lock.password += event.text;
                        if (lock.status === "failed") lock.status = "";
                    }
                    event.accepted = true;
                }

                Tty { id: tty }

                Column {
                    visible: surface.screen === lock.primary
                    anchors.centerIn: parent
                    spacing: 40

                    Label {
                        id: art
                        anchors.horizontalCenter: parent.horizontalCenter
                        // 24px is 32 physical at 1.33x, a native terminus size
                        font.pixelSize: 24
                        lineHeight: 1.0
                        textFormat: Text.PlainText
                        text: lock.logo
                    }

                    // the user centred on a character grid; the password and
                    // errors start under its first letter and grow right
                    Column {
                        id: prompt
                        width: art.width
                        spacing: 6

                        function gridX(chars) {
                            const w = cell.advanceWidth;
                            return Math.round((width - chars * w) / 2 / w) * w;
                        }

                        TextMetrics { id: cell; font.family: Theme.font; font.pixelSize: Theme.fontSize; text: "m" }

                        Label {
                            id: name
                            x: prompt.gridX(text.length)
                            textFormat: Text.PlainText
                            text: tty.user
                        }
                        Label {
                            readonly property bool waiting: lock.status === "checking" || lock.status === "ok"
                            x: name.x
                            textFormat: Text.PlainText
                            text: lock.status === "broken" ? "auth broken: ctrl+alt+f2, run hyprlock"
                                : "*".repeat(lock.password.length) + (tty.blink && !waiting ? "█" : " ")
                            color: lock.status === "broken" ? Theme.red : Theme.fg
                        }
                        Label {
                            visible: lock.status === "failed" && lock.password === ""
                            x: name.x
                            textFormat: Text.PlainText
                            text: `Login incorrect (${lock.attempts})`
                            color: Theme.red
                        }
                    }
                }
            }
        }
    }
}
