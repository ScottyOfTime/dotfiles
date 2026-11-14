import QtQuick
import QtQuick.Shapes

// one letter of a piece. `paths` are polygons on a 220-high grid (the
// outline, then any holes), leant forward: a paper cloud around it, a 3D
// block behind, a two-tone face, a shine and fat drips off the bottom
Item {
    id: g

    required property var paths
    property var drips: []
    property real lean: 0.16
    property int depth: 16
    property color face: Theme.accent

    readonly property var pts: paths.map(p => p.map(q => [q[0] + (220 - q[1]) * lean, q[1]]))

    function svg(list, d) {
        return list.map(p => "M " + p.map(q => (q[0] + d) + " " + (q[1] + d)).join(" L ") + " Z").join(" ");
    }

    Repeater {
        model: [{ w: 46, c: Theme.ink }, { w: 36, c: Theme.paper }]
        Shape {
            required property var modelData
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: modelData.c
                strokeColor: modelData.c
                strokeWidth: modelData.w
                joinStyle: ShapePath.RoundJoin
                PathSvg { path: g.svg([g.pts[0]], 0) + " " + g.svg([g.pts[0]], g.depth) }
            }
        }
    }

    Repeater {
        model: g.depth / 2
        Shape {
            required property int index
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: Qt.darker(g.face, 2.6)
                fillRule: ShapePath.OddEvenFill
                strokeColor: index === 0 ? Theme.ink : "transparent"
                strokeWidth: 4
                joinStyle: ShapePath.MiterJoin
                PathSvg { path: g.svg(g.pts, g.depth - index * 2) }
            }
        }
    }

    Repeater {
        model: g.drips
        Item {
            required property var modelData
            x: modelData[0] - 9
            y: 196
            width: 18
            height: modelData[1]
            Rectangle { x: -3; width: 24; height: parent.height + 3; radius: 12; color: Theme.ink }
            Rectangle { x: -6; y: parent.height - 24; width: 30; height: 30; radius: 15; color: Theme.ink }
            Rectangle { width: 18; height: parent.height; radius: 9; color: Qt.darker(g.face, 1.3) }
            Rectangle { x: -3; y: parent.height - 21; width: 24; height: 24; radius: 12; color: Qt.darker(g.face, 1.3) }
            Rectangle { x: 4; y: 14; width: 4; height: parent.height - 26; radius: 2; color: Qt.alpha(Theme.paper, 0.5) }
        }
    }

    Shape {
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillRule: ShapePath.OddEvenFill
            fillGradient: LinearGradient {
                x1: 0; y1: -40; x2: 0; y2: 250
                GradientStop { position: 0; color: Qt.lighter(g.face, 1.3) }
                GradientStop { position: 0.52; color: g.face }
                GradientStop { position: 0.53; color: Qt.darker(g.face, 1.3) }
                GradientStop { position: 1; color: Qt.darker(g.face, 1.3) }
            }
            strokeColor: Theme.ink
            strokeWidth: 6
            joinStyle: ShapePath.MiterJoin
            PathSvg { path: g.svg(g.pts, 0) }
        }
    }

    Rectangle {
        x: g.pts[0][0][0] + 12; y: g.pts[0][0][1] + 14
        width: 26; height: 6
        rotation: -8
        color: Theme.paper
        antialiasing: true
    }
}
