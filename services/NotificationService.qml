pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: notificationService

    property var notifications: []
    property int nextId: 1
    property bool hasUnread: false
    property int unreadCount: 0

    signal notificationAdded(var notification)
    signal notificationRemoved(int id)
    signal notificationCleared()

    // Quickshell notification server to receive system notifications
    NotificationServer {
        id: notificationServer
        
        // Enable various notification capabilities
        imageSupported: true
        actionsSupported: true
        
        onNotification: function(notification) {
            notificationService.handleSystemNotification(notification);
        }
    }

    function handleSystemNotification(notification) {
        // Mark the notification to be tracked by the server
        notification.tracked = true;
        
        // Extract notification data
        var notificationData = {
            id: nextId++,
            timestamp: new Date(),
            title: notification.summary || "Notification",
            body: notification.body || "",
            appName: notification.appName || "Unknown App",
            icon: notification.icon || "",
            urgency: notification.urgency || "normal",
            originalNotification: notification
        };
        
        console.log("Received system notification:", notificationData.title, "from", notificationData.appName);
        addNotification(notificationData);
    }

    function addNotification(notification) {
        notifications.push(notification);
        hasUnread = true;
        unreadCount++;
        
        notificationAdded(notification);
        console.log("Notification added:", notification.title);
    }

    function removeNotification(id) {
        for (var i = 0; i < notifications.length; i++) {
            if (notifications[i].id === id) {
                notifications.splice(i, 1);
                notificationRemoved(id);
                updateUnreadCount();
                console.log("Notification removed:", id);
                break;
            }
        }
    }

    function clearAllNotifications() {
        notifications = [];
        hasUnread = false;
        unreadCount = 0;
        notificationCleared();
        console.log("All notifications cleared");
    }

    function markAsRead() {
        hasUnread = false;
        unreadCount = 0;
    }

    function updateUnreadCount() {
        unreadCount = notifications.length;
        hasUnread = unreadCount > 0;
    }

    // Access to tracked notifications from the server
    property alias trackedNotifications: notificationServer.trackedNotifications
    
    // Test notification function for debugging
    function createTestNotification() {
        addNotification({
            id: nextId++,
            timestamp: new Date(),
            title: "Test Notification",
            body: "This is a test notification from Quickshell",
            appName: "Quickshell",
            urgency: "normal"
        });
    }
    
    Component.onCompleted: {
        console.log("Notification service initialized with NotificationServer");
        console.log("Ready to receive system notifications");
        
        // Add a welcome notification
        addNotification({
            id: nextId++,
            timestamp: new Date(),
            title: "Quickshell Notifications",
            body: "System notification monitoring is now active",
            appName: "Quickshell",
            urgency: "normal"
        });
    }
}
