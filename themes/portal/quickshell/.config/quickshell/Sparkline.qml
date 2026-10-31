import QtQuick
import QtQuick.Shapes

// a line of recent values scaled to the largest, with a soft fill under it
Shape {
    id: root

    property var values: []
    property real ceiling: 0
    property color colour: Theme.blue
    readonly property real peak: Math.max(ceiling, ...values, 1)
    readonly property var points: values.map((v, i) => Qt.point(
        values.length < 2 ? 0 : i / (values.length - 1) * width,
        height - 1 - v / peak * (height - 2)))

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        strokeColor: "transparent"
        fillGradient: LinearGradient {
            x1: 0; y1: 0; x2: 0; y2: root.height
            GradientStop { position: 0; color: Qt.alpha(root.colour, 0.28) }
            GradientStop { position: 1; color: Qt.alpha(root.colour, 0) }
        }
        startX: 0; startY: root.height
        PathPolyline { path: root.points.length ? [Qt.point(0, root.height)].concat(root.points, [Qt.point(root.width, root.height)]) : [] }
    }
    ShapePath {
        strokeColor: root.colour
        strokeWidth: 1.5
        fillColor: "transparent"
        joinStyle: ShapePath.RoundJoin
        PathPolyline { path: root.points }
    }
}
