# System Memory & Context Transfer

**Hello, future agent (Copilot / Claude / Gemini / etc.).**
If you are picking up development of the `SailStartup` Garmin Connect IQ app,
read these in order: `README.md`, `ARCHITECTURE.md`, `PLAN.md`, `RUNBOOK.md`,
`CHANGELOG.md`. Then skim recent commits with `git log --oneline -20`.

## Workflow Habits
- **Documentation-first commits.** When code changes, update the relevant
  `.md` files (and add a `CHANGELOG.md` entry under `[Unreleased]`) in the
  *same* commit.
- **Atomic commits.** One logical change per commit.
- **Conventional Commits.** `feat:`, `fix:`, `chore:`, `ci:`, `docs:`,
  `refactor:`, `test:`, `perf:` (with optional scope).
- **Keep CI green.** Every push to `main` runs the build job; tag pushes
  (`v*`) additionally publish a GitHub Release with the `.prg` attached.

## Current State (as of v0.1.2 — April 2026)
- **Phases 1–5 complete.** App features a 5-page carousel UI: Timer, Line,
  Race Dashboard, Manual Wind, Auto Wind (Tacks).
- Tactical features: distance to line, favored end (with bias degrees),
  time-to-burn (early/late) alert.
- Auto wind calculation uses recorded tack periods + vector averaging.
- Splash screen displays the current version (read from
  `SailStartupApp.VERSION`).
- App is named **"Sail StartUp"**.
- **Phase 7 (CI/CD) complete.** Builds via
  `blackshadev/garmin-connectiq-build-action@9.1.0` in a Dockerized SDK.
  Tagged releases auto-publish the `.prg` via `softprops/action-gh-release@v2`.
- **Phase 8 (Repo hygiene) complete.** `.gitignore` rewritten for Connect IQ;
  `bin/` untracked; least-privilege workflow `permissions`; Dependabot for
  GitHub Actions; README badges; cross-platform version-sync scripts
  (`scripts/update_version.sh` + `.ps1`); CHANGELOG, LICENSE, CONTRIBUTING,
  issue/PR templates added.

## Repo Conventions / Gotchas
- **Versioning.** Always bump `SailStartup/manifest.xml` (the
  `<iq:application … version="…">` attribute) **and**
  `SailStartup/source/SailStartupApp.mc` (`VERSION`) together. Use
  `scripts/update_version.{sh,ps1} <X.Y.Z>` to do both atomically. The bash
  sed *must* be scoped to the `iq:application` tag — a global `version="…"`
  pattern will corrupt the XML declaration.
- **Release flow.** Bump → commit `chore(release): vX.Y.Z` → tag `vX.Y.Z` →
  `git push && git push --tags`. Tag push triggers the release job.
- **Dockerized build action.** `developerKey` input must be a **relative**
  path (e.g. `developer_key`); host-absolute paths from
  `${{ github.workspace }}` don't resolve inside the container.
- **Secret.** `DEVELOPER_KEY_BASE64` (base64 of the `.der` developer key) is
  decoded in the workflow to `./developer_key` at runtime.
- **CHANGELOG.** Add entries under `[Unreleased]` as you go; promote to a new
  version section when cutting a tag.

## Immediate Next Steps (Phase 6: Polish & Recording)
1. **Activity Recording.** Use `Toybox.ActivityRecording` to start/stop a
   session so the race start and the rest of the sail are saved as a Garmin
   Activity (FIT file).
2. **On-water testing.** Continue validating UI and math during real sailing.
3. **Data Persistence (optional).** Consider persisting the marked Line and
   Wind direction across accidental app restarts.
