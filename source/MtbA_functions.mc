// All functions used to draw data points and icons in the watch face
/*
using Toybox.System;
//import Toybox.WatchUi;
using Toybox.Weather;
using Toybox.ActivityMonitor;
using Toybox.UserProfile;
using Toybox.Activity;
using Toybox.Math;
using Toybox.Graphics;
*/
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;
import Toybox.Complications;

class MtbA_functions {
	
  const IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
	const screenShape = System.getDeviceSettings().screenShape;
	var fontSize = (Storage.getValue(14) == true ? 1 : 0);
	var fontColor = (Storage.getValue(32) == true ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE);
	var condName as String = "";
	var lowPower as Boolean;
	var wakeUpTimestamp = 0;
	var lastSleepScoreDay = -1; // Tracks the day of the month (1-31) when sleep score was last triggered (API 6+ only)
	var secHands = Storage.getValue(33);

	function initialize(inLowPower) {
		lowPower = inLowPower;
	}

	// This function is used to generate the coordinates of the 4 corners of the polygon
    // used to draw a watch hand. The coordinates are generated with specified length,
    // tail length, and width and rotated around the center point at the provided angle.
    // 0 degrees is at the 12 o'clock position, and increases in the clockwise direction.
    function generateHandCoordinates(centerPoint as Array<Number>, angle as Float, handLength as Number, tailLength as Number, width as Float, triangle as Float) as Array<[Numeric, Numeric]> {
        // Map out the coordinates of the watch hand
        var coords = [[-(width / 2), tailLength], [-(width / 2), -handLength], [0,-handLength*triangle], [width / 2, -handLength], [width / 2, tailLength]];
        var result = new [5];
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 5; i += 1) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
            var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;

            result[i] = [centerPoint[0] + x, centerPoint[1] + y];
        }

        return result;
    }
	
    /* ------------------------ */
	
	// Draws the clock tick marks around the outside edges of the screen.
(:round) function drawHashMarks(dc, accentColor, width, aod, colorFlag, accIndex, showBoolean, AODColor) { // 2, 5
			var sX, sY;
			var eX, eY;
			var outerRad = width / 2;
			var innerRad = outerRad - 10;
			//var showBoolean = hourLabel;		

			if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
					var mColors = Application.loadResource(Rez.JsonData.mColors) as Array;
					if(mColors[accIndex] != accentColor){
							Storage.setValue(1, mColors[accIndex]);
							accentColor = mColors[accIndex];
					}
			} else { // Light Theme
					var mColors = Application.loadResource(Rez.JsonData.mColorsWhite) as Array;
					if(mColors[accIndex] != accentColor){
							Storage.setValue(1, mColors[accIndex]);
							accentColor = mColors[accIndex];
					}
			}	
	
			// Draw hashmarks differently depending on screen geometry.
			var increment = (aod==true) ? 5 : 1;

			// Loop through each minute and draw tick marks
			for (var i = 0; i <= 59; i += increment) {
				var angle = i * Math.PI / 30;
				if (aod==true) { // AOD mode is ON
					if (i % 5 == 0){
						if (colorFlag == true and AODColor){ // Tickmark color is ON and AOD Colors is ON
							dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
						} else if (i == 15 or i == 45) {
								//dc.setColor(accentColor, Graphics.COLOR_BLACK);
								//dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
								dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
						} else {
								//dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
								dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
						}
					}
				} else{ // AOD mode is OFF or MIP
					if ((i == 15) or (i == 45)) {
						dc.setColor(accentColor, accentColor);
					} else {
						if (colorFlag == true and (i % 5 == 0)){
							dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
						} else{
							if ((showBoolean == false) and (i == 0 or i == 30)) {
									dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
							} else {
								if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
									if (width < 360){
										dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT); // Using lighter tone for MIP displays
									} else {
										dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT); // Darker tone for AMOLED
									}
								}	else { // Light Theme
									dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
								}
							}
						}       
					}   
				}  	

				// thicker lines at 5 min intervals
				if( (i % 5) == 0) {
						dc.setPenWidth(3);
				} else {
						dc.setPenWidth(1);            
				}
				if(aod==true) { // AOD for AMOLED is ON, so only small hashmarks are going to be displayed at each 15 min
					sY = innerRad * Math.sin(angle);
					eY = outerRad * Math.sin(angle);
					sX = innerRad * Math.cos(angle);
					eX = outerRad * Math.cos(angle);							
				} else if (showBoolean == false) { // AOD for AMOLED is OFF and NOT showing hour labels, then all 5 minute marks will have same length
					// longer lines at intermediate 5 min marks
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
				} else if( (i % 5) == 0 && !((i % 15) == 0)) { // AOD for AMOLED is OFF and showing hour labels, then marks at each 15 min will be smaller to accomodate labels
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
    }

(:square) function drawHashMarks(dc, accentColor, width, aod, colorFlag, accIndex, showBoolean, AODColor) {
			var sX, sY;
			var eX, eY;
			var outerRad = width / 2;
			//var innerRad = outerRad - 10;			
			var innerRad = outerRad - 10;
			//var showBoolean = Storage.getValue(5);			
			var height = dc.getHeight();
		
			// Draw hashmarks differently depending on screen geometry.
			if (System.SCREEN_SHAPE_ROUND != screenShape) { //check if square display			
				var coords = [0, width / 4, (3 * width) / 4, width];
				if(aod==true and AODColor!=true) {	// AOD ON and AOD colors OFF
					dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
				} else { // AOD OFF or (AOD ON and AOD colors ON)
					if (colorFlag == true){
						dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
					} else{	
		        if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
							dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
						} else { // Light Theme
							dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
						}
					}
				}
				for (var i = 0; i < coords.size(); i += 1) {
					var dx = ((width / 2.0) - coords[i]) / (height / 2.0);
					var upperX = coords[i] + (dx * 10);
					
/* removed due to out of memory error
					if(coords[i] == 0){	// Draw the left-corner hash marks.
						dc.fillPolygon([[coords[i], 1], [upperX+2, 13], [upperX + 4, 13], [coords[i] + 3, 1]]); // upper
						dc.fillPolygon([[coords[i], height-1], [upperX+2, height - 13], [upperX + 4, height - 13], [coords[i] + 3, height - 1]]); // lower
					}

					if(coords[i] == width){	// Draw the right-corner hash marks.
						dc.fillPolygon([[coords[i] - 1, 1], [upperX - 3, 13], [upperX - 1, 13], [coords[i] + 2, 1]]); // upper
						dc.fillPolygon([[coords[i] - 1, height-1], [upperX - 3, height - 13], [upperX - 1, height - 13], [coords[i] + 2, height - 1]]); // lower
					}
*/
					if(coords[i] == width * 0.25){
						// Draw the upper/lower left hash marks
						dc.fillPolygon([[coords[i] - 9, 1], [upperX - 9, 11], [upperX - 7, 11], [coords[i] - 7, 1]]);
						dc.fillPolygon([[coords[i] - 9, height-1], [upperX - 9, height - 11], [upperX -7 , height - 11], [coords[i] - 7, height - 1]]); 
						// Draw the middle-upper hash marks.
						dc.fillPolygon([[1, coords[i] - 9], [11, upperX - 9], [11, upperX - 7], [1, coords[i] - 7]]);
						dc.fillPolygon([[width-1, coords[i] - 9], [width - 11, upperX - 9], [width - 11, upperX - 7], [width - 1, coords[i] - 7]]);
					}

					if(coords[i] == width * 0.75){
						// Draw the upper/lower right hash marks.						
						dc.fillPolygon([[coords[i] + 7, 1], [upperX + 7, 11], [upperX + 9, 11], [coords[i] + 9, 1]]);
						dc.fillPolygon([[coords[i] + 7, height-1], [upperX + 7, height - 11], [upperX + 9, height - 11], [coords[i] + 9, height - 1]]); 
						// Draw the middle-lower hash marks.
						dc.fillPolygon([[1, coords[i] + 7], [11, upperX + 7], [11, upperX + 9], [1, coords[i] + 9]]); // left
						dc.fillPolygon([[width-1, coords[i] + 7], [width - 11, upperX + 7], [width - 11, upperX + 9], [width - 1, coords[i] + 9]]); // right
					}
			
				}
				for (var i = 0; i <= 59; i += 15) { //draw the middle hashmarks (each 15 min)
					var angle = i * Math.PI / 30;

					if(aod==true and AODColor!=true) {	// AOD ON and AOD colors OFF
						if ((i == 15) or (i == 45)) {
							dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
						} else {
							dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
						}
					} else { // AOD OFF or AOD ON and AOD colors ON
						if ((i == 15) or (i == 45)) {
								dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
						} else {
								if (colorFlag == true){
									dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
								} else{
									if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
										dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT); // Using lighter tone for MIP displays
									} else { // Light Theme
										dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
									}
								}
						}
					}

					if( (i % 15) == 0) {
						dc.setPenWidth(3);
						sY = innerRad * Math.sin(angle);
						eY = outerRad * Math.sin(angle);
						sX = innerRad * Math.cos(angle);
						eX = outerRad * Math.cos(angle);
						sX += outerRad; sY += outerRad;
						eX += outerRad; eY += outerRad;
						dc.drawLine(sX, sY, eX, eY);
					}
				}
				return true;
			}else { // round display
				return false;
			}	
		}

    
    /* ------------------------ */
    
    // Draw the date string into the provided buffer at the specified location
    function drawDateString(dc, x as Number, y as Number, format as Boolean, size as Boolean) as Void {
			var info = Time.Gregorian.info(Time.now(), Time.FORMAT_LONG);
			var dateStr;
			
			if (format){
				dateStr = Lang.format("$1$, $3$ $2$", [info.day_of_week, info.month, info.day]);
			} else {
				dateStr = Lang.format("$1$, $2$ $3$", [info.day_of_week, info.month, info.day]);
			}

			if (x*2 == 260){
				y = y + 3;
			}

			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			//dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(x, size ? y : y+(dc.getWidth()*0.017), size ? Graphics.FONT_TINY : Graphics.FONT_XTINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);   
    }
    
    /* ------------------------ */	
    
    // Draw the Bluetooth Icon
    function drawBluetoothIcon(dc, x, y) {
    	var offset = 0;

      if (dc.getWidth()==218) { // Vivoactive 4S & Fenix 6S
				offset = 2;	
      } else if (dc.getWidth()>=360) { // Venu & D2 Air
        offset = -2;
      }
                
			var settings = System.getDeviceSettings().phoneConnected; // maybe .connectionAvailable or .ConnectionInfo.state ?
			if (settings) {
				if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
					dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
				} else {
					dc.setColor(0x0055AA, Graphics.COLOR_TRANSPARENT);
				}
			} else {
					dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_LT_GRAY), Graphics.COLOR_TRANSPARENT);
			}
			dc.drawText( x - offset, y - offset, IconsFont, "8", Graphics.TEXT_JUSTIFY_CENTER);
    }

    /* ------------------------ */	
    
    // Draw the Alarm Icon
	function drawAlarmIcon(dc, x, y, accentColor, width) {
		var offset = 0;
		var LEDoffset = 0;
        if (width==218) { // Vivoactive 4S & Fenix 6S
            offset = 2;	
        } else if (width>=360) { // Venu & D2 Air
            offset = -2;
            LEDoffset = 2;
        }
        
        var settings = System.getDeviceSettings().alarmCount;
        if (settings>0) {
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        } else {
						if (width!=208){
							dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_LT_GRAY), Graphics.COLOR_TRANSPARENT);
						} else { // Fr55
							dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
						}
        }
        dc.drawText( x - offset - LEDoffset, y - offset, IconsFont, ":", Graphics.TEXT_JUSTIFY_CENTER); 
    }
	
	/* ------------------------ */	
	
	// Draw the 3, 6, 9, and 12 hour labels.
    function drawHourLabels(dc, width, height, accent, hourLabel) {
    	// Load the custom fonts: used for drawing the 3, 6, 9, and 12 on the watchface
        var font = Application.loadResource(Rez.Fonts.id_font_black_diamond); 
				
				if (hourLabel) {
					dc.setColor(accent, Graphics.COLOR_TRANSPARENT);  
				} else if (width < 360){ // Using lighter tone for MIP displays 
						dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);  
				} else { // Darker tone for AMOLED
	    		dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);  
				}

        dc.drawText((width / 2), 14 + (width==208 ? -1 : 0), font, "12", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width - 13 + (width==208 ? 1 : 0), (height / 2) - 15, font, "3", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width / 2, height - 41 + (width==208 ? 1 : 0), font, "6", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(13 + (width==208 ? -1 : 0), (height / 2) - 15, font, "9", Graphics.TEXT_JUSTIFY_LEFT);
    }
    
	/* ------------------------ */
	
	/**
	 * Draws the weather icon on the display.
	 * 
	 * @param dc The display context.
	 * @param x The x-coordinate for the icon.
		if (cond != null && cond instanceof Number) {
	 * @param x2 The secondary x-coordinate for the icon.
	 * @param width The width of the display.
	 * @param cond The weather condition code.
	 * @param clockTime The current clock time in hours.
	 * @return Boolean indicating if the icon was drawn successfully.
	 */

function drawWeatherIcon(dc, x, y, x2, width, cond, clockTime) {
    
    // 1. FAST FAIL: Basic checks first
    if (cond == null || !(cond instanceof Number)) {
        return false;
    }
    if (!(Toybox has :Weather) || Toybox.Weather == null) {
        return false;
    }

    // 2. CACHE THE DATA: Call the API exactly once
    var conditions = Toybox.Weather.getCurrentConditions();
    if (conditions == null) {
        return false;
    }

    var sunset = 18;
    var sunrise = 6;
    var sunTimesLoaded = false;

		// 3a. SUNRISE/SUNSET VIA COMPLICATIONS (CIQ 4.2+)
    if (Toybox has :Complications) {
			var sunsetId = new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET);
			var sunriseId = new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE);
			
			var sunsetComp = Complications.getComplication(sunsetId);
			var sunriseComp = Complications.getComplication(sunriseId);

			// Check if the value is a Number (seconds since midnight)
			if (sunsetComp != null && sunsetComp.value instanceof Number && 
					sunriseComp != null && sunriseComp.value instanceof Number) {
					
					// Divide by 3600 to convert seconds since midnight into the 24-hour hour
					sunset = sunsetComp.value / 3600;
					sunrise = sunriseComp.value / 3600;
					sunTimesLoaded = true;
			}
    }

    // 3b. FALLBACK: Weather API for Sunrise/Sunset
    if (!sunTimesLoaded && Toybox.Weather has :getSunset && Toybox.Weather has :getSunrise) {
			var pos = conditions.observationLocationPosition;
			var today = conditions.observationTime;

			// By checking pos != null, we avoid the ERA crash you experienced on CIQ 7
			if (pos != null && pos instanceof Position.Location && today != null && today instanceof Time.Moment) {
				var sunsetMoment = Toybox.Weather.getSunset(pos, today);
				if (sunsetMoment != null) {
						sunset = Time.Gregorian.info(sunsetMoment, Time.FORMAT_SHORT).hour;
				}
				
				var sunriseMoment = Toybox.Weather.getSunrise(pos, today);
				if (sunriseMoment != null) {
						sunrise = Time.Gregorian.info(sunriseMoment, Time.FORMAT_SHORT).hour;
				}
			}
    }

    // Evaluate day/night exactly once
    var isNight = (clockTime >= sunset || clockTime < sunrise);

    // Layout adjustments
    if (width <= 280) {
        y = y - 2;
        if (width == 218) {
            y = y - 1;
        }
    } 

    var WeatherFont = Application.loadResource(Rez.Fonts.WeatherFont);      
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);

    // 4. "FREE" DATA EXTRACTION: Read directly from cached conditions
    var cloud = (conditions has :cloudCover) ? conditions.cloudCover : null;
    var uv = (conditions has :uvIndex) ? conditions.uvIndex.format("%d") : null;
    var precip = (conditions has :precipitationChance) ? conditions.precipitationChance : null;

    var align = Graphics.TEXT_JUSTIFY_RIGHT; 

    // 5. DRAWING & STRING BUILDING
    if (cond == 20) { // Cloudy
        dc.drawText(x2 - 1, y - 1, WeatherFont, "I", align); 
        condName = isNight ? "Cloudy Night" : "Cloudy Day";
        if (cloud != null) { condName = cloud + "% " + condName; }

    } else if (cond == 0 || cond == 5) { // Clear or Windy
        if (isNight) { 
            dc.drawText(x2 - 2, y - 1, WeatherFont, "f", align);
            condName = "Starry Night";
        } else {
            dc.drawText(x2, y - 2, WeatherFont, "H", align);
            condName = "Sunny Day";
            if (uv != null) { condName = condName + " (UV " + uv + ")"; }
        }

    } else if (cond == 1 || cond == 23 || cond == 40 || cond == 52) { // Partly Cloudy / Fair
        if (isNight) { 
            dc.drawText(x2 - 1, y - 2, WeatherFont, "g", align);
            condName = "Partly Cloudy";
            if (cloud != null) { condName = condName + " (" + cloud + "%)"; }
        } else {
            dc.drawText(x2, y - 2, WeatherFont, "G", align);
            condName = "Mostly Sunny";
            if (uv != null) { condName = condName + " (UV " + uv + ")"; }
        }

    } else if (cond == 2 || cond == 22) { // Mostly Cloudy
        if (isNight) { 
            dc.drawText(x2, y, WeatherFont, "h", align);
            condName = "Overcast Night";
        } else {
            dc.drawText(x, y, WeatherFont, "B", align);
            condName = "Mostly Cloudy";
        }
        if (cloud != null) { condName = condName + " (" + cloud + "%)"; }

    } else if (cond == 3 || cond == 14 || cond == 15 || cond == 11 || cond == 13 || cond == 24 || cond == 25 || cond == 26 || cond == 27 || cond == 45) { // Rain 
        if (isNight) { 
            dc.drawText(x2, y, WeatherFont, "c", align);
            condName = "Rainy Night";
        } else {
            dc.drawText(x, y, WeatherFont, "D", align);
            condName = "Rainy Day";
        }
        if (precip != null) { condName = precip + "% " + condName; }

    } else if (cond == 4 || cond == 10 || cond == 16 || cond == 17 || cond == 34 || cond == 43 || cond == 46 || cond == 48 || cond == 51) { // Snow
        if (isNight) { 
            dc.drawText(x2, y, WeatherFont, "e", align);
            condName = "Snowy Night";
        } else {
            dc.drawText(x, y, WeatherFont, "F", align);
            condName = "Snowy Day";
        }
        if (precip != null) { condName = precip + "% " + condName; }

    } else if (cond == 6 || cond == 12 || cond == 28 || cond == 32 || cond == 36 || cond == 41 || cond == 42) { // Thunder
        if (isNight) { 
            dc.drawText(x2, y, WeatherFont, "b", align);
        } else {
            dc.drawText(x, y, WeatherFont, "C", align);
        }
        condName = "Thunderstorms";

    } else if (cond == 7 || cond == 18 || cond == 19 || cond == 21 || cond == 44 || cond == 47 || cond == 49 || cond == 50) { // Wintry Mix
        if (isNight) { 
            dc.drawText(x2, y, WeatherFont, "d", align);
            condName = "Wintry Mix Night";
        } else {
            dc.drawText(x, y, WeatherFont, "E", align);
            condName = "Wintry Mix Day";
        }
        if (precip != null) { condName = precip + "% " + condName; }
          
    } else if (cond == 8 || cond == 9 || cond == 29 || cond == 30 || cond == 31 || cond == 33 || cond == 35 || cond == 37 || cond == 38 || cond == 39) { // Fog / Haze
        if (isNight) { 
            dc.drawText(x2, y, WeatherFont, "a", align);
            condName = "Foggy Night";
        } else {
            dc.drawText(x, y, WeatherFont, "A", align);
            condName = "Foggy Day";
        }           
    }

    return true;
}

