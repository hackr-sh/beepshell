import Quickshell.Services.SystemTray
import Quickshell
import Quickshell.Widgets
import QtQuick

Repeater {
    model: SystemTray.items

    Rectangle {
        id: trayItem
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
            menu: modelData.hasMenu ? modelData.menu : null
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
                if (!modelData._debugLogged) {
                    modelData._debugLogged = true;

                    // Debug logging to see what we're getting - including ALL properties
                    console.log("=== Tray item debug for:", modelData.title, "===");
                    console.log("iconName:", modelData.iconName);
                    console.log("iconPixmap length:", modelData.iconPixmap ? modelData.iconPixmap.length : "null");
                    console.log("icon:", modelData.icon);
                    console.log("tooltip:", modelData.tooltip);
                    console.log("status:", modelData.status);
                    console.log("category:", modelData.category);

                    // Look for menu/activation properties
                    console.log("--- Activation properties ---");
                    console.log("activate:", typeof modelData.activate);
                    console.log("activateSecondary:", typeof modelData.activateSecondary);
                    console.log("menu:", typeof modelData.menu);
                    console.log("contextMenu:", typeof modelData.contextMenu);
                    console.log("menuOpen:", typeof modelData.menuOpen);
                    console.log("showMenu:", typeof modelData.showMenu);
                    console.log("openMenu:", typeof modelData.openMenu);
                    console.log("popup:", typeof modelData.popup);
                    console.log("popupMenu:", typeof modelData.popupMenu);

                    // Log all available properties
                    console.log("--- All properties ---");
                    for (let prop in modelData) {
                        try {
                            console.log(prop + ":", typeof modelData[prop], modelData[prop]);
                        } catch (e) {
                            console.log(prop + ": (error accessing)", e.toString());
                        }
                    }
                    console.log("=== End debug ===");
                }

                // First try iconPixmap if available (most reliable)
                if (modelData.iconPixmap && modelData.iconPixmap.length > 0) {
                    return "data:image/png;base64," + modelData.iconPixmap;
                }

                // Handle icon property
                if (modelData.icon && modelData.icon.length > 0) {
                    // Handle qspixmap URLs (these should work directly)
                    if (modelData.icon.startsWith("image://qspixmap/")) {
                        return modelData.icon;
                    }

                    // Handle NixOS paths in icon property
                    if (modelData.icon.includes("?path=")) {
                        let nixPath = modelData.icon.split("?path=")[1];
                        if (nixPath && nixPath.startsWith("/nix/store/")) {

                            // Try different common icon file patterns
                            let possiblePaths = [nixPath + "/spotify-linux-32.png", nixPath + "/spotify-linux-24.png", nixPath + "/spotify-linux-48.png", nixPath + "/spotify-linux-64.png", nixPath + "/32.png", nixPath + "/32x32.png", nixPath + "/48.png", nixPath + "/48x48.png", nixPath + "/64.png", nixPath + "/64x64.png", nixPath + "/spotify.png", nixPath + "/icon.png"];

                            for (let path of possiblePaths) {
                                return "file://" + path;
                            }
                        }
                    }

                    // Handle temporary file paths (like tailscale)
                    if (modelData.icon.startsWith("image://icon/") && modelData.icon.includes("/tmp/")) {
                        let tmpPath = modelData.icon.replace("image://icon", "");
                        return "file://" + tmpPath;
                    }

                    // Try the icon property as-is (might work for some)
                    return modelData.icon;
                }

                // For NixOS, try to extract the actual file path from the iconName
                if (modelData.iconName && modelData.iconName.includes("?path=")) {
                    let nixPath = modelData.iconName.split("?path=")[1];
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
                if (modelData.iconName && modelData.iconName.length > 0) {
                    // Clean up the icon name - remove path and query parameters
                    let cleanIconName = modelData.iconName.split('?')[0].split('/').pop();

                    if (cleanIconName && cleanIconName !== "spotify-linux-32") {
                        return Quickshell.iconPath(cleanIconName);
                    }

                    // For spotify specifically, try common spotify icon names
                    if (cleanIconName === "spotify-linux-32" || modelData.iconName.includes("spotify")) {
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
                        if (modelData.title) {
                            // For spotify, use a music note symbol - check title and icon name
                            if (modelData.title.toLowerCase().includes("spotify") || (modelData.iconName && modelData.iconName.toLowerCase().includes("spotify")) || (modelData.icon && modelData.icon.toLowerCase().includes("spotify"))) {
                                return "♫";
                            }
                            // For other apps, use first letter
                            return modelData.title.charAt(0).toUpperCase();
                        }
                        return "?";
                    }
                    color: "white"
                    font.pixelSize: {
                        if (modelData.title && (modelData.title.toLowerCase().includes("spotify") || (modelData.iconName && modelData.iconName.toLowerCase().includes("spotify")) || (modelData.icon && modelData.icon.toLowerCase().includes("spotify")))) {
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
                console.log("Clicked on", modelData.title || modelData.tooltipTitle || "unnamed", "with button:", mouse.button);

                if (mouse.button === Qt.RightButton) {
                    // Context menu activation using QsMenuOpener
                    console.log("Right click - trying to open context menu");

                    if (modelData.hasMenu && modelData.menu && menuAnchor) {
                        console.log("Opening context menu via QsMenuAnchor");
                        try {
                            menuAnchor.open();
                        } catch (e) {
                            console.log("Error opening menu:", e.toString());
                            if (modelData.secondaryActivate) {
                                console.log("Falling back to secondaryActivate()");
                                modelData.secondaryActivate();
                            }
                        }
                    } else if (modelData.secondaryActivate) {
                        console.log("Calling secondaryActivate()");
                        modelData.secondaryActivate();
                    } else if (modelData.activate) {
                        console.log("Falling back to activate()");
                        modelData.activate();
                    } else {
                        console.log("No context menu method available");
                    }
                } else if (mouse.button === Qt.MiddleButton) {
                    // Middle click activation
                    if (modelData.activate) {
                        console.log("Middle click - calling activate()");
                        modelData.activate();
                    } else {
                        console.log("No middle click method available");
                    }
                }
            }

            onDoubleClicked: {
                // Double click activation
                if (modelData.activate) {
                    console.log("Double click - calling activate()");
                    modelData.activate();
                }
            }
        }
    }
}
