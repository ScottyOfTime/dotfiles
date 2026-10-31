import QtQuick
import QtQuick.Shapes

// a sign pictogram from Icons, drawn on a 24px grid and scaled to `size`
Item {
    id: root

    property string path
    property color colour: Theme.ink
    property real size: 24

    implicitWidth: size
    implicitHeight: size

    Shape {
        width: 24
        height: 24
        scale: root.size / 24
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: root.colour
            strokeColor: "transparent"
            fillRule: ShapePath.OddEvenFill
            PathSvg { path: root.path }
        }
    }
}
