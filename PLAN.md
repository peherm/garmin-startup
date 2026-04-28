# Project Execution Plan: SailStartup

This document outlines the step-by-step phases to build the SailStartup application. We will follow an iterative approach, ensuring each piece works before moving to the next.

## Phase 1: Foundation & UI Basics
* [x] Configure manifest permissions (add `Positioning`, `Sensor`, and `FitContributor` if saving activities).
* [x] Setup basic UI layout for a 260x260 round display (Forerunner 255).
* [x] Implement basic state management (app state singleton or class) to hold timer, wind, and GPS data.

## Phase 2: The Race Timer
* [x] Implement the "Sync" feature (if the sailor misses the 5-minute gun but hits a button at 4 minutes, the timer rounds to the nearest minute).
* [x] Map physical hardware buttons (Start/Stop, Back, Up, Down) using `InputDelegates`.

## Phase 3: GPS & The Starting Line
* [x] Request GPS coordinates using `Toybox.Position`.
* [x] Create an intuitive UI to "Ping" the Committee Boat and Pin End (e.g., using a Menu or long-pressing buttons).
* [x] Implement the mathematical formula to draw a line between two GPS coordinates.
* [x] Calculate and display the perpendicular distance from the current GPS location to the starting line.

## Phase 4: Wind & Favored End Calculation
* [x] Implement manual wind direction input via an on-screen menu.
* [x] Implement automatic wind direction calculation:
  * Track heading while sailing on starboard tack.
  * Track heading while sailing on port tack.
  * Average the two to determine true wind direction.
* [x] Use the wind direction and the angle of the starting line to calculate and display the "Favored End" (Boat or Pin).

## Phase 5: Time-to-Burn & Advanced Analytics
* [x] Combine current GPS speed (SOG - Speed Over Ground), distance to line, and countdown timer.
* [x] Calculate "Time to Line" at current speed.
* [x] Compare "Time to Line" with "Time to Gun" to display a +/- (early/late) indicator.
* [x] Implement UI feedback (e.g., red text for early, green for perfect/late).

## Phase 6: Polish & On-Water Testing
* [ ] Implement activity recording (`Toybox.ActivityRecording`) so the race start is saved as a Garmin Activity.
* [ ] Field testing (Simulator with simulated GPS paths, then real-world on-water testing).
* [x] Tactical UI improvements based on real-world testing (Tack Angle prominence, higher visibility fonts).
* [x] Bug fix: Resolved crash when calculating Tack Angle (removed incompatible .abs() method).
* [x] Improvement: Added immediate UI refresh on all physical button inputs for better responsiveness.

## Phase 7: CI/CD & Professional DevOps
* [x] Setup GitHub Actions workflow for automated "Headless" builds.
* [x] Configure GitHub Secrets for secure storage of the `developer_key.der` (Base64 encoded).
* [x] Implement a version-sync script to automatically update `manifest.xml` and `SailStartupApp.mc` from Git Tags.
* [x] Fix CI pipeline to use correct `blackshadev/garmin-connectiq-build-action` inputs and tag (`9.1.0`).
* [x] Decode `DEVELOPER_KEY_BASE64` secret into a key file at runtime, using a relative path so it resolves inside the action's Docker container.
* [x] Upload the built `SailStartup.prg` as a workflow artifact.
* [x] Scope version-sync `sed` to only the `<iq:application>` tag so it doesn't corrupt the XML declaration.
* [ ] (Optional) Integrate Git Submodules for any external Monkey Barrels to enable Dependabot tracking.

## Phase 8: Repository Hygiene & Best Practices
Identified during a project review after the CI pipeline started working end-to-end. Ordered by priority.

### High value, low risk
* [x] **Replace `.gitignore`** with a Connect IQ / Monkey C-tailored one (currently a Java/BlueJ template). Should ignore `bin/`, `out/`, `developer_key`, `*.der`, `*.iq`, `.DS_Store`, etc.
* [x] **Stop tracking generated build artifacts** in `SailStartup/bin/` (currently 12 files: `.prg`, `.mir`, `.mcgen`, `.mbc`). `git rm -r --cached SailStartup/bin/` after the gitignore update.
* [x] **Add `permissions:` block** to `.github/workflows/build.yml` for least-privilege `GITHUB_TOKEN` (default `contents: read`, elevate per-job where needed).
* [x] **Publish GitHub Releases on `v*` tags** — add a job that runs after build, only on tag refs, and attaches the `.prg` artifact to a GitHub Release using `softprops/action-gh-release`.
* [x] **Resolve version drift** between `manifest.xml` / `SailStartupApp.mc` (both currently `0.1.0`) and the latest tag. Either commit the version bump alongside the tag, or document/run `update_version.sh` locally before tagging so local sideloaded builds show the correct splash version.

### Medium value
* [x] **Build-status badge** in `README.md`.
* [ ] **`CHANGELOG.md`** (optional; can be auto-generated from Conventional Commits).
* [x] **Dependabot config** at `.github/dependabot.yml` for the `github-actions` ecosystem so action version bumps are flagged automatically.
* [x] **Cross-platform version-sync script** — current `update_version.sh` uses GNU `sed -i`, which doesn't run on Windows without WSL/Git-Bash. Either provide a PowerShell equivalent or a small Node/Python script.

### Low priority / informational
* [ ] Node 20 deprecation warning on `actions/checkout@v4` / `actions/upload-artifact@v4` — already on the latest major; GitHub will auto-upgrade. No action needed yet.
* [ ] Add a `LICENSE` file if the project ever moves beyond personal use (README currently states *"Private / Personal Use"*).
* [ ] Refresh `MEMORY.md` (currently addressed to "Gemini CLI" — historical, but stale).
* [ ] Add issue/PR templates and `CONTRIBUTING.md` if the repo becomes public or multi-contributor.