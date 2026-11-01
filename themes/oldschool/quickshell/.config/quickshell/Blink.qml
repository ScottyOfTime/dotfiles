import QtQuick

// a block cursor's blink; only runs while something shows it, since every
// toggle redraws its window
Timer {
    property bool on: true

    interval: 530
    repeat: true
    onRunningChanged: on = true
    onTriggered: on = !on
}
