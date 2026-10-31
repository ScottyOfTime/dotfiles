import QtQuick

// a widget header: title left, metadata right, a hairline under both
Column {
    id: root

    property string title
    property string meta
    property color tone: Theme.fg

    spacing: 6

    Item {
        width: root.width
        height: heading.height
        Caps { id: heading; text: root.title; color: root.tone }
        Caps { anchors.right: parent.right; text: root.meta }
    }
    Rectangle { width: root.width; height: 1; color: Theme.line }
}
