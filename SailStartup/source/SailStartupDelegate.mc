import Toybox.Lang;
import Toybox.WatchUi;

class SailStartupDelegate extends WatchUi.BehaviorDelegate {
    private var _raceState as RaceState;

    function initialize(raceState as RaceState) {
        BehaviorDelegate.initialize();
        _raceState = raceState;
    }

    // Triggered by the Start/Stop button (top right)
    function onSelect() as Boolean {
        if (_raceState.currentPage == 1) {
            // Line Page: Ping Boat
            if (_raceState.currentPosition != null) {
                _raceState.boatEndLocation = _raceState.currentPosition;
            }
        } else if (_raceState.currentPage == 3) {
            // Wind Page: Increase Wind
            var wind = _raceState.windDirectionDegrees;
            if (wind == null) { wind = 0; }
            _raceState.windDirectionDegrees = (wind + _raceState.windIncrement) % 360;
        } else if (_raceState.currentPage == 4) {
            // Tacks Page: Toggle Starboard Tack Recording
            _raceState.toggleStarboardRecording();
        } else {
            // Timer or Race Page: Start/Stop timer
            _raceState.countdownTimerRunning = !_raceState.countdownTimerRunning;
        }
        return true; // Return true to indicate we handled the input
    }

    // Triggered by the Back/Lap button (bottom right)
    function onBack() as Boolean {
        if (_raceState.currentPage == 1) {
            // Line Page: Ping Pin
            if (_raceState.currentPosition != null) {
                _raceState.pinEndLocation = _raceState.currentPosition;
            }
            return true;
        } else if (_raceState.currentPage == 3) {
            // Wind Page: Decrease Wind
            var wind = _raceState.windDirectionDegrees;
            if (wind == null) { wind = 0; }
            _raceState.windDirectionDegrees = (wind - _raceState.windIncrement + 360) % 360;
            return true;
        } else if (_raceState.currentPage == 4) {
            // Tacks Page: Toggle Port Tack Recording
            _raceState.togglePortRecording();
            return true;
        } else {
            // Timer or Race Page: Sync timer
            if (_raceState.countdownTimerRunning) {
                // Sync timer to nearest minute.
                _raceState.timeToGunSeconds = ((_raceState.timeToGunSeconds + 30) / 60) * 60;
                return true; 
            } else {
                // Reset timer if stopped
                if (_raceState.timeToGunSeconds != _raceState.defaultTimerMinutes * 60) {
                    _raceState.timeToGunSeconds = _raceState.defaultTimerMinutes * 60;
                    WatchUi.requestUpdate();
                    return true;
                }
                return false; // Exit app if stopped and already reset
            }
        }
    }

    // Triggered by the Down button (bottom left)
    function onNextPage() as Boolean {
        _raceState.currentPage = (_raceState.currentPage + 1) % 5;
        WatchUi.requestUpdate();
        return true;
    }

    // Triggered by the Up button (middle left)
    function onPreviousPage() as Boolean {
        _raceState.currentPage = (_raceState.currentPage + 4) % 5;
        WatchUi.requestUpdate();
        return true;
    }

    // Triggered by holding the Up button (Menu)
    function onMenu() as Boolean {
        if (_raceState.currentPage == 3) {
            // Cycle wind increment: 5 -> 10 -> 1 -> 5
            if (_raceState.windIncrement == 5) {
                _raceState.windIncrement = 10;
            } else if (_raceState.windIncrement == 10) {
                _raceState.windIncrement = 1;
            } else {
                _raceState.windIncrement = 5;
            }
            WatchUi.requestUpdate();
            return true;
        } else if (_raceState.currentPage == 0 || _raceState.currentPage == 2) {
            // Cycle default timer minutes: 5 -> 4 -> 3 -> 2 -> 1 -> 5
            _raceState.defaultTimerMinutes = _raceState.defaultTimerMinutes - 1;
            if (_raceState.defaultTimerMinutes < 1) {
                _raceState.defaultTimerMinutes = 5;
            }
            // If timer is currently stopped, also update the current time
            if (!_raceState.countdownTimerRunning) {
                _raceState.timeToGunSeconds = _raceState.defaultTimerMinutes * 60;
            }
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }
}