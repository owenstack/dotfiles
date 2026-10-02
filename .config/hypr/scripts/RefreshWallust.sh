#!/usr/bin/env bash
# Refresh QuickShell and generated palettes after wallpaper or monitor changes.

SCRIPTSDIR=$HOME/.config/hypr/scripts
UserScripts=$HOME/.config/hypr/UserScripts

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

# Kill already running processes
_ps=(rofi)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# Refresh generated palettes before restarting the active QuickShell configuration.
"${SCRIPTSDIR}/WallustSwww.sh"
sleep 0.2
pkill -x qs >/dev/null 2>&1 || true
qs -c task-bar >/dev/null 2>&1 &

dunstctl reload >/dev/null 2>&1 || true

# Relaunching rainbow borders if the script exists
sleep 1
if file_exists "${UserScripts}/RainbowBorders.sh"; then
    ${UserScripts}/RainbowBorders.sh &
fi


exit 0