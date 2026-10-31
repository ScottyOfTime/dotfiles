import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

// a glowing portal that irises open `delay` ms after it's created
Item {
    id: root

    property color colour: Theme.blue
    property int delay: 0
    property real open: 0
    property real diameter: 300
    property real stretch: 1.75

    width: diameter
    height: diameter * stretch

    Timer { running: true; interval: root.delay; onTriggered: root.open = 1 }
    Behavior on open { NumberAnimation { duration: 650; easing.type: Easing.OutBack; easing.overshoot: 1.25 } }

    Item {
        width: root.diameter
        height: root.diameter
        transform: Scale {
            origin.x: root.diameter / 2
            origin.y: root.diameter / 2
            xScale: root.open
            yScale: root.open * root.stretch
        }
        y: (root.height - root.diameter) / 2
        opacity: root.open > 0.02 ? 1 : 0

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: root.colour
            shadowBlur: 1
            blurMax: 48
            shadowScale: 1.06
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 0
        }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            readonly property real r: root.diameter / 2

            ShapePath {
                strokeColor: "transparent"
                fillGradient: RadialGradient {
                    centerX: root.diameter / 2; centerY: root.diameter / 2
                    focalX: root.diameter / 2; focalY: root.diameter / 2
                    centerRadius: root.diameter / 2
                    GradientStop { position: 0; color: Qt.alpha(root.colour, 0.05) }
                    GradientStop { position: 0.7; color: Qt.alpha(root.colour, 0.22) }
                    GradientStop { position: 1; color: Qt.alpha(root.colour, 0.6) }
                }
                PathSvg { path: `M0 ${root.diameter / 2}a${root.diameter / 2} ${root.diameter / 2} 0 1 0 ${root.diameter} 0a${root.diameter / 2} ${root.diameter / 2} 0 1 0 ${-root.diameter} 0z` }
            }
            ShapePath {
                strokeColor: "transparent"
                fillColor: root.colour
                fillRule: ShapePath.OddEvenFill
                PathSvg {
                    readonly property real d: root.diameter
                    readonly property real t: 12
                    path: `M0 ${d / 2}a${d / 2} ${d / 2} 0 1 0 ${d} 0a${d / 2} ${d / 2} 0 1 0 ${-d} 0z `
                        + `M${t} ${d / 2}a${d / 2 - t} ${d / 2 - t} 0 1 0 ${d - 2 * t} 0a${d / 2 - t} ${d / 2 - t} 0 1 0 ${-(d - 2 * t)} 0z`
                }
            }
        }
    }
}
