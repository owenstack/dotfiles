# Dotfiles doctor

Run `bash "$HOME/scripts/doctor.sh"` from the bare-repository-managed HOME. The script is read-only for the installed configuration: it reads the bare repo, config files, user service state, and live monitor information. For the zsh timing check it creates temporary XDG cache/state directories and removes them before exit. It prints one `PASS`, `WARN`, or `FAIL` per check and exits non-zero if any check fails.

## Checks and fixes

| Check | Meaning | Fix |
|---|---|---|
| `dot status`, hooks path, allow-list | Tracked files and visible untracked files are clean, `core.hooksPath` is `.githooks`, and `.gitignore` exactly matches the tracked-file allow-list plus generated-state rules. | Review `dot status`; install `gitleaks` if missing; set the hooks path with `dot config --local core.hooksPath .githooks`; after intentionally adding/removing files, regenerate the ignore allow-list with `bash "$HOME/scripts/gen-gitignore.sh"`. |
| `gitleaks` | The secret scanner required by commit/push hooks exists on `PATH`. | Install with `sudo pacman -S gitleaks`. |
| Autostart, keybind executables and scripts | Current literal app commands, app paths, and script paths in `hyprland.lua` resolve. | Install the named package or update the stale command/path in the configuration. Helium is an optional custom app path; remove or correct its keybind if it is not installed. |
| QuickShell file references | Static local QML image/file sources, `config.json`, `qml_color.json`, and the current-wallpaper path resolve. A missing `profile.jpg` is only a warning because the image is optional. | Restore the missing tracked asset or correct its relative path. Let wallpaper selection create `.config/rofi/.current_wallpaper`; add a profile image at `.config/quickshell/task-bar/profile.jpg` only if desired. |
| Rendered Qt settings | `qt5ct.conf` and `qt6ct.conf` exist and contain no unresolved template placeholders. | Run `bash "$HOME/bootstrap/post-install.sh"` after reviewing its effects, or render the corresponding `.conf.tmpl` with the current HOME path. |
| Kvantum | Only `.config/Kvantum` exists, and the selected theme has its Kvantum config. | Remove the duplicate lowercase directory after reviewing its contents; set the selected theme to a directory under `.config/Kvantum/` that contains the matching `.kvconfig`. |
| Weather secret state | Weather settings live under `${XDG_STATE_HOME:-$HOME/.local/state}`, have mode `0600`, and are not tracked. An absent file warns because no key may have been configured yet. | Let post-install create the file, or move the runtime settings file under the XDG state directory and set `chmod 600`. Never put the key in the repository. |
| Wallpaper timer | Active status is checked when a user manager is reachable. No manager, disabled timer, or enabled-but-inactive timer is a warning. | Start the user manager/session, then run `systemctl --user enable --now wallpaper-cycle.timer`. |
| Monitor resolution and scale | In a live Hyprland session, `hyprctl monitors -j` is compared with the output, mode, and scale in `monitors.lua`. Without a session the result is a warning. | Check the physical output name and supported mode; edit `monitors.lua` only after confirming the intended hardware settings, then reload Hyprland. |
| Hardcoded current-user paths | Tracked runtime config is checked for `/home/<current-user>` literals. | Replace the literal with `$HOME`, an XDG path, or a path built from the runtime user. |
| Zsh startup | Runs `zsh -i -c exit`, reports elapsed milliseconds, and fails if stderr is non-empty. Cache and history writes are redirected to temporary directories. | Inspect the warning/error printed by the interactive startup and ensure required oh-my-zsh plugins and mise initialization are available. |

The doctor does not install packages, rewrite configuration, enable services, or change monitor settings. Visual display-manager, cursor, font, and theme checks remain in `docs/FRESH-INSTALL-CHECKLIST.md`.

## Verification status

- ShellCheck warning-level lint, shell syntax, and shfmt are run in CI for this script.
- The authoring environment’s `bash scripts/doctor.sh` invocation stopped immediately with `FAIL | bare dotfiles repository missing at ~/.dotfiles`. This checkout environment does not expose the installed bare-repository HOME, so that output is **NOT RUN** evidence for the owner’s live system; the remaining checks were not evaluated here.
- Running this script in the disposable fresh-install harness is **NOT RUN** locally because the Docker daemon is unavailable. The full-install workflow is manual/weekly and can be dispatched after its workflow reaches the default branch.
