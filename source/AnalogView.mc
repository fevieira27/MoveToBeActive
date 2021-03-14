//
// Copyright 2016-2017 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
// 

using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;
//using Toybox.Application;
//using Toybox.SensorHistory;
using Toybox.Application.Storage;

var partialUpdatesAllowed = false;

// This implements an analog watch face
// Original design by Austen Harbour
class AnalogView extends WatchUi.WatchFace
{
    var offscreenBuffer;
    var dateBuffer;
    var fullScreenRefresh;
	var offset = 0;
	var Xoffset = 0;
	var accentColor = 0x55FF00;
	var MtbA = null;

    // Initialize variables for this view
    function initialize() {
        WatchFace.initialize();
        fullScreenRefresh = true;
        partialUpdatesAllowed = ( Toybox.WatchUi.WatchFace has :onPartialUpdate );
    }

    // Configure the layout of the watchface for this device
    function onLayout(dc) {
		
		if (Storage.getValue(1) != null) {
			accentColor = Storage.getValue(1);
		}
		
        // If this device supports BufferedBitmap, allocate the buffers we use for drawing
        if(Toybox.Graphics has :BufferedBitmap) {
            // Allocate a full screen size buffer with a palette of only 4 colors to draw
            // the background image of the watchface.  This is used to facilitate blanking
            // the second hand during partial updates of the display
            offscreenBuffer = new Graphics.BufferedBitmap({
                :width=>dc.getWidth(),
                :height=>dc.getHeight(),
                :palette=> [
                    Graphics.COLOR_DK_GRAY,
                    Graphics.COLOR_LT_GRAY,
                    Graphics.COLOR_BLACK,
                    Graphics.COLOR_WHITE
                    ,Graphics.COLOR_BLUE
                    ,Graphics.COLOR_TRANSPARENT
                    ,0xAAFF00 //Vivomove Green
                ]
            });

            // Allocate a buffer tall enough to draw the date into the full width of the
            // screen. This buffer is also used for blanking the second hand. This full
            // color buffer is needed because anti-aliased fonts cannot be drawn into
            // a buffer with a reduced color palette
            dateBuffer = new Graphics.BufferedBitmap({
                :width=>dc.getWidth(),
                :height=>Graphics.getFontHeight(Graphics.FONT_MEDIUM)
            });
        } else {
            offscreenBuffer = null;
        }

    }


