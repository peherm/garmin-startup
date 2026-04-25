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