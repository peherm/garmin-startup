# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Commits follow the [Conventional Commits](https://www.conventionalcommits.org/) style.

## [Unreleased]

## [0.1.4] - 2026-05-02

### Changed
- **Signed distance to line.** `getDistanceToLineMeters` now returns a signed
  perpendicular distance using the pin-on-left / boat-on-right convention:
  positive = below the line (pre-start side), negative = above (over the
  line). Wind data is not required. Both pin->boat and pin->you vectors now
  share a single reference latitude for consistency.
- **Line page** shows a colored `BELOW` / `ABOVE` tag under the distance.
  **Race page** distance is prefixed with an up-arrow when above the line.
- **Heading-aware time-to-burn.** `getTimeToBurnSeconds` now uses GPS heading
  + speed to compute the perpendicular closure rate to the line, instead of
  the previous scalar `distance / speed`. Returns `null` when sailing
  parallel to or away from the line, when the predicted crossing point falls
  outside the pin<->boat segment, or when already on/above the line.

## [0.1.3] - 2026-04-28

### Added
- **Activity Recording.** When the countdown timer is started, the app now
  opens a `Toybox.ActivityRecording` session (sport: `SAILING`) that captures
  GPS track, speed, and heading. The session is auto-saved as a FIT activity
  when the app is exited and shows up in the watch's activity history /
  Garmin Connect for post-race analysis.
- Blinking **REC** indicator on the Race page while a session is recording.
- New `SailRecorder` helper class wrapping the `ActivityRecording` lifecycle.

### Changed
- Bumped version to `0.1.3` in `manifest.xml` and `SailStartupApp.VERSION`.

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

[Unreleased]: https://github.com/peherm/garmin-startup/compare/v0.1.4...HEAD
[0.1.4]: https://github.com/peherm/garmin-startup/releases/tag/v0.1.4
[0.1.3]: https://github.com/peherm/garmin-startup/releases/tag/v0.1.3
[0.1.2]: https://github.com/peherm/garmin-startup/releases/tag/v0.1.2
[0.1.0]: https://github.com/peherm/garmin-startup/commits/main
