// All functions used to draw data points and icons in the watch face

using Toybox.System;
using Toybox.WatchUi;
using Toybox.Weather as CurrentConditions;
using Toybox.ActivityMonitor;
using Toybox.UserProfile as User;
using Toybox.Activity;
using Toybox.Math;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Application.Storage;


class MtbA_functions {
	
    const IconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
	
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
	
    /* ------------------------ */
	
	// Draws the clock tick marks around the outside edges of the screen.
    function drawHashMarks(dc, accentColor, showBoolean, width, height) {
		var screenShape = System.getDeviceSettings().screenShape;
		
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
                    if ((showBoolean == false) and (i == 0 or i == 30)) {
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
                if (showBoolean == false) { // if not showing hour labels, then all 5 minute marks will have same length
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
    
    /* ------------------------ */
    
    // Draw the date string into the provided buffer at the specified location
    function drawDateString( dc, x, y ) {
        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var dateStr = Lang.format("$1$, $2$ $3$", [info.day_of_week, info.month, info.day]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
       	dc.drawText(x, y, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);   
    }
    
    /* ------------------------ */	
    
    // Draw the Bluetooth Icon
    function drawBluetoothIcon(dc, x, y) {
    	var offset = 0;
    	var Xoffset = 0;
        if (dc.getWidth()==218) { // Vivoactive 4S & Fenix 6S
			offset = 2;	
        } else if (dc.getWidth()==390) { // Venu & D2 Air
            offset = -2;
            //Xoffset = 0;
        }
                
        var settings = System.getDeviceSettings().phoneConnected; // maybe .connectionAvailable or .ConnectionInfo.state ?
        if (settings) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText( x - offset + Xoffset, y - offset, IconsFont, "8", Graphics.TEXT_JUSTIFY_CENTER);
    }

    /* ------------------------ */	
    
    // Draw the Alarm Icon
	function drawAlarmIcon(dc, x, y, accentColor, width) {
		var offset = 0;
		var LEDoffset = 0;
        if (width==218) { // Vivoactive 4S & Fenix 6S
            offset = 2;	
        } else if (width==390) { // Venu & D2 Air
            offset = -2;
            LEDoffset = 2;
        }
        
        var settings = System.getDeviceSettings().alarmCount;
        if (settings>0) {
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText( x - offset - LEDoffset, y - offset, IconsFont, ":", Graphics.TEXT_JUSTIFY_CENTER); 
    }
	
	/* ------------------------ */	
	
	// Draw the 3, 6, 9, and 12 hour labels.
    function drawHourLabels(dc, width, height) {
    	// Load the custom fonts: used for drawing the 3, 6, 9, and 12 on the watchface
        var font = WatchUi.loadResource(Rez.Fonts.id_font_black_diamond); 
    	
	    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);  
        dc.drawText((width / 2), 14, font, "12", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width - 13, (height / 2) - 15, font, "3", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width / 2, height - 41, font, "6", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(13, (height / 2) - 15, font, "9", Graphics.TEXT_JUSTIFY_LEFT);
    }
    
	/* ------------------------ */
	
	function drawWeatherIcon(dc, x, y, x2, width) {
		var clockTime = System.getClockTime();
		var WeatherFont = WatchUi.loadResource(Rez.Fonts.WeatherFont);
		
		if(CurrentConditions has :getCurrentConditions and CurrentConditions.getCurrentConditions() != null) {
			var weather = CurrentConditions.getCurrentConditions();
	        
			var offset = 0;
			var LEDoffset = 0;
	        if (width==218) { // Vivoactive 4S
				offset = 3;				
			} else if (width==240) { // Fenix 6S & MARQ Athlete
				offset = 1;
			} else if (width==390) { // Venu
				LEDoffset = 15;
			}

	        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
	        if (weather.condition == 20) { // Cloudy
	       		dc.drawText(x2-1+(offset*1.5), y, WeatherFont, "I", Graphics.TEXT_JUSTIFY_RIGHT); // Cloudy
	       	} else if (weather.condition == 0 or weather.condition == 5) { // Clear or Windy
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(x2-width*0.01+offset, y+offset, WeatherFont, "f", Graphics.TEXT_JUSTIFY_RIGHT); // Clear Night	
	       		} else {
	       			dc.drawText(x2+offset, y, WeatherFont, "H", Graphics.TEXT_JUSTIFY_RIGHT); // Clear Day
	       		}
	       	} else if (weather.condition == 1 or weather.condition == 23 or weather.condition == 40 or weather.condition == 52) { // Partly Cloudy or Mostly Clear or fair or thin clouds
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(x-width*0.01-LEDoffset, y, WeatherFont, "g", Graphics.TEXT_JUSTIFY_RIGHT); // Partly Cloudy Night
	       		} else {
	       			dc.drawText(x2+(offset*1.7), y-1+(offset/2), WeatherFont, "G", Graphics.TEXT_JUSTIFY_RIGHT); // Partly Cloudy Day
	       		}
			} else if (weather.condition == 2 or weather.condition == 22) { // Mostly Cloudy or Partly Clear
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(x-width*0.01+offset-LEDoffset, y+offset, WeatherFont, "h", Graphics.TEXT_JUSTIFY_RIGHT); // Mostly Cloudy Night
	       		} else {
	       			dc.drawText(x2+2+(offset*2), y+(offset/2), WeatherFont, "B", Graphics.TEXT_JUSTIFY_RIGHT); // Mostly Cloudy Day
	       		}
			} else if (weather.condition == 3 or weather.condition == 14 or weather.condition == 15 or weather.condition == 11 or weather.condition == 13 or weather.condition == 24 or weather.condition == 25 or weather.condition == 26 or weather.condition == 27 or weather.condition == 45) { // Rain or Light Rain or heavy rain or showers or unkown or chance  
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(x-width*0.01+offset-LEDoffset, y, WeatherFont, "c", Graphics.TEXT_JUSTIFY_RIGHT); // Rain Night
	       		} else {
	       			dc.drawText(x2+2+(offset*2), y, WeatherFont, "D", Graphics.TEXT_JUSTIFY_RIGHT); // Rain Day
	       		}
			} else if (weather.condition == 4 or weather.condition == 10 or weather.condition == 16 or weather.condition == 17 or weather.condition == 34 or weather.condition == 43 or weather.condition == 46 or weather.condition == 48 or weather.condition == 51) { // Snow or Hail or light or heavy snow or ice or chance or cloudy chance or flurries or ice snow
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(x-width*0.01+offset-LEDoffset, y, WeatherFont, "e", Graphics.TEXT_JUSTIFY_RIGHT); // Snow Night
	       		} else {
	       			dc.drawText(x2+2+(offset*2), y, WeatherFont, "F", Graphics.TEXT_JUSTIFY_RIGHT); // Snow Day
	       		}
			} else if (weather.condition == 6 or weather.condition == 12 or weather.condition == 28 or weather.condition == 32 or weather.condition == 36 or weather.condition == 41 or weather.condition == 42) { // Thunder or scattered or chance or tornado or squall or hurricane or tropical storm
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(x-width*0.01+offset-LEDoffset, y, WeatherFont, "b", Graphics.TEXT_JUSTIFY_RIGHT); // Thunder Night
	       		} else {
	       			dc.drawText(x-1+(offset*2.1)-LEDoffset, y, WeatherFont, "C", Graphics.TEXT_JUSTIFY_RIGHT); // Thunder Day
	       		}
			} else if (weather.condition == 7 or weather.condition == 18 or weather.condition == 19 or weather.condition == 21 or weather.condition == 44 or weather.condition == 47 or weather.condition == 49 or weather.condition == 50) { // Wintry Mix (Snow and Rain) or chance or cloudy chance or freezing rain or sleet
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(x-width*0.01+offset-LEDoffset, y, WeatherFont, "d", Graphics.TEXT_JUSTIFY_RIGHT); // Snow+Rain Night
	       		} else {
	       			dc.drawText(x-1, y, WeatherFont, "E", Graphics.TEXT_JUSTIFY_RIGHT); // Snow+Rain Day
	       		}
			} else if (weather.condition == 8 or weather.condition == 9 or weather.condition == 29 or weather.condition == 30 or weather.condition == 31 or weather.condition == 33 or weather.condition == 35 or weather.condition == 37 or weather.condition == 38 or weather.condition == 39) { // Fog or Hazy or Mist or Dust or Drizzle or Smoke or Sand or sandstorm or ash or haze
				if (clockTime.hour >= 18 or clockTime.hour < 6) { 
	       			dc.drawText(x-width*0.01+(offset*1.3)-LEDoffset, y, WeatherFont, "a", Graphics.TEXT_JUSTIFY_RIGHT); // Fog Night
	       		} else {
	       			dc.drawText(x-1+(offset*2.1)-LEDoffset, y+(offset/2), WeatherFont, "A", Graphics.TEXT_JUSTIFY_RIGHT); // Fog Day
	       		}       		
	        }
		}
	}
	
	/* ------------------------ */
	
	function drawTemperature(dc, x, y, showBoolean, width) {
		if(CurrentConditions has :getCurrentConditions and CurrentConditions.getCurrentConditions() != null) {
			var weather = CurrentConditions.getCurrentConditions();
			var TempMetric = System.getDeviceSettings().temperatureUnits;
    		var fahrenheit;
			var offset = 0;
			
	        if (width==218) { // Vivoactive 4S
				offset = 4;
			} else if (width==240) { // Fenix 6S
				offset = 2;
			} else if (width==280) { // Fenix 6X
				offset = 3;
			} else if (width==260) { // Vivoactive 4
				offset = 4;
			} else if (width==390) { // Venu
				offset = -15;
			}
			
			
			if (showBoolean == false and weather has :feelsLikeTemperature) { //feels like
				if (TempMetric == System.UNIT_METRIC) { 
					dc.drawText(x+offset, y, Graphics.FONT_XTINY, weather.feelsLikeTemperature+"°C", Graphics.TEXT_JUSTIFY_LEFT);
				}
				else {
					fahrenheit = (weather.feelsLikeTemperature * 9/5) + 32; 
					fahrenheit = Lang.format("$1$", [fahrenheit.format("%d")] );
					dc.drawText(x+offset, y, Graphics.FONT_XTINY, fahrenheit +"°F", Graphics.TEXT_JUSTIFY_LEFT);
				}				
			} else if(weather has :temperature) {  // real temperature
					if (TempMetric == System.UNIT_METRIC) { 
						dc.drawText(x+offset, y, Graphics.FONT_XTINY, weather.temperature+"°C", Graphics.TEXT_JUSTIFY_LEFT);
					}
					else {
						fahrenheit = (weather.temperature * 9/5) + 32; 
						fahrenheit = Lang.format("$1$", [fahrenheit.format("%d")] );
						dc.drawText(x+offset, y, Graphics.FONT_XTINY, fahrenheit +"°F", Graphics.TEXT_JUSTIFY_LEFT);
					}
			}
		}
	}
	
	/* ------------------------ */
	
	// Weather Location Name
	function drawLocation(dc, x, y, wMax, hMax, showBoolean) {
		if(CurrentConditions has :getCurrentConditions and CurrentConditions.getCurrentConditions() != null) {
			var weather = CurrentConditions.getCurrentConditions();
			if (showBoolean != false) { // Show Location Name
				if(weather has :observationLocationName) {
					var location = weather.observationLocationName;
					if (location.length()>15 and location.find(",")!=null){
						location = location.substring(0,location.find(","));
					}
			        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
					//dc.fitTextToArea(text, font, width, height, truncate)
					dc.drawText(x, y, Graphics.FONT_XTINY, dc.fitTextToArea(location, Graphics.FONT_XTINY, wMax, hMax, true), Graphics.TEXT_JUSTIFY_CENTER);
				}		        
		    }		
		}
	}
	
	/* ------------------------ */
	
	// Notification Icon and Count
	function drawNotification(dc, xIcon, yIcon, xText, yText, accentColor, width) {

       	var formattedNotificationAmount = "";
       	var notificationAmount;      
       
        if (System.getDeviceSettings() has :notificationCount) {
	        notificationAmount = System.getDeviceSettings().notificationCount;
	    	if(notificationAmount > 99)	{
				formattedNotificationAmount = "99+";
			}
			else {
				formattedNotificationAmount = notificationAmount.format("%d");
			}
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			// Text
			dc.drawText( xText, yText, Graphics.FONT_XTINY, formattedNotificationAmount, Graphics.TEXT_JUSTIFY_LEFT);
			if (formattedNotificationAmount.toNumber() == 0){
				dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
			} else {
				dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
			}
			// Icon
			dc.drawText( xIcon, yIcon, IconsFont, "5", Graphics.TEXT_JUSTIFY_CENTER);
		}
	}
	
	/* ------------------------ */
	
	// Get heart rate
	function drawHeartRate(dc, xIcon, hrIconY, xText, width, accentColor) {
    	var heartRate;
    	if(Activity has :getActivityInfo) {
    		heartRate = Activity.getActivityInfo().currentHeartRate; 
    		if(heartRate==null) {
    			if(ActivityMonitor has :getHeartRateHistory) {
	    			var HRH=ActivityMonitor.getHeartRateHistory(1, true);
					var HRS=HRH.next();
					if(HRS!=null && HRS.heartRate!= ActivityMonitor.INVALID_HR_SAMPLE){
						heartRate = HRS.heartRate;
					}
				}
    		}
	    	if(heartRate==null) {
				heartRate = 0;
			}
		} else {
			heartRate = 0;
		}

		// Render heart rate text
		var heartRateText = heartRate.format("%d");
/*		if (heartRate == 0) {
			heartRateText="0";
		} else {
			heartRateText=heartRate.format("%d");
		}*/

		// Heart rate zones color definition (values for each zone are automatically calculated by Garmin)	
		var autoZones = User.getHeartRateZones(User.getCurrentSport());
		var heartRateZone = 0;
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
		var heartRateIconColour = Graphics.COLOR_DK_GRAY;
		if (heartRateZone == 0) { // Only when no default zones were detected
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
			} else { //(heartRate > 0) {
				heartRateZone = 1;
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
		dc.setColor(heartRateIconColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xIcon , hrIconY - 1  , IconsFont, "3", Graphics.TEXT_JUSTIFY_CENTER); // Using Icon
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText, hrIconY + 2.5 - (width == 390 ? 8.5 : 0) , Graphics.FONT_XTINY, heartRateText, Graphics.TEXT_JUSTIFY_LEFT);		
	}

	/* ------------------------ */
	
	// Draw Battery Icon and Text	
	function drawBatteryIcon(dc, xBattery, yBattery, xContact, yContact, width, height, accentColor) {
	    
	    var battery = Math.ceil(System.getSystemStats().battery);
	    var batteryState;
	    var batteryIconColour;
	       
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
		var offset = 0;
		if (width==218) { // Vivoactive 4S
			offset = 1;	
		} else if (width==280) { //Enduro & Fenix 6X Pro
			offset = -1;
		}
		dc.setColor(batteryIconColour, Graphics.COLOR_TRANSPARENT); 
		//dc.fillRoundedRectangle(x, y, width, height, radius)
		dc.fillRoundedRectangle(xBattery, yBattery , width*0.135, height*0.0625, 2);
		dc.fillRoundedRectangle(xContact, yContact , width*0.018, height*0.039 - offset, 2);
	}
	
	// Draw Battery Text (separate because of "too many arguments" error)
	function drawBatteryText(dc, xText, yText, width) {	
	
		var battery = Math.ceil(System.getSystemStats().battery);
		
		var offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = -2;	
		} else if (width==280) { // Enduro & Fenix 6X Pro
			offset = 0.75;	
		}  else if (width==218 or width==240) { // Vivoactive 4S & Fenix 6S & Vivoactive 3 Music
			offset = -0.5;	
		} 
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.drawText(xText, yText + offset , Graphics.FONT_XTINY /* batteryFont */,battery.format("%d") + "%", Graphics.TEXT_JUSTIFY_CENTER ); // Correct battery text on Fenix 5 series (except 5s)
	}
	
	/* ------------------------ */
	
	// Draw Do Not Disturb Icon
	function drawDndIcon(dc, x, y, width) {	
		
	    // If this device supports the Do Not Disturb feature,
        // load the associated Icon into memory.
		var dndIcon;
		        
        if (System.getDeviceSettings() has :doNotDisturb) {
            dndIcon = WatchUi.loadResource(Rez.Drawables.DoNotDisturbIcon);
        } else {
            //dndIcon = null;
            return false;
        }
        // Draw the do-not-disturb icon if we support it and the setting is enabled
        var offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		} 
        if (null != dndIcon && System.getDeviceSettings().doNotDisturb) {
            dc.drawBitmap( x + offset, y , dndIcon);
        }
        return true;
    }
    
	/* ------------------------ */
	
	// Draw Pulse Ox Icon and Text	
	function drawPulseOx(dc, xIcon, yIcon, xText, yText, width, accentColor) {	
          
        var pulseOx = null;
        if (Activity.getActivityInfo() has :currentOxygenSaturation) {
        	pulseOx = Activity.getActivityInfo().currentOxygenSaturation ;
        }
        
        var offset = 0;
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
        	dc.drawText( xIcon, yIcon + offset , IconsFont, "@", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
        	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        	dc.drawText( xText - offset, yText , Graphics.FONT_XTINY, Lang.format("$1$%", [pulseOx.format("%.0f")] ), Graphics.TEXT_JUSTIFY_LEFT);
        	return true;
        } else {
        	return false;
        }
	}
	
	/* ------------------------ */
	
	// Draw Floors Climbed Icon and Text
	function drawFloorsClimbed(dc, xIcon, yIcon, xText, yText, width, accentColor) {	
	
		var IconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
	    var floorsCount=0;
	    
	    if (ActivityMonitor.getInfo() has :floorsClimbed) {
	    	floorsCount = ActivityMonitor.getInfo().floorsClimbed;//.toString();
	    } else {
	    	return false;
		}
			
		if (floorsCount>=ActivityMonitor.getInfo().floorsClimbedGoal) {
			dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
		} else {
	    	dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
	    }
	    
        var offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		}	    
	    
		dc.drawText( xIcon, yIcon + offset , IconsFont, "1", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText - offset , yText , Graphics.FONT_XTINY, floorsCount, Graphics.TEXT_JUSTIFY_LEFT);
		return true;
    }

	/* ------------------------ */
	
	// Draw Distance Traveled / Steps
	function drawSteps(dc, xIcon, yIcon, xText, yText, width, accentColor) {	

		var IconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
		var DistanceMetric = System.getDeviceSettings().distanceUnits;
		var stepDistance=null;
		var distStr = "0";
		var unit = "";
        
        if (ActivityMonitor.getInfo() has :distance) {
        	if (Storage.getValue(14)==false) {
        		distStr = ActivityMonitor.getInfo().steps;
        	} else {
	    		stepDistance = ActivityMonitor.getInfo().distance;//.toString();
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
	    	}
	    }
        
        var offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		}
        
        if (ActivityMonitor.getInfo().steps>=ActivityMonitor.getInfo().stepGoal) {
        	dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        } else {
           	dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        } 
        dc.drawText( xIcon, yIcon + offset, IconsFont, "0", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
        
        // Steps Distance Text	        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xText - offset , yText, Graphics.FONT_XTINY, distStr + unit, Graphics.TEXT_JUSTIFY_LEFT); // Step Distance
	}
	
	/* ------------------------ */
	
	// Draw Hour and Minute Hands
	function drawHands(dc, width, height, accentColor, thickInd) {	
		var clockTime = System.getClockTime();
		var screenCenterPoint = [width/2, height/2];
	
       // Calculate the hour hand. Convert it to minutes and compute the angle.
        var hourHandAngle = (((clockTime.hour % 12) * 60) + clockTime.min);
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
		
		var handWidth = width;
		if (thickInd == true) {
			handWidth = width * 1.3;
		}

        //Use white to draw the hour hand, with a dark grey background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT); //(centerPoint, angle, handLength, tailLength, width)
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 3.4, 0, handWidth*(0.055 - offsetWidth))); // thick 
		dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 3.45, 0, handWidth*0.045)); // thick
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_DK_GRAY);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / (3.53 - offsetLength) , 0, handWidth*0.035)); // thick

        // Draw the minute hand.
        var minuteHandAngle = (clockTime.min / 60.0) * Math.PI * 2;
        //generateHandCoordinates(centerPoint, angle, handLength, tailLength, width) -- width / (higher means smaller)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2.19, 0, handWidth*(0.055 - offsetWidth))); // thick
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2.22, 0, handWidth*0.045)); // thick
        dc.setColor(accentColor, Graphics.COLOR_DK_GRAY);
        dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / (2.25 - offsetLengthAccent) , 0, handWidth*0.035)); // thick

	    		        
        // Draw the arbor in the center of the screen.
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillCircle(width / 2, height / 2, handWidth*0.03); // thick
        dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
        dc.drawCircle(width / 2, height / 2, handWidth*0.03); // thick
    }
    
	/* ------------------------ */
	
	// Draw Garmin Logo
	function drawGarminLogo(dc, x, y) {	    
    	var garminIcon = WatchUi.loadResource(Rez.Drawables.GarminLogo);
       	dc.drawBitmap( x, y , garminIcon);
    }

	/* ------------------------ */
	
	// Draw Calories Burned
	function drawCalories(dc, xIcon, yIcon, xText, yText, width) {	
	
		var IconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
	    var calories=0;
	    
	    if (ActivityMonitor.getInfo() has :calories) {
	    	calories = ActivityMonitor.getInfo().calories;//.toString();
	    } else {
	    	return false;
		}
			
        var offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		}	    
	    
	    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xIcon, yIcon + offset , IconsFont, "6", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText - offset , yText , Graphics.FONT_XTINY, calories, Graphics.TEXT_JUSTIFY_LEFT);
		return true;
    }

	/* ------------------------ */
	
	// Draw Elevation
	function drawElevation(dc, xIcon, yIcon, xText, yText, width) {	

		var IconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
		var elevationMetric = System.getDeviceSettings().elevationUnits;
		var elevation=null;
		var elevationStr;
		var unit;
        
        if (Activity.getActivityInfo() has :altitude) {
	    	elevation = Activity.getActivityInfo().altitude;//.toString();
	    }
        
        var offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		}
        
       	dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( xIcon, yIcon + offset, IconsFont, ";", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
        
        // Elevation Text	
		if (elevation != null) {
        	if (elevationMetric == System.UNIT_METRIC) {
        		if (elevation >= 1000) {
        			unit = " km";
        		} else {
        			unit = " m";
        		}
        	} else{
        		unit = " ft";
        		elevation = elevation * 3.28084;
        	}
        } else {
        	unit = "?";
        }
        
        if (elevation >= 1000 and elevationMetric == System.UNIT_METRIC) {
        	elevation = elevation * 0.001;
        	elevationStr = Lang.format("$1$", [elevation.format("%.1f")] );
        } else { //(elevation <1000)
        	elevationStr = Lang.format("$1$", [elevation.format("%.0f")] );
        }
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xText - offset , yText, Graphics.FONT_XTINY, elevationStr + unit, Graphics.TEXT_JUSTIFY_LEFT); // Elevation in m or mi
	}

	/* ------------------------ */
	
	// Draw Precipitation Percentage
	function drawPrecipitation(dc, xIcon, yIcon, xText, yText, width) {	
	
		//var IconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
		var IconsFont = WatchUi.loadResource(Rez.Fonts.HumidityFont);
	    var precipitation=0;
	    
	    if (CurrentConditions has :getCurrentConditions) {
	    	precipitation = CurrentConditions.getCurrentConditions().precipitationChance;//.toString();
	    } else {
	    	return false;
		}
			
        var offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		}	    
	    
	    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xIcon, yIcon + offset , IconsFont, "S", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText - offset , yText , Graphics.FONT_XTINY, Lang.format("$1$%",[precipitation]), Graphics.TEXT_JUSTIFY_LEFT);
		return true;
    }

	/* ------------------------ */
	
	// Draw Humidity Percentage
	function drawHumidity(dc, xIcon, yIcon, xText, yText, width) {	
	
		var IconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
	    var humidity=0;
	    
	    if (CurrentConditions has :getCurrentConditions) {
	    	humidity = CurrentConditions.getCurrentConditions().relativeHumidity;//.toString();
	    } else {
	    	return false;
		}
			
        var offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		}	    
	    
	    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xIcon, yIcon + offset , IconsFont, "A", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText - offset , yText , Graphics.FONT_XTINY, Lang.format("$1$%",[humidity]), Graphics.TEXT_JUSTIFY_LEFT);
		return true;
    }
	
	/* ------------------------ */	

	// Draw Wind Speed
	function drawWindSpeed(dc, xIcon, yIcon, xText, yText, width) {	

		var IconsFont = WatchUi.loadResource(Rez.Fonts.HumidityFont);
		var WindMetric = System.getDeviceSettings().paceUnits;
		var windSpeed=null;
		var unit;
        
        if (CurrentConditions has :getCurrentConditions) {
	    	windSpeed = CurrentConditions.getCurrentConditions().windSpeed;//.toString();
	    }
        
        var offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		}
        
        var beaufortZone = null;
		var windIconColour = Graphics.COLOR_DK_GRAY;
		
		if (windSpeed >= 32.7) { // Hurricane Force
			beaufortZone = 12;
		} else if (windSpeed >= 28.5) { // Violent Storm
			beaufortZone = 11;
		} else if (windSpeed >= 24.5) { // Storm
			beaufortZone = 10;
		} else if (windSpeed >= 20.8) { // Strong Gale
			beaufortZone = 9;
		} else if (windSpeed >= 17.2) { // Gale
			beaufortZone = 8;
		} else if (windSpeed >= 13.9) { // Near Gale
			beaufortZone = 7;
		} else if (windSpeed >= 10.8) { // Strong Breeze
			beaufortZone = 6;
		} else if (windSpeed >= 8) { // Fresh Breeze
			beaufortZone = 5;
		} else if (windSpeed >= 5.5) { // Moderate Breeze
			beaufortZone = 4;
		} else if (windSpeed >= 3.4) { // Gentle Breeze
			beaufortZone = 3;
		} else if (windSpeed >= 1.6) { // Light Breeze
			beaufortZone = 2;
		} else if (windSpeed >= 0.3) { // Light Air
			beaufortZone = 1;			
		} else { // Calm
			beaufortZone = 0;
		}  
		
		if (beaufortZone == 0) { // Calm
			windIconColour = 0x00AAFF;
		} else if (beaufortZone == 1) { // Light Air
			windIconColour = 0x55FFFF;
		} else if (beaufortZone == 2) { // Light Breeze
			windIconColour = 0x55AAAA; 
		} else if (beaufortZone == 3) { // Gentle Breeze
			windIconColour = 0x55AA00; 
		} else if (beaufortZone == 4) { // Moderate Breeze
			windIconColour = 0x55FF00; 
		} else if (beaufortZone == 5){ // Fresh Breeze
			windIconColour = 0xAAFF00; 
 		} else if (beaufortZone == 6){ // Strong Breeze
			windIconColour = 0xAAFFAA; 
 		} else if (beaufortZone == 7){ // Near Gale
			windIconColour = 0xFFFFAA; 
 		} else if (beaufortZone == 8){ // Gale
			windIconColour = 0xFFFF00; 
 		} else if (beaufortZone == 9){ // Strong Gale
			windIconColour = 0xFFAA00; 
 		} else if (beaufortZone == 10){ // Storm
			windIconColour = 0xFFAAAA; 
 		} else if (beaufortZone == 11){ // Violent Storm
			windIconColour = 0xFF5500; 
 		} else if (beaufortZone == 12){ // Hurricane Force
			windIconColour = 0xFF0000; 						
		}        
        
       	dc.setColor(windIconColour, Graphics.COLOR_TRANSPARENT); 
        dc.drawText( xIcon, yIcon + offset, IconsFont, "P", Graphics.TEXT_JUSTIFY_CENTER); // Icon Using Font
        
        // Wind Speed Text	
		if (windSpeed != null) {
        	if (WindMetric == System.UNIT_METRIC) {
				windSpeed = windSpeed * 3.6; //converting from m/s to km/h
				if (width==218) {
					unit = "kph";
				} else if (width==240) {
					unit = " kph";
				} else if (windSpeed>=100){
					unit = "km/h";
				} else {
        			unit = " km/h";
        		}
        	} else{
        		windSpeed = windSpeed * 2.22369; //converting from m/s to mph
        		unit = " mph";
        	}
        } else {
        	unit = " m/s";
        }
        
       	var windStr = Lang.format("$1$", [windSpeed.format("%.0d")] );
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xText - offset , yText, Graphics.FONT_XTINY, windStr + unit, Graphics.TEXT_JUSTIFY_LEFT); // Wind Speed in km/h or mph
	}

	/* ------------------------ */
	
	// Draw Solar Intensity
	function drawSolarIntensity(dc, xIcon, yIcon, xText, yText, width, accentColor) {	
	
		var IconsFont = WatchUi.loadResource(Rez.Fonts.HumidityFont);
	    var solarIntensity=0;
	    
	    if (System.getSystemStats() has :solarIntensity) {
	    	if (System.getSystemStats().solarIntensity != null) {
	    		solarIntensity = System.getSystemStats().solarIntensity;//.toString();
	    	} else {
	    		return false;
	    	}
	    } else {
	    	return false;
		}
		
		var solarZone = null;
		
		if (solarIntensity >= 80) { // Extreme
			solarZone = 5;
		} else if (solarIntensity >= 60) { // Very High
			solarZone = 4;
		} else if (solarIntensity >= 40) { // High
			solarZone = 3;
		} else if (solarIntensity >= 20) { // Moderate
			solarZone = 2;
		} else if (solarIntensity > 0) { // Low
			solarZone = 1;			
		} else { // Not existent
			solarZone = 0;
		}  

		var solarIconColour = Graphics.COLOR_DK_GRAY;
		
		if (solarZone == 0) { // Not existent
			solarIconColour = Graphics.COLOR_LT_GRAY;
		} else if (solarZone == 1) { // Low
			if (accentColor == 0xAAFF00) {
				solarIconColour = 0xAAFF00; /* Vivomove GREEN */
			} else {
				solarIconColour = 0x55FF00; /* GREEN */
			}		
		} else if (solarZone == 2) { // Moderate
			solarIconColour = 0xFFFF55; 
		} else if (solarZone == 3) { // High
			solarIconColour = 0xFFAA00; 
		} else if (solarZone == 4) { // Very High
			solarIconColour = Graphics.COLOR_RED; 
		} else if (solarZone == 5){ // Extreme
			solarIconColour = 0xFF55FF; 
		}        
        
        var offset = 0;
		if (width==390) { // Venu & D2 Air
			offset = 7;	
		}	    
	    
       	dc.setColor(solarIconColour, Graphics.COLOR_TRANSPARENT); 
		dc.drawText( xIcon, yIcon + offset , IconsFont, "R", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText - offset , yText , Graphics.FONT_XTINY, Lang.format("$1$%",[solarIntensity]), Graphics.TEXT_JUSTIFY_LEFT);
		return true;
    }
    
	/* ------------------------ */
	
	// Draw Right Bottom Data Point
	function drawRightBottom(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset, dataPoint) {	// 0=humidityIcon, 1=precipitationIcon, 2=caloriesIcon, 3=floorsClimbIcon, 4=pulseOxIcon, 5=heartRateIcon, 6=notificationIcon, 7=solarIcon, 8=none
		
		var offset = 0;
		var offset240 = 0;
		var offsetY = 0;
		var offset218 = 0;
		if (width==280) { // Enduro & Fenix 6X
			offset = -1;	
		} else if (width==240) { // Fenix 6S & MARQ
			offset240 = -1;	
		} else if (width==390) { // Venu
			offsetY=8;
		} else if (width==218) { // Vivoactive 4S
			offset218=1;
		}
		
		if (dataPoint == 0) { // Humidity(dc, xIcon, yIcon, xText, yText, width)
			drawHumidity(dc, xIcon-(xIcon*0.025)-(offsetY/2.6)+offset218, yIcon, xText-(xText*0.01)+offset240+(offsetY/4)+offset218, yText-offset240-(offsetY/8)+offset218, width);
		} else if (dataPoint == 1) { // Precipitation(dc, xIcon, yIcon, xText, yText, width)
			drawPrecipitation(dc, xIcon-(xIcon*0.02)-(offsetY/1.6), yIcon-(yIcon*0.005)-offset+(offsetY/2.6), xText-(xText*0.02)-offset240+(offsetY/2.6)+(offset218*2), yText-offset-offset240+offset218, width);
		} else if (dataPoint == 2) { // Calories(dc, xIcon, yIcon, xText, yText, width)
			drawCalories(dc, xIcon-(xIcon*0.025)-(offsetY/2.6), yIcon-offset+(offsetY/8), xText-(xText*0.025)-offset240+offsetY+(offset218*2), yText-offset-offset240-(offsetY/8)+offset218, width);
		} else if (dataPoint == 3) { // FloorsClimbed(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawFloorsClimbed(dc, xIcon+(xIcon*0.01)+offset-offsetY, yIcon+(yIcon*0.005)-offset218, xText+(xText*0.02)-(offsetY/4)+offset218, yText-offset-offset240+offset218, width, accentColor);
		} else if (dataPoint == 4) { // PulseOx(dc, xIcon, yIcon, xText, yText, width, accentColor)
/**/			drawPulseOx(dc, xIcon-(xIcon*0.01)-(offsetY/2), yIcon+(yIcon*0.005)-offset218, xText-(xText*0.005)+(offsetY/2)+offset218, yText-offset-offset240-(offsetY/8)+offset218, width, accentColor);
		} else if (dataPoint == 5) { // HeartRate(dc, xIcon, hrIconY, xText, width, Xoffset, accentColor)
			drawHeartRate(dc, xIcon-offsetY/2+offset218, yIcon+(yIcon*0.01)+offsetY, xText+(xText*0.01)-offsetY/2+(offset218*3), width, accentColor);
		} else if (dataPoint == 6) { // Notification(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawNotification(dc, xIcon-(xIcon*0.015)+offset-(offsetY*0.4)+offset218, yIcon+(yIcon*0.005)-offset+offsetY-offset218, xText+(xText*0.005)-offset-offset240-(offsetY*0.4)+(offset218*3), yText-offset-offset240-(offsetY/8)+offset218, accentColor, width);
		} else if (dataPoint == 7) { // SolarIntensity (dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawSolarIntensity(dc, xIcon+offset*3+offset240, yIcon-offset*2-offset240, xText, yText-offset-offset240, width, accentColor);
		}		
	}

	/* ------------------------ */
	
	// Draw Left Bottom Data Point
	function drawLeftBottom(dc, xIcon, yIcon, xText, yText, accentColor, width, dataPoint) {
		
		var offset = 0;
		var offset240 = 0;
		var offsetY = 0;
		var offset218 = 0;
		if (width==240) { // Fenix 6S
			offset240 = -1;	
		} else if (width==218) { // Vivoactive 4S
			offset218 = 1;	
		} else if (width==280) { // Enduro & Fenix 6X
			offset = -1;	
		} else if (width==390) {
			offsetY = 10;
		}
		
		 	
		if (dataPoint == 0) { // Humidity(dc, xIcon, yIcon, xText, yText, width)
			drawHumidity(dc, xIcon, yIcon+(offsetY/10), xText+(xText*0.01)+(offsetY/1.65)+offset218, yText+offset-(offsetY/10)+offset218, width);
		} else if (dataPoint == 1) { // Precipitation(dc, xIcon, yIcon, xText, yText, width)
			drawPrecipitation(dc, xIcon, yIcon-(yIcon*0.005)-offset+(offsetY/5), xText+(offsetY/1.41)+(offset218*2), yText-(offsetY/10)+offset218, width);
		} else if (dataPoint == 2) { // Calories(dc, xIcon, yIcon, xText, yText, width)
			drawCalories(dc, xIcon, yIcon+(offsetY/10), xText-offset+(offsetY/1.41)+(offset218*2), yText-(offsetY/10)+offset218, width);
		} else if (dataPoint == 3) { // FloorsClimbed(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawFloorsClimbed(dc, xIcon+(xIcon*0.01)+offset, yIcon-offset240+(offsetY/10), xText+(xText*0.01)+(offsetY/1.65)+offset218, yText-(offsetY/10)+offset218, width, accentColor);
		} else if (dataPoint == 4) { // PulseOx(dc, xIcon, yIcon, xText, yText, width, accentColor)
/**/			drawPulseOx(dc, xIcon, yIcon-offset240+(offsetY/10), xText+(xText*0.01)+(offsetY/1.41), yText-(offsetY/10)+offset218, width, accentColor);
		} else if (dataPoint == 5) { // HeartRate(dc, xIcon, hrIconY, xText, width, Xoffset, accentColor)
			drawHeartRate(dc, xIcon, yIcon+(yIcon*0.01)+(offsetY*0.8), xText+(xText*0.01)-offsetY/8+offset218, width, accentColor);
		} else if (dataPoint == 6) { // Notification(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawNotification(dc, xIcon-(xIcon*0.05)+offset, yIcon-offset+(offsetY*0.9), xText-offset+(offset218*2), yText-(offsetY/10)+offset218, accentColor, width);
		} else if (dataPoint == 7) { // SolarIntensity (dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawSolarIntensity(dc, xIcon-offset, yIcon-offset-offset240, xText-offset*2, yText, width, accentColor);
		}		
	}

	/* ------------------------ */
	
	// Draw Left Middle Data Point
	function drawLeftMiddle(dc, xIcon, yIcon, xText, yText, accentColor, width, dataPoint) {
	
		var offset = 0;
		var offsetY = 0;
		var offset218 = 0;
		if (width==280) { // Enduro & Fenix 6X
			offset = -1;	
		} else if (width == 390) { //Venu
			offsetY=8;
		} else if (width == 218) {
			offset218=1;
		}
 			
		if (dataPoint == 0) { // stepsIcon(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawSteps(dc, xIcon+(xIcon*0.02), yIcon-(yIcon*0.005)-offset218, xText+(xText*0.01)+(offsetY/1.3)+offset218, yText-(yText*0.01)-(offsetY/4), width, accentColor);
		} else if (dataPoint == 1) { // elevationIcon(dc, xIcon, yIcon, xText, yText, width)
			drawElevation(dc, xIcon, yIcon-(yIcon*0.005)-offset218, xText+(offsetY/1.14)+(offset218*2), yText-(yText*0.01)-(offsetY/4), width);
		} else if (dataPoint == 2) { // windIcon(dc, xIcon, yIcon, xText, yText, width)
			drawWindSpeed(dc, xIcon+(xIcon*0.03)+(offset*2)-(offsetY/8), yIcon-(yIcon*0.01)-offset218, xText-offset+(offsetY*0.9)+(offset218*2), yText-(yText*0.01)-(offsetY/4)+offset218, width);
		} else if (dataPoint == 3) { // Humidity(dc, xIcon, yIcon, xText, yText, width)
			drawHumidity(dc, xIcon, yIcon-(yIcon*0.005)-offset218, xText+(xText*0.01)+(offsetY/1.32)+offset218, yText-(yText*0.01)-(offsetY/4), width);			
		} else if (dataPoint == 4) { // Precipitation(dc, xIcon, yIcon, xText, yText, width)
			drawPrecipitation(dc, xIcon, yIcon-(yIcon*0.01)+(offsetY/8)-(offset218*2), xText+(offsetY/1.14)+(offset218*2), yText-(yText*0.01)-(offsetY/4), width);
		} else if (dataPoint == 5) { // Calories(dc, xIcon, yIcon, xText, yText, width)
			drawCalories(dc, xIcon, yIcon-(yIcon*0.005)-offset218, xText+(xText*0.01)+(offsetY/1.32)+offset218, yText-(yText*0.01)-(offsetY/4), width);
		} else if (dataPoint == 6) { // FloorsClimbed(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawFloorsClimbed(dc, xIcon+(xIcon*0.01)+offset, yIcon-(yIcon*0.005)-offset218, xText+(xText*0.01)+(offsetY/1.32)+offset218, yText-(yText*0.01)-(offsetY/4), width, accentColor);
		} else if (dataPoint == 7) { // PulseOx(dc, xIcon, yIcon, xText, yText, width, accentColor)
/**/			drawPulseOx(dc, xIcon, yIcon-(yIcon*0.005)-offset218, xText+(xText*0.01)+(offsetY/1.14)+offset218, yText-(yText*0.01)-(offsetY/4), width, accentColor);
		} else if (dataPoint == 8) { // HeartRate(dc, xIcon, hrIconY, xText, width, accentColor)
			drawHeartRate(dc, xIcon, yIcon+offsetY, xText+(xText*0.01)-(offsetY/8)+offset218, width, accentColor);
		} else if (dataPoint == 9) { // Notification(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawNotification(dc, xIcon-(xIcon*0.05), yIcon+offset+(offsetY*0.87)-(offset218*2), xText-offset+(offset218*2), yText+(offset*2)-(offsetY/2)-offset218, accentColor, width);
		} else if (dataPoint == 10) { // SolarIntensity (dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawSolarIntensity(dc, xIcon-offset, yIcon+offset, xText-offset*2, yText+offset*2, width, accentColor);
		}		
	}

	/* ------------------------ */
	
	// Draw Left Top Data Point
	function drawLeftTop(dc, xIcon, yIcon, xText, yText, accentColor, width, dataPoint) {
	
		var offset = 0;
		var offsetY = 0;
		var offset218 = 0;
		if (width==390) { // Venu
			offsetY = 8;	
		} else if (width==218) { // Vivoactive 4S
			offset218 = 1;	
		} else if (width==280) { // Enduro & Fenix 6X
			offset = -2;
		} 
			
		if (dataPoint == 0) { // stepsIcon(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawSteps(dc, xIcon+(xIcon*0.02), yIcon, xText+(xText*0.01)+(offsetY/1.3)+offset218, yText-(offsetY/2.6), width, accentColor);
		} else if (dataPoint == 1) { // elevationIcon(dc, xIcon, yIcon, xText, yText, width)
			drawElevation(dc, xIcon, yIcon-(offset/2)+(offsetY/8), xText+(offsetY/1.14)+(offset218*2), yText-(offsetY/4), width);
		} else if (dataPoint == 2) { // windIcon(dc, xIcon, yIcon, xText, yText, width)
			drawWindSpeed(dc, xIcon+(xIcon*0.03)+offset-(offsetY/5), yIcon-(yIcon*0.01)-(offset/2)-(offsetY/8)-offset218, xText-(offset/2)+(offsetY*0.9)+(offset218*2), yText-(offsetY/2), width);
		} else if (dataPoint == 3) { // Humidity(dc, xIcon, yIcon, xText, yText, width)
			drawHumidity(dc, xIcon, yIcon, xText+(xText*0.01)+(offsetY/1.32)+offset218, yText-(offsetY/2.6), width);			
		} else if (dataPoint == 4) { // Precipitation(dc, xIcon, yIcon, xText, yText, width)
			drawPrecipitation(dc, xIcon, yIcon-(yIcon*0.005)+(offsetY/8)-(offset218*2), xText+(offsetY/1.14)+(offset218*2), yText-(offsetY/2.6)-offset218, width);
		} else if (dataPoint == 5) { // Calories(dc, xIcon, yIcon, xText, yText, width)
			drawCalories(dc, xIcon, yIcon+(offsetY/8)-offset218, xText+(xText*0.01)+(offsetY/1.32)+offset218, yText-(offsetY/4)-offset218, width);
		} else if (dataPoint == 6) { // FloorsClimbed(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawFloorsClimbed(dc, xIcon+(xIcon*0.01)+offset/2, yIcon-offset218, xText+(xText*0.01)+(offsetY/1.32)+offset218, yText-(offsetY/2.6)-offset218, width, accentColor);
		} else if (dataPoint == 7) { // PulseOx(dc, xIcon, yIcon, xText, yText, width, accentColor)
/**/			drawPulseOx(dc, xIcon, yIcon-offset218, xText+(xText*0.01)+(offsetY/1.14)+offset218, yText-(offsetY/2.6)-offset218, width, accentColor);
		} else if (dataPoint == 8) { // HeartRate(dc, xIcon, hrIconY, xText, width, accentColor)
			drawHeartRate(dc, xIcon, yIcon+(yIcon*0.015)+offsetY, xText+(xText*0.01)-(offsetY/8)+offset218, width, accentColor);
		} else if (dataPoint == 9) { // Notification(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawNotification(dc, xIcon-(xIcon*0.05)+offset/2, yIcon+offsetY, xText-(offset/2)+(offset218*2), yText+(offset/2)-(offsetY*0.4), accentColor, width);
		} else if (dataPoint == 10) { // SolarIntensity (dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawSolarIntensity(dc, xIcon-offset/2, yIcon, xText-offset, yText+offset/2, width, accentColor);
		}		
	}

}
