pragma Singleton
import QtQuick
import Quickshell

// pictograms on a 24px grid, filled even-odd
Singleton {
    readonly property string portal: "M12 2a6.5 10 0 1 0 0 20a6.5 10 0 1 0 0-20z M12 5a3.8 7 0 1 0 0 14a3.8 7 0 1 0 0-14z"
    readonly property string play: "M8 5v14l11-7z"
    readonly property string pause: "M6 5h4v14H6z M14 5h4v14h-4z"
    readonly property string previous: "M6 5h2v14H6z M20 5v14L9 12z"
    readonly property string next: "M16 5h2v14h-2z M4 5v14l11-7z"
    readonly property string lock: "M7.5 10V7.5a4.5 4.5 0 0 1 9 0V10h-2.2V7.5a2.3 2.3 0 0 0-4.6 0V10z M5 10h14v12H5z M11 14h2v4h-2z"
    readonly property string sleep: "M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"
    readonly property string leave: "M4 3h9v4h-2V5H6v14h5v-2h2v4H4z M15 7.5l5 4.5-5 4.5V13H9v-2h6z"
    readonly property string reboot: "M12 5a8 8 0 1 0 8 8h-2.5a5.5 5.5 0 1 1-5.5-5.5V10l4.5-3.75L12 2.5z"
    readonly property string power: "M11 2h2v10h-2z M5.99 6.99L7.4 8.4A6.5 6.5 0 1 0 16.6 8.4L18.01 6.99A8.5 8.5 0 1 1 5.99 6.99z"
}
