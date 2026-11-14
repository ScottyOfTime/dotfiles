import QtQuick
import QtQuick.Effects

// the wallpaper: a brick wall bombed edge to edge, on a 2560x1440 canvas
// scaled to fill. Two pieces (BILLY and the distro's logo), a throw-up,
// stencils, splats, scribbles and tags over the older, buffed-over layers.
// Each part is sprayed on in coats when it's created.
Rectangle {
    id: wall

    color: Theme.bg

    function r(i) {
        const x = Math.sin(i * 12.9898 + 4.1) * 43758.5453;
        return x - Math.floor(x);
    }

    Item {
        id: canvas
        width: 2560
        height: 1440
        anchors.centerIn: parent
        scale: Math.max(wall.width / width, wall.height / height)

        Repeater {
            model: 24 * 18
            Rectangle {
                required property int index
                readonly property int row: Math.floor(index / 18)
                readonly property int col: index % 18
                readonly property real k: wall.r(index)
                x: col * 156 - (row % 2 ? 78 : 0) - 20
                y: row * 62 - 10
                width: 150
                height: 56
                color: k < 0.5 ? Qt.tint(Theme.panel, Qt.alpha(Theme.ink, k * 0.35))
                               : Qt.tint(Theme.panel, Qt.alpha(Theme.fg, (k - 0.5) * 0.08))
            }
        }

        // older layers: buffed-over patches and faded tags under them
        Repeater {
            model: [[60, 70, 700, 230], [1230, 40, 560, 300], [1990, 1040, 620, 300], [700, 1110, 520, 260], [-40, 900, 380, 400]]
            Rectangle {
                required property var modelData
                x: modelData[0]; y: modelData[1]
                width: modelData[2]; height: modelData[3]
                color: Theme.surface
                opacity: 0.5
            }
        }
        Repeater {
            model: [["skate or die", 140, 130, -4], ["oi!", 1500, 90, 6], ["dkz crew", 2150, 1120, -3], ["buff this", 760, 1180, 2], ["xox", 40, 1000, -8]]
            Tag {
                required property var modelData
                text: modelData[0]
                x: modelData[1]; y: modelData[2]
                rotation: modelData[3]
                color: Theme.dim
                opacity: 0.45
            }
        }

        Coat {
            order: 0
            Repeater {
                model: [[300, 200, 520, 300, "accent"], [1800, 240, 640, 420, "acid"], [1150, 980, 600, 260, "accent"], [2200, 760, 420, 360, "acid"], [80, 1080, 420, 300, "accent"]]
                Spray {
                    required property var modelData
                    x: modelData[0]; y: modelData[1]
                    width: modelData[2]; height: modelData[3]
                    colour: modelData[4] === "acid" ? Theme.acid : Theme.accent
                    opacity: 0.22
                    soft: 1
                    drips: 4
                    dripWidth: 10
                    seed: modelData[0]
                }
            }
        }

        Coat {
            order: 1
            Stencil { cx: 2420; cy: 140; outer: 110 }
            Stencil { cx: 120; cy: 820; outer: 80; colour: Theme.accent }
            Stencil { cx: 2470; cy: 1330; outer: 75; colour: Theme.accent }
            Item {
                x: 1080; y: 1190
                Text {
                    text: "PUNX NOT DEAD"
                    color: Theme.acid
                    font.family: Theme.font
                    font.weight: Font.Black
                    font.pixelSize: 86
                    font.letterSpacing: 8
                    layer.enabled: true
                    layer.effect: MultiEffect { blurEnabled: true; blur: 0.08; blurMax: 12 }
                }
            }
        }

        // a throw-up: chrome bubble letters in a fat ink outline, ringed in pink
        Coat {
            order: 2
            Item {
                x: 110; y: 810
                rotation: -5
                Repeater {
                    model: [{ r: 22, c: Theme.accent }, { r: 11, c: Theme.ink }]
                    Item {
                        id: ring
                        required property var modelData
                        Repeater {
                            model: 16
                            Text {
                                required property int index
                                x: Math.cos(index * Math.PI / 8) * ring.modelData.r + 6
                                y: Math.sin(index * Math.PI / 8) * ring.modelData.r + 6
                                text: throwUp.text
                                color: ring.modelData.c
                                font: throwUp.font
                            }
                        }
                    }
                }
                Text {
                    id: throwUp
                    text: "PNX"
                    color: Theme.paper
                    font.family: Theme.marker
                    font.weight: Font.Black
                    font.pixelSize: 290
                    font.letterSpacing: -14
                }
                Text {
                    x: 4; y: throwUp.height * 0.52
                    width: throwUp.width; height: throwUp.height * 0.48
                    clip: true
                    text: throwUp.text
                    color: Theme.dim
                    opacity: 0.5
                    font: throwUp.font
                    topPadding: -throwUp.height * 0.52
                }
            }
        }

        Coat {
            order: 3
            Item {
                x: 210; y: 330
                scale: 1.5
                transformOrigin: Item.TopLeft

                Scrawl {
                    x: 40; y: -110
                    colour: Theme.acid
                    weight: 9
                    path: "M 0 80 L 10 10 L 45 55 L 75 0 L 100 55 L 140 12 L 145 80 Z"
                }
                Glyph {
                    rotation: -3
                    face: Theme.acid
                    paths: [[[0, 0], [115, 0], [150, 28], [150, 82], [128, 104], [158, 130], [158, 192], [125, 220], [0, 220]],
                            [[48, 40], [92, 40], [102, 52], [102, 72], [92, 84], [48, 84]],
                            [[48, 128], [100, 128], [110, 140], [110, 168], [100, 180], [48, 180]]]
                    drips: [[40, 70]]
                }
                Glyph {
                    x: 190; y: -14; rotation: 4
                    face: Theme.acid
                    paths: [[[0, 0], [100, 0], [100, 38], [74, 38], [74, 182], [100, 182], [100, 220], [0, 220], [0, 182], [26, 182], [26, 38], [0, 38]]]
                    drips: [[50, 110]]
                }
                Glyph {
                    x: 318; y: 10; rotation: -2
                    face: Theme.acid
                    paths: [[[0, 0], [54, 0], [54, 168], [100, 168], [100, 140], [168, 194], [100, 246], [100, 220], [0, 220]]]
                    drips: [[26, 50]]
                }
                Glyph {
                    x: 500; y: -8; rotation: 3
                    face: Theme.acid
                    paths: [[[0, 0], [54, 0], [54, 168], [100, 168], [100, 140], [168, 194], [100, 246], [100, 220], [0, 220]]]
                    drips: [[30, 130]]
                }
                Glyph {
                    x: 650; y: 12; rotation: -4
                    face: Theme.acid
                    paths: [[[0, 0], [54, 0], [82, 58], [108, 0], [146, -44], [162, 0], [108, 112], [108, 220], [56, 220], [56, 112]]]
                    drips: [[80, 80]]
                }
            }
        }

        LogoPiece {
            order: 4
            size: 690
            x: 1930 - width / 2
            y: 650 - height / 2
            rotation: -4
        }

        Coat {
            order: 7
            Scrawl { x: 1330; y: 860; colour: Theme.fg; path: "M 0 40 Q 60 -10 120 30 T 240 20 T 360 40" }
            Scrawl { x: 230; y: 820; colour: Theme.accent; weight: 8; path: "M 0 0 L 980 -30" }
            Scrawl { x: 1610; y: 1080; colour: Theme.ink; weight: 7; path: "M 0 0 L 60 60 M 60 0 L 0 60 M 100 0 L 160 60 M 160 0 L 100 60" }
            Scrawl { x: 960; y: 120; colour: Theme.accent; weight: 7; path: "M 0 30 L 160 30 M 130 0 L 170 30 L 130 60" }
            Scrawl { x: 2380; y: 420; colour: Theme.fg; weight: 6; path: "M 40 70 C -10 30 10 -10 40 20 C 70 -10 90 30 40 70 Z" }

            Tag { text: "billy wuz here '04"; x: 1180; y: 1340; rotation: -4; color: Theme.fg; font.pixelSize: 54 }
            Tag { text: "billy"; x: 1030; y: 860; rotation: -8; color: Theme.accent; font.pixelSize: 70 }
            Tag { text: "no gods"; x: 2240; y: 1200; rotation: 5; color: Theme.ink; font.pixelSize: 46 }
            Tag { text: "B!"; x: 1130; y: 160; rotation: 10; color: Theme.fg; font.pixelSize: 90 }
            Tag { text: "kurt + j"; x: 760; y: 170; rotation: -3; color: Theme.fg; font.pixelSize: 40 }
            Tag { text: "est. 04"; x: 30; y: 1340; rotation: -2; color: Theme.acid; font.pixelSize: 40 }
            Tag { text: "loud"; x: 2350; y: 600; rotation: 80; color: Theme.ink; font.pixelSize: 60 }
            Tag { text: "arch / hyprland / graffiti"; x: 1760; y: 1385; color: Theme.dim; font.pixelSize: 24; font.italic: false; font.family: Theme.font }
        }
    }

    Image {
        anchors.fill: parent
        source: "grain.png"
        fillMode: Image.Tile
        opacity: 0.06
    }
}
