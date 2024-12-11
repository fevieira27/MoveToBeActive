//
// Copyright 2016-2017 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Application.Storage;

var count=0;

class AnalogSettingsViewTest extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize(null);

        // Generate a new Menu with a drawable Title
        Menu2.setTitle(new DrawableMenuTitle());

        var drawable1 = new CustomAccent();
        Menu2.addItem(new WatchUi.IconMenuItem("Accent Color", drawable1.getString(), 1, drawable1, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
        Menu2.addItem(new WatchUi.ToggleMenuItem("Theme", {:enabled=>"Light", :disabled=>"Dark"}, 32, Storage.getValue(32), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
        Menu2.addItem(new WatchUi.MenuItem("Layout", null, "design", null));
        Menu2.addItem(new WatchUi.MenuItem("Data Fields", null, "datapoints", null));
        if (Toybox has :Weather or System.getSystemStats() has :batteryInDays){ // 
            Menu2.addItem(new WatchUi.MenuItem("Base Units", null, "units", null));
        }
        //WatchUi.pushView(Menu2, new Menu2TestMenu2Delegate(), WatchUi.SLIDE_UP );	

	}

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return false;
    }  

    function onDone() {
        WatchUi.popView(WatchUi.SLIDE_BLINK);
    }

    function onWrap(key as WatchUi.Key) {
        return true;
    }    

}


class Menu2TestMenu2Delegate extends WatchUi.Menu2InputDelegate { // Sub-menu Design

	public function initialize() {
        Menu2InputDelegate.initialize();
    }

	public function onSelect(item) as Void {

        if (item instanceof WatchUi.IconMenuItem) {
            if (item.getIcon() instanceof CustomAccent){
                item.setSubLabel((item.getIcon() as CustomAccent).nextState(item.getId()));
            } else if (item.getIcon() instanceof CustomDataPoint){
                if (item.getId()==9 or item.getId()==10){
                    item.setSubLabel((item.getIcon() as CustomDataPoint).nextState(item.getId(),1)); //big
                } else {
                    item.setSubLabel((item.getIcon() as CustomDataPoint).nextState(item.getId(),2)); //small
                }
                //item.setSubLabel(item.getIcon().nextState(item.getId()));
            } else if (item.getIcon() instanceof CustomThickness){ // Custom Thickness
                item.setSubLabel((item.getIcon() as CustomThickness).nextState(item.getId()));
            } else if (item.getIcon() instanceof CustomWindSpeed){ // Custom Thickness
                item.setSubLabel((item.getIcon() as CustomWindSpeed).nextState(item.getId()));
            }
        } else if (item instanceof WatchUi.ToggleMenuItem and item.getId() instanceof Number) {
            Storage.setValue(item.getId() as Number, item.isEnabled());
        }

        WatchUi.requestUpdate(); // really needed?

        if( item.getId().equals("design") ) {
		    // Generate a new Menu with a Text Title
		    
		    var iconMenu = new WatchUi.Menu2({:title=>"Layout"});
		    //var drawable1 = new CustomAccent();
		    //iconMenu.addItem(new WatchUi.IconMenuItem("Accent Color", drawable1.getString(), 1, drawable1, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    
		    //ToggleMenuItem(label, subLabel, identifier, enabled, options)
		    iconMenu.addItem(new WatchUi.ToggleMenuItem("Garmin Logo", {:enabled=>"ON", :disabled=>"OFF"}, 3, Storage.getValue(3), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    iconMenu.addItem(new WatchUi.ToggleMenuItem("Bluetooth Logo", {:enabled=>"ON", :disabled=>"OFF"}, 4, Storage.getValue(4), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    iconMenu.addItem(new WatchUi.ToggleMenuItem("Alarm Icon", {:enabled=>"ON", :disabled=>"OFF"}, 8, Storage.getValue(8), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));    
            iconMenu.addItem(new WatchUi.ToggleMenuItem("Battery Icon", {:enabled=>"ON", :disabled=>"OFF"}, 26, Storage.getValue(26), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));    
            iconMenu.addItem(new WatchUi.ToggleMenuItem("Battery Color", {:enabled=>"Conditional", :disabled=>"Always Gray"}, 28, Storage.getValue(28), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));    
            if (System.SCREEN_SHAPE_ROUND == System.getDeviceSettings().screenShape) {
		        iconMenu.addItem(new WatchUi.ToggleMenuItem("Hour Labels", {:enabled=>"ON", :disabled=>"OFF"}, 5, Storage.getValue(5), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
                iconMenu.addItem(new WatchUi.ToggleMenuItem("Labels Color", {:enabled=>"Accent", :disabled=>"Default"}, 27, Storage.getValue(27), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));                
            }
            iconMenu.addItem(new WatchUi.ToggleMenuItem("Tickmark Color", {:enabled=>"Accent", :disabled=>"Default"}, 18, Storage.getValue(18), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            if (Toybox has :Weather and Toybox.Weather has :getCurrentConditions){ // has weather, doesn't show these for Fenix 5 Plus series
                iconMenu.addItem(new WatchUi.ToggleMenuItem("Weather Condition", {:enabled=>"ON", :disabled=>"OFF"}, 25, Storage.getValue(25), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
                iconMenu.addItem(new WatchUi.ToggleMenuItem("Condition Name", {:enabled=>"ON", :disabled=>"OFF"}, 7, Storage.getValue(7), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
                //iconMenu.addItem(new WatchUi.ToggleMenuItem("Location Name", {:enabled=>"ON", :disabled=>"OFF"}, 7, Storage.getValue(7), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));                
            }
            // allow these extra features only for LCD and AMOLED devices
            if(System.getDeviceSettings().requiresBurnInProtection){
                iconMenu.addItem(new WatchUi.ToggleMenuItem("AOD Colors", {:enabled=>"Accent", :disabled=>"Grayscale"}, 22, Storage.getValue(22), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
                if (System.SCREEN_SHAPE_ROUND == System.getDeviceSettings().screenShape) { //check if rounded display
                    iconMenu.addItem(new WatchUi.ToggleMenuItem("Seconds Hand", {:enabled=>"On", :disabled=>"Off"}, 33, Storage.getValue(33), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
                }
            }
            var drawableT = new CustomThickness();
		    iconMenu.addItem(new WatchUi.IconMenuItem("Hands Thickness", drawableT.nextState(-1), 13, drawableT, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    //WatchUi.pushView(iconMenu, new AnalogSettingsViewTest(), WatchUi.SLIDE_BLINK );
            WatchUi.pushView(iconMenu, new Menu2TestMenu2Delegate(), WatchUi.SLIDE_UP );
        } else if( item.getId().equals("datapoints") ) {
		    var dataMenu = new WatchUi.Menu2({:title=>"Data"});
		    count=0;
		    var drawable2 = new CustomDataPoint(1); // Big
		    var drawable3 = new CustomDataPoint(1); // Big
		    //count=0;
		    var drawable4 = new CustomDataPoint(2); // Small
		    var drawable5 = new CustomDataPoint(2); // Small
            var drawable6 = new CustomDataPoint(2); // Small
		    dataMenu.addItem(new WatchUi.IconMenuItem("Left Top", drawable2.nextState(-1,1/*big*/), 9, drawable2, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    dataMenu.addItem(new WatchUi.IconMenuItem("Left Middle", drawable3.nextState(-1,1/*big*/), 10, drawable3, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    dataMenu.addItem(new WatchUi.IconMenuItem("Left Bottom", drawable4.nextState(-1,2/*small*/), 11, drawable4, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            dataMenu.addItem(new WatchUi.IconMenuItem("Right Top", drawable6.nextState(-1,2/*small*/), 17, drawable6, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    dataMenu.addItem(new WatchUi.IconMenuItem("Right Bottom", drawable5.nextState(-1,2/*small*/), 12, drawable5, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		   	if (System.SCREEN_SHAPE_ROUND == System.getDeviceSettings().screenShape) { //check if rounded display
                dataMenu.addItem(new WatchUi.ToggleMenuItem("Font Size", {:enabled=>"Bigger", :disabled=>"Standard"}, 14, Storage.getValue(14), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            }
		    //WatchUi.pushView(dataMenu, new AnalogSettingsViewTest(), WatchUi.SLIDE_BLINK );
            WatchUi.pushView(dataMenu, new Menu2TestMenu2Delegate(), WatchUi.SLIDE_UP );
        } else if( item.getId().equals("units") ) { 
            //var checkWeather=Storage.getValue(21)[1]; // has :Weather
            var unitsMenu = new WatchUi.Menu2({:title=>"Units"});
            if (System.getSystemStats() has :batteryInDays){
                unitsMenu.addItem(new WatchUi.ToggleMenuItem("Battery Estimate", {:enabled=>"ON", :disabled=>"OFF"}, 19, Storage.getValue(19), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            }
            var info = Time.Gregorian.info(Time.now(), Time.FORMAT_LONG);
            unitsMenu.addItem(new WatchUi.ToggleMenuItem("Date Format", {:enabled=>Lang.format("$2$ $1$", [info.month, info.day]), :disabled=>Lang.format("$1$ $2$", [info.month, info.day])}, 24, Storage.getValue(24), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));    
            if (Toybox has :Weather and Toybox.Weather has :getCurrentConditions and Toybox.Weather.getCurrentConditions()!=null){
                if (Activity.getActivityInfo() has :rawAmbientPressure){
                    unitsMenu.addItem(new WatchUi.ToggleMenuItem("Atm. Pres. Type", {:enabled=>"Mean Sea Level", :disabled=>"Local Pressure"}, 20, Storage.getValue(20), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
                }
                //if (Toybox.Weather.getCurrentConditions().feelsLikeTemperature!=null and Toybox.Weather.getCurrentConditions().feelsLikeTemperature instanceof Number){
                    unitsMenu.addItem(new WatchUi.ToggleMenuItem("Temp. Type", {:enabled=>"Real Temperature", :disabled=>"Feels Like"}, 6, Storage.getValue(6), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
                //}
                unitsMenu.addItem(new WatchUi.ToggleMenuItem("Temp. Unit", {:enabled=>"Always Celsius", :disabled=>"User Settings"}, 16, Storage.getValue(16), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));		    
                //unitsMenu.addItem(new WatchUi.ToggleMenuItem("Wind Speed Unit", {:enabled=>"km/h or mph", :disabled=>"m/s"}, 15, Storage.getValue(15), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
                var drawableW = new CustomWindSpeed();
                unitsMenu.addItem(new WatchUi.IconMenuItem("Wind Speed Unit", drawableW.nextState(-1), 15, drawableW, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            }
            //WatchUi.pushView(unitsMenu, new AnalogSettingsViewTest(), WatchUi.SLIDE_BLINK );	
            WatchUi.pushView(unitsMenu, new Menu2TestMenu2Delegate(), WatchUi.SLIDE_UP );	
	    } else {
            WatchUi.requestUpdate();
        }  

	}

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        //return false;
    }  

}


// This is the custom drawable we will use for our main menu title
class DrawableMenuTitle extends WatchUi.Drawable {

    // This constant data stores the color state list.
    //const mColors = [0x55FF00, 0xAAFF00, 0xFFFF00, 0x00AAFF, 0x00FFFF, 0xAA55FF, 0xFFAA00, 0xFF0000, 0xFF55FF, 0xFFFFFF];

    function initialize() {
        Drawable.initialize({});
    }

    // Draw the application icon and main menu title
    function draw(dc) {
        var mIndex, width=dc.getWidth();
        
        if (Storage.getValue(2) == false or Storage.getValue(2) == null){ 
        	mIndex = 0;
        } else {
        	mIndex=Storage.getValue(2);
        }        

        var appIcon = Application.loadResource(Rez.Drawables.LauncherIcon);        
        var bitmapWidth = appIcon.getWidth();
        var labelWidth = dc.getTextWidthInPixels("Config", Graphics.FONT_SMALL);

        if(labelWidth==117 and dc has :drawScaledBitmap){ // Venu 3s
            bitmapWidth=55;
        }
    	
        if (width>=390) { // Venu 3 watch allows full width to menu header, as opposed to all other watches which is half width. This condition corrects it.
            width = width*1.25;
        } 
        var bitmapX = (width - (bitmapWidth + 2 + labelWidth)) / 3; // 2 = spacing between logo and text
        var bitmapY = (dc.getHeight() - appIcon.getHeight()) / 2;
        var labelX = bitmapX + bitmapWidth + 2; // 2 = spacing between logo and text
        var labelY = dc.getHeight() / 2;

		//var color = mColors[mIndex];
        //dc.setColor(color, color);
        //System.println(labelWidth);
        var mColors;
        if (Storage.getValue(32) == null or Storage.getValue(32) == false){
            mColors = Application.loadResource(Rez.JsonData.mColors) as Array;
        } else {
            mColors = Application.loadResource(Rez.JsonData.mColorsWhite) as Array;
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();               

        //dc.clearClip(); //clear instead?
        var Color;
        if (Storage.getValue(32) == null or Storage.getValue(32) == false){ // Dark
            Color = Graphics.COLOR_BLACK;
        } else { // Light
            Color = Graphics.COLOR_WHITE;
        }
        dc.setColor(Color, Color); // removing the background color and all the data points from the background, leaving just the hour hands and hashmarks
        dc.fillRectangle(0, 0, width, dc.getHeight()); //width & height?
        
        if(labelWidth==117 and dc has :drawScaledBitmap){ // Venu 3s
            dc.drawScaledBitmap(bitmapX, bitmapY, 55, 55, appIcon); // making icon smaller on this watch, since dc width on top of the screen is quite small constrasting to the big default icon size (70x70)
        } else if (labelWidth==117){ // Vivoactive 5, which doesn't have ScaledBitmap and icon is too big. Removing it and showing only text.
            labelX = (width - (labelWidth)) / 2;
        } else {
            dc.drawBitmap(bitmapX, bitmapY, appIcon);
        }

        dc.setColor(mColors[mIndex], Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, labelY, Graphics.FONT_SMALL, "Config", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        if(mColors[mIndex] != Storage.getValue(1)){
            Storage.setValue(2, mIndex);
            Storage.setValue(1, mColors[mIndex]);
        }
    }
}


// This is the custom Icon drawable. It fills the icon space with a color to
// to demonstrate its extents. It changes color each time the next state is
// triggered, which is done when the item is selected in this application.
class CustomAccent extends WatchUi.Drawable {

    // This constant data stores the color state list.
    //const mColors = [0x55FF00, 0xAAFF00, 0xFFFF00, Graphics.COLOR_BLUE, 0x00FFFF, 0xAA55FF, 0xFFAA00/*0xFF5500*/, 0xFF0000, 0xFF55FF, Graphics.COLOR_WHITE];
    //const mColorStrings = ["Bright Green", "Vivomove", "Yellow", "Sky Blue", "Aqua", "Medium Purple", "Orange", "Red", "Pink Flamingo", "White"];
    private var mIndex as Number;

    public function initialize() {
        Drawable.initialize({});
        if (Storage.getValue(2) == false or Storage.getValue(2) == null){ 
        	mIndex = 0;
        } else {
        	mIndex=Storage.getValue(2);
        }
    }

    // Return the color string for the menu to use as it's sublabel
    public function getString() {
        var mColorStrings;
        //if (Storage.getValue(32) == null or Storage.getValue(32) == false){
        if (Storage.getValue(32) == true){
            mColorStrings = Application.loadResource(Rez.JsonData.mColorStringsWhite) as Array;
        } else {
            mColorStrings = Application.loadResource(Rez.JsonData.mColorStrings) as Array;
        }
         
        return mColorStrings[mIndex];
    }

    // Advance to the next color state for the drawable
    public function nextState(id) {
        //var mColorStrings = Application.loadResource(Rez.JsonData.mColorStrings);
        
        var mColors;
        if (Storage.getValue(32) == true){
            mColors = Application.loadResource(Rez.JsonData.mColorsWhite) as Array;
        } else {
            mColors = Application.loadResource(Rez.JsonData.mColors) as Array;
        }

        mIndex++;
        if(mIndex >= mColors.size()) {
            mIndex = 0;
        }
		Storage.setValue(1, mColors[mIndex]);
		Storage.setValue(2, mIndex);

        //return mColorStrings[mIndex];
        return getString();
    }

    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    public function draw(dc) {
        var mColors;
        if (Storage.getValue(32) == true){
            mColors = Application.loadResource(Rez.JsonData.mColorsWhite) as Array;
        } else {
            mColors = Application.loadResource(Rez.JsonData.mColors) as Array;
        }
	    var color = mColors[mIndex];
        dc.setColor(color, color);
        dc.clear();        
    }
}

// ------

// This is the custom Icon drawable. It fills the icon space with a color to
// to demonstrate its extents. It changes color each time the next state is
// triggered, which is done when the item is selected in this application.
class CustomDataPoint extends WatchUi.Drawable {

    // This constant data stores the color state list.
    //const mIcons = ["0" /*stepsIcon*/, ";" /*elevationIcon*/, "P" /*windIcon*/, "A" /*humidityIcon*/, "S" /*precipitationIcon*/, "6" /*caloriesIcon*/, "1" /*floorsClimbIcon*/, "@" /*pulseOxIcon*/, "3" /*heartRateIcon*/, "5" /*notificationIcon*/, "R" /*solarIcon*/, "" /*none*/];
    //const mIconStrings = ["Steps", ,"Distance", "Elevation", "Wind Speed", "Humidity", "Precipitation", "Calories",  (ActivityMonitor.getInfo() has :floorsClimbed)?"Floors Climbed":"Not Available", (Activity.getActivityInfo() has :currentOxygenSaturation)?"Pulse Ox":"Not available", "Heart Rate", "Notification",(System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) ? "Solar Intensity" : "Not available", "None"];
    var mIndex; // 0=stepsIcon, 1=distanceIcon, 2=elevationIcon, 3=windSpeed, 4=humidityIcon, 5=precipitationIcon, 6=caloriesIcon, 7=floorsClimbIcon, 8=pulseOxIcon, 9=heartRateIcon, 10=notificationIcon, 11=solarIcon, 12=seconds, 13=intensityMin, 14=none
    var type;
	
    function initialize(size) {
        Drawable.initialize({});
        type=size;
        var mArray=[Storage.getValue(9), Storage.getValue(10), Storage.getValue(11), Storage.getValue(12), Storage.getValue(17)]; // if values are null, then "none"
        mIndex=mArray[count];   
        count++;
    }
 

    // Advance to the next color state for the drawable, or return the icon string for the menu to use as its label if id=-1
    function nextState(id, size) {
        //var checkWeather = Storage.getValue(21)[2];
        var mIconStrings;

        if (size==2){ // Data field locations with length limitation = "small"
            mIconStrings = ["Steps", (Toybox has :Weather and Toybox.Weather has :getCurrentConditions)?"Humidity":"Not Available", (Toybox has :Weather and Toybox.Weather has :getCurrentConditions)?"Precipitation":"Not Available", (Activity.getActivityInfo() has :rawAmbientPressure) ? "Atm. Pressure" : "Not available", "Calories Total", "Calories Active", (ActivityMonitor.getInfo() has :floorsClimbed)?"Floors Climbed":"Not Available", (Activity.getActivityInfo() has :currentOxygenSaturation)?"Pulse Ox":"Not available" , "Heart Rate", "Notifications", (System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) ? "Solar Intensity" : "Not available", "Seconds", "Digital Clock", "Intensity Min.", ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory))?"Body Battery":"Not Available", ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getStressHistory))?"Stress":"Not Available", (ActivityMonitor.getInfo() has :respirationRate)?"Respiration Rate":"Not Available", (ActivityMonitor.getInfo() has :timeToRecovery)?"Recovery Time":"Not Available", (UserProfile.getProfile() has :vo2maxRunning)?"VO2 Max Run":"Not Available", (UserProfile.getProfile() has :vo2maxCycling)?"VO2 Max Cycle":"Not Available", ((Toybox has :Weather) && (Weather has :getSunset and Weather has :getSunrise))?"Next Sun Event":"Not Available", "Battery %/day", (Toybox has :Weather and Toybox.Weather has :getHourlyForecast)?"2h Forecast":"Not Available", "None"];
        } else { // No limitations on data field length
            mIconStrings = ["Steps", "Distance", "Elevation", (Toybox has :Weather and Toybox.Weather has :getCurrentConditions)?"Wind Speed":"Not Available", (Toybox has :Weather and Toybox.Weather has :getCurrentConditions)?"Min/Max Temp.":"Not Available", (Toybox has :Weather and Toybox.Weather has :getCurrentConditions)?"Humidity":"Not Available", (Toybox has :Weather and Toybox.Weather has :getCurrentConditions)?"Precipitation":"Not Available", (Activity.getActivityInfo() has :rawAmbientPressure) ? "Atm. Pressure" : "Not available", "Calories Total", "Calories Active",  (ActivityMonitor.getInfo() has :floorsClimbed)?"Floors Climbed":"Not Available", (Activity.getActivityInfo() has :currentOxygenSaturation)?"Pulse Ox":"Not available", "Heart Rate", "Notifications",(System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) ? "Solar Intensity" : "Not available", "Seconds", "Digital Clock", "Intensity Min.", ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory))?"Body Battery":"Not Available", ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getStressHistory))?"Stress":"Not Available", (ActivityMonitor.getInfo() has :respirationRate)?"Respiration Rate":"Not Available", (ActivityMonitor.getInfo() has :timeToRecovery)?"Recovery Time":"Not Available", (UserProfile.getProfile() has :vo2maxRunning)?"VO2 Max Run":"Not Available", (UserProfile.getProfile() has :vo2maxCycling)?"VO2 Max Cycle":"Not Available", ((Toybox has :Weather) && (Weather has :getSunset and Weather has :getSunrise))?"Next Sun Event":"Not Available", "Battery %/day", (Toybox has :Weather and Toybox.Weather has :getHourlyForecast)?"3h Forecast":"Not Available", "None"];
        }

        if (id!=-1){ // -1 means to return only the name, while any other value means to skip to next step
            type=size;
            mIndex++;
            if(mIndex >= mIconStrings.size()) {
                mIndex = 0;
            }
            Storage.setValue(id, mIndex); //Storage 9 or 10
        }
        return mIconStrings[mIndex]; // Return the icon string for the menu to use as its label
    }

    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    function draw(dc) {
        var mIcons;
        if (type==2) {
            mIcons = Application.loadResource(Rez.JsonData.mIcons9) as Array;
        } else {
            mIcons = Application.loadResource(Rez.JsonData.mIcons12) as Array;
        }
        var iColor=0x55FF00;

        if (Storage.getValue(1) != null) {
			iColor = Storage.getValue(1);
            if (iColor==Graphics.COLOR_WHITE){ iColor=Graphics.COLOR_LT_GRAY; }
        }
		
        dc.setColor(iColor, Graphics.COLOR_TRANSPARENT);
		if (mIndex < mIcons.size()-1){
			var iconsFont = Application.loadResource(Rez.Fonts.IconsFont);
			var icon = mIcons[mIndex];
            dc.drawText( dc.getWidth()/2, dc.getHeight()/3, iconsFont, icon , Graphics.TEXT_JUSTIFY_CENTER);
		}
        dc.clear();
    }
}


// This is the custom Icon drawable. It fills the icon space with a color to
// to demonstrate its extents. It changes color each time the next state is
// triggered, which is done when the item is selected in this application.
class CustomThickness extends WatchUi.Drawable {

    // This constant data stores the thickness state list.
    var mIndex; // thickInd --> 0 = Standard, 1 = Thicker , 2 = Thinner
	
    function initialize() {
        Drawable.initialize({});
        /*if (Storage.getValue(13) == false or Storage.getValue(13) == null){ 
        	mIndex = 0;
        } else if (Storage.getValue(13) == true) {
            mIndex = 1;
        } else {*/
        	mIndex=Storage.getValue(13); 
        //}        
    }    

    // Advance to the next color state for the drawable
    function nextState(id) {
        var mHandStrings = ["Standard", "Thicker", "Thinner"];
        if (id!=-1){ // -1 means to return only the name, while any other value means skip to next step
            mIndex++;
            if(mIndex >= mHandStrings.size()) {
                mIndex = 0;
            }
            Storage.setValue(id, mIndex);
        }
        return mHandStrings[mIndex];
    }

}


// This is the custom Icon drawable. It fills the icon space with a color to
// to demonstrate its extents. It changes color each time the next state is
// triggered, which is done when the item is selected in this application.
(:weather) class CustomWindSpeed extends WatchUi.Drawable {

    // This constant data stores the thickness state list.
    var mIndex; // WindSpeedUnit --> 0 = Standard (kph or mph), 1 = m/s , 2 = knots
	
    function initialize() {
        Drawable.initialize({});
        /*if (Storage.getValue(13) == false or Storage.getValue(13) == null){ 
        	mIndex = 0;
        } else if (Storage.getValue(13) == true) {
            mIndex = 1;
        } else {*/
        	mIndex=Storage.getValue(15); 
        //}        
    }    

    // Advance to the next color state for the drawable
    function nextState(id) {
        var mWindUnit = ["km/h or mph", "m/s", "knots"];
        if (id!=-1){ // -1 means to return only the name, while any other value means skip to next step
            mIndex++;
            if(mIndex >= mWindUnit.size()) {
                mIndex = 0;
            }
            Storage.setValue(id, mIndex);
        }
        return mWindUnit[mIndex];
    }

}