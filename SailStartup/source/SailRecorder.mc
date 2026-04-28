import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.System;

// Thin wrapper around Toybox.ActivityRecording so the rest of the app does not
// need to deal with Session lifecycle directly. Records a SAILING activity
// that can be uploaded to Garmin Connect for post-race analysis (FIT file with
// GPS track, speed, and heading).
class SailRecorder {
    private var _session as ActivityRecording.Session?;

    function initialize() {
        _session = null;
    }

    public function isRecording() as Boolean {
        return _session != null && _session.isRecording();
    }

    // Lazily creates a sailing session and starts it. Safe to call repeatedly.
    public function start() as Void {
        if (!(Toybox has :ActivityRecording)) {
            return;
        }
        if (_session == null) {
            try {
                _session = ActivityRecording.createSession({
                    :name => "Sail Start",
                    :sport => Activity.SPORT_SAILING,
                    :subSport => Activity.SUB_SPORT_GENERIC
                });
            } catch (ex) {
                System.println("createSession failed: " + ex.getErrorMessage());
                _session = null;
                return;
            }
        }
        if (_session != null && !_session.isRecording()) {
            _session.start();
        }
    }

    // Stops the session and writes the FIT file to the device's activity list.
    // No-op if nothing is recording.
    public function stopAndSave() as Void {
        if (_session == null) {
            return;
        }
        if (_session.isRecording()) {
            _session.stop();
        }
        _session.save();
        _session = null;
    }

    // Stops the session and throws the data away.
    public function discard() as Void {
        if (_session == null) {
            return;
        }
        if (_session.isRecording()) {
            _session.stop();
        }
        _session.discard();
        _session = null;
    }
}
