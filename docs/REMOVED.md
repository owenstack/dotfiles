# Removed and migrated files

This log records deletions and case/path migrations. Git history retains prior contents.

## Phase 2 portability migrations

| Former path | Reason / evidence | Result |
|---|---|---|
| `.config/kvantum/kvantum.kvconfig` | Duplicate case-colliding Kvantum config; live `.config/Kvantum/kvantum.kvconfig` and DarkLight settings select Catppuccin assets in uppercase path. | Canonicalized under `.config/Kvantum/`; canonical selected theme remains Catppuccin. |
| `.config/kvantum/EverforestGreenDark/*`, `.config/kvantum/EverforestGreenLight/*` | Case-colliding duplicate tree; no script selected its configured Everforest theme. | Theme assets preserved by moving them to `.config/Kvantum/`. |
| `.config/kvantum/kdeglobals` | No reader or writer references this nonstandard nested path; theme scripts use `$HOME/.config/kdeglobals`. | Removed. |
| `.config/qt5ct/qt5ct.conf`, `.config/qt6ct/qt6ct.conf` | Contained `/home/owenstack`; Qtct settings use absolute palette paths and do not expand shell variables. | Converted to install-rendered `.conf.tmpl` templates; installer still needs to render them. |

## Needs owner review

- `.config/quickshell/top-bar/`: no startup edge found; retained because it may be manually launched.
- Whether the optional top-bar profile image should be supplied, and whether `GDK_SCALE=2` is intentional on the 1080p panel.
