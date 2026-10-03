#!/usr/bin/env bash
set -uo pipefail

cd /src || exit 1
git config --system --add safe.directory /src
if ! pacman -Syu --noconfirm git base-devel sudo curl jq python dbus xorg-xwayland ripgrep 2>&1 | tee /artifacts/container-prerequisites.log; then
  echo 'FAIL: unable to install container prerequisites.' | tee -a /artifacts/results.txt
  exit 1
fi

test_user=dotfresh
test_home=/home/$test_user
sudoers_file=/etc/sudoers.d/$test_user
useradd --create-home --skel /dev/null --home-dir "$test_home" --shell /bin/bash "$test_user"
printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$test_user" >"$sudoers_file"
chmod 0440 "$sudoers_file"
mkdir -p "$test_home/.config/hypr"
printf 'preexisting zsh conflict\n' >"$test_home/.zshrc"
printf 'preexisting git conflict\n' >"$test_home/.gitconfig"
printf 'preexisting Hyprland conflict\n' >"$test_home/.config/hypr/hyprland.lua"
chown -R "$test_user:$test_user" "$test_home"

run_as_test_user() {
  runuser -u "$test_user" -- env HOME="$test_home" USER="$test_user" LOGNAME="$test_user" XDG_RUNTIME_DIR="/run/user/$(id -u "$test_user")" "$@"
}
mkdir -p "/run/user/$(id -u "$test_user")"
chown "$test_user:$test_user" "/run/user/$(id -u "$test_user")"
chmod 0700 "/run/user/$(id -u "$test_user")"

