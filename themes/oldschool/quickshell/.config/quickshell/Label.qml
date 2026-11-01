import QtQuick

Text {
    color: Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.fontSize
    renderType: Text.NativeRendering
    // terminus is drawn on the pixel grid; smoothing only greys its strokes
    antialiasing: false
}
