{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Quickshell and Qt development
    quickshell
    qt6.full
    qt6.qtwayland
    qt6.qtdeclarative
    qt6.qttools
    
    # Development tools
    cmake
    ninja
    pkg-config
    gcc
    
    # QML/Qt development utilities
    qt6.qmake
    
    # General development tools
    git
    neovim
    
    # System dependencies that might be needed
    wayland
    wayland-protocols
    libxkbcommon
    
    # For debugging and development
    gdb
    valgrind
    strace
  ];
  
  shellHook = ''
    echo "Quickshell development environment loaded!"
    echo "Available tools:"
    echo "  - quickshell: Main application"
    echo "  - qmlls: QML Language Server"
    echo "  - qmlformat: QML code formatter"
    echo "  - Qt Creator: Full Qt IDE"
    echo ""
    echo "QML import paths are automatically configured."
    
    # Set up QML import paths for better development experience
    export QML_IMPORT_PATH="${pkgs.qt6.full}/bin"
    export QT_PLUGIN_PATH="${pkgs.qt6.qtwayland}/lib/qt-6/plugins"

    ln -sf ${pkgs.qt6.full}/bin/qmlls ./symlinks/qmlls
  '';
}
