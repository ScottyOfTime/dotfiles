import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// every window as a line in a list, ordered by workspace, like ps
PanelWindow {
    id: overview

    property int current: 0

    readonly property var windows: Hyprland.toplevels.values
        .filter(t => t.workspace && t.workspace.id > 0)
        .sort((a, b) => a.workspace.id - b.workspace.id
            || (a.lastIpcObject?.at?.[0] ?? 0) - (b.lastIpcObject?.at?.[0] ?? 0))

    function toggle() {
        if (visible) {
            visible = false;
            return;
        }
        Hyprland.refreshToplevels();
        current = Math.max(0, windows.findIndex(t => t.activated));
        visible = true;
        keys.forceActiveFocus();
    }

    function choose(i) {
        const t = windows[i];
        visible = false;
        if (t) Hyprland.dispatch(`hl.dsp.focus({ window = "address:0x${t.address}" })`);
    }

    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "overview"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    IpcHandler {
        target: "overview"
        function toggle(): void { overview.toggle(); }
    }


    MouseArea { anchors.fill: parent; onClicked: overview.visible = false }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            const n = overview.windows.length;
            if (event.key === Qt.Key_Escape) overview.visible = false;
            else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) overview.current = (overview.current + 1) % n;
            else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) overview.current = (overview.current + n - 1) % n;
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) overview.choose(overview.current);
            else return;
            event.accepted = true;
        }
    }

    Box {
        anchors.centerIn: parent
        width: 760
        height: list.implicitHeight + 4
        edge: Theme.bright

        // swallow clicks so only the outside closes the list
        MouseArea { anchors.fill: parent }

        Column {
            id: list
            x: 2
            y: 2
            width: parent.width - 4

            Label {
                leftPadding: 10
                height: 26
                verticalAlignment: Text.AlignVCenter
                color: Theme.dim
                text: `${"WS".padEnd(4)}${"CLASS".padEnd(16)}TITLE`
            }

            Repeater {
                model: overview.windows

                Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool picked: overview.current === index

                    width: list.width
                    height: 26
                    color: picked ? Theme.fg : "transparent"

                    Label {
                        x: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 20
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                        color: row.picked ? Theme.onLit : Theme.fg
                        text: String(row.modelData.workspace.id).padEnd(4)
                            + (row.modelData.lastIpcObject?.class ?? "").split(".").pop().slice(0, 14).padEnd(16)
                            + row.modelData.title
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: overview.current = row.index
                        onClicked: overview.choose(row.index)
                    }
                }
            }
        }
    }
}
