import QtQuick
import "./Time.qml"

Rectangle {
  anchors.centerIn: parent
  width: childrenRect.width + 12
  height: parent.height
  gradient: Gradient {
    GradientStop { position: 0.0; color: "#44000000" }
    GradientStop { position: 1.0; color: "#00000000" }
  }

  Rectangle {
    width: parent.width
    height: 4
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#FFFFFFFF" }
      GradientStop { position: 1.0; color: "#00FFFFFF" }
    }
    opacity: 0.5
  }

  Row {
    anchors.centerIn: parent
    spacing: 6
    Text {
      text: Time.time
      color: "white"
      font.pixelSize: 16
    }
  }
}

