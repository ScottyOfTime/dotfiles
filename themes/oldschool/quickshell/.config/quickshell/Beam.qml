import QtQuick

// the crt's beam, centred in its parent.
// across and down are fractions of the parent (0 is a dot), glow fades it;
// all three draw in a few hard steps rather than smoothly
Item {
    id: beam

    property real across: 0
    property real down: 0
    property real glow: 1

    function steps(value, count) {
        return Math.floor(value * count) / count;
    }

    readonly property int w: Math.max(6, Math.round(parent.width * steps(across, 4)))
    readonly property int h: Math.max(4, Math.round(parent.height * steps(down, 5)))

    anchors.fill: parent
    opacity: Math.ceil(glow * 3) / 3

    Rectangle {
        anchors.centerIn: parent
        width: beam.w
        height: beam.h
        color: Theme.bright
    }
}
