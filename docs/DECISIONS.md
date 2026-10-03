# Decisions

## Open questions for owner

- Is `GDK_SCALE=2` intentional on a 1080p panel? Keep current scale 1 plus GDK_SCALE=2 (current behavior) or set GDK_SCALE=1 to match the panel; changing it can alter application sizing, so no visual change was made.
- Confirm the owner’s preferred license for original configuration. An MIT `LICENSE` is proposed but not committed pending confirmation.

## Recorded choices

- Bootstrap clones oh-my-zsh directly rather than evaluating its downloaded installer script. This keeps `--dry-run` free of command-substitution downloads and avoids running an unpinned `curl | sh` payload; future oh-my-zsh updates can replace the clone intentionally.
- Install gitleaks after checkout but before configuring `core.hooksPath`. `--no-packages` still installs/checks this hook prerequisite; it skips the desktop package manifests only.
- Hook failures name `sudo pacman -S gitleaks` and the manual `--no-verify` escape hatch. The escape hatch is for an equivalent prior scan, not a normal install path.

- Retain the top-bar Quickshell configuration under Needs owner review: no startup or keybind edge was found, but deletion is irreversible from the user perspective and the brief says to retain it when uncertain.
- Use Open-Meteo `WeatherWrap.sh` as the top-bar weather source because it uses the existing no-key weather implementation and its fallback, instead of introducing another dependency on an absent ags tree.
- Canonicalize Kvantum at `.config/Kvantum/`, which matches the live theme settings and current Catppuccin theme-switch commands; preserve the Everforest theme assets under the canonical directory.
- Keep current monitor geometry and scale. Extracting this changes config architecture, not visual output; validated with `hyprland --verify-config` against the repository `.config` root; runtime testing still needs a Wayland session.
- Pin mise to supported policy choices: use Node LTS, major Go and Bun lines where known, and `latest` only for GitHub CLI; exact versions should be resolved and locked by installed mise during bootstrap.

- Remove Waybar, Mako, SwayNC, and Cava configurations after rewiring active refresh and shader branches to Quickshell/Dunst; migrate referenced notification icon files rather than dropping them.
- Preserve selected active Kitty theme files that reference the OFL Computer Modern Typewriter variable font. Do not silently replace the typeface; owner review is needed before pruning or replacing its font assets.
- Package names that fail the local CachyOS `pacman -Si` lookup are isolated in the AUR manifest with verification comments; install failures are reported and do not abort bootstrap.
- Replace the unavailable `swww` package with `awww-git`, its maintained successor/fork, and update the wallpaper commands to the documented `awww` CLI. Keep the `WallustSwww.sh` filename because callers reference it; read the current image from `awww query --json` because `awww` does not retain swww's cache files. This is reversible in one commit, but a live graphical session is still needed to verify transitions and theme refresh behavior.
- Use `simple-sddm-theme-2-git` for the upstream `simple_sddm_2` theme directory; retain Saturnian cursor selection as an unresolved manual-install/owner-review item because no package with that name was found in the queried repositories.
