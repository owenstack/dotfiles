#!/usr/bin/env bash
set -euo pipefail
DRY_RUN=0
NO_PACKAGES=0
YES=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1;;
    --no-packages) NO_PACKAGES=1;;
    --yes) YES=1;;
    -h|--help) echo 'Usage: bootstrap.sh [--dry-run] [--no-packages] [--yes]'; exit 0;;
    *) echo "Unknown option: $arg" >&2; exit 2;;
  esac
done
(( EUID != 0 )) || { echo 'Refusing to run as root.' >&2; exit 1; }
[[ -f /etc/arch-release ]] || { echo 'This bootstrap requires Arch Linux or CachyOS.' >&2; exit 1; }
command -v curl >/dev/null || { echo 'curl is required to run the bootstrap.' >&2; exit 1; }
command -v pacman >/dev/null || { echo 'pacman is required on Arch-based systems.' >&2; exit 1; }
if (( ! DRY_RUN )); then
  sudo -v
  required=()
  command -v git >/dev/null 2>&1 || required+=(git)
  pacman -Q base-devel >/dev/null 2>&1 || required+=(base-devel)
  if ((${#required[@]})); then
    if (( YES )); then sudo pacman -S --needed --noconfirm "${required[@]}"
    else sudo pacman -S --needed "${required[@]}"
    fi
  fi
  curl -fsSI --connect-timeout 5 https://github.com >/dev/null || { echo 'Network check failed.' >&2; exit 1; }
else
  echo 'DRY-RUN: Arch/root/network/package checks will be evaluated without changes.'
fi
home=${HOME:?HOME must be set}
dotdir="$home/.dotfiles"
dot() { git --git-dir="$dotdir" --work-tree="$home" "$@"; }
if [[ ! -d $dotdir ]]; then
  if (( DRY_RUN )); then echo "DRY-RUN git clone --bare https://github.com/owenstack/dotfiles.git $dotdir"
  else git clone --bare https://github.com/owenstack/dotfiles.git "$dotdir"; fi
else
  if (( DRY_RUN )); then echo "DRY-RUN git --git-dir=$dotdir fetch --all --prune"
  else dot fetch --all --prune; fi
fi
if (( ! DRY_RUN )); then
  dot config --local status.showUntrackedFiles no
  dot config --local core.hooksPath .githooks
fi
backup="$home/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
if (( ! DRY_RUN )); then
  mkdir -p "$backup"
  while IFS= read -r -d '' path; do
    target="$home/$path"
    [[ -e $target || -L $target ]] || continue
    expected=$(mktemp)
    if dot show "HEAD:$path" > "$expected" 2>/dev/null && ! cmp -s "$expected" "$target"; then
      mkdir -p "$backup/$(dirname "$path")"
      cp -a "$target" "$backup/$path"
      printf 'Backed up %s\n' "$path"
    fi
    rm -f "$expected"
  done < <(dot ls-tree -r --name-only -z HEAD)
  rmdir "$backup" 2>/dev/null || true
fi
if (( DRY_RUN )); then echo 'DRY-RUN dot checkout (conflicts would be backed up first)'
else dot checkout
fi
if (( ! NO_PACKAGES )); then
  if (( DRY_RUN )); then echo 'DRY-RUN install packages listed in bootstrap/packages/*.txt'
  else
    valid=(); failed=()
    while IFS= read -r name; do
      [[ -z $name || $name == \#* ]] && continue
      if pacman -Si "$name" >/dev/null 2>&1; then valid+=("$name"); else failed+=("$name"); fi
    done < "$home/bootstrap/packages/pacman.txt"
    if ((${#valid[@]})); then sudo pacman -S --needed "${valid[@]}"; fi
    if ((${#failed[@]})); then printf 'Unavailable packages (review manually): %s\n' "${failed[*]}"; fi
    if ! command -v paru >/dev/null 2>&1 && ! command -v yay >/dev/null 2>&1; then
      if pacman -Si paru >/dev/null 2>&1; then sudo pacman -S --needed paru; fi
    fi
    aur_helper=$(command -v paru || command -v yay || true)
    if [[ -n $aur_helper ]]; then
      while IFS= read -r name; do
        [[ -z $name || $name == \#* ]] && continue
        "$aur_helper" -Si "$name" >/dev/null 2>&1 && "$aur_helper" -S --needed "$name" || echo "AUR package unavailable: $name"
      done < "$home/bootstrap/packages/aur.txt"
    else echo 'No AUR helper is available; skipping AUR list.'; fi
  fi
fi
if (( DRY_RUN )); then echo 'DRY-RUN bootstrap/post-install.sh'; else
  post_args=(); (( YES )) && post_args+=(--yes)
  bash "$home/bootstrap/post-install.sh" "${post_args[@]}"
fi
printf '\nBootstrap finished.\n'
if [[ -d $backup ]]; then printf 'Backups: %s\n' "$backup"; else echo 'Backups: none'; fi
echo 'Manual steps: review package failures, run gh auth login, confirm display-manager session and hardware-specific monitor settings.'
