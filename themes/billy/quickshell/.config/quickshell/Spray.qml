import QtQuick
import QtQuick.Effects

// a patch of spray paint: soft edges, overspray specks and drips
Item {
    id: root

    property color colour: Theme.accent
    property int seed: 0
    property int drips: 2
    property real dripWidth: 3.5
    property real soft: 0.5

    function r(i) {
        const x = Math.sin((seed + 1) * 12.9898 + i * 78.233) * 43758.5453;
        return x - Math.floor(x);
    }

    // a few overlapping bursts, softened together, so no two are the same
    Item {
        id: blobs
        anchors.fill: parent
        visible: false
        layer.enabled: true
        Repeater {
            model: 4
            Rectangle {
                required property int index
                readonly property real sx: 0.55 + root.r(index + 10) * 0.45
                readonly property real sy: 0.6 + root.r(index + 20) * 0.4
                width: root.width * sx
                height: root.height * sy
                x: (root.width - width) * root.r(index + 30)
                y: (root.height - height) * root.r(index + 34)
                rotation: (root.r(index + 38) - 0.5) * 16
                radius: Math.min(width, height) / 2
                antialiasing: true
                color: root.colour
            }
        }
    }
    MultiEffect {
        source: blobs
        anchors.fill: blobs
        blurEnabled: true
        blur: root.soft
        blurMax: 12
    }

    Repeater {
        model: 18
        Rectangle {
            required property int index
            readonly property real a: root.r(index * 3) * Math.PI * 2
            readonly property real d: 0.5 + root.r(index * 3 + 1) * 0.22
            width: 1.5 + root.r(index * 3 + 2) * 2.5
            height: width
            radius: width / 2
            x: root.width / 2 + Math.cos(a) * root.width * d - width / 2
            y: root.height / 2 + Math.sin(a) * root.height * d - height / 2
            color: root.colour
        }
    }

    Repeater {
        model: root.drips
        Item {
            required property int index
            x: root.width * (0.25 + 0.5 * root.r(40 + index))
            y: root.height * 0.8
            width: root.dripWidth
            height: root.dripWidth * (2 + root.r(50 + index) * 5)
            Rectangle { width: parent.width; height: parent.height; radius: width / 2; color: root.colour }
            Rectangle {
                width: parent.width * 1.6; height: width; radius: width / 2
                x: -parent.width * 0.3; y: parent.height - width * 0.8
                color: root.colour
            }
        }
    }
}
