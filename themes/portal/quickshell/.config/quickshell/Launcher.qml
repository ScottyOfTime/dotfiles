import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: launcher

    property bool shown: false
    readonly property var apps: DesktopEntries.applications.values
        .filter(a => !a.noDisplay && a.name.toLowerCase().includes(search.text.toLowerCase()))
        .sort((a, b) => {
            const q = search.text.toLowerCase();
            const pa = a.name.toLowerCase().startsWith(q), pb = b.name.toLowerCase().startsWith(q);
            return pa === pb ? a.name.localeCompare(b.name) : pa ? -1 : 1;
        })

    function toggle() {
        if (shown) {
            close();
            return;
        }
        hide.stop();
        search.text = "";
        list.currentIndex = 0;
        visible = true;
        shown = true;
        search.forceActiveFocus();
    }

    function close() {
        shown = false;
        hide.restart();
    }

    function launch(app) {
        if (!app) return;
        app.execute();
        close();
    }

    visible: false
    color: "transparent"
    implicitWidth: 620
    implicitHeight: 720
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    IpcHandler {
        target: "launcher"
        function toggle(): void { launcher.toggle(); }
    }

    HyprlandFocusGrab {
        windows: [launcher]
        active: launcher.shown
        onCleared: launcher.close()
    }

    Timer { id: hide; interval: 160; onTriggered: launcher.visible = false }

    Panel {
        anchors.centerIn: parent
        out: launcher.shown
        padX: 22
        padY: 20
        radius: 6
        edge: Theme.blue
        glow: true

        Column {
            spacing: 14

            Readout { width: 520; title: "launcher"; meta: `${launcher.apps.length} apps` }

            Rectangle {
                width: 520
                height: 42
                radius: 4
                color: Theme.bg
                border.color: search.text !== "" ? Theme.blue : Theme.line
                border.width: search.text !== "" ? 2 : 1

                Rectangle {
                    x: 12
                    width: 8; height: 18
                    radius: 1
                    color: Theme.orange
                    anchors.verticalCenter: parent.verticalCenter
                }
                TextInput {
                    id: search
                    x: 30
                    width: parent.width - 42
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.fg
                    font.family: Theme.font
                    font.bold: true
                    font.pixelSize: 16
                    onTextChanged: list.currentIndex = 0
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) launcher.close();
                        else if (event.key === Qt.Key_Down) list.incrementCurrentIndex();
                        else if (event.key === Qt.Key_Up) list.decrementCurrentIndex();
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                            launcher.launch(launcher.apps[list.currentIndex]);
                        else return;
                        event.accepted = true;
                    }

                    Label {
                        visible: search.text === ""
                        text: "search"
                        color: Theme.dim
                        font.bold: false
                        font.pixelSize: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            ListView {
                id: list
                width: 520
                height: 14 * 34
                clip: true
                model: launcher.apps
                highlightMoveDuration: 110
                highlight: Rectangle { color: Theme.blue; radius: 4 }

                delegate: Item {
                    id: entry
                    required property var modelData
                    required property int index
                    readonly property bool current: ListView.isCurrentItem
                    width: 520
                    height: 34

                    Row {
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                        spacing: 12
                        Caps {
                            text: String(entry.index + 1).padStart(2, "0")
                            color: entry.current ? Theme.onLit : Theme.dim
                            width: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        IconImage {
                            source: Quickshell.iconPath(entry.modelData.icon, true)
                            implicitSize: 20
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Label {
                            text: entry.modelData.name
                            color: entry.current ? Theme.onLit : Theme.fg
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: list.currentIndex = entry.index
                        onClicked: launcher.launch(entry.modelData)
                    }
                }
            }
        }
    }
}
