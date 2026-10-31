pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// cpu, memory, network and the rest from /proc and /sys, every two seconds
Singleton {
    id: stats

    property int cpu: 0
    property int mem: 0
    property real memUsed: 0
    property real memTotal: 0
    property int swap: 0
    property string net: "0B/s"
    property string down: "0B/s"
    property string up: "0B/s"
    property string load: "0.00"
    property real freq: 0
    property int temp: 0
    property real uptime: 0
    property real diskUsed: 0
    property real diskTotal: 0
    property var cpuHistory: []
    property var downHistory: []
    readonly property int historyLength: 48

    property var lastCpu: [0, 0]
    property real lastRx: -1
    property real lastTx: -1

    function rate(bytes) {
        const units = ["B", "K", "M", "G"];
        let i = 0;
        while (bytes >= 1024 && i < units.length - 1) { bytes /= 1024; i++; }
        return (i ? bytes.toFixed(1) : Math.round(bytes)) + units[i] + "/s";
    }

    function gib(bytes) {
        return (bytes / 1073741824).toFixed(1);
    }

    function since(seconds) {
        const h = Math.floor(seconds / 3600), m = Math.floor(seconds % 3600 / 60);
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    function push(list, value) {
        const next = list.concat([value]);
        return next.length > historyLength ? next.slice(next.length - historyLength) : next;
    }

    FileView { id: stat; path: "/proc/stat"; blockLoading: true }
    FileView { id: meminfo; path: "/proc/meminfo"; blockLoading: true }
    FileView { id: netdev; path: "/proc/net/dev"; blockLoading: true }
    FileView { id: loadavg; path: "/proc/loadavg"; blockLoading: true }
    FileView { id: cpuinfo; path: "/proc/cpuinfo"; blockLoading: true }
    FileView { id: uptimeFile; path: "/proc/uptime"; blockLoading: true }
    FileView { id: sensor; blockLoading: true }

    // hwmon numbering changes between boots, so find the cpu sensor by name
    Process {
        running: true
        command: ["sh", "-c", "grep -lE '^(k10temp|coretemp)$' /sys/class/hwmon/*/name | head -1"]
        stdout: StdioCollector {
            onStreamFinished: if (text.trim()) sensor.path = text.trim().replace(/name$/, "temp1_input")
        }
    }

    Process {
        id: df
        command: ["df", "-B1", "--output=used,size", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split("\n").pop().trim().split(/\s+/).map(Number);
                stats.diskUsed = f[0];
                stats.diskTotal = f[1];
            }
        }
    }
    Timer { interval: 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: df.running = true }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            stat.reload(); meminfo.reload(); netdev.reload(); loadavg.reload();
            cpuinfo.reload(); uptimeFile.reload();
            if (sensor.path != "") sensor.reload();

            const c = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = c[3] + c[4], total = c.reduce((a, b) => a + b, 0);
            const dt = total - lastCpu[1];
            if (dt > 0) cpu = Math.round(100 * (1 - (idle - lastCpu[0]) / dt));
            lastCpu = [idle, total];
            cpuHistory = push(cpuHistory, cpu);

            const m = {};
            for (const l of meminfo.text().split("\n")) {
                const [k, v] = l.split(":");
                if (v) m[k] = parseInt(v);
            }
            mem = Math.round(100 * (1 - m.MemAvailable / m.MemTotal));
            memTotal = m.MemTotal * 1024;
            memUsed = (m.MemTotal - m.MemAvailable) * 1024;
            swap = m.SwapTotal > 0 ? Math.round(100 * (1 - m.SwapFree / m.SwapTotal)) : 0;

            let rx = 0, tx = 0;
            for (const l of netdev.text().split("\n").slice(2)) {
                const [name, rest] = l.split(":");
                if (!rest || name.trim() === "lo") continue;
                const f = rest.trim().split(/\s+/).map(Number);
                rx += f[0];
                tx += f[8];
            }
            if (lastRx >= 0) {
                down = rate((rx - lastRx) / 2);
                up = rate((tx - lastTx) / 2);
                net = down;
                downHistory = push(downHistory, (rx - lastRx) / 2);
            }
            lastRx = rx;
            lastTx = tx;

            load = loadavg.text().split(" ")[0];
            const mhz = cpuinfo.text().split("\n").filter(l => l.startsWith("cpu MHz")).map(l => parseFloat(l.split(":")[1]));
            if (mhz.length) freq = mhz.reduce((a, b) => a + b, 0) / mhz.length / 1000;
            uptime = parseFloat(uptimeFile.text().split(" ")[0]);
            if (sensor.path != "") temp = Math.round(parseInt(sensor.text()) / 1000);
        }
    }
}
