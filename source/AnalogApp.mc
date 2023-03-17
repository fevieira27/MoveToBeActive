//
// Copyright 2016-2017 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application;
import Toybox.Time;
import Toybox.Lang;
import Toybox.WatchUi;
//using Toybox.Communications;

// This is the primary entry point of the application.
class AnalogWatch extends Application.AppBase
{
    public function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    public function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    public function onStop(state as Dictionary?) as Void {
    }

    // This method runs each time the main application starts.
    public function getInitialView() as Array<Views or InputDelegates>? {
        var mainView = new AnalogView();
        if( Toybox.WatchUi has :WatchFaceDelegate ) {
            var inputDelegate = new $.AnalogDelegate(mainView);
            return [mainView, inputDelegate] as Array<Views or InputDelegates>;
        } else {
            return [mainView] as Array<Views>;
        }
    }

    // This method runs when a goal is triggered and the goal view is started.
//    function getGoalView(goal) {
//        return [new AnalogGoalView(goal)];
//    }

    function getSettingsView() {
        return [new $.AnalogSettingsViewTest(), new $.Menu2TestMenu2Delegate()] as Array<Views or InputDelegates>;
    }
}


