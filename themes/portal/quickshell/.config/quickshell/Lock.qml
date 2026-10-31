import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

// session lock: the chamber wall with a single test subject verification panel
Scope {
    id: lock

    property string password: ""
    property string status: ""
    property int attempts: 0
    property bool gone: false

    function lockNow() {
        password = "";
        status = "";
        gone = false;
        session.locked = true;
    }

    // the panel says so, swings back into the wall, then the session unlocks
    function leave() {
        status = "ok";
        password = "";
        swingAway.restart();
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
    Timer { id: swingAway; interval: 450; onTriggered: lock.gone = true }
    Timer { id: unlockAfterLeave; interval: 650; onTriggered: { session.locked = false; lock.status = ""; } }

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

            Chamber {
                anchors.fill: parent
                number: Hyprland.monitorFor(surface.screen)?.activeWorkspace?.id ?? 1
            }

            Item {
                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
                    if (lock.status === "ok") return;
                    jolt.restart();
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

                // jolts on a wrapper, so it doesn't replace the panel's own swing
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: parent.height * 0.3
                    width: field.width
                    height: field.height
                    transform: Translate { id: nudge }

                    SequentialAnimation {
                        id: jolt
                        NumberAnimation { target: nudge; property: "y"; to: -3; duration: 35; easing.type: Easing.OutQuad }
                        NumberAnimation { target: nudge; property: "y"; to: 0; duration: 160; easing.type: Easing.OutBack; easing.overshoot: 3 }
                    }

                    Panel {
                        id: field
                        readonly property color tone: lock.status === "failed" || lock.status === "broken" ? Theme.red
                            : lock.status === "ok" ? Theme.blue
                            : lock.password !== "" || lock.status === "checking" ? Theme.blue : Theme.orange

                        out: !lock.gone
                        delay: 300
                        radius: 6
                        padX: 22
                        padY: 16
                        edge: tone
                        glow: lock.password !== "" || lock.status !== ""

                        Column {
                            width: 480
                            spacing: 10

                            Row {
                                width: parent.width
                                Caps {
                                    text: "test subject verification"
                                    width: parent.width - count.width
                                }
                                Caps {
                                    id: count
                                    text: lock.attempts > 0 ? `attempt ${lock.attempts + 1}` : ""
                                    color: Theme.red
                                }
                            }

                            Label {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: 18
                                text: lock.status === "ok" ? "verified. testing will now resume"
                                    : lock.status === "checking" ? "verifying test subject..."
                                    : lock.password !== "" ? "•".repeat(lock.password.length)
                                    : lock.status === "failed" ? "incorrect. this will be noted in your file"
                                    : lock.status === "broken" ? "auth broken: ctrl+alt+f2, run hyprlock"
                                    : "please enter your password to resume testing"
                                color: lock.status === "failed" || lock.status === "broken" ? Theme.red
                                    : lock.password !== "" || lock.status === "checking" || lock.status === "ok" ? Theme.blue
                                    : Theme.dim
                                elide: Text.ElideMiddle
                            }
                        }
                    }
                }
            }
        }
    }
}
