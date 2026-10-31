pragma Singleton
import QtQuick
import Quickshell

// the announcer's lines; `pick` is stable for a given number
Singleton {
    readonly property var notice: [
        "announcement", "attention", "please note", "for your safety",
        "enrichment center update", "a message for the test subject",
    ]
    readonly property var launcher: [
        "all apparatus are tested for your safety",
        "please select an apparatus to continue testing",
        "the enrichment center supports your choice",
        "apparatus may not be returned once launched",
        "do not look directly at the operational end of the apparatus",
        "cake will be provided at the conclusion of testing",
    ]
    readonly property var power: [
        "the enrichment center thanks you for your participation",
        "testing will resume shortly",
        "please remain in the relaxation vault until notified",
        "this was a triumph",
    ]

    function pick(list, n) {
        return list[Math.abs(Math.floor(n)) % list.length];
    }
}
