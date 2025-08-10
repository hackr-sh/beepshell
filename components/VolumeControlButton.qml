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
    property var isHovered: false

    Timer {
        id: volumeControlTimer
        interval: 150
        running: true
        repeat: true
        onTriggered: {
            volumeControlProcess.running = true;
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        height: 4
        width: parent.width
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "white"
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
        opacity: volumeControlButton.isHovered ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
        z: 1
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#FF003C3C"
            }
            GradientStop {
                position: 1.0
                color: "#00003C3C"
            }
        }
        opacity: volumeControlButton.isHovered ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
        z: 0
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

    Process {
        id: launchPavucontrolProcess
        command: ["pavucontrol"]
        running: false
    }

    IconImage {
        anchors.centerIn: parent
        width: 20
        height: 20
        source: {
            if (volumeControlButton.volume > 0.66) {
                return Quickshell.iconPath(Quickshell.shellDir + "/icons/vol-2.svg");
            } else if (volumeControlButton.volume > 0.33) {
                return Quickshell.iconPath(Quickshell.shellDir + "/icons/vol-1.svg");
            } else {
                return Quickshell.iconPath(Quickshell.shellDir + "/icons/vol-0.svg");
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            volumeControlButton.isHovered = true;
        }
        onExited: {
            volumeControlButton.isHovered = false;
        }
        onDoubleClicked: {
            launchPavucontrolProcess.running = true;
        }
    }
}
