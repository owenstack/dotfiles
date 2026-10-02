# Decisions

## Open questions for owner

- Is `GDK_SCALE=2` intentional on a 1080p panel? Keep current scale 1 plus GDK_SCALE=2 (current behavior) or set GDK_SCALE=1 to match the panel; changing it can alter application sizing, so no visual change was made.
- Confirm the owner’s preferred license for original configuration. An MIT `LICENSE` is proposed but not committed pending confirmation.

## Recorded choices

- Retain the top-bar Quickshell configuration under Needs owner review: no startup or keybind edge was found, but deletion is irreversible from the user perspective and the brief says to retain it when uncertain.
- Use Open-Meteo `WeatherWrap.sh` as the top-bar weather source because it uses the existing no-key weather implementation and its fallback, instead of introducing another dependency on an absent ags tree.
- Canonicalize Kvantum at `.config/Kvantum/`, which matches the live theme settings and current Catppuccin theme-switch commands; preserve the Everforest theme assets under the canonical directory.
- Keep current monitor geometry and scale. Extracting this changes config architecture, not visual output; validation against Hyprland 0.55 Lua monitor module support remains needed before relocation.
- Pin mise to supported policy choices: use Node LTS, major Go and Bun lines where known, and `latest` only for GitHub CLI; exact versions should be resolved and locked by installed mise during bootstrap.
