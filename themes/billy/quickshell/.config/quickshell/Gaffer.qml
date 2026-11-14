import QtQuick
import QtQuick.Shapes

// a strip of black gaffer tape: torn ends, a cloth weave and a dull sheen
Item {
    id: root

    property int seed: 0
    property real tear: 7
    default property alias content: inner.data

    function r(i) {
        const x = Math.sin((seed + 1) * 12.9898 + i * 78.233) * 43758.5453;
        return x - Math.floor(x);
    }
    function torn(x0, dir) {
        const steps = Math.max(2, Math.round(height / 5));
        let p = "";
        for (let i = 0; i <= steps; i++)
            p += ` L ${x0 + dir * r(i + (dir > 0 ? 0 : 50)) * tear} ${height * i / steps}`;
        return p;
    }

    Shape {
        id: cloth
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: Theme.ink
            strokeColor: "transparent"
            PathSvg {
                path: `M ${root.tear} 0 L ${root.width - root.tear} 0`
                    + root.torn(root.width - root.tear, 1).replace(/ L [^L]*$/, "")
                    + ` L ${root.width - root.tear} ${root.height} L ${root.tear} ${root.height}`
                    + root.torn(root.tear, -1).split(" L ").slice(1).reverse().map(s => " L " + s).join("")
                    + " Z"
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: root.tear
        anchors.rightMargin: root.tear
        clip: true
        Repeater {
            model: Math.max(0, Math.floor(root.height / 3))
            Rectangle {
                required property int index
                y: index * 3 + 1
                width: parent.width
                height: 1
                color: Qt.alpha(Theme.paper, 0.035)
            }
        }
        Rectangle { width: parent.width; height: 2; color: Qt.alpha(Theme.paper, 0.08) }
    }

    Item {
        id: inner
        anchors.fill: parent
    }
}
