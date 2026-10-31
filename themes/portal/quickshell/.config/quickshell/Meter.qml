import QtQuick

// a text progress bar: [#######-------]
Label {
    property real fraction: 0
    property int cells: 20
    readonly property int filled: Math.round(Math.max(0, Math.min(1, fraction)) * cells)

    text: "[" + "#".repeat(filled) + "-".repeat(cells - filled) + "]"
}
