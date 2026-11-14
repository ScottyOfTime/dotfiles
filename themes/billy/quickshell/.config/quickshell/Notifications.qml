import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets

// notification server: each one a taped-up photocopy, stacked top-right;
// critical ones get a spray of the accent and stay until clicked
PanelWindow {
    id: popups

    visible: server.trackedNotifications.values.length > 0
    color: "transparent"
    anchors { top: true; right: true }
    margins { top: 56; right: 22 }
    implicitWidth: 430
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
        x: 14
        y: 18
        spacing: 22

        Repeater {
            model: server.trackedNotifications

            Item {
                id: note
                required property var modelData
                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                property real t: 0

                width: 390
                height: body.implicitHeight + 28
                rotation: (modelData.id % 3) - 1
                opacity: Math.ceil(t * 3) / 3
                Behavior on t { NumberAnimation { duration: 180 } }
                Component.onCompleted: t = 1

                Timer {
                    running: !note.critical && !mouse.containsMouse
                    // expireTimeout is milliseconds, as the notification spec sends it
                    interval: note.modelData.expireTimeout > 0 ? note.modelData.expireTimeout : 6000
                    onTriggered: note.modelData.expire()
                }

                Spray {
                    visible: note.critical
                    x: -14; y: -12
                    width: parent.width + 28
                    height: parent.height + 24
                    seed: note.modelData.id
                    drips: 3
                    dripWidth: 5
                }
                Rectangle { x: 5; y: 5; width: parent.width; height: parent.height; color: Qt.alpha(Theme.ink, 0.5) }
                Rectangle { anchors.fill: parent; color: Theme.paper }
                Image {
                    anchors.fill: parent
                    source: "grain.png"
                    fillMode: Image.Tile
                    opacity: 0.1
                }
                Tape { x: parent.width / 2 - 40; y: -12; width: 80; rotation: (note.modelData.id % 2 ? 4 : -4) }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: note.modelData.dismiss()
                }

                Column {
                    id: body
                    x: 16; y: 16
                    width: 358
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
                            font.pixelSize: 15
                            font.weight: Font.Black
                            width: 320
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Label {
                        visible: text !== ""
                        text: note.modelData.body
                        font.bold: false
                        width: 358
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
                            Dymo {
                                required property var modelData
                                required property int index
                                text: modelData.text
                                size: 11
                                seed: index + 50
                                tilt: index % 2 ? 1.5 : -1.5
                                onClicked: modelData.invoke()
                            }
                        }
                    }
                }
            }
        }
    }
}
