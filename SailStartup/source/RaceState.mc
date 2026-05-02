import Toybox.Position;
import Toybox.Lang;
import Toybox.Math;

class RaceState {
    public var countdownTimerRunning as Boolean;
    public var timeToGunSeconds as Number;
    
    public var currentPosition as Position.Location?;
    public var pinEndLocation as Position.Location?;
    public var boatEndLocation as Position.Location?;
    
    public var windDirectionDegrees as Number?; 
    public var currentSpeedKnots as Float?;
    public var currentHeading as Float?;
    public var currentPage as Number;
    public var windIncrement as Number;
    public var defaultTimerMinutes as Number;
    
    public var portTackHeading as Float?;
    public var starboardTackHeading as Float?;
    
    public var isRecordingPort as Boolean;
    public var isRecordingStarboard as Boolean;
    
    private var _portSumX as Float;
    private var _portSumY as Float;
    private var _stbdSumX as Float;
    private var _stbdSumY as Float;

    function initialize() {
        countdownTimerRunning = false;
        defaultTimerMinutes = 5;
        timeToGunSeconds = defaultTimerMinutes * 60; // Default to 5 minutes
        currentPage = 0;
        windIncrement = 5;

        currentPosition = null;
        pinEndLocation = null;
        boatEndLocation = null;
        windDirectionDegrees = null;
        currentSpeedKnots = null;
        currentHeading = null;
        portTackHeading = null;
        starboardTackHeading = null;
        
        isRecordingPort = false;
        isRecordingStarboard = false;
        _portSumX = 0.0;
        _portSumY = 0.0;
        _stbdSumX = 0.0;
        _stbdSumY = 0.0;
    }

    public function setCurrentHeading(headingDeg as Float) as Void {
        currentHeading = headingDeg;
        var rad = headingDeg * Math.PI / 180.0;
        var sinH = Math.sin(rad);
        var cosH = Math.cos(rad);

        if (isRecordingStarboard) {
            _stbdSumX += sinH;
            _stbdSumY += cosH;
        }
        if (isRecordingPort) {
            _portSumX += sinH;
            _portSumY += cosH;
        }
    }

    public function toggleStarboardRecording() as Void {
        if (!isRecordingStarboard) {
            isRecordingStarboard = true;
            _stbdSumX = 0.0;
            _stbdSumY = 0.0;
            starboardTackHeading = null;
        } else {
            isRecordingStarboard = false;
            if (_stbdSumX != 0.0 || _stbdSumY != 0.0) {
                var rad = Math.atan2(_stbdSumX, _stbdSumY);
                var deg = rad * 180.0 / Math.PI;
                if (deg < 0) { deg += 360.0; }
                starboardTackHeading = deg;
            }
            updateWindFromTacks();
        }
    }

    public function togglePortRecording() as Void {
        if (!isRecordingPort) {
            isRecordingPort = true;
            _portSumX = 0.0;
            _portSumY = 0.0;
            portTackHeading = null;
        } else {
            isRecordingPort = false;
            if (_portSumX != 0.0 || _portSumY != 0.0) {
                var rad = Math.atan2(_portSumX, _portSumY);
                var deg = rad * 180.0 / Math.PI;
                if (deg < 0) { deg += 360.0; }
                portTackHeading = deg;
            }
            updateWindFromTacks();
        }
    }

    public function updateWindFromTacks() as Void {
        if (portTackHeading != null && starboardTackHeading != null) {
            var pRad = portTackHeading * Math.PI / 180.0;
            var sRad = starboardTackHeading * Math.PI / 180.0;

            var sinSum = Math.sin(pRad) + Math.sin(sRad);
            var cosSum = Math.cos(pRad) + Math.cos(sRad);

            // Using atan2(x, y) where x is sinSum (East) and y is cosSum (North) 
            // gives the compass angle directly.
            var windRad = Math.atan2(sinSum, cosSum);
            var windDeg = windRad * 180.0 / Math.PI;

            if (windDeg < 0) {
                windDeg += 360.0;
            }
            windDirectionDegrees = windDeg.toNumber();
        }
    }

    public function getTackAngle() as Number? {
        if (portTackHeading == null || starboardTackHeading == null) {
            return null;
        }
        var diff = portTackHeading - starboardTackHeading;
        if (diff < 0) {
            diff = -diff;
        }
        if (diff > 180) {
            diff = 360 - diff;
        }
        return diff.toNumber();
    }

    // Signed perpendicular distance from current position to the infinite
    // line through pin and boat ends. Convention (pin = left, boat = right
    // when approaching the line):
    //   positive  -> below the line (pre-start side, where you start from)
    //   negative  -> above the line (over early / past the line)
    // Distance extends past either end of the line (no segment clamping).
    public function getDistanceToLineMeters() as Float? {
        if (pinEndLocation == null || boatEndLocation == null || currentPosition == null) {
            return null;
        }

        var p = pinEndLocation.toRadians();
        var b = boatEndLocation.toRadians();
        var c = currentPosition.toRadians();

        var pLat = p[0]; var pLon = p[1];
        var bLat = b[0]; var bLon = b[1];
        var cLat = c[0]; var cLon = c[1];

        var R = 6371000.0; // Earth radius in meters

        // Use a single reference latitude (pin) so both vectors share the
        // same local equirectangular frame.
        var refCos = Math.cos(pLat);
        var xB = (bLon - pLon) * refCos * R;
        var yB = (bLat - pLat) * R;
        var xC = (cLon - pLon) * refCos * R;
        var yC = (cLat - pLat) * R;

        var lenA = Math.sqrt(xB * xB + yB * yB);

        if (lenA == 0.0) {
            // Degenerate line: fall back to unsigned distance from pin.
            return Math.sqrt(xC * xC + yC * yC).toFloat();
        }

        // Signed 2D cross product of (pin->boat) x (pin->you), divided by
        // |pin->boat|. With pin on the left and boat on the right, the
        // pre-start side yields a positive value.
        var signedPerp = (xC * yB - yC * xB) / lenA;
        return signedPerp.toFloat();
    }

