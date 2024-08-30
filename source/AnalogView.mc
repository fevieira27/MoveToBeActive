//
// Copyright 2016-2017 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
// 

import Toybox.Activity;
import Toybox.Weather;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;

//var partialUpdatesAllowed = false;

// This implements an analog watch face
// Original design by Austen Harbour
class AnalogView extends WatchUi.WatchFace
{
    //var offscreenBuffer;
    private var _offscreenBuffer as BufferedBitmap?;
    //private var _fullScreenRefresh as Boolean;
    //private var _partialUpdatesAllowed as Boolean;

    //var fullScreenRefresh;
	//var accentColor;
	//var MtbA = null;
    var inLowPower=false;
    //var canBurnIn=false;
    var upTop=true;    

    // Initialize variables for this view
    function initialize() {

        WatchFace.initialize();
        //_fullScreenRefresh = true;
        //_partialUpdatesAllowed = (WatchUi.WatchFace has :onPartialUpdate);

		if (Storage.getValue(1) == null or Storage.getValue(2) == null) {
            if (System.getDeviceSettings().screenWidth >= 360){ // AMOLED
//                accentColor = 0xAAFF00; 
                Storage.setValue(2, 1);
                Storage.setValue(1, 0xAAFF00); // Vivomove Green
            } else {
//                accentColor = 0x55FF00; 
                Storage.setValue(2, 0);
                Storage.setValue(1, 0x55FF00); // Bright Green
            }
        }

        var currentVersion=510;

        if (Storage.getValue(23)==null or Storage.getValue(23)<currentVersion){
            var checks = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
            if (System.getSystemStats() has :batteryInDays){
                checks[0]=true;
            }
            if (System.getDeviceSettings() has :doNotDisturb) { checks[4]=true; }
            if (System.getSystemStats() has :solarIntensity) { checks[8]=true; }
            if (UserProfile.getProfile() has :vo2maxRunning and UserProfile.getProfile() has :vo2maxCycling) { checks[3]=true; }

            if (Toybox has :Weather){
                checks[1]=true;
                if (Toybox.Weather has :getCurrentConditions){ 
                    checks[2]=true; 
                }
                if (Weather has :getSunset and Weather has :getSunrise) { checks[15]=true; }
            }
            if (Activity has :getActivityInfo) { 
                checks[9]=true; 
                if (Activity.getActivityInfo() has :currentOxygenSaturation){ checks[11]=true; }
                // if (Activity.getActivityInfo() has :altitude) { checks[16]=true; }
                if (Activity.getActivityInfo() has :meanSeaLevelPressure) { checks[6]=true; } // old 18
                if (Activity.getActivityInfo() has :rawAmbientPressure) { checks[5]=true; } // old 19
            }
            if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) { checks[10]=true; } // old 15
            if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getStressHistory)) { checks[13]=true; }
            
            if (ActivityMonitor.getInfo() has :floorsClimbed) { checks[12]=true; }
            if (ActivityMonitor.getInfo() has :respirationRate) { checks[14]=true; }
            if (ActivityMonitor.getInfo() has :timeToRecovery) { checks[7]=true; } // old 17
            
            Storage.setValue(21,checks);
        }

        if (Storage.getValue(19) == null ){ Storage.setValue(19, false); } // Battery Estimate, added on the initialize to try and correct an error that 26 users had
    }

    // Configure the layout of the watchface for this device
    public function onLayout(dc as Dc) as Void {
		
        var offscreenBufferOptions = {
                :width=>dc.getWidth(),
                :height=>dc.getHeight(),
                :palette=> [
                    Graphics.COLOR_DK_GRAY,
                    Graphics.COLOR_LT_GRAY,
                    Graphics.COLOR_BLACK,
                    Graphics.COLOR_WHITE
                    //,Storage.getValue(1)
                ]
            };

        if (Graphics has :createBufferedBitmap) {
            // get() used to return resource as Graphics.BufferedBitmap
            _offscreenBuffer = Graphics.createBufferedBitmap(offscreenBufferOptions).get() as BufferedBitmap;

        } else if (Graphics has :BufferedBitmap) { // If this device supports BufferedBitmap, allocate the buffers we use for drawing
            // Allocate a full screen size buffer with a palette of only 4 colors to draw
            // the background image of the watchface.  This is used to facilitate blanking
            // the second hand during partial updates of the display
            _offscreenBuffer = new Graphics.BufferedBitmap(offscreenBufferOptions);
        } else {
            _offscreenBuffer = null;
        }
    }


    // Handle the update event
    public function onUpdate(dc as Dc) as Void {
        var targetDc = null;        
        var MtbA = new MtbA_functions();
        var check = Storage.getValue(21);
        var canBurnIn=System.getDeviceSettings().requiresBurnInProtection;
        var accentColor = Storage.getValue(1);

        // We always want to refresh the full screen when we get a regular onUpdate call.
        //_fullScreenRefresh = true;
        if (null != _offscreenBuffer) {
            // If we have an offscreen buffer that we are using to draw the background,
            // set the draw context of that buffer as our target.
            targetDc = _offscreenBuffer.getDc();
            dc.clearClip();
        } else {
            targetDc = dc;
        }

        var width = targetDc.getWidth();
        var height = targetDc.getHeight();

        //System.println(width);
        //System.println(height);

        //var labels=Storage.getValue(5);

        if(inLowPower and canBurnIn) { // aod on
        	if (dc has :setAntiAlias) {
        		dc.setAntiAlias(false);
        	}
            
            upTop=!upTop;
            //targetDc.clearClip();
            targetDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK); // removing the background color and all the data points from the background, leaving just the hour hands and hashmarks
            targetDc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight()); //width & height?

            if(Storage.getValue(18)){
                drawBackground(dc);
                MtbA.drawHashMarks(dc, accentColor, width, height, inLowPower and canBurnIn, Storage.getValue(18)); //dc
            } else {
                MtbA.drawHashMarks(targetDc, accentColor, width, height, inLowPower and canBurnIn, Storage.getValue(18)); //dc
                drawBackground(dc);
            }

            // Draw the tick marks around the edges of the screen
            
            //drawBackground(dc);
            //dc.drawBitmap(0, 0, _offscreenBuffer);
        } else {

            // Fill the entire background
            if (Storage.getValue(32) == true){ // Light Theme
                targetDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
            } else { // Dark Theme
                targetDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            }
            targetDc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight()); //width & height?

            // Output the offscreen buffers to the main display if required.
            drawBackground(dc);

            // Draw the tick marks around the edges of the screen
            if(width>=360){ // No need for anti-alias on hashmarks of AMOLED screens
                MtbA.drawHashMarks(dc, accentColor, width, height, inLowPower and canBurnIn, Storage.getValue(18)); //dc        
            }

            if (dc has :setAntiAlias) {
                dc.setAntiAlias(true);
            }

            // Draw the tick marks around the edges of the screen
            if(width<360){ // With anti-alias for MIP displays
                MtbA.drawHashMarks(dc, accentColor, width, height, inLowPower and canBurnIn, Storage.getValue(18)); //dc                        
            }

            // Garmin Logo check
            var logo=Storage.getValue(3);
            var position = Application.loadResource(Rez.JsonData.mPosition);
            if (logo == null or logo == true) {
                MtbA.drawGarminLogo(dc, position[4], position[5]); 
            }

            // Draw the 3, 6, 9, and 12 hour labels.
            if (System.SCREEN_SHAPE_ROUND == System.getDeviceSettings().screenShape and Storage.getValue(5) != false) {
                MtbA.drawHourLabels(dc, width, height, accentColor); 
            }

            //Draw Weather Icon (dc, x, y, x2, width)
            //if (Toybox has :Weather and Weather has :getCurrentConditions) {
            if (check[1] and check[2]) {
                if(Toybox.Weather.getCurrentConditions() != null) {
                    //var cond = Toybox.Weather.getCurrentConditions();
                    if (logo==false){ // Hide Garmin Logo
                        if (Storage.getValue(25)!=false){ // Show current weather condition and temperature
                            //if (cond.condition!=null and cond.condition instanceof Number){
                                MtbA.drawWeatherIcon(dc, position[18], position[22], position[19], width);
                            //}
                            //Draw Temperature Text
                            MtbA.drawTemperature(dc, position[21], position[7], Storage.getValue(6), width);
                        }
                        //if (cond.observationLocationName!=null){
                            //Draw Location Name
                            MtbA.drawLocation(dc, width/2, position[6], width*0.60, dc.getFontHeight(Graphics.FONT_TINY), Storage.getValue(7));
                        //}
                    } else { // Show Garmin Logo
                        if (Storage.getValue(25)!=false){ // Show current weather condition and temperature
                            //if (cond.condition!=null and cond.condition instanceof Number){
                                MtbA.drawWeatherIcon(dc, position[18], position[20], position[19], width);
                            //}
                            //Draw Temperature Text
                            MtbA.drawTemperature(dc, position[21], (System.SCREEN_SHAPE_ROUND == System.getDeviceSettings().screenShape)?position[15]:position[20], Storage.getValue(6), width);
                        }
                        //if (cond.observationLocationName!=null){
                            //Draw Location Name
                            MtbA.drawLocation(dc, width/2, position[23], width*0.60, dc.getFontHeight(Graphics.FONT_TINY), Storage.getValue(7));
                        //}                        
                    }
                }
            }
            
            // Draw Battery
            if (Storage.getValue(26)!=false){ // Show Battery Icon
                MtbA.drawBatteryIcon(dc, width*0.69, height / 2.11, width*0.82, height / 2.06+(width==218 ? 1 : 0), width, height, accentColor);
                MtbA.drawBatteryText(dc, width*0.76, height / 2.14 - 1, width, check[0]);
            }

            //Data Points
            var FontAdj=0;
            if (Storage.getValue(14)==true){ // fontSize height adjustment
                if (width==260 and dc.getFontHeight(Graphics.FONT_TINY)==29) { //Fenix 6
                    FontAdj=6;
                } else if (width==260 and dc.getFontHeight(Graphics.FONT_TINY)==27) { // Vivoactive 4
                    FontAdj=5; 
                } else if (width==280){
                    FontAdj=7;
                } else if (width==416) { // Venu 2 and 2 Plus
                    FontAdj=5;
                } else if (width==360 or width==390) { //Venu and 2s
                    FontAdj=4;
                } else if (width>=454) {
                    FontAdj=6;
                } else if (width==218) {
                    if (dc.getFontHeight(Graphics.FONT_TINY)==23){
                        FontAdj=2;
                    } else {
                        FontAdj=3;
                    }
                } else if (width==240) { 
                    if (dc.getFontHeight(Graphics.FONT_TINY)==26 and dc.getFontHeight(Graphics.FONT_XTINY)!=26) { // Fenix 6s
                        FontAdj=4;
                    }
                } else { // Fenix 5 Plus
                    FontAdj=2;
                }
            }

            // (dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset, dataPoint)            
            var dataPoint = Storage.getValue(12); //right bottom
            MtbA.drawPoints(dc, position[8], position[14], position[10], position[15]-FontAdj, accentColor, width, dataPoint, 4);
            //MtbA.drawRightPoints(dc, position[8], position[14], position[10], position[15], accentColor, width, 0, dataPoint);

            dataPoint = Storage.getValue(17); //right top
            MtbA.drawPoints(dc, position[8], position[9], position[10], position[11]-FontAdj, accentColor, width, dataPoint, 4); 

            //(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
            dataPoint = Storage.getValue(9); // left top
            MtbA.drawPoints(dc, position[12], position[9], position[13], position[11]-FontAdj, accentColor, width, dataPoint, 1);

            dataPoint = Storage.getValue(10); // left middle
            MtbA.drawPoints(dc, position[12], position[16], position[13], position[17]-FontAdj, accentColor, width, dataPoint, 2);	
            //MtbA.drawLeftMiddle(dc, position[12], position[16], position[13], position[17], accentColor, width, dataPoint);	

            dataPoint = Storage.getValue(11); // left bottom
            MtbA.drawPoints(dc, position[12], position[14], position[13], position[15]-FontAdj, accentColor, width, dataPoint, 3);

            var iconSize = 0;

            if (width==360){
                iconSize = 12;
            } else if (width==280){
                iconSize = 13;
            } else if (width==260){
                iconSize = 14;
            } else if (width==240){
                iconSize = 12;
            } else if (width==218){
                iconSize = 15;
            } else if (width>360){
                iconSize = 20;
            }

            // Bluetooth, Alarm and Dnd Icons
            var alarm = Storage.getValue(8), blue = Storage.getValue(4);
            if (check[4] and System.getDeviceSettings().doNotDisturb) { // Dnd exists and is turned on
                if ((alarm == true and blue == true) or (alarm == null and blue == null)){ // all 3 icons
                    // Draw the Do Not Disturb Icon in the middle
                    MtbA.drawDndIcon(dc, position[0], position[1], width, check[4]);
                    // Draw alarm icon on the right
                    MtbA.drawAlarmIcon(dc, position[3], position[1], accentColor, width);
                    //Draw bluetooth icon on the left
                    MtbA.drawBluetoothIcon(dc, position[2], position[1]);
                } else if(alarm == false and (blue == true)) { // alarm icon is hidden
                    // Draw the Do Not Disturb Icon on the right
                    MtbA.drawDndIcon(dc, (position[0]+position[3])/2, position[1], width, check[4]);
                    //Draw bluetooth icon on the left
                    MtbA.drawBluetoothIcon(dc, (position[2]+position[0])/2, position[1]);
                } else if(alarm == true and blue == false){ // bluetooth icon is hidden
                    // Draw the Do Not Disturb Icon on the left
                    MtbA.drawDndIcon(dc, (position[3]+position[0])/2, position[1], width, check[4]);
                    // Draw alarm icon on the right
                    MtbA.drawAlarmIcon(dc, (position[0]+position[2])/2, position[1], accentColor, width);                    
                } else{ // only Dnd
                    // Draw the Do Not Disturb Icon in the middle
                    MtbA.drawDndIcon(dc, position[0], position[1], width, check[4]);
                }
            } else { // Dnd does not exist or is turned off
                if ((alarm == true or alarm == null) and (blue == true or blue == null)){ // all 2 icons
                    // Draw alarm icon on the right
                    //MtbA.drawAlarmIcon(dc, (position[3]+(position[3]+position[0])/2)/2, position[1], accentColor, width);
                    MtbA.drawAlarmIcon(dc, ((position[3]+position[0])/2)+iconSize, position[1], accentColor, width);
                    //Draw bluetooth icon on the left
                    MtbA.drawBluetoothIcon(dc, (position[2]+position[0])/2, position[1]);
                } else if(alarm == false and (blue == true)){ // alarm icon is hidden
                    MtbA.drawBluetoothIcon(dc, (width/2)-1, position[1]);
                } else if(alarm == true){
                    MtbA.drawAlarmIcon(dc, width/2, position[1], accentColor, width);
                }
            }

            //Draw the date string
            if (logo == null or logo == true) { // Garmin Logo check
                MtbA.drawDateString( dc, width / 2, position[6] ); 
            } else { // No Garmin Logo
                MtbA.drawDateString( dc, width / 2, position[5] + (width<=240 ? 5 : 0 ) + (width==218 ? 3 : 0 )); // offsets needed because of size of Garmin Logo compared to Date Font
            }

        } 
        
		//Draw Hour and Minute hands
        if (Storage.getValue(13) == 1){ // thicker
			MtbA.drawHands(dc, width, height, accentColor, 1, inLowPower, upTop);
		} else if (Storage.getValue(13) == 0) { // standard //or Storage.getValue(13) == null
			MtbA.drawHands(dc, width, height, accentColor, 0, inLowPower, upTop);
		} else { // thinner
            MtbA.drawHands(dc, width, height, accentColor, 2, inLowPower, upTop);
        }            

        /*
        if (_partialUpdatesAllowed) {
            // If this device supports partial updates and they are currently
            // allowed run the onPartialUpdate method to draw the second hand.
            onPartialUpdate(dc);
        } else if (inLowPower==false) {
            // Otherwise, if we are out of sleep mode, draw the second hand
            // directly in the full update method.

            //call the seconds hand here
        }

        _fullScreenRefresh = false;
        */
    }


  // Handle the partial update event
    public function onPartialUpdate(dc as Dc) as Void {
        // If we're not doing a full screen refresh we need to re-draw the background
        // before drawing the updated second hand position. Note this will only re-draw
        // the background in the area specified by the previously computed clipping region.
    //    if (!_fullScreenRefresh) {
    //        drawBackground(dc);
    //    }

        //call the seconds hand here
    }


    //! Draw the watch face background
    //! onUpdate uses this method to transfer newly rendered Buffered Bitmaps
    //! to the main display.
    //! onPartialUpdate uses this to blank the second hand from the previous
    //! second before outputting the new one.
    //! @param dc Device context
    private function drawBackground(dc as Dc) as Void {
        // If we have an offscreen buffer that has been written to
        // draw it to the screen.
        if (null != _offscreenBuffer) {
            dc.drawBitmap(0, 0, _offscreenBuffer);
        }

    }
    
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

