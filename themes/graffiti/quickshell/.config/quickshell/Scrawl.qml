import QtQuick
import QtQuick.Shapes

// a stroke of marker or paint: `path` is SVG path data
Shape {
    id: scrawl

    property alias path: svg.path
    property color colour: Theme.fg
    property real weight: 6

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: "transparent"
        strokeColor: scrawl.colour
        strokeWidth: scrawl.weight
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
        PathSvg { id: svg }
    }
}
