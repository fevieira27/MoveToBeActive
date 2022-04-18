//
// Copyright 2016-2017 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application;
import Toybox.Time;
//using Toybox.Communications;

// This is the primary entry point of the application.
class AnalogWatch extends Application.AppBase
{
    var temperature = null;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // This method runs each time the main application starts.
    function getInitialView() as Array<Views or InputDelegates>? {
        if( Toybox.WatchUi has :WatchFaceDelegate ) {
            return [new AnalogView(), new AnalogDelegate()] as Array<Views or InputDelegates>;
        } else {
            return [new AnalogView()] as Array<Views or InputDelegates>;
        }
    }

    // This method runs when a goal is triggered and the goal view is started.
//    function getGoalView(goal) {
//        return [new AnalogGoalView(goal)];
//    }

    function getSettingsView() {
        return [new AnalogSettingsViewTest(), new Menu2TestMenu2Delegate()];
    }
}


