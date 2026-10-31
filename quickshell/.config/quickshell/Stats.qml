pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// cpu, memory and network rates from /proc, every two seconds
Singleton {
    property int cpu: 0
    property int mem: 0
    property string net: "0B/s"

    property var lastCpu: [0, 0]
    property real lastRx: -1

    function rate(bytes) {
        const units = ["B", "K", "M", "G"];
        let i = 0;
        while (bytes >= 1024 && i < units.length - 1) { bytes /= 1024; i++; }
        return (i ? bytes.toFixed(1) : Math.round(bytes)) + units[i] + "/s";
    }

    FileView { id: stat; path: "/proc/stat" }
    FileView { id: meminfo; path: "/proc/meminfo" }
    FileView { id: netdev; path: "/proc/net/dev" }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            stat.reload(); meminfo.reload(); netdev.reload();

            const c = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = c[3] + c[4], total = c.reduce((a, b) => a + b, 0);
            const dt = total - lastCpu[1];
            if (dt > 0) cpu = Math.round(100 * (1 - (idle - lastCpu[0]) / dt));
            lastCpu = [idle, total];

            const m = {};
            for (const l of meminfo.text().split("\n")) {
                const [k, v] = l.split(":");
                if (v) m[k] = parseInt(v);
            }
            mem = Math.round(100 * (1 - m.MemAvailable / m.MemTotal));

            let rx = 0;
            for (const l of netdev.text().split("\n").slice(2)) {
                const [name, rest] = l.split(":");
                if (rest && name.trim() !== "lo") rx += Number(rest.trim().split(/\s+/)[0]);
            }
            if (lastRx >= 0) net = rate((rx - lastRx) / 2);
            lastRx = rx;
        }
    }
}
