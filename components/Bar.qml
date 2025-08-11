import Quickshell
import QtQuick

Scope {

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: topBarPanelWindow
            mask: Region {
                Region {
                    item: leftWidget
                }
                Region {
                    item: centerWidget
                }
                Region {
                    item: rightRow
                }
            }

            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 48
            color: "transparent"

            NiriWorkspaces {
                id: leftWidget
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
            }

            ClockWidget {
                id: centerWidget
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            Row {
                id: rightRow
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                width: childrenRect.width
                height: parent.height
                spacing: 6

                Tray {
                    id: tray
                    parentWindow: topBarPanelWindow
                    rightPanel: rightRow
                }

                Rectangle {
                    width: childrenRect.width
                    height: parent.height
                    color: "transparent"

                    Row {
                        width: childrenRect.width
                        height: parent.height
                        anchors.centerIn: parent
                        spacing: 0
                        VolumeControlButton {
                            id: volumeControlButton
                        }

                        PowerButton {
                            id: powerButton
                        }
                    }
                }
            }
        }
    }
}
