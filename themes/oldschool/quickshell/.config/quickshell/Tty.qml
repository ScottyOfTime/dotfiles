import QtQuick
import Quickshell
import Quickshell.Io

// facts for tty-style text: host, kernel, user, and a blinking cursor
Item {
    id: tty

    readonly property string host: hostname.text().trim()
    readonly property string kernel: release.text().trim()
    readonly property string user: Quickshell.env("USER") ?? ""
    property bool blink: true

    FileView { id: hostname; path: "/etc/hostname"; blockLoading: true }
    FileView { id: release; path: "/proc/sys/kernel/osrelease"; blockLoading: true }
    Timer { interval: 530; running: true; repeat: true; onTriggered: tty.blink = !tty.blink }
}
