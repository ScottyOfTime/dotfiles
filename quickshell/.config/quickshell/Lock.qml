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

    Timer { id: previewEnd; interval: 6000; onTriggered: session.locked = false }

    PamContext {
        id: pam
        // the system's login rules, as hyprlock uses; a custom config
        // directory would make their includes resolve there and fail
        config: "login"
        onResponseRequiredChanged: if (responseRequired) respond(lock.password)
        onCompleted: result => {
            lock.password = "";
            if (result === PamResult.Success) {
                lock.status = "";
                lock.attempts = 0;
                session.locked = false;
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

            Image {
                anchors.fill: parent
                source: `file://${Quickshell.env("HOME")}/.cache/wallpaper/zine-${Theme.mode}.png`
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Item {
                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
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
                    fill: Theme.panel
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
                        text: lock.status === "checking" ? "checking..."
                            : lock.password !== "" ? "•".repeat(lock.password.length)
                            : lock.status === "failed" ? `exit ${lock.attempts}: wrong password`
                            : lock.status === "broken" ? "auth broken: ctrl+alt+f2, run hyprlock"
                            : "password"
                        color: lock.status === "failed" || lock.status === "broken" ? Theme.red
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
