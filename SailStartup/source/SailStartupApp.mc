import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Math;

class SailStartupApp extends Application.AppBase {
    private var _raceState as RaceState;

    function initialize() {
        AppBase.initialize();
        _raceState = new RaceState();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    // Callback for position updates
    function onPosition(info as Position.Info) as Void {
        if (info != null) {
            if (info.position != null) {
                _raceState.currentPosition = info.position;
            }
            if (info.speed != null) {
                _raceState.currentSpeedKnots = info.speed * 1.94384; // Convert m/s to knots
            }
            if (info.heading != null) {
                // heading is in radians (-PI to PI), convert to degrees (0 to 360)
                var headingDeg = info.heading * (180.0 / Math.PI);
                if (headingDeg < 0) {
                    headingDeg += 360.0;
                }
                _raceState.setCurrentHeading(headingDeg);
            }
        }
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SailStartupView(_raceState), new SailStartupDelegate(_raceState) ];
    }

}

function getApp() as SailStartupApp {
    return Application.getApp() as SailStartupApp;
}