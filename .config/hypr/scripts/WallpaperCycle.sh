#!/usr/bin/env bash
set -euo pipefail

pictures_dir="$(xdg-user-dir PICTURES 2>/dev/null || true)"
if [[ -z "$pictures_dir" || ! -d "$pictures_dir/wallpapers" ]]; then
  pictures_dir="$HOME/Pictures"
fi
wallpaper_dir="$pictures_dir/wallpapers"
wallust_script="$HOME/.config/hypr/scripts/WallustSwww.sh"
current_marker="$HOME/.config/rofi/.current_wallpaper"

if [[ ! -d "$wallpaper_dir" ]]; then
  printf 'Wallpaper folder not found: %s\n' "$wallpaper_dir" >&2
  exit 1
fi

mapfile -d '' wallpapers < <(
  find -L "$wallpaper_dir" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
       -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.tif' \
       -o -iname '*.tiff' -o -iname '*.gif' -o -iname '*.pnm' \
       -o -iname '*.tga' -o -iname '*.farbfeld' \) -print0 \
    | sort -z
)

if (( ${#wallpapers[@]} == 0 )); then
  printf 'No supported wallpapers found in %s\n' "$wallpaper_dir" >&2
  exit 1
fi

current_wallpaper="$(readlink -f "$current_marker" 2>/dev/null || true)"
current_index=-1
for i in "${!wallpapers[@]}"; do
  if [[ "${wallpapers[$i]}" == "$current_wallpaper" ]]; then
    current_index=$i
    break
  fi
done

next_index=$(( (current_index + 1) % ${#wallpapers[@]} ))
next_wallpaper="${wallpapers[$next_index]}"

if ! awww query >/dev/null 2>&1; then
  awww-daemon --format xrgb >/dev/null 2>&1 &
  ready=false
  for _ in {1..50}; do
    if awww query >/dev/null 2>&1; then
      ready=true
      break
    fi
    sleep 0.1
  done
  if [[ "$ready" != true ]]; then
    printf 'awww daemon did not become ready\n' >&2
    exit 1
  fi
fi

awww img "$next_wallpaper" --transition-type fade
"$wallust_script" "$next_wallpaper"

if command -v notify-send >/dev/null 2>&1; then
  notify-send --app-name=Wallpaper "Wallpaper changed" "$(basename "$next_wallpaper")"
fi
