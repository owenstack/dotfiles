# Fresh install: human verification

Use a disposable VM or spare machine after the automated Arch harness passes. Keep the existing machine unchanged until the new install has booted and the backups have been checked.

- [ ] Confirm the intended UEFI boot entry and SDDM display-manager service; reboot once and reach the greeter.
- [ ] Sign into the Hyprland session and confirm the task-bar appears without restarting or crashing.
- [ ] Switch between dark and light themes; check GTK, Qt, Kitty/Ghostty, Rofi, and the task-bar palette.
- [ ] Wait for `wallpaper-cycle.timer` to fire, or run the documented wallpaper cycle command; confirm the image and generated colors update.
- [ ] Send a test notification and confirm Dunst displays and dismisses it.
- [ ] Open and dismiss the lock screen, then unlock the session.
- [ ] Check every connected monitor’s mode, position, and scale in the session; compare with `monitors.lua` and confirm GTK sizing is usable.
- [ ] Confirm the selected cursor is visible in both Hyprland and an XWayland application.
- [ ] Confirm the Fantasque Sans Mono Nerd Font and Nerd Font symbols render in terminal and Quickshell text.
- [ ] Check audio, brightness, Wi-Fi, clipboard history, screenshots, and logout actions that apply to the hardware.
- [ ] Review `~/.dotfiles-backup/` before restoring any machine-specific files; retain a copy until the new setup is accepted.

The automated container cannot establish that a physical monitor, cursor theme, display manager, GPU, audio device, or font looks correct. Record those visual/hardware results separately from CI.

## Restore an overwritten file

Bootstrap saves conflicting tracked paths under `~/.dotfiles-backup/<timestamp>/` before checkout. To restore one file, copy its backup over the installed path, for example:

```sh
cp -a "$HOME/.dotfiles-backup/<timestamp>/.config/hypr/hyprland.lua" \
  "$HOME/.config/hypr/hyprland.lua"
```

Replace the timestamp and relative path with the matching backup. For a full rollback, copy only the wanted paths from the backup; there is no automatic uninstall because this is a bare-repository `$HOME` workflow and a whole-home restore could overwrite newer personal files.
