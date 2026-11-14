import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

// a slab of gaffer tape stuck up from the bottom edge, written on in
// paint marker; the pick is marked with a highlighter
PanelWindow {
    id: launcher

    property bool shown: false
    property real t: 0
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
        search.text = "";
        list.currentIndex = 0;
        visible = true;
        shown = true;
        t = 1;
        search.forceActiveFocus();
    }

    function close() {
        shown = false;
        t = 0;
    }

    function launch(app) {
        if (!app) return;
        app.execute();
        close();
    }

    visible: false
    color: "transparent"
    anchors.bottom: true
    implicitWidth: 600
    implicitHeight: 660
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // moves in four hard steps, like a flip book
    Behavior on t { NumberAnimation { duration: 160 } }
    onTChanged: if (t === 0 && !shown) visible = false

    IpcHandler {
        target: "launcher"
        function toggle(): void { launcher.toggle(); }
    }

    HyprlandFocusGrab {
        windows: [launcher]
        active: launcher.shown
        onCleared: launcher.close()
    }

    Gaffer {
        id: sheet
        width: 500
        height: 590
        x: (launcher.width - width) / 2
        y: launcher.height - height - 24 + (1 - Math.round(launcher.t * 4) / 4) * (height + 60)
        seed: 3
        tear: 9

        Column {
            x: 30; y: 24
            spacing: 10

            Row {
                spacing: 8
                Marker { text: ">"; color: Theme.accent; font.pixelSize: 22 }
                TextInput {
                    id: search
                    width: 400
                    color: Theme.paper
                    font.family: Theme.marker
                    font.italic: true
                    font.weight: Font.Black
                    font.pixelSize: 21
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
                }
            }

            Rectangle { width: 440; height: 2; color: Theme.dim }

            ListView {
                id: list
                width: 440
                height: 15 * 32
                clip: true
                model: launcher.apps
                highlightMoveDuration: 0
                highlight: Rectangle { color: Theme.accent; radius: 3 }

                delegate: Item {
                    id: entry
                    required property var modelData
                    required property int index
                    width: 440
                    height: 32

                    Row {
                        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                        spacing: 10
                        IconImage {
                            source: Quickshell.iconPath(modelData.icon, true)
                            implicitSize: 20
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Marker {
                            text: modelData.name.toLowerCase()
                            color: entry.ListView.isCurrentItem ? Theme.ink : Theme.paper
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: list.currentIndex = index
                        onClicked: launcher.launch(modelData)
                    }
                }
            }
        }
    }
}
