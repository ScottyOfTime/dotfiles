import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Strip {
    id: menu

    required property var lock
    readonly property var actions: [
        () => menu.lock.lockNow(),
        () => Quickshell.execDetached(["systemctl", "suspend"]),
        () => Hyprland.dispatch("hl.dsp.exit()"),
        () => Quickshell.execDetached(["systemctl", "reboot"]),
        () => Quickshell.execDetached(["systemctl", "poweroff"]),
    ]

    prompt: "session"
    space: "powermenu"
    searchable: false
    items: ["lock", "suspend", "log out", "reboot", "shut down"]
    onChosen: i => {
        close();
        actions[i]();
    }

    IpcHandler {
        target: "power"
        function toggle(): void { menu.toggle(); }
    }
}
