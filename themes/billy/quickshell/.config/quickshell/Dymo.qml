import QtQuick
import QtQuick.Shapes

// a strip of label-maker tape: raised capitals and scissor-cut ends; `hot`
// sprays a splat of the accent behind it
Item {
    id: root

    property string text: ""
    property color tape: Theme.ink
    property color letters: Theme.paper
    property real size: 13
    property real maxWidth: 10000
    property real tilt: 0
    property int seed: 0
    property bool hot: false
    property real heat: hot ? 1 : 0
    readonly property bool hovered: mouse.containsMouse
    readonly property real cutL: root.r(1) * size * 0.5
    readonly property real cutR: root.r(2) * size * 0.5

    signal clicked()
    signal wheeled(var event)

    function r(i) {
        const x = Math.sin((seed + 1) * 12.9898 + i * 78.233) * 43758.5453;
        return x - Math.floor(x);
    }

    implicitWidth: label.width + size * 1.8
    implicitHeight: Math.round(size * 2.1)
    rotation: tilt
    Behavior on heat { NumberAnimation { duration: 200 } }

    Spray {
        visible: root.heat > 0
        opacity: Math.ceil(root.heat * 3) / 3
        x: -root.size; y: -root.size * 0.7
        width: root.width + root.size * 2
        height: root.height + root.size * 1.4
        seed: root.seed
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: root.tape
            strokeColor: "transparent"
            startX: root.r(3) > 0.5 ? root.cutL : 0; startY: 0
            PathLine { x: root.r(4) > 0.5 ? root.width - root.cutR : root.width; y: 0 }
            PathLine { x: root.r(4) > 0.5 ? root.width : root.width - root.cutR; y: root.height }
            PathLine { x: root.r(3) > 0.5 ? 0 : root.cutL; y: root.height }
            PathLine { x: root.r(3) > 0.5 ? root.cutL : 0; y: 0 }
        }
    }

    // the plastic's sheen
    Rectangle {
        x: root.size * 0.6; y: 2
        width: root.width - root.size * 1.2; height: 1.5
        color: Qt.alpha(Theme.paper, 0.15)
    }

    Text {
        id: label
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: font.letterSpacing / 2
        width: Math.min(implicitWidth, root.maxWidth)
        elide: Text.ElideRight
        text: root.text
        color: root.letters
        style: Text.Raised
        styleColor: Qt.alpha(Theme.ink, 0.55)
        font.family: Theme.font
        font.weight: Font.ExtraBold
        font.pixelSize: root.size
        font.capitalization: Font.AllUppercase
        font.letterSpacing: root.size * 0.18
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        onWheel: event => root.wheeled(event)
    }
}
