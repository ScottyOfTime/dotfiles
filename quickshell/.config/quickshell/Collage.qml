import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io

// the wallpaper: a riso collage laid out on a 2560x1440 canvas, scaled to
// fill. Pieces drop in one after another when it's created.
Rectangle {
    id: collage

    color: Theme.bg

    FileView { id: hostname; path: "/etc/hostname"; blockLoading: true }

    Item {
        id: canvas
        width: 2560
        height: 1440
        anchors.centerIn: parent
        scale: Math.max(collage.width / width, collage.height / height)

        Piece {
            order: 0; cx: 1961; cy: 1187; twist: -10
            Grid {
                x: 1681; y: 1017
                rotation: 8
                columns: 25
                Repeater {
                    model: 25 * 15
                    Item {
                        width: 22; height: 22
                        Rectangle { anchors.centerIn: parent; width: 12; height: 12; radius: 6; color: Theme.dim }
                    }
                }
            }
        }

        Piece {
            order: 1; cx: 860; cy: 1000; twist: 8
            Poly { points: [[340, 820], [1340, 760], [1380, 1180], [380, 1240]]; fill: Theme.surface }
        }

        Piece {
            order: 2; cx: 1860; cy: 630; twist: -6
            Repeater {
                model: [{ off: 16, colour: Theme.ink, border: 0 }, { off: 0, colour: Theme.panel, border: 6 }]
                Rectangle {
                    x: 1860 - 390 + modelData.off; y: 630 - 390 + modelData.off
                    width: 780; height: 780; radius: 390
                    color: modelData.colour
                    border.color: Theme.ink
                    border.width: modelData.border
                    antialiasing: true
                }
            }
        }

        Piece {
            order: 3; cx: 870; cy: 610; twist: 14
            Poly { points: [[220, 520], [1500, 470], [1520, 700], [240, 750]]; fill: Theme.accent }
            Text {
                x: 300; y: 528
                rotation: -2.2
                transformOrigin: Item.BottomLeft
                text: hostname.text().trim()
                color: Theme.ink
                font.family: Theme.font
                font.weight: Font.ExtraBold
                font.pixelSize: 150
                font.letterSpacing: -4
            }
        }

        Piece {
            order: 4; cx: 1760; cy: 293; twist: -18
            Poly { points: [[1596, 276], [1916, 246], [1924, 310], [1604, 340]]; fill: Theme.paper; shadow: 10 }
        }

        Piece {
            order: 5; cx: 700; cy: 1330; twist: 4
            Text {
                x: 400; y: 1300
                text: "arch  /  hyprland  /  zine"
                color: Theme.dim
                font.family: Theme.font
                font.bold: true
                font.pixelSize: 34
                font.letterSpacing: 6
            }
        }
    }

    // paper grain over everything
    Image {
        anchors.fill: parent
        source: "grain.png"
        fillMode: Image.Tile
        opacity: 0.05
    }
}
