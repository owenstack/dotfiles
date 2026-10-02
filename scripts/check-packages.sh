#!/usr/bin/env bash
set -euo pipefail

script_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
pacman_manifest="$script_root/bootstrap/packages/pacman.txt"
aur_manifest="$script_root/bootstrap/packages/aur.txt"
dry_run=0

if [[ ${1:-} == --dry-run ]]; then
  dry_run=1
elif (($# > 0)); then
  echo 'Usage: check-packages.sh [--dry-run]' >&2
  exit 2
fi

[[ -f $pacman_manifest && -f $aur_manifest ]] || {
  echo 'Package manifests are missing.' >&2
  exit 2
}

is_cachyos=0
if [[ -f /etc/cachyos-release ]] || grep -qi '^ID=cachyos$' /etc/os-release 2>/dev/null; then
  is_cachyos=1
fi

if ((dry_run)); then
  echo 'DRY-RUN package validation plan:'
  while IFS= read -r line; do
    package=${line%%#*}
    package=${package//[[:space:]]/}
    [[ -z $package ]] || printf 'pacman -Si %s\n' "$package"
  done <"$pacman_manifest"
  while IFS= read -r line; do
    package=${line%%#*}
    package=${package//[[:space:]]/}
    [[ -z $package ]] || printf 'AUR RPC info %s\n' "$package"
  done <"$aur_manifest"
  exit 0
fi

[[ -f /etc/arch-release || $is_cachyos == 1 ]] || {
  echo 'Run this check inside an Arch Linux or CachyOS container.' >&2
  exit 2
}
command -v pacman >/dev/null || {
  echo 'pacman is required.' >&2
  exit 2
}
command -v python3 >/dev/null || {
  echo 'python3 is required for the AUR RPC check.' >&2
  exit 2
}

echo 'Synchronizing Arch package databases before validation.'
pacman -Sy --noconfirm

failed=0
printf '\n%-34s %-16s %s\n' 'PACKAGE' 'STATUS' 'DETAIL'
printf '%-34s %-16s %s\n' '-------' '------' '------'
while IFS= read -r line; do
  package=${line%%#*}
  package=${package//[[:space:]]/}
  [[ -z $package ]] && continue

  if [[ $line == *'# cachyos'* ]] && ((is_cachyos == 0)); then
    printf '%-34s %-16s %s\n' "$package" 'NOT VERIFIED' 'CachyOS-only repo entry; Arch container cannot validate it'
  elif pacman -Si "$package" >/dev/null 2>&1; then
    repository=$(pacman -Si "$package" | sed -n 's/^Repository[[:space:]]*:[[:space:]]*//p' | head -n 1)
    printf '%-34s %-16s %s\n' "$package" 'PASS' "pacman repo: ${repository:-unknown}"
  else
    printf '%-34s %-16s %s\n' "$package" 'FAIL' 'not found by pacman -Si'
    failed=1
  fi
done <"$pacman_manifest"

if python3 - "$aur_manifest" <<'PY'
import datetime
import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

manifest = sys.argv[1]
packages = []
with open(manifest, encoding="utf-8") as source:
    for line in source:
        package = line.split("#", 1)[0].strip()
        if package:
            packages.append(package)

results = {}
request_error = None
for start in range(0, len(packages), 50):
    batch = packages[start : start + 50]
    query = urllib.parse.urlencode([("arg[]", package) for package in batch])
    url = f"https://aur.archlinux.org/rpc/v5/info?{query}"
    for attempt in range(5):
        request = urllib.request.Request(
            url,
            headers={"User-Agent": "owenstack-dotfiles-package-check/1.0"},
        )
        try:
            with urllib.request.urlopen(request, timeout=20) as response:
                payload = json.load(response)
            if payload.get("type") != "multiinfo":
                raise ValueError("unexpected AUR RPC response type")
            results.update((item["Name"], item) for item in payload.get("results", []))
            request_error = None
            break
        except urllib.error.HTTPError as error:
            request_error = f"HTTP {error.code}"
            if error.code not in (429, 500, 502, 503, 504) or attempt == 4:
                break
        except (OSError, ValueError) as error:
            request_error = type(error).__name__
            if attempt == 4:
                break
        time.sleep(min(2**attempt, 16))
    if request_error:
        for package in batch:
            results[package] = {"_error": request_error}

failed = False
print("\nAUR package validation:")
print(f"{'PACKAGE':34} {'STATUS':16} DETAIL")
print(f"{'-------':34} {'------':16} ------")
now = time.time()
two_years = 2 * 365 * 24 * 60 * 60
for package in packages:
    item = results.get(package)
    if item is None:
        print(f"{package:34} {'FAIL':16} missing from AUR RPC (renamed or deleted)")
        failed = True
        continue
    if "_error" in item:
        print(f"{package:34} {'FAIL':16} AUR RPC unavailable: {item['_error']}")
        failed = True
        continue

    warnings = []
    if item.get("OutOfDate"):
        flagged = datetime.datetime.fromtimestamp(item["OutOfDate"], datetime.timezone.utc).date()
        warnings.append(f"OutOfDate since {flagged}")
    if item.get("Maintainer") is None:
        warnings.append("orphaned (Maintainer is null)")
    if now - item.get("LastModified", now) > two_years:
        warnings.append("last modified over 2 years ago")
    version = item.get("Version", "unknown version")
    print(f"{package:34} {'PASS':16} {version}")
    if warnings:
        print(f"  WARN: {'; '.join(warnings)}")

sys.exit(1 if failed else 0)
PY
then
  :
else
  failed=1
fi

exit "$failed"
