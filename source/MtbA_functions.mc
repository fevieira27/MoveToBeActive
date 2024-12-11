// All functions used to draw data points and icons in the watch face

import Toybox.System;
//import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.ActivityMonitor;
import Toybox.UserProfile;
import Toybox.Activity;
import Toybox.Math;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Application.Storage;

class MtbA_functions {
	
  const IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
	const screenShape = System.getDeviceSettings().screenShape;
	var fontSize = (Storage.getValue(14) == true ? 1 : 0);
	var fontColor = (Storage.getValue(32) == true ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE);
	var condName as String = "";
	var lowPower as Boolean = false;

    public function enterSleep() as Void {
        lowPower=true;
        //WatchUi.requestUpdate();
    }


    //! This method is called when the device exits sleep mode.
    //! Set the isAwake flag to let onUpdate know it should render the second hand.
    public function exitSleep() as Void {
        //_isAwake = true;
        lowPower=false;
        //WatchUi.requestUpdate();
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
			if (System.SCREEN_SHAPE_ROUND == screenShape) { //check if round display					
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
				return true;
			} else { // rectangle display
				return false;
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
    function drawDateString(dc, x as Number, y as Number, format as Boolean) as Void {
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
			dc.drawText(x, y, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);   
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
	
	function drawWeatherIcon(dc, x, y, x2, width, cond, clockTime) {
		
		//var cond = Toybox.Weather.getCurrentConditions().condition;
		var sunset, sunrise;

		if (cond!=null and cond instanceof Number){
			//System.println(clockTime);
			//var clockTime = System.getClockTime().hour;
//			clockTime = clockTime.hour;
			var WeatherFont = Application.loadResource(Rez.Fonts.WeatherFont);

			// gets the correct symbol (sun/moon) depending on actual sun events
			if (Toybox has :Weather and Weather has :getSunset and Weather has :getSunrise and Toybox.Weather has :getCurrentConditions) {
				var position=null, today=null;
				if (Toybox.Weather.getCurrentConditions() has :observationLocationPosition and Toybox.Weather.getCurrentConditions() has :observationTime){ //trying to address errors found on ERA viewer when watch can't get position
					position = Toybox.Weather.getCurrentConditions().observationLocationPosition; // or Activity.Info.currentLocation if observation is null?
					today = Toybox.Weather.getCurrentConditions().observationTime; // or new Time.Moment(Time.now().value()); ?
				}	
				if ((position!=null and position instanceof Position.Location) and (today!=null and today instanceof Moment)){
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
					
			if (width<=280){
				y = y-2;
				if (width==218) {
					y = y-1;
				}
			} 

			//weather icon test
			//weather.condition = 6;

			dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
			if (cond == 20) { // Cloudy
				dc.drawText(x2-1, y-1, WeatherFont, "I", Graphics.TEXT_JUSTIFY_RIGHT); // Cloudy
				if (clockTime >= sunset or clockTime < sunrise) { 
					condName="Cloudy Night";
				} else {
					condName="Cloudy Day";
				}
			} else if (cond == 0 or cond == 5) { // Clear or Windy
				if (clockTime >= sunset or clockTime < sunrise) { 
							dc.drawText(x2-2, y-1, WeatherFont, "f", Graphics.TEXT_JUSTIFY_RIGHT); // Clear Night	
							condName="Starry Night";
						} else {
							dc.drawText(x2, y-2, WeatherFont, "H", Graphics.TEXT_JUSTIFY_RIGHT); // Clear Day
							condName="Sunny Day";
						}
			} else if (cond == 1 or cond == 23 or cond == 40 or cond == 52) { // Partly Cloudy or Mostly Clear or fair or thin clouds
				if (clockTime >= sunset or clockTime < sunrise) { 
							dc.drawText(x2-1, y-2, WeatherFont, "g", Graphics.TEXT_JUSTIFY_RIGHT); // Partly Cloudy Night
							condName="Partly Cloudy";
						} else {
							dc.drawText(x2, y-2, WeatherFont, "G", Graphics.TEXT_JUSTIFY_RIGHT); // Partly Cloudy Day
							//Storage.setValue(34, "Mostly Sunny");
							condName="Mostly Sunny";
						}
			} else if (cond == 2 or cond == 22) { // Mostly Cloudy or Partly Clear
				if (clockTime >= sunset or clockTime < sunrise) { 
							dc.drawText(x2, y, WeatherFont, "h", Graphics.TEXT_JUSTIFY_RIGHT); // Mostly Cloudy Night
							condName="Overcast Night";
						} else {
							dc.drawText(x, y, WeatherFont, "B", Graphics.TEXT_JUSTIFY_RIGHT); // Mostly Cloudy Day
							condName="Mostly Cloudy";
						}
			} else if (cond == 3 or cond == 14 or cond == 15 or cond == 11 or cond == 13 or cond == 24 or cond == 25 or cond == 26 or cond == 27 or cond == 45) { // Rain or Light Rain or heavy rain or showers or unkown or chance  
				if (clockTime >= sunset or clockTime < sunrise) { 
							dc.drawText(x2, y, WeatherFont, "c", Graphics.TEXT_JUSTIFY_RIGHT); // Rain Night
							condName="Rainy Night";
						} else {
							dc.drawText(x, y, WeatherFont, "D", Graphics.TEXT_JUSTIFY_RIGHT); // Rain Day
							condName="Rainy Day";
						}
			} else if (cond == 4 or cond == 10 or cond == 16 or cond == 17 or cond == 34 or cond == 43 or cond == 46 or cond == 48 or cond == 51) { // Snow or Hail or light or heavy snow or ice or chance or cloudy chance or flurries or ice snow
				if (clockTime >= sunset or clockTime < sunrise) { 
							dc.drawText(x2, y, WeatherFont, "e", Graphics.TEXT_JUSTIFY_RIGHT); // Snow Night
							condName="Snowy Night";
						} else {
							dc.drawText(x, y, WeatherFont, "F", Graphics.TEXT_JUSTIFY_RIGHT); // Snow Day
							condName="Snowy Day";
						}
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
	
	/* ------------------------ */
	
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
	
	/* ------------------------ */
	
	// Weather Location Name
	function drawLocation(dc, x, y, showBoolean, logo) {

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
			
			if(width==280 or width==240){ //Fenix 6X & Enduro
				yIcon=yIcon-5;
				if (width==240 and dc.getFontHeight(0)>=26){ //Fenix 5 Plus
					yIcon=yIcon-0.5;
				}
			} else if (width==260){
				yIcon=yIcon-4;
			} else if (width==218){
				yIcon=yIcon-3;
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
					if (accentColor == 0x55FF00 or System.getDeviceSettings().requiresBurnInProtection == false) {
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
	
		// Draw Battery Text (separate because of "too many arguments" error)
	function drawBatteryText(dc, xText, yText, width, estimateFlag) {	
	
		//var estimateFlag = Storage.getValue(19);
		var battery = Math.ceil(System.getSystemStats().battery);
		var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var maxCharge = Storage.getValue(30);
		var check = dc.getFontHeight(0);

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

		if (estimateFlag == true and System.getSystemStats() has :batteryInDays){ // user requested and watch supports
			if (System.getSystemStats().batteryInDays!=null and System.getSystemStats().batteryInDays!=0){ //trying to make sure that we don't get an error if batteryInDays not supported by watch
				battery = System.getSystemStats().batteryInDays;
			} 
			/*
			else {
				battery = Math.ceil(System.getSystemStats().battery);
			}
		} else {
			battery = Math.ceil(System.getSystemStats().battery);
			*/
		}

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
			if (width==208 and battery > 40){
				dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			} else {
				dc.setColor(((battery <= 40 and battery > 20) ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE), Graphics.COLOR_TRANSPARENT);
			}
			//dc.setColor((Graphics.COLOR_BLACK), Graphics.COLOR_TRANSPARENT);
		}
		
		dc.drawText(xText + offsetLED, yText + offset , 0 /* batteryFont */,battery.format("%d") + (estimateFlag == true and battery!=0 ? "d" : "%"), Graphics.TEXT_JUSTIFY_CENTER ); // Correct battery text on Fenix 5 series (except 5s)
	}


	/* ------------------------ */

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


	/* ------------------------ */

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

		if(width==280 or width==240){ 
			yIcon=yIcon-6;
/*			if (width==240 and dc.getTextDimensions("100",0)[1]>=26){ //Fenix 5 Plus & Venu Sq
				yIcon=yIcon-0.5;
			}*/
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
		
		//if (System.getSystemStats().charging==false and Storage.getValue(21)!=null){
		if (text.toNumber() instanceof Number) {
			dc.drawText(xText + dc.getTextWidthInPixels(text,fontSize), yText + fontSize*((dc.getFontHeight(Graphics.FONT_TINY)-dc.getFontHeight(Graphics.FONT_XTINY))*0.9 - (width==360 ? 1 : 0)),	0, "%/d", Graphics.TEXT_JUSTIFY_LEFT);
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
			} else { // Light Theme
				if (pulseOx >= 95) { // Normal
					dc.setColor(0x00AA00, Graphics.COLOR_TRANSPARENT); /* GREEN */
				} else if (pulseOx >= 85) { // Between Normal and Brain being affected
					dc.setColor(0x0055AA, Graphics.COLOR_TRANSPARENT); /* Blue */
				} else if (pulseOx >= 80) { // Brain affected
					dc.setColor(0xAAAA00, Graphics.COLOR_TRANSPARENT); /* pastel yellow */
				} else if (pulseOx >= 66) { // Between brain affected and cyanosis
					dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT); /* orange */
				} else { // Cyanosis
					dc.setColor(0xFF0000, Graphics.COLOR_TRANSPARENT); /* red */
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
	
	/* ------------------------ */
	
	// Draw Floors Climbed Icon and Text
	function drawFloorsClimbed(dc, xIcon, yIcon, xText, yText, width, accentColor) {	
	
		//var IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
	  var floorsCount=0;
	    
	  if (ActivityMonitor.getInfo() has :floorsClimbed) {
	    	floorsCount = ActivityMonitor.getInfo().floorsClimbed;//.toString();
	  } else {
	    	return false;
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

		//var IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
		var unit = "";
        
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

		var distStr = ActivityMonitor.getInfo().steps;
		if (distStr == null) { distStr = 0; }	
		
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
		dc.drawText(xText , yText, fontSize, distStr + unit, Graphics.TEXT_JUSTIFY_LEFT); // Step Text
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
			if (width==360 or width==390 or width==416){ //AMOLED
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
	function drawHands(dc, width, height, accentColor, thickInd, aod, upTop, AODColor) {	
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
			} else if (thickInd == 2) {
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
		var BurnIn = System.getDeviceSettings().requiresBurnInProtection;
		if (aod==true and BurnIn==true and AODColor != true) { //AOD mode ON
			accentColor=Graphics.COLOR_LT_GRAY;
			//arborColor=Graphics.COLOR_LT_GRAY;
			//borderColor=Graphics.COLOR_BLACK;
		}

		if (accentColor==5592405){ // Came from MtbA White
			accentColor=Graphics.COLOR_LT_GRAY;
		}		

		//Use white to draw the hour hand, with a dark grey background
		dc.setColor(borderColor, Graphics.COLOR_TRANSPARENT); //(centerPoint, angle, handLength, tailLength, width, triangle)
		dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 3.485, 0, Math.ceil(handWidth+(width*0.01)), triangle)); // hour hand border

		dc.setColor(((aod==true and BurnIn==true and AODColor != true) or (fontColor == Graphics.COLOR_BLACK)) ? arborColor : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); // Light gray if AOD mode ON, White if not (or MIP display)
		dc.fillPolygon(generateHandCoordinates(screenCenterPoint, hourHandAngle, width / 3.54 , 0, handWidth, triangle-0.01)); // hour hand
		
		// Draw the minute hand.
		//var minuteHandAngle = (clockTime.min / 60.0) * Math.PI * 2;
		var minuteHandAngle = (clockTime.min / 30.0) * Math.PI;
		
		//generateHandCoordinates(centerPoint, angle, handLength, tailLength, width) -- width / (higher means smaller)
		dc.setColor(borderColor, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2.225, 0, Math.ceil(handWidth+(width*0.01)), triangle)); // minute hand border
		dc.setColor(accentColor, Graphics.COLOR_WHITE);
		dc.fillPolygon(generateHandCoordinates(screenCenterPoint, minuteHandAngle, width / 2.25 , 0, handWidth, triangle-0.01)); // minute hand

							
		// Draw the arbor in the center of the screen.
		dc.setColor(borderColor,Graphics.COLOR_BLACK);
		dc.fillCircle(width / 2, height / 2, handWidth*0.65-offsetOuterCircle); // *0.65
		dc.setColor(arborColor, Graphics.COLOR_WHITE);
		dc.fillCircle(width / 2, height / 2, handWidth*0.65-offsetInnerCircle); // -4

		if (aod==true and BurnIn==true)  {
			var checkerboard = Application.loadResource(Rez.Fonts.Checkerboard);
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			for (var row=(upTop) ? 1 : 0; row < height+48; row += 48) {
				for (var col=0 ; col <= width; col += 48) {
					dc.drawText( row, col , checkerboard, "@", Graphics.TEXT_JUSTIFY_CENTER); // Using Font
				}
			}
			dc.fillRectangle( 0, 0 , width, 1); // Using Font
		} else if(BurnIn==true and Storage.getValue(33)==true){
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
			dc.setColor(((aod==true and BurnIn==true and AODColor != true) or (accentColor == Graphics.COLOR_WHITE)) ? arborColor : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); // Light gray if AOD mode ON, White if not (or MIP display)
			dc.fillPolygon(generateHandCoordinates(screenCenterPoint, secondHandAngle, width / 2.075, -(width/2.23), Math.ceil(handWidth-(width*0.0035))/2.75, 1.0)); //rectangle
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
			calories = ActivityMonitor.getInfo().calories - restCalories; // active = total - rest
		} else {
			calories = ActivityMonitor.getInfo().calories; // Total
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
	function drawElevation(dc, xIcon, yIcon, xText, yText, width) {	

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
				if (elevationStr >= 1000) {
					unit = " km";
				} else {
					unit = " m";
				}
			} else{
				unit = " ft";
				elevationStr = elevationStr * 3.28084;
			}
			if (elevationStr >= 1000 and elevationMetric == System.UNIT_METRIC) {
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
		dc.drawText(xText, yText, fontSize, elevationStr + unit, Graphics.TEXT_JUSTIFY_LEFT); // Elevation in m or mi
	}

/* ------------------------ */
	
	// Draw Atmospheric Pressure
	function drawPressure(dc, xIcon, yIcon, xText, yText, width) {	

		//var IconsFont = Application.loadResource(Rez.Fonts.IconsFont);
		var pressure=null;
		//var unit= "";

		if (Storage.getValue(20)==true){ //Athmospheric Pressure Type
			if (Activity has :getActivityInfo and Activity.getActivityInfo() has :meanSeaLevelPressure) {
				if(Activity.getActivityInfo().meanSeaLevelPressure!=null){
					pressure = Activity.getActivityInfo().meanSeaLevelPressure;
				}
			}
		} else {
			if (Activity has :getActivityInfo and Activity.getActivityInfo() has :rawAmbientPressure) {
				//elevation = Activity.getActivityInfo().altitude;
				if(Activity.getActivityInfo().rawAmbientPressure!=null){
					pressure = Activity.getActivityInfo().rawAmbientPressure;
				} else if (Activity.getActivityInfo() has :AmbientPressure and Activity.getActivityInfo().ambientPressure!=null){
					pressure = Activity.getActivityInfo().ambientPressure;
				}
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
				pressure = pressure / 100;
				pressure = pressure.format("%.0f");				
				//unit = " hPa";
			} else {
				pressure = pressure / 100 * 0.02953; // inches of mercury
				pressure = pressure.format("%.1f");
				//unit = " inHg";
			}
			
		} else{
			pressure = "";
		}
       		
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(xText, yText, fontSize, pressure, Graphics.TEXT_JUSTIFY_LEFT); // pressure in hPa
	}


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
					if (forecast[0].forecastTime != null){ // Trying to fix an error when weather data is not available
						var info = Gregorian.info(forecast[0].forecastTime, Time.FORMAT_SHORT);
						var x2Icon = xIcon + 1;
						drawWeatherIcon(dc, xIcon, yIcon, x2Icon, width, forecast[0].condition, info.hour);
						var adj = xIcon + dc.getTextWidthInPixels("000", 0) + 1;
						drawWeatherIcon(dc, adj, yIcon, adj, width, forecast[1].condition, info.hour+1);
						if (size==3 and width>208) { // don't go in if FR55 (not enough space/resolution for 3 hour forecast)
							adj = adj + dc.getTextWidthInPixels("000", 0) + 1;
							drawWeatherIcon(dc, adj, yIcon, adj, width, forecast[2].condition, info.hour+2);
						}					
					}
				}
			}
	//	}
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
				} else if (width<=400) {
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
			dc.drawText(xText , yText, fontSize, windStr + unit, Graphics.TEXT_JUSTIFY_LEFT); // Wind Speed in km/h or mph
		}     
	}

	/* ------------------------ */
	
	// Draw Solar Intensity
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
					solarIconColour = 0xAAFF00; /* Vivomove GREEN */
				} else {
					solarIconColour = 0x55FF00; /* GREEN */
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
			if (dc.getFontHeight(0)>=26){
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
		var intensity=0;

		if (ActivityMonitor.getInfo().activeMinutesWeek.total != null and ActivityMonitor.getInfo().activeMinutesWeekGoal!=null) {
	    	intensity = ActivityMonitor.getInfo().activeMinutesWeek.total;//.toString();
	  } else {
	    	return false;
		}

		if (intensity>=ActivityMonitor.getInfo().activeMinutesWeekGoal) {
			dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
		} else {
			if (width>=360){ //AMOLED
				dc.setColor((fontColor==Graphics.COLOR_WHITE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY), Graphics.COLOR_TRANSPARENT);
			} else { // MIP, for better readability
				dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
				yIcon = yIcon-5;
			}
	  }

		if (width==240 and System.SCREEN_SHAPE_ROUND == screenShape){
			yIcon = yIcon - 1;
			if (dc.getFontHeight(0)>=26){
				yIcon = yIcon - 1;
			}
		} else if (width==218){
			yIcon = yIcon + 1;
		}

		dc.drawText( xIcon, yIcon, IconsFont, "B", Graphics.TEXT_JUSTIFY_CENTER); // Using Font

		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(xText, yText,	fontSize, intensity, Graphics.TEXT_JUSTIFY_LEFT);

		return true;
	}

/* ------------------------ */
	
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

/* ------------------------ */
	
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

/* ------------------------ */
	// Add Vo2 Max - vo2maxRunning and vo2maxCycling from UserProfile.getProfile()

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
					dc.setColor(0xAAFF00, Graphics.COLOR_TRANSPARENT); /* Vivomove GREEN */
				} else {
					dc.setColor(0x55FF00, Graphics.COLOR_TRANSPARENT); /* GREEN */
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

/* ------------------------ */
	// Add respiration Rate (breaths per minute) - respirationRate from ActivityMonitor.getInfo()
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

/* ------------------------ */

	// Add Recovery Time (hours) - timeToRecovery from ActivityMonitor.getInfo()
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


	/* ------------------------ */

	// Draw next Sun Event time
	//(:memory) 
(:tempo) function drawSunriseSunset(dc, xIcon, yIcon, xText, yText, width) {	
          
		// placeholder for SDK 5
		var myTime = System.getClockTime(); 
		var sunset, sunrise;

		if (Toybox has :Weather and Weather has :getSunset and Weather has :getSunrise) {
			if (Toybox.Weather.getCurrentConditions()!=null){
				var position = Toybox.Weather.getCurrentConditions().observationLocationPosition; // or Activity.Info.currentLocation if observation is null?
				var today = Toybox.Weather.getCurrentConditions().observationTime; // or new Time.Moment(Time.now().value()); ?
				if (position!=null and today!=null){
					// sunset = Time.Gregorian.info(Weather.getSunset(position, today), Time.FORMAT_SHORT);
					// sunrise = Time.Gregorian.info(Weather.getSunrise(position, today), Time.FORMAT_SHORT);
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
		dc.drawText( xIcon, yIcon + offset , IconsFont, icon, Graphics.TEXT_JUSTIFY_CENTER); // Using Font
		
		dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
		//dc.drawText( xText, yText , fontSize, Lang.format("$1$:$2$$3$",[time.hour.format("%02u"), time.min.format("%02u"), am_pm]), Graphics.TEXT_JUSTIFY_LEFT);
		
		if (time!=null){
			text=Lang.format("$1$:$2$",[time.hour.format("%02u"), time.min.format("%02u")]);
		}
		
		dc.drawText( xText, yText , fontSize, text, Graphics.TEXT_JUSTIFY_LEFT);
		if (am_pm!=""){
			dc.drawText(xText + dc.getTextWidthInPixels(text,fontSize), yText + fontSize*((dc.getFontHeight(Graphics.FONT_TINY)-dc.getFontHeight(Graphics.FONT_XTINY))*0.9 - (width==360 ? 1 : 0)),	0, am_pm, Graphics.TEXT_JUSTIFY_LEFT);
		}

		return true;
	}


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
			drawNotification(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.03)-offset390, xText, yText, accentColor, width);
		} else if ((side>2 and dataPoint == 10) or (side<=2 and dataPoint == 14)) { // SolarIntensity (dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawSolarIntensity(dc, xIcon, yIcon, xText, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 11) or (side<=2 and dataPoint == 15)) { // Seconds
			drawSeconds(dc, xIcon, yIcon+(width*0.02)-(offset390*2), xText, yText, width, 1);
		} else if ((side>2 and dataPoint == 12) or (side<=2 and dataPoint == 16)) { // Digital Clock
			drawSeconds(dc, xIcon, yIcon+(width*0.02)-(offset390*2), xText, yText, width, 2);
		} else if ((side>2 and dataPoint == 13) or (side<=2 and dataPoint == 17)) { // Intensity Minutes
			drawIntensityMin(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.025)-(offset390*2), xText, yText, width, accentColor);
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
		}	else if ((side>2 and dataPoint == 20) or (side<=2 and dataPoint == 24)) { // Next Sun Event
			drawSunriseSunset(dc, xIcon, yIcon+(xIcon*0.002), xText-offset390, yText, width);
		} else if ((side>2 and dataPoint == 21) or (side<=2 and dataPoint == 25)) { // Notification(dc, xIcon, yIcon, xText, yText, accentColor, width, Xoffset)
			//drawBatteryConsumption(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.035)-offset390, xText, yText, width);
			drawBatteryConsumption(dc, xIcon-(xIcon*0.002), yIcon+(width*0.025)-offset390, xText, yText, width);
		} else if (side>2 and dataPoint == 22){
			drawForecast(dc, xIcon+(width*0.06), yIcon+(width*0.01), width, 2);
		} else if (side<=2 and dataPoint == 1) { 
			drawDistance(dc, xIcon-offset390, yIcon, xText+(xText*0.015)-offset390, yText, width, accentColor);
		} else if (side<=2 and dataPoint == 2) { // elevationIcon(dc, xIcon, yIcon, xText, yText, width)
			drawElevation(dc, xIcon-(xIcon*0.015), yIcon-(xIcon*0.01), xText+(xText*0.015)-offset390, yText, width);
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
			drawNotification(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.03)-offset390, xText, yText, accentColor, width);
		} else if ((side>2 and dataPoint == 10) or (side<=2 and dataPoint == 14)) { // SolarIntensity (dc, xIcon, yIcon, xText, yText, width, accentColor)
			drawSolarIntensity(dc, xIcon, yIcon, xText, yText, width, accentColor);
		} else if ((side>2 and dataPoint == 11) or (side<=2 and dataPoint == 15)) { // Seconds
			drawSeconds(dc, xIcon, yIcon+(width*0.02)-(offset390*2), xText, yText, width, 1);
		} else if ((side>2 and dataPoint == 12) or (side<=2 and dataPoint == 16)) { // Digital Clock
			drawSeconds(dc, xIcon, yIcon+(width*0.02)-(offset390*2), xText, yText, width, 2);
		} else if ((side>2 and dataPoint == 13) or (side<=2 and dataPoint == 17)) { // Intensity Minutes
			drawIntensityMin(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.025)-(offset390*2), xText, yText, width, accentColor);
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
			//drawBatteryConsumption(dc, xIcon-(xIcon*0.002), yIcon+(xIcon*0.035)-offset390, xText, yText, width);
			drawBatteryConsumption(dc, xIcon-(xIcon*0.002), yIcon+(width*0.025)-offset390, xText, yText, width);
		} else if (side<=2 and dataPoint == 1) { 
			drawDistance(dc, xIcon-offset390, yIcon, xText+(xText*0.015)-offset390, yText, width, accentColor);
		} else if (side<=2 and dataPoint == 2) { // elevationIcon(dc, xIcon, yIcon, xText, yText, width)
			drawElevation(dc, xIcon-(xIcon*0.015), yIcon-(xIcon*0.01), xText+(xText*0.015)-offset390, yText, width);
		}
	}


}