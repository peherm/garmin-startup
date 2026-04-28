import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;

class SplashView extends WatchUi.View {
    private var _raceState as RaceState;

    function initialize(raceState as RaceState) {
        View.initialize();
        _raceState = raceState;
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        var timer = new Timer.Timer();
        timer.start(method(:switchToMainView), 2000, false);
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        // App Name
        dc.drawText(width / 2, height * 0.4, Graphics.FONT_LARGE, "Sail StartUp", Graphics.TEXT_JUSTIFY_CENTER);

        // Version
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 0.6, Graphics.FONT_XTINY, "v" + SailStartupApp.VERSION, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function switchToMainView() as Void {
        WatchUi.switchToView(new SailStartupView(_raceState), new SailStartupDelegate(_raceState), WatchUi.SLIDE_IMMEDIATE);
    }
}