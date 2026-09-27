#!/usr/bin/env bash

if ! awww query >/dev/null 2>&1; then
  awww-daemon --format xrgb &
  sleep 0.5
fi

for candidate in \
  "$(readlink -f "$HOME/.config/rofi/.current_wallpaper" 2>/dev/null)" \
  "$HOME/.local/state/theme/current_wallpaper" \
  "$HOME/.config/hypr/background.jpg"; do
  if [[ -f "$candidate" ]]; then
    awww img "$candidate" --transition-type none
    exit $?
  fi
done

notify-send -a "surface-dots" "No wallpaper found" \
  "Choose one from the hub or place an image at ~/.local/state/theme/current_wallpaper"
