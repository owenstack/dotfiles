#!/usr/bin/env bash

set -o pipefail

hyprctl binds -j | jq -r '
  def modifiers:
    {
      "0": "",
      "1": "SHIFT",
      "4": "CTRL",
      "5": "CTRL + SHIFT",
      "8": "ALT",
      "9": "ALT + SHIFT",
      "12": "CTRL + ALT",
      "64": "SUPER",
      "65": "SUPER + SHIFT",
      "68": "SUPER + CTRL",
      "72": "SUPER + ALT"
    }[.modmask | tostring] // ("MOD " + (.modmask | tostring));

  .[]
  | select(.description != "")
  | (([modifiers, .key] | map(select(. != "")) | join(" + ")) + "\t" + .description)
' | sort -fu | rofi -dmenu -i -p "Keyboard shortcuts" -no-custom >/dev/null
