pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// facts for tty-style text: host, kernel, user and distro, read once
Singleton {
    // /proc always has the hostname; /etc/hostname is missing on some systems
    readonly property string host: hostname.text().trim()
    readonly property string kernel: release.text().trim()
    readonly property string user: Quickshell.env("USER") ?? ""
    readonly property string distro: ((osRelease.text().match(/^NAME="?([^"\n]*)/m) ?? ["", "linux"])[1]).toLowerCase()

    FileView { id: hostname; path: "/proc/sys/kernel/hostname"; blockLoading: true }
    FileView { id: release; path: "/proc/sys/kernel/osrelease"; blockLoading: true }
    FileView { id: osRelease; path: "/etc/os-release"; blockLoading: true }
}
