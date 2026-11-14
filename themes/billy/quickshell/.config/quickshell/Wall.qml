import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io

// the wallpaper: the distro's logo (os-release's LOGO) sprayed big on a bare
// wall, piece-style: an ink and paper cloud around it, a 3D block, a
// two-tone face, overspray, and drips off its lower edges. Sprayed on in
// coats when it's created.
Rectangle {
    id: wall

    color: Theme.bg

    readonly property string logoName: (osRelease.text().match(/^LOGO="?([^"\n]+)"?$/m) ?? [])[1] ?? "distributor-logo"
    readonly property real size: Math.round(height * 0.52)
    readonly property real depth: Math.round(size * 0.035)

    function r(i) {
        const x = Math.sin(i * 12.9898 + 4.1) * 43758.5453;
        return x - Math.floor(x);
    }

    FileView { id: osRelease; path: "/etc/os-release"; blockLoading: true }

    Item {
        id: piece
        width: wall.size * 1.4
        height: wall.size * 1.4
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -wall.height * 0.02
        rotation: -4

        Image {
            id: logo
            anchors.fill: parent
            anchors.margins: wall.size * 0.2
            source: `/usr/share/pixmaps/${wall.logoName}.svg`
            onStatusChanged: if (status === Image.Error) source = Quickshell.iconPath(wall.logoName, "distributor-logo")
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
            order: 1
            Repeater {
                model: [{ t: 0.04, c: Theme.ink }, { t: 0.12, c: Theme.paper }]
                Item {
                    id: layerOf
                    required property var modelData
                    anchors.fill: parent
                    Repeater {
                        model: [0, wall.depth]
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
            order: 2
            Silhouette {
                width: piece.width; height: piece.height
                x: wall.depth + 3; y: wall.depth + 3
                mask: core
                colour: Theme.ink
            }
            Repeater {
                model: wall.depth
                Silhouette {
                    required property int index
                    width: piece.width; height: piece.height
                    x: wall.depth - index; y: wall.depth - index
                    mask: core
                    colour: Qt.darker(Theme.accent, 2.6)
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
                    readonly property real w: wall.size * 0.032
                    readonly property real stretch: 1.1 + wall.r(index + 40) * 0.16
                    x: piece.width * (0.3 + index * 0.1 + (wall.r(index + 60) - 0.5) * 0.05) - w / 2 - 4
                    width: w + 8
                    height: piece.height * 1.3
                    clip: true

                    Repeater {
                        model: [{ c: Theme.ink, inset: 0, extra: 0.012 }, { c: Qt.darker(Theme.accent, 1.3), inset: 4, extra: 0 }]
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
                    GradientStop { position: 0; color: Qt.lighter(Theme.accent, 1.3) }
                    GradientStop { position: 0.55; color: Theme.accent }
                    GradientStop { position: 0.56; color: Qt.darker(Theme.accent, 1.3) }
                    GradientStop { position: 1; color: Qt.darker(Theme.accent, 1.3) }
                }
            }
        }

        Coat {
            order: 3
            Repeater {
                model: 90
                Rectangle {
                    required property int index
                    readonly property real a: wall.r(index * 2) * Math.PI * 2
                    readonly property real d: 0.5 + wall.r(index * 2 + 1) * 0.12
                    width: 2 + wall.r(index + 300) * 5
                    height: width
                    radius: width / 2
                    x: piece.width / 2 + Math.cos(a) * piece.width * d
                    y: piece.height / 2 + Math.sin(a) * piece.height * d
                    color: wall.r(index + 600) < 0.7 ? Theme.accent : Theme.acid
                    opacity: 0.8
                }
            }
        }
    }

    Text {
        anchors { right: parent.right; bottom: parent.bottom; margins: 24 }
        text: "billy wuz here '04"
        color: Theme.dim
        opacity: 0.6
        rotation: -3
        font.family: Theme.marker
        font.italic: true
        font.weight: Font.Black
        font.pixelSize: Math.round(wall.height * 0.025)
    }

    Image {
        anchors.fill: parent
        source: "grain.png"
        fillMode: Image.Tile
        opacity: 0.06
    }
}
