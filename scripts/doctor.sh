#!/usr/bin/env bash
set -uo pipefail

home=${HOME:?HOME must be set}
config_home=${XDG_CONFIG_HOME:-$home/.config}
state_home=${XDG_STATE_HOME:-$home/.local/state}
dotdir="$home/.dotfiles"
hypr_config="$config_home/hypr"
quickshell_config="$config_home/quickshell"
failed=0

pass() { printf 'PASS | %s\n' "$1"; }
warn() { printf 'WARN | %s\n' "$1"; }
fail() {
  printf 'FAIL | %s\n' "$1"
  failed=1
}

if [[ ! -d $dotdir ]]; then
  fail 'bare dotfiles repository missing at ~/.dotfiles'
  exit "$failed"
fi
if ! git --git-dir="$dotdir" rev-parse --is-bare-repository >/dev/null 2>&1; then
  fail "$HOME/.dotfiles is not a readable bare Git repository"
  exit "$failed"
fi

if [[ $(git --git-dir="$dotdir" config --get core.hooksPath 2>/dev/null || true) == .githooks ]]; then
  pass 'Git hooks path is .githooks'
else
  fail 'Git core.hooksPath is not .githooks'
fi
if command -v gitleaks >/dev/null 2>&1; then
  pass "gitleaks is available ($(gitleaks version 2>/dev/null | head -n 1))"
else
  fail 'gitleaks executable is missing from PATH'
fi

if status_output=$(git --git-dir="$dotdir" --work-tree="$home" status --porcelain --untracked-files=all 2>/dev/null); then
  if [[ -z $status_output ]]; then
    pass 'dot status is clean, including untracked files'
  else
    fail 'dot status reports tracked changes or untracked files'
  fi
else
  fail 'unable to read dot status'
fi

