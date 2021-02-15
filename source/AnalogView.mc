//
// Copyright 2016-2017 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.ActivityMonitor;

var partialUpdatesAllowed = false;

// This implements an analog watch face
// Original design by Austen Harbour
class AnalogView extends WatchUi.WatchFace
{
    var font;
    //var isAwake;
    var screenShape;
    var dndIcon;
	var garminIcon;
    var offscreenBuffer;
    var dateBuffer;
    //var curClip;
    var screenCenterPoint;
    var fullScreenRefresh;
    var batteryIconColour;
	var batteryTextColour;
	var heartRateIconColour;
	var heartRateZoneTextColour;
	var heartRateZone;

    // Initialize variables for this view
    function initialize() {
        WatchFace.initialize();
        screenShape = System.getDeviceSettings().screenShape;
        fullScreenRefresh = true;
        partialUpdatesAllowed = ( Toybox.WatchUi.WatchFace has :onPartialUpdate );
    }

    // Configure the layout of the watchface for this device
    function onLayout(dc) {

        // Load the custom font we use for drawing the 3, 6, 9, and 12 on the watchface.
        font = WatchUi.loadResource(Rez.Fonts.id_font_black_diamond);

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
                    Graphics.COLOR_WHITE,
                    Graphics.COLOR_BLUE,
                    Graphics.COLOR_TRANSPARENT,
                    0xAAFF00 //Vivomove Green
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

        //curClip = null;

        screenCenterPoint = [dc.getWidth()/2, dc.getHeight()/2];
    }

    // This function is used to generate the coordinates of the 4 corners of the polygon
    // used to draw a watch hand. The coordinates are generated with specified length,
    // tail length, and width and rotated around the center point at the provided angle.
    // 0 degrees is at the 12 o'clock position, and increases in the clockwise direction.
    function generateHandCoordinates(centerPoint, angle, handLength, tailLength, width) {
        // Map out the coordinates of the watch hand
        var coords = [[-(width / 2), tailLength], [-(width / 2), -handLength], [width / 2, -handLength], [width / 2, tailLength]];
        var result = new [4];
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i += 1) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
            var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;

