import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io

// the distro's logo (os-release's LOGO) as a piece: an ink and paper cloud
// around it, a 3D block, a two-tone face, overspray, and drips off its
// lower edges, all built from the logo's own shape. `size` is the logo's;
// the piece is 1.4 times that, to leave its blur room
Item {
    id: piece

    property real size: 600
    property int order: 0
    property color face: Theme.accent
    readonly property real depth: Math.round(size * 0.035)
    readonly property string logoName: (osRelease.text().match(/^LOGO="?([^"\n]+)"?$/m) ?? [])[1] ?? "distributor-logo"

    width: size * 1.4
    height: size * 1.4

    function r(i) {
        const x = Math.sin(i * 12.9898 + 4.1) * 43758.5453;
        return x - Math.floor(x);
    }

    FileView { id: osRelease; path: "/etc/os-release"; blockLoading: true }

    Image {
        id: logo
        anchors.fill: parent
        anchors.margins: piece.size * 0.2
        source: `/usr/share/pixmaps/${piece.logoName}.svg`
        onStatusChanged: if (status === Image.Error) source = Quickshell.iconPath(piece.logoName, "distributor-logo")
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
        visible: false
        layer.enabled: true
    }

    // the masks: the logo softened and cut at half, which drops its thin
    // bits (a trademark sign), then that softened a lot for the cloud
    MultiEffect {
        id: core
        anchors.fill: parent
        source: logo
        autoPaddingEnabled: false
        blurEnabled: true
        blur: 1
        blurMax: 28
        visible: false
        layer.enabled: true
    }
    Silhouette {
        id: coreShape
        anchors.fill: parent
        mask: core
        colour: Theme.ink
        visible: false
        layer.enabled: true
    }
    MultiEffect {
        id: cloud
        anchors.fill: parent
        source: coreShape
        autoPaddingEnabled: false
        blurEnabled: true
        blur: 1
        blurMax: 64
        visible: false
        layer.enabled: true
    }

    Coat {
        order: piece.order
        Repeater {
            model: [{ t: 0.04, c: Theme.ink }, { t: 0.12, c: Theme.paper }]
            Item {
                id: layerOf
                required property var modelData
                anchors.fill: parent
                Repeater {
                    model: [0, piece.depth]
                    Silhouette {
                        required property int modelData
                        width: piece.width; height: piece.height
                        x: modelData; y: modelData
                        mask: cloud
                        threshold: layerOf.modelData.t
                        colour: layerOf.modelData.c
                    }
                }
            }
        }
    }

    Coat {
        order: piece.order + 1
        Silhouette {
            width: piece.width; height: piece.height
            x: piece.depth + 3; y: piece.depth + 3
            mask: core
            colour: Theme.ink
        }
        Repeater {
            model: piece.depth
            Silhouette {
                required property int index
                width: piece.width; height: piece.height
                x: piece.depth - index; y: piece.depth - index
                mask: core
                colour: Qt.darker(piece.face, 2.6)
            }
        }

        // drips: narrow strips of the shape stretched down from the top,
        // so each run starts at the shape's lower edge in its column,
        // whatever the logo
        Repeater {
            model: 5
            Item {
                id: drip
                required property int index
                readonly property real w: piece.size * 0.032
                readonly property real stretch: 1.1 + piece.r(index + 40) * 0.16
                x: piece.width * (0.3 + index * 0.1 + (piece.r(index + 60) - 0.5) * 0.05) - w / 2 - 4
                width: w + 8
                height: piece.height * 1.3
                clip: true

                Repeater {
                    model: [{ c: Theme.ink, inset: 0, extra: 0.012 }, { c: Qt.darker(piece.face, 1.3), inset: 4, extra: 0 }]
                    Item {
                        id: strip
                        required property var modelData
                        x: modelData.inset
                        width: drip.width - modelData.inset * 2
                        height: parent.height
                        clip: true
                        Silhouette {
                            x: -drip.x - strip.x
                            width: piece.width; height: piece.height
                            mask: core
                            colour: strip.modelData.c
                            transform: Scale { yScale: drip.stretch + strip.modelData.extra }
                        }
                    }
                }
            }
        }

        Repeater {
            model: 8
            Silhouette {
                required property int index
                readonly property real a: index * Math.PI / 4
                width: piece.width; height: piece.height
                x: Math.cos(a) * 5; y: Math.sin(a) * 5
                mask: core
                colour: Theme.ink
            }
        }
        Silhouette {
            anchors.fill: parent
            mask: core
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.lighter(piece.face, 1.3) }
                GradientStop { position: 0.55; color: piece.face }
                GradientStop { position: 0.56; color: Qt.darker(piece.face, 1.3) }
                GradientStop { position: 1; color: Qt.darker(piece.face, 1.3) }
            }
        }
    }

    Coat {
        order: piece.order + 2
        Repeater {
            model: 90
            Rectangle {
                required property int index
                readonly property real a: piece.r(index * 2) * Math.PI * 2
                readonly property real d: 0.5 + piece.r(index * 2 + 1) * 0.12
                width: 2 + piece.r(index + 300) * 5
                height: width
                radius: width / 2
                x: piece.width / 2 + Math.cos(a) * piece.width * d
                y: piece.height / 2 + Math.sin(a) * piece.height * d
                color: piece.r(index + 600) < 0.7 ? piece.face : Theme.acid
                opacity: 0.8
            }
        }
    }
}
