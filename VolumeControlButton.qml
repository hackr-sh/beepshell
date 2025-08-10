import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Widgets

Rectangle {
    id: volumeControlButton
    width: parent.height
    height: parent.height
    color: "transparent"

    property var volume: 0.0
    Timer {
        id: volumeControlTimer
        interval: 150
        running: true
        repeat: true
        onTriggered: {
            volumeControlProcess.running = true;
        }
    }

    Process {
        id: volumeControlProcess
        command: ["amixer", "sget", "Master"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = text.split("\n").filter(line => line.includes("Left:"))[0].split("[")[1].split("%")[0];
                    var resultAsNumber = parseFloat(result) / 100.0;
                    volumeControlButton.volume = resultAsNumber;
                } catch (e) {
                    console.error("Failed to parse volume:", e);
                }
            }
        }
    }

    IconImage {
        anchors.centerIn: parent
        width: 20
        height: 20
        source: {
          if (volumeControlButton.volume > 0.66) {
            return Quickshell.iconPath(Quickshell.shellDir + "/icons/vol-2.svg")
          } else if (volumeControlButton.volume > 0.33) {
            return Quickshell.iconPath(Quickshell.shellDir + "/icons/vol-1.svg")
          } else {
            return Quickshell.iconPath(Quickshell.shellDir + "/icons/vol-0.svg")
          }
        }
    }
}