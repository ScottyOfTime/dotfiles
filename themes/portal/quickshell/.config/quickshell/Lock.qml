import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

// session lock: a single "password:" box
Scope {
    id: lock

    property string password: ""
    property string status: ""
    property int attempts: 0

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

                Box {
                    anchors.centerIn: parent
                    width: 440
                    height: field.implicitHeight + 24
                    edge: lock.status === "failed" || lock.status === "broken" ? Theme.red : Theme.blue

                    Label {
                        id: field
                        x: 14
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 28
                        elide: Text.ElideRight
                        textFormat: Text.StyledText
                        text: {
                            const key = `<font color="${Theme.dim}">password:</font> `;
                            if (lock.status === "ok") return key + "unlocked";
                            if (lock.status === "checking") return key + "checking...";
                            if (lock.status === "broken") return `<font color="${Theme.red}">auth broken: ctrl+alt+f2, run hyprlock</font>`;
                            if (lock.password === "" && lock.status === "failed")
                                return key + `<font color="${Theme.red}">wrong (${lock.attempts})</font>`;
                            return key + "*".repeat(lock.password.length) + `<font color="${Theme.blue}">_</font>`;
                        }
                    }
                }
            }
        }
    }
}
