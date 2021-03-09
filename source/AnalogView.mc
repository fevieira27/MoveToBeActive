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
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.Weather as CurrentConditions;
using Toybox.SensorHistory;
using Toybox.UserProfile as User;
using Toybox.Application.Storage;


var partialUpdatesAllowed = false;

// This implements an analog watch face
// Original design by Austen Harbour
class AnalogView extends WatchUi.WatchFace
{
    var font;
    var IconsFont;
    var WeatherFont;
    var screenShape;
    var dndIcon;
	var garminIcon;
    var offscreenBuffer;
    var dateBuffer;
    var screenCenterPoint;
    var fullScreenRefresh;
    var stepsIcon;
    var unit;
    var distStr;
    var batteryIconColour;
	var heartRateIconColour;
	var heartRateZone;
	var heartRate;	
	var batteryState;
	var offset = 0;
	var Xoffset = 0;
	var accentColor = 0x55FF00;

    // Initialize variables for this view
    function initialize() {
        WatchFace.initialize();
        screenShape = System.getDeviceSettings().screenShape;
        fullScreenRefresh = true;
        partialUpdatesAllowed = ( Toybox.WatchUi.WatchFace has :onPartialUpdate );
    }

    // Configure the layout of the watchface for this device
    function onLayout(dc) {
		
		if (Storage.getValue(1) != null) {
			accentColor = Storage.getValue(1);
		}
		
        // Load the custom fonts: used for drawing the 3, 6, 9, and 12 on the watchface and various icons
        font = WatchUi.loadResource(Rez.Fonts.id_font_black_diamond);
        IconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont); 
        WeatherFont = WatchUi.loadResource(Rez.Fonts.WeatherFont);

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
                    //,Graphics.COLOR_BLUE
                    //,Graphics.COLOR_TRANSPARENT
                    //,0xAAFF00 //Vivomove Green
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
                	dc.setColor(accentColor, accentColor);
                } else {
                    if ((Storage.getValue(5) == false) and (i == 0 or i == 30)) {
                        dc.setColor(accentColor, accentColor);
                    } else {
                	    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
                    }
                }            	
            	// thicker lines at 5 min intervals
            	if( (i % 5) == 0) {
                    dc.setPenWidth(3);
                } else {
                    dc.setPenWidth(1);            
                }
                // longer lines at intermediate 5 min marks
                if (Storage.getValue(5) == false) { // if not showing hour labels, then all 5 minute marks will have same length
					if ((i % 5) == 0) {               		
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
				} else if( (i % 5) == 0 && !((i % 15) == 0)) { // when showing hour labels, the marks at each 15 min will be smaller to accomodate labels
						sY = (innerRad-10) * Math.sin(angle);
						eY = outerRad * Math.sin(angle);
						sX = (innerRad-10) * Math.cos(angle);
						eX = outerRad * Math.cos(angle);
					} else {
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
    	dc.setAntiAlias(true);
        var width;
        var height;
        var clockTime = System.getClockTime();
        var stepDistance = ActivityMonitor.getInfo().distance;//.toString();
        var DistanceMetric = System.getDeviceSettings().distanceUnits;
        var TempMetric = System.getDeviceSettings().temperatureUnits;
        var minuteHandAngle;
        var hourHandAngle;
        var battery = Math.ceil(System.getSystemStats().battery);        
        var targetDc = null;
        var floorsCount = null;
        if (ActivityMonitor.getInfo() has :floorsClimbed) {
        	floorsCount = ActivityMonitor.getInfo().floorsClimbed;//.toString();
        }
        var pulseOx = null;
        if (ActivityMonitor.getInfo() has :currentOxygenSaturation) {
        	pulseOx = ActivityMonitor.getInfo().currentOxygenSaturation;
        }
        		
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
			Xoffset = 7;
		} else if (width==240) { // Fenix 6S e Vivoactive 3 Music & MARQ Athlete
			Xoffset = 0;
		}

        // Fill the entire background with Black.
        targetDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        targetDc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
        
        // Draw a grey triangle over the upper right half of the screen.
        //targetDc.fillPolygon([[0, 0], [targetDc.getWidth(), 0], [targetDc.getWidth(), targetDc.getHeight()], [0, 0]]);
                                    

        // Output the offscreen buffers to the main display if required.
        drawBackground(dc);

        if (Storage.getValue(5) == null or Storage.getValue(5) == true) {
            // Draw the 3, 6, 9, and 12 hour labels.
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText((width / 2), 14, font, "12", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width - 13, (height / 2) - 15, font, "3", Graphics.TEXT_JUSTIFY_RIGHT);
            dc.drawText(width / 2, height - 41, font, "6", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(13, (height / 2) - 15, font, "9", Graphics.TEXT_JUSTIFY_LEFT);
        }

		
		//Weather
		if(CurrentConditions has :getCurrentConditions) {
			var weather = CurrentConditions.getCurrentConditions();
			//System.println(CurrentConditions.getCurrentConditions().feelsLikeTemperature);
			//System.println(CurrentConditions.getCurrentConditions().relativeHumidity);
	        //System.println(CurrentConditions.getCurrentConditions().precipitationChance);
			
			offset = 0;
	        if (width==218) { // Vivoactive 4S
				offset = 2;
			} else if (width==240) { // Fenix 6S
				offset = -1;
			} else if (width==280) { // Fenix 6X
				Xoffset = -2;
			} else if (width==260) { // Vivoactive 4
				offset = 4;
			}

	        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
	        if (weather.condition == 20) { // Cloudy
	       		dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "I", Graphics.TEXT_JUSTIFY_RIGHT); // Cloudy
	       	} else if (weather.condition == 0 or weather.condition == 5) { // Clear or Windy
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(width/2.15-Xoffset+offset, height*0.65-29, WeatherFont, "f", Graphics.TEXT_JUSTIFY_RIGHT); // Clear Night	
	       		} else {
	       			dc.drawText(width/2.15-Xoffset+offset, height*0.65-29, WeatherFont, "H", Graphics.TEXT_JUSTIFY_RIGHT); // Clear Day
	       		}
	       	} else if (weather.condition == 1 or weather.condition == 23 or weather.condition == 40 or weather.condition == 52) { // Partly Cloudy or Mostly Clear or fair or thin clouds
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "g", Graphics.TEXT_JUSTIFY_RIGHT); // Partly Cloudy Night
	       		} else {
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "G", Graphics.TEXT_JUSTIFY_RIGHT); // Partly Cloudy Day
	       		}
			} else if (weather.condition == 2 or weather.condition == 22) { // Mostly Cloudy or Partly Clear
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "h", Graphics.TEXT_JUSTIFY_RIGHT); // Mostly Cloudy Night
	       		} else {
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "B", Graphics.TEXT_JUSTIFY_RIGHT); // Mostly Cloudy Day
	       		}
			} else if (weather.condition == 3 or weather.condition == 14 or weather.condition == 15 or weather.condition == 11 or weather.condition == 13 or weather.condition == 24 or weather.condition == 25 or weather.condition == 26 or weather.condition == 27 or weather.condition == 45) { // Rain or Light Rain or heavy rain or showers or unkown or chance  
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "c", Graphics.TEXT_JUSTIFY_RIGHT); // Rain Night
	       		} else {
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "D", Graphics.TEXT_JUSTIFY_RIGHT); // Rain Day
	       		}
			} else if (weather.condition == 4 or weather.condition == 10 or weather.condition == 16 or weather.condition == 17 or weather.condition == 34 or weather.condition == 43 or weather.condition == 46 or weather.condition == 48 or weather.condition == 51) { // Snow or Hail or light or heavy snow or ice or chance or cloudy chance or flurries or ice snow
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "e", Graphics.TEXT_JUSTIFY_RIGHT); // Snow Night
	       		} else {
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "F", Graphics.TEXT_JUSTIFY_RIGHT); // Snow Day
	       		}
			} else if (weather.condition == 6 or weather.condition == 12 or weather.condition == 28 or weather.condition == 32 or weather.condition == 36 or weather.condition == 41 or weather.condition == 42) { // Thunder or scattered or chance or tornado or squall or hurricane or tropical storm
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "b", Graphics.TEXT_JUSTIFY_RIGHT); // Thunder Night
	       		} else {
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "C", Graphics.TEXT_JUSTIFY_RIGHT); // Thunder Day
	       		}
			} else if (weather.condition == 7 or weather.condition == 18 or weather.condition == 19 or weather.condition == 21 or weather.condition == 44 or weather.condition == 47 or weather.condition == 49 or weather.condition == 50) { // Wintry Mix (Snow and Rain) or chance or cloudy chance or freezing rain or sleet
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "d", Graphics.TEXT_JUSTIFY_RIGHT); // Snow+Rain Night
	       		} else {
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "E", Graphics.TEXT_JUSTIFY_RIGHT); // Snow+Rain Day
	       		}
			} else if (weather.condition == 8 or weather.condition == 9 or weather.condition == 29 or weather.condition == 30 or weather.condition == 31 or weather.condition == 33 or weather.condition == 35 or weather.condition == 37 or weather.condition == 38 or weather.condition == 39) { // Fog or Hazy or Mist or Dust or Drizzle or Smoke or Sand or sandstorm or ash or haze
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "a", Graphics.TEXT_JUSTIFY_RIGHT); // Fog Night
	       		} else {
	       			dc.drawText(width/2.1-Xoffset+offset, height*0.65-29, WeatherFont, "A", Graphics.TEXT_JUSTIFY_RIGHT); // Fog Day
	       		}       		
	        }
	        
			if (Storage.getValue(6) == null or Storage.getValue(6) == true) {
				if(weather has :temperature) {
					if (TempMetric == System.UNIT_METRIC) { 
						dc.drawText(width/2.05-Xoffset+offset, height*0.57, Graphics.FONT_XTINY, weather.temperature+"°C", Graphics.TEXT_JUSTIFY_LEFT);
					}
					else {
						var fahrenheit = (weather.temperature * 9/5) + 32; 
						fahrenheit = Lang.format("$1$", [fahrenheit.format("%d")] );
						dc.drawText(width/2.05-Xoffset+offset, height*0.57, Graphics.FONT_XTINY, fahrenheit +"°F", Graphics.TEXT_JUSTIFY_LEFT);
					}
					//dc.drawText(width/2 - 15, height*0.58, IconsFont, "<", Graphics.TEXT_JUSTIFY_CENTER); // Using Font;
				}
			} else { // Feels like setting selected
				if(weather has :feelsLikeTemperature) {
					if (TempMetric == System.UNIT_METRIC) { 
						dc.drawText(width/2.05-Xoffset+offset, height*0.57, Graphics.FONT_XTINY, weather.feelsLikeTemperature+"°C", Graphics.TEXT_JUSTIFY_LEFT);
					}
					else {
						var fahrenheit = (weather.feelsLikeTemperature * 9/5) + 32; 
						fahrenheit = Lang.format("$1$", [fahrenheit.format("%d")] );
						dc.drawText(width/2.05-Xoffset+offset, height*0.57, Graphics.FONT_XTINY, fahrenheit +"°F", Graphics.TEXT_JUSTIFY_LEFT);
					}
				}
			}

			if (Storage.getValue(7) == null or Storage.getValue(7) == true) {
				if(weather has :observationLocationName) {
					var location = weather.observationLocationName;
					if (location.length()>15 and location.find(",")!=null){
						location = location.substring(0,location.find(","));
					}
			        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
					//dc.fitTextToArea(text, font, width, height, truncate)
					dc.drawText(width/2, height*0.65, Graphics.FONT_XTINY, dc.fitTextToArea(location, Graphics.FONT_XTINY, width*0.60, height*0.10, true), Graphics.TEXT_JUSTIFY_CENTER);
				}		        
		    }		
		}	
		
		
		// Notifications	
       	offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 10;	
		} else if (width==280) { // Enduro & Fenix 6X
			offset = 1;	
			Xoffset = 0;
		} else if (width==218) { // Vivoactive 4S & Fenix 6S
			offset = -1;	
		} else if (width==240) { // Vivoactive 3 Music & MARQ Athlete
			offset = 2;
		} else if (width==260) { // Vivoactive 4
			Xoffset = 0;
		}
       
       	var formattedNotificationAmount = "";
       	var notificationAmount;      
       
        if (System.getDeviceSettings() has :notificationCount) {
	        notificationAmount = System.getDeviceSettings().notificationCount;
	    	if(notificationAmount > 20)	{
				formattedNotificationAmount = "20+";
			}
			else {
				formattedNotificationAmount = notificationAmount.format("%d");
			}
		}
		if (System.getDeviceSettings() has :notificationCount) {
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText( width *0.8 - Xoffset, height * 0.572 , Graphics.FONT_XTINY, formattedNotificationAmount, Graphics.TEXT_JUSTIFY_LEFT);
			if (formattedNotificationAmount.toNumber() == 0){
				dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
			} else {
				dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
			}
			dc.drawText( width *0.74 + offset/2 - Xoffset, height * 0.56 + offset, IconsFont, "5", Graphics.TEXT_JUSTIFY_CENTER);
		}
		
		
		// X offset for left "bar": hear rate, steps and floor climb
		if (width==390) { // Venu & D2 Air
			Xoffset = 22;
		} else if (width==240) { // Fenix 6S e Vivoactive 3 Music & MARQ Athlete
			Xoffset = 5;
		} else if (width==280) { // Fenix 6X e Enduro
			Xoffset = 5;
		} else if (width==260) { // Fenix 6X e Enduro
			Xoffset = 5;
		}
		
		// Get heart rate
    	if(ActivityMonitor has :getHeartRateHistory) {
    		heartRate = Activity.getActivityInfo().currentHeartRate; 
    		if(heartRate==null) {
    			var HRH=ActivityMonitor.getHeartRateHistory(1, true);
				var HRS=HRH.next();
				if(HRS!=null && HRS.heartRate!= ActivityMonitor.INVALID_HR_SAMPLE){
					heartRate = HRS.heartRate;
				}
    		}
	    	if(heartRate==null) {
				heartRate = 0;
			}
		} else {
			heartRate = 0;
		}

		// Render heart rate text
		var heartRateText;
		if (heartRate == 0) {
			heartRateText="0";
		} else {
			heartRateText=heartRate.format("%d");
		}


		// Heart rate zones color definition (values for each zone are automatically calculated by Garmin)	
		var autoZones = User.getHeartRateZones(User.getCurrentSport());
		heartRateZone = 0;
		if (heartRate >= autoZones[5]) { // 185
			heartRateZone = 7;
		} else if (heartRate >= autoZones[4]) { // 167
			heartRateZone = 6;
		} else if (heartRate >= autoZones[3]) { // 148
			heartRateZone = 5;
		} else if (heartRate >= autoZones[2]) { // 130
			heartRateZone = 4;
		} else if (heartRate >= autoZones[1]) { // 111
			heartRateZone = 3;
		} else if (heartRate >= autoZones[0]) { // 93
			heartRateZone = 2;
		} else {  
			heartRateZone = 1;
		}
		
		// Choose the colour of the heart rate icon based on heart rate zone
		if (heartRateZone == 0) { // No default zones detected
			if (heartRate >= 185) {
				heartRateZone = 7;
			} else if (heartRate >= 167) {
				heartRateZone = 6;
			} else if (heartRate >= 148) {
				heartRateZone = 5;
			} else if (heartRate >= 130) {
				heartRateZone = 4;
			} else if (heartRate >= 111) {
				heartRateZone = 3;
			} else if (heartRate >= 93) {
				heartRateZone = 2;
			} else if (heartRate > 0) {
				heartRateZone = 1;
			} else {
				heartRateIconColour = Graphics.COLOR_DK_GRAY; //No heart rate detected
			} 
		} 
		
		if (heartRateZone == 1) { // Resting / Light load
			heartRateIconColour = Graphics.COLOR_LT_GRAY;
		} else if (heartRateZone == 2) { // Moderate Effort
			heartRateIconColour = Graphics.COLOR_BLUE;
		} else if (heartRateZone == 3) { // Weight Control
			if (accentColor == 0xAAFF00) {
				heartRateIconColour = 0xAAFF00; /* Vivomove GREEN */
			} else {
				heartRateIconColour = 0x55FF00; /* GREEN */
			}
		} else if (heartRateZone == 4) { // Aerobic
			heartRateIconColour = 0xFFFF00; /* yellow */
		} else if (heartRateZone == 5) { // Anaerobic
			heartRateIconColour = 0xFFAA00; /* orange */
		} else if (heartRateZone == 6){ // Maximum effort
			heartRateIconColour = 0xFF5555; /* pastel red */
 		} else if (heartRateZone == 7){ // Speed
			heartRateIconColour = 0xFF0000; /* bright red */
		}
				
			
		// Render heart rate icon and text
		offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 6;	
		}
		
		var hrIconY = height/2.9;
		var hrIconWidth = 17;
		dc.setColor(heartRateIconColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText( width / 4.7 - Xoffset , hrIconY - 1 + offset , IconsFont, "3", Graphics.TEXT_JUSTIFY_CENTER); // Using Icon
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(width / 3.65 - offset - Xoffset, hrIconY + (hrIconWidth / 2) -6 , Graphics.FONT_XTINY, heartRateText, Graphics.TEXT_JUSTIFY_LEFT);		


        // Choose the colour of the battery based on it's state
        if (battery > 30) {
			batteryState=0;
		} else if (battery <= 15) {
			batteryState=1;
		} else if (battery <= 30) {
			batteryState=2;
		} else {
			batteryState=3;
		}
		
		if (batteryState == 0) {
			if (accentColor == 0xAAFF00) {
				batteryIconColour = 0xAAFF00; /* Vivomove GREEN */
			} else {
				batteryIconColour = 0x55FF00; /* GREEN */
			}
		} else if (batteryState == 1) {
			batteryIconColour = 0xFF5555 /* pastel red */;
		} else if (batteryState == 2) {
			batteryIconColour = 0xFFFF55 /* pastel yellow */;
		} else {
			batteryIconColour = Graphics.COLOR_LT_GRAY ; // Not detected
		}
        
        // Render battery icon
		offset = 0;
		if (width==218) { // Vivoactive 4S
			offset = 1;	
		} else if (width==280) { //Enduro & Fenix 6X Pro
			offset = -1;
		}
		dc.setColor(batteryIconColour, Graphics.COLOR_TRANSPARENT); 
		//dc.fillRoundedRectangle(x, y, width, height, radius)
		dc.fillRoundedRectangle(width*0.69, height / 2.1 , width*0.135 /* batteryWidth */, height*0.0625 /* batteryHeight */, 2);
		dc.fillRoundedRectangle(width*0.82, height / 2.05 , width*0.018 /* batteryWidth */, height*0.039 - offset /* batteryHeight */, 2);
		offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = -2;	
		} else if (width==280) { // Enduro & Fenix 6X Pro
			offset = 0.75;	
		}  else if (width==218 or width==240) { // Vivoactive 4S & Fenix 6S & Vivoactive 3 Music
			offset = -0.5;	
		} 
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.drawText(width*0.76, height / 2.12 - 1 + offset , Graphics.FONT_XTINY /* batteryFont */,battery.format("%d") + "%", Graphics.TEXT_JUSTIFY_CENTER ); // Correct battery text on Fenix 5 series (except 5s)
		
        // If this device supports the Do Not Disturb feature,
        // load the associated Icon into memory.
        if (System.getDeviceSettings() has :doNotDisturb) {
            dndIcon = WatchUi.loadResource(Rez.Drawables.DoNotDisturbIcon);
        } else {
            dndIcon = null;
        }
        // Draw the do-not-disturb icon if we support it and the setting is enabled
        offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		} 
        if (null != dndIcon && System.getDeviceSettings().doNotDisturb) {
            dc.drawBitmap( width /2.2 + offset, height * 0.31 , dndIcon);
        }
        
		
        // Garmin Logo -- Create script to remove logo from Fenix 5 series (except 5 Plus and 5x Plus) and Forerunner Series
        if (Storage.getValue(3) == null or Storage.getValue(3) == true) {
			garminIcon = WatchUi.loadResource(Rez.Drawables.GarminLogo);
        	dc.drawBitmap( width / 2 - 50, height / 6 , garminIcon);
		}
                
        
		//Bluetooth icon
        if (Storage.getValue(4) == null or Storage.getValue(4) == true) {
            offset = 0;
            if (width==218) { // Vivoactive 4S & Fenix 6S
                offset = -5;	
            } else if (width==390) { // Venu & D2 Air
                offset = 9;	
            }
                    
            var settings = System.getDeviceSettings().phoneConnected; // maybe .connectionAvailable or .ConnectionInfo.state ?
            if (settings) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawText( width*0.7+14 + offset, height / 2.9 + offset, IconsFont, "8", Graphics.TEXT_JUSTIFY_CENTER);
        }

  
        //Floors Climbed
        offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		}
        
        if (pulseOx!= null) {
        	// Change the colour of the pulse Ox icon based on current value
			if (pulseOx >= 95) { // Normal
				if (accentColor == 0xAAFF00) {
					dc.setColor(0xAAFF00, Graphics.COLOR_TRANSPARENT); /* Vivomove GREEN */
				} else {
					dc.setColor(0x55FF00, Graphics.COLOR_TRANSPARENT); /* GREEN */
				}
			} else if (pulseOx >= 85) { // Between Normal and Brain being affected
				dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT); /* Blue */
			} else if (pulseOx >= 80) { // Brain affected
				dc.setColor(0xFFFF55, Graphics.COLOR_TRANSPARENT); /* pastel yellow */
			} else if (pulseOx >= 66) { // Between brain affected and cyanosis
				dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT); /* orange */
			} else { // Cyanosis
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT); /* red */
			}
        	dc.drawText( width / 4.7 - Xoffset, height * 0.565 + offset , IconsFont, "@", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
        	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        	dc.drawText( width / 3.75 - offset - Xoffset, height * 0.572 , Graphics.FONT_XTINY, Lang.format("$1$%", [pulseOx.format("%.0f")] ), Graphics.TEXT_JUSTIFY_LEFT);
        } else if (ActivityMonitor.getInfo() has :floorsClimbed) {
        	if (floorsCount>=ActivityMonitor.getInfo().floorsClimbedGoal) {
        		dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        	} else {
            	dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            }
        	dc.drawText( width / 4.7 - Xoffset, height * 0.565 + offset , IconsFont, "1", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
        	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        	dc.drawText( width / 3.65 - offset - Xoffset, height * 0.572 , Graphics.FONT_XTINY, floorsCount, Graphics.TEXT_JUSTIFY_LEFT);
        }
        
        //Steps Icon
        offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		}
        
        if (ActivityMonitor.getInfo().steps>=ActivityMonitor.getInfo().stepGoal) {
        	dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        } else {
           	dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        } 
        dc.drawText( width / 4.6 - Xoffset, height / 2.25 + offset, IconsFont, "0", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
        
        // Steps Distance Text	
		if (stepDistance != null) {
        	if (DistanceMetric == System.UNIT_METRIC) {
        		unit = " km";
        		stepDistance = stepDistance * 0.00001;
        	} else{
        		unit = " mi";
        		stepDistance = stepDistance * 0.00001 * 0.621371;
        	}
        } else {
        	unit = "?";
        }
        
        if (stepDistance >= 10) {
        	distStr = Lang.format("$1$", [stepDistance.format("%.0f")] );
        } else { //(stepDistance <10)
        	distStr = Lang.format("$1$", [stepDistance.format("%.1f")] );
        }
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 3.75 - offset - Xoffset, height / 2.18, Graphics.FONT_XTINY, distStr + unit, Graphics.TEXT_JUSTIFY_LEFT); // Step Distance


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
        
        // Correct widths and lengths depending on resolution
        var offsetWidth = 0;
        var offsetLength = 0;
        var offsetLengthAccent = 0;
        
        if (width == 240) { // MARQ
        	offsetWidth = 0.005;
        	offsetLength = 0.05;
        } else if (width == 280) { // Fenix 6X
        	offsetWidth = 0.005;
        	offsetLength = 0.05;
        	offsetLengthAccent = 0.01;
        } else if (width == 390) { // Venu
        	offsetLength = 0.03;
        	offsetLengthAccent = 0.01;
        }

        //Use white to draw the hour hand, with a dark grey background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        //generateHandCoordinates(centerPoint, angle, handLength, tailLength, width) -- width / (higher means smaller)
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 3.4, 0, width*(0.055 - offsetWidth))); 
		dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 3.45, 0, width*0.045));
        //dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        //dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 4 + 0.75 , 0, 7.25));        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / (3.53 - offsetLength) , 0, width*0.035));

        // Draw the minute hand.
        minuteHandAngle = (clockTime.min / 60.0) * Math.PI * 2;
        //generateHandCoordinates(centerPoint, angle, handLength, tailLength, width) -- width / (higher means smaller)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2.19, 0, width*(0.055 - offsetWidth)));
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2.22, 0, width*0.045));
        //dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        //dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2 - 20.25, 0, 7.06));
        dc.setColor(accentColor, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / (2.25 - offsetLengthAccent) , 0, width*0.035));

	    		        
        // Draw the arbor in the center of the screen.
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillCircle(width / 2, height / 2, width*0.03);
        dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
        dc.drawCircle(width / 2, height / 2, width*0.03);
        
        fullScreenRefresh = false;
    }
    
    // Draw the date string into the provided buffer at the specified location
    function drawDateString( dc, x, y ) {
        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var dateStr = Lang.format("$1$, $2$ $3$", [info.day_of_week, info.month, info.day]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
       	dc.drawText(x, y, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);
        
    }
      

    // Handle the partial update event
    //function onPartialUpdate( dc ) {
        // If we're not doing a full screen refresh we need to re-draw the background
        // before drawing the updated second hand position. Note this will only re-draw
        // the background in the area specified by the previously computed clipping region.
    //}


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
            dc.drawBitmap(0, (height * 0.725) + offset, dateBuffer );
        } else {
            // Otherwise, draw it from scratch. drawDateString( dc, x, y )
            drawDateString( dc, width / 2, height * 0.725 + offset );
            
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
