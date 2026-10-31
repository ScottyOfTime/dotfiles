import QtQuick
import QtQuick.Shapes

// a paper scrap: ragged quad with a hard shadow, rotated by `tilt`
Item {
    id: root

    property color fill: Theme.paper
    property real tilt: 0
    property int seed: 0
    property real ragged: 2.5
    property real shadow: 3
    property real padX: 12
    property real padY: 5
    property bool tape: false
    property real tapeWidth: 30
    default property alias content: inner.data
    readonly property bool hovered: mouse.containsMouse

    signal clicked()
    signal wheeled(var event)

    implicitWidth: inner.implicitWidth + padX * 2
    implicitHeight: inner.implicitHeight + padY * 2
    rotation: tilt
    Behavior on rotation { SpringAnimation { spring: 5; damping: 0.22 } }
    Behavior on scale { SpringAnimation { spring: 5; damping: 0.22 } }

    // repeatable pseudo-random offset per corner, so a scrap keeps its cut
    function j(i) {
        const x = Math.sin((seed + 1) * 12.9898 + i * 78.233) * 43758.5453;
        return (x - Math.floor(x)) * 2 * ragged - ragged;
    }

    Repeater {
        model: [{ off: root.shadow, colour: Theme.ink }, { off: 0, colour: root.fill }]
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: modelData.colour
                strokeColor: "transparent"
                startX: root.j(0) + modelData.off; startY: root.j(1) + modelData.off
                PathLine { x: root.width + root.j(2) + modelData.off; y: root.j(3) + modelData.off }
                PathLine { x: root.width + root.j(4) + modelData.off; y: root.height + root.j(5) + modelData.off }
                PathLine { x: root.j(6) + modelData.off; y: root.height + root.j(7) + modelData.off }
                PathLine { x: root.j(0) + modelData.off; y: root.j(1) + modelData.off }
            }
        }
    }

    Rectangle {
        visible: root.tape
        z: 2
        width: root.tapeWidth
        height: root.tapeWidth * 0.3
        x: root.width * 0.15
        y: -height * 0.45
        rotation: (root.j(8) > 0 ? -1 : 1) * 7
        antialiasing: true
        color: Qt.alpha(Theme.accent, 0.75)
    }

    MouseArea {
        id: mouse
        z: 3
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: root.clicked()
        onWheel: event => root.wheeled(event)
    }

    Item {
        id: inner
        x: root.padX
        y: root.padY
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
