import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

// notification server: one log line each under the bar, top-right; click
// a line to dismiss it
PanelWindow {
    id: popups

    visible: server.trackedNotifications.values.length > 0
    color: "transparent"
    anchors { top: true; right: true }
    margins { top: Theme.px(Theme.bar, devicePixelRatio) }
    implicitWidth: 620
    implicitHeight: stack.implicitHeight
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications"

    NotificationServer {
        id: server
        actionsSupported: true
        bodyMarkupSupported: false
        onNotification: n => n.tracked = true
    }

    Column {
        id: stack
        width: parent.width

        Repeater {
            model: server.trackedNotifications

            Rectangle {
                id: note
                required property var modelData
                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                readonly property string arrived: Qt.formatDateTime(new Date(), "HH:mm")

                anchors.right: parent.right
                width: stack.width
                height: Theme.px(26, popups.devicePixelRatio)
                color: area.containsMouse ? Theme.surface : Theme.panel

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Theme.px(1, popups.devicePixelRatio)
                    color: Theme.line
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: note.modelData.dismiss()
                }

                Timer {
                    running: !note.critical && !area.containsMouse
                    // expireTimeout is milliseconds, as the notification spec sends it
                    interval: note.modelData.expireTimeout > 0 ? note.modelData.expireTimeout : 6000
                    onTriggered: note.modelData.expire()
                }

                Label {
                    id: line
                    x: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: note.width - actions.implicitWidth - 24
                    elide: Text.ElideRight
                    textFormat: Text.StyledText
                    readonly property string body: note.modelData.body.replace(/\s+/g, " ").trim()
                    function plain(s) { return s.replace(/&/g, "&amp;").replace(/</g, "&lt;"); }
                    text: `<font color="${note.critical ? Theme.red : Theme.dim}">[${note.arrived}] ${line.plain(note.modelData.appName || "notify")}:</font> `
                        + `<font color="${note.critical ? Theme.red : Theme.fg}">${line.plain(note.modelData.summary)}</font>`
                        + (body ? `<font color="${Theme.dim}"> - ${line.plain(body)}</font>` : "")
                }

                Row {
                    id: actions
                    anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    spacing: 8
                    Repeater {
                        model: note.modelData.actions
                        Label {
                            required property var modelData
                            text: `[${modelData.text}]`
                            color: hover.containsMouse ? Theme.bright : Theme.fg
                            MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true; onClicked: parent.modelData.invoke() }
                        }
                    }
                }
            }
        }
    }
}
