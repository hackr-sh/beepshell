import Quickshell
import QtQuick
import Quickshell.Widgets
import Quickshell.Io

Rectangle {
    id: rootPowerButton
    width: parent.height
    height: parent.height
    color: "transparent"

    property bool isHovered: false

    Process {
        id: powerProcess
        command: ["wlogout"]
        running: false
    }

    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 4
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#FFFFFFFF"
            }
            GradientStop {
                position: 1.0
                color: "#00000000"
            }
        }
        opacity: rootPowerButton.isHovered ? 1.0 : 0.0
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
        opacity: rootPowerButton.isHovered ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
    }

    IconImage {
        anchors.centerIn: parent
        source: Quickshell.iconPath(Quickshell.shellDir + "/icons/power-0.svg")
        width: 20
        height: 20
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            // TODO: Eventually we want to build a power menu inside of quickshell (perhaps even the same bar)
            powerProcess.running = true;
        }
        onEntered: {
            rootPowerButton.isHovered = true;
        }
        onExited: {
            rootPowerButton.isHovered = false;
        }
    }
}
