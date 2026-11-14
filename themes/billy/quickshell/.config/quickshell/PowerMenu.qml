import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// lock, sleep, log out, reboot and shut down, stencilled across the screen;
// the pick gets a spray of the accent. They go up one at a time.
PanelWindow {
    id: menu

    required property var lock
    property int current: 0
    property bool shown: false
    property int dealt: 0
    property int dealTarget: 0

    readonly property var actions: [
        { name: "lock", run: () => menu.lock.lockNow() },
        { name: "sleep", run: () => Quickshell.execDetached(["systemctl", "suspend"]) },
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
            dealTarget = actions.length;
            dealer.restart();
            keys.forceActiveFocus();
        }
    }

    function close() {
        shown = false;
        dealTarget = 0;
        dealer.restart();
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

    Timer {
        id: dealer
        interval: 55
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (menu.dealt < menu.dealTarget) menu.dealt++;
            else if (menu.dealt > menu.dealTarget) menu.dealt--;
            else {
                stop();
                if (!menu.shown) menu.visible = false;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        opacity: 0.85 * menu.dealt / menu.actions.length
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
        spacing: 50

        Repeater {
            model: menu.actions

            Item {
                id: option
                required property var modelData
                required property int index
                readonly property bool picked: menu.current === index

                visible: index < menu.dealt
                width: word.implicitWidth
                height: word.implicitHeight + 40
                rotation: [-3, 2, -1.5, 3, -2][index]

                Spray {
                    visible: option.picked
                    x: -26; y: -18
                    width: parent.width + 52
                    height: word.implicitHeight + 36
                    seed: 100 + index
                    drips: 3
                    dripWidth: 6
                }

                Text {
                    id: word
                    text: option.modelData.name
                    color: option.picked ? Theme.ink : Theme.paper
                    style: Text.Outline
                    styleColor: option.picked ? Theme.accent : Theme.ink
                    font.family: Theme.font
                    font.weight: Font.Black
                    font.pixelSize: 56
                    font.capitalization: Font.AllUppercase
                }

                Dymo {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: word.implicitHeight + 14
                    text: option.index + 1
                    size: 11
                    seed: 120 + option.index
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: menu.current = option.index
                    onClicked: menu.choose(option.index)
                }
            }
        }
    }
}