generate_allowlist() {
  printf '%s\n' '/*' '!/.gitignore'
  declare -A emitted_dirs=()
  while IFS= read -r -d '' path; do
    IFS=/ read -r -a parts <<<"$path"
    current=''
    for ((index = 0; index < ${#parts[@]} - 1; index++)); do
      current+="/${parts[index]}"
      if [[ -z ${emitted_dirs[$current]+x} ]]; then
        printf '!%s/\n' "$current"
        emitted_dirs[$current]=1
      fi
    done
    printf '!/%s\n' "$path"
  done < <(git --git-dir="$dotdir" ls-files -z)
  cat <<'IGNORE'

# Generated user state and rendered install templates
/.local/state/quickshell/weather_api.conf
/.config/quickshell/weather_api.conf
/.config/quickshell/.cache/
/.config/rofi/.current_wallpaper
/.cache/quickshell/
/.config/qt5ct/qt5ct.conf
/.config/qt6ct/qt6ct.conf
/.config/ghostty/wallust.conf
/.config/ghostty/theme.conf
/.config/kitty/kitty-themes/
/.config/wlogout/colors-wlogout.css
IGNORE
}

if [[ -f $home/.gitignore ]] && cmp -s "$home/.gitignore" <(generate_allowlist); then
  pass 'generated .gitignore allow-list matches dot tracked files'
else
  fail 'generated .gitignore allow-list drift detected'
fi

runtime_tools=(dunst blueman-applet vdirsyncer qs hypridle wl-paste cliphist kitty thunar hyprctl quickshell sleep mpv)
for executable in "${runtime_tools[@]}"; do
  if command -v "$executable" >/dev/null 2>&1; then
    pass "autostart/keybind executable: $executable"
  else
    fail "autostart/keybind executable missing: $executable"
  fi
done
for required_path in \
  /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
  "$home/Applications/Helium.AppImage"; do
  if [[ -x $required_path ]]; then
    pass "autostart/keybind executable: ${required_path#"$home"/}"
  else
    fail "autostart/keybind executable missing: ${required_path#"$home"/}"
  fi
done

if [[ -f $hypr_config/hyprland.lua ]]; then
  while IFS= read -r script_name; do
    [[ -n $script_name ]] || continue
    if [[ -x $hypr_config/scripts/$script_name ]]; then
      pass "keybind script exists: $script_name"
    else
      fail "keybind script missing or not executable: $script_name"
    fi
  done < <(sed -nE 's/.*scripts \.\. "([^"]+\.sh)".*/\1/p' "$hypr_config/hyprland.lua" | sort -u)
else
  fail 'Hyprland Lua configuration is missing'
fi

if [[ -d $quickshell_config ]]; then
  if python3 - "$quickshell_config" <<'PY'; then :; else failed=1; fi
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
pattern = re.compile(r'\bsource\s*:\s*(?:Qt\.resolvedUrl\s*\()?\s*["\']([^"\']+)["\']')
extensions = {".png", ".jpg", ".jpeg", ".webp", ".svg", ".gif", ".wav", ".qml", ".js"}
failed = False
for source_file in sorted(root.rglob("*.qml")):
    content = source_file.read_text(encoding="utf-8", errors="replace")
    for match in pattern.finditer(content):
        reference = match.group(1)
        if reference.startswith(("image://", "file://", "qrc:/")) or "${" in reference:
            continue
        if pathlib.Path(reference).suffix.lower() not in extensions:
            continue
        target = (source_file.parent / reference).resolve()
        if target.exists():
            print(f"PASS | QuickShell file: {target.relative_to(root.parent)}")
        elif target.name == "profile.jpg":
            print(f"WARN | optional QuickShell profile image missing: {target}")
        else:
            print(f"FAIL | QuickShell referenced file missing: {target}")
            failed = True
sys.exit(1 if failed else 0)
PY
else
  fail 'Quickshell configuration directory is missing'
fi
for quickshell_file in config.json qml_color.json; do
  if [[ -f $quickshell_config/$quickshell_file ]]; then
    pass "QuickShell runtime file exists: $quickshell_file"
  else
    fail "QuickShell runtime file missing: $quickshell_file"
  fi
done
if [[ -e $home/.cache/quickshell/theme_mode ]]; then
  pass 'QuickShell theme-mode state exists'
else
  warn 'QuickShell theme-mode cache is missing; post-install creates the default'
fi
if [[ -e $config_home/rofi/.current_wallpaper ]]; then
  pass 'QuickShell current-wallpaper link resolves'
else
  fail 'QuickShell current-wallpaper path is missing or broken'
fi

for qt_config in qt5ct qt6ct; do
  rendered="$config_home/$qt_config/$qt_config.conf"
  if [[ ! -f $rendered ]]; then
    fail "rendered Qt configuration missing: $qt_config.conf"
  elif grep -Eq '@[A-Z_]+@|\$\{HOME\}|\$HOME' "$rendered"; then
    fail "rendered Qt configuration has unresolved placeholders: $qt_config.conf"
  else
    pass "rendered Qt configuration: $qt_config.conf"
  fi
done

kvantum_dir="$config_home/Kvantum"
if [[ -d $kvantum_dir && ! -e $config_home/kvantum ]]; then
  pass 'Kvantum has one canonical uppercase config directory'
else
  fail 'Kvantum directory missing or lowercase duplicate exists'
fi
selected_theme=$(sed -nE 's/^theme[[:space:]]*=[[:space:]]*([^[:space:]]+).*/\1/p' "$kvantum_dir/kvantum.kvconfig" 2>/dev/null | head -n 1)
if [[ -n $selected_theme && -f $kvantum_dir/$selected_theme/$selected_theme.kvconfig ]]; then
  pass "selected Kvantum theme resolves: $selected_theme"
else
  fail 'selected Kvantum theme does not resolve to a theme config'
fi

weather_file="$state_home/quickshell/weather_api.conf"
case "$weather_file" in
"$state_home"/*) pass 'weather settings path is below XDG_STATE_HOME' ;;
*) fail 'weather settings path is outside XDG_STATE_HOME' ;;
esac
if [[ -e $weather_file ]]; then
  mode=$(stat -c '%a' "$weather_file" 2>/dev/null || true)
  if [[ $mode == 600 ]]; then pass 'weather settings mode is 0600'; else fail 'weather settings mode is not 0600'; fi
  real_weather=$(readlink -f "$weather_file" 2>/dev/null || printf '%s' "$weather_file")
  relative_weather=${weather_file#"$home"/}
  relative_real=${real_weather#"$home"/}
  if [[ $weather_file == "$home"/* ]] && {
    git --git-dir="$dotdir" ls-files --error-unmatch -- "$relative_weather" >/dev/null 2>&1 ||
      git --git-dir="$dotdir" ls-files --error-unmatch -- "$relative_real" >/dev/null 2>&1
  }; then
    fail 'weather settings file is tracked by dot'
  else
    pass 'weather settings file is not tracked by dot'
  fi
else
  warn 'weather settings file does not exist yet; post-install creates it with mode 0600'
fi

if systemctl --user show-environment >/dev/null 2>&1; then
  if systemctl --user is-active --quiet wallpaper-cycle.timer; then
    pass 'wallpaper-cycle.timer is active'
  elif systemctl --user is-enabled --quiet wallpaper-cycle.timer; then
    warn 'wallpaper-cycle.timer is enabled but not active'
  else
    warn 'wallpaper-cycle.timer is not enabled'
  fi
else
  warn 'no accessible systemd user manager; timer status not checked'
fi

monitor_lua="$hypr_config/monitors.lua"
monitor_output=$(sed -nE 's/.*output[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$monitor_lua" 2>/dev/null | head -n 1)
monitor_mode=$(sed -nE 's/.*mode[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$monitor_lua" 2>/dev/null | head -n 1)
monitor_scale=$(sed -nE 's/.*scale[[:space:]]*=[[:space:]]*([0-9.]+).*/\1/p' "$monitor_lua" 2>/dev/null | head -n 1)
if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && command -v hyprctl >/dev/null 2>&1 && monitor_json=$(hyprctl monitors -j 2>/dev/null) && [[ -n $monitor_json ]]; then
  expected_width=${monitor_mode%%x*}
  expected_height=${monitor_mode#*x}
  expected_height=${expected_height%%@*}
  if [[ -n $monitor_json && -n $monitor_output && -n $monitor_mode && -n $monitor_scale ]] && jq -e --arg name "$monitor_output" --argjson width "$expected_width" --argjson height "$expected_height" --arg scale "$monitor_scale" 'any(.[]; .name == $name and .width == $width and .height == $height and (.scale | tostring) == $scale)' <<<"$monitor_json" >/dev/null; then
    pass "monitor $monitor_output matches $monitor_mode at scale $monitor_scale"
  else
    fail "configured monitor mode/scale did not apply: $monitor_output $monitor_mode scale $monitor_scale"
  fi
else
  warn 'Hyprland session is not running; monitor mode/scale not checked'
fi

if git --git-dir="$dotdir" --work-tree="$home" grep -I -n -F "/home/$(id -un)" HEAD -- .zshrc .zprofile .config/hypr .config/quickshell .config/systemd .config/rofi .config/dunst .config/wallust >/dev/null 2>&1; then
  fail 'tracked runtime files contain a hardcoded current-user /home path'
else
  grep_status=$?
  if ((grep_status == 1)); then
    pass 'tracked runtime files have no hardcoded current-user /home path'
  else
    fail 'unable to scan tracked runtime files for hardcoded /home paths'
  fi
fi

if [[ -e $hypr_config/sounds/startup.wav ]]; then
  pass 'optional startup sound exists'
else
  warn 'optional Hyprland startup sound is missing'
fi

if command -v zsh >/dev/null 2>&1; then
  scratch=$(mktemp -d "${TMPDIR:-/tmp}/dot-doctor.XXXXXX") || exit 1
  trap 'rm -rf -- "$scratch"' EXIT
  started=$(date +%s%N)
  if XDG_CACHE_HOME="$scratch/cache" XDG_STATE_HOME="$scratch/state" HISTFILE="$scratch/history" MISE_AUTO_INSTALL=0 MISE_CACHE_DIR="$scratch/mise-cache" MISE_DATA_DIR="$scratch/mise-data" zsh -i -c exit 2>"$scratch/stderr"; then
    finished=$(date +%s%N)
    elapsed_ms=$(((finished - started) / 1000000))
    if [[ ! -s $scratch/stderr ]]; then
      pass "zsh interactive startup: ${elapsed_ms}ms, stderr empty"
    else
      fail 'zsh interactive startup wrote to stderr'
    fi
  else
    fail 'zsh -i -c exit failed'
  fi
  rm -rf -- "$scratch"
  trap - EXIT
else
  fail 'zsh executable is missing'
fi

exit "$failed"
