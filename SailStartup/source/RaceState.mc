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

        var avgLatB = (bLat + pLat) / 2.0;
        var xB = (bLon - pLon) * Math.cos(avgLatB) * R;
        var yB = (bLat - pLat) * R;

        var avgLatC = (cLat + pLat) / 2.0;
        var xC = (cLon - pLon) * Math.cos(avgLatC) * R;
        var yC = (cLat - pLat) * R;

        var lenA = Math.sqrt(xB * xB + yB * yB);
        
        if (lenA == 0.0) {
            return Math.sqrt(xC * xC + yC * yC).toFloat();
        }

        var cross = xC * yB - yC * xB;
        if (cross < 0) {
            cross = -cross;
        }
        return (cross / lenA).toFloat();
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

    public function getTimeToBurnSeconds() as Number? {
        if (!countdownTimerRunning && timeToGunSeconds == defaultTimerMinutes * 60) {
            return null; // Timer hasn't started
        }

        var distMeters = getDistanceToLineMeters();
        if (distMeters == null || currentSpeedKnots == null) {
            return null; // Missing data
        }

        // Convert knots back to m/s for calculation
        var speedMs = currentSpeedKnots / 1.94384;
        
        if (speedMs < 0.5) {
            return null; // Moving too slow, calculation is useless/infinite
        }

        var timeToLineSeconds = distMeters / speedMs;
        
        // Positive means we have time to burn (we are early)
        // Negative means we are late
        return (timeToGunSeconds - timeToLineSeconds).toNumber();
    }
}