import QtQuick
import "./Time.qml"

Rectangle {
  anchors.centerIn: parent
  height: parent.height
  color: "transparent"

  Rectangle {
    width: clockRow.width + 50
    anchors.horizontalCenter: parent.horizontalCenter
    height: parent.height
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#44000000" }
      GradientStop { position: 1.0; color: "#00000000" }
    }
  }
    

  Rectangle {
    width: clockRow.width + 50
    anchors.horizontalCenter: parent.horizontalCenter
    height: 4
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#FFFFFFFF" }
      GradientStop { position: 1.0; color: "#00FFFFFF" }
    }
    opacity: 0.5
  }

  Row {
    id: clockRow
    anchors.centerIn: parent
    spacing: 6
    Text {
      text: Time.time
      color: "white"
      font.pixelSize: 16
    }
  }
}

