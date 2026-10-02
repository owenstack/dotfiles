# Inventory and reference graph

## Current tracked config inventory

Current tracked file count: **532**. Total Git blob payload: **5,266,237 bytes**. Baseline `main`: 968 files / 6,014,175 bytes.

Sizes are Git blob sizes (so the before/after comparison uses the same measure); per-app counts cover tracked files under `.config/<app>`. Origin is inferred from headers and project metadata. Live means a reference from the Hyprland/QuickShell/systemd startup chain, shell startup, or a current script/menu edge.

| App | Tracked bytes | Files | Origin | Startup / live reference |
|---|---:|---:|---|---|
| `Kvantum` | 683,961 | 11 | Catppuccin/Everforest upstream assets | indirect |
| `Thunar` | 10,311 | 2 | unknown / mixed | not found / unknown |
| `btop` | 9,475 | 2 | unknown / mixed | indirect |
| `dunst` | 5,614 | 4 | unknown / mixed | direct |
| `fastfetch` | 417,704 | 8 | unknown / mixed | indirect |
| `fish` | 160 | 1 | unknown / mixed | indirect (QuickShell command) |
| `ghostty` | 896 | 1 | Owen config | indirect |
| `git` | 35 | 1 | Owen config | indirect |
| `gtk-3.0` | 477 | 1 | unknown / mixed | not found / unknown |
| `hypr` | 1,320,028 | 168 | JaKooLit-derived + Owen Lua/scripts | direct |
| `kitty` | 938,477 | 16 | Owen config + selected upstream theme | indirect |
| `micro` | 1,137 | 2 | Owen settings + Catppuccin | not found / unknown |
| `mise` | 7,863 | 2 | Owen config | indirect |
| `nwg-look` | 282 | 1 | unknown / mixed | indirect |
| `qt5ct` | 2,440 | 3 | unknown / mixed | indirect |
| `qt6ct` | 4,020 | 5 | unknown / mixed | indirect |
| `quickshell` | 819,472 | 143 | Owen / upstream-derived | direct |
| `rofi` | 602,691 | 104 | JaKooLit-derived + Owen changes | indirect |
| `systemd` | 308 | 2 | Owen units | direct |
| `wallust` | 6,764 | 7 | Wallust templates + Owen config | indirect |
| `wezterm` | 3,850 | 1 | unknown / mixed | not found / unknown |
| `wlogout` | 351,356 | 17 | unknown / mixed | not found / unknown |
| `xfce4` | 476 | 2 | unknown / mixed | not found / unknown |
| `yad` | 1,590 | 1 | unknown / mixed | not found / unknown |
| `zathura` | 2,194 | 1 | unknown / mixed | not found / unknown |

## Reference graph method

Starting roots: `.config/hypr/hyprland.lua`, `.config/hypr/shader.lua`, all QuickShell `shell.qml` files, `.config/systemd/user/*`, `.zshrc`, and keybinds in the active Lua config. `rg` searches covered filenames and extensionless basenames across QML/JS, Lua, shell, systemd, Rofi, Dunst, and Wallust files. Static edges were followed through Lua `require`, QML imports, shell sources and command paths, systemd `ExecStart`, and keybind exec targets. Dynamic path construction and user-invoked menus remain an approximation.

### Current graph result

- `hyprland.lua` requires `shader.lua` and `monitors.lua`, starts Dunst, `qs -c task-bar`, `hypridle`, wallpaper daemon, clipboard watchers, and polkit agent. The startup sound is guarded by a file check.
- QuickShell entry points are `.config/quickshell/task-bar/shell.qml` and `.config/quickshell/overview/shell.qml`; top-bar has no startup edge and remains for owner review.
- `wallpaper-cycle.timer` activates its service; wallpaper scripts generate Wallust palettes and restart task-bar QuickShell.
- Active bar references no longer target Waybar; Waybar assets/scripts were removed. Notification image/icon files used by shell scripts now live under `.config/hypr/assets/notifications/`; Dunst remains the notification daemon.
- Rofi launchers and QuickShell command execution reach many Hyprland scripts. User-invoked settings scripts are retained where the current graph does not prove them dead.

### Remaining uncertainty

- `shellcheck`, `shfmt`, `stylua`, and `gitleaks` were unavailable locally at baseline. `qmllint` and `zsh` are available.
- No Wayland desktop session is available for Hyprland/Quickshell runtime validation.
- Dynamic script/menu edges and the full Quickshell import graph need target-machine runtime verification.
