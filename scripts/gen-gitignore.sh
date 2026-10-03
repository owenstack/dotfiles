#!/usr/bin/env bash
set -euo pipefail

dry_run=0
[[ ${1:-} == --dry-run ]] && dry_run=1
script_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
root=$(git rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$script_root")
if ! git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 && [[ -d ${HOME:?}/.dotfiles ]]; then
  export GIT_DIR="$HOME/.dotfiles" GIT_WORK_TREE="$root"
fi
git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo 'Run from a dotfiles Git checkout or configured bare work tree.' >&2
  exit 1
}
cd "$root"
out=$(mktemp)
trap 'rm -f "$out"' EXIT
{
  printf '%s\n' '/*' '!/.gitignore'
  declare -A emitted_dirs=()
  while IFS= read -r -d '' path; do
    IFS=/ read -r -a parts <<<"$path"
    current=""
    for ((i = 0; i < ${#parts[@]} - 1; i++)); do
      current+="/${parts[i]}"
      if [[ -z ${emitted_dirs[$current]+x} ]]; then
        printf '!%s/\n' "$current"
        emitted_dirs[$current]=1
      fi
    done
    printf '!/%s\n' "$path"
  done < <(git ls-files -z)
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
/.config/hypr/env.local
/.config/kitty/kitty-themes/
/.config/wlogout/colors-wlogout.css
IGNORE
} >"$out"
if ((dry_run)); then cat "$out"; else cp "$out" .gitignore; fi
