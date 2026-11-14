import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

// session lock: the wall, with the password punched out on label tape
Scope {
    id: lock

    property string password: ""
    property string status: ""
    property int attempts: 0

    function lockNow() {
        password = "";
        status = "";
        session.locked = true;
        marker.setText("locked");
    }

    // the tape peels off, then the session actually unlocks
    function leave() {
        status = "ok";
        password = "";
        leaving();
        unlockAfterLeave.restart();
    }

    signal leaving()

    function submit() {
        if (password === "" || pam.active) return;
        status = "checking";
        pam.start();
    }

    // marks the session locked across a qs crash (monitors hot-unplugging on
    // DPMS off kill it), so the restarted qs (hypr-theme/start) relocks at once
    FileView {
        id: marker
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/qs-locked"
        blockLoading: true
        printErrors: false
    }
    Component.onCompleted: if (marker.text().trim() === "locked") lockNow()

    IpcHandler {
        target: "lock"
        function lock(): void { lock.lockNow(); }
        // locks for six seconds then unlocks itself, to look at it safely
        function preview(): void { lock.lockNow(); previewEnd.restart(); }
    }

    Timer { id: previewEnd; interval: 6000; onTriggered: lock.leave() }
    Timer { id: unlockAfterLeave; interval: 300; onTriggered: { session.locked = false; marker.setText("unlocked"); lock.status = ""; } }

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

            Wall { anchors.fill: parent }

            Item {
                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
                    if (lock.status === "ok") return;
                    punch.restart();
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

                Column {
                    id: strip
                    // under the logo rather than over it
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: parent.height * 0.08
                    spacing: 12
                    property real peel: 0
                    rotation: peel * 9
                    transform: Translate { id: kick; y: strip.peel * 260 }
                    opacity: 1 - Math.floor(peel * 3) / 3

                    Connections {
                        target: lock
                        function onLeaving() { peelAnim.restart(); }
                    }
                    NumberAnimation { id: peelAnim; target: strip; property: "peel"; from: 0; to: 1; duration: 280 }

                    // every key is a clack of the label maker: a 3px jolt
                    SequentialAnimation {
                        id: punch
                        PropertyAction { target: kick; property: "x"; value: 3 }
                        PauseAnimation { duration: 50 }
                        PropertyAction { target: kick; property: "x"; value: 0 }
                    }

                    Dymo {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: lock.status === "failed" ? `wrong x${lock.attempts}`
                            : lock.status === "broken" ? "auth broken: ctrl+alt+f2, run hyprlock"
                            : lock.status === "checking" ? "checking" : "password"
                        size: 15
                        seed: 90
                        tape: lock.status === "failed" || lock.status === "broken" ? Theme.red : Theme.ink
                        letters: Theme.paper
                    }

                    Dymo {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: lock.status === "ok" ? "come in" : lock.password !== "" ? "*".repeat(lock.password.length) : "_"
                        maxWidth: 700
                        size: 30
                        seed: 91 + lock.attempts
                        hot: lock.status === "ok" || lock.status === "checking"
                        tape: Theme.ink
                        letters: lock.status === "ok" ? Theme.accent : Theme.paper
                    }
                }
            }
        }
    }
}
