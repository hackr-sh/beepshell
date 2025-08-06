import QtQuick

Rectangle {
  color: "#44000000"
  anchors.centerIn: parent
  width: childrenRect.width + 12
  height: childrenRect.height + 12
  radius: 6

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