/* old function
	function drawWeatherIcon(dc, x, y, x2, width, cond, clockTime) {
		
		var sunset, sunrise, precip="% ", cloud="%", uv="UV ";

		if (cond != null && cond instanceof Number){
			//System.println(clockTime);
			//var clockTime = System.getClockTime().hour;
//			clockTime = clockTime.hour;

			// gets the correct symbol (sun/moon) depending on actual sun events
			if (Toybox has :Weather && Toybox.Weather != null) {
				if (Toybox.Weather has :getCurrentConditions && Toybox.Weather.getCurrentConditions() != null) {
					if (Toybox.Weather has :getSunset && Toybox.Weather has :getSunrise) {
						var position=null, today=null;
						if ((Toybox.Weather.getCurrentConditions() has :observationLocationPosition && Toybox.Weather.getCurrentConditions().observationLocationPosition!=null) && (Toybox.Weather.getCurrentConditions() has :observationTime && Toybox.Weather.getCurrentConditions().observationTime!=null)){ //trying to address errors found on ERA viewer when watch can't get position. Not sure if only related to SDK 7.4.2 or overall for system 7
						//if (Toybox.Weather.getCurrentConditions() has :observationLocationPosition and Toybox.Weather.getCurrentConditions() has :observationTime){ //trying to address errors found on ERA viewer when watch can't get position
							position = Toybox.Weather.getCurrentConditions().observationLocationPosition; // or Activity.Info.currentLocation if observation is null?
							today = Toybox.Weather.getCurrentConditions().observationTime; // or new Time.Moment(Time.now().value()); ?
							if (Toybox.Weather.getCurrentConditions() has :precipitationChance and Toybox.Weather.getCurrentConditions().precipitationChance!=null){
								precip = Toybox.Weather.getCurrentConditions().precipitationChance + precip;
							}
							if (Toybox.Weather.getCurrentConditions() has :cloudCover and Toybox.Weather.getCurrentConditions().cloudCover!=null){
								cloud = Toybox.Weather.getCurrentConditions().cloudCover + cloud;
							}
							if (Toybox.Weather.getCurrentConditions() has :uvIndex and Toybox.Weather.getCurrentConditions().uvIndex!=null){
								uv = uv+Toybox.Weather.getCurrentConditions().uvIndex.format("%d");
							}
						}	
						if ((position!=null and position instanceof Position.Location) && (today != null && today instanceof Moment)){
							if (Weather.getSunset(position, today)!=null) {
								sunset = Time.Gregorian.info(Weather.getSunset(position, today), Time.FORMAT_SHORT);
								sunset = sunset.hour;
							} else {
								sunset = 18; 
							}
							if (Weather.getSunrise(position, today)!=null) {
								sunrise = Time.Gregorian.info(Weather.getSunrise(position, today), Time.FORMAT_SHORT);
								sunrise = sunrise.hour;
							} else {
								sunrise = 6;
							}
						} else {
							sunset = 18;
							sunrise = 6;
						}
					} else {
						sunset = 18;
						sunrise = 6;
					}			
				} else{
					return false;
				}
			} else {
				return false;
			}
					
			if (width<=280){
				y = y-2;
				if (width==218) {
					y = y-1;
				}
			} 

			//weather icon test
			//System.println(sunset);
			//sunset = 6;
			//sunrise = 1;

			var WeatherFont = Application.loadResource(Rez.Fonts.WeatherFont);			

			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			if (cond == 20) { // Cloudy
				dc.drawText(x2-1, y-1, WeatherFont, "I", Graphics.TEXT_JUSTIFY_RIGHT); // Cloudy
				if (clockTime >= sunset or clockTime < sunrise) { 
					condName="Cloudy Night";
				} else {
					condName="Cloudy Day";
				}
				condName=cloud.length()==1 ? condName : cloud+" "+condName;
			} else if (cond == 0 or cond == 5) { // Clear or Windy
				if (clockTime >= sunset or clockTime < sunrise) { 
					dc.drawText(x2-2, y-1, WeatherFont, "f", Graphics.TEXT_JUSTIFY_RIGHT); // Clear Night	
					condName="Starry Night";
				} else {
					dc.drawText(x2, y-2, WeatherFont, "H", Graphics.TEXT_JUSTIFY_RIGHT); // Clear Day
					condName="Sunny Day";
					condName=uv.length()==3 ? condName : condName+" ("+uv+")";
				}
			} else if (cond == 1 or cond == 23 or cond == 40 or cond == 52) { // Partly Cloudy or Mostly Clear or fair or thin clouds
				if (clockTime >= sunset or clockTime < sunrise) { 
					dc.drawText(x2-1, y-2, WeatherFont, "g", Graphics.TEXT_JUSTIFY_RIGHT); // Partly Cloudy Night
					condName="Partly Cloudy";
					condName=cloud.length()==1 ? condName : condName+" ("+cloud+")";
				} else {
					dc.drawText(x2, y-2, WeatherFont, "G", Graphics.TEXT_JUSTIFY_RIGHT); // Partly Cloudy Day
					condName="Mostly Sunny";
					condName=uv.length()==3 ? condName : condName+" ("+uv+")";
				}
			} else if (cond == 2 or cond == 22) { // Mostly Cloudy or Partly Clear
				if (clockTime >= sunset or clockTime < sunrise) { 
					dc.drawText(x2, y, WeatherFont, "h", Graphics.TEXT_JUSTIFY_RIGHT); // Mostly Cloudy Night
					condName="Overcast Night";
				} else {
					dc.drawText(x, y, WeatherFont, "B", Graphics.TEXT_JUSTIFY_RIGHT); // Mostly Cloudy Day
					condName="Mostly Cloudy";
				}
				condName=cloud.length()==1 ? condName : condName+" ("+cloud+")";
			} else if (cond == 3 or cond == 14 or cond == 15 or cond == 11 or cond == 13 or cond == 24 or cond == 25 or cond == 26 or cond == 27 or cond == 45) { // Rain or Light Rain or heavy rain or showers or unkown or chance  
				if (clockTime >= sunset or clockTime < sunrise) { 
					dc.drawText(x2, y, WeatherFont, "c", Graphics.TEXT_JUSTIFY_RIGHT); // Rain Night
					condName="Rainy Night";
				} else {
					dc.drawText(x, y, WeatherFont, "D", Graphics.TEXT_JUSTIFY_RIGHT); // Rain Day
					condName="Rainy Day";
				}
				condName=precip=="% " ? condName : precip+condName;
			} else if (cond == 4 or cond == 10 or cond == 16 or cond == 17 or cond == 34 or cond == 43 or cond == 46 or cond == 48 or cond == 51) { // Snow or Hail or light or heavy snow or ice or chance or cloudy chance or flurries or ice snow
				if (clockTime >= sunset or clockTime < sunrise) { 
					dc.drawText(x2, y, WeatherFont, "e", Graphics.TEXT_JUSTIFY_RIGHT); // Snow Night
					condName="Snowy Night";
				} else {
					dc.drawText(x, y, WeatherFont, "F", Graphics.TEXT_JUSTIFY_RIGHT); // Snow Day
					condName="Snowy Day";
				}
				condName=precip=="% " ? condName : precip+condName;
			} else if (cond == 6 or cond == 12 or cond == 28 or cond == 32 or cond == 36 or cond == 41 or cond == 42) { // Thunder or scattered or chance or tornado or squall or hurricane or tropical storm
				if (clockTime >= sunset or clockTime < sunrise) { 
					dc.drawText(x2, y, WeatherFont, "b", Graphics.TEXT_JUSTIFY_RIGHT); // Thunder Night
				} else {
					dc.drawText(x, y, WeatherFont, "C", Graphics.TEXT_JUSTIFY_RIGHT); // Thunder Day
				}
				condName="Thunderstorms";
			} else if (cond == 7 or cond == 18 or cond == 19 or cond == 21 or cond == 44 or cond == 47 or cond == 49 or cond == 50) { // Wintry Mix (Snow and Rain) or chance or cloudy chance or freezing rain or sleet
				if (clockTime >= sunset or clockTime < sunrise) { 
					dc.drawText(x2, y, WeatherFont, "d", Graphics.TEXT_JUSTIFY_RIGHT); // Snow+Rain Night
					condName="Wintry Mix Night";
				} else {
					dc.drawText(x, y, WeatherFont, "E", Graphics.TEXT_JUSTIFY_RIGHT); // Snow+Rain Day
					condName="Wintry Mix Day";
				}
				condName=precip=="% " ? condName : precip+condName;						
			} else if (cond == 8 or cond == 9 or cond == 29 or cond == 30 or cond == 31 or cond == 33 or cond == 35 or cond == 37 or cond == 38 or cond == 39) { // Fog or Hazy or Mist or Dust or Drizzle or Smoke or Sand or sandstorm or ash or haze
				if (clockTime >= sunset or clockTime < sunrise) { 
					dc.drawText(x2, y, WeatherFont, "a", Graphics.TEXT_JUSTIFY_RIGHT); // Fog Night
					condName="Foggy Night";
				} else {
					dc.drawText(x, y, WeatherFont, "A", Graphics.TEXT_JUSTIFY_RIGHT); // Fog Day
					condName="Foggy Day";
				}       		
			}
			return true;
		} else {
			return false;
		}
	}
	*/

	/* ------------------------ */
	function drawTemperature(dc, x, y, showBoolean, width, unit) {
    // 1. Check for Weather Support
    if (!(Toybox has :Weather)) {
        return false;
    }

    // 2. Fetch Weather (Cache the object!)
    var weather = Weather.getCurrentConditions();
    
    // 3. Early Exit (No weather data available)
    if (weather == null) {
        return false;
    }

    // 4. Select the Temperature to display
    var temp = null;
    if (showBoolean == false && weather.feelsLikeTemperature != null) {
        temp = weather.feelsLikeTemperature;
    } else if (weather.temperature != null) {
        temp = weather.temperature;
    }

    // 5. Second Early Exit (Data exists, but temperature is null)
    if (temp == null) {
        return false;
    }

    // 6. System Settings Short-Circuit
    // If 'unit' is true, the || operator short-circuits and skips calling getDeviceSettings() entirely!
    var isCelsius = unit || (System.getDeviceSettings().temperatureUnits == System.UNIT_METRIC);
    var unitsStr = isCelsius ? "°C" : "°F";

    var minTemp = weather.lowTemperature;
    var maxTemp = weather.highTemperature;

    // 7. Perform Math ONCE (Consolidated Fahrenheit conversion)
    if (!isCelsius) {
        temp = (temp * 1.8) + 32; 
        if (minTemp != null) { minTemp = (minTemp * 1.8) + 32; }
        if (maxTemp != null) { maxTemp = (maxTemp * 1.8) + 32; }
    }

    // 8. Layout Offset (Mutating 'y' directly)
    if (width == 390) { // Venu
        y -= 1;
    }

    // 9. Single-Pass Color Logic
    var tempColor = fontColor; // Default color
    if (minTemp != null && maxTemp != null) {
        var isDarkTheme = (fontColor == Graphics.COLOR_WHITE);
        if (temp <= minTemp) {
            tempColor = isDarkTheme ? Graphics.COLOR_BLUE : 0x0055AA; // Blue
        } else if (temp >= maxTemp) {
            tempColor = isDarkTheme ? 0xFFAA00 : 0xFF5500; // Orange
        }
    }

    // 10. Fix System 7 SDK Bug
    // .toNumber().toString() safely casts floats to ints faster than .format("%d")
    var tempStr = temp.toNumber().toString();

    // 11. Draw Temperature Value
    dc.setColor(tempColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y, Graphics.FONT_XTINY, tempStr, Graphics.TEXT_JUSTIFY_LEFT);
    
    // 12. Draw Unit Value
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x + dc.getTextWidthInPixels(tempStr, Graphics.FONT_XTINY), y, Graphics.FONT_XTINY, unitsStr, Graphics.TEXT_JUSTIFY_LEFT); 
    
    return true;
}


/* old function
	function drawTemperature(dc, x, y, showBoolean, width, unit) {
		
		var TempMetric = System.getDeviceSettings().temperatureUnits;
		var temp=null, units = "", minTemp=null, maxTemp=null;
		var weather = Weather.getCurrentConditions();

		if ((weather.lowTemperature!=null) and (weather.highTemperature!=null)){ // and weather.lowTemperature instanceof Number ;  and weather.highTemperature instanceof Number
			minTemp = weather.lowTemperature;
			maxTemp = weather.highTemperature;
		}

		var offset=0;

		if(width==390){ // venu
			offset=-1;
		}
			
		if (showBoolean == false and weather!=null and (weather.feelsLikeTemperature!=null)) { //feels like ;  and weather.feelsLikeTemperature instanceof Number
			if (TempMetric == System.UNIT_METRIC or unit) { //Celsius
				units = "°C";
				temp = weather.feelsLikeTemperature;
			}	else {
				temp = (weather.feelsLikeTemperature * 9/5) + 32; 
				if (minTemp!=null and maxTemp!=null){
					minTemp = (minTemp* 9/5) + 32;
					maxTemp = (maxTemp* 9/5) + 32;
				}
				//temp = Lang.format("$1$", [temp.format("%d")] );
				units = "°F";
			}				
		} else if(weather!=null and (weather.temperature!=null)) {  // real temperature ;  and weather.temperature instanceof Number
				if (TempMetric == System.UNIT_METRIC or unit) { //Celsius
					units = "°C";
					temp = weather.temperature;
				}	else {
					temp = (weather.temperature * 9/5) + 32; 
					if (minTemp!=null and maxTemp!=null){
						minTemp = (minTemp* 9/5) + 32;
						maxTemp = (maxTemp* 9/5) + 32;
					}
					//temp = Lang.format("$1$", [temp.format("%d")] );
					units = "°F";
				}
		}
		
		if (temp != null){ // and temp instanceof Number
			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			if ((minTemp != null) and (maxTemp != null)) { //  and minTemp instanceof Number ;  and maxTemp instanceof Number
				if (temp<=minTemp){
					if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
						dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT); // Light Blue 0x55AAFF
					} else { // Light Theme
						dc.setColor(0x0055AA, Graphics.COLOR_TRANSPARENT); 
					}
				} else if (temp>=maxTemp){
					if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
						dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT); // Light Orange
					} else { // Light Theme
						dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT);
					}
				}				
			}

			// correcting a bug introduced by System 7 SDK
			temp=temp.format("%d");

			dc.drawText(x, y+offset, Graphics.FONT_XTINY, temp, Graphics.TEXT_JUSTIFY_LEFT); // + units
			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			dc.drawText(x + dc.getTextWidthInPixels(temp,Graphics.FONT_XTINY), y+offset , Graphics.FONT_XTINY, units, Graphics.TEXT_JUSTIFY_LEFT); 
		}
	}
*/
	
	/* ------------------------ */
	
// Weather Condition Name (Now with Smart Sleep Score)
(:afterAPI6) function drawLocation(dc, x, y, showBoolean, logo, accentColor) {
    
	// 1. Early Exit: If the user disabled this field, don't do any math at all
	if (showBoolean == false) {
			return; 
	}

	// 2. Maintain your original layout coordinate adjustments
	if (x * 2 == 260 and logo) {
			y = y + 6;
	}

	//x -= 1;

	var textToDraw = condName;
	var isShowingSleep = false;
	var sleepScoreColor = Graphics.COLOR_TRANSPARENT; // Will be set dynamically
	var sleepScore = 0; // Will be set dynamically

	if (Toybox has :Complications) {
		// 3. Sleep Mode Detection Engine
		var clockTime = System.getClockTime(); // 24-hour time (hour: 0-23, day: 1-31)
		
		// Detect waking up (Date-based
		// Only evaluate during typical morning hours (5:00 AM - 11:59 AM))
		if (clockTime.hour >= 5 and clockTime.hour < 12) {
			var todayInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			// If we haven't registered a wake-up event for TODAY yet
			if (lastSleepScoreDay != todayInfo.day) {
				var sleepComp = Toybox.Complications.getComplication(new Toybox.Complications.Id(Toybox.Complications.COMPLICATION_TYPE_SLEEP_SCORE));
				
				// Once Garmin publishes today's sleep score, lock in the wake-up timestamp
				if (sleepComp != null and sleepComp.value != null) {
						wakeUpTimestamp = Time.now().value();
						lastSleepScoreDay = todayInfo.day; // Locks it in for today
				}				
			}
		}

		// 4. 30-Minute Timeout Logic
		if (wakeUpTimestamp > 0) {
			var secondsSinceWake = Time.now().value() - wakeUpTimestamp;
			
			if (secondsSinceWake <= 1800) { // 30 minutes = 1800 seconds	
				// Try to fetch the Sleep Score Complication
				var sleepComp = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_SLEEP_SCORE));					
				if (sleepComp != null and sleepComp.value != null) {
					// Override the weather text with the Sleep Score!
					sleepScore = sleepComp.value.toNumber(); // Cast to number for math checks
					textToDraw = "Today's sleep score: "; // + sleepScore.toString()
					isShowingSleep = true;
					
					var isDarkTheme = (fontColor == Graphics.COLOR_WHITE);
					
					// Garmin Official Sleep Score Brackets
					if (sleepScore >= 90) { // Excellent
							sleepScoreColor = isDarkTheme ? ((accentColor == 0xAAFF00) ? 0xAAFF00 : 0x55FF00) : 0x00AA00;
					} else if (sleepScore >= 80) { // Good
							sleepScoreColor = isDarkTheme ? Graphics.COLOR_BLUE : 0x0055AA;
					} else if (sleepScore >= 60) { // Fair
							sleepScoreColor = isDarkTheme ? 0xFFFF55 : 0xAAAA00; // Yellow
					} else { // Poor (< 60)
							sleepScoreColor = isDarkTheme ? Graphics.COLOR_ORANGE : 0xFF5500; // Orange/Red
					}
				}
			}
		} else {
				// 30 minutes have passed. Reset the timestamp so we stop checking until tomorrow.
				wakeUpTimestamp = 0;
		}
	}
	
	dc.setColor((fontColor == Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
	// Draw the final chosen text (Weather or Sleep)
	dc.drawText(x, y, Graphics.FONT_XTINY, textToDraw+"  ", Graphics.TEXT_JUSTIFY_CENTER);

	// 5. Drawing Logic
	if (isShowingSleep) {
		//x -= 1;
		dc.setColor(sleepScoreColor, Graphics.COLOR_TRANSPARENT); 
		dc.drawText(x/2+dc.getTextWidthInPixels(textToDraw,Graphics.FONT_XTINY)-dc.getTextWidthInPixels("  ",Graphics.FONT_XTINY), y, Graphics.FONT_XTINY, sleepScore.toString(), Graphics.TEXT_JUSTIFY_CENTER);
	}
	
}

	// Weather Condition Name
(:beforeAPI6) function drawLocation(dc, x, y, showBoolean, logo, accentColor) {
	if(x*2==260 and logo){
		y = y+6;
	}

	dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
	//dc.fitTextToArea(text, font, width, height, truncate)
	dc.drawText(x, y, Graphics.FONT_XTINY, showBoolean != false ? condName : "", Graphics.TEXT_JUSTIFY_CENTER);
}

	/* ------------------------ */
	
	// Notification Icon and Count
function drawNotification(dc, xIcon, yIcon, xText, yText, accentColor, width) {
    // 1. Cache the settings object (Only ask the system once)
    var notificationAmount = System.getDeviceSettings().notificationCount;
        
    if (notificationAmount != null) {
        
        // 2. Format Text (Use .toString() instead of the heavier .format())
        var formattedNotificationAmount = (notificationAmount > 99) ? "99+" : notificationAmount.toString();
        
        // Draw Text
        dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xText, yText, fontSize, formattedNotificationAmount, Graphics.TEXT_JUSTIFY_LEFT);
        
        // 3. Layout Offsets (Hardcoded integers replace slow floating-point math)
        var offset = 0;
        if (width >= 360) {
            if (width == 360) {
                offset = 7;
            } else {
                // Covers 390, 416, and 454 (Replaces width * 0.013 / 0.011)
                offset = 5; 
            }
        } else if (width == 218) { // VA 4s
            offset = 3; 
        } else if (width == 240 && dc.getFontHeight(0) >= 26) { // Fenix 5 Plus
            offset = -1; // Replaced -0.5 float with integer
        }

        // 4. Icon Color Logic (No string conversions!)
        var iconColor;
        if (notificationAmount == 0) { 
            // When notification count is zero
            iconColor = (fontColor == Graphics.COLOR_WHITE) ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY;
        } else {
            iconColor = accentColor;
        }

        // Draw Icon
        dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xIcon, yIcon + offset, IconsFont, "5", Graphics.TEXT_JUSTIFY_CENTER);
    }
}


/* old function
	function drawNotification(dc, xIcon, yIcon, xText, yText, accentColor, width) {

		var formattedNotificationAmount = "";
		var notificationAmount;    
       
		if (System.getDeviceSettings().notificationCount!=null) {
			notificationAmount = System.getDeviceSettings().notificationCount;
			if(notificationAmount > 99)	{
				formattedNotificationAmount = "99+";
			}
			else {
				formattedNotificationAmount = notificationAmount.format("%d");
			}
			
			// Text
			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			dc.drawText( xText, yText, fontSize, formattedNotificationAmount, Graphics.TEXT_JUSTIFY_LEFT);
			
			if (width==240 and dc.getFontHeight(0)>=26){ //Fenix 5 Plus
				yIcon=yIcon-0.5;
			} else if(width==360){
				yIcon=yIcon+(width*0.02);
			} else if(width>360 and width<440){
				yIcon=yIcon+(width*0.013);
			} else if(width>=440){
				yIcon=yIcon+(width*0.011);
			} else if(width==218){ // VA 4s
				yIcon=yIcon+(width*0.012);
			}

			// Icon
			if (formattedNotificationAmount.toNumber() == 0){ // when notification count is zero
//				if (width>=360){ //AMOLED (2021)
					dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
//				} else { // MIP, for better readability
//					dc.setColor( (accentColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_WHITE), Graphics.COLOR_TRANSPARENT); // if accent color is white and notification is zero, then icon color is gray
//				}
			} else {
				dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
			}
			dc.drawText( xIcon, yIcon, IconsFont, "5", Graphics.TEXT_JUSTIFY_CENTER);
		}
	}
*/	
	/* ------------------------ */

