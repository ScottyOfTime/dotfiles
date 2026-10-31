import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets

// notification server: each one a scrap, stacked top-right
PanelWindow {
    id: popups

    visible: server.trackedNotifications.values.length > 0
    color: "transparent"
    anchors { top: true; right: true }
    margins { top: 60; right: 22 }
    implicitWidth: 420
    implicitHeight: stack.implicitHeight + 30
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
        x: 10
        y: 10
        spacing: 16

        move: Transition { NumberAnimation { property: "y"; duration: 200; easing.type: Easing.OutBack } }

        Repeater {
            model: server.trackedNotifications

            Scrap {
                id: note
                required property var modelData
                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                readonly property color text: critical ? Theme.ink : Theme.fg

                seed: modelData.id
                tilt: (modelData.id % 2 ? 1.5 : -1.5) + (hovered ? 0 : (modelData.id % 3) - 1)
                fill: critical ? Theme.accent : Theme.panel
                padX: 16
                padY: 12
                tape: critical
                scale: 0.6
                Component.onCompleted: scale = 1
                onClicked: modelData.dismiss()

                Timer {
                    running: !note.critical && !note.hovered
                    interval: note.modelData.expireTimeout > 0 ? note.modelData.expireTimeout * 1000 : 6000
                    onTriggered: note.modelData.expire()
                }

                Column {
                    width: 360
                    spacing: 6

                    Row {
                        spacing: 10
                        IconImage {
                            visible: source != ""
                            source: note.modelData.image || (note.modelData.appIcon
                                ? Quickshell.iconPath(note.modelData.appIcon, true) : "")
                            implicitSize: 22
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Label {
                            text: note.modelData.summary || note.modelData.appName
                            color: note.text
                            font.pixelSize: 14
                            width: 320
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Label {
                        visible: text !== ""
                        text: note.modelData.body
                        color: note.text
                        font.bold: false
                        width: 360
                        wrapMode: Text.Wrap
                        maximumLineCount: 5
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }

                    Row {
                        visible: note.modelData.actions.length > 0
                        spacing: 10
                        topPadding: 4

                        Repeater {
                            model: note.modelData.actions
                            Scrap {
                                required property var modelData
                                required property int index
                                seed: index + 50
                                tilt: index % 2 ? 2 : -2
                                padX: 10
                                padY: 3
                                onClicked: modelData.invoke()
                                Label { text: modelData.text; font.pixelSize: 12 }
                            }
                        }
                    }
                }
            }
        }
    }
}
