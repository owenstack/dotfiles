#!/usr/bin/env bash
set -u
home=${HOME:?}
fail=0
check() { local label=$1; shift; if "$@"; then printf 'PASS | %s\n' "$label"; else printf 'FAIL | %s\n' "$label"; fail=1; fi; }
check 'Hyprland executable' command -v hyprland
check 'Quickshell executable' command -v qs
check 'zsh clean startup' bash -c 'zsh -i -c exit 2>/tmp/dotfiles-zsh.err && test ! -s /tmp/dotfiles-zsh.err'
if command -v systemd-analyze >/dev/null 2>&1; then check 'systemd user unit syntax' systemd-analyze --user verify "$home"/.config/systemd/user/*.service "$home"/.config/systemd/user/*.timer; else echo 'SKIP | systemd-analyze unavailable'; fi
for path in "$home/.config/hypr/UserScripts/WeatherWrap.sh" "$home/.config/hypr/scripts/wallpaperdaemon.sh"; do check "file $path" test -e "$path"; done
exit "$fail"
