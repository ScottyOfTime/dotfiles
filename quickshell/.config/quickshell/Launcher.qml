import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: launcher

    property int seed: 0
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
        const last = seed;
        while (seed === last || seed % 7 === last % 7)
            seed = Math.floor(Math.random() * 1000);
        search.text = "";
        list.currentIndex = 0;
        visible = true;
        shown = true;
        search.forceActiveFocus();
    }

    function close() {
        shown = false;
        hideAfterSlide.restart();
    }

    function launch(app) {
        if (!app) return;
        app.execute();
        close();
    }

    visible: false
    color: "transparent"
    anchors.bottom: true
    implicitWidth: 560
    implicitHeight: 640
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

    Timer { id: hideAfterSlide; interval: 220; onTriggered: launcher.visible = false }

    // rises from below the screen edge and settles just above it
    Scrap {
        id: scrap
        anchors.horizontalCenter: parent.horizontalCenter
        y: launcher.shown ? launcher.height - height - 36 : launcher.height + 30
        Behavior on y {
            NumberAnimation {
                duration: launcher.shown ? 420 : 200
                easing.type: launcher.shown ? Easing.OutBack : Easing.InCubic
                easing.overshoot: 1.4
            }
        }
        seed: launcher.seed
        tilt: (launcher.seed % 7) - 3
        ragged: 9
        shadow: 7
        padX: 24
        padY: 22
        tape: true
        tapeWidth: 110
        supersample: true

        Column {
            spacing: 12

            Row {
                spacing: 8
                Label { text: "›"; color: Theme.accent; font.pixelSize: 18 }
                TextInput {
                    id: search
                    width: 400
                    color: Theme.ink
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
                }
            }

            Rectangle { width: 440; height: 2; color: Theme.ink }

            ListView {
                id: list
                width: 440
                height: 15 * 30
                clip: true
                model: launcher.apps
                highlightMoveDuration: 120
                highlight: Rectangle {
                    color: Theme.accent
                    rotation: -1
                    antialiasing: true
                }

                delegate: Item {
                    required property var modelData
                    required property int index
                    width: 440
                    height: 30

                    Row {
                        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                        spacing: 10
                        IconImage {
                            source: Quickshell.iconPath(modelData.icon, true)
                            implicitSize: 20
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Label { text: modelData.name; anchors.verticalCenter: parent.verticalCenter }
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