    // Handle the update event
    function onUpdate(dc) {
    	if (dc has :setAntiAlias) {
    		dc.setAntiAlias(true);
    	}
        var width;
        var height;
        var targetDc = null;
        
        MtbA = new MtbA_functions();
        		
        // We always want to refresh the full screen when we get a regular onUpdate call.
        fullScreenRefresh = true;

        if(null != offscreenBuffer) {
            dc.clearClip();
            // If we have an offscreen buffer that we are using to draw the background,
            // set the draw context of that buffer as our target.
            targetDc = offscreenBuffer.getDc();
        } else {
            targetDc = dc;
        }

        width = targetDc.getWidth();
        height = targetDc.getHeight();
        if (width==390) { // Venu & D2 Air
			Xoffset = 10;
		} else if (width==218) {
			Xoffset = 1;
		} else if (width==240 or width==260 or width==280) { // Fenix 6S e Vivoactive 3 Music & MARQ Athlete
			Xoffset = 0;
		}


        // Fill the entire background with Black.
        targetDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        targetDc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
        
        // Draw a grey triangle over the upper right half of the screen.
        //targetDc.fillPolygon([[0, 0], [targetDc.getWidth(), 0], [targetDc.getWidth(), targetDc.getHeight()], [0, 0]]);
                                    

        // Output the offscreen buffers to the main display if required.
        drawBackground(dc);
		
		
		// Draw the 3, 6, 9, and 12 hour labels.
        if (Storage.getValue(5) == null or Storage.getValue(5) == true) {
            MtbA.drawHourLabels(dc, width, height);
        }
		
		//Draw Weather Icon (dc, x, y, x2, width)
		if (Toybox has :Weather) {
			if (Storage.getValue(3)==false){ // Hide Garmin Logo
				//System.println(Xoffset);
				if (width == 218) {
					MtbA.drawWeatherIcon(dc, width/1.95-1, height*0.62-5, width/2-Xoffset, width);
				} else {
					MtbA.drawWeatherIcon(dc, width/1.95, height*0.62+Xoffset, width/2-Xoffset, width);
				}
				//Draw Temperature Text
				MtbA.drawTemperature(dc, width/2+Xoffset, height*0.65, Storage.getValue(6), width);
				//Draw Location Name
				MtbA.drawLocation(dc, width/2, height*0.725, width*0.60, height*0.10, Storage.getValue(7));
			} else { // Show Garmin Logo
				MtbA.drawWeatherIcon(dc, width/1.95, height*0.65-29, width/2-Xoffset, width);
				//Draw Temperature Text
				MtbA.drawTemperature(dc, width/2+Xoffset, height*0.57, Storage.getValue(6), width);
				//Draw Location Name
				MtbA.drawLocation(dc, width/2, height*0.65, width*0.60, height*0.10, Storage.getValue(7));
			}
		}
		
		// Notifications (dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)	
		MtbA.drawNotification(dc, width*0.74, height*0.56, width *0.8, height*0.57, accentColor, width, Xoffset);
		//MtbA.drawPrecipitation(dc, width*0.71, height*0.565, width *0.75, height*0.57, width);

		// Draw Battery
		MtbA.drawBatteryIcon(dc, width*0.69, height / 2.1, width*0.82, height / 2.05, width, height, accentColor);
		MtbA.drawBatteryText(dc, width*0.76, height / 2.12 - 1, width);
		
		// Draw the Do Not Disturb Icon
		MtbA.drawDndIcon(dc, width /2.2, height * 0.31, width);        
		
        // Garmin Logo check
        if (Storage.getValue(3) == null or Storage.getValue(3) == true) {
			MtbA.drawGarminLogo(dc, width / 2 - 50, height / 6);
		}
                      
		//Bluetooth icon
        if (Storage.getValue(4) == null or Storage.getValue(4) == true) {
            if (Storage.getValue(8) == null or Storage.getValue(8) == true) {
	            MtbA.drawBluetoothIcon(dc, width*0.72 /*width*0.66+14*/, height / 3);
	        } else {
	        	MtbA.drawBluetoothIcon(dc, width*0.75, height / 3);
	        }
        }
        
        
        //Alarm icon
        if (Storage.getValue(8) == null or Storage.getValue(8) == true) {
            if (Storage.getValue(4) == null or Storage.getValue(4) == true) {
            	MtbA.drawAlarmIcon(dc, width*0.81 /*width*0.75+14*/, height/3, accentColor, width);
	        } else {
	        	MtbA.drawAlarmIcon(dc, width*0.75, height/3, accentColor, width);
	        }
        }
 
		
		// Xoffset for the 3 left data points: heart rate, steps and floor climb
		if (width==390) { // Venu & D2 Air
			Xoffset = 22;
		} else if (width==240) { // Fenix 6S e Vivoactive 3 Music & MARQ Athlete
			Xoffset = 5;
		} else if (width==280) { // Fenix 6X e Enduro
			Xoffset = 5;
		} else if (width==260) { // Vivoactive 4
			Xoffset = 5;
		} else if (width==218) { // Fenix 6S e Vivoactive 3 Music & MARQ Athlete
			Xoffset = 2;
		}
		
		// Draw heart rate
		MtbA.drawHeartRate(dc, width / 4.7, height/2.9, width / 3.65, width, Xoffset, accentColor);
					
        // Draw Pulse Ox and return true (if sensor is active) or false (if sensor inactive)    
        var pulseBoolean = MtbA.drawPulseOx(dc, width / 4.7 - Xoffset, height * 0.565, width / 3.75 - Xoffset, height * 0.57, width, accentColor);
        if (pulseBoolean==false) {
        	// Floors Climbed (dc, xIcon, yIcon, xText, yText, width, accentColor)
        	MtbA.drawFloorsClimbed(dc, width / 4.7 - Xoffset, height * 0.56, width / 3.65 - Xoffset, height * 0.57, width, accentColor);
        	//MtbA.drawHumidity(dc, width / 4.6 - Xoffset, height * 0.56, width / 3.75 - Xoffset, height * 0.57, width);
        	//MtbA.drawSolarIntensity(dc, width / 4.6 - Xoffset, height * 0.56, width / 3.75 - Xoffset, height * 0.57, width, accentColor);        	
        }
        
		// Draw Distance Traveled / Steps (dc, xIcon, yIcon, xText, yText, width, accentColor)
		MtbA.drawSteps(dc, width / 4.6 - Xoffset, height / 2.25, width / 3.75 - Xoffset, height / 2.18, width, accentColor);
		//MtbA.drawWindSpeed(dc, width / 4.6 - Xoffset, height / 2.25, width / 3.75 - Xoffset, height / 2.18, width);
        
        // Draw elevation (dc, xIcon, yIcon, xText, yText, width)
        //MtbA.drawElevation(dc, width / 4.6 - Xoffset, height / 2.25, width / 3.75 - Xoffset, height / 2.18, width);

    	// Calories (dc, xIcon, yIcon, xText, yText, width, accentColor)
    	//MtbA.drawCalories(dc, width / 4.6 - Xoffset, height * 0.56, width / 3.75 - Xoffset, height * 0.57, width);


        // If we have an offscreen buffer that we are using for the date string,
        // Draw the date into it. If we do not, the date will get drawn every update
        // after blanking the second hand.
        if( null != dateBuffer ) {
            var dateDc = dateBuffer.getDc();

            //Draw the background image buffer into the date buffer to set the background
            dateDc.drawBitmap(0, -(height / 4), offscreenBuffer); //Graphics.Dc.drawBitmap(x, y, bitmap)

            //Draw the date string into the buffer.
            MtbA.drawDateString( dateDc, width / 2, 0 );

		    // Draw the tick marks around the edges of the screen
		    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
		    MtbA.drawHashMarks(dc, accentColor, Storage.getValue(5), width, height);
		            
            //drawBatt( dc, width, height);
        }
        
		//Draw Hour and Minute hands
		MtbA.drawHands(dc, width, height, accentColor);        
        
        fullScreenRefresh = false;
    }
          

