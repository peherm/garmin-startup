# System Memory & Context Transfer

**Hello Gemini CLI!** 
If you are reading this, you are taking over development of the `SailStartup` Garmin Connect IQ application. 
Please read `README.md`, `ARCHITECTURE.md`, and `PLAN.md` to understand the project goals and design constraints.

## Workflow Habits
* **Documentation-First Commits:** After implementing any code changes, always review and update all relevant `.md` files (`README.md`, `ARCHITECTURE.md`, `PLAN.md`, `RUNBOOK.md`) before committing.
* **Atomic Commits:** Commit code and its corresponding documentation updates together in a single commit.

## Current State (As of Last Session)
* **Phases 1 through 5 are complete.** 
* The app features a 5-page carousel UI: Timer, Line, Race Dashboard, Manual Wind, and Auto Wind (Tacks).
* Tactical features include: Distance to Line, Favored End (with bias degrees), and Time-to-Burn (Early/Late alert).
* Auto Wind calculation uses recorded tack periods and vector averaging to find True Wind and Tack Angle.
* The UI has been optimized for high-visibility with large fonts for critical data.
* A splash screen with versioning (`v0.1.0`) is implemented.
* The app has been renamed to **"Sail StartUp"**.

## Immediate Next Steps (Phase 6: Polish & Recording)
1. **Implement Activity Recording:** Use `Toybox.ActivityRecording` to start/stop a session so the race start and subsequent sailing are saved as a Garmin Activity (FIT file).
2. **On-Water Testing:** Continue validating the UI and math during real sailing sessions.
3. **Data Persistence:** (Optional) Consider saving the marked Line and Wind direction so they persist if the app is accidentally closed/restarted.