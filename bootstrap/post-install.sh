#!/usr/bin/env bash
set -euo pipefail
DRY_RUN=0
YES=0
for arg in "$@"; do case "$arg" in --dry-run) DRY_RUN=1;; --yes) YES=1;; esac; done
run() { if ((DRY_RUN)); then printf 'DRY-RUN'; printf ' %q' "$@"; printf '\n'; else "$@"; fi; }
home=${HOME:?HOME must be set}
xdg_config=${XDG_CONFIG_HOME:-$home/.config}
xdg_state=${XDG_STATE_HOME:-$home/.local/state}
xdg_cache=${XDG_CACHE_HOME:-$home/.cache}
custom=${ZSH_CUSTOM:-$home/.oh-my-zsh/custom}
if [[ ! -d $home/.oh-my-zsh ]]; then run env KEEP_ZSHRC=yes RUNZSH=no CHSH=no sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; fi
run mkdir -p "$custom/plugins" "$xdg_state/quickshell" "$xdg_cache/quickshell" "$xdg_config/kitty/kitty-themes" "$xdg_cache/zsh"
if [[ ! -e $xdg_state/quickshell/weather_api.conf ]]; then run install -m 600 /dev/null "$xdg_state/quickshell/weather_api.conf"; fi
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  target="$custom/plugins/$plugin"
  if [[ ! -d $target ]]; then run git clone "https://github.com/zsh-users/$plugin.git" "$target"; fi
done
# agnosterzak may be supplied as an OMZ theme or a user custom theme.
if [[ ! -f $home/.oh-my-zsh/themes/agnosterzak.zsh-theme && ! -f $custom/themes/agnosterzak.zsh-theme ]]; then
  echo 'Manual check: ZSH_THEME=agnosterzak was not found; install the owner-approved theme.' >&2
fi
if command -v mise >/dev/null 2>&1; then run mise install; fi
for config in qt5ct qt6ct; do
  tmpl="$xdg_config/$config/$config.conf.tmpl"
  out="$xdg_config/$config/$config.conf"
  if [[ -f $tmpl ]]; then
    if ((DRY_RUN)); then echo "DRY-RUN render $tmpl to $out"; else sed "s|@HOME@|$home|g" "$tmpl" > "$out"; fi
  fi
done
[[ -e $xdg_cache/quickshell/theme_mode ]] || { if ((DRY_RUN)); then echo 'DRY-RUN create dark theme mode'; else printf 'dark\n' > "$xdg_cache/quickshell/theme_mode"; fi; }
if command -v fc-cache >/dev/null 2>&1; then run fc-cache -f; fi
if command -v gh >/dev/null 2>&1 && ! gh auth status >/dev/null 2>&1; then echo 'Run gh auth login to configure GitHub credentials.'; fi
if command -v systemctl >/dev/null 2>&1; then run systemctl --user enable --now wallpaper-cycle.timer || true; fi
if ((YES)) && command -v zsh >/dev/null 2>&1; then run chsh -s "$(command -v zsh)"; fi