function drawHeartRate(dc, xIcon, hrIconY, xText, width, accentColor) {
    var heartRate = null;

    // 1. Try the Complications API first (Connect IQ 4.2.0+)
    if (Toybox has :Complications) {
        var hrComplicationId = new Complications.Id(Complications.COMPLICATION_TYPE_HEART_RATE);
        var hrComplication = Complications.getComplication(hrComplicationId);
        
        if (hrComplication != null && hrComplication.value != null) {
            heartRate = hrComplication.value;
        }
    }

    // 2. Fallback to Activity and ActivityMonitor for older devices
    if (heartRate == null) {
        if (Activity has :getActivityInfo) {
            heartRate = Activity.getActivityInfo().currentHeartRate; 
            
            if (heartRate == null) {
                if (ActivityMonitor has :getHeartRateHistory) {
                    var HRH = ActivityMonitor.getHeartRateHistory(1, true);
                    var HRS = HRH.next();
                    if (HRS != null && HRS.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                        heartRate = HRS.heartRate;
                    }
                }
            }
        }
    }

    // 3. Final default if no heart rate data is available from any source
    if (heartRate == null) {
        heartRate = 0;
    }

    // Render heart rate text
    var heartRateText = heartRate.format("%d");

		// Heart rate zones color definition (values for each zone are automatically calculated by Garmin)	
		var autoZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
		var heartRateZone = 0;

		if (autoZones!=null){
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
		} else { // Only when no default zones were detected
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
		
		// Choose the colour of the heart rate icon based on heart rate zone
		var heartRateIconColour;
		
		if (fontColor==Graphics.COLOR_WHITE){ // Dark Theme
			heartRateIconColour = Graphics.COLOR_DK_GRAY;
			
			if (heartRateZone == 1) { // Resting / Light load
				if (width==360 or width==390 or width==416){ //AMOLED
					heartRateIconColour = Graphics.COLOR_LT_GRAY;
				} else { // MIP, for better readability
					heartRateIconColour = Graphics.COLOR_WHITE;
				}
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
		} else { // Light Theme
			heartRateIconColour = Graphics.COLOR_BLACK;

			if (heartRateZone == 1) { // Resting / Light load
				heartRateIconColour = Graphics.COLOR_DK_GRAY;
			} else if (heartRateZone == 2) { // Moderate Effort
				heartRateIconColour = 0x0055AA; // Blue
			} else if (heartRateZone == 3) { // Weight Control
				heartRateIconColour = 0x00AA00; // Green
			} else if (heartRateZone == 4) { // Aerobic
				heartRateIconColour = 0xAAAA00; // Yellow
			} else if (heartRateZone == 5) { // Anaerobic
				heartRateIconColour = 0xFF5500; // Orange
			} else if (heartRateZone == 6){ // Maximum effort
				heartRateIconColour = 0xAA0000; // pastel red
			} else if (heartRateZone == 7){ // Speed
				heartRateIconColour = 0xFF0000; // bright red
			}
		}

		var offset=0;
		if (width >= 360) { // Venu, Venu 2 & 2s
			offset = 3;
			hrIconY = hrIconY + 1;
		}	else if(width==280){ // Fenix 6X & Enduro
			xText = xText-0.5;
			hrIconY = hrIconY - 4.5;
		}	else if(width==260){ // Fenix 6
			xText = xText-1.5;
			hrIconY = hrIconY - 4;
		}	else if(width==240){ // Fenix 6s
				xText = xText-0.5;
				hrIconY = hrIconY - 5;
				if (System.SCREEN_SHAPE_ROUND != screenShape){ //rectangle
					hrIconY = hrIconY + 1;
					xIcon = xIcon - 1;
					offset = 4;
				} else if(dc.getFontHeight(0)>=26){ // Fenix 5 Plus
					xIcon = xIcon - 1;
					offset = 4;
				}
		}	else if(width==218){ // VA4s
			xText = xText-1.5;
			hrIconY = hrIconY - 2;			
		}	else if(width==208){ // FR55
			offset = 1;
		}

		var FontAdj= 0;
		if (fontSize==1){ //big
				if (width==260 and dc.getFontHeight(Graphics.FONT_TINY)==29) { //Fenix 6
						FontAdj=6;
				} else if (width==260 and dc.getFontHeight(Graphics.FONT_TINY)==27) { // Vivoactive 4
						FontAdj=5; 
				} else if (width==280){
						FontAdj=7;
				} else if (width>=400) {
						FontAdj=5;
				} else if (width==218) {
						FontAdj=3;
				} else if (width==240 and dc.getFontHeight(Graphics.FONT_TINY)==26) { // Fenix 5, 5S, 5X, 7S
						FontAdj=3;
				} else {
						FontAdj=4;
				}
		}

		if (heartRate==0){
			heartRateText="--";
		}

		// Render heart rate icon and text
		dc.setColor(heartRateIconColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xIcon + offset/3 , hrIconY - 1, IconsFont, "3", Graphics.TEXT_JUSTIFY_CENTER); // Icon
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText, hrIconY - offset - FontAdj , fontSize, heartRateText, Graphics.TEXT_JUSTIFY_LEFT);	// Text	
	}

	/* ------------------------ */
	
	// Draw Battery Icon and Text	
	function drawBatteryIcon(dc, xBattery, yBattery, xContact, yContact, width, accentColor, greyIcon) {
	    
		var battery = Math.ceil(System.getSystemStats().battery);
		var batteryIconColour;
		var height=dc.getHeight();
				
		// Choose the colour of the battery based on it's state
		if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
			batteryIconColour = Graphics.COLOR_LT_GRAY;
			if (greyIcon!=false){ // Show battery colors
				if (battery <= 20) {
					batteryIconColour = 0xFF5555 /* pastel red */;
				} else if (battery <= 40) {
					batteryIconColour = 0xFFFF55 /* pastel yellow */;
				} else {
					if (accentColor == 0x55FF00 or canBurnIn == false) {
						batteryIconColour = 0x55FF00; /* GREEN */
					} else {
						batteryIconColour = 0xAAFF00; /* Vivomove GREEN */
					}
				}
			} 			
		} else { // Light Theme
			batteryIconColour = Graphics.COLOR_DK_GRAY;
			if (greyIcon!=false){ // Show battery colors
				if (battery <= 20) {
					batteryIconColour = 0xAA0000; /* red */
				} else if (battery <= 40) {
					batteryIconColour = 0xAAAA00; /* yellow  */
				} else {
					batteryIconColour = 0x00AA00; /* green */
				}
			}
		}

		//System.println(dc.getTextDimensions("100",0)[1]);
        
    // Render battery icon
		var offset = 0, offsetLED = 0;
		if (width==218) { // Vivoactive 4S
			offset = 1;	
		} else if (width==280) { //Enduro & Fenix 6X Pro
			offset = -1;
		} else if (width==416) { // Venu 2
			offsetLED = 2;
		} else if (System.SCREEN_SHAPE_ROUND != screenShape) { // Venu sq
			offsetLED = -5;
			offset = offset - 3;
			yBattery = yBattery - 3;
			xContact = xContact + 14;
			yContact = yContact - 2;
		} else if (width==240 and dc.getFontHeight(0)>=26){ //text height in pixels (Fenix 5 Plus)
			xBattery = xBattery - 5;
			offsetLED = -3;
			offset = -1;
			xContact = xContact + 7;
			yContact = yContact + 1;
		} else if (width==208){
			offsetLED = -2;
			offset = -1;
			yBattery = yBattery - 1;
		}

		dc.setColor(batteryIconColour, Graphics.COLOR_TRANSPARENT); 
		//dc.fillRoundedRectangle(x, y, width, height, radius)
		dc.fillRoundedRectangle(xBattery, yBattery , width*0.135 + (System.SCREEN_SHAPE_ROUND != screenShape ? 14 : 0) + (width==240 and dc.getFontHeight(0)>=26 and System.SCREEN_SHAPE_ROUND == screenShape ? 12 : 0), height*0.0625 - offsetLED, 2);
		dc.fillRoundedRectangle(xContact, yContact , width*0.018, height*0.039 - offset, 2);
	}
	
/* old function
	// Draw Battery Text (separate because of "too many arguments" error)
	function drawBatteryText(dc, xText, yText, width, estimateFlag, greyIcon) {	
	
		//var estimateFlag = Storage.getValue(19);

	  var battery=null;
	    
    if (Toybox has :Complications) {
        var batteryComplicationId = new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY);
        var batteryComplication = Complications.getComplication(batteryComplicationId);
        
        if (batteryComplication != null && batteryComplication.value != null) {
            battery = batteryComplication.value;
        }
    }

    // 2. Fallback to getSystemStats for older devices
    if (battery == null) {
			battery = Math.ceil(System.getSystemStats().battery);
		}

		var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var maxCharge = Storage.getValue(30);

				if (System.getSystemStats().charging==true or (maxCharge!=null and battery>maxCharge or (battery==maxCharge and battery==100))){
			var test = [
        today.hour,
        today.min,
        today.day,
        today.month,
        today.year
    	];
			Storage.setValue(29, test); // last time seen charging
			Storage.setValue(30, battery); // max percentage when charging
			//Storage.setValue(20, null); // reset last battery estimate
			Storage.setValue(31, null); // reset last estimated consumption data field
			//Storage.setValue(22, null); // reset last hourDiff calculation
		}

*/

	function drawBatteryText(dc, xText, yText, width, estimateFlag, greyIcon) { 
		var battery = null;
			
		if (Toybox has :Complications) {
				var batteryComplication = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY));
				
				if (batteryComplication != null && batteryComplication.value != null) {
						battery = batteryComplication.value;
				}
		}

		// Fallback to getSystemStats
		if (battery == null) {
				battery = Math.ceil(System.getSystemStats().battery);
		}

		var maxCharge = Storage.getValue(30);
		var lastChargeTime = Storage.getValue(29);
		var nowSec = Time.now().value(); // Get current epoch time in seconds
		var isCharging = System.getSystemStats().charging;

		// EFFICIENCY FIX: Only write to storage if battery went UP, 
		// OR if sitting on the charger we update the timestamp at most once every 5 minutes.
		if (isCharging == true || (maxCharge != null && battery > maxCharge)) {
			if (maxCharge == null || battery > maxCharge) {
				// Battery went up! Save new baseline.
				Storage.setValue(29, nowSec); 
				Storage.setValue(30, battery); 
				Storage.setValue(31, null); // Reset estimate
			} else if (isCharging && battery == maxCharge) {
				// Sitting on charger at max capacity. Keep moving the timestamp forward 
				// so the calculation starts when they UNPLUG it, but only write every 5 mins (300 sec)
				if (lastChargeTime == null || (nowSec - lastChargeTime) > 300) {
						Storage.setValue(29, nowSec);
				}
			}
		}
		var check = dc.getFontHeight(0);

		//System.println(dc.getTextDimensions("100",0)[1]);
		//System.println(width);

		var offset = 0, offsetLED = 0;
		if (width==390) { // Venu & D2 Air
			if (check>=33){ // Venu, D2 Air & Approach S70 42mm (33)
				offset = -2;
			} else if (check==30){ // FR165 (30)
				offset = 0;
			} else { // epix Pro Gen 2 42mm & MARQ Gen 2
				offset = -1;
			}
		} else if (width==280) { // Enduro & Fenix 6X Pro
			offset = 0.75;	
		}  else if (width<=218 or width==240) { // Vivoactive 4S & Fenix 6S & Vivoactive 3 Music
			if (width==218 and dc.getFontHeight(1)==23) { // FR255s
				offset = 0;			
			} else if (System.SCREEN_SHAPE_ROUND == screenShape) { 
				offset = -0.5;	
				if (width==240 and check>=26){ //Fenix 5 Plus or FR55
					offset = -2.5;
				} else if (width==208){
					offset = -3;
				}
			} else { // Venu sq
				offset = -4.5;	
				offsetLED = 6;
			}
		} else if (width==360) { // Venu 2 & 2s
			offset = -1;	
		} else if (width>=416) {
			if (width==454 and check==35){ // Venu 3
				offset = 1;
			}
			offsetLED = -1;
		}

		if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		} else { // Light Theme
			if (greyIcon==true){
				if (width==208 and battery > 40){
					dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
				} else {
					dc.setColor(((battery <= 40 and battery > 20) ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE), Graphics.COLOR_TRANSPARENT);
				}
			} else {
				dc.setColor((Graphics.COLOR_WHITE), Graphics.COLOR_TRANSPARENT);
			}
		}

		if (estimateFlag == true and System.getSystemStats() has :batteryInDays){ // user requested and watch supports
			if (System.getSystemStats().batteryInDays!=null and System.getSystemStats().batteryInDays!=0){ //trying to make sure that we don't get an error if batteryInDays not supported by watch
				battery = System.getSystemStats().batteryInDays;
			} 
		}
		
		dc.drawText(xText + offsetLED, yText + offset , 0 /* batteryFont */,battery.format("%d") + (estimateFlag == true and battery!=0 ? "d" : "%"), Graphics.TEXT_JUSTIFY_CENTER ); // Correct battery text on Fenix 5 series (except 5s)
	}


	/* ------------------------ */
/*
	function calcHourDiff(today) { // calculate hourDiff
		var lastCharge=Storage.getValue(29) as Array;
		var hourDiff = 0;
		
		hourDiff = (((today.hour - lastCharge[0])*60 + ((today.min - lastCharge[1])))/60d); 

		if (today.day != lastCharge[2]){ // different day
			hourDiff = ((today.day-lastCharge[2])*24) + hourDiff;
		}

		if (today.month != lastCharge[3]){ // different month
			var month_days=0;
			if (lastCharge[3]==2) {
				if ((lastCharge[4] % 400 == 0) or ( (lastCharge[4] % 4 == 0) and (lastCharge[4] % 100 != 0) )){ //leap year check
					month_days=29;
				} else {
					month_days=28;
				}
			} else if ((lastCharge[3]<=7 and lastCharge[3] % 3 == 0) or (lastCharge[3]>7 and lastCharge[3] % 2 == 0)){ //odd months before Aug or even months on/after Aug = 31 days
				month_days=31;
			} else{
				month_days=30;
			}
			hourDiff = ((today.month-lastCharge[3])*month_days*24)+hourDiff;
		}

		if (today.year != lastCharge[4]){ // different year
			var year_days=0;
			if ((lastCharge[4] % 400 == 0) or ( (lastCharge[4] % 4 == 0) and (lastCharge[4] % 100 != 0) )){ //leap year check
				year_days=366;
			} else {
				year_days=365;
			}
			hourDiff = ((today.year-lastCharge[4])*year_days*24)+hourDiff;
		}
		//Storage.setValue(32,hourDiff);
		return hourDiff;
	}
*/

	/* ------------------------ */

function drawBatteryConsumption(dc, xIcon, yIcon, xText, yText, width) {  
    var battery = Math.ceil(System.getSystemStats().battery);
    var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var text = null;
    
    var maxCharge = Storage.getValue(30);
    var lastChargeTime = Storage.getValue(29);

    if (System.getSystemStats().charging == true) {
        text = "chrng.";
    } else if (System.getSystemStats().charging == false && ((width >= 360 && today.sec % 30 == 0) || (width < 360 && today.sec == 0))) {
        
        if (maxCharge == null || lastChargeTime == null) { 
            text = "charge"; 
            Storage.setValue(31, "charge");
        } else if (battery >= maxCharge || (maxCharge - battery) < 1) { 
            // Wait for at least a 1% drop to avoid wild division-by-zero estimates
            text = "estim."; 
            Storage.setValue(31, "estim.");
        } else { 
            // Calculate elapsed hours directly from Epoch seconds
            var nowSec = Time.now().value();
            var hourDiff = (nowSec - lastChargeTime) / 3600.0;
            
            // Failsafe to prevent division by zero if time glitch occurs
            if (hourDiff > 0.1) {
                var consumption = ((maxCharge - battery) / hourDiff) * 24.0;
                
                if (consumption < 1) {
                    text = consumption.format("%.1f"); 
                } else if (consumption >= 100) {
                    text = "100";
                } else {
                    text = consumption.format("%.0f"); 
                }
                Storage.setValue(31, text);
            } else {
                text = "estim.";
            }
        }
    } else {
        text = Storage.getValue(31);
        if (text == null && maxCharge == null){
            text = "charge"; 
        } else if (text == null && maxCharge != null) {
            text = "estim."; 
        }
    }

/* old function
	function drawBatteryConsumption(dc, xIcon, yIcon, xText, yText, width) {	
	
		var battery = Math.ceil(System.getSystemStats().battery);
		var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var text = null;
		var maxCharge = Storage.getValue(30);

		if (System.getSystemStats().charging==true){
			text = "chrng.";
		} else if (System.getSystemStats().charging==false and ((width >=360 and today.sec % 30 == 0) or (width <360 and today.sec == 0))){ // 3 times per minute for AMOLED and 1 time per minute for MIP // or every 15 minutes -> and today.sec==0 and (today.min % 15 == 0)
			if (maxCharge==null){ // need to charge for the first time
				text = "charge"; // show percentage?
				Storage.setValue(31, "charge");
			}	else if (battery==maxCharge or maxCharge-battery<=1){ // still waiting for battery percentage to drop in order to calculate estimation
				text = "estim."; //text = "calc"; // show percentage?
				Storage.setValue(31, "estim.");
			} else{ // battery has dropped, so estimate is going to be calculated here
				// calculate hourDiff
				var hourDiff;
				hourDiff = calcHourDiff(today); //calculate hourDiff
						
				if(hourDiff==0){ //error, not expected on a real watch
					return false;
				}

				//Lang.format("$1$", [stepDistance.format("%.1f")] );
				text = ((maxCharge-battery)/hourDiff)*24; //text = battery*(hourdiff)/(battDiff)
				if (text<1){
					text = text.format("%.1f") ; // + "%/d" 
				} else if (text>=100){
					text = "100"; // "%/d"
				} else{
					text = text.format("%.0f") ; // + "%/d"
				}
				Storage.setValue(31, text);
				// text = Lang.format("$1$", [text.format("%.1f")] )  + "d";
			}
		} else {
			text = Storage.getValue(31);
			if (text == null and maxCharge == null){
				text = "charge"; // never charged
			} else if (text == null and maxCharge != null) {
				text = "estim."; // not able to calculate yet
			}
		}
*/

		if(width==280 or width==240){ 
			yIcon=yIcon-6;
		} else if (width==260){
			yIcon=yIcon-5;
		} else if (width==218){
			yIcon=yIcon-4;
		} else if (width>416){
			yIcon=yIcon-2;
		}

		if (width>=360){ //AMOLED (2021)
			dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
		} else { // MIP, for better readability
			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT); // if accent color is white and notification is zero, then icon color is gray
		}
		dc.drawText( xIcon, yIcon, IconsFont, "4", Graphics.TEXT_JUSTIFY_CENTER);
		
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText, yText, fontSize, text, Graphics.TEXT_JUSTIFY_LEFT);
		
		//if (text.toNumber() instanceof Number) {
		if (text != null && !text.equals("charge") && !text.equals("estim.") && !text.equals("chrng.")) {
        dc.drawText(xText + dc.getTextWidthInPixels(text, fontSize), yText + fontSize*((dc.getFontHeight(Graphics.FONT_TINY)-dc.getFontHeight(Graphics.FONT_XTINY))*0.9 - (width==360 ? 1 : 0)), 0, "%/d", Graphics.TEXT_JUSTIFY_LEFT);
    }
		return true;
	}


	/* ------------------------ */
	
	// Draw Do Not Disturb Icon
	function drawDndIcon(dc, x, y, width) {	
		
	    // If this device supports the Do Not Disturb feature,
        // load the associated Icon into memory.
		//var dndIcon;
		        
		if (System.getDeviceSettings() has :doNotDisturb and System.getDeviceSettings().doNotDisturb==true) {
			//dndIcon = Application.loadResource(Rez.Drawables.DoNotDisturbIcon);

			// Draw the do-not-disturb icon if we support it and the setting is enabled
			var offsetX = 0, offsetY = 0;
			if (width>=390) { // Venu & D2 Air
				offsetX = 7;	
				offsetY = 2;
			} else if (width==280 or width==260 or width==240){ // Fenix 6X & Enduro & Fenix 6
				offsetX = -1;
			} else if (width==218){ // VA4s
				offsetY = -2;
			} else if (width==360){ // Venu 2s
				offsetY = 2;
				offsetX = 2;
			}		

			if (width!=208){
				dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
			} else { // FR55
				dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			}

			dc.drawText( x + offsetX, y + offsetY , IconsFont, "Y", Graphics.TEXT_JUSTIFY_LEFT);
			return true;
		} else {
			//dndIcon = null;
			return false;
		}

}
    
	/* ------------------------ */
	
	// Draw Pulse Ox Icon and Text	
	function drawPulseOx(dc, xIcon, yIcon, xText, yText, width, accentColor) {          
    var pulseOx = null;

    // 1. Try Complications API First (API 4.2.0+)
    if (Toybox has :Complications) {
        var pulseOxComp = Toybox.Complications.getComplication(new Toybox.Complications.Id(Toybox.Complications.COMPLICATION_TYPE_PULSE_OX));
        
        if (pulseOxComp != null && pulseOxComp.value != null) {
            pulseOx = pulseOxComp.value;
        }
    }
    
    // 2. Fallback to Activity API (Cache the object!)
    if (pulseOx == null && Toybox has :Activity && Activity has :getActivityInfo) {
        var info = Activity.getActivityInfo(); // Called exactly ONCE
        if (info != null && info has :currentOxygenSaturation && info.currentOxygenSaturation != null) {
            pulseOx = info.currentOxygenSaturation;
        }
    }
    
    // 3. Early Exit (Skip layout math and memory allocation if there is no data)
    if (pulseOx == null) {
        return false;
    }
    
    // 4. Layout Offsets (Only executed if we are actually drawing!)
    // Integers are passed by value, so mutating yIcon directly saves us from declaring an 'offset' variable
    if (width >= 360) { // Venu & D2 Air
        yIcon += 7; 
    } else if (System.SCREEN_SHAPE_ROUND != screenShape) { // Venu sq
        yIcon -= 2;
    }
    
    // 5. Data Formatting & Single-Pass Color Logic
    var iconColor;
    var isDarkTheme = (fontColor == Graphics.COLOR_WHITE);

    if (pulseOx >= 95) { // Normal
        iconColor = isDarkTheme ? ((accentColor == 0xAAFF00) ? 0xAAFF00 : 0x55FF00) : 0x00AA00;
    } else if (pulseOx >= 85) { // Between Normal and Brain being affected
        iconColor = isDarkTheme ? Graphics.COLOR_BLUE : 0x0055AA;
    } else if (pulseOx >= 80) { // Brain affected
        iconColor = isDarkTheme ? 0xFFFF55 : 0xAAAA00;
    } else if (pulseOx >= 66) { // Between brain affected and cyanosis
        iconColor = isDarkTheme ? Graphics.COLOR_ORANGE : 0xFF5500;
    } else { // Cyanosis
        iconColor = isDarkTheme ? Graphics.COLOR_RED : 0xFF0000;
    }

    // 6. Draw Icon
    dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xIcon, yIcon, IconsFont, "Q", Graphics.TEXT_JUSTIFY_CENTER);
    
    // 7. Draw Text
    // .toNumber().toString() parses faster than formatting arrays
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText, yText, fontSize, pulseOx.toNumber().toString() + "%", Graphics.TEXT_JUSTIFY_LEFT);
    
    return true;
	}


