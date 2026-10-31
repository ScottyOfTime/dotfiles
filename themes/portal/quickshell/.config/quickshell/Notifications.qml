import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

// notification server: flat boxes stacked top-right, click to dismiss
PanelWindow {
    id: popups

    visible: server.trackedNotifications.values.length > 0
    color: "transparent"
    anchors { top: true; right: true }
    margins { top: Theme.bar + 8; right: 8 }
    implicitWidth: 400
    implicitHeight: stack.implicitHeight
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications"

    NotificationServer {
        id: server
        actionsSupported: true
        imageSupported: true
        bodyMarkupSupported: false
        onNotification: n => n.tracked = true
    }

    Column {
        id: stack
        width: parent.width
        spacing: 6

        Repeater {
            model: server.trackedNotifications

            Box {
                id: note
                required property var modelData
                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                readonly property string arrived: Qt.formatDateTime(new Date(), "HH:mm")

                width: stack.width
                height: body.implicitHeight + 20
                edge: critical ? Theme.orange : Theme.blue

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

                Column {
                    id: body
                    x: 10
                    y: 10
                    width: parent.width - 20
                    spacing: 3

                    Label {
                        text: `${note.modelData.appName || "notification"} · ${note.arrived}`
                        color: note.critical ? Theme.orange : Theme.dim
                        font.pixelSize: 11
                    }
                    Label {
                        text: note.modelData.summary
                        font.bold: true
                        width: parent.width
                        elide: Text.ElideRight
                    }
                    Label {
                        visible: text !== ""
                        text: note.modelData.body
                        width: parent.width
                        wrapMode: Text.Wrap
                        maximumLineCount: 5
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                    Row {
                        visible: note.modelData.actions.length > 0
                        spacing: 10
                        topPadding: 3
                        Repeater {
                            model: note.modelData.actions
                            Label {
                                required property var modelData
                                text: `[${modelData.text}]`
                                color: hover.containsMouse ? Theme.blue : Theme.fg
                                MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true; onClicked: parent.modelData.invoke() }
                            }
                        }
                    }
                }
            }
        }
    }
}
