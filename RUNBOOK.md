# Runbook: Build, Test, and Deploy

This document provides instructions on how to operate the development environment.

## Prerequisites
* Visual Studio Code with the **Monkey C** extension installed.
* Garmin Connect IQ SDK downloaded via the SDK Manager.
* Device targets (Forerunner 255) downloaded via the SDK Manager.

## Building and Running in Simulator
1. Open the project in VS Code.
2. Open the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`).
3. Select **Monkey C: Build and Run**.
4. Select the **fr255** as the target device.
5. The Connect IQ Simulator will launch and boot the app.

## Simulating GPS and Movement
Since this is a sailing app, testing GPS logic is critical. You cannot test this easily by just walking outside.
1. In the Connect IQ Simulator, go to **Simulation > FIT Data > Simulate Data**. This provides a fake moving GPS coordinate.
2. For more precise testing (e.g., simulating crossing a starting line), you can record a real activity (walking across a field) or create a custom `.fit` file and play it back in the simulator via **Simulation > FIT Data > Playback File...**.

## Sideloading to Physical Device
To test the app on the actual Forerunner 255:
1. Connect the Garmin watch to your computer via USB.
2. Open the Command Palette in VS Code.
3. Select **Monkey C: Build for Device**.
4. Select **fr255**.
5. The compiler will generate a `.prg` file in your `bin/` folder (e.g., `bin/SailStartup.prg`).
6. Copy the `.prg` file and paste it into the `GARMIN/APPS/` folder on your watch's mounted USB drive.
7. Disconnect the watch. The app will now be available in your activity list!

## Versioning
When releasing a new version of the app, ensure the version number is updated in **two** places to keep them in sync:

1.  **`SailStartup/manifest.xml`**: Update the `version` attribute in the `<iq:application>` tag. This is used by the Garmin ecosystem.
2.  **`SailStartup/source/SailStartupApp.mc`**: Update the `VERSION` constant. This is used to display the version number on the splash screen.

Example:
```xml
<!-- manifest.xml -->
<iq:application ... version="0.2.0">
```
```monkeyc
// SailStartupApp.mc
public static const VERSION = "0.2.0";
```