/* old function
	function drawPulseOx(dc, xIcon, yIcon, xText, yText, width, accentColor) {	
          
		var pulseOx = null;
		if (Activity has :getActivityInfo and Activity.getActivityInfo() has :currentOxygenSaturation) {
			pulseOx = Activity.getActivityInfo().currentOxygenSaturation;
		}
		
		var offset = 0;
		if (width>=360) { // Venu & D2 Air
			offset = 7;	
		} else if (System.SCREEN_SHAPE_ROUND != screenShape){ // Venu sq
			offset = -2;
		}
		
		if (pulseOx!= null) {
			// Change the colour of the pulse Ox icon based on current value
			if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
				if (pulseOx >= 95) { // Normal
					if (accentColor == 0xAAFF00) {
						dc.setColor(0xAAFF00, Graphics.COLOR_TRANSPARENT); // Vivomove GREEN
					} else {
						dc.setColor(0x55FF00, Graphics.COLOR_TRANSPARENT); // GREEN
					}
				} else if (pulseOx >= 85) { // Between Normal and Brain being affected
					dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT); // Blue
				} else if (pulseOx >= 80) { // Brain affected
					dc.setColor(0xFFFF55, Graphics.COLOR_TRANSPARENT); // pastel yellow
				} else if (pulseOx >= 66) { // Between brain affected and cyanosis
					dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT); // orange
				} else { // Cyanosis
					dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT); // red
				}
			} else { // Light Theme
				if (pulseOx >= 95) { // Normal
					dc.setColor(0x00AA00, Graphics.COLOR_TRANSPARENT); // GREEN
				} else if (pulseOx >= 85) { // Between Normal and Brain being affected
					dc.setColor(0x0055AA, Graphics.COLOR_TRANSPARENT); // Blue
				} else if (pulseOx >= 80) { // Brain affected
					dc.setColor(0xAAAA00, Graphics.COLOR_TRANSPARENT); // pastel yellow
				} else if (pulseOx >= 66) { // Between brain affected and cyanosis
					dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT); // orange
				} else { // Cyanosis
					dc.setColor(0xFF0000, Graphics.COLOR_TRANSPARENT); // red
				}
			}

			dc.drawText( xIcon, yIcon + offset , IconsFont, "Q", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			//dc.drawText( xText, yText , fontSize, Lang.format("$1$%", [pulseOx.format("%.0f")] ), Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText( xText, yText, fontSize, pulseOx.format("%.0f") + "%", Graphics.TEXT_JUSTIFY_LEFT);
			return true;
		} else {
			return false;
		}
	}
/*

	/* ------------------------ */
	
	// Draw Floors Climbed Icon and Text
	function drawFloorsClimbed(dc, xIcon, yIcon, xText, yText, width, accentColor) {	
	
	  var floorsCount=null;
	    
    if (Toybox has :Complications) {
        var floorComplication = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_FLOORS_CLIMBED));
        
        if (floorComplication != null && floorComplication.value != null) {
            floorsCount = floorComplication.value;
        }
    }

    // 2. Fallback to Activity and ActivityMonitor for older devices
    if (floorsCount == null) {
			if (ActivityMonitor.getInfo() has :floorsClimbed) {
					floorsCount = ActivityMonitor.getInfo().floorsClimbed;
			} else {
					return false;
			}
		}

		var goal = ActivityMonitor.getInfo().floorsClimbedGoal;
		if (goal == null) { goal = 0; }
		
		if (floorsCount>=goal) {
			dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
		} else {
			if (width>=360){ //AMOLED
				dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
			} else { // MIP, for better readability
				dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			}
	  }
	    
    var offset = 0;
		if (width>=360) { // Venu & D2 Air
			offset = 7;	
		}	else if(width==260){
			offset = 1;
		}	else if(width==218){
			offset = 0.5;
		}
	    
		dc.drawText(xIcon, yIcon + offset , IconsFont, "1", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(xText, yText , fontSize, floorsCount, Graphics.TEXT_JUSTIFY_LEFT);
		return true;
    }

	/* ------------------------ */
	
	// Draw Steps
	function drawSteps(dc, xIcon, yIcon, xText, yText, width, accentColor) {	

		var distStr = null;
        
    var offsetY = 0;
		if (width>=360) { // Venu & D2 Air
			offsetY = 7;	
		} else if (width==260 or width==218){
			offsetY = 0.5;
			xIcon = xIcon+1;
		} else if (System.SCREEN_SHAPE_ROUND != screenShape){ // Venu sq
			yIcon = yIcon-1.5;
			xIcon = xIcon+1;
		}

    if (Toybox has :Complications) {
        var stepsComplication = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_STEPS));
        
        if (stepsComplication != null && stepsComplication.value != null) {
            distStr = stepsComplication.value;
						if (distStr instanceof Float) { // Garmin's Complications API returns integer before 10k and Float after 10k, but we want Integer always
							distStr = null; // Fallback to ActivityMonitor after 10k
						}
				}
    }

    // 2. Fallback to Activity and ActivityMonitor for older devices
    if (distStr == null) {
			distStr = ActivityMonitor.getInfo().steps;
			if (distStr == null) { distStr = 0; }	
		}
		
		var goal = ActivityMonitor.getInfo().stepGoal;
		if (goal == null) { goal = 0; }	
        
		if (distStr>=goal) {
			dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
		} else {
			if (width>=360){ //AMOLED
				dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
			} else { // MIP, for better readability
				dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			}
		} 
		dc.drawText( xIcon, yIcon + offsetY, IconsFont, "0", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		
		// Steps Text	        
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(xText , yText, fontSize, distStr, Graphics.TEXT_JUSTIFY_LEFT); // Step Text
	}


	/* ------------------------ */
	
	// Draw Distance Traveled
	function drawDistance(dc, xIcon, yIcon, xText, yText, width, accentColor) {	

		//var IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
		var DistanceMetric = System.getDeviceSettings().distanceUnits;
		var stepDistance = ActivityMonitor.getInfo().distance;//.toString();
		var distStr = "0";
		var unit = "";
        
		if (stepDistance != null) {
			
			if (DistanceMetric == System.UNIT_METRIC) {
					unit = " km";
					stepDistance = stepDistance * 0.00001;
			} else{
					unit = " mi";
					stepDistance = stepDistance * 0.00001 * 0.621371;
			}
		} else {
			stepDistance=0;
			unit = "?";
		}
			
		if (stepDistance >= 100) {
			distStr = stepDistance.format("%.0f");
		} else { //(stepDistance <10)
			distStr = stepDistance.format("%.1f");
		}	    		
        
    var offsetY = 0;
		if (width>=360) { // Venu & D2 Air
			offsetY = 7;	
		} else if (System.SCREEN_SHAPE_ROUND != screenShape) { // Venu sq
			offsetY = -2;
		} else if (width==240 and dc.getFontHeight(0)>=26){ // Fenix 5 Plus
			offsetY = -1;
		}
        
		var goal = ActivityMonitor.getInfo().stepGoal;
		if (goal == null) { goal = 0; }	

		if (ActivityMonitor.getInfo().steps!=null and ActivityMonitor.getInfo().steps>=goal) {
			dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
		} else {
			if (width>=360){ //AMOLED
				dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
			} else { // MIP, for better readability
				dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			}
		} 
		dc.drawText( xIcon, yIcon + offsetY, IconsFont, "7", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		
		// Distance Text	        
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(xText , yText, fontSize, distStr + unit, Graphics.TEXT_JUSTIFY_LEFT); // Step Distance
	}


	/* ------------------------ */
	
	// Draw Hour and Minute Hands
(:display) function drawHands(dc, width, height, accentColor, thickInd, aod, upTop, AODColor) {	
		var clockTime = System.getClockTime();
		var screenCenterPoint = [width/2, height/2];

		// Calculate the hour hand. Convert it to minutes and compute the angle.
		//var hourHandAngle = (((clockTime.hour % 12) * 60) + clockTime.min);
		//hourHandAngle = hourHandAngle / (12 * 60.0);
		//hourHandAngle = hourHandAngle * Math.PI * 2;
		var hourHandAngle = Math.PI/6*(1.0*clockTime.hour+clockTime.min/60.0);
		
		// Correct widths and lengths depending on resolution
		var offsetInnerCircle = 0;
		var offsetOuterCircle = 0;
		var triangle = 1.09;

		// thickInd = 0 --> Standard
		// thickInd = 1 --> Thicker
		// thickInd = 2 --> Thinner

		var handWidth = width as Float;
		if (handWidth==260){
			handWidth=10;
			offsetOuterCircle=-1;			
			if (thickInd == true or thickInd == 1) { // remove redundancies on later versions, true/false was used previously instead of 0,1,2
				handWidth = handWidth+3;
			} else if (thickInd == 2) { // thinner
				handWidth = handWidth-2;
			}
		} else if (handWidth==240){
			handWidth=10;
			offsetOuterCircle = -1;			
			if (thickInd == true or thickInd == 1) {
				handWidth = handWidth+2;
			} else if (thickInd == 2) {
				handWidth = handWidth-2;
			}
		} else if (handWidth==280){
			handWidth=11;
			offsetInnerCircle = 1;
			if (thickInd == true or thickInd == 1) {
				//offsetInnerCircle = 1;
				offsetOuterCircle = -0.5;
				handWidth = handWidth+4;
			} else if (thickInd == 2) {
				handWidth = handWidth-3;
			}
		} else if (handWidth<=218){ // Vivoactive 4S
			handWidth=8;
			//offsetInnerCircle = 1;
			offsetOuterCircle = -1;
			if (thickInd == true or thickInd == 1) {
				handWidth = handWidth+3;
				//offsetInnerCircle = 1;
				//offsetOuterCircle = 1;
			} else if (thickInd == 2) {
				handWidth = handWidth-1;
			}
		} else if (handWidth==360 or handWidth==320){ // Venu 2s and Sq2
			handWidth=15;
			offsetInnerCircle = 1;
			offsetOuterCircle = -1;
			if (thickInd == true or thickInd == 1) {
				handWidth = handWidth+5;
				offsetInnerCircle = 2;
				offsetOuterCircle = 0;
			} else if (thickInd == 2) {
				handWidth = handWidth-5;
			}
		} else if (handWidth>=390){ // Venu 1 & 2
			handWidth=14;
			offsetInnerCircle = 1;
			offsetOuterCircle = -1;
			if (thickInd == true or thickInd == 1) {
				handWidth = handWidth+5;
				offsetInnerCircle = 2;
				//offsetOuterCircle = 1;
			} else if (thickInd == 2) {
				handWidth = handWidth-4;
			}
		}
		
		var borderColor=Graphics.COLOR_BLACK, arborColor=Graphics.COLOR_LT_GRAY; // colors for not AOD mode
		//var BurnIn = System.getDeviceSettings().requiresBurnInProtection;
		if (aod==true and canBurnIn==true and AODColor != true) { //AOD mode ON
			accentColor=Graphics.COLOR_LT_GRAY;
			//arborColor=Graphics.COLOR_LT_GRAY;
			//borderColor=Graphics.COLOR_BLACK;
		}

		//Use white to draw the hour hand, with a dark grey background
		dc.setColor(borderColor, Graphics.COLOR_TRANSPARENT); //(centerPoint, angle, handLength, tailLength, width, triangle)
		dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 3.485, 0, Math.ceil(handWidth+(width*0.01)), triangle)); // hour hand border

		if(fontColor == Graphics.COLOR_BLACK){ // Light Theme
			arborColor = Graphics.COLOR_DK_GRAY;
		} 

		dc.setColor(((aod==true and canBurnIn==true and AODColor != true) or (fontColor == Graphics.COLOR_BLACK)) ? arborColor : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); // Light gray if AOD mode ON or White Theme, White if not (or MIP display)
		dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 3.54 , 0, handWidth, triangle-0.01)); // hour hand
		
		// Draw the minute hand.
		//var minuteHandAngle = (clockTime.min / 60.0) * Math.PI * 2;
		var minuteHandAngle = (clockTime.min / 30.0) * Math.PI;
		
		//generateHandCoordinates(centerPoint, angle, handLength, tailLength, width) -- width / (higher means smaller)
		dc.setColor(borderColor, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2.225, 0, Math.ceil(handWidth+(width*0.01)), triangle)); // minute hand border
		dc.setColor(accentColor, Graphics.COLOR_WHITE);
		dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2.25 , 0, handWidth, triangle-0.01)); // minute hand

		if(fontColor == Graphics.COLOR_BLACK){ // Light Theme
			//arborColor = Graphics.COLOR_LT_GRAY;
			arborColor = Graphics.COLOR_BLACK;
		} 
							
		// Draw the arbor in the center of the screen.
		dc.setColor(borderColor,Graphics.COLOR_BLACK);
		dc.fillCircle(width / 2, height / 2, handWidth*0.65-offsetOuterCircle); // *0.65
		dc.setColor((aod==true and canBurnIn==true) ? Graphics.COLOR_BLACK : arborColor, Graphics.COLOR_WHITE);
		dc.fillCircle(width / 2, height / 2, handWidth*0.65-offsetInnerCircle); // -4

		if (aod==true and canBurnIn==true)  {
			var checkerboard = Application.loadResource(Rez.Fonts.Checkerboard);
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			for (var row=(upTop) ? 1 : 0; row < height+48; row += 48) {
				for (var col=0 ; col <= width; col += 48) {
					dc.drawText( row, col , checkerboard, "@", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
				}
			}
			dc.fillRectangle( 0, 0 , width, 1); // Using Font
		} else if(secHands==true){ // seconds hand true
			if (canBurnIn==true or lowPower==false){ // AMOLED or MIP not in low-power mode
				// Seconds hand
				var secondHandAngle = (clockTime.sec / 60.0) * Math.PI * 2;
				dc.setColor(borderColor,Graphics.COLOR_BLACK);
				//dc.fillPolygon(generateHandCoordinates(screenCenterPoint, seicondHandAngle, width / 2.225, 22, Math.ceil(handWidth+(width*0.02))/3, triangle)); //pointed triangle
				dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.055, (width/15)+2, Math.ceil(handWidth+(width*0.0255))/2.75, 1.0)); //tip rectangle
				dc.setColor(accentColor, Graphics.COLOR_WHITE);
				//dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.25, 20, handWidth/3, triangle-0.01)); //pointed triangle
				dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.075, width / 15, handWidth/2.75, 1.0)); //rectangle
				// tip in different color
				if (fontColor == Graphics.COLOR_WHITE) { // Dark Theme
					dc.setColor(borderColor,Graphics.COLOR_BLACK);
					dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.055, -(width/2.25), Math.ceil(handWidth+(width*0.0255))/2.75, 1.0)); //rectangle
				}
				dc.setColor(((aod==true and canBurnIn==true and AODColor != true) or (accentColor == Graphics.COLOR_WHITE)) ? arborColor : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); // Light gray if AOD mode ON, White if not (or MIP display)
				dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.075, -(width/2.23), Math.ceil(handWidth-(width*0.0035))/2.75, 1.0)); //rectangle
			}
		}
	}


	(:crossover) function drawHands(dc, width, height, accentColor, thickInd, aod, upTop, AODColor) {	
		var clockTime = System.getClockTime();
		var screenCenterPoint = [width/2, height/2];

		// thickInd = 0 --> Standard
		// thickInd = 1 --> Thicker
		// thickInd = 2 --> Thinner

		var handWidth = width as Float;
		if (handWidth==260){
			handWidth=10;
			//offsetOuterCircle=-1;			
			if (thickInd == true or thickInd == 1) { // remove redundancies on later versions, true/false was used previously instead of 0,1,2
				handWidth = handWidth+3;
			} else if (thickInd == 2) { // thinner
				handWidth = handWidth-2;
			}
		} else if (handWidth==240){
			handWidth=10;
			//offsetOuterCircle = -1;			
			if (thickInd == true or thickInd == 1) {
				handWidth = handWidth+2;
			} else if (thickInd == 2) {
				handWidth = handWidth-2;
			}
		} else if (handWidth==280){
			handWidth=11;
			//offsetInnerCircle = 1;
			if (thickInd == true or thickInd == 1) {
				//offsetInnerCircle = 1;
				//offsetOuterCircle = -0.5;
				handWidth = handWidth+4;
			} else if (thickInd == 2) {
				handWidth = handWidth-3;
			}
		} else if (handWidth<=218){ // Vivoactive 4S
			handWidth=8;
			//offsetInnerCircle = 1;
			//offsetOuterCircle = -1;
			if (thickInd == true or thickInd == 1) {
				handWidth = handWidth+3;
				//offsetInnerCircle = 1;
				//offsetOuterCircle = 1;
			} else if (thickInd == 2) {
				handWidth = handWidth-1;
			}
		} else if (handWidth==360 or handWidth==320){ // Venu 2s and Sq2
			handWidth=15;
			//offsetInnerCircle = 1;
			//offsetOuterCircle = -1;
			if (thickInd == true or thickInd == 1) {
				handWidth = handWidth+5;
				//offsetInnerCircle = 2;
				//offsetOuterCircle = 0;
			} else if (thickInd == 2) {
				handWidth = handWidth-5;
			}
		} else if (handWidth>=390){ // Venu 1 & 2
			handWidth=14;
			//offsetInnerCircle = 1;
			//offsetOuterCircle = -1;
			if (thickInd == true or thickInd == 1) {
				handWidth = handWidth+5;
				//offsetInnerCircle = 2;
				//offsetOuterCircle = 1;
			} else if (thickInd == 2) {
				handWidth = handWidth-4;
			}
		}
		
		var borderColor=Graphics.COLOR_BLACK, arborColor=Graphics.COLOR_LT_GRAY; // colors for not AOD mode
		//var BurnIn = System.getDeviceSettings().requiresBurnInProtection;
		if (aod==true and canBurnIn==true and AODColor != true) { //AOD mode ON
			accentColor=Graphics.COLOR_LT_GRAY;
			//arborColor=Graphics.COLOR_LT_GRAY;
			//borderColor=Graphics.COLOR_BLACK;
		}

		if(fontColor == Graphics.COLOR_BLACK){ // Light Theme
			arborColor = Graphics.COLOR_DK_GRAY;
		} 

		if (aod==true and canBurnIn==true)  {
			var checkerboard = Application.loadResource(Rez.Fonts.Checkerboard);
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			for (var row=(upTop) ? 1 : 0; row < height+48; row += 48) {
				for (var col=0 ; col <= width; col += 48) {
					dc.drawText( row, col , checkerboard, "@", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
				}
			}
			dc.fillRectangle( 0, 0 , width, 1); // Using Font
		} else if(secHands==true){ // seconds hand true
			if (canBurnIn==true or lowPower==false){ // AMOLED or MIP not in low-power mode
				// Seconds hand
				var secondHandAngle = (clockTime.sec / 60.0) * Math.PI * 2;
				dc.setColor(borderColor,Graphics.COLOR_BLACK);
				//dc.fillPolygon(generateHandCoordinates(screenCenterPoint, seicondHandAngle, width / 2.225, 22, Math.ceil(handWidth+(width*0.02))/3, triangle)); //pointed triangle
				dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.055, (width/15)+2, Math.ceil(handWidth+(width*0.0255))/2.75, 1.0)); //tip rectangle
				dc.setColor(accentColor, Graphics.COLOR_WHITE);
				//dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.25, 20, handWidth/3, triangle-0.01)); //pointed triangle
				dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.075, width / 15, handWidth/2.75, 1.0)); //rectangle
				// tip in different color
				if (fontColor == Graphics.COLOR_WHITE) { // Dark Theme
					dc.setColor(borderColor,Graphics.COLOR_BLACK);
					dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.055, -(width/2.25), Math.ceil(handWidth+(width*0.0255))/2.75, 1.0)); //rectangle
				}
				dc.setColor(((aod==true and canBurnIn==true and AODColor != true) or (accentColor == Graphics.COLOR_WHITE)) ? arborColor : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); // Light gray if AOD mode ON, White if not (or MIP display)
				dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.075, -(width/2.23), Math.ceil(handWidth-(width*0.0035))/2.75, 1.0)); //rectangle
			}
		}
	}

    
	/* ------------------------ */
	
	// Draw Garmin Logo
	function drawGarminLogo(dc, x as Number, y as Number, theme) {	    
    	var garminIcon = null;
			
			if (theme){ // light theme
				garminIcon = Application.loadResource(Rez.Drawables.GarminLogoWhite);
			} else { // dark theme
				garminIcon = Application.loadResource(Rez.Drawables.GarminLogo);
			}

			dc.drawBitmap( x, y , garminIcon);
    }

	/* ------------------------ */
	
	// Draw Calories Burned
	function drawCalories(dc, xIcon, yIcon, xText, yText, width, type) {	
	
		//var IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
		var calories=0;
		var total_calories = ActivityMonitor.getInfo().calories; // Total
		
    if (Toybox has :Complications) {
        var caloriesComplication = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_CALORIES));
        
        if (caloriesComplication != null && caloriesComplication.value != null) {
            calories = caloriesComplication.value; // Active Calories
        }

			if (type==1) { // Total Calories				
				calories = total_calories;
			}
    } else { // 2. Fallback to Activity and ActivityMonitor for older devices			
			calories = total_calories;
			if (type==2){ // Active Calories formula by markdotai and topcaser (https://forums.garmin.com/developer/connect-iq/f/discussion/208338/active-calories/979052), with small adjustments by MtbA
				var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);		
				var profile = UserProfile.getProfile();
				var age = today.year - profile.birthYear;
				var weight = profile.weight / 1000.0;
				var restCalories=0, adj=0.5;

				if (profile.gender == UserProfile.GENDER_MALE) {
					restCalories = 5.2 - 6.116*age + 7.628*profile.height + 12.2*weight;
				} else {// female
					restCalories = -197.6 - 6.116*age + 7.628*profile.height + 12.2*weight;
				}

				if(today.hour>=18){ adj=0; }
				restCalories = Math.round(((today.hour*60+today.min) * restCalories / 1440 ) - adj).toNumber();
				calories = calories - restCalories; // active = total - rest
			} 
    }

    var offset = 0;
		if (width>=360) { // Venu & D2 Air
			offset = 7;	
		}	else if (System.SCREEN_SHAPE_ROUND != screenShape) { // Venu sq
			offset = -2;	
		} else if (width==240 and dc.getFontHeight(0)>=26){ //Fenix 5 Plus
			offset = -1;	
		}
	    
		// Icon
		if (width==360 or width==390 or width==416){ //AMOLED
			dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
		} else { // MIP, for better readability
			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		}		
		dc.drawText( xIcon, yIcon + offset , IconsFont, "6", Graphics.TEXT_JUSTIFY_CENTER); // Using Font

		// Text
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText , yText , fontSize, calories, Graphics.TEXT_JUSTIFY_LEFT);

	}

	/* ------------------------ */
	
	// Draw Elevation
