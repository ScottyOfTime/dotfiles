import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// a dmenu-style strip over the bar: a prompt, an optional search field and
// the matches in a row. Arrows or Tab move, Enter picks, Esc closes.
PanelWindow {
    id: strip

    property string prompt
    property string space
    property var items: []
    property bool searchable: true
    property int current: 0
    property bool shown: false
    readonly property alias query: input.text

    signal chosen(int index)

    function open() {
        input.text = "";
        current = 0;
        visible = true;
        shown = true;
        input.forceActiveFocus();
    }

    function close() {
        shown = false;
        visible = false;
    }

    function toggle() {
        if (shown) close();
        else open();
    }

    visible: false
    color: Theme.panel
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.bar
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: strip.space
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    HyprlandFocusGrab {
        windows: [strip]
        active: strip.shown
        onCleared: strip.close()
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.line
    }

    Row {
        height: parent.height

        Rectangle {
            width: label.implicitWidth + 20
            height: parent.height
            color: Theme.orange
            Label { id: label; anchors.centerIn: parent; text: strip.prompt; color: Theme.onLit; font.bold: true }
        }

        TextInput {
            id: input
            width: strip.searchable ? 260 : 1
            readOnly: !strip.searchable
            leftPadding: 10
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: 13
            cursorVisible: strip.searchable
            onTextChanged: strip.current = 0
            Keys.onPressed: event => {
                const n = strip.items.length;
                if (event.key === Qt.Key_Escape) strip.close();
                else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down || event.key === Qt.Key_Tab)
                    strip.current = Math.min(n - 1, strip.current + 1);
                else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up || event.key === Qt.Key_Backtab)
                    strip.current = Math.max(0, strip.current - 1);
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (n > 0) strip.chosen(strip.current);
                } else if (!strip.searchable && event.key >= Qt.Key_1 && event.key < Qt.Key_1 + n)
                    strip.chosen(event.key - Qt.Key_1);
                else return;
                event.accepted = true;
            }
        }

        ListView {
            id: list
            width: strip.width - x
            height: parent.height
            orientation: ListView.Horizontal
            clip: true
            model: strip.items
            currentIndex: strip.current
            highlightMoveDuration: 0
            highlightFollowsCurrentItem: true

            delegate: Rectangle {
                required property string modelData
                required property int index
                readonly property bool picked: index === strip.current
                width: name.implicitWidth + 20
                height: list.height
                color: picked ? Theme.blue : "transparent"

                Label {
                    id: name
                    anchors.centerIn: parent
                    text: strip.searchable ? modelData : `${index + 1} ${modelData}`
                    color: picked ? Theme.onLit : Theme.fg
                    font.bold: picked
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: strip.chosen(index)
                }
            }
        }
    }
}
