import QtQuick

// the crt's beam, centred in its parent. across and down are fractions of
// the parent (0 is a dot), glow fades it. stepped draws it as a hard-edged
// rectangle moving in a few jumps; otherwise it's a soft glow that tapers at
// the ends and rounds into a dot, as a tube switching off looks
Item {
    id: beam

    property real across: 0
    property real down: 0
    property real glow: 1
    property bool stepped: true

    function steps(value, count) {
        return stepped ? Math.floor(value * count) / count : value;
    }

    readonly property int w: Math.max(6, Math.round(parent.width * steps(across, 4)))
    readonly property int h: Math.max(4, Math.round(parent.height * steps(down, 5)))

    anchors.fill: parent
    opacity: stepped ? Math.ceil(glow * 3) / 3 : glow

    Rectangle {
        visible: beam.stepped
        anchors.centerIn: parent
        width: beam.w
        height: beam.h
        color: Theme.bright
    }

    Canvas {
        id: soft
        anchors.fill: parent
        visible: !beam.stepped
        renderTarget: Canvas.FramebufferObject
        Connections {
            target: beam
            function onWChanged() { soft.requestPaint(); }
            function onHChanged() { soft.requestPaint(); }
        }
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            // an ellipse larger than the beam, solid in the middle and fading
            // at its rim; wide enough while tall to fill the corners
            const grow = 1.15 + 0.4 * beam.down;
            const rx = beam.w / 2 * grow + 8;
            const ry = beam.h / 2 * grow + 8;
            ctx.save();
            ctx.translate(width / 2, height / 2);
            ctx.scale(rx, ry);
            const g = ctx.createRadialGradient(0, 0, 0, 0, 0, 1);
            g.addColorStop(0, Theme.bright);
            g.addColorStop(Math.min(0.85, Math.max(0.15, 1 - 16 / Math.min(rx, ry))), Theme.bright);
            g.addColorStop(1, "transparent");
            ctx.fillStyle = g;
            ctx.fillRect(-1, -1, 2, 2);
            ctx.restore();
        }
    }
}
