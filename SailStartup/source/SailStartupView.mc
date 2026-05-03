import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;
import Toybox.Application;

class SailStartupView extends WatchUi.View {
    private var _raceState as RaceState;
    private var _updateTimer as Timer.Timer?;

    function initialize(raceState as RaceState) {
        View.initialize();
        _raceState = raceState;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // We will use custom drawing, so onLayout is not needed.
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        // Request a screen update every second.
        _updateTimer = new Timer.Timer();
        _updateTimer.start(method(:onTimer), 1000, true);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Get screen dimensions
        var width = dc.getWidth();
        var height = dc.getHeight();

        if (_raceState.currentPage == 0) {
            drawTimerPage(dc, width, height);
        } else if (_raceState.currentPage == 1) {
            drawLinePage(dc, width, height);
        } else if (_raceState.currentPage == 2) {
            drawRacePage(dc, width, height);
        } else if (_raceState.currentPage == 3) {
            drawWindPage(dc, width, height);
        } else if (_raceState.currentPage == 4) {
            drawTacksPage(dc, width, height);
        }

        // Draw page indicators
        var numPages = 5;
        var dotSpacing = 20;
        var startX = width / 2 - (dotSpacing * (numPages - 1)) / 2;
        var y = height * 0.90;
        
        for (var i = 0; i < numPages; i++) {
            dc.setColor(i == _raceState.currentPage ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(startX + (i * dotSpacing), y.toNumber(), 4);
        }
    }

    function drawTimerPage(dc as Dc, width as Number, height as Number) as Void {
        var timeToGun = _raceState.timeToGunSeconds;
        var minutes = timeToGun / 60;
        var seconds = timeToGun % 60;
        var timerString = Lang.format("$1$:$2$", [minutes, seconds.format("%02d")]);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 0.15, Graphics.FONT_MEDIUM, "TIMER", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height / 2 - (Graphics.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT) / 2), 
                    Graphics.FONT_NUMBER_THAI_HOT, 
                    timerString, Graphics.TEXT_JUSTIFY_CENTER);

        var showResetHint = !_raceState.countdownTimerRunning && _raceState.timeToGunSeconds != _raceState.defaultTimerMinutes * 60;

        if (showResetHint) {
            // Show reset hint above the page-indicator dots, in a larger font for readability.
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height * 0.74, Graphics.FONT_TINY, "Back to Reset", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            // Draw timer length and hint
            var lengthString = "Length: " + _raceState.defaultTimerMinutes + "m (Hold UP)";
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height * 0.75, Graphics.FONT_XTINY, lengthString, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawLinePage(dc as Dc, width as Number, height as Number) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 0.15, Graphics.FONT_MEDIUM, "LINE", Graphics.TEXT_JUSTIFY_CENTER);

        var dist = _raceState.getDistanceToLineMeters();
        if (dist != null) {
            var absDist = dist < 0 ? -dist : dist;
            var distString = absDist.format("%d") + " m";
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height / 2 - (Graphics.getFontHeight(Graphics.FONT_LARGE) / 2), Graphics.FONT_LARGE, distString, Graphics.TEXT_JUSTIFY_CENTER);

            // Below = pre-start side (positive). Above = over the line (negative).
            var sideLabel = dist >= 0 ? "BELOW" : "ABOVE";
            var sideColor = dist >= 0 ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
            dc.setColor(sideColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height * 0.60, Graphics.FONT_XTINY, sideLabel, Graphics.TEXT_JUSTIFY_CENTER);

