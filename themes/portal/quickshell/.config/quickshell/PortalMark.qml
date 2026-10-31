import QtQuick
import QtQuick.Shapes

// a blue and an orange portal side by side
Row {
    id: root

    property real size: 16

    spacing: size * 0.15

    Repeater {
        model: [Theme.blue, Theme.orange]
        Pictogram {
            required property color modelData
            path: Icons.portal
            colour: modelData
            size: root.size
        }
    }
}
