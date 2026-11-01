import QtQuick

Text {
    color: Theme.fg
    font.family: Theme.font
    font.pointSize: Theme.fontPoints
    // thinner and closer to ghostty's pixel-exact terminus than native
    // rendering, whose strokes smear over fractional pixels at 1.33x
    renderType: Text.CurveRendering
}