            var favored = _raceState.getFavoredEnd();
            if (favored != null) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.drawText(width / 2, height * 0.70, Graphics.FONT_XTINY, "Favored: " + favored, Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height / 2 - (Graphics.getFontHeight(Graphics.FONT_MEDIUM) / 2), Graphics.FONT_MEDIUM, "Ping Ends", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Draw Boat indicator (Start/Stop button is Top Right)
        var boatY = height * 0.35;
        dc.setColor(_raceState.boatEndLocation != null ? Graphics.COLOR_GREEN : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle((width * 0.85).toNumber(), boatY.toNumber(), 8);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText((width * 0.85).toNumber() - 15, boatY.toNumber() - (Graphics.getFontHeight(Graphics.FONT_XTINY) / 2), Graphics.FONT_XTINY, "BOAT", Graphics.TEXT_JUSTIFY_RIGHT);

        // Draw Pin indicator (Back button is Bottom Right)
        var pinY = height * 0.65;
        dc.setColor(_raceState.pinEndLocation != null ? Graphics.COLOR_RED : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle((width * 0.85).toNumber(), pinY.toNumber(), 8);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText((width * 0.85).toNumber() - 15, pinY.toNumber() - (Graphics.getFontHeight(Graphics.FONT_XTINY) / 2), Graphics.FONT_XTINY, "PIN", Graphics.TEXT_JUSTIFY_RIGHT);
    }
    function drawRacePage(dc as Dc, width as Number, height as Number) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 0.15, Graphics.FONT_MEDIUM, "RACE", Graphics.TEXT_JUSTIFY_CENTER);

        // Recording indicator (top-left red dot + REC) when an activity
        // session is in progress. Blinks once per second.
        if (getApp().getRecorder().isRecording()) {
            var blinkOn = (System.getTimer() / 500) % 2 == 0;
            if (blinkOn) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle((width * 0.18).toNumber(), (height * 0.18).toNumber(), 5);
                dc.drawText((width * 0.22).toNumber(), height * 0.18 - (Graphics.getFontHeight(Graphics.FONT_XTINY) / 2), Graphics.FONT_XTINY, "REC", Graphics.TEXT_JUSTIFY_LEFT);
            }
        }

        var timeToGun = _raceState.timeToGunSeconds;
        var minutes = timeToGun / 60;
        var seconds = timeToGun % 60;
        var timerString = Lang.format("$1$:$2$", [minutes, seconds.format("%02d")]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 0.35, Graphics.FONT_NUMBER_HOT, timerString, Graphics.TEXT_JUSTIFY_CENTER);

        var dist = _raceState.getDistanceToLineMeters();
        var distString;
        if (dist != null) {
            var absDist = dist < 0 ? -dist : dist;
            var sideTag = dist >= 0 ? "" : "↑ "; // up arrow = above the line
            distString = sideTag + absDist.format("%d") + " m";
        } else {
            distString = "--";
        }
        dc.drawText(width / 2, height * 0.60, Graphics.FONT_LARGE, distString, Graphics.TEXT_JUSTIFY_CENTER);

        var timeToBurn = _raceState.getTimeToBurnSeconds();
        if (timeToBurn != null) {
            var burnString = "";
            if (timeToBurn > 0) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                burnString = "BURN: " + timeToBurn + "s";
            } else {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                burnString = "LATE: " + (-timeToBurn) + "s";
            }
            // Increased font size to FONT_MEDIUM for better visibility
            dc.drawText(width / 2, height * 0.78, Graphics.FONT_MEDIUM, burnString, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            var favored = _raceState.getFavoredEnd();
            if (favored != null) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.drawText(width / 2, height * 0.80, Graphics.FONT_XTINY, "Favored: " + favored, Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
    }

    function drawWindPage(dc as Dc, width as Number, height as Number) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 0.15, Graphics.FONT_MEDIUM, "MANUAL WIND", Graphics.TEXT_JUSTIFY_CENTER);

