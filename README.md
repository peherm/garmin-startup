# Sail StartUp (Garmin Connect IQ)

[![Build and Verify](https://github.com/peherm/garmin-startup/actions/workflows/build.yml/badge.svg)](https://github.com/peherm/garmin-startup/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/peherm/garmin-startup?sort=semver)](https://github.com/peherm/garmin-startup/releases/latest)

A tactical sailing app for the Garmin Forerunner 255 to help sailors master regatta starts. 
Getting a good start—crossing the line at maximum speed exactly when the gun goes off—is the hardest and most critical part of a race. This app aims to provide the critical data needed to achieve the perfect start.

## Features

* **Race Timer:** A configurable countdown timer synced to the race committee's signals.
* **Starting Line Pinging:** Save the exact GPS coordinates of both ends of the starting line (Committee Boat and Pin End).
* **Wind & Favored End Calculation:** Input wind direction manually or calculate it automatically by sailing on port and starboard tacks. The app will determine which end of the line is favored.
* **Distance to Line:** Real-time distance from the boat to the starting line (using cross-track error/perpendicular distance).
* **Time to Burn (Early/Late Indicator):** Real-time estimates combining current speed, distance to line, and the countdown timer to tell the sailor if they are early (need to burn time) or late.
* **Activity Recording:** Saves the entire session, including a GPS track and key sailing metrics, as a standard `.fit` file that can be uploaded to Garmin Connect for post-race analysis.

## Development

This application is built using the Garmin Connect IQ SDK (Monkey C) targeting API Level 5.2.0. 
Target Device: Garmin Forerunner 255 / 255 Music.

## Documentation Links

* [PLAN.md](PLAN.md) - Project execution phases and roadmap.
* [ARCHITECTURE.md](ARCHITECTURE.md) - System design and data models.
* [RUNBOOK.md](RUNBOOK.md) - How to build, test, and deploy the application.

## License

Private / Personal Use