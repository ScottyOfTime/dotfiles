import QtQuick

// sprayed on in three hard coats rather than faded in, `order` beats after
// it's created
Item {
    id: coat

    property int order: 0
    property real t: 0

    anchors.fill: parent
    opacity: Math.ceil(t * 3) / 3
    Behavior on t { NumberAnimation { duration: 240 } }
    Timer { running: true; interval: 150 + coat.order * 140; onTriggered: coat.t = 1 }
}
