#!/usr/bin/env bash
set -u
home=${HOME:?}
fail=0
pass() { printf 'PASS | %s\n' "$1"; }
failed() {
  printf 'FAIL | %s\n' "$1"
  fail=1
}
for exe in hyprland hypridle hyprlock qs dunst blueman-applet vdirsyncer mpv wl-paste cliphist; do
  if command -v "$exe" >/dev/null 2>&1; then pass "executable: $exe"; else failed "executable: $exe"; fi
done
if [[ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]]; then pass 'polkit authentication agent'; else failed 'polkit authentication agent'; fi
for path in \
  "$home/.config/hypr/UserScripts/WeatherWrap.sh" \
  "$home/.config/hypr/scripts/wallpaperdaemon.sh" \
  "$home/.config/quickshell/task-bar/shell.qml" \
  "$home/.config/quickshell/overview/shell.qml"; do
  if [[ -e $path ]]; then pass "file: ${path#"$home"/}"; else failed "file: ${path#"$home"/}"; fi
done
if command -v systemd-analyze >/dev/null 2>&1; then
  if systemd-analyze --user verify "$home"/.config/systemd/user/*.service "$home"/.config/systemd/user/*.timer >/dev/null; then pass 'systemd user units'; else failed 'systemd user units'; fi
else printf 'SKIP | systemd-analyze unavailable\n'; fi
if command -v zsh >/dev/null 2>&1; then
  if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/dotfiles-verify-cache}" XDG_STATE_HOME="${XDG_STATE_HOME:-/tmp/dotfiles-verify-state}" zsh -i -c exit 2>/tmp/dotfiles-zsh.err && [[ ! -s /tmp/dotfiles-zsh.err ]]; then pass 'zsh interactive startup (empty stderr)'; else failed 'zsh interactive startup'; fi
else failed 'zsh executable'; fi
if command -v hyprland >/dev/null 2>&1 && [[ -n ${WAYLAND_DISPLAY:-} ]]; then
  if XDG_CONFIG_HOME="$home/.config" hyprland --verify-config >/dev/null; then pass 'Hyprland config'; else failed 'Hyprland config'; fi
else printf 'SKIP | Hyprland runtime verification requires a Wayland session\n'; fi
exit "$fail"