            result[i] = [centerPoint[0] + x, centerPoint[1] + y];
        }

        return result;
    }

    // Draws the clock tick marks around the outside edges of the screen.
    function drawHashMarks(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Draw hashmarks differently depending on screen geometry.
        if (System.SCREEN_SHAPE_ROUND == screenShape) {
            var sX, sY;
            var eX, eY;
            var outerRad = width / 2;
            var innerRad = outerRad - 10;
            
            // Loop through each minute and draw tick marks
            for (var i = 0; i <= 59; i += 1) {
            	var angle = i * Math.PI / 30;
                if ((i == 15) or (i == 45)) {
                	dc.setColor(0xAAFF00, 0xAAFF00);
                }
                else {
                	dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
                }            	
            	// thicker lines at 5 min intervals
            	if( (i % 5) == 0) {
                    dc.setPenWidth(3);
                }
                else {
                    dc.setPenWidth(1);            
                }
                // longer lines at intermediate 5 min marks
                if( (i % 5) == 0 && !((i % 15) == 0)) {               		
            		sY = (innerRad-10) * Math.sin(angle);
                	eY = outerRad * Math.sin(angle);
                	sX = (innerRad-10) * Math.cos(angle);
                	eX = outerRad * Math.cos(angle);
                }
                else {
                	sY = innerRad * Math.sin(angle);
                	eY = outerRad * Math.sin(angle);
                	sX = innerRad * Math.cos(angle);
                	eX = outerRad * Math.cos(angle);
            	}
            	
            	sX += outerRad; sY += outerRad;
                eX += outerRad; eY += outerRad;
                dc.drawLine(sX, sY, eX, eY);

            }
        } else {
            var coords = [0, width / 4, (3 * width) / 4, width];
            for (var i = 0; i < coords.size(); i += 1) {
                var dx = ((width / 2.0) - coords[i]) / (height / 2.0);
                var upperX = coords[i] + (dx * 10);
                // Draw the upper hash marks.
                dc.fillPolygon([[coords[i] - 1, 2], [upperX - 1, 12], [upperX + 1, 12], [coords[i] + 1, 2]]);
                // Draw the lower hash marks.
                dc.fillPolygon([[coords[i] - 1, height-2], [upperX - 1, height - 12], [upperX + 1, height - 12], [coords[i] + 1, height - 2]]);
            }
        }
    }

    // Handle the update event
    function onUpdate(dc) {
        var width;
        var height;
        var clockTime = System.getClockTime();
        var minuteHandAngle;
        var hourHandAngle;
        //var secondHand;
        var targetDc = null;

        // We always want to refresh the full screen when we get a regular onUpdate call.
        fullScreenRefresh = true;

        if(null != offscreenBuffer) {
            dc.clearClip();
            //curClip = null;
            // If we have an offscreen buffer that we are using to draw the background,
            // set the draw context of that buffer as our target.
            targetDc = offscreenBuffer.getDc();
        } else {
            targetDc = dc;
        }

        width = targetDc.getWidth();
        height = targetDc.getHeight();

        // Fill the entire background with Black.
        targetDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        targetDc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
        
        // Draw a grey triangle over the upper right half of the screen.
        //targetDc.fillPolygon([[0, 0], [targetDc.getWidth(), 0], [targetDc.getWidth(), targetDc.getHeight()], [0, 0]]);
                                    
		// Draw the 3, 6, 9, and 12 hour labels.
		targetDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		targetDc.drawText((width / 2), 14, font, "12", Graphics.TEXT_JUSTIFY_CENTER);
		targetDc.drawText(width - 13, (height / 2) - 15, font, "3", Graphics.TEXT_JUSTIFY_RIGHT);
		targetDc.drawText(width / 2, height - 41, font, "6", Graphics.TEXT_JUSTIFY_CENTER);
		targetDc.drawText(13, (height / 2) - 15, font, "9", Graphics.TEXT_JUSTIFY_LEFT);
        

        // Output the offscreen buffers to the main display if required.
        drawBackground(dc);

		
		// Get heart rate
		var heartRate;
    	if(ActivityMonitor has :INVALID_HR_SAMPLE) {
    		heartRate = retrieveHeartrateText();
    	}
    	else {
    		heartRate = 0;
    	}
		

		// Render heart rate text
		var heartRateText;
		if (heartRate == 0) {
			heartRateText="0";
		} else {
			heartRateText=heartRate.format("%d");
		}
		//dc.drawText(width/4, height/2 /* heartRateTextY */, Graphics.FONT_XTINY /* heartRateFont */, heartRateText, Graphics.TEXT_JUSTIFY_CENTER );

		// Heart rate zones definition
		heartRateZone = 0;
		if (heartRate >= 162) {
			heartRateZone = 5;
		} else if (heartRate >= 138) {
			heartRateZone = 4;
		} else if (heartRate >= 114) {
			heartRateZone = 3;
		} else if (heartRate >= 90) {
			heartRateZone = 2;
		} else {
			heartRateZone = 1;
		}
		
		// Choose the colour of the heart rate icon based on heart rate zone
		heartRateZoneTextColour = Graphics.COLOR_WHITE;
		if (heartRateZone == 0) {
			heartRateIconColour = Graphics.COLOR_LT_GRAY;
		} else if (heartRateZone == 1) {
			heartRateIconColour = Graphics.COLOR_DK_GRAY;
		} else if (heartRateZone == 2) {
			heartRateIconColour = Graphics.COLOR_BLUE;
		} else if (heartRateZone == 3) {
			heartRateIconColour = 0xAAFF00; /* Vivomove GREEN */
		} else if (heartRateZone == 4) {
			heartRateIconColour = 0xFFFF55; /* pastel yellow */
		} else if (heartRateZone == 5){
			heartRateIconColour = 0xFF5555; /* pastel red */
		}

		
		// Render heart rate icon
		var hrIconY = height/2-17;
		var hrIconWidth = 20;
		var hrIconXOffset = height/2;
		dc.setColor(heartRateIconColour, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(width/4 - (hrIconWidth / 4.7), hrIconY + (hrIconWidth / 3.2), hrIconWidth / 3.2);
		dc.fillCircle(width/4 + (hrIconWidth / 4.7), hrIconY + (hrIconWidth / 3.2), hrIconWidth / 3.2);
		dc.fillPolygon([
			[width/4 - (hrIconWidth / 2.2), hrIconY + (hrIconWidth / 1.8) - 1],
			[width/4, hrIconY + (hrIconWidth * 0.95)],
			[width/4 + (hrIconWidth / 2.2), hrIconY + (hrIconWidth / 1.8) - 1]
		]);
		
		dc.setColor(heartRateZoneTextColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(width/4, hrIconY + (hrIconWidth / 2) + 7, Graphics.FONT_XTINY, heartRateText, Graphics.TEXT_JUSTIFY_CENTER);


        // Choose the colour of the battery based on it's state
		var battery = System.getSystemStats().battery; //System.getSystemStats().battery.toLong()
		var batteryState;
		
		if (battery >= 50) {
			batteryState=0;
		} else if (battery <= 10) {
			batteryState=1;
		} else if (battery <= 20) {
			batteryState=2;
		} else {
			batteryState=3;
		}

		batteryTextColour = Graphics.COLOR_BLACK;
		if (batteryState == 0) {
			batteryIconColour = 0xAAFF00 /* Vivomove GREEN */;
		} else if (batteryState == 1) {
			batteryIconColour = 0xFF5555 /* pastel red */;
		} else if (batteryState == 2) {
			batteryIconColour = 0xFFFF55 /* pastel yellow */;
		} else {
			batteryIconColour = Graphics.COLOR_DK_GRAY ; 
		}
        
        // Render battery
		dc.setColor(batteryIconColour, Graphics.COLOR_TRANSPARENT); //dc.fillRoundedRectangle(x, y, width, height, radius)
		dc.fillRoundedRectangle(width*0.7-3, (height / 2)-8 , 35 /* batteryWidth */, 16 /* batteryHeight */, 2);
		dc.fillRoundedRectangle(width*0.7+ 31, (height / 2)-5 , 4 /* batteryWidth */, 10 /* batteryHeight */, 2);
		dc.setColor(batteryTextColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(width*0.7+14, (height / 2)-10, Graphics.FONT_XTINY /* batteryFont */,battery.format("%d") + "%", Graphics.TEXT_JUSTIFY_CENTER );

        // If this device supports the Do Not Disturb feature,
        // load the associated Icon into memory.
        if (System.getDeviceSettings() has :doNotDisturb) {
            dndIcon = WatchUi.loadResource(Rez.Drawables.DoNotDisturbIcon);
        } else {
            dndIcon = null;
        }
        
        garminIcon = WatchUi.loadResource(Rez.Drawables.GarminLogo);
        dc.drawBitmap( width / 2 - 50, height / 5 , garminIcon);
        
        // Draw the do-not-disturb icon if we support it and the setting is enabled
        if (null != dndIcon && System.getDeviceSettings().doNotDisturb) {
            dc.drawBitmap( width /2 - 15, height /3, dndIcon);
        }

        // If we have an offscreen buffer that we are using for the date string,
        // Draw the date into it. If we do not, the date will get drawn every update
        // after blanking the second hand.
        if( null != dateBuffer ) {
            var dateDc = dateBuffer.getDc();

            //Draw the background image buffer into the date buffer to set the background
            dateDc.drawBitmap(0, -(height / 4), offscreenBuffer);

            //Draw the date string into the buffer.
            drawDateString( dateDc, width / 2, 0 );

		    // Draw the tick marks around the edges of the screen
		    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
		    drawHashMarks(dc);
		            
            //drawBatt( dc, width, height);
        }

        // Calculate the hour hand. Convert it to minutes and compute the angle.
        hourHandAngle = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHandAngle = hourHandAngle / (12 * 60.0);
        hourHandAngle = hourHandAngle * Math.PI * 2;

        //Use white to draw the hour hand, with a dark grey background
		dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 4 + 5, 0, 10));
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 4 + 1, 0, 5));
        
        // Draw the minute hand.
        minuteHandAngle = (clockTime.min / 60.0) * Math.PI * 2;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2 - 18, 0, 10));
        dc.setColor(0xAAFF00, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2 - 22, 0, 5));
        
        // Draw the arbor in the center of the screen.
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillCircle(width / 2, height / 2, 7);
        dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
        dc.drawCircle(width / 2, height / 2, 7);
        
