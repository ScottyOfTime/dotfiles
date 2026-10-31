import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

// notification server: panels stacked top-right
PanelWindow {
    id: popups

    visible: server.trackedNotifications.values.length > 0
    color: "transparent"
    anchors { top: true; right: true }
    margins { top: 56; right: 8 }
    implicitWidth: 440
    implicitHeight: stack.implicitHeight + 40
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
        x: 20
        y: 14
        spacing: 10

        move: Transition { NumberAnimation { property: "y"; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }

        Repeater {
            model: server.trackedNotifications

            Panel {
                id: note
                required property var modelData
                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                readonly property color tone: critical ? Theme.orange : Theme.blue
                readonly property string arrived: Qt.formatDateTime(new Date(), "HH:mm")

                padX: 16
                padY: 12
                edge: tone
                edgeLeft: true
                glow: critical
                fill: hovered ? Theme.glassHover : Theme.glass
                onClicked: modelData.dismiss()

                Timer {
                    running: !note.critical && !note.hovered
                    // expireTimeout is milliseconds, as the notification spec sends it
                    interval: note.modelData.expireTimeout > 0 ? note.modelData.expireTimeout : 6000
                    onTriggered: note.modelData.expire()
                }

                Column {
                    width: 370
                    spacing: 6

                    Hazard {
                        visible: note.critical
                        width: parent.width
                        height: 8
                    }

                    Readout {
                        width: parent.width
                        title: note.modelData.appName || "notification"
                        tone: note.tone
                        meta: note.arrived
                    }

                    Row {
                        spacing: 12

                        Image {
                            visible: note.modelData.image !== ""
                            source: note.modelData.image
                            width: visible ? 44 : 0
                            height: 44
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            mipmap: true
                        }

                        Column {
                            width: 370 - (note.modelData.image !== "" ? 56 : 0)
                            spacing: 4

                            Label {
                                text: note.modelData.summary || note.modelData.appName
                                font.pixelSize: 14
                                width: parent.width
                                elide: Text.ElideRight
                            }
                            Label {
                                visible: text !== ""
                                text: note.modelData.body
                                color: Theme.dim
                                font.bold: false
                                width: parent.width
                                wrapMode: Text.Wrap
                                maximumLineCount: 5
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                            }
                        }
                    }

                    Row {
                        visible: note.modelData.actions.length > 0
                        spacing: 6
                        topPadding: 4

                        Repeater {
                            model: note.modelData.actions
                            Panel {
                                id: action
                                required property var modelData
                                padX: 10
                                padY: 4
                                fill: hovered ? Theme.blue : Theme.bg
                                onClicked: modelData.invoke()
                                Caps { text: modelData.text; color: action.hovered ? Theme.onLit : Theme.fg }
                            }
                        }
                    }
                }
            }
        }
    }
}
