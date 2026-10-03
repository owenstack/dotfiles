#!/usr/bin/env bash
set -euo pipefail
DRY_RUN=0
YES=0
for arg in "$@"; do case "$arg" in --dry-run) DRY_RUN=1 ;; --yes) YES=1 ;; esac done
((EUID != 0)) || {
  echo 'Refusing to run post-install as root.' >&2
  exit 1
}
run() { if ((DRY_RUN)); then
  printf 'DRY-RUN'
  printf ' %q' "$@"
  printf '\n'
else "$@"; fi; }
home=${HOME:?HOME must be set}
xdg_config=${XDG_CONFIG_HOME:-$home/.config}
xdg_state=${XDG_STATE_HOME:-$home/.local/state}
xdg_cache=${XDG_CACHE_HOME:-$home/.cache}
custom=${ZSH_CUSTOM:-$home/.oh-my-zsh/custom}
backup_root="$home/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
backup_existing() {
  local path=$1 relative
  [[ -e $path || -L $path ]] || return 0
  relative=${path#"$home"/}
  [[ $relative != "$path" ]] || relative="external/$(basename "$path")"
  mkdir -p "$backup_root/$(dirname "$relative")"
  cp -a -- "$path" "$backup_root/$relative"
  printf 'Backed up existing file before overwrite: %s\n' "$path"
}
install_file() {
  local source=$1 target=$2 mode=$3
  if ((DRY_RUN)); then
    printf 'DRY-RUN install -m %s %s %s\n' "$mode" "$source" "$target"
    return
  fi
  if [[ -e $target ]] && ! cmp -s "$source" "$target"; then backup_existing "$target"; fi
  install -m "$mode" "$source" "$target"
}
if [[ ! -d $home/.oh-my-zsh ]]; then run git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$home/.oh-my-zsh"; fi
run mkdir -p "$custom/plugins" "$xdg_state/quickshell" "$xdg_cache/quickshell" "$xdg_config/kitty/kitty-themes" "$xdg_cache/zsh"
if [[ ! -e $xdg_state/quickshell/weather_api.conf ]]; then
  run install -m 600 /dev/null "$xdg_state/quickshell/weather_api.conf"
else
  run chmod 600 "$xdg_state/quickshell/weather_api.conf"
fi
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
    if ((DRY_RUN)); then
      echo "DRY-RUN render $tmpl to $out (existing output will be backed up if different)"
    else
      rendered=$(sed "s|@HOME@|$home|g" "$tmpl")
      if [[ -L $out ]]; then
        backup_existing "$out"
        echo "Replacing generated-config symlink after backup: $out"
        rm -f -- "$out"
      elif [[ -e $out ]] && ! cmp -s <(printf '%s' "$rendered") "$out"; then
        backup_existing "$out"
      fi
      printf '%s' "$rendered" >"$out"
    fi
  fi
done
[[ -e $xdg_cache/quickshell/theme_mode ]] || { if ((DRY_RUN)); then echo 'DRY-RUN create dark theme mode'; else printf 'dark\n' >"$xdg_cache/quickshell/theme_mode"; fi; }
font_source="$xdg_config/kitty/Typewriter Variable"
font_target="$home/.local/share/fonts/Typewriter Variable"
if [[ -d $font_source ]]; then
  run mkdir -p "$font_target"
  for font in "$font_source"/*.ttf; do
    [[ -f $font ]] || continue
    install_file "$font" "$font_target/$(basename "$font")" 644
  done
fi
if command -v fc-cache >/dev/null 2>&1; then run fc-cache -f "$home/.local/share/fonts"; fi
if command -v gh >/dev/null 2>&1 && ! gh auth status >/dev/null 2>&1; then echo 'Run gh auth login to configure GitHub credentials.'; fi
if command -v systemctl >/dev/null 2>&1; then
  echo 'Enabling the wallpaper-cycle user timer (systemctl --user enable --now).'
  run systemctl --user enable --now wallpaper-cycle.timer || true
fi
if ((YES)) && command -v zsh >/dev/null 2>&1; then
  echo '--yes supplied: changing the login shell to zsh.'
  run chsh -s "$(command -v zsh)"
fi
