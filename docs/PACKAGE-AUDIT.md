# Package manifest audit

Audit basis: repository runtime references and package metadata checked on 2026-10-03. `pacman -Si` resolved every entry in `bootstrap/packages/pacman.txt` against the installed CachyOS sync databases. The AUR RPC v5 resolved every entry in `bootstrap/packages/aur.txt`; `scripts/check-packages.sh` repeats these checks in CI and warns about orphaned, flagged, or stale AUR packages. AUR versions and metadata change over time, so the weekly job is the current check.

## Required providers and package-name findings

| Need found in config/scripts | Provider in manifest | Evidence |
|---|---|---|
| Hyprland, lock/idle/sunset, portals, Quickshell (`qs`), Dunst, clipboard, polkit, Bluetooth, media player | `hyprland`, `hypridle`, `hyprlock`, `hyprsunset`, `xdg-desktop-portal-hyprland`, `quickshell`, `dunst`, `cliphist`, `wl-clipboard`, `polkit-gnome`, `blueman`, `mpv` | Startup commands in `hyprland.lua` and `.config/hypr/configs/Startup_Apps.conf`; `.config/quickshell/**` calls `qs`/`quickshell`. CachyOS `pacman -Si` passed. |
| Wallpaper daemon and theme generation | `awww-git`, `wallust` | Active wallpaper scripts and `shader.lua` call `awww`/`awww-daemon`; `WallustSwww.sh` uses `awww query --json` and `wallust`. AUR RPC v5 returned both package names. |
| Screenshot, video wallpaper and logout | `grimblast-git`, `grim`, `slurp`, `swappy`, `mpvpaper`, `wlogout` | `screenshot.sh`, `WallpaperSelect.sh`, and `Wlogout.sh`; package metadata found in the official repos or AUR RPC. |
| System controls, notifications, network, media keys, calendar | `brightnessctl`, `pamixer`, `pipewire-pulse`, `libnotify`, `networkmanager`, `playerctl`, `khal`, `upower` | Hyprland scripts and task-bar QML invoke these commands/services. `pacman -Si` passed for each listed official package. |
| Wallpaper picker helpers | `bc`, `ffmpeg`, `imagemagick`, `xdg-user-dirs`, `waypaper` | `WallpaperSelect.sh`, `WallpaperEffects.sh`, `DarkLight.sh`, and retained top-bar `theme-mode.sh`. `waypaper` is AUR; the others resolved in CachyOS. |
| Fantasque Sans Mono Nerd Font | `ttf-fantasque-nerd` | `.config/ghostty/config` selects `FantasqueSansM Nerd Font Mono`; this exact package exists in official Arch Extra and CachyOS. |
| SDDM theme directory `simple_sddm_2` | `simple-sddm-theme-2-git` | AUR RPC v5 returns this package with upstream `https://github.com/JaKooLit/simple-sddm-2`. The package name and source are confirmed; CI package-name validation does not inspect the installed theme directory. A real install check remains part of Workstream D. |
| Pokemon color scripts | `pokemon-colorscripts-git` | This exact AUR package exists, and CachyOS also supplies it. No invocation was found in active tracked runtime references; it is retained for now as owner review rather than removed silently. |

The old `swww` package is not available in current CachyOS/Arch sync metadata. Its active wallpaper command interface has been migrated to `awww`, the maintained successor/fork; its upstream documents `awww-daemon`, `awww img`, `awww query --json`, and the `AWWW_TRANSITION_*` environment variables. The script that previously parsed swww's cache files now reads the image path from `awww query --json` instead. Upstream source: [awww project](https://codeberg.org/LGFae/awww).

The Saturnian cursor name was not found in the AUR RPC or current CachyOS package metadata, and no tracked config names it. It is not listed in either package manifest. Treat the cursor as manually installed or choose a replacement during owner review; do not claim a package provider until one is verified.

## Owner review: manifest entries without a proven active runtime edge

These packages are retained because this audit is not authorization to remove user tools or inherited support. Confirm they are still wanted before pruning them:

- `btop`, `micro`: no active autostart/keybind invocation found in the searched Hyprland, Quickshell, or systemd runtime files; they are standalone user applications/configs.
- `pokemon-colorscripts-git`: package is valid, but no active command invocation was found.
- `ttf-fira-code`, `ttf-jetbrains-mono-nerd`, `noto-fonts-emoji`, `ttf-nerd-fonts-symbols-mono`: font fallback/emoji coverage entries; exact family demand varies by Qt/Quickshell assets.
- `shellcheck`, `shfmt`, `stylua`, `gitleaks`: repository maintenance and hook/CI tools rather than desktop runtime packages.
- `base-devel`, `git`, `curl`, `jq`, `ripgrep`, `python`, `python-requests`: bootstrap, AUR build, helper-script, and repository maintenance dependencies.
- `sddm`: display-manager choice is part of the install profile; verify the owner wants SDDM enabled on a fresh machine.

The broader manifests also contain standalone applications such as `btop`, `fastfetch`, `lsd`, `fzf`, `kitty`, `ghostty`, `zsh`, `mise`, `github-cli`, and `fish`. Some are interactive user tools and shell defaults, rather than commands invoked by the desktop autostart chain. Keep them pending explicit owner preference.

## Validation results

- CachyOS sync metadata, `pacman -Si` per manifest line: **PASSED**, every `pacman.txt` entry resolved.
- AUR RPC v5 for each manifest line: **PASSED**, every `aur.txt` entry resolved. Metadata is printed by the validation script; warnings do not fail the check.
- Arch container package validation workflow: **NOT RUN locally** (Docker daemon unavailable); the committed workflow runs this check on pull requests touching the manifests and weekly.
- Fresh package installation and confirmation that `simple_sddm_2` lands at the expected SDDM theme path: **NOT RUN**; Workstream D owns clean-machine installation verification.
