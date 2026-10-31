import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// every window as a live "photo" pasted on, grouped by workspace
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

    Timer { id: hide; interval: 120; onTriggered: overview.visible = false }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        opacity: overview.shown ? 0.8 : 0
        Behavior on opacity { NumberAnimation { duration: 140 } }
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
                spacing: 14

                Scrap {
                    seed: 200 + group.modelData
                    tilt: group.modelData % 2 ? -3 : 3
                    fill: Theme.surface
                    padX: 12; padY: 4
                    Label { text: `workspace ${group.modelData}`; color: Theme.fg }
                }

                Flow {
                    width: Math.min(group.members.length, 3) * 360
                    spacing: 28

                    Repeater {
                        model: group.members

                        Item {
                            id: photo
                            required property var modelData
                            readonly property int index: overview.windows.indexOf(modelData)
                            readonly property bool picked: overview.current === index
                            readonly property bool out: index < overview.dealt
                            readonly property var size: modelData.lastIpcObject?.size ?? [16, 9]
                            readonly property real aspect: size[0] / Math.max(1, size[1])

                            width: 320
                            height: 320 / Math.max(aspect, 0.8) + 44

                            Item {
                                id: paper
                                width: parent.width
                                height: parent.height
                                rotation: photo.picked ? 0 : [-4, 3, -2, 5, -3][photo.index % 5]
                                scale: (photo.picked ? 1.08 : 1) * (photo.out ? 1 : 0.6)
                                opacity: photo.out ? 1 : 0
                                Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                                Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                                Behavior on opacity { NumberAnimation { duration: 110 } }

                                Rectangle { x: 6; y: 6; width: parent.width; height: parent.height; color: Theme.ink; antialiasing: true }
                                Rectangle {
                                    anchors.fill: parent
                                    color: photo.picked ? Theme.accent : Theme.panel
                                    antialiasing: true

                                    Rectangle {
                                        id: frame
                                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
                                        height: parent.height - 52
                                        color: Theme.bg
                                        clip: true

                                        ScreencopyView {
                                            anchors.fill: parent
                                            captureSource: overview.visible ? photo.modelData.wayland : null
                                            live: true
                                        }

                                        Label {
                                            anchors.centerIn: parent
                                            z: -1
                                            text: photo.modelData.lastIpcObject?.class ?? ""
                                            color: Theme.dim
                                        }
                                    }

                                    Label {
                                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 12 }
                                        text: photo.modelData.title
                                        elide: Text.ElideRight
                                        color: photo.picked ? Theme.ink : Theme.fg
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: overview.current = photo.index
                                    onClicked: overview.choose(photo.index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
