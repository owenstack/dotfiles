# Lint baseline

Date: 2026-10-02. `shellcheck`, `shfmt`, and `stylua` are unavailable in the environment. `qmllint` and `zsh` are installed. Therefore no raw output from those unavailable tools can be claimed; the CI/check scripts added later should provide repeatable scans. Desktop runtime validation is unavailable without a Wayland session.

## Final verification update

- `bash -n` passed for tracked shell scripts after extracting the embedded Rofi emoji data into its own file.
- `qmllint` passed for 40 tracked QML files; it exited 255 without diagnostics on 33 files in this environment. A single-file check of `task-bar/shell.qml` passed. A QuickShell load test was unavailable without a Wayland session.
- `hyprland --verify-config` passed with `XDG_CONFIG_HOME` pointed at the repository `.config` root. The normal home config did not yet contain the newly tracked `monitors.lua` because the bare checkout has not been run.
- `zsh -i -c exit` median improved from 209.5 ms (before) to 91.6 ms (after), 20 runs each. All final runs had empty stderr, using temporary XDG cache/state paths.
- `scripts/check.sh` passed available checks and skipped gitleaks, shellcheck, shfmt, and stylua because they were not installed. An attempted package install could not prompt for sudo credentials in this non-interactive execution environment.
- `systemd-analyze --user verify` could not complete because the sandbox disallows the user-systemd socket operations; no user service manager session is exposed.
- Full package-consuming install and post-install behavior were not run locally because the Docker daemon socket is inaccessible. The targeted Arch-container conflict-backup and second-run snapshot integration subsequently passed in PR CI.

- PR CI later passed ShellCheck at error severity, shfmt on maintained bootstrap/check scripts, StyLua across all Lua files, and gitleaks on its shallow checkout. The full-tree style-warning baseline is still not available.
- The Arch-container checkout integration passed: it preserved a conflicting `.zshrc` under the backup path and confirmed the second run left the temporary HOME snapshot unchanged.
