import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// every window as a live thumbnail, grouped by workspace
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
    color: Theme.bg
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
            else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) overview.current = (overview.current + 1) % n;
            else if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab) overview.current = (overview.current + n - 1) % n;
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) overview.choose(overview.current);
            else return;
            event.accepted = true;
        }
    }

    Flow {
        anchors.centerIn: parent
        width: Math.min(parent.width - 120, 4 * 340)
        spacing: 12

        Repeater {
            model: overview.windows

            Box {
                id: thumb
                required property var modelData
                required property int index
                readonly property bool picked: overview.current === index
                readonly property var size: modelData.lastIpcObject?.size ?? [16, 9]

                width: 328
                height: 324 / Math.max(size[0] / Math.max(1, size[1]), 0.8) + 26
                edge: picked ? Theme.blue : Theme.line

                Rectangle {
                    width: parent.width
                    height: 24
                    color: thumb.picked ? Theme.blue : "transparent"
                    Label {
                        x: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 16
                        elide: Text.ElideRight
                        text: `${thumb.modelData.workspace.id}: ${thumb.modelData.title}`
                        color: thumb.picked ? Theme.onLit : Theme.fg
                    }
                }

                ScreencopyView {
                    x: 2
                    y: 24
                    width: parent.width - 4
                    height: parent.height - 26
                    captureSource: overview.visible ? thumb.modelData.wayland : null
                    live: true
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: overview.current = thumb.index
                    onClicked: overview.choose(thumb.index)
                }
            }
        }
    }
}
