# Follow-up report after PR #1

## Owner actions required

1. **Secrets:** no credential findings were detected by the full-history gitleaks scan, so no rotation or history rewrite is indicated by this audit. Trufflehog's second opinion was not run. Do not rewrite history based on this report; if a later confirmed credential requires it, rotate first and decide on a separately reviewed rewrite plan.
2. **Fresh install and hardware:** follow the checklist in [PR #5](https://github.com/owenstack/dotfiles/pull/5) on a VM or spare machine. Confirm the display manager and first login, wallpaper timer, theme switch, notification, lock screen, monitor mode/scale, cursor, font, `simple_sddm_2` theme path, and Helium launch. The container harness exists, but Docker was unavailable here.
3. **GDK scale:** run the five-minute A/B procedure in [`SCALE-TEST.md`](SCALE-TEST.md). The tracked default remains `GDK_SCALE=2`; the untracked `~/.config/hypr/env.local` lets you compare `1` and `2` without changing that default.
4. **Licensing:** review [`LICENSE-AUDIT.md`](LICENSE-AUDIT.md) and [`LICENSE-PROPOSAL.md`](LICENSE-PROPOSAL.md). Choose a scope for Owen-authored files and resolve the attribution/license status for `snes19xx`-attributed and unclear mixed QuickShell/assets before committing any repository-wide `LICENSE`. No `LICENSE` file was added.
5. **Font and profile images:** decide whether to keep the OFL Computer Modern Typewriter files and whether to supply personal profile images. The images remain optional and are not fetched or committed.
6. **Remaining package decisions:** decide whether Saturnian cursors stay manually installed or get replaced. Validate on a fresh install that `simple-sddm-theme-2-git` installs to `simple_sddm_2`; package metadata is confirmed in [PR #4](https://github.com/owenstack/dotfiles/pull/4), but installation/path verification is not.
7. **GitHub security and branch protection:** run these yourself if desired; no repository settings were changed.

   Enable secret scanning and push protection:

   ```sh
   gh api --method PATCH repos/owenstack/dotfiles \
     --field 'security_and_analysis[secret_scanning][status]=enabled' \
     --field 'security_and_analysis[secret_scanning_push_protection][status]=enabled'
   ```

   Require the always-running CI checks on `main`:

   ```sh
   gh api --method PUT repos/owenstack/dotfiles/branches/main/protection --input - <<'JSON'
   {
     "required_status_checks": {
       "strict": true,
       "contexts": ["static", "bootstrap-dry-run", "bootstrap-checkout-integration"]
     },
     "enforce_admins": false,
     "required_pull_request_reviews": null,
     "restrictions": null
   }
   JSON
   ```

   `package-validation` runs only when package files change and weekly, so it is not listed as an always-present required context. The slow fresh-install workflow is manual/weekly.

   Suggested repository description and topics:

   ```sh
   gh repo edit owenstack/dotfiles \
     --description "Owen's CachyOS Hyprland and QuickShell dotfiles with a bare-repo bootstrap installer" \
     --add-topic dotfiles --add-topic cachyos --add-topic arch-linux \
     --add-topic hyprland --add-topic quickshell --add-topic zsh --add-topic mise
   ```

## Status of the gaps recorded after PR #1

| Known gap | Status | Evidence and remaining limit |
|---|---|---|
| Full-history secret scan | **PASSED** | Local gitleaks v8.30.1 scanned 30 commits/about 3.49 MB and found 0 findings; working-tree scan covered about 1.61 MB and found 0. CI gitleaks job also passed. See [PR #2](https://github.com/owenstack/dotfiles/pull/2). Trufflehog was **NOT RUN** because no binary was available and Docker was unavailable. The clone had the available `main` history but no tags/other refs. |
| Package names | **PASSED**; package install, post-install, and timer | **NOT RUN** | Manifest package names passed CachyOS `pacman -Si` and AUR RPC validation; Arch package-validation CI passed. Added `thunar`, and the official Helium release helper selects the GitHub AppImage and validates GitHub's SHA-256 digest metadata. Actual package installation, Helium download/install, SDDM theme directory, desktop post-install and timer firing are **NOT RUN** locally. See [PR #4](https://github.com/owenstack/dotfiles/pull/4). |
| Hooks work on a fresh machine | **PASSED** | Workstream B's throwaway bare-repo status/add/commit integration test passed in CI with no hook bypass; hooks fail closed with actionable gitleaks install guidance. See [PR #3](https://github.com/owenstack/dotfiles/pull/3). |
| `monitors.lua` applies on the real machine | **NOT RUN** | Hyprland accepts the repository config (`hyprland --verify-config` returned `config ok`), but this environment did not have the owner's installed bare repo or a graphical owner session. Hardware mode/scale must be checked with the checklist in [PR #5](https://github.com/owenstack/dotfiles/pull/5). |
| Dynamic presets, legacy trees and inherited helpers | **PASSED** for reference audit; preset pruning verification | **NOT RUN** | Selector reachability and helper decisions are documented in [PR #7](https://github.com/owenstack/dotfiles/pull/7). Removed only the unreferenced upstream updater that could overwrite the managed home. No animation/shader preset was removed because the reduced-set graphical test was **NOT RUN**; legacy configs remain because helpers read/edit them. |
| Large tracked binary payload | **PASSED: audited** | [PR #8](https://github.com/owenstack/dotfiles/pull/8) lists the 30 largest blobs, extension/directory totals, classifications and size options. No asset was removed; personal/uncertain art needs owner approval, and historical object bytes remain unchanged. |
| Owner review items | **NOT RUN: owner decisions pending** | GDK A/B and license scope are in this PR; Typewriter font and profile-image decisions are in [`LICENSE-AUDIT.md`](LICENSE-AUDIT.md). Saturnian cursor and SDDM path decisions are in [PR #4](https://github.com/owenstack/dotfiles/pull/4). Fantasque Sans Mono Nerd Font is verified as `ttf-fantasque-nerd`; Saturnian cursor package was not found. |

## Pull requests

No PR has been merged by this agent. All branches are based on the same current `main` (`a097a3e`); CodeRabbit was rate-limited on submitted PRs or skipped draft PR #7, so there were no actionable bot comments. GitGuardian and Socket checks passed where shown.

| PR | Workstream | Changed files | CI | Bot review |
|---:|---|---:|---|---|
| [#2](https://github.com/owenstack/dotfiles/pull/2) | A: history secret scan | 4 | Green, including gitleaks | CodeRabbit rate-limited; no comments |
| [#3](https://github.com/owenstack/dotfiles/pull/3) | B: hooks/bootstrap | 10 | Green | CodeRabbit rate-limited; no comments |
| [#4](https://github.com/owenstack/dotfiles/pull/4) | C: package validation, including Helium AppImage helper | 19 | Green, including package-validation | CodeRabbit rate-limited; no comments |
| [#5](https://github.com/owenstack/dotfiles/pull/5) | D: fresh-install harness | 6 | Green | CodeRabbit rate-limited; no comments |
| [#6](https://github.com/owenstack/dotfiles/pull/6) | E: read-only doctor | 4 | Green | CodeRabbit rate-limited; no comments |
| [#7](https://github.com/owenstack/dotfiles/pull/7) | F: safe pruning audit | 5 | Green; draft | CodeRabbit skipped draft |
| [#8](https://github.com/owenstack/dotfiles/pull/8) | G: binary audit | 2 | Green | CodeRabbit rate-limited; no comments |
| [#9](https://github.com/owenstack/dotfiles/pull/9) | H: decision preparation and consolidated report | 9 | Green: static, bootstrap dry-run, integration, GitGuardian, Socket | CodeRabbit review still in progress at report time; no findings yet |

## Tree measurements

The same Git-tree method (`git ls-tree -r -l`) was used for every branch. Each follow-up branch is independent and has `origin/main` as its base, so “before” is 532 files / 5,269,899 blob bytes for each PR. The values below are the measured tree at each pushed PR head; H is filled after its final commit.

| PR | Tracked files before → after | Blob bytes before → after |
|---:|---:|---:|
| #2 | 532 → 532 | 5,269,899 → 5,272,710 |
| #3 | 532 → 532 | 5,269,899 → 5,275,501 |
| #4 | 532 → 536 | 5,269,899 → 5,284,972 |
| #5 | 532 → 536 | 5,269,899 → 5,285,126 |
| #6 | 532 → 534 | 5,269,899 → 5,285,755 |
| #7 | 532 → 531 | 5,269,899 → 5,274,171 |
| #8 | 532 → 533 | 5,269,899 → 5,277,659 |
| #9 | 532 → 536 | 5,269,899 → 5,293,774 |

- `.git` occupied 4.1 MiB at the binary-audit measurement; `git count-objects -vH` reported 552 KiB loose objects and a 3.18 MiB pack.
- The PR #1 cleanup report measured `zsh -i -c exit` at a 91.6 ms median after cleanup (20 runs; empty stderr). No comparable installed-machine measurement was available in this follow-up.
- Existing Git history was not rewritten. Working-tree savings do not remove old objects from history.

## Remaining unverified items

- Full clean package-consuming install and post-install on a fresh machine: Docker daemon unavailable locally; manual/weekly harness workflow not run in this environment.
- Actual graphical smoke test, visual theme/profile/font/cursor comparison, and user-systemd timer firing: no graphical session or usable Docker daemon.
- Live doctor against Owen's machine: **NOT RUN**. The available `$HOME` lacked `~/.dotfiles`, so it was not a valid installed bare-repo HOME; no conclusion about the owner's live system is implied.
- Animation reduced-set menu test, Quickshell visual behavior, and monitor application on actual hardware remain owner/harness checks.
- Trufflehog second opinion and a package installation test of the current Helium GitHub AppImage helper were not run.
