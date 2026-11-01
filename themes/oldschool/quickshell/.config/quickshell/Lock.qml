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
    signal leaving()
    // locking cuts straight to black, then the logo and prompt are drawn in
    // like a slow scan: rows top to bottom, each left to right
    property real drawn: 1
    readonly property var primary: Quickshell.screens.find(s => s.x === 0 && s.y === 0)
        ?? Quickshell.screens[0]

    function lockNow() {
        password = "";
        status = "";
        drawn = 0;
        session.locked = true;
        scan.restart();
    }

    NumberAnimation { id: scan; target: lock; property: "drawn"; from: 0; to: 1; duration: 380 }

    function leave() {
        leaving();
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

                Blink { id: blink; running: content.visible && lock.drawn >= 1 }

                Column {
                    id: content
                    visible: surface.screen === lock.primary
                    anchors.centerIn: parent
                    spacing: 40

                    Label {
                        id: art
                        anchors.horizontalCenter: parent.horizontalCenter
                        // 18pt is 24px, 32 physical at 1.33x (Label sizes in points)
                        font.pointSize: 18
                        lineHeight: 1.0
                        textFormat: Text.PlainText
                        text: Tty.logo
                    }

                    // separate labels, so the user name doesn't re-centre as the
                    // password grows; x is rounded so the pixel font stays sharp
                    Column {
                        id: prompt
                        width: art.width
                        spacing: 6

                        Label {
                            x: Math.round((prompt.width - width) / 2)
                            textFormat: Text.PlainText
                            text: Tty.user
                        }
                        // only the stars are centred; the block trails them, or
                        // sits centred itself while nothing is typed
                        Item {
                            width: prompt.width
                            height: stars.height

                            Label {
                                id: stars
                                x: Math.round((parent.width - width) / 2)
                                textFormat: Text.PlainText
                                text: lock.status === "broken" ? "auth broken: ctrl+alt+f2, run hyprlock"
                                    : "*".repeat(lock.password.length)
                                color: lock.status === "broken" ? Theme.red : Theme.fg
                            }
                            Label {
                                visible: blink.on && lock.status !== "broken"
                                    && lock.status !== "checking" && lock.status !== "ok"
                                x: lock.password === "" ? Math.round((parent.width - width) / 2) : stars.x + stars.width
                                textFormat: Text.PlainText
                                text: "█"
                            }
                        }
                        Label {
                            visible: lock.status === "failed" && lock.password === ""
                            x: Math.round((prompt.width - width) / 2)
                            textFormat: Text.PlainText
                            text: `Login incorrect (${lock.attempts})`
                            color: Theme.red
                        }
                    }
                }

                // the undrawn part: everything below the row being drawn,
                // and that row to the right of the beam
                Item {
                    id: undrawn
                    readonly property int row: 4
                    readonly property real at: lock.drawn * Math.ceil(content.height / row)
                    readonly property int done: Math.floor(at)
                    visible: content.visible && lock.drawn < 1
                    x: content.x
                    y: content.y
                    width: content.width
                    height: content.height

                    Rectangle {
                        y: (undrawn.done + 1) * undrawn.row
                        width: parent.width
                        height: Math.max(0, parent.height - y)
                        color: Theme.bg
                    }
                    Rectangle {
                        x: Math.round((undrawn.at - undrawn.done) * parent.width)
                        y: undrawn.done * undrawn.row
                        width: parent.width - x
                        height: undrawn.row
                        color: Theme.bg
                    }
                }
            }
        }
    }
}
