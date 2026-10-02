# Portability

- This setup targets Arch-based CachyOS and uses pacman/AUR, Hyprland 0.55 Lua, Quickshell, zsh, oh-my-zsh, mise, and systemd user units.
- Hardware-specific behavior includes `eDP-1` at 1920x1080, workspace assignments to `DP-1`, laptop power/battery scripts, touchpad settings, cursor themes, and monitor-specific lock screens. Review these on other hardware.
- `GDK_SCALE=2` remains paired with the current 1x monitor scale; see the owner question in `DECISIONS.md`.
- Qt5ct and Qt6ct do not reliably expand shell variables in `color_scheme_path`; their tracked `.tmpl` files are rendered by the post-install step to absolute `$HOME` paths.
- Arch zsh plugin `archlinux` is intentionally retained for CachyOS. Other distributions need this plugin removed or replaced.
- Quickshell profile images are optional user files under the relevant Quickshell config folder. Weather cache and settings belong under XDG cache/state directories.
- Some Rasi, Hyprlock, and app-specific formats accept `~` in path fields; installer output should be checked on the target versions.