  // Handle the partial update event
    function onPartialUpdate( dc ) {
        // If we're not doing a full screen refresh we need to re-draw the background
        // before drawing the updated second hand position. Note this will only re-draw
        // the background in the area specified by the previously computed clipping region.
    }


    // Draw the watch face background
    // onUpdate uses this method to transfer newly rendered Buffered Bitmaps
    // to the main display.
    // onPartialUpdate uses this to blank the second hand from the previous
    // second before outputing the new one.
    function drawBackground(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();

        //If we have an offscreen buffer that has been written to
        //draw it to the screen.
        if( null != offscreenBuffer ) {
            dc.drawBitmap(0, 0, offscreenBuffer);
        }

        // Draw the date
        offset = 0;
        if (width==218) { // Vivoactive 4S
			offset = -3;
		} else if (width==240) { // Vivoactive 4S and MARQ Athlete
			offset = -2;
		} else if (width==390) { // Vivoactive 4S and MARQ Athlete
			offset = 13;
		} else if (width==260) { // Vivoactive 4S and MARQ Athlete
			offset = 1;
		}
		
        
        if( null != dateBuffer ) {
            // If the date is saved in a Buffered Bitmap, just copy it from there.
            if (Storage.getValue(3) == null or Storage.getValue(3) == true) {
            	dc.drawBitmap(0, (height * 0.725) + offset, dateBuffer ); //Graphics.Dc.drawBitmap(x, y, bitmap)
			} else {
				dc.drawBitmap(0, height / 5.1, dateBuffer ); //Graphics.Dc.drawBitmap(x, y, bitmap)
			}            	
        } else {
            // Otherwise, draw it from scratch. drawDateString( dc, x, y )
            
            // Garmin Logo check
	        if (Storage.getValue(3) == null or Storage.getValue(3) == true) {
            	MtbA.drawDateString( dc, width / 2, height * 0.725 + offset );
			} else {
				MtbA.drawDateString( dc, 0, height / 5.1 );
			}
            
            
		    // Draw the tick marks around the edges of the screen
		    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
		    MtbA.drawHashMarks(dc, accentColor);
		          
        }
        //drawBatt( dc, width, height);
    }
    
    // This method is called when the device re-enters sleep mode.
    // Set the isAwake flag to let onUpdate know it should stop rendering the second hand.
    function onEnterSleep() {
//        isAwake = false;
//        WatchUi.requestUpdate();
    }

    // This method is called when the device exits sleep mode.
    // Set the isAwake flag to let onUpdate know it should render the second hand.
    function onExitSleep() {
//        isAwake = true;
    }
}

class AnalogDelegate extends WatchUi.WatchFaceDelegate {

    function initialize() {
        WatchFaceDelegate.initialize();
    }

    // The onPowerBudgetExceeded callback is called by the system if the
    // onPartialUpdate method exceeds the allowed power budget. If this occurs,
    // the system will stop invoking onPartialUpdate each second, so we set the
    // partialUpdatesAllowed flag here to let the rendering methods know they
    // should not be rendering a second hand.
    function onPowerBudgetExceeded(powerInfo) {
        System.println( "Average execution time: " + powerInfo.executionTimeAverage );
        System.println( "Allowed execution time: " + powerInfo.executionTimeLimit );
        //partialUpdatesAllowed = false;
    }
}
