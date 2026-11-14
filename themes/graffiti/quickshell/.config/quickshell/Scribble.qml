import QtQuick
import QtQuick.Shapes

// a hand-drawn loop round something, overshooting where it closes; `drawn`
// draws it in, in four strokes
Shape {
    id: root

    property color colour: Theme.accent
    property real drawn: 1
    property real weight: 3
    readonly property real sweep: Math.ceil(drawn * 4) / 4 * 420

    preferredRendererType: Shape.CurveRenderer
    rotation: -7
    Behavior on drawn { NumberAnimation { duration: 160 } }

    ShapePath {
        fillColor: "transparent"
        strokeColor: root.colour
        strokeWidth: root.weight
        capStyle: ShapePath.RoundCap
        // once round, then on past the start a little wider, as a hand does
        PathAngleArc {
            centerX: root.width / 2
            centerY: root.height / 2
            radiusX: root.width / 2
            radiusY: root.height / 2
            startAngle: 200
            sweepAngle: Math.min(360, root.sweep)
        }
        PathAngleArc {
            centerX: root.width / 2 + 2
            centerY: root.height / 2 - 2
            radiusX: root.width / 2 * 1.1
            radiusY: root.height / 2 * 1.15
            startAngle: 200
            sweepAngle: Math.max(0, root.sweep - 360)
        }
    }
}
