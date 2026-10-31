import QtQuick
import QtQuick.Effects

// the test chamber sign: chamber number, progress and hazard pictograms
Item {
    id: sign

    property int number: 1
    property int shown: number
    property string host: ""
    property int delay: 0
    property real swing: 0
    readonly property int total: 10

    function lit(i) {
        const x = Math.sin(sign.shown * 91.7 + i * 47.3) * 43758.5453;
        return x - Math.floor(x) > 0.5;
    }

    width: 600
    height: sheet.height + 80
    opacity: Math.min(1, swing * 2.5)
    transform: Rotation {
        origin.x: sign.width / 2
        origin.y: sign.height
        axis { x: 1; y: 0; z: 0 }
        angle: (1 - sign.swing) * 85
    }
    Behavior on swing { NumberAnimation { duration: 520; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
    Timer { running: true; interval: sign.delay; onTriggered: sign.swing = 1 }

    onNumberChanged: flip.restart()

    SequentialAnimation {
        id: flip
        NumberAnimation { target: numberFlip; property: "yScale"; to: 0; duration: 90; easing.type: Easing.InCubic }
        ScriptAction { script: sign.shown = sign.number }
        NumberAnimation { target: numberFlip; property: "yScale"; to: 1; duration: 240; easing.type: Easing.OutBack; easing.overshoot: 1.6 }
    }

    RectangularShadow {
        anchors.fill: face
        radius: face.radius
        blur: 50
        offset.y: 16
        color: Qt.rgba(0, 0, 0, Theme.mode === "dark" ? 0.5 : 0.18)
    }

    Rectangle {
        id: face
        anchors.fill: parent
        radius: 24
        color: Theme.panel
        border.color: Theme.line
        border.width: 2

        Column {
            id: sheet
            x: 48
            y: 36
            width: parent.width - 96
            spacing: 18

            Item {
                width: parent.width
                height: 330
                transform: Scale { id: numberFlip; origin.y: 165 }

                Text {
                    text: String(sign.shown % 100).padStart(2, "0")
                    color: Theme.ink
                    font.family: Theme.font
                    font.weight: Font.Bold
                    font.pixelSize: 360
                    font.letterSpacing: -14
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 6
                    x: -14
                }
            }

            Text {
                text: `${String(Math.min(sign.shown, sign.total)).padStart(2, "0")}/${sign.total}`
                color: Theme.ink
                font.family: Theme.font
                font.weight: Font.Bold
                font.pixelSize: 40
            }

            Row {
                spacing: 6
                Repeater {
                    model: sign.total
                    Rectangle {
                        required property int index
                        width: (504 - 9 * 6) / 10
                        height: 14
                        radius: 2
                        color: index < sign.shown ? Theme.ink : Qt.alpha(Theme.ink, 0.12)
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }

            Rectangle { width: parent.width; height: 5; color: Theme.ink }

            Grid {
                columns: 5
                columnSpacing: 26
                rowSpacing: 26
                Repeater {
                    model: Icons.chamber
                    Pictogram {
                        required property string modelData
                        required property int index
                        path: modelData
                        size: 80
                        colour: sign.lit(index) ? Theme.ink : Qt.alpha(Theme.ink, 0.13)
                        Behavior on colour { ColorAnimation { duration: 220 } }
                    }
                }
            }

            Rectangle { width: parent.width; height: 5; color: Theme.ink }

            Row {
                spacing: 16
                PortalMark { size: 36; anchors.verticalCenter: parent.verticalCenter }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Caps { text: "aperture science"; color: Theme.ink; font.pixelSize: 20; font.letterSpacing: 3 }
                    Caps { text: `enrichment center · ${sign.host}`; font.pixelSize: 15; font.letterSpacing: 2.5 }
                }
            }
        }
    }
}
