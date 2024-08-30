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
    //! Constructor
    public function initialize() {
        AppBase.initialize();
    }

    //! Handle app startup
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void {
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {
    }

    // This method runs each time the main application starts.
    public function getInitialView() as [Views] or [Views, InputDelegates] { // SDK 7
    //public function getInitialView() {
        //var mainView = new AnalogView(); // old way
        if( Toybox.WatchUi has :WatchFaceDelegate ) {
            //var inputDelegate = new $.AnalogDelegate(mainView); // old way
            //return [mainView, inputDelegate]; // old way
            return [new $.AnalogView(), new $.AnalogDelegate()];
        } else {
            return [new $.AnalogView()];
        }
    }

    // This method runs when a goal is triggered and the goal view is started.
//    function getGoalView(goal) {
//        return [new AnalogGoalView(goal)];
//    }

    function getSettingsView() { // as [Views] or [Views, InputDelegates] {
        return [new $.AnalogSettingsViewTest(), new $.Menu2TestMenu2Delegate()];  // as Array[InputDelegate];
    }
}


