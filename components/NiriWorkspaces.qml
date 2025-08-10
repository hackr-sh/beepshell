import Quickshell.Io
import QtQuick

Rectangle {
    id: root
    color: "transparent"
    width: workspaceRow.width
    height: parent.height
    radius: 8

    property var workspaces: []
    property alias spacing: workspaceRow.spacing

    // Process to run niri msg to get workspace info
    Process {
        id: niriProcess
        command: ["niri", "msg", "-j", "workspaces"]
        running: false  // Set to false initially, controlled by timer

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text);
                    root.workspaces = result;
                } catch (e) {
                    console.error("Failed to parse niri workspaces:", e);
                }
            }
        }
    }

    // Process for switching workspaces
    Process {
        id: switchProcess
        running: false
    }

    // Timer to refresh workspace info
    Timer {
        id: refreshTimer
        interval: 25  // Refresh every 25ms for better responsiveness
        running: true
        repeat: true

        onTriggered: {
            niriProcess.running = true;
        }
    }

    // Initial load
    Component.onCompleted: {
        niriProcess.running = true;
    }

    function switchToWorkspace(workspaceId) {
        switchProcess.command = ["niri", "msg", "action", "focus-workspace", workspaceId.toString()];
        switchProcess.running = true;
    }

    Row {
        id: workspaceRow
        spacing: 8
        height: parent.height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            id: workspaceRepeater
            model: {
                // Sort workspaces by their index to maintain consistent order (1, 2, 3, 4...)
                if (!root.workspaces)
                    return [];

                var sortedWorkspaces = root.workspaces.slice(); // Create a copy
                sortedWorkspaces.sort(function (a, b) {
                    var aIdx = a.idx !== undefined ? a.idx : (a.id !== undefined ? a.id : 999);
                    var bIdx = b.idx !== undefined ? b.idx : (b.id !== undefined ? b.id : 999);
                    return aIdx - bIdx;
                });
                return sortedWorkspaces;
            }

            Rectangle {
                id: workspaceItem
                property bool isFocused: modelData.is_focused || false
                property bool isActive: modelData.is_active || false
                property bool isUrgent: modelData.is_urgent || false
                property bool hasWindows: modelData.active_window_id !== null
                property bool isHovered: false

                width: Math.max(32, workspaceText.width + 16)
                height: parent.height
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: "#001a1a"
                        }
                        GradientStop {
                            position: 1.0
                            color: "#00001a1a"
                        }
                    }
                    opacity: workspaceItem.hasWindows && !workspaceItem.isFocused && !workspaceItem.isActive ? 1.0 : 0.0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: "#3c0000"
                        }
                        GradientStop {
                            position: 1.0
                            color: "#003c0000"
                        }
                    }
                    opacity: workspaceItem.isUrgent && !workspaceItem.isFocused && !workspaceItem.isActive ? 1.0 : 0.0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: "#003c3c"
                        }
                        GradientStop {
                            position: 1.0
                            color: "#00003c3c"
                        }
                    }
                    opacity: workspaceItem.isFocused || workspaceItem.isActive ? 1.0 : 0.0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }
                


                Rectangle {
                    width: parent.width
                    height: 4
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: (workspaceItem.isActive || workspaceItem.isFocused || workspaceItem.isHovered) ? "#FFFFFFFF" : "#00000000"
                        }
                        GradientStop {
                            position: 1.0
                            color: (workspaceItem.isActive || workspaceItem.isFocused || workspaceItem.isHovered) ? "#00FFFFFF" : "#00000000"
                        }
                    }
                    opacity: workspaceItem.isHovered ? 1.0 : 0.5
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Text {
                    id: workspaceText
                    anchors.centerIn: parent
                    text: modelData.name || modelData.idx || "?"
                    color: {
                        if (parent.isFocused)
                            return "#FFFFFF";
                        if (parent.isUrgent)
                            return "#FFFFFF";
                        return "#808080";
                    }
                    font.pixelSize: 12
                    font.bold: parent.isFocused || parent.isUrgent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        // Switch to workspace using niri action
                        var workspaceId = modelData.idx || modelData.id;
                        if (workspaceId !== undefined) {
                            root.switchToWorkspace(workspaceId);
                        }
                    }
                    onEntered: parent.isHovered = true
                    onExited: parent.isHovered = false
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
