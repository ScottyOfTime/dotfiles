import QtQuick
import QtQuick.Effects

// the logo's shape filled with one colour (or `gradient`), cut out by
// `mask`; a blurred mask with a low `threshold` grows the shape, a high one
// drops its thin details
Item {
    id: root

    required property Item mask
    property color colour: Theme.ink
    property real threshold: 0.5
    property Gradient gradient: null

    Rectangle {
        id: fill
        anchors.fill: parent
        color: root.colour
        gradient: root.gradient
        visible: false
        layer.enabled: true
        // a flat colour needs no more than a few texels
        layer.textureSize: root.gradient ? Qt.size(width, height) : Qt.size(2, 2)
    }
    MultiEffect {
        anchors.fill: parent
        source: fill
        maskEnabled: true
        maskSource: root.mask
        maskThresholdMin: root.threshold
        maskSpreadAtMin: 0.01
    }
}
