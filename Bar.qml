import Quickshell
import QtQuick

Scope {

    Variants {
        model: Quickshell.screens

        PanelWindow {
            mask: Region {
                Region {
                    item: tray
                }
                Region {
                    item: workspaces
                }
                Region {
                    item: clock
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
                id: workspaces
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
            }

            ClockWidget {
                id: clock
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            Tray {
                id: tray
                anchors.right: parent.right
                anchors.rightMargin: 12
            }
        }
    }
}
