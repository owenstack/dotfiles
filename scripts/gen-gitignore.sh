#!/usr/bin/env bash
set -euo pipefail

dry_run=0
[[ ${1:-} == --dry-run ]] && dry_run=1
root=$(git rev-parse --show-toplevel)
cd "$root"
out=$(mktemp)
trap 'rm -f "$out"' EXIT
{
  printf '%s\n' '/*' '!/.gitignore'
  declare -A emitted_dirs=()
  while IFS= read -r -d '' path; do
    IFS=/ read -r -a parts <<< "$path"
    current=""
    for ((i=0; i<${#parts[@]}-1; i++)); do
      current+="/${parts[i]}"
      if [[ -z ${emitted_dirs[$current]+x} ]]; then printf '!%s/\n' "$current"; emitted_dirs[$current]=1; fi
    done
    printf '!/%s\n' "$path"
  done < <(git ls-files -z)
  cat <<'IGNORE'

# Generated user state and rendered install templates
/.config/quickshell/weather_api.conf
/.config/quickshell/.cache/
/.cache/quickshell/
/.config/qt5ct/qt5ct.conf
/.config/qt6ct/qt6ct.conf
/.config/ghostty/wallust.conf
/.config/ghostty/theme.conf
IGNORE
} > "$out"
if ((dry_run)); then cat "$out"; else cp "$out" .gitignore; fi