    public function getFavoredEnd() as String? {
        if (pinEndLocation == null || boatEndLocation == null || windDirectionDegrees == null) {
            return null;
        }

        var p = pinEndLocation.toRadians();
        var b = boatEndLocation.toRadians();
        
        var pLat = p[0]; var pLon = p[1];
        var bLat = b[0]; var bLon = b[1];
        
        var R = 6371000.0;
        var avgLat = (bLat + pLat) / 2.0;
        
        // Vector from Pin to Boat
        var dx = (bLon - pLon) * Math.cos(avgLat) * R;
        var dy = (bLat - pLat) * R;
        var lineLen = Math.sqrt(dx * dx + dy * dy);
        
        if (lineLen == 0.0) {
            return "SQUARE";
        }
        
        var nx = dx / lineLen;
        var ny = dy / lineLen;
        
        // Vector pointing into the wind
        // 0 deg = North (+y), 90 deg = East (+x)
        var windRad = windDirectionDegrees * Math.PI / 180.0;
        var wx = Math.sin(windRad);
        var wy = Math.cos(windRad);
        
        var dot = nx * wx + ny * wy;
        
        if (dot > 1.0) { dot = 1.0; }
        if (dot < -1.0) { dot = -1.0; }
        
        var biasRad = Math.asin(dot);
        var biasDeg = (biasRad * 180.0 / Math.PI).toNumber();
        
        if (biasDeg > 2) { 
            return "BOAT " + biasDeg + "°";
        } else if (biasDeg < -2) {
            return "PIN " + (-biasDeg) + "°";
        } else {
            return "SQUARE";
        }
    }

    // Heading-aware time-to-burn. Returns the difference (in seconds) between
    // the countdown remaining and the time it will take to reach the line on
    // the *current* heading. Returns null when:
    //   - timer is idle, GPS data missing, or speed is too low,
    //   - the boat is already on/above the line (burn no longer meaningful),
    //   - the boat is sailing parallel to or away from the line, or
    //   - the projected crossing point falls outside the pin<->boat segment
    //     (i.e. would cross only an imaginary extension of the line).
    public function getTimeToBurnSeconds() as Number? {
        if (!countdownTimerRunning && timeToGunSeconds == defaultTimerMinutes * 60) {
            return null; // Timer hasn't started
        }

        if (pinEndLocation == null || boatEndLocation == null || currentPosition == null) {
            return null;
        }
        if (currentSpeedKnots == null || currentHeading == null) {
            return null;
        }

        var speedMs = currentSpeedKnots / 1.94384;
        if (speedMs < 0.5) {
            return null; // Moving too slow, calculation is unstable
        }

        // Build local pin-referenced ENU frame (matches getDistanceToLineMeters).
        var p = pinEndLocation.toRadians();
        var b = boatEndLocation.toRadians();
        var c = currentPosition.toRadians();
        var R = 6371000.0;
        var refCos = Math.cos(p[0]);
        var xB = (b[1] - p[1]) * refCos * R;
        var yB = (b[0] - p[0]) * R;
        var xC = (c[1] - p[1]) * refCos * R;
        var yC = (c[0] - p[0]) * R;

        var lenA = Math.sqrt(xB * xB + yB * yB);
        if (lenA == 0.0) {
            return null;
        }

        // Signed perpendicular distance (positive = below the line / pre-start).
        var d = (xC * yB - yC * xB) / lenA;
        if (d <= 0.0) {
            return null; // Already on or above the line.
        }

        // Velocity vector from GPS heading (degrees, 0 = N, 90 = E).
        var headingRad = currentHeading * Math.PI / 180.0;
        var vx = speedMs * Math.sin(headingRad);
        var vy = speedMs * Math.cos(headingRad);

        // Rate of change of d along the velocity. Negative => approaching line.
        var dDot = (vx * yB - vy * xB) / lenA;
        if (dDot >= -0.05) {
            // Parallel to or moving away from the line: never crosses.
            return null;
        }

        var timeToLineSeconds = -d / dDot;

        // Verify the crossing point falls on the actual line segment, not its
        // extension past either end.
        var crossX = xC + vx * timeToLineSeconds;
        var crossY = yC + vy * timeToLineSeconds;
        var alongLine = (crossX * xB + crossY * yB) / lenA;
        if (alongLine < 0.0 || alongLine > lenA) {
            return null;
        }

        // Positive => time to burn (early). Negative => late.
        return (timeToGunSeconds - timeToLineSeconds).toNumber();
    }
}