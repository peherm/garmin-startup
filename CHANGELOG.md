# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Commits follow the [Conventional Commits](https://www.conventionalcommits.org/) style.

## [Unreleased]

### Added
- `CHANGELOG.md` (this file).
- `LICENSE` declaring "All Rights Reserved / Personal Use".
- `.github/ISSUE_TEMPLATE/` (bug report + feature request) and `pull_request_template.md`.
- `CONTRIBUTING.md` with the documentation-first / Conventional Commits workflow.

### Changed
- `MEMORY.md` refreshed to reflect the current state (post Phase 8 hygiene work).

## [0.1.2] - 2026-04-28

### Added
- `.github/dependabot.yml` for weekly `github-actions` dependency updates.
- `scripts/update_version.ps1` — PowerShell sibling of `update_version.sh` for Windows.
- README badges for build status and the latest GitHub Release.
- GitHub Release job in `build.yml` that publishes `SailStartup.prg` on every `v*` tag.

### Changed
- `.gitignore` rewritten with Connect IQ-specific rules (`bin/`, `out/`, `*.prg`,
  `*.mir`, `*.mcgen`, `*.mbc`, `*.der`, `developer_key*`, etc.).
- `build.yml` declares an explicit least-privilege `permissions:` block (top-level
  `contents: read`; release job overrides with `contents: write`).
- Local `manifest.xml` and `SailStartupApp.mc` versions synced to `0.1.2` so
  sideloaded builds display the correct splash version.
- `RUNBOOK.md` documents the release procedure with both bash and PowerShell flows.

### Fixed
- `scripts/update_version.sh` regex no longer matches the XML declaration's
  `version="1.0"`; sed is scoped to `<iq:application … version="…">`.
- CI build action call corrected: pinned to
  `blackshadev/garmin-connectiq-build-action@9.1.0` with the action's actual
  inputs (`projectJungle`, `developerKey`, `device`, `typeCheck`, `outputPath`).
- Developer key path passed to the build action is now relative
  (`developer_key`) so it resolves inside the action's Docker container.

### Removed
- 12 generated artifacts under `SailStartup/bin/` were untracked from the index
  (still produced locally, now ignored).

## [0.1.0] - Initial CI/CD-capable release

### Added
- Full race-start logic with 5-page carousel UI: Timer, Line, Race Dashboard,
  Manual Wind, Auto Wind (Tacks).
- Tactical features: distance to line, favored end (with bias degrees), and
  time-to-burn (early/late) alerts.
- Auto wind calculation from recorded port/starboard tack vectors.
- Splash screen with version display.
- Initial GitHub Actions CI pipeline building the `.prg` for Forerunner 255.

[Unreleased]: https://github.com/peherm/garmin-startup/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/peherm/garmin-startup/releases/tag/v0.1.2
[0.1.0]: https://github.com/peherm/garmin-startup/commits/main
