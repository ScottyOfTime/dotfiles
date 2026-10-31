import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// big scraps for lock, suspend, log out, reboot and shut down
PanelWindow {
    id: menu

    required property var lock
    property int current: 0
    property bool shown: false

    readonly property var actions: [
        { name: "lock", run: () => menu.lock.lockNow() },
        { name: "suspend", run: () => Quickshell.execDetached(["systemctl", "suspend"]) },
        { name: "log out", run: () => Hyprland.dispatch("hl.dsp.exit()") },
        { name: "reboot", run: () => Quickshell.execDetached(["systemctl", "reboot"]) },
        { name: "shut down", run: () => Quickshell.execDetached(["systemctl", "poweroff"]) },
    ]

    function toggle() {
        if (shown) {
            close();
        } else {
            current = 0;
            visible = true;
            shown = true;
            keys.forceActiveFocus();
        }
    }

    function close() {
        shown = false;
        hide.restart();
    }

    function choose(i) {
        close();
        actions[i].run();
    }

    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "powermenu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    IpcHandler {
        target: "power"
        function toggle(): void { menu.toggle(); }
    }

    Timer { id: hide; interval: 160; onTriggered: menu.visible = false }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        opacity: menu.shown ? 0.7 : 0
        Behavior on opacity { NumberAnimation { duration: 140 } }
    }

    MouseArea { anchors.fill: parent; onClicked: menu.close() }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) menu.close();
            else if (event.key === Qt.Key_Left) menu.current = (menu.current + 4) % 5;
            else if (event.key === Qt.Key_Right) menu.current = (menu.current + 1) % 5;
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) menu.choose(menu.current);
            else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_5) menu.choose(event.key - Qt.Key_1);
            else return;
            event.accepted = true;
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 26

        Repeater {
            model: menu.actions

            Scrap {
                id: option
                required property var modelData
                required property int index
                readonly property bool picked: menu.current === index || hovered

                seed: 100 + index
                tilt: picked ? 0 : [-5, 4, -3, 6, -4][index]
                scale: picked ? 1.1 : 1
                fill: picked ? Theme.accent : Theme.panel
                ragged: 6
                shadow: 6
                padX: 26
                padY: 22
                tape: index === 2
                tapeWidth: 50
                anchors.verticalCenter: parent.verticalCenter

                // each drops in a beat after the last
                y: menu.shown ? 0 : -40
                opacity: menu.shown ? 1 : 0
                Behavior on y { SequentialAnimation { PauseAnimation { duration: menu.shown ? option.index * 35 : 0 } NumberAnimation { duration: menu.shown ? 240 : 110; easing.type: menu.shown ? Easing.OutBack : Easing.InCubic } } }
                Behavior on opacity { SequentialAnimation { PauseAnimation { duration: menu.shown ? option.index * 35 : 0 } NumberAnimation { duration: 110 } } }

                onClicked: menu.choose(index)

                Column {
                    spacing: 6
                    Label {
                        text: option.modelData.name
                        font.pixelSize: 24
                        color: option.picked ? Theme.ink : Theme.fg
                    }
                    Label {
                        text: option.index + 1
                        font.pixelSize: 12
                        color: option.picked ? Theme.ink : Theme.dim
                    }
                }
            }
        }
    }
}