function drawElevation(dc, xIcon, yIcon, xText, yText, width, side) { 
    // side 1 = left top
    // side 2 = left middle
    var elevation = null;

    // 1. Try Complications API First (API Level 4.2.0+)
    if (Toybox has :Complications) {
        var elevComp = Toybox.Complications.getComplication(new Toybox.Complications.Id(Toybox.Complications.COMPLICATION_TYPE_ALTITUDE));
        
        if (elevComp != null && elevComp.value != null) {
            // Safe conversion whether it returns a Number or Float
            elevation = elevComp.value.toFloat();
        }
    }

    // 2. Fallback to Activity API
    if (elevation == null && Activity has :getActivityInfo) {
        var info = Activity.getActivityInfo(); // Cache the info object
        if (info != null && info has :altitude && info.altitude != null) {
            elevation = info.altitude.toFloat();
        }
    }

    // 3. Layout Offsets (Icon)
    var offsetY = 0;
    if (width >= 360) { // Venu & D2 Air
        offsetY = 7;  
    } else if (width == 240 && dc.getFontHeight(0) >= 26) { // Fenix 5 Plus
        offsetY = -1;
    }
        
    // 4. Determine Icon Color mathematically
    var iconColor = (width == 360 || width == 390 || width == 416) 
        ? (fontColor == Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY) 
        : fontColor; // MIP fallback
        
    // Draw Icon
    dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xIcon, yIcon + offsetY, IconsFont, ";", Graphics.TEXT_JUSTIFY_CENTER); 

    // 5. Data Formatting
    var elevationStr = "";
    var unit = "N/A";
        
    if (elevation != null) {
        // Only fetch device settings if we actually have data to format
        var isMetric = (System.getDeviceSettings().elevationUnits == System.UNIT_METRIC);

        if (isMetric) {
            if (elevation >= 1000 && fontSize == 1 && width <= 240 && side == 2) {
                elevationStr = (elevation * 0.001).format("%.1f");
                unit = "km";
            } else {
                elevationStr = elevation.format("%.0f");
                unit = "m";
            }
        } else {
            // Statute units (Feet)
            elevationStr = (elevation * 3.28084).format("%.0f");
            unit = "ft";
        }
    }

    // 6. Draw Elevation Text
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText, yText, fontSize, elevationStr, Graphics.TEXT_JUSTIFY_LEFT); 

    // 7. Draw Unit
    var unitX = xText + dc.getTextWidthInPixels(elevationStr, fontSize);
    var unitYOffset = fontSize * ((dc.getFontHeight(Graphics.FONT_TINY) - dc.getFontHeight(Graphics.FONT_XTINY)) * 0.9 - (width == 360 || width == 260 ? 1 : 0) + (width == 208 ? 1 : 0));
    
    dc.drawText(unitX, yText + unitYOffset, 0, unit, Graphics.TEXT_JUSTIFY_LEFT);
}

/* old function	
	function drawElevation(dc, xIcon, yIcon, xText, yText, width, side) {	
		// side 1 = left top
		// side 2 = left middle

		//var IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
		var elevationMetric = System.getDeviceSettings().elevationUnits;
		var elevation=null;
		var elevationStr;
		var unit;
        
		if (Activity has :getActivityInfo and Activity.getActivityInfo() has :altitude) {
			//elevation = Activity.getActivityInfo().altitude;
			if(Activity.getActivityInfo().altitude!=null){
				elevation = Activity.getActivityInfo().altitude.toFloat();
			}
		}

		var offsetY = 0;
		if (width>=360) { // Venu & D2 Air
			offsetY = 7;	
//		} else if (System.SCREEN_SHAPE_ROUND != screenShape){ // Venu sq
//			offsetY = -1;
		} else if (width==240 and dc.getFontHeight(0)>=26){ // Fenix 5 Plus
			offsetY = -1;
		}
        
		if (width==360 or width==390 or width==416){ //AMOLED
			dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
		} else { // MIP, for better readability
			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		}
		dc.drawText( xIcon, yIcon + offsetY, IconsFont, ";", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
        
		elevationStr = elevation;			

    // Elevation Text	
		if (elevationStr != null and elevationMetric!=null) {
			if (elevationMetric == System.UNIT_METRIC) {
				unit = "m";				
				if (elevationStr >= 1000) {
					if (fontSize==1 and width<=240 and side==2){
						unit = "km";
					}
				}
			} else{
				unit = "ft";
				elevationStr = elevationStr * 3.28084;
			}
			if (elevationStr >= 1000 and elevationMetric == System.UNIT_METRIC and fontSize==1 and width<=240 and side==2) {
				elevationStr = elevationStr * 0.001;
				//elevationStr = Lang.format("$1$", [elevationStr.format("%.1f")] );
				elevationStr = elevationStr.format("%.1f");
			} else { //(elevation <1000)
				//elevationStr = Lang.format("$1$", [elevationStr.format("%.0f")] );
				elevationStr = elevationStr.format("%.0f");
			}
		} else {
			elevationStr="";
			unit = "N/A";
		}
       		
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(xText, yText, fontSize, elevationStr, Graphics.TEXT_JUSTIFY_LEFT); // Elevation in m or ft
		dc.drawText(xText + dc.getTextWidthInPixels(elevationStr,fontSize), yText + fontSize*((dc.getFontHeight(Graphics.FONT_TINY)-dc.getFontHeight(Graphics.FONT_XTINY))*0.9 - (width==360 or width==260? 1 : 0) + (width==208? 1 : 0)),	0, unit, Graphics.TEXT_JUSTIFY_LEFT);
	}
*/

/* ------------------------ */
	
	// Draw Atmospheric Pressure
function drawPressure(dc, xIcon, yIcon, xText, yText, width) {  
    var pressure = null;
    var wantsSeaLevel = (Storage.getValue(20) == true);

    // 1. Try Complications API First (Sea Level Pressure ONLY)
    if (wantsSeaLevel && Toybox has :Complications) {
        var pressComp = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE));
        
        if (pressComp != null && pressComp.value != null) {
            pressure = pressComp.value.toFloat(); // API returns pascals
        }
    }

    // 2. Fallback to Activity API (For older watches OR Ambient Pressure)
    if (pressure == null && Activity has :getActivityInfo) {
        var info = Activity.getActivityInfo(); // Cache this to prevent multiple API calls
        if (info != null) {
            if (wantsSeaLevel) {
                if (info has :meanSeaLevelPressure && info.meanSeaLevelPressure != null) {
                    pressure = info.meanSeaLevelPressure.toFloat();
                }
            } else {
                // User wants Ambient Pressure (No Complication available for this)
                if (info has :rawAmbientPressure && info.rawAmbientPressure != null) {
                    pressure = info.rawAmbientPressure.toFloat();
                } else if (info has :ambientPressure && info.ambientPressure != null) {
                    pressure = info.ambientPressure.toFloat();
                }
            }
        }
    }

    // 3. Layout Offsets (Icon)
    var offset = 0;
    if (width >= 360) { // Venu & D2 Air
        offset = 7; 
    } else if (System.SCREEN_SHAPE_ROUND != screenShape) { // Venu sq
        offset = -2;
    }

    // 4. Determine Data and Icon Color mathematically
    var pressureStr = "";
    var iconColor = (fontColor == Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY); // Default

    if (pressure != null) {
        // A. Dynamic Color Logic
        if (pressure < 100914.4) {
            // Low Pressure (Stormy/Rain) -> Orange
            iconColor = (fontColor == Graphics.COLOR_WHITE) ? 0xFFAA00 : 0xFF5500; 
        } else if (pressure > 102268.9) {
            // High Pressure (Fair/Clear) -> Blue
            iconColor = (fontColor == Graphics.COLOR_WHITE) ? Graphics.COLOR_BLUE : 0x0055AA; 
        }

        // B. Format the Text
        var isMetric = (System.getDeviceSettings().temperatureUnits == System.UNIT_METRIC || Storage.getValue(16) == true);
        
        if (isMetric) {
            pressureStr = (pressure * 0.01).format("%.0f"); // hPa
        } else {
            // Consolidated math: (0.01 * 0.02953) = 0.0002953 (inHg)
            pressureStr = (pressure * 0.0002953).format("%.1f"); 
        }
    }

    // 5. Draw Icon
    dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xIcon, yIcon + offset, IconsFont, "@", Graphics.TEXT_JUSTIFY_CENTER); 

    // 6. Draw Pressure Text
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText, yText, fontSize, pressureStr, Graphics.TEXT_JUSTIFY_LEFT); 
}

/* old function
	function drawPressure(dc, xIcon, yIcon, xText, yText, width) {	

		//var IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
		var pressure=null;
		//var unit= "";

		if (Storage.getValue(20)==true){ //Athmospheric Pressure Type
			if (Activity has :getActivityInfo and Activity.getActivityInfo() has :meanSeaLevelPressure and Activity.getActivityInfo().meanSeaLevelPressure!=null) {
				pressure = Activity.getActivityInfo().meanSeaLevelPressure;
			}
		} else {
			if (Activity has :getActivityInfo and Activity.getActivityInfo() has :rawAmbientPressure and Activity.getActivityInfo().rawAmbientPressure!=null) {
				pressure = Activity.getActivityInfo().rawAmbientPressure;
			} else if (Activity has :getActivityInfo and Activity.getActivityInfo() has :AmbientPressure and Activity.getActivityInfo().ambientPressure!=null){
				pressure = Activity.getActivityInfo().ambientPressure;
			}
		}

		var offset = 0;
		if (width>=360) { // Venu & D2 Air
			offset = 7;	
		} else if (System.SCREEN_SHAPE_ROUND != screenShape){ // Venu sq
			offset = -2;
		}

		dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);

		if (pressure!=null and pressure instanceof Float){
			if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
				if(pressure<100914.4) {
					dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT); 
				} else if (pressure>102268.9){
					dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT); 
				} 
			} else { // Light Theme
				if(pressure<100914.4) {
					dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT); 
				} else if (pressure>102268.9){
					dc.setColor(0x0055AA, Graphics.COLOR_TRANSPARENT); 	
				} 				
			}

			dc.drawText( xIcon, yIcon + offset , IconsFont, "@", Graphics.TEXT_JUSTIFY_CENTER); // Using Font

    // Pressure Text	
//		if (pressure != null and pressure instanceof Float) {
			if (System.getDeviceSettings().temperatureUnits == System.UNIT_METRIC or Storage.getValue(16)==true) { // Always Celsius
				pressure = pressure * 0.01 ; // divided by 100
				pressure = pressure.format("%.0f");				
				//unit = " hPa";
			} else {
				pressure = pressure * 0.01 * 0.02953; // inches of mercury
				pressure = pressure.format("%.1f");
				//unit = " inHg";
			}
			
		} else{
			pressure = "";
		}
       		
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(xText, yText, fontSize, pressure, Graphics.TEXT_JUSTIFY_LEFT); // pressure in hPa
	}
*/

	/* ------------------------ */
	
	// Draw Precipitation Percentage
(:tempo) function drawPrecipitation(dc, xIcon, yIcon, xText, yText, width) {	
	
		//var IconsFont = Application.loadResource(Rez.Fonts.HumidityFont);
	  var precipitation=0;
	    
		if (Toybox has :Weather and Toybox.Weather has :getCurrentConditions) {
				if (Weather.getCurrentConditions()!=null and Weather.getCurrentConditions().precipitationChance!=null){
					precipitation = Weather.getCurrentConditions().precipitationChance;//.toString();
				} else {
					return false;
				}
		} else {
			return false;
		}
	
    var offset = 0;
		if (width<=280){
			if (System.SCREEN_SHAPE_ROUND == screenShape) {
				xIcon = xIcon - 1;
				xText = xText - 6;
			} else { // Venu sq
				yIcon = yIcon - 5;
				xIcon = xIcon - 0.5;
				xText = xText - 3;
			}
		} else if (width>=360) { // Venu & D2 Air
			offset = 7;	
		}

		var precipitationIconColour;
		
		if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
			if (precipitation >= 90) { // Very High
				precipitationIconColour = 0xAA55FF; // Violet
			} else if (precipitation >= 60) { // High
				precipitationIconColour = 0x0055FF; // Dark Blue
			} else if (precipitation >= 30) { // Moderate
				precipitationIconColour = Graphics.COLOR_BLUE; // Blue
			} else if (precipitation > 0) { // Low
				precipitationIconColour = 0x00FFFF; // Light blue		
			} else { // Not existent
				precipitationIconColour = Graphics.COLOR_LT_GRAY;
			}  
		} else { // Light Theme
			if (precipitation >= 90) { // Very High
				precipitationIconColour = 0x5500AA; // Purple
			} else if (precipitation >= 60) { // High
				precipitationIconColour = 0x0055AA; // Cobalt
			} else if (precipitation >= 30) { // Moderate
				precipitationIconColour = 0x00AAAA; // Blue
			} else if (precipitation > 0) { // Low
				precipitationIconColour = 0x00AAFF; // Light blue		
			} else { // Not existent
				precipitationIconColour = Graphics.COLOR_DK_GRAY;
			}  
		}

	  dc.setColor(precipitationIconColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xIcon, yIcon + offset , IconsFont, "S", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText - offset , yText , fontSize, precipitation + "%", Graphics.TEXT_JUSTIFY_LEFT);
		
		return true;
    }

/* ------------------------ */
	
	// Draw Min and Max Temperatures
(:tempo) function drawMinMaxTemp(dc, xIcon, yIcon, xText, yText, width) { 
    
    // 1. Guard clauses for early exit
    if (!(Toybox has :Weather) || !(Weather has :getCurrentConditions)) { 
        return false; 
    }

    var weather = Weather.getCurrentConditions();
    if (weather == null || weather.lowTemperature == null || weather.highTemperature == null) {
        return false;
    }

    var minTemp = weather.lowTemperature;
    var maxTemp = weather.highTemperature;
    var units = "°C";

    // 2. Unit conversion
    if (System.getDeviceSettings().temperatureUnits != System.UNIT_METRIC && Storage.getValue(16) != true) {
        minTemp = (minTemp * 1.8) + 32; 
        maxTemp = (maxTemp * 1.8) + 32; 
        units = "°F";
    }

    // 3. Format strings early (fixes SDK 7 bug and prepares for width calculation)
    var minStr = minTemp.format("%d");
    var maxStr = maxTemp.format("%d");
      
    // 4. Calculate Y offset
    var offset = 0;
    if (width >= 360) { // Venu & D2 Air (AMOLED)
        offset = 7; 
    } else if (System.SCREEN_SHAPE_ROUND != screenShape) { // Venu sq
        offset = -2;  
    } else if (width == 240 && dc.getFontHeight(0) >= 26) { // Fenix 5 Plus
        offset = -1;
    }

    // 5. Draw Icon
    if (width >= 360) { // AMOLED
        dc.setColor(fontColor == Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    } else { // MIP
        dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    }
    dc.drawText(xIcon, yIcon + offset, IconsFont, ".", Graphics.TEXT_JUSTIFY_CENTER);

    // 6. Pre-calculate widths to avoid string concatenation garbage collection overhead
    var wMin = dc.getTextWidthInPixels(minStr, fontSize);
    var wSlash = dc.getTextWidthInPixels("/", fontSize);
    var wMax = dc.getTextWidthInPixels(maxStr, fontSize);

    // Draw Min Temp
    dc.setColor(fontColor == Graphics.COLOR_WHITE ? Graphics.COLOR_BLUE : 0x0055AA, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText, yText, fontSize, minStr, Graphics.TEXT_JUSTIFY_LEFT);

    // Draw Slash
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText + wMin, yText, fontSize, "/", Graphics.TEXT_JUSTIFY_LEFT);

    // Draw Max Temp
    dc.setColor(fontColor == Graphics.COLOR_WHITE ? 0xFFAA00 : 0xFF5500, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText + wMin + wSlash, yText, fontSize, maxStr, Graphics.TEXT_JUSTIFY_LEFT);

    // Draw Units
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText + wMin + wSlash + wMax, yText, fontSize, units, Graphics.TEXT_JUSTIFY_LEFT);
    
    return true;
}

/* old function
function drawMinMaxTemp(dc, xIcon, yIcon, xText, yText, width) {	
	
		//var IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
		var minTemp, maxTemp;
		var TempMetric = System.getDeviceSettings().temperatureUnits;
		var weather;
		var units = "";
    
		if (Toybox has :Weather and Toybox.Weather has :getCurrentConditions) { 
			weather = Weather.getCurrentConditions();
			if (weather!=null){
				if ((weather.lowTemperature!=null) and (weather.highTemperature!=null)){ //  and weather.lowTemperature instanceof Number ;  and weather.highTemperature instanceof Number
					minTemp = weather.lowTemperature;
					maxTemp = weather.highTemperature;
				} else { return false; }
			} else { return false; }
		} else {
			return false;
		}

		if (TempMetric == System.UNIT_METRIC or Storage.getValue(16)==true) { //Celsius
			units = "°C";
		}	else {
			minTemp = (minTemp * 9/5) + 32; 
			maxTemp = (maxTemp * 9/5) + 32; 
			//temp = Lang.format("$1$", [temp.format("%d")] );
			units = "°F";
		}
			
    var offset = 0;
		if (width>=360) { // Venu & D2 Air
			offset = 7;	
		}	else if (System.SCREEN_SHAPE_ROUND != screenShape) { // Venu sq
			offset = -2;	
		} else if (width==240 and dc.getFontHeight(0)>=26){ //Fenix 5 Plus
			offset = -1;
		}

		//precipitationIconColour = 0x00FFFF; // Light blue		
		//precipitationIconColour = 0xAA55FF; // Violet

		if (width>=360){ //AMOLED
			dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
		} else { // MIP, for better readability
			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		}
		dc.drawText( xIcon, yIcon + offset , IconsFont, ".", Graphics.TEXT_JUSTIFY_CENTER); // Using Font

		// correcting a bug introduced by System 7 SDK
		minTemp=minTemp.format("%d");
		maxTemp=maxTemp.format("%d");

		dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_BLUE : 0x0055AA), Graphics.COLOR_TRANSPARENT); // Light Blue 0x00FFFF / 0x55AAFF
		dc.drawText( xText, yText , fontSize, minTemp, Graphics.TEXT_JUSTIFY_LEFT); //Lang.format("$1$%",[precipitation])

		dc.setColor((fontColor==Graphics.COLOR_WHITE ? 0xFFAA00 : 0xFF5500), Graphics.COLOR_TRANSPARENT); // Purple 0xAA55FF
		dc.drawText( xText + dc.getTextWidthInPixels(minTemp+"/",fontSize) , yText , fontSize, maxTemp, Graphics.TEXT_JUSTIFY_LEFT); //Lang.format("$1$%",[precipitation])

		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText + dc.getTextWidthInPixels(minTemp,fontSize), yText , fontSize, "/", Graphics.TEXT_JUSTIFY_LEFT); //Lang.format("$1$%",[precipitation])
		dc.drawText( xText + dc.getTextWidthInPixels(minTemp+"/"+maxTemp,fontSize), yText , fontSize, units, Graphics.TEXT_JUSTIFY_LEFT); //Lang.format("$1$%",[precipitation])
		
		return true;
    }
*/

	/* ------------------------ */
	
	// Draw Humidity Percentage
