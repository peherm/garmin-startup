import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Math;

class SailStartupApp extends Application.AppBase {
    public static const VERSION = "0.1.5";
    private var _raceState as RaceState;
    private var _recorder as SailRecorder;

    function initialize() {
        AppBase.initialize();
        _raceState = new RaceState();
        _recorder = new SailRecorder();
    }

    public function getRecorder() as SailRecorder {
        return _recorder;
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        // Persist any in-flight recording so the sailor never loses their FIT.
        _recorder.stopAndSave();
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
        return [ new SplashView(_raceState) ];
    }

}

function getApp() as SailStartupApp {
    return Application.getApp() as SailStartupApp;
}