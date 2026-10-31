import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

// session lock: the wallpaper with a single password scrap
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

    // the scrap falls away, then the session actually unlocks
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

    IpcHandler {
        target: "lock"
        function lock(): void { lock.lockNow(); }
        // locks for six seconds then unlocks itself, to look at it safely
        function preview(): void { lock.lockNow(); previewEnd.restart(); }
    }

    Timer { id: previewEnd; interval: 6000; onTriggered: lock.leave() }
    Timer { id: unlockAfterLeave; interval: 340; onTriggered: { session.locked = false; lock.status = ""; } }

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

            Collage { anchors.fill: parent }

            Item {
                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
                    if (lock.status === "ok") return;
                    shaker.shake();
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

                // a kick of rotation and sideways nudge on every key press,
                // on a wrapper so it doesn't fight the scrap's own tilt
                Item {
                    id: shaker
                    // below the wallpaper's banner rather than on top of it
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: parent.height * 0.24
                    width: field.width
                    height: field.height
                    transform: Translate { id: nudge }

                    Connections {
                        target: lock
                        function onLeaving() {
                            shakeAnim.stop();
                            fallTurn.to = (Math.random() < 0.5 ? -1 : 1) * (14 + Math.random() * 10);
                            fallAnim.restart();
                        }
                    }

                    ParallelAnimation {
                        id: fallAnim
                        NumberAnimation { id: fallTurn; target: shaker; property: "rotation"; duration: 320; easing.type: Easing.InBack }
                        NumberAnimation { target: nudge; property: "y"; to: 420; duration: 320; easing.type: Easing.InBack; easing.overshoot: 2.5 }
                        NumberAnimation { target: shaker; property: "opacity"; to: 0; duration: 320; easing.type: Easing.InCubic }
                    }

                    function shake() {
                        kickTurn.to = (Math.random() < 0.5 ? -1 : 1) * (0.8 + Math.random() * 1.2);
                        kickSlide.to = (Math.random() * 2 - 1) * 4;
                        shakeAnim.restart();
                    }

                    SequentialAnimation {
                        id: shakeAnim
                        ParallelAnimation {
                            NumberAnimation { id: kickTurn; target: shaker; property: "rotation"; duration: 40; easing.type: Easing.OutQuad }
                            NumberAnimation { id: kickSlide; target: nudge; property: "x"; duration: 40; easing.type: Easing.OutQuad }
                        }
                        ParallelAnimation {
                            NumberAnimation { target: shaker; property: "rotation"; to: 0; duration: 180; easing.type: Easing.OutBack; easing.overshoot: 3 }
                            NumberAnimation { target: nudge; property: "x"; to: 0; duration: 180; easing.type: Easing.OutBack; easing.overshoot: 3 }
                        }
                    }

                Scrap {
                    id: field
                    seed: 91 + lock.attempts
                    tilt: lock.status === "failed" ? 3 : -2
                    fill: lock.status === "ok" ? Theme.accent : Theme.panel
                    ragged: 5
                    shadow: 6
                    padX: 22
                    padY: 16
                    tape: true
                    tapeWidth: 70
                    scale: 0.8
                    Component.onCompleted: scale = 1

                    Label {
                        width: 380
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 20
                        text: lock.status === "ok" ? "unlocked"
                            : lock.status === "checking" ? "checking..."
                            : lock.password !== "" ? "•".repeat(lock.password.length)
                            : lock.status === "failed" ? `exit ${lock.attempts}: wrong password`
                            : lock.status === "broken" ? "auth broken: ctrl+alt+f2, run hyprlock"
                            : "password"
                        color: lock.status === "ok" ? Theme.ink
                            : lock.status === "failed" || lock.status === "broken" ? Theme.red
                            : lock.password !== "" || lock.status === "checking" ? Theme.accent
                            : Theme.dim
                        elide: Text.ElideMiddle
                    }
                }
                }
            }
        }
    }
}