(:tempo) function drawHumidity(dc, xIcon, yIcon, xText, yText, width, accentColor) {	
	
		//var IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
		var humidity=0;
		
		if (Toybox has :Weather and Toybox.Weather has :getCurrentConditions) {
			if (Weather.getCurrentConditions()!= null and Weather.getCurrentConditions().relativeHumidity != null){
				humidity = Weather.getCurrentConditions().relativeHumidity;//.toString();
			} else {
				return false;
			}
		} else {
			return false;
		}		

		var offsetY = 0;
		if (width>=360) { // Venu & D2 Air
			offsetY = 7;	
		} else if(width==260){
			offsetY = 1;
			xIcon = xIcon + 1;
		} else if(width==240){
			xIcon = xIcon + 1;
			if (System.SCREEN_SHAPE_ROUND == screenShape) { // not rectangle
				offsetY = -0.5;
			} else {
				offsetY = -1.5;
			}
		} else if(width==218){
			xIcon = xIcon + 1;
		} 

		if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
			if ((humidity > 0 and humidity < 25) or humidity >=70) { // Poor
				dc.setColor(0xFF5555, Graphics.COLOR_TRANSPARENT); // Red
			} else if (humidity < 30 or humidity >= 60) { // Fair
				dc.setColor(0xFFFF55, Graphics.COLOR_TRANSPARENT); // Yellow
			} else { // Healthy
				if (accentColor == 0xAAFF00) {
					dc.setColor(0xAAFF00, Graphics.COLOR_TRANSPARENT); /* Vivomove GREEN */
				} else {
					dc.setColor(0x55FF00, Graphics.COLOR_TRANSPARENT); // Green
				}
			}		
		} else { // Light Theme
			if ((humidity > 0 and humidity < 25) or humidity >=70) { // Poor
				dc.setColor(0xAA0000, Graphics.COLOR_TRANSPARENT); // Red
			} else if (humidity < 30 or humidity >= 60) { // Fair
				dc.setColor(0xAAAA00, Graphics.COLOR_TRANSPARENT); // Yellow
			} else { // Healthy
				dc.setColor(0x00AA00, Graphics.COLOR_TRANSPARENT); // Green
			}
		}
	    
		dc.drawText( xIcon, yIcon + offsetY , IconsFont, "A", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText , yText , fontSize, humidity + "%", Graphics.TEXT_JUSTIFY_LEFT);
		return true;
  }
	
	/* ------------------------ */		

(:tempo) function drawForecast(dc, xIcon, yIcon, width, size) {	
		//var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

		if (Toybox has :Weather and Toybox.Weather has :getHourlyForecast) {
				var forecast = null;
//			if ((width >=360 and today.sec % 30 == 0) or (width <360 and today.sec == 0)){  // 3 times per minute for AMOLED and 1 time per minute for MIP
				if(Weather.getHourlyForecast() != null) {
					forecast = Weather.getHourlyForecast();
					//forecast[-1].condition;
					if (forecast.size()>=1 and forecast[0].condition!=null){ // Trying to fix an error when weather data is not available
						//var info = Gregorian.info(forecast[0].forecastTime, Time.FORMAT_SHORT);
						var oneHour = new Time.Duration(3600); // 1 hour
						var info = Time.Gregorian.info(Time.now().add(oneHour), Time.FORMAT_SHORT);
						var x2Icon = xIcon + 1;
						drawWeatherIcon(dc, xIcon, yIcon, x2Icon, width, forecast[0].condition, info.hour);
						if (forecast.size()>=2 and forecast[1].condition!=null){
						var adj = xIcon + dc.getTextWidthInPixels("000", 0) + 1;
						oneHour = new Time.Duration(3600*2); // 2 hours
						info = Time.Gregorian.info(Time.now().add(oneHour), Time.FORMAT_SHORT);
						drawWeatherIcon(dc, adj, yIcon, adj, width, forecast[1].condition, info.hour);
						if (size==3 and width>208 and forecast.size()>=3 and forecast[2].condition!=null) { // don't go in if FR55 (not enough space/resolution for 3 hour forecast)
							adj = adj + dc.getTextWidthInPixels("000", 0) + 1;
							oneHour = new Time.Duration(3600*3); // 3 hours
							info = Time.Gregorian.info(Time.now().add(oneHour), Time.FORMAT_SHORT);
							drawWeatherIcon(dc, adj, yIcon, adj, width, forecast[2].condition, info.hour);
						}					
					}
				}
			}
		}
	}
	/* ------------------------ */	

	// Draw Wind Speed
(:tempo) function drawWindSpeed(dc, xIcon, yIcon, xText, yText, width) {	

		var WindMetric = System.getDeviceSettings().paceUnits;
		var windSpeed=null;
		var windBearing=null;
		var letter=null;
		var unit;
    var windIconColour = Graphics.COLOR_DK_GRAY;

		if (Toybox has :Weather and Toybox.Weather has :getCurrentConditions and Weather.getCurrentConditions() != null and Weather.getCurrentConditions().windSpeed != null and (Weather.getCurrentConditions().windBearing != null and Weather.getCurrentConditions().windBearing instanceof Number)){
			windSpeed = Weather.getCurrentConditions().windSpeed;//.toString();
			windBearing = Weather.getCurrentConditions().windBearing;//.toString();

			if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
				if (windSpeed >= 32.7) { // Hurricane Force
					windIconColour = 0xAA0000;
				} else if (windSpeed >= 28.5) { // Violent Storm
					windIconColour = 0xFF0000;
				} else if (windSpeed >= 24.5) { // Storm
					windIconColour = 0xFF5500;
				} else if (windSpeed >= 20.8) { // Strong Gale
					windIconColour = 0xFFAA00;
				} else if (windSpeed >= 17.2) { // Gale
					windIconColour = 0xFFAA55;
				} else if (windSpeed >= 13.9) { // Near Gale
					windIconColour = 0xAAFF00;
				} else if (windSpeed >= 10.8) { // Strong Breeze
					windIconColour = 0x55FF00;
				} else if (windSpeed >= 8) { // Fresh Breeze
					windIconColour = 0x00FF55;
				} else if (windSpeed >= 5.5) { // Moderate Breeze
					windIconColour = 0x55FFAA;
				} else if (windSpeed >= 3.4) { // Gentle Breeze
					windIconColour = 0xAAFFAA;
				} else if (windSpeed >= 1.6) { // Light Breeze
					windIconColour = 0x55FFFF;
				} else if (windSpeed >= 0.5) { // Light Air
					windIconColour = 0xAAFFFF; 
				} else { // Calm
					windIconColour = 0xFFFFFF; 
				}  
			} else { // Light Theme
				if (windSpeed >= 32.7) { // Hurricane Force
					windIconColour = 0xFF0000; 		// Bright Red OK
				} else if (windSpeed >= 28.5) { // Violent Storm
					windIconColour = 0xAA0000; 		// Dark Red OK
				} else if (windSpeed >= 24.5) { // Storm
					windIconColour = 0xFF5500; 		// Orange OK
				} else if (windSpeed >= 20.8) { // Strong Gale
					windIconColour = 0xFFAA00; 		// Light Orange OK
				} else if (windSpeed >= 17.2) { // Gale
					windIconColour = 0xFFAA55; 		// Lighter Orange OK
				} else if (windSpeed >= 13.9) { // Near Gale
					windIconColour = 0xAAAA00; 		// Yellow OK
				} else if (windSpeed >= 10.8) { // Strong Breeze
					windIconColour = 0xAAAA55; 		// Pastel Yellow OK
				} else if (windSpeed >= 8) { // Fresh Breeze
					windIconColour = 0x55AA00; 		// Light Green OK
				} else if (windSpeed >= 5.5) { // Moderate Breeze
					windIconColour = 0x00AA00; 		// Green OK
				} else if (windSpeed >= 3.4) { // Gentle Breeze
					windIconColour = 0x0055AA; 		// Cobalt OK
				} else if (windSpeed >= 1.6) { // Light Breeze
					windIconColour = 0x00AAAA; 		// Blue OK
				} else if (windSpeed >= 0.3) { // Light Air
					windIconColour = 0x00AAFF; 		// Light blue OK
				} else { // Calm
					windIconColour = 0x55AAFF; 		// Cyan OK
				}  
			}

			if (windBearing >= 335 or windBearing < 25) {
				letter = "N"; 
			} else if (windBearing >= 25 and windBearing < 65) {
				letter = "NE"; 
			} else if (windBearing >= 65 and windBearing < 115) {
				letter = "E"; 
			} else if (windBearing >= 115 and windBearing < 155) {
				letter = "SE"; 
			} else if (windBearing >= 155 and windBearing < 205) {
				letter = "S";
			} else if (windBearing >= 205 and windBearing < 245) {
				letter = "SW"; 
			} else if (windBearing >= 245 and windBearing < 295) {
				letter = "W"; 
			} else if (windBearing >= 295 and windBearing < 335) {
				letter = "NW"; 
			} else {
				letter = "P";
			}      
			if (letter.length()==2 and (width>260 or System.SCREEN_SHAPE_ROUND != screenShape or width==240)) {
				xIcon = xIcon - 2;
			} 
		}
        
		dc.setColor(windIconColour, Graphics.COLOR_TRANSPARENT);
		//dc.drawText( xIcon, yIcon + offset, IconsFont, "P", Graphics.TEXT_JUSTIFY_CENTER); // Icon Using Font

		if (width==360) { // Venu 2s
			xIcon = xIcon -1;
		} else if (width==280) { // Fenix 6X & Enduro
			yIcon = yIcon - 6;
		} else if (width==260 or width==240) { // Fenix 6 & 6s
			if (System.SCREEN_SHAPE_ROUND == screenShape){
				yIcon = yIcon - 4;
			} else {
				yIcon = yIcon - 6;
			}
		} else if (width==208) { // FR55
				yIcon = yIcon - 1;
				xIcon = xIcon - 1;
		}

		if (letter != null){
			dc.drawText( xIcon , yIcon, Graphics.FONT_TINY, letter, Graphics.TEXT_JUSTIFY_CENTER); // Icon Using Font    
		}

    // Wind Speed Text	
		var WindUnit = Storage.getValue(15);
		if (windSpeed != null and WindUnit==0) { // not in m/s or knots
      if (WindMetric == System.UNIT_METRIC) {
				windSpeed = windSpeed * 3.6; //converting from m/s to km/h
				if (width<=218) {
					unit = "kph";
				} else if (fontSize==1 and width<=240) {
					unit = " kph";
				} else {
					unit = " km/h";
				}
			} else{
				windSpeed = windSpeed * 2.22369; //converting from m/s to mph
				unit = " mph";
			}
		} else if (windSpeed != null and WindUnit==2){ // knots
			windSpeed = windSpeed * 1.94384449; //converting from m/s to knots
			unit = " kts";
		} else { // m/s
			unit = " m/s";
		}

		if (windSpeed != null){
			var windStr = Math.round(windSpeed).format("%.0f");
			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			dc.drawText(xText , yText, fontSize, windStr, Graphics.TEXT_JUSTIFY_LEFT); // Wind Speed in km/h or mph
			dc.drawText(xText + dc.getTextWidthInPixels(windStr,fontSize), yText + fontSize*((dc.getFontHeight(Graphics.FONT_TINY)-dc.getFontHeight(Graphics.FONT_XTINY))*0.9 - (width==360 or width==260? 1 : 0) + (width==208? 1 : 0)),	0, unit, Graphics.TEXT_JUSTIFY_LEFT);
		}     
	}

	/* ------------------------ */
	
	// Draw Solar Intensity
	function drawSolarIntensity(dc, xIcon, yIcon, xText, yText, width, accentColor) { 
    var solarIntensity = null;

/* Returns incorrect numbers for now (Aug/2026 - SDK 9.2.0) - Garmin is aware of the issue and is working on a fix (https://forums.garmin.com/developer/connect-iq/i/bug-reports/the-solar-input-data-collected-from-complications-complication_type_solar_input-don-t-make-sense).
    // 1. Try Complications API First (API 4.2.0+)
    if (Toybox has :Complications) {
        var solarComp = Toybox.Complications.getComplication(new Toybox.Complications.Id(Toybox.Complications.COMPLICATION_TYPE_SOLAR_INPUT));
        
        if (solarComp != null && solarComp.value != null) {
            solarIntensity = solarComp.value;
        }
    }
*/

    // 2. Fallback to SystemStats API (Cache the heavy object!)
    if (solarIntensity == null && System has :getSystemStats) {
        var stats = System.getSystemStats(); // Called exactly ONCE
        if (stats has :solarIntensity && stats.solarIntensity != null) {
            solarIntensity = stats.solarIntensity;
        }
    }
    
    // 3. Early Exit (Skip layout math if the watch has no solar panel)
    if (solarIntensity == null) {
        return false;
    }

    // 4. Single-Pass Color Logic (Flattened)
    var solarIconColour;
    var isDarkTheme = (fontColor == Graphics.COLOR_WHITE);

    if (solarIntensity >= 80) { // Extreme
        solarIconColour = isDarkTheme ? 0xAA55FF : 0xFF00AA; 
    } else if (solarIntensity >= 60) { // Very High
        solarIconColour = isDarkTheme ? Graphics.COLOR_RED : 0xFF0000; 
    } else if (solarIntensity >= 40) { // High
        solarIconColour = isDarkTheme ? 0xFFAA00 : 0xFF5500; 
    } else if (solarIntensity >= 20) { // Moderate
        solarIconColour = isDarkTheme ? 0xFFFF55 : 0xAAAA00; 
    } else if (solarIntensity > 0) { // Low
        // Nested ternary applied to safely handle the accent color check
        solarIconColour = isDarkTheme ? ((accentColor == 0xAAFF00) ? 0xAAFF00 : 0x55FF00) : 0x00AA00;
    } else { // Non-existent
        solarIconColour = isDarkTheme ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY;
    }

    // 5. Layout Offsets (Only calculated if rendering)
    // Modifying yIcon directly saves us from declaring a separate 'offsetY' variable
    if (width == 280 || width == 240) { // Fenix 6X & Enduro
        yIcon -= 2;
    } else if (width == 260) {
        yIcon -= 1; // Rounding -0.5 to nearest integer to avoid float coercion!
    }
      
    // 6. Draw Icon
    dc.setColor(solarIconColour, Graphics.COLOR_TRANSPARENT); 
    dc.drawText(xIcon, yIcon, IconsFont, "R", Graphics.TEXT_JUSTIFY_CENTER); 
    
    // 7. Draw Text
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText, yText, fontSize, solarIntensity.toNumber().toString() + "%", Graphics.TEXT_JUSTIFY_LEFT);
    
    return true;
	}

/* old function
	function drawSolarIntensity(dc, xIcon, yIcon, xText, yText, width, accentColor) {	
	
		var solarIntensity=0;
		
		if (System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) {
			solarIntensity = System.getSystemStats().solarIntensity;//.toString();
		} else {
			return false;
		}
		
		var solarIconColour = null;

		if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
			if (solarIntensity >= 80) { // Extreme
				solarIconColour = 0xAA55FF; 
			} else if (solarIntensity >= 60) { // Very High
				solarIconColour = Graphics.COLOR_RED; 
			} else if (solarIntensity >= 40) { // High
				solarIconColour = 0xFFAA00; 
			} else if (solarIntensity >= 20) { // Moderate
				solarIconColour = 0xFFFF55; 
			} else if (solarIntensity > 0) { // Low
				if (accentColor == 0xAAFF00) {
					solarIconColour = 0xAAFF00; // Vivomove GREEN
				} else {
					solarIconColour = 0x55FF00; // GREEN
				}		
			} else { // Not existent
				solarIconColour = Graphics.COLOR_LT_GRAY;
			}  
		} else { // Light Theme
			if (solarIntensity >= 80) { // Extreme
				solarIconColour = 0xFF00AA; // Cerise
			} else if (solarIntensity >= 60) { // Very High
				solarIconColour = 0xFF0000; // Red
			} else if (solarIntensity >= 40) { // High
				solarIconColour = 0xFF5500; // Orange
			} else if (solarIntensity >= 20) { // Moderate
				solarIconColour = 0xAAAA00; // Yellow
			} else if (solarIntensity > 0) { // Low
				solarIconColour = 0x00AA00; // GREEN		
			} else { // Not existent
				solarIconColour = Graphics.COLOR_DK_GRAY;
			}  		
		}

    var offsetY = 0;
		if (width==280 or width==240) { // Fenix 6X & Enduro
			offsetY = -2;
		}	else if (width==260){
			offsetY = -0.5;
		}
	    
    dc.setColor(solarIconColour, Graphics.COLOR_TRANSPARENT); 
		dc.drawText( xIcon, yIcon + offsetY , IconsFont, "R", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText , yText , fontSize, solarIntensity + "%", Graphics.TEXT_JUSTIFY_LEFT);
		return true;
  }
*/

	/* ------------------------ */
	
	function drawSeconds(dc, xIcon, yIcon, xText, yText, width, type) {
		var clockTime = System.getClockTime();
		var seconds = clockTime.sec.format("%02d");
		var am_pm="";

		if (type==2){ //digital clock
			if (System.getDeviceSettings().is24Hour==false){
				am_pm="AM";
				if (clockTime.hour >= 12){
					clockTime.hour = clockTime.hour-12;
					am_pm="PM";
				}
				if (clockTime.hour == 0){
					clockTime.hour = 12;
				}
			}
			seconds = clockTime.hour.format("%2d") + ":" + clockTime.min.format("%02d");
			if (clockTime.hour < 10 and clockTime.hour > 0 and width>=240){
				xText=xText-(dc.getTextWidthInPixels(clockTime.hour.format("%2d"),fontSize))/2;
			} else {
				xText=xText-(dc.getTextWidthInPixels("1",fontSize))/2;
			}
		}

		// placeholder for future implementation of Partial Update
		/*
		dc.setClip(
				mSecondsClipRectX + mSecondsClipXAdjust,
				mSecondsClipRectY,
				mSecondsClipRectWidth,
				mSecondsClipRectHeight
		)
		dc.setColor(gThemeColour, Graphics.COLOR_RED);
		dc.clear();
		*/
		
		if (width>=360){ //AMOLED
			dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
		} else { // MIP displays, for better readability
			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			yIcon = yIcon-5; // 3?
		}

		if (width==240 and System.SCREEN_SHAPE_ROUND == screenShape){
			yIcon = yIcon - 1.5;
			if (dc.getFontHeight(0)>=26){ // Fenix 5 Plus
				yIcon = yIcon + 1;
			}
		} else if (width==218){
			yIcon = yIcon + 1;
		}

		dc.drawText( xIcon, yIcon, IconsFont, "2", Graphics.TEXT_JUSTIFY_CENTER); // Using Font

		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		if (lowPower==false) {
			dc.drawText(xText, yText,	fontSize, seconds, Graphics.TEXT_JUSTIFY_LEFT);
		}

		if (type==2){ //digital clock
			//dc.drawText(xText + dc.getTextWidthInPixels(seconds,fontSize), yText + fontSize*((dc.getFontHeight(Graphics.FONT_TINY)-dc.getFontHeight(Graphics.FONT_XTINY))*0.9 - (width>=360 ? 1 : 0)),	0, am_pm, Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(xText + dc.getTextWidthInPixels(seconds,fontSize), yText + fontSize*((dc.getFontHeight(Graphics.FONT_TINY)-dc.getFontHeight(Graphics.FONT_XTINY))*0.9 - (width>=360 ? 1 : 0)),	0, am_pm, Graphics.TEXT_JUSTIFY_LEFT);
		}

	}

	/* ------------------------ */
	
	function drawIntensityMin(dc, xIcon, yIcon, xText, yText, width, accentColor) {
	  var intensity=null;
	    
    if (Toybox has :Complications) {
        var intensityComplicationId = new Complications.Id(Complications.COMPLICATION_TYPE_INTENSITY_MINUTES);
        var intensityComplication = Complications.getComplication(intensityComplicationId);
        if (intensityComplication != null && intensityComplication.value != null) {
            intensity = intensityComplication.value;
        }
    }

    // 2. Fallback to Activity and ActivityMonitor for older devices
    if (intensity == null) {
			if (ActivityMonitor.getInfo().activeMinutesWeek.total != null and ActivityMonitor.getInfo().activeMinutesWeekGoal!=null) {
					intensity = ActivityMonitor.getInfo().activeMinutesWeek.total;
			} else {
					return false;
			}
		}

		if (intensity>=ActivityMonitor.getInfo().activeMinutesWeekGoal) {
			dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
		} else {
			if (width>=360){ //AMOLED
				dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
			} else { // MIP, for better readability
				dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			}
	  }

		if (width<300 and System.SCREEN_SHAPE_ROUND == screenShape){
			yIcon = yIcon-5;
			if (dc.getFontHeight(0)>=26){
				yIcon = yIcon - 1;
			}
			if (width==218){
				yIcon = yIcon + 1;
			}
		}

		dc.drawText( xIcon, yIcon, IconsFont, "B", Graphics.TEXT_JUSTIFY_CENTER); // Using Font

		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(xText, yText,	fontSize, intensity, Graphics.TEXT_JUSTIFY_LEFT);

		return true;
	}

