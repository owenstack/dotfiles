# Security scan findings

Baseline scan date: 2026-10-02. No `gitleaks` binary is installed in the environment, so an independent gitleaks scan could not be run. A textual scan was performed for common credential markers and API key write paths; the QuickShell settings panel currently writes a user-entered weather API key to `~/.config/quickshell/weather_api.conf` (see Phase 2 remediation). No secret value is recorded here. Run `gitleaks detect` after installing gitleaks and before publishing.
