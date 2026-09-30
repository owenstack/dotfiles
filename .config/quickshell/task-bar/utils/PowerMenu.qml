import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// This is a separate power menu for ALT+F4
// FILE 1/4 --- PowerMenu.qml
// Reads the two cache files that decide appearance and
// then hands off to PowerMenuController.qml

PanelWindow {
    id: win
    WlrLayershell.namespace: "power-menu"

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    focusable: true
    Component.onCompleted: win.requestActivate()

    WlrLayershell.exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrLayerKeyboardFocus.Exclusive

    property bool isDarkMode: true
    property string style: "life"

    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/quickshell"
    readonly property string styleFile: cacheDir + "/power_menu_style"
    readonly property string colorsFile: cacheDir + "/power_menu_colors"
    readonly property string paletteFile: Quickshell.env("HOME") + "/.config/quickshell/qml_color.json"
    property var wallpaperPalette: ({})
    readonly property color wallpaperBackground: wallpaperPalette.windowBackground || (isDarkMode ? "#141719" : "#f0ece6")
    readonly property color wallpaperAccent: wallpaperPalette.accentPrimary || (isDarkMode ? "#859866" : "#6c8453")

    function loadWallpaperPalette(content) {
        try {
            const colors = JSON.parse(content || "{}")
            if (colors.accentPrimary && colors.windowBackground)
                wallpaperPalette = colors
        } catch (error) {
            console.warn("[PowerMenu] Could not load wallpaper palette:", error)
        }
    }

    FileView {
        id: wallpaperPaletteView
        path: win.paletteFile
        watchChanges: true
        preload: true
        onFileChanged: reload()
        onLoaded: win.loadWallpaperPalette(String(text() || ""))
    }

    // Per-skin accent overrides (empty = skin keeps its built-in default).
    property string colLifeDark: ""
    property string colLifeLight: ""
    property string colCassiniDark: ""
    property string colCassiniLight: ""
    readonly property string livingAccent: win.colLifeDark !== "" ? win.colLifeDark : String(win.wallpaperAccent)
    readonly property string cassiniSelBg: win.colCassiniDark !== "" ? win.colCassiniDark : String(win.wallpaperAccent)

    // Dark/light: shared with the rest of the shell
    Process {
        id: themeCheck
        command: ["cat", "/home/owenstack/.cache/quickshell/theme_mode"]
        running: true
        stdout: StdioCollector {
            onTextChanged: {
                win.isDarkMode = (text.trim() !== "light")
                themeCheck.running = false
            }
        }
    }

    // Make sure the cache dir + a default style file exist (seed once).
    Process {
        id: styleSeed
        command: ["bash", "-c",
            "mkdir -p \"" + win.cacheDir + "\"; " +
            "[ -f \"" + win.styleFile + "\" ] || printf 'life' > \"" + win.styleFile + "\""]
        running: true
    }

    // Life vs Cassini skin
    Process {
        id: styleCheck
        command: ["cat", win.styleFile]
        running: true
        stdout: StdioCollector {
            onTextChanged: {
                const s = text.trim().toLowerCase()
                if (s === "cassini" || s === "life") win.style = s
                styleCheck.running = false
            }
        }
    }

    // Per-skin accent colours written by the settings panel.
    Process {
        id: colorsCheck
        command: ["cat", win.colorsFile]
        running: true
        stdout: StdioCollector {
            onTextChanged: {
                try {
                    const t = text.trim()
                    if (t.length > 0) {
                        const d = JSON.parse(t)
                if (d.custom === true) {
                    if (d.lifeDark)     win.colLifeDark     = d.lifeDark
                    if (d.lifeLight)    win.colLifeLight    = d.lifeLight
                    if (d.cassiniDark)  win.colCassiniDark  = d.cassiniDark
                    if (d.cassiniLight) win.colCassiniLight = d.cassiniLight
                } else {
                    win.colLifeDark = ""
                    win.colLifeLight = ""
                    win.colCassiniDark = ""
                    win.colCassiniLight = ""
                }
                    }
                } catch (e) {}
                colorsCheck.running = false
            }
        }
    }

    // Dim / click-to-dismiss backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(win.wallpaperBackground.r, win.wallpaperBackground.g, win.wallpaperBackground.b, win.isDarkMode ? 0.55 : 0.35)

        MouseArea {
            anchors.fill: parent
            onClicked: controller.backdropClicked()
        }
    }

    PowerMenuController {
        id: controller
        isDarkMode: win.isDarkMode
        style: win.style
        wallpaperPalette: win.wallpaperPalette
        livingAccent: win.livingAccent
        cassiniSelBg: win.cassiniSelBg

        // Round to avoid fractional blur; small slide that plays in and out
        x: Math.round((parent.width - width) / 2)
        y: Math.round(((parent.height - height) / 2) + ((1 - Math.min(1, intro)) * 24))

        focus: true
    }
}
