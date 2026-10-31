pragma Singleton
import QtQuick
import Quickshell

// pictograms on a 24px grid, filled even-odd
Singleton {
    function wave(y) {
        let top = `M2 ${y}`, bottom = "";
        for (let i = 1; i <= 8; i++) top += ` L${2 + i * 2.5} ${y + (i % 2 ? -2 : 0)}`;
        for (let i = 8; i >= 0; i--) bottom += ` L${2 + i * 2.5} ${y + 3 + (i % 2 ? -2 : 0)}`;
        return top + bottom + " Z";
    }

    readonly property var chamber: [
        "M4 4h16v16H4z M6.5 6.5v11h11v-11z M9.5 9.5h5v5h-5z",
        "M10 2h4v5h3.5L12 12.5 6.5 7H10z M6 15h12v7H6z",
        "M3 19h18v3H3z M6 15h12v3H6z M10.5 12h3v2h-3z",
        wave(8) + " " + wave(15),
        "M12 2C16 2 17.5 6.5 17.5 12S16 22 12 22 6.5 17.5 6.5 12 8 2 12 2z M12 9.5a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5z",
        "M12 2a6.5 10 0 1 0 0 20a6.5 10 0 1 0 0-20z M12 5a3.8 7 0 1 0 0 14a3.8 7 0 1 0 0-14z",
        "M12 8a4 4 0 1 0 0 8a4 4 0 1 0 0-8z M11 1h2v4h-2z M11 19h2v4h-2z M1 11h4v2H1z M19 11h4v2h-4z",
        "M3 21C5 10 12 5 19 5V2l4 4.5L19 11V8C13 8 7.5 12 6 21z",
        "M4 13h16v8H4z M11 6h2v6h-2z M12 1.5c1.5 1.5 1.5 3 0 3.8c-1.5-.8-1.5-2.3 0-3.8z",
        "M2 11h5v2H2z M17 11h5v2h-5z M12 7l1.2 3.8L17 12l-3.8 1.2L12 17l-1.2-3.8L7 12l3.8-1.2z",
    ]

    readonly property string lock: "M7.5 10V7.5a4.5 4.5 0 0 1 9 0V10h-2.2V7.5a2.3 2.3 0 0 0-4.6 0V10z M5 10h14v12H5z M11 14h2v4h-2z"
    readonly property string sleep: "M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"
    readonly property string leave: "M4 3h9v4h-2V5H6v14h5v-2h2v4H4z M15 7.5l5 4.5-5 4.5V13H9v-2h6z"
    readonly property string reboot: "M12 5a8 8 0 1 0 8 8h-2.5a5.5 5.5 0 1 1-5.5-5.5V10l4.5-3.75L12 2.5z"
    readonly property string power: "M11 2h2v10h-2z M5.99 6.99L7.4 8.4A6.5 6.5 0 1 0 16.6 8.4L18.01 6.99A8.5 8.5 0 1 1 5.99 6.99z"
}
