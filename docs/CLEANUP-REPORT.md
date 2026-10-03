# Cleanup and bootstrap report

Branch: `cleanup/bootstrap`

Status: prepared for review; not merged.

## Results by phase

### Phase 1: inventory and safety

- Added `docs/INVENTORY.md` with the tracked `.config/<app>` inventory and a static reference graph rooted at Hyprland Lua, shader Lua, QuickShell entry points, systemd user units, shell startup, and keybinds.
- Added the security and lint baselines. No credential marker or private-key block was found by the available textual scan. `gitleaks` was unavailable, so neither a full working-tree scan nor history scan is verified.
- Created a normal clone in `/tmp/dotfiles-work` and validated bare-repository status/add/commit behavior in a scratch HOME. The scratch commit required bypassing the gitleaks hook because gitleaks is unavailable.

### Phase 2: correctness and portability

- Repointed QuickShell weather to the existing no-key `WeatherWrap.sh`, moved weather state/cache to XDG locations, made the profile image optional, and put user-entered weather credentials under XDG state with a 0600 chmod and ignore rule.
- Guarded the optional startup sound, removed literal `/home/owenstack` paths from tracked runtime files, consolidated Kvantum under `.config/Kvantum/`, and rendered Qt5ct/Qt6ct absolute-path templates during install.
- Extracted monitor settings into `monitors.lua` with the current monitor scale and `GDK_SCALE=2` unchanged.

### Phase 3: evidence-based cleanup

- Removed unused NixOS helpers, marker files, Waybar, Mako, SwayNC daemon configuration, Cava configuration, unused Micro runtime syntax data and colorschemes, unused btop themes, and 171 vendored Kitty theme files.
- Rewired relevant refresh/theme paths to QuickShell and Dunst, migrated still-used notification art, and fetched Kitty themes on demand. Renamed the case-colliding screenshot helper and the mixed refresh helper. Every deletion and migration is recorded in `docs/REMOVED.md`.
- Retained dynamic animation/shader selections and legacy configs read by helper scripts. Top-bar, Fish, WezTerm, the selected Typewriter font, and upstream license questions remain in owner review.

### Phases 4–5: shell, tooling, and bootstrap

- Hardened zsh startup, history, PATH, mise activation, Git defaults, fallback Bash startup, and bare-repo aliases. Added `scripts/gen-gitignore.sh`, repository checks, hooks, package manifests, installer, post-install, verifier, and pinned-action CI workflow.
- Set mise policy to Node LTS, Bun and Go major lines, and latest GitHub CLI; committed the generated mise lockfile.
- Bootstrap dry runs passed on the CachyOS host. The local bare-repo smoke test passed status/add/commit (hook bypassed only for missing gitleaks). A CI Arch-container integration test seeded a fresh temporary HOME with a conflicting `.zshrc`, verified its backup, and compared a full HOME filesystem/content snapshot across the second run; it passed without package or post-install steps.

### Phase 6: documentation

- Added install/workflow documentation, portability notes, decision log, third-party notice, removal log, inventory, security/lint baselines, and this report. No `LICENSE` was added; MIT remains a proposal for owner confirmation.

## Measurements

Counts and sizes use the same Git-tree method for the original `main` and the final branch. Git blob bytes count tracked file contents without worktree metadata or compression.

| Measure | Original `main` | `cleanup/bootstrap` | Change |
|---|---:|---:|---:|
| Tracked files | 968 | **532** | **−436 files (45.0%)** |
| Git blob payload | 6,014,175 bytes | **5,269,605 bytes** | **−744,570 bytes (12.4%)** |

`zsh -i -c exit` was measured over 20 runs with temporary XDG cache/state directories: median **209.5 ms before** and **91.6 ms after**. Final stderr was empty on all 20 runs.

## Verification

