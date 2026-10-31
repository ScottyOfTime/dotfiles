import QtQuick
import QtQuick.Shapes

// a round gauge with the value in the middle
Item {
    id: root

    property real fraction: 0
    property string text
    property real size: 64

    width: size
    height: size

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: Theme.surface
            strokeWidth: 5
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: root.size / 2; centerY: root.size / 2; radiusX: root.size / 2 - 4; radiusY: root.size / 2 - 4; startAngle: 0; sweepAngle: 360 }
        }
        ShapePath {
            strokeColor: root.fraction > 0.9 ? Theme.red : root.fraction > 0.75 ? Theme.orange : Theme.blue
            strokeWidth: 5
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.size / 2; centerY: root.size / 2
                radiusX: root.size / 2 - 4; radiusY: root.size / 2 - 4
                startAngle: -90
                sweepAngle: Math.max(1, 360 * Math.min(1, root.fraction))
                Behavior on sweepAngle { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            }
        }
    }

    Label {
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: 14
    }
}
