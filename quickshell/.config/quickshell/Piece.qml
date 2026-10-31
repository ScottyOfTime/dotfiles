import QtQuick

// one piece of the collage: drops in from above with a twist, `order` beats
// after the collage starts, pivoting around (cx, cy) in canvas coordinates
Item {
    id: piece

    property int order: 0
    property real cx: 0
    property real cy: 0
    property real twist: 12
    property real drop: 0

    anchors.fill: parent
    opacity: drop > 0.05 ? 1 : 0
    transform: [
        Rotation { origin.x: piece.cx; origin.y: piece.cy; angle: (1 - piece.drop) * piece.twist },
        Translate { y: (1 - piece.drop) * -900 }
    ]

    Behavior on drop { NumberAnimation { duration: 560; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
    Timer { running: true; interval: 120 + piece.order * 110; onTriggered: piece.drop = 1 }
}
