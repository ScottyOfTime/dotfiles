import QtQuick
import Quickshell
import Quickshell.Io

Strip {
    id: launcher

    readonly property var apps: DesktopEntries.applications.values
        .filter(a => !a.noDisplay && a.name.toLowerCase().includes(query.toLowerCase()))
        .sort((a, b) => {
            const q = query.toLowerCase();
            const pa = a.name.toLowerCase().startsWith(q), pb = b.name.toLowerCase().startsWith(q);
            return pa === pb ? a.name.localeCompare(b.name) : pa ? -1 : 1;
        })

    prompt: "run"
    space: "launcher"
    items: apps.map(a => a.name)
    onChosen: i => {
        apps[i]?.execute();
        close();
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { launcher.toggle(); }
    }
}