/* ------------------------ */
	function drawBodyBattery(dc, xIcon, yIcon, xText, yText, width) {
    var bbValue = null;
    var supportsBodyBattery = false;

    // 1. Try Complications API First (API 4.2.0+)
    if (Toybox has :Complications) {
        supportsBodyBattery = true;
        var bbComp = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_BODY_BATTERY));
        
        if (bbComp != null && bbComp.value != null) {
            bbValue = bbComp.value;
        }
    }

    // 2. Fallback to SensorHistory API
    if (bbValue == null && Toybox has :SensorHistory && SensorHistory has :getBodyBatteryHistory) {
        supportsBodyBattery = true;
        var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
        if (bbIterator != null) {
            var sample = bbIterator.next();
            if (sample != null && sample.data != null) {
                bbValue = sample.data;
            }
        }
    }

    // 3. Early Exit! (If hardware doesn't support Body Battery at all, skip execution)
    if (!supportsBodyBattery) {
        return false;
    }

    // 4. Layout Offsets (Evaluated only when rendering is guaranteed)
    var offset = 0;
    if (width >= 360) { // Venu & D2 Air
        offset = 7; 
    } else if (System.SCREEN_SHAPE_ROUND != screenShape) { // Venu sq
        offset = -2;  
    } else if (width == 240 && dc.getFontHeight(0) >= 26) { // Fenix 5 Plus
        offset = -1;
    }

    // 5. Data Formatting & Single-Pass Threshold Consolidation
    var iconColor;
    var textStr;

    if (bbValue != null) {
        textStr = bbValue.format("%d"); // .toString() is faster than format("%d")
        var isDarkTheme = (fontColor == Graphics.COLOR_WHITE);

        if (bbValue <= 25) {
            iconColor = isDarkTheme ? Graphics.COLOR_RED : 0xAA0000;
        } else if (bbValue <= 50) {
            iconColor = isDarkTheme ? 0xFFAA00 : 0xFF5500; // Orange
        } else if (bbValue <= 75) {
            iconColor = isDarkTheme ? 0xFFFF55 : 0xAAAA00; // Yellow
        } else {
            iconColor = isDarkTheme ? Graphics.COLOR_BLUE : 0x0055AA; // Blue
        }
    } else {
        textStr = "--";
        iconColor = (width >= 360) 
            ? (fontColor == Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY)
            : fontColor;
    }

    // 6. Draw Text
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText, yText, fontSize, textStr, Graphics.TEXT_JUSTIFY_LEFT);

    // 7. Draw Icon
    dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xIcon, yIcon + offset, IconsFont, "U", Graphics.TEXT_JUSTIFY_CENTER);

    return true;
}

/* old function
	function drawBodyBattery(dc, xIcon, yIcon, xText, yText, width) {

		var offset = 0;
		if (width>=360) { // Venu & D2 Air
			offset = 7;	
		}	else if (System.SCREEN_SHAPE_ROUND != screenShape) { // Venu sq
			offset = -2;	
		} else if (width==240 and dc.getFontHeight(0)>=26){ //Fenix 5 Plus
			offset = -1;
		}

		// Body Battery
		if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)){ //check[15]
			var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({:period=>1});
			var sample = bbIterator.next(); 

			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			if (sample != null) { 
				dc.drawText(xText, yText,	fontSize, sample.data.format("%d"), Graphics.TEXT_JUSTIFY_LEFT);
				//dc.drawText(xText, yText,	fontSize, Lang.format("$1$",[sample.data.format("%02d")]), Graphics.TEXT_JUSTIFY_LEFT);

				if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
					if (sample.data<=25) {
						dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
					} else if (sample.data<=50){
						dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT); // Orange
					} else if (sample.data<=75){
						dc.setColor(0xFFFF55, Graphics.COLOR_TRANSPARENT); //YELLOW
					} else { //between 76 and 100
						dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
					}
				} else { // Light Theme
					if (sample.data<=25) {
						dc.setColor(0xAA0000, Graphics.COLOR_TRANSPARENT); // Red
					} else if (sample.data<=50){
						dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT); // Orange
					} else if (sample.data<=75){
						dc.setColor(0xAAAA00, Graphics.COLOR_TRANSPARENT); //YELLOW
					} else { //between 76 and 100
						dc.setColor(0x0055AA, Graphics.COLOR_TRANSPARENT); // Blue
					}						
				}
			} else{
				dc.drawText(xText, yText,	fontSize, "--", Graphics.TEXT_JUSTIFY_LEFT);
				if (width>=360){ //AMOLED
					dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
				} else { // MIP displays, for better readability
					dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
				}
			}
		} else { return false; }

		dc.drawText( xIcon, yIcon + offset , IconsFont, "U", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		return true;

	}
*/

/* ------------------------ */
function drawStress(dc, xIcon, yIcon, xText, yText, width) {
    var stressScore = null;
    var supportsStress = false;

    // 1. Try Complications API First (API 4.2.0+)
    if (Toybox has :Complications) {
        supportsStress = true;
        var stressComp = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_STRESS));
        
        if (stressComp != null && stressComp.value != null) {
            stressScore = stressComp.value;
        }
    }

    // 2. Fallback to SensorHistory API
    if (stressScore == null && Toybox has :SensorHistory && SensorHistory has :getStressHistory) {
        supportsStress = true;
        var stressIterator = SensorHistory.getStressHistory({:period => 1});
        
        if (stressIterator != null) {
            var sample = stressIterator.next(); 
            if (sample != null && sample.data != null) {
                stressScore = sample.data;
            }
        }
    }

    // 3. Early Exit! (If the watch physically does not support Stress, skip everything)
    if (!supportsStress) {
        return false;
    }

    // 4. Layout Offsets (Removed slow floating-point -0.5 math)
    var offsetY = 0;
    if (width >= 360) { // Fenix 6X & Enduro
        offsetY = width * 0.02;
    } else if (width == 260) {
        offsetY = -1; // Rounding -0.5 to nearest integer prevents runtime type coercion
    }

    var iconColor;
    var textStr;

    // 5. Data Formatting and Color Consolidation
    if (stressScore != null) {
        textStr = stressScore.format("%d").toString(); 
        
        // Caching this evaluation saves us from running it 4 times
        var isDarkTheme = (fontColor == Graphics.COLOR_WHITE); 
        
        // Single threshold check replaces the massive double if/else block!
        if (stressScore <= 25) {
            iconColor = isDarkTheme ? Graphics.COLOR_BLUE : 0x0055AA;
        } else if (stressScore <= 50) {
            iconColor = isDarkTheme ? 0xFFFF55 : 0xAAAA00;
        } else if (stressScore <= 75) {
            iconColor = isDarkTheme ? Graphics.COLOR_ORANGE : 0xFF5500;
        } else {
            iconColor = isDarkTheme ? Graphics.COLOR_RED : 0xAA0000;
        }
    } else {
        // Watch supports stress, but no data available (e.g., while on movement). Stress data only works if user is still for a few seconds.
        textStr = "--";
        iconColor = (width >= 360) 
            ? (fontColor == Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY)
            : fontColor;
    }

    // 6. Draw Text
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText, yText, fontSize, textStr, Graphics.TEXT_JUSTIFY_LEFT);

    // 7. Draw Icon
    dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xIcon, yIcon + offsetY, IconsFont, "T", Graphics.TEXT_JUSTIFY_CENTER); 
    
    return true;
}	

/* old function
	function drawStress(dc, xIcon, yIcon, xText, yText, width) {

		var offsetY = 0;
		if (width>=360) { // Fenix 6X & Enduro
			offsetY = 1;
		}	else if (width==260){
			offsetY = -0.5;
		} 

		// Stress
		if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getStressHistory)){ 
			var stressIterator = Toybox.SensorHistory.getStressHistory({:period=>1});
			var sample = stressIterator.next(); 

			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			if (sample != null) { 
				dc.drawText(xText, yText,	fontSize, sample.data.format("%d"), Graphics.TEXT_JUSTIFY_LEFT);
				if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
					if (sample.data<=25) {
						dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
					} else if (sample.data<=50){
						dc.setColor(0xFFFF55, Graphics.COLOR_TRANSPARENT);
					} else if (sample.data<=75){
						dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
					} else { //between 76 and 100
						dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);					
					}
				} else { // Light Theme
					if (sample.data<=25) {
						dc.setColor(0x0055AA, Graphics.COLOR_TRANSPARENT); // Blue
					} else if (sample.data<=50){
						dc.setColor(0xAAAA00, Graphics.COLOR_TRANSPARENT); // Yellow
					} else if (sample.data<=75){
						dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT); // Orange
					} else { //between 76 and 100
						dc.setColor(0xAA0000, Graphics.COLOR_TRANSPARENT); // Red
					}					
				}
			} else{
				dc.drawText(xText, yText,	fontSize, "--", Graphics.TEXT_JUSTIFY_LEFT);
				if (width>=360){ //AMOLED
					dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
				} else { // MIP displays, for better readability
					dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
				}
			}
		} else { return false; }

		dc.drawText( xIcon, yIcon + offsetY , IconsFont, "T", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		return true;
	}
*/

/* ------------------------ */
	// Add Vo2 Max - vo2maxRunning and vo2maxCycling from UserProfile.getProfile()
	function drawVO2Max(dc, xIcon, yIcon, xText, yText, width, cycle) { 
    var vo2max = null;

    // 1. Try Complications API First (API 4.2.0+)
    if (Toybox has :Complications) {
        // Dynamically select Run or Bike based on the 'cycle' parameter
        var compType = cycle ? Toybox.Complications.COMPLICATION_TYPE_VO2MAX_BIKE 
                             : Toybox.Complications.COMPLICATION_TYPE_VO2MAX_RUN;
                             
        var vo2Comp = Toybox.Complications.getComplication(new Toybox.Complications.Id(compType));
        
        if (vo2Comp != null && vo2Comp.value != null) {
            vo2max = vo2Comp.value;
        }
    }

    // 2. Fallback to UserProfile API (Cache the object!)
    if (vo2max == null && Toybox has :UserProfile) {
        var profile = UserProfile.getProfile(); // Called exactly ONCE
        
        // Properly respect the 'cycle' parameter to pull the correct metric
        if (cycle && profile has :vo2maxCycling && profile.vo2maxCycling != null) {
            vo2max = profile.vo2maxCycling;
        } else if (!cycle && profile has :vo2maxRunning && profile.vo2maxRunning != null) {
            vo2max = profile.vo2maxRunning;
        }
    }

    // 3. Early Exit (Skip layout math if there is no data)
    if (vo2max == null) { 
        return false; 
    }

    // 4. Layout Offsets 
    if (width == 280 || width == 240) { // Fenix 6X & Enduro
        yIcon -= 5;
    } else if (width == 260) {
        yIcon -= 4;
    } else if (width == 218) {
        yIcon -= 3;
    } else if (width == 360) {
        yIcon -= 1;
    }

    // 5. Data Formatting & Single-Pass Color Logic
    var iconColor;
    var isDarkTheme = (fontColor == Graphics.COLOR_WHITE);

    if (vo2max <= 30) { // Very Poor
        iconColor = isDarkTheme ? Graphics.COLOR_RED : 0xAA0000;
    } else if (vo2max <= 34) { // Poor
        iconColor = isDarkTheme ? Graphics.COLOR_ORANGE : 0xFF5500;
    } else if (vo2max <= 39) { // Fair
        iconColor = 0xAAFF00; 
    } else if (vo2max <= 44) { // Good
        iconColor = isDarkTheme ? (width >= 360 ? 0xAAFF00 : 0x55FF00) : 0x55FF00;
    } else if (vo2max <= 48) { // Excellent
        iconColor = isDarkTheme ? Graphics.COLOR_BLUE : 0x00AAAA;
    } else { // Superior
        iconColor = isDarkTheme ? 0xAA55FF : 0x5500AA;
    }

    // 6. Draw Icon
    dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xIcon, yIcon, IconsFont, "X", Graphics.TEXT_JUSTIFY_CENTER);
    
    // 7. Draw Text
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText, yText, fontSize, vo2max.toNumber().toString(), Graphics.TEXT_JUSTIFY_LEFT);
    
    return true;
	}

/* old function 
	function drawVO2Max(dc, xIcon, yIcon, xText, yText, width, cycle) {	
	
		var text = null;

		if (UserProfile.getProfile() has :vo2maxRunning and UserProfile.getProfile() has :vo2maxCycling) { 
				if (UserProfile.getProfile().vo2maxRunning!=null) {
					text = UserProfile.getProfile().vo2maxRunning;
				} else if (UserProfile.getProfile().vo2maxCycling!=null) {
					text = UserProfile.getProfile().vo2maxCycling;
				}
		} else { return false; }

		if(width==280 or width==240){ //Fenix 6X & Enduro
			yIcon=yIcon-5;
		} else if (width==260){
			yIcon=yIcon-4;
		} else if (width==218){
			yIcon=yIcon-3;
		} else if (width==360){
			yIcon=yIcon-1;
		}

		if (fontColor == Graphics.COLOR_WHITE){ // Dark Theme
			if (text<=30){ // Very Poor
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			} else if (text<=34){ // Poor
				dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
			} else if (text<=39){ // Fair
				dc.setColor(0xAAFF00, Graphics.COLOR_TRANSPARENT);
			} else if (text<=44){ // Good
				if (width>=360) {
					dc.setColor(0xAAFF00, Graphics.COLOR_TRANSPARENT); // Vivomove GREEN
				} else {
					dc.setColor(0x55FF00, Graphics.COLOR_TRANSPARENT); // GREEN
				}		
			} else if (text<=48){ // Excellent
				dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT); // Blue or Graphics.COLOR_BLUE
			} else { // Superior
				dc.setColor(0xAA55FF, Graphics.COLOR_TRANSPARENT); // Purple or 0xAA55FF
			}
		} else { // Light Theme
			if (text<=30){ // Very Poor
				dc.setColor(0xAA0000, Graphics.COLOR_TRANSPARENT);
			} else if (text<=34){ // Poor
				dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT);
			} else if (text<=39){ // Fair
				dc.setColor(0xAAFF00, Graphics.COLOR_TRANSPARENT);
			} else if (text<=44){ // Good
				dc.setColor(0x55FF00, Graphics.COLOR_TRANSPARENT);
			} else if (text<=48){ // Excellent
				dc.setColor(0x00AAAA, Graphics.COLOR_TRANSPARENT); // Blue or Graphics.COLOR_BLUE
			} else { // Superior
				dc.setColor(0x5500AA, Graphics.COLOR_TRANSPARENT); // Purple or 0xAA55FF
			}			
		}

		dc.drawText( xIcon, yIcon, IconsFont, "X", Graphics.TEXT_JUSTIFY_CENTER);
		
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText( xText, yText, fontSize, text.format("%d"), Graphics.TEXT_JUSTIFY_LEFT);
		
		return true;
	}
/*


/* ------------------------ */
	// Add respiration Rate (breaths per minute) - respirationRate from ActivityMonitor.getInfo()
	function drawRespiration(dc, xIcon, yIcon, xText, yText, accentColor, width) {
    var respRate = null;

    // 1. Try Complications API First (API 4.2.0+)
    if (Toybox has :Complications) { // && Toybox.Complications has :COMPLICATION_TYPE_RESPIRATION_RATE
        var respComp = Toybox.Complications.getComplication(new Toybox.Complications.Id(Toybox.Complications.COMPLICATION_TYPE_RESPIRATION_RATE));
        
        if (respComp != null && respComp.value != null) {
            respRate = respComp.value;
        }
    }

    // 2. Fallback to ActivityMonitor API (Cache the object!)
    if (respRate == null && Toybox has :ActivityMonitor) {
        var info = ActivityMonitor.getInfo(); // Called exactly ONCE
        if (info has :respirationRate && info.respirationRate != null) {
            respRate = info.respirationRate;
        }
    }

    // 3. Format Text (Handle the null fallback to "--")
    var text = (respRate != null) ? respRate.toNumber().toString() : "--";

    // 4. Draw Text
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);   
    dc.drawText(xText, yText, fontSize, text, Graphics.TEXT_JUSTIFY_LEFT);
    
    // 5. Layout Offsets (For the Icon)
    if (width == 280 || width == 240) { // Fenix 6X & Enduro
        yIcon -= 5;
    } else if (width == 260) {
        yIcon -= 4;
    } else if (width == 218) {
        yIcon -= 3;
    }

    // 6. Icon Color Logic (Flattened)
    var iconColor;
    if (width >= 360) { // AMOLED displays
        iconColor = (fontColor == Graphics.COLOR_WHITE) ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY;
    } else { // MIP displays, for better readability
        iconColor = fontColor;
    }

    // 7. Draw Icon
    dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xIcon, yIcon, IconsFont, "W", Graphics.TEXT_JUSTIFY_CENTER);
    
    return true;
	}

/* old function
	function drawRespiration(dc, xIcon, yIcon, xText, yText, accentColor, width) {

		var text=null;    
       
		if (ActivityMonitor.getInfo() has :respirationRate and ActivityMonitor.getInfo().respirationRate!=null) {// if (check[14]) {
			text = ActivityMonitor.getInfo().respirationRate;
		} else { 
			//return false; 
			text = "--";
		}

		// Text
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);		
		dc.drawText( xText, yText, fontSize, text, Graphics.TEXT_JUSTIFY_LEFT);
		
		if(width==280 or width==240){ //Fenix 6X & Enduro
			yIcon=yIcon-5;
		} else if (width==260){
			yIcon=yIcon-4;
		} else if (width==218){
			yIcon=yIcon-3;
		}

		// Icon
		if (width>=360){ //AMOLED
			dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
		} else { // MIP displays, for better readability
			dc.setColor( fontColor, Graphics.COLOR_TRANSPARENT); 
		}
		dc.drawText( xIcon, yIcon, IconsFont, "W", Graphics.TEXT_JUSTIFY_CENTER);
		return true;
	}
*/

/* ------------------------ */

// Add Recovery Time (hours) - timeToRecovery from ActivityMonitor.getInfo()
function drawRecoveryTime(dc, xIcon, yIcon, xText, yText, width) {          
    var recovery = 0.0 as Float;
		var unitText = "h";

    // 1. Try Complications API First (API 4.2.0+)
    if (Toybox has :Complications) {
        var recovComp = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME));
        
        if (recovComp != null && recovComp.value != null) {
            recovery = recovComp.value;
						if (recovery > 99) {
							recovery = recovery.toFloat() / 60; // Convert minutes to hours
						} else {
							unitText = "min";
						}
        }
    }

    // 2. Fallback to ActivityMonitor API
    if (recovery == 0 && ActivityMonitor has :getInfo) {
        var info = ActivityMonitor.getInfo(); // Cache the object to avoid multiple API calls
        if (info has :timeToRecovery && info.timeToRecovery != null) {
            recovery = info.timeToRecovery;
        }
    }

    // 3. Early Exit! (Saves CPU by skipping layout math if there is no data)
    if (recovery == 0) {
        return false;
    } 

    // 4. Layout Offsets
    var offset = 0;
    if (width >= 360) { // Venu & D2 Air
        offset = 6; 
    } else if (System.SCREEN_SHAPE_ROUND != screenShape) { // Rectangle display
        offset = -2;
    }

    // 5. Determine Icon Color mathematically
    var iconColor = (width >= 360) 
        ? (fontColor == Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY)
        : fontColor; // MIP displays fallback

    // 6. Draw Icon
    dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xIcon, yIcon + offset, IconsFont, "V", Graphics.TEXT_JUSTIFY_CENTER); 

    // 7. Format and Draw Text
    // .toFloat() ensures safely formatted decimals regardless of whether the API returns a Number or Float
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText, yText, fontSize, (recovery < 10 && unitText.equals("h") ? recovery.toFloat().format("%.1f") : recovery.toFloat().format("%.0f"))+unitText, Graphics.TEXT_JUSTIFY_LEFT); 

    return true;        
}

