# Removed and migrated files

This log records deletions and case/path migrations. Git history retains prior contents.

## Phase 2 portability migrations

| Former path | Reason / evidence | Result |
|---|---|---|
| `.config/kvantum/kvantum.kvconfig` | Duplicate case-colliding Kvantum config; live `.config/Kvantum/kvantum.kvconfig` and DarkLight settings select Catppuccin assets in uppercase path. | Canonicalized under `.config/Kvantum/`; canonical selected theme remains Catppuccin. |
| `.config/kvantum/EverforestGreenDark/*`, `.config/kvantum/EverforestGreenLight/*` | Case-colliding duplicate tree; no script selected its configured Everforest theme. | Theme assets preserved by moving them to `.config/Kvantum/`. |
| `.config/kvantum/kdeglobals` | No reader or writer references this nonstandard nested path; theme scripts use `$HOME/.config/kdeglobals`. | Removed. |
| `.config/qt5ct/qt5ct.conf`, `.config/qt6ct/qt6ct.conf` | Contained `/home/owenstack`; Qtct settings use absolute palette paths and do not expand shell variables. | Converted to install-rendered `.conf.tmpl` templates; installer still needs to render them. |

## Needs owner review

- `.config/quickshell/top-bar/`: no startup edge found; retained because it may be manually launched.
- Whether the optional top-bar profile image should be supplied, and whether `GDK_SCALE=2` is intentional on the 1080p panel.

## Phase 3: safe dead-file removals

| Removed path | Reason / evidence | Search evidence |
|---|---|---|
| `.config/hypr/scripts/Polkit-NixOS.sh` | CachyOS configuration starts the packaged polkit agent in `hyprland.lua`; Nix store traversal is obsolete. | Removed its only commented reference from `configs/Startup_Apps.conf`; no active Lua/QML/systemd references. |
| `.config/hypr/scripts/UptimeNixOS.sh` | Nix-store-specific helper is not appropriate for CachyOS. | Replaced the only `hyprlock-2k.conf` fallback with plain `uptime -p`; re-grep found no remaining path reference. |
| `.config/hypr/v2.3.20` | JaKooLit version marker; no code reads version marker. | Repository-wide search found only the marker path itself. |

### Needs owner review (retained)

- Waybar scripts/configs have references from scripts, menus, and inactive legacy Hyprland config; the graph does not prove all are dead until those live user-invoked paths are rewired.
- `mako/` and `swaync/` remain referenced by notification/theme/asset scripts even though Dunst is the started daemon. Removing them now would leave those paths dangling.
- `wezterm/` is not launched, but Quickshell still recognizes its window class; retained pending an explicit UI cleanup decision.
- `fish/config.fish` remains referenced by Quickshell overview search commands, so fish is included as a package.
- Animation presets and shaders remain until the preset selector and Quickshell shader drawer are exhaustively mapped; dynamic filename selectors make an incomplete grep unsafe.

| Former path | Reason / evidence | Result |
|---|---|---|
| `.config/hypr/scripts/ScreenShot.sh` | Case-insensitive collision with active `.config/hypr/scripts/screenshot.sh`; active Lua binds invoke lowercase file, while legacy un-sourced `configs/Keybinds.conf` / `Laptops.conf` referenced the uppercase helper. | Preserved behavior under the distinct path `ScreenshotLegacy.sh`; updated those legacy references. No files were discarded. |

## Phase 3: kitty theme vendor reduction

| Removed path | Reason / evidence | Replacement |
|---|---|---|
| `.config/kitty/kitty-themes/*.conf` (171 upstream-vendored files) | Whole-repository search found no literal theme filename dependencies; `Kitty_themes.sh` dynamically enumerated every file from this directory. | Selector now shallow-clones `kovidgoyal/kitty-themes` into XDG data on first menu use, and copies only the selected theme into the ignored runtime config directory. Wallust writes its generated `01-Wallust.conf` target there. |

## Phase 3: micro runtime data

| Removed path | Reason / evidence | Evidence |
|---|---|---|
| `.config/micro/syntax/*.yaml` (146 upstream runtime syntax definitions) | These are runtime syntax definitions shipped by micro itself and duplicate its packaged runtime. | `settings.json` only selects a colorscheme; repository-wide search outside the syntax directory found no imports/references to these filenames. |
| `.config/micro/colorschemes/catppuccin-frappe.micro`, `catppuccin-latte.micro`, `catppuccin-mocha.micro` | Not selected by `.config/micro/settings.json`, which selects `catppuccin-macchiato`. | Search of repo references found no references to the three unselected names. |

## Phase 3: unused btop themes

| Removed path | Reason / evidence | Evidence |
|---|---|---|
| `.config/btop/themes/catppuccin_frappe.theme`, `catppuccin_latte.theme`, `catppuccin_mocha.theme` | `.config/btop/btop.conf` selects only `catppuccin_macchiato.theme`; no btop theme switcher references the other filenames. | Repository-wide search for the three exact filenames and extensionless stems found no references outside the files. |

## Phase 3: Waybar and inactive notification daemons

| Removed / migrated paths | Reason / evidence | Result |
|---|---|---|
| `.config/waybar/**` (107 files), `.config/hypr/scripts/WaybarCava.sh`, `WaybarLayout.sh`, `WaybarScripts.sh`, `WaybarStyles.sh`, and `.config/rofi/config-waybar-layout.rasi`, `config-waybar-style.rasi` | Quickshell is the configured bar; no Waybar startup occurs in the Lua startup chain or systemd user units. Script/config references were internal to the removed Waybar tree or inactive legacy configuration. `shader.lua`, wallpaper refresh, and theme refresh branches are being rewired to task-bar QuickShell. | Deleted after references were updated. Cava was only included as an unused generated configuration and Waybar visualizer. |
| `.config/hypr/scripts/RefreshNoWaybar.sh` | Functionally duplicate refresh helper used by wallpaper, animations, and monitor profile scripts. | Renamed to `.config/hypr/scripts/RefreshWallust.sh`; references updated to QuickShell and Dunst. |
| `.config/mako/**` | No active startup, systemd, Quickshell, or script references; Dunst is the configured daemon. | Removed. |
| `.config/swaync/config.json`, `.config/swaync/style.css` | SwayNC is not launched; Quickshell reads Dunst history and `hyprland.lua` starts Dunst. Existing shell scripts only needed notification images/icons. | Removed daemon config after moving referenced image/icon assets to `.config/hypr/assets/notifications/` and updating all paths. |
| `.config/wallust/templates/colors-waybar.css` and Waybar target settings | Generated only for the removed Waybar configuration. | Removed template and target; no active runtime reference remains. |

| `.config/cava/**`, `.config/wallust/templates/colors-cava`, `.config/wallust/templates/colors-swaync.css` | No active QuickShell or shell command launches Cava; these were only generated for removed Waybar/SwayNC modules. | Removed corresponding unused Wallust template entries and base package. |
| `.config/wallust/templates/colors-waybar.css` | Also imported by wlogout. | Replaced with a focused `colors-wlogout.css` palette template and generated wlogout stylesheet. |

| `.config/hypr/scripts/RofiEmoji.sh` embedded word list | The text payload after the shell script caused syntax/lint checks to parse non-shell emoji data as code. | Moved its full data payload to adjacent `RofiEmoji.data`; the shell script reads that data file. Menu output remains backed by the same entries. |
