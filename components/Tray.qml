import Quickshell.Services.SystemTray
import Quickshell
import Quickshell.Widgets
import QtQuick

Repeater {
    model: SystemTray.items

    Rectangle {
        id: trayItem
        required property var modelData
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
            if (modelData.hasMenu && modelData.menu) {
                // Connect to menu change signals if available
                try {
                    if (modelData.menu.menuChanged) {
                        modelData.menu.menuChanged.connect(function () {
                            console.log("Menu changed for", modelData.title || modelData.tooltipTitle || "unnamed");
                        });
                    }
                } catch (e) {
                    console.log("Could not connect to menu signals:", e.toString());
                }
            }
        }

        // QsMenuAnchor for context menu
        QsMenuAnchor {
            id: menuAnchor
            menu: trayItem.modelData.hasMenu ? trayItem.modelData.menu : null
            anchor.item: mouseArea
            anchor.edges: Qt.BottomEdge | Qt.RightEdge
            anchor.gravity: Qt.LeftEdge | Qt.BottomEdge
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

            // Only log debug info if this is the first time we see this item
            source: {
                if (!trayItem.modelData._debugLogged) {
                    trayItem.modelData._debugLogged = true;

                    // Debug logging to see what we're getting - including ALL properties
                    console.log("=== Tray item debug for:", trayItem.modelData.title, "===");
                    console.log("iconName:", trayItem.modelData.iconName);
                    console.log("iconPixmap length:", trayItem.modelData.iconPixmap ? trayItem.modelData.iconPixmap.length : "null");
                    console.log("icon:", trayItem.modelData.icon);
                    console.log("tooltip:", trayItem.modelData.tooltip);
                    console.log("status:", trayItem.modelData.status);
                    console.log("category:", trayItem.modelData.category);

                    // Look for menu/activation properties
                    console.log("--- Activation properties ---");
                    console.log("activate:", typeof trayItem.modelData.activate);
                    console.log("activateSecondary:", typeof trayItem.modelData.activateSecondary);
                    console.log("menu:", typeof trayItem.modelData.menu);
                    console.log("contextMenu:", typeof trayItem.modelData.contextMenu);
                    console.log("menuOpen:", typeof trayItem.modelData.menuOpen);
                    console.log("showMenu:", typeof trayItem.modelData.showMenu);
                    console.log("openMenu:", typeof trayItem.modelData.openMenu);
                    console.log("popup:", typeof trayItem.modelData.popup);
                    console.log("popupMenu:", typeof trayItem.modelData.popupMenu);

                    // Log all available properties
                    console.log("--- All properties ---");
                    for (let prop in trayItem.modelData) {
                        try {
                            console.log(prop + ":", typeof trayItem.modelData[prop], trayItem.modelData[prop]);
                        } catch (e) {
                            console.log(prop + ": (error accessing)", e.toString());
                        }
                    }
                    console.log("=== End debug ===");
                }

                // First try iconPixmap if available (most reliable)
                if (trayItem.modelData.iconPixmap && trayItem.modelData.iconPixmap.length > 0) {
                    return "data:image/png;base64," + trayItem.modelData.iconPixmap;
                }

                // Handle icon property
                if (trayItem.modelData.icon && trayItem.modelData.icon.length > 0) {
                    // Handle qspixmap URLs (these should work directly)
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

                    if (trayItem.modelData.hasMenu && trayItem.modelData.menu && menuAnchor) {
                        console.log("Opening context menu via QsMenuAnchor");
                        try {
                            menuAnchor.open();
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

            onDoubleClicked: {
                // Double click activation
                if (trayItem.modelData.activate) {
                    console.log("Double click - calling activate()");
                    trayItem.modelData.activate();
                }
            }
        }
    }
}
