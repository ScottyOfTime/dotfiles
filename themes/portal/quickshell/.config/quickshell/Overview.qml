import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// every window as a live monitor, grouped by workspace
PanelWindow {
    id: overview

    property bool shown: false
    property int current: 0
    property int dealt: 0
    property int dealTarget: 0

    readonly property var windows: Hyprland.toplevels.values
        .filter(t => t.workspace && t.workspace.id > 0)
        .sort((a, b) => a.workspace.id - b.workspace.id
            || (a.lastIpcObject?.at?.[0] ?? 0) - (b.lastIpcObject?.at?.[0] ?? 0))
    readonly property var workspaces: [...new Set(windows.map(t => t.workspace.id))]

    function toggle() {
        if (shown) {
            close();
            return;
        }
        hide.stop();
        Hyprland.refreshToplevels();
        current = Math.max(0, windows.findIndex(t => t.activated));
        visible = true;
        shown = true;
        dealTarget = windows.length;
        dealer.restart();
        keys.forceActiveFocus();
    }

    function close() {
        shown = false;
        dealTarget = 0;
        dealer.restart();
    }

    function choose(i) {
        const t = windows[i];
        close();
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

    Timer {
        id: dealer
        interval: 30
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (overview.dealt < overview.dealTarget) overview.dealt++;
            else if (overview.dealt > overview.dealTarget) overview.dealt = Math.max(overview.dealTarget, overview.dealt - 2);
            else {
                stop();
                if (!overview.shown) hide.restart();
            }
        }
    }

    Timer { id: hide; interval: 160; onTriggered: overview.visible = false }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        opacity: overview.shown ? 0.88 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
    }

    MouseArea { anchors.fill: parent; onClicked: overview.close() }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            const n = overview.windows.length;
            if (event.key === Qt.Key_Escape) overview.close();
            else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) overview.current = (overview.current + 1) % n;
            else if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab) overview.current = (overview.current + n - 1) % n;
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) overview.choose(overview.current);
            else return;
            event.accepted = true;
        }
    }

    Readout {
        anchors { top: parent.top; topMargin: 80; horizontalCenter: parent.horizontalCenter }
        width: Math.min(parent.width - 160, 1600)
        title: "windows"
        meta: `${overview.windows.length} open · ${overview.workspaces.length} workspaces`
        opacity: overview.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
    }

    Flow {
        anchors.centerIn: parent
        width: Math.min(parent.width - 160, 1600)
        spacing: 40

        Repeater {
            model: overview.workspaces

            Column {
                id: group
                required property int modelData
                readonly property var members: overview.windows.filter(t => t.workspace.id === modelData)
                spacing: 12

                Row {
                    spacing: 10
                    readonly property bool out: overview.windows.indexOf(group.members[0]) < overview.dealt
                    opacity: out ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 140 } }
                    Label {
                        text: String(group.modelData).padStart(2, "0")
                        font.pixelSize: 26
                        font.weight: Font.ExtraBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Caps { text: "workspace"; anchors.verticalCenter: parent.verticalCenter }
                }

                Flow {
                    width: Math.min(group.members.length, 3) * 356
                    spacing: 20

                    Repeater {
                        model: group.members

                        Panel {
                            id: monitor
                            required property var modelData
                            readonly property int index: overview.windows.indexOf(modelData)
                            readonly property bool picked: overview.current === index
                            readonly property var size: modelData.lastIpcObject?.size ?? [16, 9]
                            readonly property real aspect: size[0] / Math.max(1, size[1])

                            out: index < overview.dealt
                            padX: 6
                            padY: 6
                            radius: 6
                            fill: picked ? Theme.blue : Theme.glass
                            edge: picked ? Theme.blue : "transparent"
                            glow: picked
                            scale: picked ? 1.04 : 1
                            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                            onHoveredChanged: if (hovered) overview.current = index
                            onClicked: overview.choose(index)

                            Column {
                                spacing: 6

                                Rectangle {
                                    width: 324
                                    height: 324 / Math.max(monitor.aspect, 0.8)
                                    radius: 3
                                    color: Theme.bg
                                    clip: true

                                    ScreencopyView {
                                        anchors.fill: parent
                                        captureSource: overview.visible ? monitor.modelData.wayland : null
                                        live: true
                                    }

                                    Caps {
                                        anchors.centerIn: parent
                                        z: -1
                                        text: monitor.modelData.lastIpcObject?.class ?? ""
                                    }
                                }

                                Row {
                                    leftPadding: 4
                                    spacing: 8
                                    Caps {
                                        text: monitor.modelData.lastIpcObject?.class ?? ""
                                        color: monitor.picked ? Theme.onLit : Theme.orange
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Label {
                                        text: monitor.modelData.title
                                        width: 300 - x
                                        elide: Text.ElideRight
                                        color: monitor.picked ? Theme.onLit : Theme.fg
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
