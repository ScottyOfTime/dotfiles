import QtQuick

// a flat box with a square border
Rectangle {
    property color edge: Theme.line

    color: Theme.panel
    border.color: edge
    border.width: 2
}
