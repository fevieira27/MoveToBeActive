//
// Copyright 2016-2017 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
// 

import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application.Storage;

//var partialUpdatesAllowed = false;

// This implements an analog watch face
// Original design by Austen Harbour
class AnalogView extends WatchUi.WatchFace
{
    var offscreenBuffer;
    //var fullScreenRefresh;
	var accentColor;
	var MtbA = null;
    var inLowPower=false;
    var canBurnIn=false;
    var upTop=true;    

    // Initialize variables for this view
    function initialize() {
        WatchFace.initialize();
        //fullScreenRefresh = true;
        //partialUpdatesAllowed = ( Toybox.WatchUi.WatchFace has :onPartialUpdate );
        var sSettings=System.getDeviceSettings();
        //first check if the setting is availe on the current device
        if(sSettings has :requiresBurnInProtection) {
            //get the state of the setting      
        	canBurnIn=sSettings.requiresBurnInProtection;
        }
    }

    //! Factory function to create buffered bitmap
    function bufferedBitmapFactory(options as {
                :width as Number,
                :height as Number,
                :palette as Array<ColorType>
    //            ,:colorDepth as Number,
    //            :bitmapResource as WatchUi.BitmapResource
            }) as BufferedBitmapReference or BufferedBitmap {
        if (Graphics has :createBufferedBitmap) {
            return Graphics.createBufferedBitmap(options);
        } else {
            return new Graphics.BufferedBitmap(options);
        }
    }

    // Configure the layout of the watchface for this device
    function onLayout(dc) {
		
		if (Storage.getValue(1) != null) {
			accentColor = Storage.getValue(1);
		} else {
            accentColor = 0x55FF00;
        }

        //System.println(accentColor);
		
        // If this device supports BufferedBitmap, allocate the buffers we use for drawing
        if(Toybox.Graphics has :BufferedBitmap or :BufferedBitmapReference) {
            // Allocate a full screen size buffer with a palette of only 4 colors to draw
            // the background image of the watchface.  This is used to facilitate blanking
            // the second hand during partial updates of the display

            //offscreenBuffer = new Graphics.BufferedBitmap({
            offscreenBuffer = bufferedBitmapFactory({ // SDK 4.0
                :width=>dc.getWidth(),
                :height=>dc.getHeight(),
                :palette=> [
                    Graphics.COLOR_DK_GRAY,
                    Graphics.COLOR_LT_GRAY,
                    Graphics.COLOR_BLACK,
                    Graphics.COLOR_WHITE
                    ,accentColor
/*                    ,Graphics.COLOR_BLUE
                    ,Graphics.COLOR_TRANSPARENT
                    ,0xAAFF00 //Vivomove Green
                    ,0x55FF00 //Green
                    ,0xFFFF00 //Yellow
                    ,0x00FFFF //Cyan
                    ,0xAA55FF //Violet
                    ,0xFFAA00 //Orange
                    ,0xFF0000 //Red
                    ,0xFF55FF //Pink */
                ]
      		}) ; 

            if (Graphics has :createBufferedBitmap) {
            	//System.println("test1");
		        //targetDc = offscreenBuffer.get();//.getDc()
                offscreenBuffer = offscreenBuffer.get();
		    }
        } else {
            offscreenBuffer = null;
        }

    }


    // Handle the update event
    function onUpdate(dc) {
        var width;
        var height;
        var targetDc = null;
        var Xoffset = 0;
        
        MtbA = new MtbA_functions();
        		
        // We always want to refresh the full screen when we get a regular onUpdate call.
        //fullScreenRefresh = true;

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

    if(inLowPower and canBurnIn) {
        	if (dc has :setAntiAlias) {
        		dc.setAntiAlias(false);
        	}
            
            upTop=!upTop;
            targetDc.clearClip();
            targetDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK); // removing the background color and all the data points from the background, leaving just the hour hands and hashmarks
            targetDc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight()); //width & height?

            // Draw the tick marks around the edges of the screen
            MtbA.drawHashMarks(targetDc, accentColor, Storage.getValue(5), width, height, inLowPower and canBurnIn); //dc