/* old function
	function drawRecoveryTime(dc, xIcon, yIcon, xText, yText, width) {	
          
		var recovery = null;
		if (ActivityMonitor.getInfo() has :timeToRecovery and ActivityMonitor.getInfo().timeToRecovery!=null){ 
			recovery = ActivityMonitor.getInfo().timeToRecovery;
		}
		
		var offset = 0;
		if (width>=360) { // Venu & D2 Air
			offset = 6;	
		} else if (System.SCREEN_SHAPE_ROUND != screenShape) { //check if rectangle display
			offset = -2;
		}
		
		if (recovery == null) {
			return false;
		} else {					
			if (width>=360){ //AMOLED
				dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
			} else { // MIP displays, for better readability
				dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			}

			dc.drawText( xIcon, yIcon + offset , IconsFont, "V", Graphics.TEXT_JUSTIFY_CENTER); // Using Font

			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			dc.drawText(xText, yText , fontSize, (recovery>=10 ? recovery.format("%.0f") : recovery.format("%.1f")) + " hs", Graphics.TEXT_JUSTIFY_LEFT); //Lang.format("$1$", [recovery.format("%.1f")] )
			return true;       	
		}

	}	
*/

	/* ------------------------ */

	// Draw next Sun Event time
	//(:memory) 
(:tempo) function drawSunriseSunset(dc, xIcon, yIcon, xText, yText, width) { 
    var sunriseSec = null;
    var sunsetSec = null;

    // 1. Try Complications API First (Fastest)
    if (Toybox has :Complications) {      
        var sunsetComp = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET));
        var sunriseComp = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE));

        if (sunsetComp != null && sunsetComp.value instanceof Number && sunriseComp != null && sunriseComp.value instanceof Number) {
            sunsetSec = sunsetComp.value;
            sunriseSec = sunriseComp.value;
        }
    }

    // 2. Fallback to Weather API (Time.Moment calculation)
    if (sunriseSec == null && Toybox has :Weather && Weather has :getSunset) {
        var conditions = Weather.getCurrentConditions();
        if (conditions != null) {
            var pos = conditions.observationLocationPosition;
            var today = conditions.observationTime;

            if (pos != null && pos instanceof Position.Location && today != null && today instanceof Time.Moment) {
                var sunsetMom = Weather.getSunset(pos, today);
                var sunriseMom = Weather.getSunrise(pos, today);

                if (sunsetMom != null && sunriseMom != null) {
                    var ssInfo = Time.Gregorian.info(sunsetMom, Time.FORMAT_SHORT);
                    var srInfo = Time.Gregorian.info(sunriseMom, Time.FORMAT_SHORT);
                    
                    // Convert Gregorian Moment to seconds since midnight
                    sunsetSec = (ssInfo.hour * 3600) + (ssInfo.min * 60) + ssInfo.sec;
                    sunriseSec = (srInfo.hour * 3600) + (srInfo.min * 60) + srInfo.sec;
                }
            }
        } else {
            return false; // Replicating your original early exit if no conditions exist
        }
    }

    // 3. Determine Day/Night and Target Time
    var icon, text, am_pm = "";
    var isDay = false;

    if (sunriseSec != null && sunsetSec != null) {
        var myTime = System.getClockTime();
        var currentSec = (myTime.hour * 3600) + (myTime.min * 60) + myTime.sec;

        // One simple math check replaces 4 complex if/else time comparisons
        isDay = (currentSec >= sunriseSec && currentSec < sunsetSec);
        
        var targetSec = isDay ? sunsetSec : sunriseSec;
        icon = isDay ? "?" : ">";

        // Format hour and minute from seconds
        var outHour = targetSec / 3600;
        var outMin = (targetSec % 3600) / 60;

        if (!System.getDeviceSettings().is24Hour) {
            if (outHour >= 12) {
                am_pm = "PM";
                if (outHour > 12) { outHour -= 12; }
            } else {
                am_pm = "AM";
                if (outHour == 0) { outHour = 12; }
            }
        }

        // Direct string concatenation is faster than Lang.format()
        text = outHour.format("%02d") + ":" + outMin.format("%02d");

    } else {
        // Fallback if polar region / no data
        icon = ">";
        text = "--";
        isDay = false; 
    }

    // 4. Determine Colors mathematically (No string checking)
    var iconColor = !isDay 
        ? (fontColor == Graphics.COLOR_WHITE ? Graphics.COLOR_BLUE : 0x0055AA) // Sunrise (Blue)
        : (fontColor == Graphics.COLOR_WHITE ? 0xFFAA00 : 0xFF5500);           // Sunset (Orange)

    // 5. Drawing
    var offset = (width >= 360) ? 7 : 0;
    
    // Draw Icon
    dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xIcon, yIcon + offset, IconsFont, icon, Graphics.TEXT_JUSTIFY_CENTER); 
    
    // Draw Time
    dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(xText, yText, fontSize, text, Graphics.TEXT_JUSTIFY_LEFT); 
    
    // Draw AM/PM
    if (!am_pm.equals("")) { 
        var amPmX = xText + dc.getTextWidthInPixels(text, fontSize);
        var amPmY = yText + fontSize * ((dc.getFontHeight(Graphics.FONT_TINY) - dc.getFontHeight(Graphics.FONT_XTINY)) * 0.9 - (width == 360 ? 1 : 0));
        dc.drawText(amPmX, amPmY, 0, am_pm, Graphics.TEXT_JUSTIFY_LEFT);
    }

    return true;
}

/* old function 

function drawSunriseSunset(dc, xIcon, yIcon, xText, yText, width) {	
          
		// placeholder for SDK 5
		var myTime = System.getClockTime(); 
		var sunset, sunrise;

		if (Toybox has :Weather and Weather has :getSunset and Weather has :getSunrise) {
			if (Toybox.Weather.getCurrentConditions()!=null){
				var position = Toybox.Weather.getCurrentConditions().observationLocationPosition; // or Activity.Info.currentLocation if observation is null?
				var today = Toybox.Weather.getCurrentConditions().observationTime; // or new Time.Moment(Time.now().value()); ?
				if (position!=null and today!=null){
					sunset = Weather.getSunset(position, today);
					sunrise = Weather.getSunrise(position, today);
				} else {
				return false;
				}
			} else {
				return false;
			}
		} else {
			return false;
		}

		var offset = 0;
		if (width>=360) { // Venu & D2 Air
			offset = 7;	
		}		

		var icon, time, text="", am_pm="";
		if (sunset!=null and sunrise!=null){
			sunset = Time.Gregorian.info(sunset, Time.FORMAT_SHORT);
			sunrise = Time.Gregorian.info(sunrise, Time.FORMAT_SHORT);
			if (myTime.hour > sunrise.hour and myTime.hour < sunset.hour){ 
				icon = "?";
				time = sunset;
			} else if (myTime.hour == sunrise.hour and myTime.min > sunrise.min){ 
				icon = "?";
				time = sunset;
			} else if (myTime.hour == sunset.hour and myTime.min <= sunset.min){ 
				icon = "?";
				time = sunset;
			}	else {
				icon = ">";
				time = sunrise;
			}

			if (System.getDeviceSettings().is24Hour==false){
				am_pm="AM";
				if (time.hour >= 12){
					time.hour = time.hour-12;
					am_pm="PM";
				}
				if (time.hour == 0){
					time.hour = 12;
				}
			}
		} else {
			icon = ">";
			time = null;
			text="--";
		}

		if (icon != null && icon.equals(">")){
			dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_BLUE : 0x0055AA), Graphics.COLOR_TRANSPARENT); // Blue
		} else {
			dc.setColor((fontColor==Graphics.COLOR_WHITE ? 0xFFAA00 : 0xFF5500), Graphics.COLOR_TRANSPARENT); // Orange
		}
		dc.drawText( xIcon, yIcon + offset , IconsFont, icon, Graphics.TEXT_JUSTIFY_CENTER); // Draw Icon
		
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		//dc.drawText( xText, yText , fontSize, Lang.format("$1$:$2$$3$",[time.hour.format("%02u"), time.min.format("%02u"), am_pm]), Graphics.TEXT_JUSTIFY_LEFT);
		
		if (time!=null){
			text=Lang.format("$1$:$2$",[time.hour.format("%02u"), time.min.format("%02u")]);
		}
		
		dc.drawText( xText, yText , fontSize, text, Graphics.TEXT_JUSTIFY_LEFT); // Draw time
		if (am_pm!=""){ // draw AM/PM on a smaller font
			dc.drawText(xText + dc.getTextWidthInPixels(text,fontSize), yText + fontSize*((dc.getFontHeight(Graphics.FONT_TINY)-dc.getFontHeight(Graphics.FONT_XTINY))*0.9 - (width==360 ? 1 : 0)),	0, am_pm, Graphics.TEXT_JUSTIFY_LEFT);
		}

		return true;
	}
/*

	/* ------------------------ */
	
	// Draw Data Fields
(:tempo) function drawPoints(dc, xIcon, yIcon, xText, yText, accentColor, width, dataPoint, side) {	// exclude for Fenix 5 plus
		// side 1 = left top
		// side 2 = left middle
		// side 3 = left bottom
		// side 4 = right top and bottom

		var offset390=0;

		if (width>=390) { // Venu 1 & 2
			offset390=1;
		} else if (System.SCREEN_SHAPE_ROUND != screenShape) { //check if rectangle display
			offset390=1;
		}
		
		if (dataPoint == 0) { //Steps 
			drawSteps(dc, xIcon-(xIcon*0.002), yIcon, xText, yText, width, accentColor);
		} else if (Toybox has :Weather and ((side>2 and dataPoint == 1) or (side<=2 and dataPoint == 5))) { // Humidity(dc, xIcon, yIcon, xText, yText, width)
			drawHumidity(dc, xIcon+(xIcon*0.005), yIcon, xText-(xText*0.002), yText, width, accentColor);
		} else if ((side>2 and dataPoint == 2) or (side<=2 and dataPoint == 6)) { // Precipitation(dc, xIcon, yIcon, xText, yText, width)
			if (side<=3){ xText=xText+width*0.012; }
			drawPrecipitation(dc, xIcon+(xIcon*0.0125)+offset390, yIcon-(xIcon*0.001)+(offset390*2), xText+(xText*0.025)-(offset390*2), yText, width);
		} else if ((side>2 and dataPoint == 3) or (side<=2 and dataPoint == 7)) { // elevationIcon(dc, xIcon, yIcon, xText, yText, width)
			drawPressure(dc, xIcon, yIcon, xText+(xText*0.01)-offset390, yText, width);
		} else if ((side>2 and dataPoint == 4) or (side<=2 and dataPoint == 8)) { // Calories Total
			drawCalories(dc, xIcon+(offset390*2), yIcon, xText, yText, width, 1);
		} else if ((side>2 and dataPoint == 5) or (side<=2 and dataPoint == 9)) { // Calories Active
			drawCalories(dc, xIcon+(offset390*2), yIcon, xText, yText, width, 2);
		} else if ((side>2 and dataPoint == 6) or (side<=2 and dataPoint == 10)) { // FloorsClimbed(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawFloorsClimbed(dc, xIcon-(xIcon*0.002), yIcon-(xIcon*0.001), xText, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 7) or (side<=2 and dataPoint == 11)) { // PulseOx(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawPulseOx(dc, xIcon, yIcon, xText-offset390, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 8) or (side<=2 and dataPoint == 12)) { // HeartRate(dc, xIcon, hrIconY, xText, width, Xoffset, accentColor)
			//drawHeartRate(dc, xIcon-(xIcon*0.005), yIcon+(xIcon*0.03)-offset390, xText, width, accentColor);
			drawHeartRate(dc, xIcon-(xIcon*0.005), yIcon+(width*0.017)-offset390, xText, width, accentColor);
		} else if ((side>2 and dataPoint == 9) or (side<=2 and dataPoint == 13)) { // Notification(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawNotification(dc, xIcon-(xIcon*0.002), yIcon+(width*0.002)+offset390, xText, yText, accentColor, width);
		} else if ((side>2 and dataPoint == 10) or (side<=2 and dataPoint == 14)) { // SolarIntensity (dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawSolarIntensity(dc, xIcon, yIcon, xText, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 11) or (side<=2 and dataPoint == 15)) { // Seconds
			drawSeconds(dc, xIcon, yIcon+(width*0.02)-(offset390*2), xText, yText, width, 1);
		} else if ((side>2 and dataPoint == 12) or (side<=2 and dataPoint == 16)) { // Digital Clock
			drawSeconds(dc, xIcon, yIcon+(width*0.02)-(offset390*2), xText, yText, width, 2);
		} else if ((side>2 and dataPoint == 13) or (side<=2 and dataPoint == 17)) { // Intensity Minutes
			drawIntensityMin(dc, xIcon-(xIcon*0.002), yIcon+(width*0.015)-(offset390*2), xText, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 14) or (side<=2 and dataPoint == 18)) { // SolarIntensity (dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawBodyBattery(dc, xIcon+2, yIcon-1, xText+(xText*0.01), yText, width);
			//drawBodyBattery(dc, xIcon+2, yIcon-(width*0.05), xText+(xText*0.01), yText, width);
		} else if ((side>2 and dataPoint == 15) or (side<=2 and dataPoint == 19)) { // Calories(dc, xIcon, yIcon, xText, yText, width)
			drawStress(dc, xIcon-(xIcon*0.002), yIcon, xText, yText, width);
		} else if ((side>2 and dataPoint == 16) or (side<=2 and dataPoint == 20)) { // Respiration Rate(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawRespiration(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.03)-offset390, xText, yText, accentColor, width);
		} else if ((side>2 and dataPoint == 17) or (side<=2 and dataPoint == 21)) { // Recovery Time(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawRecoveryTime(dc, xIcon, yIcon+(xIcon*0.002), xText-offset390, yText, width);
		} else if ((side>2 and dataPoint == 18) or (side<=2 and dataPoint == 22)) { // Vo2 Max Run(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawVO2Max(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.03)-offset390, xText, yText, width, false); // run
		} else if ((side>2 and dataPoint == 19) or (side<=2 and dataPoint == 23)) { // Vo2 Max Cycling(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawVO2Max(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.03)-offset390, xText, yText, width, true); //cycling
		}	else if ((side>2 and dataPoint == 20) or (side<=2 and dataPoint == 24)) { // Next Sun Event
			drawSunriseSunset(dc, xIcon, yIcon+(xIcon*0.002), xText-offset390, yText, width);
		} else if ((side>2 and dataPoint == 21) or (side<=2 and dataPoint == 25)) { // Notification(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawBatteryConsumption(dc, xIcon-(xIcon*0.002), yIcon+(width*0.025)-offset390, xText, yText, width);
		} else if (side>2 and dataPoint == 22){
			drawForecast(dc, xIcon+(width*0.06), yIcon+(width*0.01), width, 2);
		} else if (side<=2 and dataPoint == 1) { 
			drawDistance(dc, xIcon-offset390, yIcon, xText+(xText*0.015)-offset390, yText, width, accentColor);
		} else if (side<=2 and dataPoint == 2) { // elevationIcon(dc, xIcon, yIcon, xText, yText, width)
			drawElevation(dc, xIcon-(xIcon*0.015), yIcon-(xIcon*0.01), xText+(xText*0.015)-offset390, yText, width, side);
		} else if (side<=2 and dataPoint == 3) { // windIcon(dc, xIcon, yIcon, xText, yText, width)
			drawWindSpeed(dc, xIcon-offset390, yIcon+(xIcon*0.01)-offset390, xText, yText, width);
		} else if (side<=2 and dataPoint == 4) { // drawMinMaxTemp(dc, xIcon, yIcon, xText, yText, width)
			drawMinMaxTemp(dc, xIcon+(offset390*2), yIcon, xText+(xText*0.01), yText, width);
		} else if (side<=2 and dataPoint == 26){
			drawForecast(dc, xIcon+(width*0.06), yIcon+(width*0.01), width, 3);
		}
	}

	/* ------------------------ */
	
	// Draw Data Fields
(:noTempo)	function drawPoints(dc, xIcon, yIcon, xText, yText, accentColor, width, dataPoint, side) {	// exclude for Fenix 5 plus
		// side 1 = left top
		// side 2 = left middle
		// side 3 = left bottom
		// side 4 = right top and bottom

		var offset390=0;

		if (width>=390) { // Venu 1 & 2
			offset390=1;
		} else if (System.SCREEN_SHAPE_ROUND != screenShape) { //check if rectangle display
			offset390=1;
		}
		
		if (dataPoint == 0) { //Steps 
			drawSteps(dc, xIcon-(xIcon*0.002), yIcon, xText, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 3) or (side<=2 and dataPoint == 7)) { // elevationIcon(dc, xIcon, yIcon, xText, yText, width)
			drawPressure(dc, xIcon, yIcon, xText+(xText*0.01)-offset390, yText, width);
		} else if ((side>2 and dataPoint == 4) or (side<=2 and dataPoint == 8)) { // Calories Total
			drawCalories(dc, xIcon+(offset390*2), yIcon, xText, yText, width, 1);
		} else if ((side>2 and dataPoint == 5) or (side<=2 and dataPoint == 9)) { // Calories Active
			drawCalories(dc, xIcon+(offset390*2), yIcon, xText, yText, width, 2);
		} else if ((side>2 and dataPoint == 6) or (side<=2 and dataPoint == 10)) { // FloorsClimbed(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawFloorsClimbed(dc, xIcon-(xIcon*0.002), yIcon-(xIcon*0.001), xText, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 7) or (side<=2 and dataPoint == 11)) { // PulseOx(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawPulseOx(dc, xIcon, yIcon, xText-offset390, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 8) or (side<=2 and dataPoint == 12)) { // HeartRate(dc, xIcon, hrIconY, xText, width, Xoffset, accentColor)
			//drawHeartRate(dc, xIcon-(xIcon*0.005), yIcon+(xIcon*0.03)-offset390, xText, width, accentColor);
			drawHeartRate(dc, xIcon-(xIcon*0.005), yIcon+(width*0.017)-offset390, xText, width, accentColor);
		} else if ((side>2 and dataPoint == 9) or (side<=2 and dataPoint == 13)) { // Notification(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawNotification(dc, xIcon-(xIcon*0.002), yIcon+(width*0.002)-offset390, xText, yText, accentColor, width);
		} else if ((side>2 and dataPoint == 10) or (side<=2 and dataPoint == 14)) { // SolarIntensity (dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawSolarIntensity(dc, xIcon, yIcon, xText, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 11) or (side<=2 and dataPoint == 15)) { // Seconds
			drawSeconds(dc, xIcon, yIcon+(width*0.02)-(offset390*2), xText, yText, width, 1);
		} else if ((side>2 and dataPoint == 12) or (side<=2 and dataPoint == 16)) { // Digital Clock
			drawSeconds(dc, xIcon, yIcon+(width*0.02)-(offset390*2), xText, yText, width, 2);
		} else if ((side>2 and dataPoint == 13) or (side<=2 and dataPoint == 17)) { // Intensity Minutes
			drawIntensityMin(dc, xIcon-(xIcon*0.002), yIcon+(width*0.015)-(offset390*2), xText, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 14) or (side<=2 and dataPoint == 18)) { // SolarIntensity (dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawBodyBattery(dc, xIcon+2, yIcon-1, xText+(xText*0.01), yText, width);			
		} else if ((side>2 and dataPoint == 15) or (side<=2 and dataPoint == 19)) { // Calories(dc, xIcon, yIcon, xText, yText, width)
			drawStress(dc, xIcon-(xIcon*0.002), yIcon+4, xText, yText, width);
		} else if ((side>2 and dataPoint == 16) or (side<=2 and dataPoint == 20)) { // Respiration Rate(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawRespiration(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.03)-offset390, xText, yText, accentColor, width);
		} else if ((side>2 and dataPoint == 17) or (side<=2 and dataPoint == 21)) { // Recovery Time(dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawRecoveryTime(dc, xIcon, yIcon+(xIcon*0.002), xText-offset390, yText, width);
		} else if ((side>2 and dataPoint == 18) or (side<=2 and dataPoint == 22)) { // Vo2 Max Run(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawVO2Max(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.03)-offset390, xText, yText, width, false); // run
		} else if ((side>2 and dataPoint == 19) or (side<=2 and dataPoint == 23)) { // Vo2 Max Cycling(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawVO2Max(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.03)-offset390, xText, yText, width, true); //cycling
		} else if ((side>2 and dataPoint == 21) or (side<=2 and dataPoint == 25)) { // Notification(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			drawBatteryConsumption(dc, xIcon-(xIcon*0.002), yIcon+(width*0.025)-offset390, xText, yText, width);
		} else if (side<=2 and dataPoint == 1) { 
			drawDistance(dc, xIcon-offset390, yIcon, xText+(xText*0.015)-offset390, yText, width, accentColor);
		} else if (side<=2 and dataPoint == 2) { // elevationIcon(dc, xIcon, yIcon, xText, yText, width)
			drawElevation(dc, xIcon-(xIcon*0.015), yIcon-(xIcon*0.01), xText+(xText*0.015)-offset390, yText, width, side);
		}
	}

	public function enterSleep(inLowPower) as Void {
			lowPower=inLowPower;
			//WatchUi.requestUpdate();
	}

	//! This method is called when the device exits sleep mode.
	//! Set the isAwake flag to let onUpdate know it should render the second hand.
	public function exitSleep(inLowPower) as Void {
			//_isAwake = true;
			lowPower=inLowPower;
			//WatchUi.requestUpdate();
	}


}