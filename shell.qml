//@ pragma UseQApplication

import Quickshell
import QtQuick
import "./components"
import "./services"

ShellRoot {
  Bar {}
  
  // Global notification toast
  SimpleNotificationToast {
    id: globalNotificationToast
  }
  
  // Connect to notification service
  Connections {
    target: Notifications
    function onNotificationAdded(notification) {
      globalNotificationToast.showNotification(notification);
    }
  }
}