# Tracked binary and repository size audit

Measured on `origin/main` at `a097a3e` (2026-10-03). Git-tree sizes are uncompressed blob content lengths from `git ls-tree -r -l HEAD`; they are not the packed repository size. The 532 tracked files contain **5,269,899 bytes** (about 5.03 MiB). `git count-objects -vH` reports 552.00 KiB loose objects and a 3.18 MiB pack; `du -sh .git` reports **4.1 MiB** including filesystem metadata and refs.

The largest entries include source/configuration text as well as images and fonts. No binary was removed in this audit. Personal images and inherited artwork remain owner-review items; changing tracked files would reduce the working tree, but would not reduce existing Git history without a history rewrite. History rewrites are outside this workstream and are not proposed here.

## 30 largest tracked blobs

| Bytes | Path | Classification and handling |
|---:|---|---|
| 292,001 | `.config/rofi/moths.jpg` | Personal/uncertain background artwork; keep pending owner approval. |
| 232,632 | `.config/kitty/Typewriter Variable/cmunvi.ttf` | Third-party CMU Typewriter font; SIL OFL 1.1 notice is retained in the font directory. |
| 193,880 | `.config/kitty/Typewriter Variable/cmunvt.ttf` | Third-party CMU Typewriter font; SIL OFL 1.1 notice is retained. |
| 171,214 | `.config/Kvantum/EverforestGreenLight/EverforestGreenLight.svg` | Third-party theme asset; license/source needs audit. |
| 171,214 | `.config/Kvantum/EverforestGreenDark/EverforestGreenDark.svg` | Third-party theme asset; license/source needs audit. |
| 152,249 | `.config/hypr/assets/notifications/images/note.png` | Inherited JaKooLit notification artwork; license/source needs audit. |
| 149,585 | `.config/fastfetch/h3.png` | Personal/uncertain logo/avatar-style artwork referenced by Fastfetch; keep pending owner approval. |
| 149,470 | `.config/Kvantum/catppuccin-mocha-blue/catppuccin-mocha-blue.svg` | Third-party Catppuccin Kvantum asset; upstream MIT license, attribution added to `NOTICE`. |
| 149,470 | `.config/Kvantum/catppuccin-latte-blue/catppuccin-latte-blue.svg` | Third-party Catppuccin Kvantum asset; upstream MIT license, attribution added to `NOTICE`. |
| 122,248 | `.config/kitty/Typewriter Variable/cmunvi.woff` | Third-party CMU Typewriter webfont format; OFL notice retained. |
| 114,156 | `.config/fastfetch/j.png` | Personal/uncertain logo/avatar-style artwork; keep pending owner approval. |
| 99,328 | `.config/kitty/Typewriter Variable/cmunvt.woff` | Third-party CMU Typewriter webfont format; OFL notice retained. |
| 97,829 | `.config/kitty/Typewriter Variable/cmunvi.eot` | Third-party CMU Typewriter webfont format; OFL notice retained. |
| 88,544 | `.config/hypr/scripts/RofiEmoji.data` | Text data, not a binary; retained by the active emoji picker. |
| 79,007 | `.config/kitty/Typewriter Variable/cmunvt.eot` | Third-party CMU Typewriter webfont format; OFL notice retained. |
| 74,075 | `.config/fastfetch/h.png` | Personal/uncertain logo/avatar-style artwork; keep pending owner approval. |
| 72,889 | `.config/fastfetch/arch.png` | Fastfetch distro artwork; third-party origin/license needs confirmation. |
| 62,849 | `.config/hypr/assets/notifications/images/error.png` | Inherited JaKooLit notification artwork; license/source needs audit. |
| 60,403 | `.config/wlogout/icons/power.png` | Third-party/inherited icon artwork; origin/license needs audit. |
| 58,847 | `.config/quickshell/task-bar/desktop/Taskbar.qml` | Source text, not binary. |
| 51,752 | `.config/hypr/assets/notifications/images/bell.png` | Inherited JaKooLit notification artwork; license/source needs audit. |
| 50,871 | `.config/wlogout/icons/restart.png` | Third-party/inherited icon artwork; origin/license needs audit. |
| 45,191 | `.config/hypr/assets/notifications/images/ja.png` | Inherited JaKooLit notification artwork; license/source needs audit. |
| 44,415 | `.config/quickshell/task-bar/dock/WideDrawer.qml` | Source text, not binary. |
| 43,432 | `.config/hypr/assets/notifications/icons/vpn.png` | Inherited notification icon; origin/license needs audit. |
| 42,555 | `.config/wlogout/icons/power-hover.png` | Third-party/inherited icon artwork; origin/license needs audit. |
| 42,446 | `.config/kitty/Typewriter Variable/cmunvi.svg` | Third-party CMU Typewriter vector font; OFL notice retained. |
| 41,647 | `.config/rofi/jellyfish.jpg` | Personal/uncertain background artwork; keep pending owner approval. |
| 39,591 | `.config/quickshell/task-bar/hub/SettingsPanel.qml` | Source text, not binary. |
| 37,481 | `.config/quickshell/top-bar/bar/Bar.qml` | Source text, not binary. |

