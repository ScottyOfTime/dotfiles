import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

// a photocopied sheet taped up from the bottom edge; the pick is marked
// with a highlighter
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

    Item {
        id: sheet
        width: 500
        height: 590
        x: (launcher.width - width) / 2
        y: launcher.height - height - 30 + (1 - Math.round(launcher.t * 4) / 4) * (height + 60)
        rotation: -1.2

        Rectangle { x: 6; y: 6; width: parent.width; height: parent.height; color: Qt.alpha(Theme.ink, 0.5) }
        Rectangle { anchors.fill: parent; color: Theme.paper }
        Image {
            anchors.fill: parent
            source: "grain.png"
            fillMode: Image.Tile
            opacity: 0.1
        }
        Tape { x: -30; y: -4; rotation: -35 }
        Tape { x: parent.width - 60; y: -6; rotation: 33 }

        Column {
            x: 26; y: 30
            spacing: 12

            Row {
                spacing: 8
                Label { text: ">"; color: Theme.accent; font.pixelSize: 20; font.weight: Font.Black }
                TextInput {
                    id: search
                    width: 400
                    color: Theme.ink
                    font.family: Theme.font
                    font.weight: Font.ExtraBold
                    font.pixelSize: 18
                    font.capitalization: Font.AllUppercase
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

            Rectangle { width: 448; height: 4; color: Theme.ink; rotation: 0.6; antialiasing: true }

            ListView {
                id: list
                width: 448
                height: 15 * 31
                clip: true
                model: launcher.apps
                highlightMoveDuration: 0
                highlight: Rectangle {
                    color: Qt.alpha(Theme.accent, 0.55)
                    radius: 5
                    rotation: -0.8
                    antialiasing: true
                }

                delegate: Item {
                    id: entry
                    required property var modelData
                    required property int index
                    width: 448
                    height: 31

                    Row {
                        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                        spacing: 10
                        IconImage {
                            source: Quickshell.iconPath(modelData.icon, true)
                            implicitSize: 20
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Label {
                            text: modelData.name
                            color: Theme.ink
                            font.pixelSize: 15
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