//        if( partialUpdatesAllowed ) {
            // If this device supports partial updates and they are currently
            // allowed run the onPartialUpdate method to draw the second hand.
            //onPartialUpdate( dc );
//        } else if ( isAwake ) {
            // Otherwise, if we are out of sleep mode, draw the second hand
            // directly in the full update method.
            //dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            //secondHand = (clockTime.sec / 60.0) * Math.PI * 2;

            //dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHand, 60, 20, 2));
//        }


        fullScreenRefresh = false;
    }
    
    // Draw the date string into the provided buffer at the specified location
    function drawDateString( dc, x, y ) {
        var info = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var dateStr = Lang.format("$1$, $2$ $3$", [info.day_of_week, info.month, info.day]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);
    }
    
       
    function retrieveHeartrateText() {
    	var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, false);
    	var currentHeartrate = heartrateIterator.next().heartRate;
    	
    	if(currentHeartrate == ActivityMonitor.INVALID_HR_SAMPLE) {
			return "";
		}
	
		return currentHeartrate;
    }
    
    

    // Handle the partial update event
    //function onPartialUpdate( dc ) {
        // If we're not doing a full screen refresh we need to re-draw the background
        // before drawing the updated second hand position. Note this will only re-draw
        // the background in the area specified by the previously computed clipping region.
      //  if(!fullScreenRefresh) {
        //    drawBackground(dc);
        //}

        //var clockTime = System.getClockTime();
        //var secondHand = (clockTime.sec / 60.0) * Math.PI * 2;
        //var secondHandPoints = generateHandCoordinates(screenCenterPoint, secondHand, 60, 20, 2);

        // Update the cliping rectangle to the new location of the second hand.
        //curClip = getBoundingBox( secondHandPoints );
        //var bboxWidth = curClip[1][0] - curClip[0][0] + 1;
        //var bboxHeight = curClip[1][1] - curClip[0][1] + 1;
        //dc.setClip(curClip[0][0], curClip[0][1], bboxWidth, bboxHeight);

        // Draw the second hand to the screen.
        //dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        //dc.fillPolygon(secondHandPoints);
    //}

    // Compute a bounding box from the passed in points
    function getBoundingBox( points ) {
        var min = [9999,9999];
        var max = [0,0];

        for (var i = 0; i < points.size(); ++i) {
            if(points[i][0] < min[0]) {
                min[0] = points[i][0];
            }

            if(points[i][1] < min[1]) {
                min[1] = points[i][1];
            }

            if(points[i][0] > max[0]) {
                max[0] = points[i][0];
            }

            if(points[i][1] > max[1]) {
                max[1] = points[i][1];
            }
        }

        return [min, max];
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
        if( null != dateBuffer ) {
            // If the date is saved in a Buffered Bitmap, just copy it from there.
            dc.drawBitmap(0, (height * 0.65), dateBuffer );
        } else {
            // Otherwise, draw it from scratch.
            drawDateString( dc, width / 2, height * 0.65 );
            
		    // Draw the tick marks around the edges of the screen
		    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
		    drawHashMarks(dc);
		          
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
