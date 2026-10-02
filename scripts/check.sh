#!/usr/bin/env bash
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
fail=0
if command -v shellcheck >/dev/null 2>&1; then git ls-files -z -- '*.sh' '*.bash' | xargs -0 -r shellcheck || fail=1; else echo 'SKIP missing shellcheck'; fi
if command -v shfmt >/dev/null 2>&1; then git ls-files -z -- '*.sh' '*.bash' | xargs -0 -r shfmt -d || fail=1; else echo 'SKIP missing shfmt'; fi
if command -v stylua >/dev/null 2>&1; then git ls-files -z -- '*.lua' | xargs -0 -r stylua --check || fail=1; else echo 'SKIP missing stylua'; fi
if command -v gitleaks >/dev/null 2>&1; then gitleaks detect --source . --redact || fail=1; else echo 'SKIP missing gitleaks'; fi
collisions=$(git ls-files | tr '[:upper:]' '[:lower:]' | sort | uniq -d)
if [[ -n $collisions ]]; then printf 'case collisions:\n%s\n' "$collisions"; fail=1; fi
username=owenstack
if rg --hidden -n "/home/$username" . --glob '!docs/**' --glob '!.git/**'; then fail=1; fi
exit "$fail"
