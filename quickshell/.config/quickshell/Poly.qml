import QtQuick
import QtQuick.Shapes

// a filled polygon with an ink outline and a hard ink shadow
Item {
    id: poly

    required property var points
    property color fill: Theme.panel
    property real shadow: 16
    property real outline: 6

    anchors.fill: parent

    Repeater {
        model: [{ off: poly.shadow, colour: Theme.ink, stroke: 0 }, { off: 0, colour: poly.fill, stroke: poly.outline }]
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: modelData.colour
                strokeColor: modelData.stroke > 0 ? Theme.ink : "transparent"
                strokeWidth: modelData.stroke
                joinStyle: ShapePath.MiterJoin
                startX: poly.points[0][0] + modelData.off
                startY: poly.points[0][1] + modelData.off
                PathPolyline {
                    path: poly.points.concat([poly.points[0]]).map(p => Qt.point(p[0] + modelData.off, p[1] + modelData.off))
                }
            }
        }
    }
}
