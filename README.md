# owenstack/dotfiles

Personal CachyOS / Hyprland dotfiles, kept in the repository root as a mirror of `$HOME` and managed with a bare Git repository. The active desktop bar and shell UI is QuickShell.

<!-- Screenshot placeholder: add an owner-approved desktop capture here. -->

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/owenstack/dotfiles/a097a3eb3286dd12336225dfc4697f6981308e14/bootstrap/bootstrap.sh | bash
```

The bootstrap checks out the bare repository, backs up conflicting files, installs packages listed under `bootstrap/packages/`, configures zsh plugins, renders machine-specific Qt paths, and prints any manual steps. Use `--dry-run`, `--no-packages`, or `--yes` when running a checked-out copy. `--no-post-install` skips user-level setup for controlled recovery or checkout tests.

## Bare-repository workflow

The `dot` command wraps Git with `--git-dir=$HOME/.dotfiles --work-tree=$HOME`:

```bash
dot status
dot add .config/hypr/hyprland.lua
dot commit -m 'chore: adjust Hyprland config'
dot push
```

`status.showUntrackedFiles=no` keeps the rest of `$HOME` out of status; add only intentional files. The generated root `.gitignore` allows tracked paths and hides every other path to prevent accidental additions.

## What is configured

- Hyprland Lua configuration and hardware-specific monitor, idle, lock, and shader settings.
- QuickShell task bar and overview, with a retained top-bar configuration that is not currently in the startup chain.
- Dunst notifications, Rofi menus, Wallust theming, wallpaper cycling via a systemd user timer, Kitty and Ghostty.
- zsh with oh-my-zsh, mise runtimes, Git defaults, Qt/GTK appearance, and terminal tools.

The active Quickshell entry points are `.config/quickshell/task-bar/shell.qml` and `.config/quickshell/overview/shell.qml`. Theme switching is implemented by the QuickShell theme-mode scripts and Wallust templates; the wallpaper timer updates the wallpaper and generated palettes.

## Directory map

| Path | Purpose |
|---|---|
| `.config/hypr/` | Hyprland Lua config, scripts, shaders, and monitor settings |
| `.config/quickshell/` | Task bar, overview, and retained top-bar UI |
| `.config/rofi/` | Launchers and menus |
| `.config/wallust/` | Palette generation templates |
| `.config/systemd/user/` | Wallpaper cycle timer and service |
| `.config/kitty/`, `.config/ghostty/` | Terminal settings |
| `bootstrap/`, `scripts/` | Installer, verification, and repository checks |

## Adding files

Place files at their `$HOME`-relative path. Since unknown paths are ignored, stage only the intended file with `dot add -f path`, run `scripts/gen-gitignore.sh` to refresh the allow-list from the index, review it, then commit. Do not add caches, generated output, credentials, `.env` files, or anything from `~/.cache`.

## Secrets policy

Never commit API keys, tokens, passwords, private keys, `.env` files, or machine-local caches. Runtime credentials belong under `$XDG_STATE_HOME` (falling back to `~/.local/state`) and must be stored with mode `0600`. Do not put secrets in tracked configuration, even temporarily; use an environment variable or a state file excluded from Git.

An owner can enable GitHub secret scanning and push protection with:

```bash
gh api --method PATCH repos/owenstack/dotfiles --input - <<'JSON'
{"security_and_analysis":{"secret_scanning":{"status":"enabled"},"secret_scanning_push_protection":{"status":"enabled"}}}
JSON
```

## Troubleshooting

- **Checkout conflict:** the installer copies differing existing files to `~/.dotfiles-backup/<timestamp>/` before checking out. Restore from there if needed.
- **Missing icons or fonts:** install the named font packages in `bootstrap/packages/`, then run `fc-cache -f` and restart the app.
- **QuickShell does not start:** check `qs -c task-bar` from a terminal, then inspect user journal logs with `journalctl --user -b`. Confirm the packages and referenced scripts with `bootstrap/verify.sh`.
- **No wallpaper changes:** check `systemctl --user status wallpaper-cycle.timer` and the user journal.

## License and attribution

Third-party notices are in [NOTICE](NOTICE). A proposed MIT license for Owen's original configuration is recorded for owner confirmation in `docs/DECISIONS.md`; no license is granted by this repository yet.