            dc.drawBitmap(0, 0, offscreenBuffer);
    } else {

    	if (dc has :setAntiAlias) {
    		dc.setAntiAlias(true);
    	}

        // Fill the entire background with Black.
        targetDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        targetDc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

        // Draw the tick marks around the edges of the screen
        MtbA.drawHashMarks(targetDc, accentColor, Storage.getValue(5), width, height, inLowPower and canBurnIn); //dc
        
        // Output the offscreen buffers to the main display if required.
        //drawBackground(dc);
        if( null != offscreenBuffer ) {
            dc.drawBitmap(0, 0, offscreenBuffer);
        }

		// Draw the 3, 6, 9, and 12 hour labels.
        if (Storage.getValue(5) == null or Storage.getValue(5) == true) {
            MtbA.drawHourLabels(dc, width, height); 
        }

        if (width==390) { // Venu & D2 Air
			Xoffset = 10;
        } else if (width==416) {
			Xoffset = 13;
		} else if (width==218) {
			Xoffset = 1;
		} else if (width==240 or width==260 or width==280 or width==360) { // Fenix 6S e Vivoactive 3 Music & MARQ Athlete
			Xoffset = 0;
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
		
		
		//Data Points
		var dataPoint = Storage.getValue(12);
        
		// (dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset, dataPoint)
		MtbA.drawRightBottom(dc, width*0.73, height*0.557, width * 0.776, height * 0.57, accentColor, width, Xoffset, dataPoint);
	
		// Xoffset for the 3 left data points: heart rate, steps and floor climb
		if (width==240) { // Fenix 6S & Vivoactive 3 Music & MARQ Athlete
			Xoffset = -2;
		} else if (width==218) { // Vivoactive 4S
			Xoffset = -4;
		} else if (width>=360) { // Venu & D2 Air
			Xoffset = 15;
		}  

		dataPoint = Storage.getValue(9); //(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
		MtbA.drawLeftTop(dc, width/5.3-Xoffset, height/2.988, width/4.127-Xoffset, height/2.86, accentColor, width, dataPoint);
		dataPoint = Storage.getValue(10);
		MtbA.drawLeftMiddle(dc, width/5.3-Xoffset, height/2.222, width/4.127-Xoffset, height / 2.15, accentColor, width, dataPoint);	
		dataPoint = Storage.getValue(11); 
        MtbA.drawLeftBottom(dc, width/5.3-Xoffset, height/1.793, width/4.127-Xoffset, height/1.75, accentColor, width, dataPoint);
		
		// Notifications (dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)	
		//MtbA.drawNotification(dc, width*0.74, height*0.56, width *0.8, height*0.57, accentColor, width, Xoffset);
		//MtbA.drawPrecipitation(dc, width*0.71, height*0.565, width *0.75, height*0.57, width);

		// Draw Battery
		MtbA.drawBatteryIcon(dc, width*0.69, height / 2.1, width*0.82, height / 2.05, width, height, accentColor);
		MtbA.drawBatteryText(dc, width*0.76, height / 2.12 - 1, width);
		
		// Draw the Do Not Disturb Icon
		MtbA.drawDndIcon(dc, width /2.2, height * 0.31, width);        
		
        // Garmin Logo check
        if (Storage.getValue(3) == null or Storage.getValue(3) == true) {
            if (width==218 or width==240){
                MtbA.drawGarminLogo(dc, width / 2 - 47, height / 6); 
            } else {
			    MtbA.drawGarminLogo(dc, width / 2 - 54, height / 6); 
            }
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
 
				
        //Draw the date string
        var offset = 0;
        if (width==218) { // Vivoactive 4S
			offset = -3;
		} else if (width==240) { // Fenix 6S and MARQ
			offset = -2;
		} else if (width==260) { // Vivoactive 4
			offset = 1;
		} else if (width>=360) { // Venu 1 & 2 & 2s
			offset = 13;
        }
        // Garmin Logo check
        if (Storage.getValue(3) == null or Storage.getValue(3) == true) {
            MtbA.drawDateString( dc, width / 2, height * 0.725 + offset );
        } else {
            MtbA.drawDateString( dc, width / 2, height / 5.1 );
        }
    } 

		//Draw Hour and Minute hands
		if (Storage.getValue(13) == null or Storage.getValue(13) == false){
			MtbA.drawHands(dc, width, height, accentColor, false, inLowPower, upTop);
		} else {
			MtbA.drawHands(dc, width, height, accentColor, true, inLowPower, upTop);
		}               
        
        //fullScreenRefresh = false;
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
 /*   function drawBackground(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();

        //If we have an offscreen buffer that has been written to
        //draw it to the screen.
        if( null != offscreenBuffer ) {
            dc.drawBitmap(0, 0, offscreenBuffer);
        }

        // Draw the date
        var offset = 0;
        if (width==218) { // Vivoactive 4S
			offset = -3;
		} else if (width==240) { // Fenix 6S and MARQ
			offset = -2;
		} else if (width==390) { // Venu
			offset = 13;
		} else if (width==260) { // Vivoactive 4
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
    }*/

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }


    // This method is called when the device re-enters sleep mode.
    // Set the isAwake flag to let onUpdate know it should stop rendering the second hand.
    function onEnterSleep() {
//        isAwake = false;
//        WatchUi.requestUpdate();
        inLowPower=true;
    	WatchUi.requestUpdate(); 
    }

    // This method is called when the device exits sleep mode.
    // Set the isAwake flag to let onUpdate know it should render the second hand.
    function onExitSleep() {
//        isAwake = true;
        inLowPower=false;
    	WatchUi.requestUpdate(); 
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