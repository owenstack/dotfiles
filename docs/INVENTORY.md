# Inventory and reference graph

Tracked file count at baseline: **969**. Tracked blob size: **6818702 total**. A normal analysis clone was made at `/tmp/dotfiles-work`.

## Top-level `.config` inventory

Sizes are tracked file bytes; origin is inferred from headers, directory structure, and known project conventions. Startup relevance is based on references from the listed startup roots, and is conservative where the graph is incomplete.

| App | Tracked bytes | Files | Origin | Live startup reference |
|---|---:|---:|---|---|
| `Kvantum` | 316,032 | 5 | unknown / mixed | indirect / unknown |
| `Thunar` | 10,311 | 2 | unknown / mixed | indirect / unknown |
| `btop` | 12,943 | 5 | unknown / mixed | indirect / unknown |
| `cava` | 24,722 | 10 | upstream-vendored | indirect / unknown |
| `dunst` | 5,614 | 4 | unknown / mixed | yes |
| `fastfetch` | 417,718 | 8 | unknown / mixed | indirect / unknown |
| `fish` | 160 | 1 | unknown / mixed | indirect / unknown |
| `ghostty` | 1,557 | 2 | unknown / mixed | yes |
| `gtk-3.0` | 477 | 1 | unknown / mixed | indirect / unknown |
| `hypr` | 495,045 | 150 | JaKooLit + Owen Lua config | yes |
| `kitty` | 1,033,225 | 187 | upstream-vendored themes + Owen config | yes |
| `kvantum` | 371,235 | 8 | unknown / mixed | indirect / unknown |
| `mako` | 1,675 | 3 | unknown / mixed | indirect / unknown |
| `micro` | 298,251 | 151 | upstream-vendored | indirect / unknown |
| `mise` | 67 | 1 | unknown / mixed | yes |
| `nwg-look` | 282 | 1 | unknown / mixed | indirect / unknown |
| `qt5ct` | 2,454 | 3 | unknown / mixed | indirect / unknown |
| `qt6ct` | 4,034 | 5 | unknown / mixed | indirect / unknown |
| `quickshell` | 817,998 | 143 | Owen / upstream-derived | yes |
| `rofi` | 1,407,418 | 106 | JaKooLit + Owen changes | yes |
| `swaync` | 850,047 | 27 | unknown / mixed | indirect / unknown |
| `systemd` | 308 | 2 | unknown / mixed | yes |
| `wallust` | 18,390 | 9 | upstream templates + Owen config | yes |
| `waybar` | 367,240 | 107 | JaKooLit/upstream-vendored | indirect / unknown |
| `wezterm` | 3,850 | 1 | unknown / mixed | indirect / unknown |
| `wlogout` | 351,384 | 17 | unknown / mixed | indirect / unknown |
| `xfce4` | 476 | 2 | unknown / mixed | indirect / unknown |
| `yad` | 1,590 | 1 | unknown / mixed | indirect / unknown |
| `zathura` | 2,194 | 1 | unknown / mixed | indirect / unknown |

## Reference graph method

Starting roots: `.config/hypr/hyprland.lua`, `.config/hypr/shader.lua`, each quickshell `shell.qml`, `.config/systemd/user/*`, `.zshrc`, and active Lua keybind definitions. References were identified with repository-wide `rg` searches over filenames and extensionless basenames, plus inspection of `require`, QML imports, shell `source`/exec targets, systemd `ExecStart`, and keybind commands. This is a static reachability approximation; dynamic shell construction and user-invoked menus can hide edges.

### Confirmed live edges

- `hyprland.lua` requires `shader.lua`, sets environment and starts `qs -c task-bar` and `qs -c overview`; it starts scripts and shell commands directly.
- `task-bar/shell.qml` and `overview/shell.qml` are entry points. `top-bar` has no startup edge located and is retained for owner review.
- `wallpaper-cycle.timer` activates `wallpaper-cycle.service`; service/script references remain in scope.
- `shader.lua` invokes `qs -c task-bar` in its shader recovery path and still has Waybar-related branches.
- Rofi menus and keybinds dynamically invoke scripts from `.config/hypr/scripts` and `.config/rofi`.

### Limits / pending verification

- `gitleaks`, `shellcheck`, `shfmt`, and `stylua` are unavailable in the analysis environment at baseline. `qmllint` and `zsh` are available. No Wayland session is available for runtime UI checks.
- This inventory is a baseline. Phase 3 requires a refreshed graph after each removal group.
