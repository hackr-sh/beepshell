import Quickshell
import QtQuick
import QtQuick.Layouts

// Simple notification toast using basic window
PanelWindow {
    id: notificationToast

    property var notification: null
    property bool isVisible: false
    property bool isHovered: false

    screen: Quickshell.screens[0]

    // Position at top-right
    anchors {
        top: true
        right: true
    }

    margins {
        top: 4   // Below the bar
        right: 6
    }

    implicitWidth: 500
    implicitHeight: 150

    visible: isVisible && notification !== null
    color: "transparent"

    // Auto-hide timer
    Timer {
        id: autoHideTimer
        interval: 3000
        running: notificationToast.visible && !notificationToast.isHovered
        onTriggered: notificationToast.hideNotification()
        onRunningChanged: {
            if (!running) {
                notificationToast.countdownElapsed = 0;
            }
        }
    }

    property var countdownElapsed: 0

    Timer {
        id: autoHideTimerCountdown
        interval: 25
        running: autoHideTimer.running
        repeat: true
        onTriggered: {
            notificationToast.countdownElapsed += 25;
        }
    }    

    function showNotification(notif) {
        notification = notif;
        isVisible = true;
        autoHideTimer.restart();
    }

    function hideNotification() {
        isVisible = false;
    }

    Rectangle {
        id: notificationToastContentRect
        anchors.fill: parent
        anchors.margins: 10
        width: 500
        height: 150

        color: "#E6000000"  // Semi-transparent black
        radius: 12

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 12
            width: (parent.width * notificationToast.countdownElapsed / 3000) - 24
            height: 2
            color: "#404040"
        }

        MouseArea {
            anchors.fill: notificationToastContentRect
            hoverEnabled: true
            onEntered: {
                console.log("Entered");
                notificationToast.isHovered = true;
            }
            onExited: {
                console.log("Exited");
                notificationToast.isHovered = false;
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8

                // Header with title and close button
                Row {
                    width: 500 - 20 - 30
                    spacing: 10

                    Text {
                        text: notificationToast.notification ? notificationToast.notification.title : ""
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                        width: parent.width - 30
                        wrapMode: Text.WordWrap
                    }

                    Rectangle {
                        id: closeAreaRect
                        width: 20
                        height: 20
                        color: closeAreaMouseArea.pressed ? "#FF6666" : (closeAreaMouseArea.isHovered ? "#FF4444" : "transparent")
                        radius: 4

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        MouseArea {
                            id: closeAreaMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: notificationToast.hideNotification()
                            property bool isHovered: false
                            onEntered: isHovered = true
                            onExited: isHovered = false
                        }
                    }
                }

                // Body text
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    maximumLineCount: 3
                    text: notificationToast.notification ? notificationToast.notification.body : ""
                    color: "#EEEEEE"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }

                // App name and time
                Row {
                    spacing: 10
                    Text {
                        text: notificationToast.notification ? (notificationToast.notification.appName || "Unknown App") : ""
                        color: "#AAAAAA"
                        font.pixelSize: 10
                        font.italic: true
                    }
                    Text {
                        text: notificationToast.notification ? Qt.formatTime(notificationToast.notification.timestamp, "hh:mm") : ""
                        color: "#CCCCCC"
                        font.pixelSize: 10
                    }
                }
            }
        }

        // Click to dismiss
        MouseArea {
            anchors.fill: parent
            onClicked: notificationToast.hideNotification()
            z: -1
        }
    }

    // Fade-in animation
    Behavior on visible {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
}
