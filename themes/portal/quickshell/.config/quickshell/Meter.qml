import QtQuick

// a labelled bar: label and value over a thin track
Column {
    id: root

    property string label
    property string value
    property real fraction: 0

    spacing: 4

    Item {
        width: root.width
        height: name.height
        Caps { id: name; text: root.label }
        Label { anchors.right: parent.right; text: root.value; font.pixelSize: 11 }
    }
    Rectangle {
        width: root.width
        height: 4
        radius: 2
        color: Theme.surface

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.fraction))
            height: parent.height
            radius: 2
            color: root.fraction > 0.9 ? Theme.red : root.fraction > 0.75 ? Theme.orange : Theme.blue
            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        }
    }
}
