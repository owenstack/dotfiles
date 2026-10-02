#!/usr/bin/env bash
set -euo pipefail
script_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
root=$(git rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$script_root")
if ! git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 && [[ -d ${HOME:?}/.dotfiles ]]; then
  export GIT_DIR="$HOME/.dotfiles" GIT_WORK_TREE="$root"
fi
git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo 'Run from a dotfiles Git checkout or configured bare work tree.' >&2
  exit 1
}
cd "$root"
fail=0
if command -v shellcheck >/dev/null 2>&1; then git ls-files -z -- '*.sh' '*.bash' | xargs -0 -r shellcheck --severity=error || fail=1; else echo 'SKIP missing shellcheck'; fi
if command -v shfmt >/dev/null 2>&1; then
  shfmt -d -i 2 bootstrap/*.sh scripts/*.sh .githooks/* || fail=1
else echo 'SKIP missing shfmt'; fi
if command -v stylua >/dev/null 2>&1; then git ls-files -z -- '*.lua' | xargs -0 -r stylua --check || fail=1; else echo 'SKIP missing stylua'; fi
if command -v gitleaks >/dev/null 2>&1; then gitleaks detect --source . --redact || fail=1; else echo 'SKIP missing gitleaks'; fi
collisions=$(git ls-files | tr '[:upper:]' '[:lower:]' | sort | uniq -d)
if [[ -n $collisions ]]; then
  printf 'case collisions:\n%s\n' "$collisions"
  fail=1
fi
username=owenstack
if rg --hidden -n "/home/$username" . --glob '!docs/**' --glob '!.git/**'; then fail=1; fi
exit "$fail"