        var wind = _raceState.windDirectionDegrees;
        var windString = wind != null ? wind.format("%d") + "°" : "--";

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height / 2 - (Graphics.getFontHeight(Graphics.FONT_NUMBER_HOT) / 2), Graphics.FONT_NUMBER_HOT, windString, Graphics.TEXT_JUSTIFY_CENTER);

        // Draw indicators for adjusting wind
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText((width * 0.85).toNumber(), height * 0.35 - (Graphics.getFontHeight(Graphics.FONT_MEDIUM) / 2), Graphics.FONT_MEDIUM, "+", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText((width * 0.85).toNumber(), height * 0.65 - (Graphics.getFontHeight(Graphics.FONT_MEDIUM) / 2), Graphics.FONT_MEDIUM, "-", Graphics.TEXT_JUSTIFY_RIGHT);

        // Draw step indicator
        var stepString = "Step: " + _raceState.windIncrement + "° (Hold UP)";
        dc.drawText(width / 2, height * 0.75, Graphics.FONT_XTINY, stepString, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawTacksPage(dc as Dc, width as Number, height as Number) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 0.15, Graphics.FONT_MEDIUM, "AUTO WIND", Graphics.TEXT_JUSTIFY_CENTER);

        var tackAngle = _raceState.getTackAngle();
        if (tackAngle != null) {
            // Main display: Tack Angle
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height / 2 - (Graphics.getFontHeight(Graphics.FONT_LARGE) / 2), Graphics.FONT_LARGE, "Tack: " + tackAngle + "°", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Secondary: Current Heading
            var heading = _raceState.currentHeading;
            var headingString = heading != null ? heading.format("%d") + "°" : "--";
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height * 0.70, Graphics.FONT_XTINY, "Hdg: " + headingString, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            // Fallback: Current Heading if no tacks recorded yet
            var heading = _raceState.currentHeading;
            var headingString = heading != null ? heading.format("%d") + "°" : "--";
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height / 2 - (Graphics.getFontHeight(Graphics.FONT_LARGE) / 2), Graphics.FONT_LARGE, "Hdg: " + headingString, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Draw Starboard Tack (Top Right)
        var stbY = height * 0.35;
        var stbdColor = Graphics.COLOR_DK_GRAY;
        if (_raceState.isRecordingStarboard) {
            // Blink if recording (simple blink using seconds)
            if ((System.getTimer() / 500) % 2 == 0) {
                stbdColor = Graphics.COLOR_GREEN;
            }
        } else if (_raceState.starboardTackHeading != null) {
            stbdColor = Graphics.COLOR_GREEN;
        }
        dc.setColor(stbdColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle((width * 0.85).toNumber(), stbY.toNumber(), 8);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var stbdText = "STBD";
        if (_raceState.isRecordingStarboard) {
            stbdText = "REC";
        } else if (_raceState.starboardTackHeading != null) {
            stbdText = "STBD (" + _raceState.starboardTackHeading.format("%d") + "°)";
        }
        dc.drawText((width * 0.85).toNumber() - 15, stbY.toNumber() - (Graphics.getFontHeight(Graphics.FONT_XTINY) / 2), Graphics.FONT_XTINY, stbdText, Graphics.TEXT_JUSTIFY_RIGHT);

        // Draw Port Tack (Bottom Right)
        var portY = height * 0.65;
        var portColor = Graphics.COLOR_DK_GRAY;
        if (_raceState.isRecordingPort) {
            if ((System.getTimer() / 500) % 2 == 0) {
                portColor = Graphics.COLOR_RED;
            }
        } else if (_raceState.portTackHeading != null) {
            portColor = Graphics.COLOR_RED;
        }
        dc.setColor(portColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle((width * 0.85).toNumber(), portY.toNumber(), 8);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var portText = "PORT";
        if (_raceState.isRecordingPort) {
            portText = "REC";
        } else if (_raceState.portTackHeading != null) {
            portText = "PORT (" + _raceState.portTackHeading.format("%d") + "°)";
        }
        dc.drawText((width * 0.85).toNumber() - 15, portY.toNumber() - (Graphics.getFontHeight(Graphics.FONT_XTINY) / 2), Graphics.FONT_XTINY, portText, Graphics.TEXT_JUSTIFY_RIGHT);

        var wind = _raceState.windDirectionDegrees;
        if (wind != null && _raceState.portTackHeading != null && _raceState.starboardTackHeading != null) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height * 0.78, Graphics.FONT_XTINY, "Calc Wind: " + wind.format("%d") + "°", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        if (_updateTimer != null) {
            _updateTimer.stop();
            _updateTimer = null;
        }
    }

    // Simple callback to request a screen update
    public function onTimer() as Void {
        if (_raceState.countdownTimerRunning) {
            if (_raceState.timeToGunSeconds > 0) {
                _raceState.timeToGunSeconds -= 1;
            } else {
                // Stop the timer at exactly 0:00 for now.
                _raceState.countdownTimerRunning = false;
            }
        }
        WatchUi.requestUpdate();
    }

}