The notification artwork is actively referenced from Hyprland scripts, and the Catppuccin/Everforest assets are named in theme configuration or theme-switch code. The Fastfetch images are selected in Fastfetch presets. The two Rofi background images are used by the dark/light Rofi styles. These reference edges make removal a behavior change and do not establish asset ownership.

## Total tracked bytes by extension

| Extension | Bytes |
|---|---:|
| `.png` | 1,600,622 |
| `.svg` | 879,567 |
| `.qml` | 642,532 |
| `.ttf` | 426,512 |
| `.jpg` | 333,648 |
| `.sh` | 230,672 |
| `.woff` | 221,576 |
| `.rasi` | 177,070 |
| `.eot` | 176,836 |
| `.conf` | 116,865 |
| `.data` | 88,544 |
| no extension | 67,549 |
| `.glsl` | 48,323 |
| `.py` | 41,078 |
| `.kvconfig` | 38,322 |
| `.js` | 37,834 |
| `.md` | 37,494 |
| `.txt` | 30,293 |
| `.lua` | 28,918 |
| `.scm` | 8,556 |
| `.lock` | 7,809 |
| `.jsonc` | 6,999 |
| `.toml` | 2,765 |
| `.css` | 2,748 |
| `.xml` | 2,147 |
| `.light` | 2,142 |
| `.dark` | 2,129 |
| `.json` | 2,050 |
| `.tmpl` | 1,896 |
| `.list` | 1,531 |
| `.yml` | 1,444 |
| `.theme` | 1,308 |
| `.micro` | 1,091 |
| `.ini` | 477 |
| `.timer` | 162 |
| `.fish` | 160 |
| `.service` | 146 |
| `.rc` | 84 |

## Total tracked bytes by top-level path

| Top-level path | Bytes |
|---|---:|
| `.config/` | 5,189,011 |
| `docs/` | 27,482 |
| `.gitignore` | 26,110 |
| `bootstrap/` | 13,681 |
| `README.md` | 3,640 |
| `scripts/` | 2,918 |
| `.zshrc` | 1,943 |
| `NOTICE` | 1,943 |
| `.github/` | 1,444 |
| `.gitconfig` | 721 |
| `.githooks/` | 348 |
| `.bashrc` | 308 |
| `.gitleaks.toml` | 233 |
| `.zprofile` | 83 |
| `.bash_profile` | 34 |

## Options and owner review

- **Keep in Git:** preserves the one-step bare-repo checkout and offline availability. Current default; no visual behavior or asset path changes.
- **Fetch at install:** can reduce tracked working-tree and future clone bytes if the asset is not also retained in Git history. Requires stable upstream URL, checksum/signature verification, license review, and a failure/fallback policy. Good only for clear regenerable or third-party assets.
- **External storage:** reduces this repository's current tree once references point to user-managed files, but adds restore and availability work; personal wallpapers/avatar images must not be moved without approval.
- **Git LFS:** can reduce Git object-pack growth after migration but adds LFS client/server requirements and does not suit a plain bare-repo checkout unless those requirements are deliberately documented. It does not retroactively reduce historical objects without a rewrite.

No personal wallpaper/avatar or uncertain third-party asset was removed or replaced. Any reduction to current tracked payload can save at most its current tree bytes; existing history remains unchanged unless the owner separately approves a history rewrite.
