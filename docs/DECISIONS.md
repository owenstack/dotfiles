# Decisions

## Open questions for owner

- Is `GDK_SCALE=2` intentional on a 1080p panel? Keep current scale 1 plus GDK_SCALE=2 (current behavior) or set GDK_SCALE=1 to match the panel; changing it can alter application sizing, so no visual change was made.
- Confirm the owner’s preferred license for original configuration. An MIT `LICENSE` is proposed but not committed pending confirmation.

## Recorded choices

- Retain the top-bar Quickshell configuration under Needs owner review: no startup or keybind edge was found, but deletion is irreversible from the user perspective and the brief says to retain it when uncertain.
- Use Open-Meteo `WeatherWrap.sh` as the top-bar weather source because it uses the existing no-key weather implementation and its fallback, instead of introducing another dependency on an absent ags tree.
- Canonicalize Kvantum at `.config/Kvantum/`, which matches the live theme settings and current Catppuccin theme-switch commands; preserve the Everforest theme assets under the canonical directory.
- Keep current monitor geometry and scale. Extracting this changes config architecture, not visual output; validated with `hyprland --verify-config` against the repository `.config` root; runtime testing still needs a Wayland session.
- Pin mise to supported policy choices: use Node LTS, major Go and Bun lines where known, and `latest` only for GitHub CLI; exact versions should be resolved and locked by installed mise during bootstrap.

- Remove Waybar, Mako, SwayNC, and Cava configurations after rewiring active refresh and shader branches to Quickshell/Dunst; migrate referenced notification icon files rather than dropping them.
- Preserve selected active Kitty theme files that reference the OFL Computer Modern Typewriter variable font. Do not silently replace the typeface; owner review is needed before pruning or replacing its font assets.
- Package names that fail the local CachyOS `pacman -Si` lookup are isolated in the AUR manifest with verification comments; install failures are reported and do not abort bootstrap.
# Workstream F: selector reachability and upstream helpers

## Dynamic selector enumeration and fallbacks

| Selector | Directory and enumeration | Fallback behavior |
|---|---|---|
| `Animations.sh` | `$HOME/.config/hypr/animations`; `find -L -maxdepth 1 -type f`, strips `.conf`, then `sort -V`; menu reconstructs `<choice>.conf`. | Empty directory yields an empty Rofi menu; there is no fallback preset. Keep every current preset until the reduced-set selector is exercised in a graphical harness. `hyprland.lua` defines the active animation inline; the active preset file is therefore not known. `GameMode.sh` toggles Hyprland's animations option and names no preset. |
| Shader selection | `shader.lua` maps names to explicit `.glsl` filenames under `$HOME/.config/hypr/shaders/`; Rofi selectors `shaders_menu*.sh` and QuickShell `WideDrawer.qml` also hold explicit lists. No directory scan or fallback is used. | `hyprland.lua` calls `shader.toggle("Main")`, which selects `main.glsl`; the shader module returns failure for unknown names and clears on its explicit off action. Keep every file named by any selector. The `old/` subdirectory is not enumerated, and the four module entries that name `matte.glsl`, `IBM5151.glsl`, `clarity_inefficient.glsl`, and `focus.glsl` currently resolve against the root shader directory, not `old/`; retain pending correction/review. |
| `ThemeChanger.sh` | Does not enumerate a repository theme directory. It asks `wallust theme list`, removes the heading, strips `- `, and sends all installed Wallust theme names to Rofi. | Cancel/empty selection exits cleanly; no built-in theme fallback. |
| `RofiThemeSelector.sh` | Merges top-level `*.rasi` files from `~/.config/rofi/themes` and `${XDG_DATA_HOME:-~/.local/share}/rofi/themes`, then sorts/deduplicates names. | Empty set reports “No Rofi Themes” and exits. |
| `RofiThemeSelector-modified.sh` | Top-level `*.rasi` from `~/.local/share/rofi/themes` and `~/.config/rofi/themes`; it restricts the candidates to themes compatible with the current config rather than using repository-wide static names. | Empty set reports no themes and exits; no fallback theme is selected. |
| `Kitty_themes.sh` | Top-level `*.conf` under `${XDG_DATA_HOME:-~/.local/share}/kitty-themes/themes`; on first use clones `kovidgoyal/kitty-themes` shallowly. | Clone failure or no `.conf` files reports an error and exits. The active wallust theme is separately generated and not part of this selector. |
| Wallpaper selectors | `WallpaperSelect.sh` and `WallpaperRandom.sh` recursively `find -L` image/video files below `${xdg-user-dir PICTURES}/wallpapers`; supported extension lists are embedded in each script. `WallpaperEffects.sh` offers effects for the current wallpaper and uses no preset directory. `WallpaperAutoChange.sh` cycles files below its wallpaper directory. | The scripts expect the owner to supply wallpaper files; no repository wallpaper fallback is guaranteed. The systemd `WallpaperCycle.sh` chooses from the same user wallpaper collection and reports when none is available. |

## Preset keep-list and script decisions

- Keep all 17 animation presets: the selector discovers all top-level `.conf` files dynamically, and a reduced menu has not been run in the graphical fresh-install harness. `hyprland.lua` uses inline animation definitions, so no preset file is confirmed as active. The “disable animations” candidate is `03- Disable Animation.conf`; no script references it by name.
- Keep all root shader files selected by static references. `Main` / `main.glsl` is active at startup. Reading Mode, Night Light, and CRT Mode are referenced by named module modes, and Rofi/QuickShell enumerate other names. Do not delete shader assets while a reader remains.
- Keep `hypr/UserConfigs/` and `hypr/configs/`: manual settings/keybind tools read and edit their files, and scripts use path construction. Static source analysis does not prove these trees dead.
- `KooLsDotsUpdate.sh`: remove. It is not called by active Lua, Quickshell, systemd, or script references, and its update action clones/pulls the upstream JaKooLit dotfiles then runs `copy.sh`, which can overwrite this bare-repo-managed `$HOME`. Exact filename and basename search found no callers outside its own file and generated `.gitignore` entry.
- `Distro_update.sh`: retain for now as a manually launchable system-upgrade helper; no active caller was found. It updates the OS through the package manager and does not fetch/copy dotfiles. The risk is its immediate system upgrade action, so keep it out of autostart and leave it for owner review.
- `Kool_Quick_Settings.sh`: retain as an inherited manual utility. Its menu invokes settings editors, animation and Rofi selectors, Kitty theme selection, and `sddm_wallpaper.sh`; static Lua/systemd sources do not call it directly. No current active Lua bind was found, so investigate an owner-preferred replacement before deleting the only menu entry point for those utilities.
- `sddm_wallpaper.sh`: retain. `Kool_Quick_Settings.sh` calls it with `--normal`; it updates the installed `simple_sddm_2` theme with sudo after an explicit menu action, not a repo-managed home file.
- `initial-boot.sh` is already absent from current `main` (removed in PR #1); no further removal is needed.

No animation or shader preset was removed in this pass. The required reduced-set selector experiment is **NOT RUN** because this environment has no Docker daemon or graphical session; retaining the dynamic choices is the reversible outcome until that evidence exists.
