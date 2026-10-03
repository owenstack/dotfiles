# Follow-up report after PR #1

## Owner actions required

1. **Secrets:** no credential findings were detected by the full-history gitleaks scan, so no rotation or history rewrite is indicated by this audit. Trufflehog's second opinion was not run. Do not rewrite history based on this report; if a later confirmed credential requires it, rotate first and decide on a separately reviewed rewrite plan.
2. **Fresh install and hardware:** follow the checklist in [PR #5](https://github.com/owenstack/dotfiles/pull/5) on a VM or spare machine. Confirm the display manager and first login, wallpaper timer, theme switch, notification, lock screen, monitor mode/scale, cursor, font, `simple_sddm_2` theme path, and Helium launch. The container harness could not complete because Arch package mirrors timed out.
3. **GDK scale:** run the five-minute A/B procedure in [`SCALE-TEST.md`](SCALE-TEST.md). The tracked default remains `GDK_SCALE=2`; the untracked `~/.config/hypr/env.local` lets you compare `1` and `2` without changing that default.
4. **Licensing:** review [`LICENSE-AUDIT.md`](LICENSE-AUDIT.md) and [`LICENSE-PROPOSAL.md`](LICENSE-PROPOSAL.md). Choose a scope for Owen-authored files and resolve the attribution/license status for `snes19xx`-attributed and unclear mixed QuickShell/assets before committing any repository-wide `LICENSE`. No `LICENSE` file was added.
5. **Font and profile images:** decide whether to keep the OFL Computer Modern Typewriter files and whether to supply personal profile images. The images remain optional and are not fetched or committed.
6. **Draft prune PR:** review and approve or reject the veto list on [PR #7](https://github.com/owenstack/dotfiles/pull/7). The train skipped it because neither the approval label nor the exact owner approval comment was present.
7. **Remaining package decisions:** decide whether Saturnian cursors stay manually installed or get replaced. Validate on a fresh install that `simple-sddm-theme-2-git` installs to `simple_sddm_2`; package metadata is confirmed in [PR #4](https://github.com/owenstack/dotfiles/pull/4), but installation/path verification is not.
8. **GitHub security and branch protection:** run these yourself if desired; no repository settings were changed.

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
| Full-history secret scan | **PASSED** | Independent gitleaks v8.30.1 scanned all fetched refs: 48 commits/about 3.60 MB, 0 findings; rehearsal history and tree scans also passed. Current-head gitleaks CI passed. See [PR #2](https://github.com/owenstack/dotfiles/pull/2). Trufflehog was **NOT RUN** because its binary was unavailable. |
| Package names | **PASSED**; package install, post-install, and timer | **NOT RUN** | Manifest package names passed CachyOS `pacman -Si` and AUR RPC validation; Arch package-validation CI passed. Added `thunar`, and the official Helium release helper selects the GitHub AppImage and validates GitHub's SHA-256 digest metadata. Actual package installation, Helium download/install, SDDM theme directory, desktop post-install and timer firing are **NOT RUN** locally. See [PR #4](https://github.com/owenstack/dotfiles/pull/4). |
| Hooks work on a fresh machine | **PASSED** | Workstream B's throwaway bare-repo status/add/commit integration test passed in CI with no hook bypass; hooks fail closed with actionable gitleaks install guidance. See [PR #3](https://github.com/owenstack/dotfiles/pull/3). |
| `monitors.lua` applies on the real machine | **NOT RUN** | Hyprland accepts the repository config (`hyprland --verify-config` returned `config ok`), but this environment did not have the owner's installed bare repo or a graphical owner session. Hardware mode/scale must be checked with the checklist in [PR #5](https://github.com/owenstack/dotfiles/pull/5). |
| Dynamic presets, legacy trees and inherited helpers | **PASSED** for reference audit; preset pruning verification | **NOT RUN** | Selector reachability and helper decisions are documented in [PR #7](https://github.com/owenstack/dotfiles/pull/7). Removed only the unreferenced upstream updater that could overwrite the managed home. No animation/shader preset was removed because the reduced-set graphical test was **NOT RUN**; legacy configs remain because helpers read/edit them. |
| Large tracked binary payload | **PASSED: audited** | [PR #8](https://github.com/owenstack/dotfiles/pull/8) lists the 30 largest blobs, extension/directory totals, classifications and size options. No asset was removed; personal/uncertain art needs owner approval, and historical object bytes remain unchanged. |
| Owner review items | **NOT RUN: owner decisions pending** | GDK A/B and license scope are in this PR; Typewriter font and profile-image decisions are in [`LICENSE-AUDIT.md`](LICENSE-AUDIT.md). Saturnian cursor and SDDM path decisions are in [PR #4](https://github.com/owenstack/dotfiles/pull/4). Fantasque Sans Mono Nerd Font is verified as `ttf-fantasque-nerd`; Saturnian cursor package was not found. |

## Pull requests

Actual train order: #2, #3, #4, #6, #5, #8, skip #7, then #9. #2, #3, #4, #6, #5, and #8 are merged. PR #7 remains a draft and is pending owner approval of its veto list; it was skipped under the gate. PR #9 is being rebased and verified now. No branch other than a PR head was force-pushed, and `main` was updated only by the approved squash merges.

| PR | Workstream | Rebased files | Result | Checks and review |
|---:|---|---:|---|---|
| [#2](https://github.com/owenstack/dotfiles/pull/2) | A: history secret scan | 4 | **MERGED** `751eb8f` | Current-head CI passed, including full-history gitleaks; CodeRabbit’s actionable workflow findings were already fixed in the head. |
| [#3](https://github.com/owenstack/dotfiles/pull/3) | B: hooks/bootstrap | 10 | **MERGED** `d464b2d` | Current-head CI and no-bypass hook integration passed; CodeRabbit was rate-limited. |
| [#4](https://github.com/owenstack/dotfiles/pull/4) | C: package validation and Helium helper | 20 | **MERGED** `c561b65` | Current-head static, package-validation, and bootstrap integration checks passed; latest available CodeRabbit review had no actionable findings. |
| [#6](https://github.com/owenstack/dotfiles/pull/6) | E: read-only doctor | 5 | **MERGED** `ede9baa` | Current-head static and bootstrap integration checks passed; CodeRabbit was rate-limited. |
| [#5](https://github.com/owenstack/dotfiles/pull/5) | D: fresh-install harness | 7 | **MERGED** `60eea78` | Current-head static and bootstrap integration checks passed. CodeRabbit findings were fixed in `8fe2581` and `85b2819`, then its final status passed. |
| [#8](https://github.com/owenstack/dotfiles/pull/8) | G: binary audit | 3 | **MERGED** `4b6507f` | Current-head static and integration checks passed; CodeRabbit was rate-limited. |
| [#7](https://github.com/owenstack/dotfiles/pull/7) | F: prune presets | 5 | **SKIPPED** | Draft remains open; no `veto-list-approved` label or exact owner approval comment was present. |
| [#9](https://github.com/owenstack/dotfiles/pull/9) | H: decision prep and consolidated report | 9 | **OPEN; rebase and report refresh complete** | Rebased onto post-#8 main. Check the current PR status before merge; CodeRabbit was rate-limited on the latest review attempt. |

## Tree measurements

Measured with `git ls-tree -r -l` on pre-H `origin/main` at `4b6507f2ed8d597c6507b2bd021af68d2f0d59a5`, after #2, #3, #4, #6, #5, and #8 merged and with #7 skipped. This is the measurement that will be recorded in this report branch before H merges.

| Measurement | Pre-H main value |
|---|---:|
| Tracked files | 543 |
| Blob bytes | 5,332,147 |
| `git count-objects -vH` object size in this scratch clone | 10.16 MiB (1,781 loose objects; no pack) |
| `zsh -i -c exit` mean | 39.922 ms over 20 runs; empty stderr; all exit codes 0 |

The zsh timing used the tracked main `.zshrc`, a throwaway `HOME`, and temporary XDG cache/state/config directories. The repository is a scratch clone holding all train refs, so its object-store size is not a measurement of an owner workstation’s clone. Final post-H main measurements will be posted after H merges. Existing Git history was not rewritten; the working tree’s blob size excludes old unreachable savings.

## Remaining unverified items

- Full clean package-consuming install and post-install on a fresh machine: the harness was attempted, but Arch package mirror requests timed out during prerequisite setup; the manual/weekly workflow was not run.
- Actual graphical smoke test, visual theme/profile/font/cursor comparison, and user-systemd timer firing: no graphical session or successful full-install harness.
- Live doctor against Owen's machine: **NOT RUN**. The available `$HOME` lacked `~/.dotfiles`, so it was not a valid installed bare-repo HOME; no conclusion about the owner's live system is implied.
- Animation reduced-set menu test, Quickshell visual behavior, and monitor application on actual hardware remain owner/harness checks.
- Trufflehog second opinion and a package installation test of the current Helium GitHub AppImage helper were not run.
