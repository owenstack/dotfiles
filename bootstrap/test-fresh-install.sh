#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
log_dir=${FRESH_INSTALL_LOG_DIR:-"$repo_root/fresh-install-logs"}

if [[ ${1:-} == --dry-run ]]; then
  printf 'DRY-RUN: docker run Arch Linux, create an empty non-root HOME, install every package, run full bootstrap, verify configuration, test idempotency and attempt headless Hyprland/Quickshell. Logs: %s\n' "$log_dir"
  exit 0
fi
if (($# > 0)); then
  echo 'Usage: test-fresh-install.sh [--dry-run]' >&2
  exit 2
fi
command -v docker >/dev/null || {
  echo 'docker is required for the fresh-install harness.' >&2
  exit 2
}
docker info >/dev/null 2>&1 || {
  echo 'The Docker daemon is unavailable.' >&2
  exit 2
}

mkdir -p "$log_dir"
docker run --rm --privileged \
  -v "$repo_root:/src:ro" \
  -v "$log_dir:/artifacts" \
  archlinux:latest bash /src/bootstrap/test-fresh-install-container.sh 2>&1 | tee "$log_dir/container.log"
