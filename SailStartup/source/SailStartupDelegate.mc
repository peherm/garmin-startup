import Toybox.Lang;
import Toybox.WatchUi;

class SailStartupDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new SailStartupMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}