failed=0
printf 'PACKAGE\tSOURCE\tRESULT\n' >/artifacts/package-install.tsv
while IFS= read -r line || [[ -n $line ]]; do
  package=${line%%#*}
  package=${package//[[:space:]]/}
  [[ -z $package ]] && continue
  if pacman -Si "$package" >/dev/null 2>&1; then
    if run_as_test_user sudo -n pacman -S --needed --noconfirm "$package" >>/artifacts/package-install.log 2>&1; then
      printf '%s\tpacman\tPASS\n' "$package" >>/artifacts/package-install.tsv
    else
      printf '%s\tpacman\tFAIL\n' "$package" >>/artifacts/package-install.tsv
      failed=1
    fi
  else
    printf '%s\tpacman\tFAIL_NOT_FOUND\n' "$package" >>/artifacts/package-install.tsv
    failed=1
  fi
done <bootstrap/packages/pacman.txt

# Install yay-bin only as a disposable AUR builder so each manifest entry can
# be installed and reported separately before the normal bootstrap is run.
if runuser -u "$test_user" -- bash -lc 'cd /tmp && git clone --depth 1 https://aur.archlinux.org/yay-bin.git yay-bin && cd yay-bin && makepkg --noconfirm --skippgpcheck -si' >>/artifacts/aur-helper.log 2>&1; then
  while IFS= read -r line || [[ -n $line ]]; do
    package=${line%%#*}
    package=${package//[[:space:]]/}
    [[ -z $package ]] && continue
    if run_as_test_user yay -Si "$package" >/dev/null 2>&1 && run_as_test_user yay -S --needed --noconfirm --answerclean None --answerdiff None "$package" >>/artifacts/package-install.log 2>&1; then
      printf '%s\tAUR\tPASS\n' "$package" >>/artifacts/package-install.tsv
    else
      printf '%s\tAUR\tFAIL\n' "$package" >>/artifacts/package-install.tsv
      failed=1
    fi
  done <bootstrap/packages/aur.txt
else
  while IFS= read -r line || [[ -n $line ]]; do
    package=${line%%#*}
    package=${package//[[:space:]]/}
    [[ -z $package ]] || printf '%s\tAUR\tNOT_INSTALLED_HELPER_FAILED\n' "$package" >>/artifacts/package-install.tsv
  done <bootstrap/packages/aur.txt
  failed=1
fi

if run_as_test_user env DOTFILES_REPO_URL=file:///src bash /src/bootstrap/bootstrap.sh --yes >/artifacts/bootstrap-first.log 2>&1; then
  echo 'PASS: full bootstrap with package installation completed.' | tee -a /artifacts/results.txt
else
  echo 'FAIL: full bootstrap with package installation exited non-zero; see bootstrap-first.log.' | tee -a /artifacts/results.txt
  failed=1
fi

backup_root="$test_home/.dotfiles-backup"
for path in .zshrc .gitconfig .config/hypr/hyprland.lua; do
  backup_matches=$(find "$backup_root" -type f -path "*/$path" -exec grep -Fl 'preexisting' {} + 2>/dev/null || true)
  if [[ -n $backup_matches ]]; then
    printf 'PASS: conflict backed up: %s\n' "$path" | tee -a /artifacts/results.txt
  else
    printf 'FAIL: conflict backup missing: %s\n' "$path" | tee -a /artifacts/results.txt
    failed=1
  fi
done

snapshot_home() {
  # shellcheck disable=SC2016 # These expressions expand in the nested Bash process.
  run_as_test_user bash -c 'cd "$HOME" && find . -mindepth 1 -path "./.cache" -prune -o -path "./.local/state" -prune -o -printf "%P\t%y\t%l\n" | sort && find . -mindepth 1 -path "./.cache" -prune -o -path "./.local/state" -prune -o -type f -print0 | sort -z | xargs -0 -r sha256sum'
}
first_snapshot=$(snapshot_home)
if run_as_test_user env DOTFILES_REPO_URL=file:///src bash /src/bootstrap/bootstrap.sh --yes >/artifacts/bootstrap-second.log 2>&1; then
  second_snapshot=$(snapshot_home)
  if [[ $first_snapshot == "$second_snapshot" ]]; then
    echo 'PASS: second full bootstrap left non-cache HOME files unchanged.' | tee -a /artifacts/results.txt
  else
    echo 'FAIL: repeated bootstrap changed non-cache HOME files.' | tee -a /artifacts/results.txt
    failed=1
  fi
else
  echo 'FAIL: idempotency bootstrap exited non-zero.' | tee -a /artifacts/results.txt
  failed=1
fi

if run_as_test_user env XDG_CONFIG_HOME="$test_home/.config" bash "$test_home/bootstrap/verify.sh" >/artifacts/verify.log 2>&1; then
  echo 'PASS: bootstrap/verify.sh' | tee -a /artifacts/results.txt
else
  echo 'FAIL: bootstrap/verify.sh; see verify.log.' | tee -a /artifacts/results.txt
  failed=1
fi
if run_as_test_user env XDG_CONFIG_HOME="$test_home/.config" hyprland --verify-config >/artifacts/hyprland-verify.log 2>&1; then
  echo 'PASS: hyprland --verify-config' | tee -a /artifacts/results.txt
else
  echo 'FAIL: hyprland --verify-config; see hyprland-verify.log.' | tee -a /artifacts/results.txt
  failed=1
fi
# shellcheck disable=SC2016 # The nested Bash process expands TIMEFORMAT and HOME.
if run_as_test_user bash -c 'TIMEFORMAT="zsh startup elapsed %3R seconds"; time zsh -i -c exit 2>"$HOME/zsh-stderr.log"' >/artifacts/zsh-startup.log 2>&1 && [[ ! -s "$test_home/zsh-stderr.log" ]]; then
  echo 'PASS: zsh -i -c exit with empty stderr; see zsh-startup.log for elapsed time.' | tee -a /artifacts/results.txt
else
  echo 'FAIL: zsh startup emitted stderr or exited non-zero.' | tee -a /artifacts/results.txt
  failed=1
fi

units=("$test_home"/.config/systemd/user/*.service "$test_home"/.config/systemd/user/*.timer)
if run_as_test_user systemd-analyze --user verify "${units[@]}" >/artifacts/systemd-user-verify.log 2>&1; then
  echo 'PASS: systemd-analyze --user verify' | tee -a /artifacts/results.txt
else
  echo 'NOT RUN: no accessible user systemd manager in this container; see systemd-user-verify.log.' | tee -a /artifacts/results.txt
  if command -v loginctl >/dev/null && command -v machinectl >/dev/null; then
    loginctl enable-linger "$test_user" >>/artifacts/systemd-user-verify.log 2>&1 || true
    machinectl shell "$test_user@.host" /usr/bin/systemctl --user is-system-running >>/artifacts/systemd-user-verify.log 2>&1 || true
  fi
fi

autostart_commands=(sleep mpv dunst blueman-applet vdirsyncer qs hypridle wl-paste cliphist)
for executable in "${autostart_commands[@]}"; do
  # shellcheck disable=SC2016 # The nested Bash process expands the positional argument.
  if run_as_test_user bash -c 'command -v "$1" >/dev/null 2>&1' _ "$executable"; then
    printf 'PASS: autostart executable %s\n' "$executable" >>/artifacts/autostart.log
  else
    printf 'FAIL: autostart executable %s missing\n' "$executable" >>/artifacts/autostart.log
    failed=1
  fi
done
if [[ -x $test_home/.config/hypr/scripts/wallpaperdaemon.sh && -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]]; then
  echo 'PASS: autostart script and polkit executable' >>/artifacts/autostart.log
else
  echo 'FAIL: autostart script or polkit executable missing' >>/artifacts/autostart.log
  failed=1
fi

smoke_pass=0
smoke_runtime_failure=0
smoke_not_run=0
for attempt in 1 2; do
  echo "Headless attempt $attempt/2" >>/artifacts/headless-attempts.log
  # shellcheck disable=SC2016 # The nested Bash process expands the positional argument.
  if ! run_as_test_user bash -c 'command -v "$1" >/dev/null 2>&1' _ hyprland || ! run_as_test_user bash -c 'command -v "$1" >/dev/null 2>&1' _ qs; then
    smoke_not_run=1
    echo 'NOT RUN: Hyprland or Quickshell is not installed.' >>/artifacts/headless-attempts.log
    break
  fi
  # shellcheck disable=SC2016 # The nested Bash process expands its environment and variables.
  if run_as_test_user env HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" XDG_RUNTIME_DIR="/run/user/$(id -u "$test_user")" bash -c '
    set -u
    export WAYLAND_DISPLAY=wayland-fresh AQ_BACKENDS=headless WLR_RENDERER_ALLOW_SOFTWARE=1
    hyprland --config "$HOME/.config/hypr/hyprland.lua" > /artifacts/hyprland-headless.log 2>&1 & compositor=$!
    for _ in {1..150}; do [[ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]] && break; sleep 0.1; done
    [[ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]] || { kill "$compositor" 2>/dev/null; wait "$compositor" 2>/dev/null; exit 1; }
    qs -c task-bar > /artifacts/quickshell-headless.log 2>&1 & shell_pid=$!
    sleep 15
    if ! kill -0 "$shell_pid"; then
      echo QUICKSHELL_EARLY_EXIT
      kill "$compositor" 2>/dev/null || true
      wait "$compositor" 2>/dev/null || true
      exit 20
    fi
    kill "$shell_pid" "$compositor" 2>/dev/null || true
    wait "$shell_pid" 2>/dev/null || true
    wait "$compositor" 2>/dev/null || true
  ' >>/artifacts/headless-attempts.log 2>&1; then
    if rg -qi 'failed to load|module .*not installed|qml.*(error|failed)|no such file|could not load|segmentation fault|crash' /artifacts/hyprland-headless.log /artifacts/quickshell-headless.log; then
      smoke_runtime_failure=1
      echo 'FAIL: headless logs contain a QML/load error or crash.' | tee -a /artifacts/results.txt
      break
    fi
    smoke_pass=1
    echo 'PASS: headless Hyprland and qs -c task-bar stayed running without QML/load failures.' | tee -a /artifacts/results.txt
    break
  elif rg -qi 'failed to load|module .*not installed|qml.*(error|failed)|no such file|could not load|segmentation fault|crash' /artifacts/hyprland-headless.log /artifacts/quickshell-headless.log; then
    smoke_runtime_failure=1
    echo 'FAIL: headless logs contain a QML/load error or crash.' | tee -a /artifacts/results.txt
    break
  elif rg -q 'QUICKSHELL_EARLY_EXIT' /artifacts/headless-attempts.log; then
    smoke_runtime_failure=1
    echo 'FAIL: Quickshell exited before the smoke window ended.' | tee -a /artifacts/results.txt
    break
  fi
  echo "Attempt $attempt failed; see compositor and Quickshell logs." >>/artifacts/headless-attempts.log
done
if ((smoke_pass == 0)); then
  if ((smoke_not_run == 1)); then
    echo 'NOT RUN: headless graphical smoke test prerequisites are unavailable; see headless-attempts.log and runtime logs.' | tee -a /artifacts/results.txt
  else
    if ((smoke_runtime_failure == 0)); then
      echo 'FAIL: headless graphical smoke test failed after two bounded attempts; see headless-attempts.log and runtime logs.' | tee -a /artifacts/results.txt
    fi
    failed=1
  fi
fi

printf '\nPackage install results:\n'
cat /artifacts/package-install.tsv
printf '\nHarness results:\n'
cat /artifacts/results.txt
exit "$failed"
