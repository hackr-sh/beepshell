import Quickshell
import Quickshell.Io
import QtQuick

Scope {

  Variants {
    model: Quickshell.screens

    PanelWindow {
      property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      height: 64
      color: "black"

      NiriWorkspaces {
        id: workspaces
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
      }

      ClockWidget {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
      }

      Tray {
      }
    }
  }
}