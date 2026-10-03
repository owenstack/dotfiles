#!/usr/bin/env bash
set -euo pipefail

dry_run=0
if [[ ${1:-} == --dry-run ]]; then
  dry_run=1
elif (($# > 0)); then
  echo 'Usage: install-helium.sh [--dry-run]' >&2
  exit 2
fi

home=${HOME:?HOME must be set}
destination="$home/Applications/Helium.AppImage"
api_url=https://api.github.com/repos/imputnet/helium-linux/releases/latest
case $(uname -m) in
x86_64) asset_suffix=x86_64.AppImage ;;
aarch64 | arm64) asset_suffix=arm64.AppImage ;;
*)
  printf 'Helium AppImage is unsupported on %s.\n' "$(uname -m)" >&2
  exit 1
  ;;
esac

if ((dry_run)); then
  printf 'DRY-RUN query %s for latest %s asset and SHA-256 digest\n' "$api_url" "$asset_suffix"
  printf 'DRY-RUN install verified asset to %s\n' "$destination"
  exit 0
fi

command -v curl >/dev/null 2>&1 || {
  echo 'curl is required.' >&2
  exit 1
}
command -v jq >/dev/null 2>&1 || {
  echo 'jq is required.' >&2
  exit 1
}
command -v sha256sum >/dev/null 2>&1 || {
  echo 'sha256sum is required.' >&2
  exit 1
}

release=$(curl --retry 3 --retry-all-errors --retry-delay 2 -fsSL "$api_url")
asset=$(jq -er --arg suffix "$asset_suffix" '[.assets[] | select(.name | endswith($suffix))][0] // error("matching AppImage asset missing")' <<<"$release")
url=$(jq -er '.browser_download_url | select(startswith("https://github.com/imputnet/helium-linux/releases/download/"))' <<<"$asset")
digest=$(jq -er '.digest | select(startswith("sha256:")) | sub("^sha256:"; "") | select(test("^[0-9a-f]{64}$"))' <<<"$asset")
version=$(jq -er '.tag_name' <<<"$release")

temporary_dir=$(mktemp -d "${TMPDIR:-/tmp}/helium.XXXXXXXX")
trap 'rm -rf -- "$temporary_dir"' EXIT
download="$temporary_dir/Helium.AppImage"
curl --retry 3 --retry-all-errors --retry-delay 2 -fL "$url" -o "$download"
printf '%s  %s\n' "$digest" "$download" | sha256sum --check --status || {
  echo 'Helium AppImage SHA-256 digest did not match GitHub release metadata.' >&2
  exit 1
}
chmod 755 "$download"
mkdir -p "$(dirname "$destination")"
if [[ -e $destination || -L $destination ]]; then
  backup="$home/.dotfiles-backup/helium-$(date +%Y%m%d-%H%M%S)/Helium.AppImage"
  mkdir -p "$(dirname "$backup")"
  cp -a -- "$destination" "$backup"
  printf 'Backed up existing Helium AppImage to %s\n' "$backup"
fi
mv -f -- "$download" "$destination"
printf 'Installed Helium %s from the official GitHub release to %s\n' "$version" "$destination"
