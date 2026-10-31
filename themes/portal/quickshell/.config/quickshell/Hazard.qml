import QtQuick

// diagonal warning stripes
Item {
    id: root

    property color colour: Theme.ink
    property color base: Theme.orange
    property real stripe: 10

    clip: true

    Rectangle { anchors.fill: parent; color: root.base }

    Repeater {
        model: Math.ceil((root.width + root.height) / (root.stripe * 2)) + 1
        Rectangle {
            required property int index
            x: index * root.stripe * 2 - root.height
            y: -root.height
            width: root.stripe
            height: root.height * 3
            rotation: 45
            color: root.colour
            antialiasing: true
        }
    }
}
