# Architecture & System Design

## Core Connect IQ Structure
The app will be built around the standard Connect IQ MVC-like pattern.

* `SailStartupApp`: The entry point. Manages app lifecycle, loads saved properties (like preferred timer duration), and injects the state into views.
* `SailStartupView`: The main display. Will likely be heavily custom-drawn using `dc` (Device Context) rather than standard layouts to maximize space for large text (Timer, Distance).
* `SailStartupDelegate`: Handles physical button presses. The Forerunner 255 relies purely on 5 hardware buttons (Up, Down, Start, Back, Light).

## Data Models & State Management
A `RaceState` class will be created to hold all reactive data. This prevents passing dozens of variables between the App, View, and Delegate.

```monkeyc
class RaceState {
    var countdownTimerRunning as Boolean;
    var timeToGunSeconds as Number;
    
    var pinEndLocation as Position.Location;
    var boatEndLocation as Position.Location;
    
    var windDirectionDegrees as Number; // 0-359
    var currentSpeedKnots as Float;
    var currentHeading as Float;
}
```

## Key Modules Used
* `Toybox.Position`: For grabbing real-time GPS coordinates, speed over ground, and heading.
* `Toybox.Math`: Essential for sailing calculations. We will use Haversine formulas for distance and standard trigonometry to calculate Cross-Track Error (distance to the line) and favored ends.
* `Toybox.Timer`: To trigger screen updates (e.g., 1 Hz refresh rate) and drive the countdown clock.
* `Toybox.System`: For device settings and time.
* `Toybox.ActivityRecording`: To create a session, record GPS track and other data, and save it as a `.fit` file.

## Mathematical Concepts Required
1. **Distance to Line:** Calculated as the shortest (perpendicular) distance from a point (the watch) to a line segment (the start line defined by two GPS coordinates).
2. **Favored End:** Determined by comparing the bearing of the starting line to the wind direction. Whichever end is further upwind is favored.
3. **Wind via Tacking:** Calculated by taking the median heading on Port, the median heading on Starboard, and finding the bisecting angle.

## User Interface (Button Mapping)
The UI is a "Carousel" of 5 pages that the user navigates with the Up/Down buttons. The Start/Stop and Back buttons are contextual to the active page.

* **Up/Down Buttons:** Scroll between pages.
* **Page 1: TIMER**
  * `Start/Stop`: Start/Pause countdown.
  * `Back`: Sync timer to nearest minute, or reset if stopped.
  * `Hold Up`: Cycle default timer length (5/4/3/2/1 min).
* **Page 2: LINE**
  * `Start/Stop`: Ping Committee Boat location.
  * `Back`: Ping Pin End location.
* **Page 3: RACE**
  * The main "dashboard" view showing Timer, Distance to Line, and Time to Burn.
  * `Start/Stop`: Start/Pause countdown.
  * `Back`: Sync timer.
* **Page 4: MANUAL WIND**
  * `Start/Stop`: Increase manual wind angle.
  * `Back`: Decrease manual wind angle.
  * `Hold Up`: Cycle adjustment increment (1/5/10 deg).
* **Page 5: AUTO WIND (TACKS)**
  * `Start/Stop`: Start/Stop recording Starboard tack heading.
  * `Back`: Start/Stop recording Port tack heading.