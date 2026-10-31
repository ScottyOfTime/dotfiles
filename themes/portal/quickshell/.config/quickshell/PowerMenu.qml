import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// five procedure signs: lock, suspend, log out, reboot, shut down
PanelWindow {
    id: menu

    required property var lock
    property int current: 0
    property bool shown: false
    property int quip: 0
    // how many signs are out; the dealer steps it toward the target
    property int dealt: 0
    property int dealTarget: 0

    readonly property var actions: [
        { name: "lock", note: "hold all testing", icon: Icons.lock, run: () => menu.lock.lockNow() },
        { name: "suspend", note: "relaxation vault", icon: Icons.sleep, run: () => Quickshell.execDetached(["systemctl", "suspend"]) },
        { name: "log out", note: "exit the facility", icon: Icons.leave, run: () => Hyprland.dispatch("hl.dsp.exit()") },
        { name: "reboot", note: "recalibrate chamber", icon: Icons.reboot, run: () => Quickshell.execDetached(["systemctl", "reboot"]) },
        { name: "shut down", note: "terminate testing", icon: Icons.power, run: () => Quickshell.execDetached(["systemctl", "poweroff"]) },
    ]

    function toggle() {
        if (shown) {
            close();
        } else {
            hide.stop();
            quip++;
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
        interval: 45
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (menu.dealt < menu.dealTarget) menu.dealt++;
            else if (menu.dealt > menu.dealTarget) menu.dealt--;
            else {
                stop();
                if (!menu.shown) hide.restart();
            }
        }
    }

    Timer { id: hide; interval: 160; onTriggered: menu.visible = false }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        opacity: menu.shown ? 0.82 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
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

    Column {
        anchors.centerIn: parent
        spacing: 28

        Row {
            spacing: 12
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: menu.shown ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 160 } }
            PortalMark { size: 18; anchors.verticalCenter: parent.verticalCenter }
            Caps { text: "select a procedure"; color: Theme.fg; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
        }

        Row {
            spacing: 18

            Repeater {
                model: menu.actions

                Panel {
                    id: option
                    required property var modelData
                    required property int index
                    // hover moves the one selection rather than adding a second
                    // highlight, which would stick when the cursor hides
                    readonly property bool picked: menu.current === index
                    readonly property color tint: picked ? Theme.onLit : Theme.ink
                    onHoveredChanged: if (hovered) menu.current = index

                    out: index < menu.dealt
                    radius: 14
                    padX: 26
                    padY: 24
                    fill: picked ? Theme.blue : Theme.panel
                    edge: picked ? Theme.blue : "transparent"
                    glow: picked
                    onClicked: menu.choose(index)

                    Column {
                        width: 170
                        spacing: 14

                        Item {
                            width: parent.width
                            height: 72
                            Pictogram {
                                path: option.modelData.icon
                                size: 72
                                colour: option.tint
                            }
                            Caps {
                                anchors.right: parent.right
                                text: String(option.index + 1).padStart(2, "0")
                                color: option.picked ? Theme.onLit : Theme.orange
                                font.pixelSize: 12
                            }
                        }
                        Rectangle { width: parent.width; height: 3; color: option.tint }
                        Label {
                            text: option.modelData.name
                            font.pixelSize: 22
                            font.weight: Font.Black
                            color: option.tint
                        }
                        Caps {
                            text: option.modelData.note
                            color: option.picked ? Theme.onLit : Theme.dim
                        }
                    }
                }
            }
        }

        Caps {
            text: Quips.pick(Quips.power, menu.quip)
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: menu.shown ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 160 } }
        }
    }
}
