import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: root
    color: "transparent"
    width: workspaceRow.width
    height: 32

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
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            id: workspaceRepeater
            model: {
                // Sort workspaces by their index to maintain consistent order (1, 2, 3, 4...)
                if (!root.workspaces) return []
                
                var sortedWorkspaces = root.workspaces.slice() // Create a copy
                sortedWorkspaces.sort(function(a, b) {
                    var aIdx = a.idx !== undefined ? a.idx : (a.id !== undefined ? a.id : 999)
                    var bIdx = b.idx !== undefined ? b.idx : (b.id !== undefined ? b.id : 999)
                    return aIdx - bIdx
                })
                return sortedWorkspaces
            }

            Rectangle {
                property bool isFocused: modelData.is_focused || false
                property bool isActive: modelData.is_active || false
                property bool isUrgent: modelData.is_urgent || false
                property bool hasWindows: modelData.active_window_id !== null

                width: Math.max(32, workspaceText.width + 16)
                height: 24
                radius: 6

                // Dynamic colors based on state
                color: {
                    if (isFocused) return "#7fc8ff"
                    if (isActive) return "#4a90e2"
                    if (isUrgent) return "#ff6b6b"
                    if (hasWindows) return "#333333"
                    return "#1a1a1a"
                }

                border.width: 2
                border.color: {
                    if (isFocused) return "#bbddff"
                    if (isActive) return "#6bb6ff"
                    if (isUrgent) return "#ff8e8e"
                    if (hasWindows) return "#555555"
                    return "#2a2a2a"
                }

                // Subtle gradient effect
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.lighter(parent.color, 1.1)
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.darker(parent.color, 1.1)
                    }
                }

                Text {
                    id: workspaceText
                    anchors.centerIn: parent
                    text: modelData.name || modelData.idx || "?"
                    color: {
                        if (parent.isFocused) return "#FFFFFF"
                        if (parent.isUrgent) return "#FFFFFF"
                        return "#808080"
                    }
                    font.pixelSize: 12
                    font.bold: parent.isFocused || parent.isUrgent
                }

                // Urgent indicator
                Rectangle {
                    visible: parent.isUrgent
                    width: 6
                    height: 6
                    radius: 3
                    color: "#ff6b6b"
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 2
                    anchors.rightMargin: 2
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    
                    onEntered: parent.opacity = 0.8
                    onExited: parent.opacity = 1.0
                    
                    onClicked: {
                        // Switch to workspace using niri action
                        var workspaceId = modelData.idx || modelData.id;
                        if (workspaceId !== undefined) {
                            root.switchToWorkspace(workspaceId);
                        }
                    }
                }

                // Smooth transitions
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
} 