- Passed: `bash -n` on tracked shell scripts; Hyprland `--verify-config` with `XDG_CONFIG_HOME` set to the repository `.config`; case-collision check; required `/home/owenstack` scan outside docs; shell startup timing/empty stderr; bootstrap and post-install dry runs.
- Local tools were unavailable; the PR static CI subsequently passed. CI runs ShellCheck over tracked shell files at error severity, shfmt on maintained bootstrap/check scripts, StyLua over all tracked Lua files, gitleaks on the checked-out tree, collision checks, and the username-path scan. ShellCheck warnings below error severity were not baseline-compared.
- `qmllint` passed 40 tracked QML files but exited 255 without diagnostics on 33; QuickShell runtime loading could not be checked without a Wayland session.
- `systemd-analyze --user verify` could not access a user systemd manager in this environment. No Hyprland/QuickShell graphical session was available.
- Package installation, post-install behavior on a fresh desktop, and the user-systemd timer remain unverified. AUR entries with uncertain names are marked `# VERIFY`; AUR RPC validation was unavailable.
- The attempted local systemd verification and local bootstrap verifier are not equivalent to a fresh Arch install. Target-machine verification remains necessary before calling the desktop bootstrappable.

## Deviations and owner review

### Hook and bootstrap follow-up (2026-10-02)

- **PASSED:** `pacman -Si gitleaks` on the CachyOS host resolved to `extra/gitleaks` v8.30.1.
- **PASSED:** ShellCheck v0.11.0 at warning severity and `shfmt -d -i 2` on touched scripts; bootstrap and post-install dry runs were run with a throwaway `HOME`.
- **PASSED:** both hooks were manually invoked with a minimal `PATH` that omitted gitleaks; each exited nonzero and printed the pacman install command and `--no-verify` escape hatch.
- **NOT RUN:** the Arch-container integration test could not sync Arch package databases because the configured mirrors timed out. The PR CI integration job will provide the clean-container result.

- The brief's aggressive pruning criteria could not safely prove animation/shader presets or legacy `UserConfigs`/`configs` dead: selector/helper code constructs their names dynamically. Those trees remain, documented in `docs/REMOVED.md`.
- `top-bar` is not in autostart but is retained for manual use; Fish is referenced by the overview search command; WezTerm is recognized by QuickShell. These are listed for owner review.
- The `agnosterzak` theme was not found in the tracked tree. Post-install warns if it is absent from the local oh-my-zsh installation; the owner must supply/approve the theme if needed.
- The public AUR and package metadata could not all be queried reliably from this environment. Package install reports unavailable names instead of aborting; check `bootstrap/packages/aur.txt` and `pacman.txt` before relying on a fresh install.
- `shfmt` is enforced on the maintained bootstrap, hook, and repository-check scripts rather than all inherited third-party shell files, which would create broad unrelated formatting churn. ShellCheck runs across tracked shell files at error severity; warning-level results were not compared against a pre-cleanup baseline.
- PR static CI, Arch bootstrap dry-run, and the fresh-HOME conflict-backup/idempotency integration passed. The gitleaks CI checkout was shallow and reported one commit scanned, so full historical secret scanning remains unverified. No visual desktop comparison or full package-consuming install was available.

### Follow-up verification status (2026-10-02)

- **PASSED:** full-history gitleaks v8.30.1 scan across available refs: 30 commits scanned, about 3.49 MB, zero findings. **PASSED:** working-tree gitleaks scan: about 1.61 MB, zero findings. See [SECURITY-FINDINGS.md](SECURITY-FINDINGS.md). This supersedes PR #1's shallow scan status.
- **NOT RUN:** trufflehog second opinion; no local binary was available and the local Docker socket was inaccessible.
- **NOT RUN:** package manifest validation, full fresh-machine package installation, post-install desktop behavior, wallpaper user timer, QuickShell runtime loading, monitor application on the physical display, and graphical visual checks. These remain assigned to later workstreams or the human VM checklist.
- The gitleaks CI checkout is being changed to fetch full history and scan all refs plus the working tree. CI status is pending the follow-up PR.

## Open questions

- Is `GDK_SCALE=2` intentional on a 1080p panel? Keep scale 1 plus GDK scale 2, or change GDK scale to 1; no visible behavior was changed.
- Confirm the proposed MIT license for Owen-authored config.
- Confirm whether to retain the selected Typewriter font and whether to provide the optional QuickShell profile image.
- Confirm the package supplying the `simple_sddm_2` theme and the AUR font/cursor names marked for verification.

## Suggested repository metadata

- Description: `Owen's CachyOS Hyprland and QuickShell dotfiles with a bare-repo bootstrap installer`.
- Suggested topics: `dotfiles`, `cachyos`, `arch-linux`, `hyprland`, `quickshell`, `zsh`, `mise`.

## Original PR #1

Title: **Clean up, harden and add bootstrap**. Do not merge until owner review items and target-machine install checks are addressed.
