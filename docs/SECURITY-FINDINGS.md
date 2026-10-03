# Security scan findings

Scan date: 2026-10-02. Full-history gitleaks scan **PASSED**: gitleaks v8.30.1, 30 commits / about 3.49 MB scanned, 0 findings. Working-tree scan **PASSED**: about 1.61 MB scanned, 0 findings. The clone contained the available `main` history and all refs; no tags or other refs were present. JSON reports were written to `/tmp/gitleaks-history.json` and `/tmp/gitleaks-tree.json` and contained zero findings.

History investigation included `git log --all -S'API_KEY'` and path enumeration for weather files, QuickShell settings panels, `.env*`, PEM/key files, Wallust state, `.current_wallpaper`, and `.cache`. These searches found paths and historical API_KEY code, but no gitleaks finding or credential value. `git log -S` found the settings-panel change at `d1caaa8a2529dffcc213d2a682662f061acb47e5`; the writer now stores the value below `${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/weather_api.conf` and requests mode 0600 after writing. The QuickShell FileView API does not expose a file creation mode; the UI applies `chmod 600` immediately after writing, leaving a short creation-to-chmod interval.

Trufflehog second opinion: **NOT RUN**; no local binary was available and Docker was inaccessible to the current user. `.gitleaks.toml` has no allowlist entries. Its sole custom rule detects quoted `API_KEY` assignments of 12 or more characters; default rules remain enabled by `useDefault = true`. The rule narrows extra detection to the known weather-secret serialization format and does not suppress default rules.

The workflow now checks out full history, scans all refs plus the working tree, and runs weekly. The runner scan is pending CI; local equivalent passed as above.
