import QtQuick

// a torn strip of duct tape
Rectangle {
    width: 90
    height: 26
    color: Qt.alpha(Theme.dim, 0.85)
    antialiasing: true

    Repeater {
        model: 2
        Rectangle {
            required property int index
            x: index ? parent.width - 2 : -2
            width: 4
            height: parent.height
            color: parent.color
            transform: Scale { yScale: 0.82; origin.y: parent.height / 2 }
        }
    }
}
