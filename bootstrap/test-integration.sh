#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == --dry-run ]]; then
  echo 'DRY-RUN: create a temporary user/HOME, preserve a conflicting .zshrc, then verify a no-change second checkout.'
  exit 0
fi
[[ ${DOTFILES_CI_CONTAINER:-} == 1 ]] || {
  echo 'Set DOTFILES_CI_CONTAINER=1 to run this container-only integration test.' >&2
  exit 2
}
((EUID == 0)) || {
  echo 'Run this test as root inside a disposable Arch container.' >&2
  exit 1
}
[[ -f /etc/arch-release ]] || {
  echo 'This integration test requires an Arch container.' >&2
  exit 1
}
for tool in git curl sudo runuser useradd userdel; do
  command -v "$tool" >/dev/null || {
    echo "Missing test dependency: $tool" >&2
    exit 1
  }
done
pacman -Q base-devel >/dev/null 2>&1 || {
  echo 'base-devel must be installed in the test container.' >&2
  exit 1
}

test_user="dotsmoke-$$"
test_home=$(mktemp -d /tmp/dotfiles-bootstrap.XXXXXX)
sudoers_file="/etc/sudoers.d/$test_user"
cleanup() {
  userdel "$test_user" >/dev/null 2>&1 || true
  rm -f -- "$sudoers_file"
  [[ $test_home == /tmp/dotfiles-bootstrap.* ]] && rm -rf -- "$test_home"
}
trap cleanup EXIT
useradd --no-create-home --home-dir "$test_home" --shell /bin/bash "$test_user"
chown "$test_user:$test_user" "$test_home"
printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$test_user" >"$sudoers_file"
chmod 0440 "$sudoers_file"

runuser -u "$test_user" -- env HOME="$test_home" DOTFILES_REPO_URL="$PWD" REPO_ROOT="$PWD" bash -s <<'USER_SCRIPT'
set -euo pipefail
dotdir="$HOME/.dotfiles"
git init --bare "$dotdir" >/dev/null
git --git-dir="$dotdir" config remote.origin.url "$DOTFILES_REPO_URL"
git --git-dir="$dotdir" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git --git-dir="$dotdir" fetch "$DOTFILES_REPO_URL" HEAD:refs/heads/ci-test >/dev/null
git --git-dir="$dotdir" symbolic-ref HEAD refs/heads/ci-test
printf 'preexisting CI conflict\n' >"$HOME/.zshrc"

bash "$REPO_ROOT/bootstrap/bootstrap.sh" --no-packages --no-post-install --yes
backup_file=$(find "$HOME/.dotfiles-backup" -type f -path '*/.zshrc' -print -quit)
[[ -n $backup_file && -f $backup_file ]]
grep -Fx 'preexisting CI conflict' "$backup_file" >/dev/null
cmp "$HOME/.zshrc" "$REPO_ROOT/.zshrc"
first_mtime=$(stat -c %y "$HOME/.zshrc")
backup_count=$(find "$HOME/.dotfiles-backup" -mindepth 1 -maxdepth 1 -type d | wc -l)

bash "$REPO_ROOT/bootstrap/bootstrap.sh" --no-packages --no-post-install --yes
second_mtime=$(stat -c %y "$HOME/.zshrc")
second_backup_count=$(find "$HOME/.dotfiles-backup" -mindepth 1 -maxdepth 1 -type d | wc -l)
[[ $first_mtime == "$second_mtime" ]]
[[ $backup_count == "$second_backup_count" ]]
[[ -z $(git --git-dir="$dotdir" --work-tree="$HOME" status --porcelain) ]]
echo 'PASS: conflicting file backed up; second checkout left files and backups unchanged.'
USER_SCRIPT
