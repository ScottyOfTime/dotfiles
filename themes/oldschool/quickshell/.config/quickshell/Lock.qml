import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

// session lock: the distro logo and a login prompt on the primary screen
// (the one at 0,0), other screens left blank; the password is never echoed
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
                        anchors.horizontalCenter: parent.horizontalCenter
                        // 24px is 32 physical at 1.33x, a native terminus size
                        font.pixelSize: 24
                        lineHeight: 1.0
                        textFormat: Text.PlainText
                        text: lock.logo
                    }

                    Label {
                        // the host line is the widest, so the block doesn't
                        // shift as the cursor blinks
                        anchors.horizontalCenter: parent.horizontalCenter
                        lineHeight: 1.3
                        textFormat: Text.StyledText
                        text: {
                            const lines = [`<font color="${Theme.dim}">${tty.host} · ${tty.kernel}</font>`, "",
                                `login: ${tty.user}`];
                            const cursor = tty.blink ? "█" : "&nbsp;";
                            if (lock.status === "broken")
                                lines.push(`<font color="${Theme.red}">auth broken: ctrl+alt+f2, run hyprlock</font>`);
                            else if (lock.status === "checking" || lock.status === "ok")
                                lines.push("password:");
                            else
                                lines.push("password: " + cursor);
                            if (lock.status === "failed" && lock.password === "")
                                lines.push("", `<font color="${Theme.red}">Login incorrect (${lock.attempts})</font>`);
                            return lines.join("<br>");
                        }
                    }
                }
            }
        }
    }
}
