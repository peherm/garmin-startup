# System Memory & Context Transfer

**Hello Gemini CLI!** 
If you are reading this, you are taking over development of the `SailStartup` Garmin Connect IQ application. 
Please read `README.md`, `ARCHITECTURE.md`, and `PLAN.md` to understand the project goals and design constraints.

## Current State (As of Last Session)
* **Phase 1 is complete.** The project compiles successfully. 
* Extraneous default resources (`layout.xml` and `menu.xml`) have been removed.
* We have a custom view (`SailStartupView.mc`) that clears the screen and manually draws "5:00" in the center.
* We have a state class (`RaceState.mc`) instantiated in the main app file and passed to the view and delegate.
* Permissions for `Positioning`, `Sensor`, and `FitContributor` are correctly configured in `manifest.xml`.

## Immediate Next Steps (Phase 2: The Race Timer)
We need to make the timer actually count down and be controllable by the user.

1. **Update `SailStartupDelegate.mc`**: 
   * Implement the `onSelect()` method to intercept the Start/Stop physical button press.
   * This method should toggle the `_raceState.countdownTimerRunning` boolean.
2. **Update `SailStartupView.mc`**:
   * Inside the `onTimer()` callback (which fires every 1 second), check if `_raceState.countdownTimerRunning` is true.
   * If it is true, decrement `_raceState.timeToGunSeconds`.
   * Ensure the timer stops at 0.
   * The existing `WatchUi.requestUpdate()` will handle redrawing the screen.