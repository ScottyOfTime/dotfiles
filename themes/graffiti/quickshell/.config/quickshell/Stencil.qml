import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

// a stencilled star, centred on (cx, cy), soft-edged with overspray round it
Item {
    id: stencil

    property real cx
    property real cy
    property real outer: 90
    property color colour: Theme.acid

    function r(i) {
        const x = Math.sin(i * 12.9898 + 4.1) * 43758.5453;
        return x - Math.floor(x);
    }
    function star(c, outer, inner) {
        const pts = [];
        for (let i = 0; i < 10; i++) {
            const a = (-90 + i * 36) * Math.PI / 180;
            const rad = i % 2 ? inner : outer;
            pts.push(`${c + rad * Math.cos(a)} ${c + rad * Math.sin(a)}`);
        }
        return "M " + pts.join(" L ") + " Z";
    }

    x: cx - width / 2
    y: cy - height / 2
    width: (outer + 30) * 2
    height: width

    Shape {
        id: cut
        anchors.fill: parent
        visible: false
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: stencil.colour
            strokeColor: "transparent"
            PathSvg { path: stencil.star(stencil.width / 2, stencil.outer, stencil.outer * 0.42) }
        }
    }
    MultiEffect { source: cut; anchors.fill: cut; blurEnabled: true; blur: 0.12; blurMax: 16 }

    Repeater {
        model: 30
        Rectangle {
            required property int index
            readonly property real a: stencil.r(index * 2 + stencil.cx) * Math.PI * 2
            readonly property real d: stencil.outer * (0.9 + stencil.r(index * 2 + 1 + stencil.cy) * 0.5)
            x: stencil.width / 2 + Math.cos(a) * d
            y: stencil.height / 2 + Math.sin(a) * d
            width: 2 + stencil.r(index + stencil.cx) * 4
            height: width
            radius: width / 2
            color: stencil.colour
            opacity: 0.7
        }
    }
}
