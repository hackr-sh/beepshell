pragma ComponentBehavior: Bound

import Quickshell.Services.SystemTray
import Quickshell
import Quickshell.Widgets
import QtQuick

Repeater {
    id: trayRepeater
    model: SystemTray.items
    required property var parentWindow
    required property var rightPanel

    function closeOtherMenus() {
        console.log("Closing other menus");
        for (let i = 0; i < trayRepeater.count; i++) {
            let item = trayRepeater.itemAt(i);
            if (item.modelData.hasMenu && item.modelData.menu) {
                item.menuOpener.visible = false;
            }
        }
    }

    Rectangle {
        id: trayItem
        required property var modelData
        property var menuOpener: menuOpener
        property bool hovered: false
        width: 32
        height: parent.height
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: trayItem.hovered ? '#003c3c' : "#00003c3c"
            }
            GradientStop {
                position: 1.0
                color: trayItem.hovered ? '#00003c3c' : "#00000000"
            }
        }

        anchors.verticalCenter: parent.verticalCenter

        // Monitor menu changes
        Component.onCompleted: {
            if (trayItem.modelData.hasMenu && trayItem.modelData.menu) {
                // Connect to menu change signals if available
                try {
                    if (trayItem.modelData.menu.menuChanged) {
                        trayItem.modelData.menu.menuChanged.connect(function () {
                            console.log("Menu changed for", trayItem.modelData.title || trayItem.modelData.tooltipTitle || "unnamed");
                            console.log("Menu:", trayItem.modelData.menu);
                        });
                    }
                } catch (e) {
                    console.log("Could not connect to menu signals:", e.toString());
                }
            }
        }

        QsMenuOpener {
            id: menuOpener
            menu: trayItem.modelData.hasMenu ? trayItem.modelData.menu : null
            property var visible: false
        }
        PopupWindow {
            id: menuOpenerWindow
            anchor.window: trayRepeater.parentWindow
            anchor.rect.x: trayRepeater.rightPanel.x + trayItem.x
            anchor.rect.y: trayRepeater.parentWindow.height - trayItem.y
            implicitWidth: menuOpenerRepeater.implicitWidth
            implicitHeight: {
                let height = 0;
                for (let i = 0; i < menuOpenerRepeater.count; i++) {
                    let item = menuOpenerRepeater.itemAt(i);
                    if (item.modelData.isSeparator) {
                        height += 1;
                    } else {
                        height += 30;
                    }
                }
                console.log("Menu opener height:", height);
                return height;
            }
            visible: menuOpener.visible
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                color: "#FF000000"
                radius: 12
                Column {
                    id: menuOpenerRow
                    height: menuOpenerRepeater.count * 30
                    width: parent.width
                    padding: 0
                    spacing: 0
                    Repeater {
                        id: menuOpenerRepeater
                        model: menuOpener.children
                        implicitWidth: {
                            let maxWidth = 0;
                            for (let i = 0; i < menuOpenerRepeater.count; i++) {
                                let item = menuOpenerRepeater.itemAt(i);
                                if (item.textWidth > maxWidth) {
                                    maxWidth = item.textWidth;
                                }
                            }
                            return maxWidth;
                        }
                        Rectangle {
                            id: menuOpenerItem
                            required property var modelData
                            property bool hovered: false
                            property int textWidth: menuOpenerItemText.paintedWidth + 16
                            enabled: modelData.text || modelData.isSeparator === true
                            color: "transparent"
                            height: menuOpenerItem.modelData.isSeparator ? 1 : 30
                            width: menuOpenerRepeater.implicitWidth
                            Text {
                                id: menuOpenerItemText
                                enabled: menuOpenerItem.modelData.text && !menuOpenerItem.modelData.isSeparator
                                anchors.verticalCenter: parent.verticalCenter
                                text: menuOpenerItem.modelData.text
                                color: menuOpenerItem.modelData.enabled ? "white" : "#808080"
                                x: 8
                                font.pixelSize: 12
                                font.bold: true
                                z: 1
                            }
                            Rectangle {
                                enabled: menuOpenerItem.modelData.isSeparator && !menuOpenerItem.modelData.text
                                width: parent.width
                                height: menuOpenerItem.modelData.isSeparator ? 1 : 0
                                color: "#212121"
                                anchors.centerIn: parent
                            }
                            Rectangle {
                                anchors.fill: parent
                                color: (menuOpenerItem.modelData.enabled && !menuOpenerItem.modelData.isSeparator) ? "#003c3c" : "#00000000"
                                anchors.centerIn: parent
                                opacity: menuOpenerItem.hovered ? 0.5 : 0.0
                                radius: 12
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    console.log("Entered", menuOpenerItem.modelData.text);
                                    menuOpenerItem.hovered = true;
                                }
                                onExited: {
                                    console.log("Exited", menuOpenerItem.modelData.text);
                                    menuOpenerItem.hovered = false;
                                }
                                onClicked: {
                                    menuOpenerItem.modelData.triggered();
                                    menuOpener.visible = false;
                                }
                                z: 1000
                            }
                        }
                    }
                }
            }
        }
        Rectangle {
            width: parent.width
            height: 4
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: trayItem.hovered ? "#FFFFFF" : "#00000000"
                }
                GradientStop {
                    position: 1.0
                    color: trayItem.hovered ? "#00FFFFFF" : "#00000000"
                }
            }
            anchors.top: parent.top
        }

        IconImage {
            id: trayIcon
            anchors.centerIn: parent
            width: 20
            height: 20

            source: {
                if (trayItem.modelData.iconPixmap && trayItem.modelData.iconPixmap.length > 0) {
                    return "data:image/png;base64," + trayItem.modelData.iconPixmap;
                }

                if (trayItem.modelData.icon && trayItem.modelData.icon.length > 0) {
                    if (trayItem.modelData.icon.startsWith("image://qspixmap/")) {
                        return trayItem.modelData.icon;
                    }

                    // Handle NixOS paths in icon property
                    if (trayItem.modelData.icon.includes("?path=")) {
                        let nixPath = trayItem.modelData.icon.split("?path=")[1];
                        if (nixPath && nixPath.startsWith("/nix/store/")) {

                            // Try different common icon file patterns
                            let possiblePaths = [nixPath + "/spotify-linux-32.png", nixPath + "/spotify-linux-24.png", nixPath + "/spotify-linux-48.png", nixPath + "/spotify-linux-64.png", nixPath + "/32.png", nixPath + "/32x32.png", nixPath + "/48.png", nixPath + "/48x48.png", nixPath + "/64.png", nixPath + "/64x64.png", nixPath + "/spotify.png", nixPath + "/icon.png"];

                            for (let path of possiblePaths) {
                                return "file://" + path;
                            }
                        }
                    }

                    // Handle temporary file paths (like tailscale)
                    if (trayItem.modelData.icon.startsWith("image://icon/") && trayItem.modelData.icon.includes("/tmp/")) {
                        let tmpPath = trayItem.modelData.icon.replace("image://icon", "");
                        return "file://" + tmpPath;
                    }

                    // Try the icon property as-is (might work for some)
                    return trayItem.modelData.icon;
                }

                // For NixOS, try to extract the actual file path from the iconName
                if (trayItem.modelData.iconName && trayItem.modelData.iconName.includes("?path=")) {
                    let nixPath = trayItem.modelData.iconName.split("?path=")[1];
                    if (nixPath) {
                        // Try different common icon file extensions in the Nix store path
                        let possiblePaths = [nixPath, nixPath + ".png", nixPath + ".svg", nixPath + "/32x32.png", nixPath + "/48x48.png", nixPath + "/64x64.png"];

                        for (let path of possiblePaths) {
                            if (path.startsWith("/nix/store/")) {
                                return "file://" + path;
                            }
                        }
                    }
                }

                // Then try iconName with standard icon lookup
                if (trayItem.modelData.iconName && trayItem.modelData.iconName.length > 0) {
                    // Clean up the icon name - remove path and query parameters
                    let cleanIconName = trayItem.modelData.iconName.split('?')[0].split('/').pop();

                    if (cleanIconName && cleanIconName !== "spotify-linux-32") {
                        return Quickshell.iconPath(cleanIconName);
                    }

                    // For spotify specifically, try common spotify icon names
                    if (cleanIconName === "spotify-linux-32" || trayItem.modelData.iconName.includes("spotify")) {
                        let spotifyIcon = Quickshell.iconPath("spotify", true) || Quickshell.iconPath("spotify-client", true) || Quickshell.iconPath("com.spotify.Client", true) || Quickshell.iconPath("spotify-linux-32", true);
                        if (spotifyIcon) {
                            return spotifyIcon;
                        }
                    }
                    return Quickshell.iconPath(cleanIconName, true) || "";
                }

                return "";
            }

            // Fallback if no icon is available or fails to load
            Rectangle {
                visible: trayIcon.source === "" || trayIcon.status === Image.Error
                anchors.centerIn: parent
                width: 24
                height: 24
                color: "#404040"
                radius: 4
                border.color: "#666666"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (trayItem.modelData.title) {
                            // For spotify, use a music note symbol - check title and icon name
                            if (trayItem.modelData.title.toLowerCase().includes("spotify") || (trayItem.modelData.iconName && trayItem.modelData.iconName.toLowerCase().includes("spotify")) || (trayItem.modelData.icon && trayItem.modelData.icon.toLowerCase().includes("spotify"))) {
                                return "♫";
                            }
                            // For other apps, use first letter
                            return trayItem.modelData.title.charAt(0).toUpperCase();
                        }
                        return "?";
                    }
                    color: "white"
                    font.pixelSize: {
                        if (trayItem.modelData.title && (trayItem.modelData.title.toLowerCase().includes("spotify") || (trayItem.modelData.iconName && trayItem.modelData.iconName.toLowerCase().includes("spotify")) || (trayItem.modelData.icon && trayItem.modelData.icon.toLowerCase().includes("spotify")))) {
                            return 14;
                        }
                        return 12;
                    }
                    font.bold: true
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onEntered: parent.hovered = true
            onExited: parent.hovered = false

            onClicked: mouse => {
                console.log("Clicked on", trayItem.modelData.title || trayItem.modelData.tooltipTitle || "unnamed", "with button:", mouse.button);

                if (mouse.button === Qt.RightButton) {
                    // Context menu activation using QsMenuOpener
                    console.log("Right click - trying to open context menu");

                    if (trayItem.modelData.hasMenu && trayItem.modelData.menu && menuOpener) {
                        console.log("Opening context menu via QsMenuOpener");
                        try {
                            if (menuOpener.visible) {
                                trayRepeater.closeOtherMenus();
                            } else {
                                trayRepeater.closeOtherMenus();
                                menuOpener.visible = true;
                            }
                        } catch (e) {
                            console.log("Error opening menu:", e.toString());
                            if (trayItem.modelData.secondaryActivate) {
                                console.log("Falling back to secondaryActivate()");
                                trayItem.modelData.secondaryActivate();
                            }
                        }
                    } else if (trayItem.modelData.secondaryActivate) {
                        console.log("Calling secondaryActivate()");
                        trayItem.modelData.secondaryActivate();
                    } else if (trayItem.modelData.activate) {
                        console.log("Falling back to activate()");
                        trayItem.modelData.activate();
                    } else {
                        console.log("No context menu method available");
                    }
                } else if (mouse.button === Qt.MiddleButton) {
                    // Middle click activation
                    if (trayItem.modelData.activate) {
                        console.log("Middle click - calling activate()");
                        trayItem.modelData.activate();
                    } else {
                        console.log("No middle click method available");
                    }
                }
            }

            onDoubleClicked: mouse => {
                // Double click activation
                if (trayItem.modelData.activate && mouse.button === Qt.LeftButton) {
                    console.log("Double click - calling activate()");
                    trayItem.modelData.activate();
                }
                if (mouse.button === Qt.RightButton) {
                    menuOpener.visible = !menuOpener.visible;
                }
            }
        }
    }
}