//! This method is called when the device re-enters sleep mode.
    //! Set the isAwake flag to let onUpdate know it should stop rendering the second hand.
    public function onEnterSleep() as Void {
        //_isAwake = false;
        inLowPower=true;
        WatchUi.requestUpdate();
    }


    //! This method is called when the device exits sleep mode.
    //! Set the isAwake flag to let onUpdate know it should render the second hand.
    public function onExitSleep() as Void {
        //_isAwake = true;
        inLowPower=false;
        //WatchUi.requestUpdate();
    }

    //! Turn off partial updates
    /* public function turnPartialUpdatesOff() as Void {
        _partialUpdatesAllowed = false;
    }    
    */
}

class AnalogDelegate extends WatchUi.WatchFaceDelegate {

    //private var _view as AnalogView;

    //function initialize(view as AnalogView) {
    function initialize() {
        WatchFaceDelegate.initialize();
//        _view = view;
    }

    // The onPowerBudgetExceeded callback is called by the system if the
    // onPartialUpdate method exceeds the allowed power budget. If this occurs,
    // the system will stop invoking onPartialUpdate each second, so we set the
    // partialUpdatesAllowed flag here to let the rendering methods know they
    // should not be rendering a second hand.
    function onPowerBudgetExceeded(powerInfo) {
        //System.println( "Average execution time: " + powerInfo.executionTimeAverage );
        //System.println( "Allowed execution time: " + powerInfo.executionTimeLimit );
        //partialUpdatesAllowed = false;
    }
}