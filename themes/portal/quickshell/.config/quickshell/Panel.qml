import QtQuick
import QtQuick.Effects

// a wall panel: flat and seamed, it swings out of the wall on its bottom
// hinge when created (after `delay` ms) and whenever `out` turns true
Item {
    id: root

    property color fill: Theme.panel
    property color edge: "transparent"
    property bool edgeLeft: false
    property bool glow: false
    property real radius: 4
    property real padX: 12
    property real padY: 6
    property bool out: true
    property int delay: 0
    property bool ready: false
    readonly property bool opened: out && ready
    property real swing: opened ? 1 : 0
    default property alias content: inner.data
    readonly property bool hovered: mouse.containsMouse

    signal clicked()
    signal wheeled(var event)

    implicitWidth: inner.implicitWidth + padX * 2
    implicitHeight: inner.implicitHeight + padY * 2
    opacity: Math.min(1, swing * 2.5)
    transform: Rotation {
        origin.x: root.width / 2
        origin.y: root.height
        axis { x: 1; y: 0; z: 0 }
        angle: (1 - root.swing) * 85
    }
    Behavior on swing {
        NumberAnimation {
            duration: root.opened ? 280 : 140
            easing.type: root.opened ? Easing.OutBack : Easing.InCubic
            easing.overshoot: 1.4
        }
    }
    Timer { interval: root.delay; running: true; onTriggered: root.ready = true }

    RectangularShadow {
        anchors.fill: body
        visible: root.glow
        radius: root.radius
        blur: 22
        spread: 1
        color: Qt.alpha(root.edge, 0.6)
    }

    Rectangle {
        id: body
        anchors.fill: parent
        radius: root.radius
        color: root.fill
        border.color: Theme.line
        border.width: 1
        antialiasing: true
        Behavior on color { ColorAnimation { duration: 120 } }

        Rectangle {
            visible: root.edge.a > 0
            color: root.edge
            antialiasing: true
            x: root.edgeLeft ? 0 : root.radius
            y: root.edgeLeft ? root.radius : parent.height - height
            width: root.edgeLeft ? 3 : parent.width - root.radius * 2
            height: root.edgeLeft ? parent.height - root.radius * 2 : 3
        }
    }

    // below the content, so buttons inside a panel get their own clicks
    MouseArea {
        id: mouse
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
        width: childrenRect.width
        height: childrenRect.height
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
