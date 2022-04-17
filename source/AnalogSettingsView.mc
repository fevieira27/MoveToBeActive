//
// Copyright 2016-2017 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Application.Storage;

var count=0;

class AnalogSettingsViewTest extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize(null);


//    function onMenu() {
    
	// Add menu items for demonstrating toggles, checkbox and icon menu items
    //menu.addItem(new WatchUi.MenuItem("Toggles", "sublabel", "toggle", null));
    //menu.addItem(new WatchUi.MenuItem("Checkboxes", null, "check", null));
    //menu.addItem(new WatchUi.MenuItem("Icons", null, "icon", null));
    //menu.addItem(new WatchUi.MenuItem("Custom", null, "custom", null));
    //WatchUi.pushView(menu, new AnalogSettingsDelegate(), WatchUi.SLIDE_UP );

    // Generate a new Menu with a drawable Title
    //var menu = new WatchUi.Menu2({:title=>new DrawableMenuTitle()});
    Menu2.setTitle(new DrawableMenuTitle());

    Menu2.addItem(new WatchUi.MenuItem("Layout", null, "design", null));
    Menu2.addItem(new WatchUi.MenuItem("Data Fields", null, "datapoints", null));
    
    //WatchUi.pushView(Menu2, new Menu2TestMenu2Delegate(), WatchUi.SLIDE_UP );	

	}

	function onSelect(item) {
        // For IconMenuItems, we will change to the next icon state.
        // This demonstates a custom toggle operation using icons.
        // Static icons can also be used in this layout.

        if(item instanceof IconMenuItem) {
            item.setSubLabel(item.getIcon().nextState(item.getId()));
        } else {
            Storage.setValue(item.getId(), item.isEnabled());       
        }
        
        WatchUi.requestUpdate();
    }    

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return false;
    }  

    function onDone() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onWrap(key as WatchUi.Key) {
        return true;
    }    

}


class Menu2TestMenu2Delegate extends WatchUi.Menu2InputDelegate { // Sub-menu Design

	function initialize() {
        Menu2InputDelegate.initialize();
    }

	function onSelect(item) {

		var boolean;

        if( item.getId().equals("design") ) {
		    // Generate a new Menu with a Text Title
		    
		    var iconMenu = new WatchUi.Menu2({:title=>"Design"});
		    var drawable1 = new CustomAccent();
		    iconMenu.addItem(new WatchUi.IconMenuItem("Accent Color", drawable1.getString(), 1, drawable1, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    
		    if (Storage.getValue(3) != null ){
		    	boolean = Storage.getValue(3);
		    } else {
		    	boolean = true;
		    } 
		    //ToggleMenuItem(label, subLabel, identifier, enabled, options)
		    iconMenu.addItem(new WatchUi.ToggleMenuItem("Garmin Logo", {:enabled=>"ON", :disabled=>"OFF"}, 3, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    if (Storage.getValue(4) != null ){
		    	boolean = Storage.getValue(4);
		    } else {
		    	boolean = true;
		    } 
		    iconMenu.addItem(new WatchUi.ToggleMenuItem("Bluetooth Logo", {:enabled=>"ON", :disabled=>"OFF"}, 4, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    if (Storage.getValue(8) != null ){
		    	boolean = Storage.getValue(8);
		    } else {
		    	boolean = true;
		    }
		    iconMenu.addItem(new WatchUi.ToggleMenuItem("Alarm Icon", {:enabled=>"ON", :disabled=>"OFF"}, 8, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));    
            if (System.SCREEN_SHAPE_ROUND == System.getDeviceSettings().screenShape) {
                if (Storage.getValue(5) != null ){
                    boolean = Storage.getValue(5);
                } else {
                    boolean = true;
                }
		        iconMenu.addItem(new WatchUi.ToggleMenuItem("Hour Labels", {:enabled=>"ON", :disabled=>"OFF"}, 5, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            }
            //if (width==240 and dc.getTextDimensions("100",0)[1]>=26){
            if (Toybox has :Weather){ // Doesn't show for Fenix 5 Plus
                if (Storage.getValue(7) != null ){
                    boolean = Storage.getValue(7);
                } else {
                    boolean = true;
                }
                iconMenu.addItem(new WatchUi.ToggleMenuItem("Location Name", {:enabled=>"ON", :disabled=>"OFF"}, 7, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            }
            // allow full colors in AOD for AMOLED devices
            if(System.getDeviceSettings().requiresBurnInProtection == true){
                if (Storage.getValue(18) != null ){
                    boolean = Storage.getValue(18);
                } else {
                    boolean = true;
                }
                iconMenu.addItem(new WatchUi.ToggleMenuItem("Mute AOD Colors", {:enabled=>"Mute Colors", :disabled=>"Full Color"}, 18, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            }
                		    
            var drawableT = new CustomThickness();
/*		    if (Storage.getValue(13) != null ){
		    	boolean = Storage.getValue(13);
		    } else {
		    	boolean = false;
		    }*/
		    iconMenu.addItem(new WatchUi.IconMenuItem("Hands Thickness", drawableT.getString(), 13, drawableT, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));

		    WatchUi.pushView(iconMenu, new AnalogSettingsViewTest(), WatchUi.SLIDE_UP );
        } else if( item.getId().equals("datapoints") ) {
		    var dataMenu = new WatchUi.Menu2({:title=>"Data"});
		    count=0;
		    var drawable2 = new CustomLeftTopDataPoint();
		    var drawable3 = new CustomLeftTopDataPoint();
		    count=0;
		    var drawable4 = new CustomLeftBottomDataPoint();
		    var drawable5 = new CustomLeftBottomDataPoint();
            var drawable6 = new CustomLeftBottomDataPoint();
		    dataMenu.addItem(new WatchUi.IconMenuItem("Left Top", drawable2.getString(), 9, drawable2, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    dataMenu.addItem(new WatchUi.IconMenuItem("Left Middle", drawable3.getString(), 10, drawable3, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    dataMenu.addItem(new WatchUi.IconMenuItem("Left Bottom", drawable4.getString(), 11, drawable4, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            dataMenu.addItem(new WatchUi.IconMenuItem("Right Top", drawable6.getString(), 17, drawable6, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    dataMenu.addItem(new WatchUi.IconMenuItem("Right Bottom", drawable5.getString(), 12, drawable5, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    if (Toybox has :Weather){
                if (Storage.getValue(6) != null ){
                    boolean = Storage.getValue(6);
                } else {
                    boolean = true;
                }	    		    		    
                dataMenu.addItem(new WatchUi.ToggleMenuItem("Temp. Type", {:enabled=>"Real Temperature", :disabled=>"Feels Like"}, 6, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
                if (Storage.getValue(15) != null ){
                    boolean = Storage.getValue(15);
                } else {
                    boolean = true;
                }
                dataMenu.addItem(new WatchUi.ToggleMenuItem("Wind Speed Unit", {:enabled=>"km/h or mph", :disabled=>"m/s"}, 15, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
                if (Storage.getValue(16) != null ){
                    boolean = Storage.getValue(16);
                } else {
                    boolean = false;
                }
                dataMenu.addItem(new WatchUi.ToggleMenuItem("Temperat. Unit", {:enabled=>"Always Celsius", :disabled=>"User Settings"}, 16, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            }
/*		   	if (Storage.getValue(14) != null ){
		    	boolean = Storage.getValue(14);
		    } else {
		    	boolean = false;
		    }
		    dataMenu.addItem(new WatchUi.ToggleMenuItem("Font Size", {:enabled=>"Bigger", :disabled=>"Standard"}, 14, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));      
*/		    
		    WatchUi.pushView(dataMenu, new AnalogSettingsViewTest(), WatchUi.SLIDE_UP );			        	    
	    } else {
            WatchUi.requestUpdate();
        }  

	}

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return false;
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
        var mIndex;
        
        if (Storage.getValue(2) == false or Storage.getValue(2) == null){ 
        	mIndex = 0;
        } else {
        	mIndex=Storage.getValue(2);
        }        
        
        System.println(dc.getWidth());

        var appIcon = Application.loadResource(Rez.Drawables.LauncherIcon);        
        var bitmapWidth = appIcon.getWidth();
        var labelWidth = dc.getTextWidthInPixels("Config", Graphics.FONT_SMALL); // Aqui pra corrigir background?

        var bitmapX = (dc.getWidth() - (bitmapWidth + 2 + labelWidth)) / 3; // 2 = spacing
        var bitmapY = (dc.getHeight() - appIcon.getHeight()) / 2;
        var labelX = bitmapX + bitmapWidth + 2; // 2 = spacing
        var labelY = dc.getHeight() / 2;

		//var color = mColors[mIndex];
        //dc.setColor(color, color);

        var mColors = Application.loadResource(Rez.JsonData.mColors);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();               

        //dc.clearClip(); //clear instead?
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK); // removing the background color and all the data points from the background, leaving just the hour hands and hashmarks
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight()); //width & height?
        
        dc.drawBitmap(bitmapX, bitmapY, appIcon);
        dc.setColor(mColors[mIndex], Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, labelY, Graphics.FONT_SMALL, "Config", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}


// This is the custom Icon drawable. It fills the icon space with a color to
// to demonstrate its extents. It changes color each time the next state is
// triggered, which is done when the item is selected in this application.
class CustomAccent extends WatchUi.Drawable {

    // This constant data stores the color state list.
    //const mColors = [0x55FF00, 0xAAFF00, 0xFFFF00, Graphics.COLOR_BLUE, 0x00FFFF, 0xAA55FF, 0xFFAA00/*0xFF5500*/, 0xFF0000, 0xFF55FF, Graphics.COLOR_WHITE];
    //const mColorStrings = ["Bright Green", "Vivomove", "Yellow", "Sky Blue", "Aqua", "Medium Purple", "Orange", "Red", "Pink Flamingo", "White"];
    var mIndex;

    function initialize() {
        Drawable.initialize({});
        if (Storage.getValue(2) == false or Storage.getValue(2) == null){ 
        	mIndex = 0;
        } else {
        	mIndex=Storage.getValue(2);
        }
    }

    // Return the color string for the menu to use as it's sublabel
    function getString() {
        var mColorStrings = Application.loadResource(Rez.JsonData.mColorStrings);
        return mColorStrings[mIndex];
    }
    
    // Return the color code to save in Storage
    function getColor() {
        var mColors = Application.loadResource(Rez.JsonData.mColors);
        return mColors[mIndex];
    }

    // Advance to the next color state for the drawable
    function nextState(id) {
        var mColorStrings = Application.loadResource(Rez.JsonData.mColorStrings);
        mIndex++;
        if(mIndex >= mColorStrings.size()) {
            mIndex = 0;
        }
		Storage.setValue(1, getColor());
		Storage.setValue(2, mIndex);

        return mColorStrings[mIndex];
    }

    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    function draw(dc) {
        var mColors = Application.loadResource(Rez.JsonData.mColors);
	    var color = mColors[mIndex];
        dc.setColor(color, color);
        dc.clear();        
       
    }
}



// This is the custom Icon drawable. It fills the icon space with a color to
// to demonstrate its extents. It changes color each time the next state is
// triggered, which is done when the item is selected in this application.
class CustomLeftTopDataPoint extends WatchUi.Drawable {

    // This constant data stores the color state list.
    //const mIcons = ["0" /*stepsIcon*/, ";" /*elevationIcon*/, "P" /*windIcon*/, "A" /*humidityIcon*/, "S" /*precipitationIcon*/, "6" /*caloriesIcon*/, "1" /*floorsClimbIcon*/, "@" /*pulseOxIcon*/, "3" /*heartRateIcon*/, "5" /*notificationIcon*/, "R" /*solarIcon*/, "" /*none*/];
    //const mIconStrings = ["Steps", ,"Distance", "Elevation", "Wind Speed", "Humidity", "Precipitation", "Calories",  (ActivityMonitor.getInfo() has :floorsClimbed)?"Floors Climbed":"Not Available", (Activity.getActivityInfo() has :currentOxygenSaturation)?"Pulse Ox":"Not available", "Heart Rate", "Notification",(System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) ? "Solar Intensity" : "Not available", "None"];
    var mIndex; // 0=stepsIcon, 1=distanceIcon, 2=elevationIcon, 3=windSpeed, 4=humidityIcon, 5=precipitationIcon, 6=caloriesIcon, 7=floorsClimbIcon, 8=pulseOxIcon, 9=heartRateIcon, 10=notificationIcon, 11=solarIcon, 12=seconds, 13=intensityMin, 14=none
	
    function initialize() {
        Drawable.initialize({});
        var mArray=[Storage.getValue(9) == null ? 14 : Storage.getValue(9), Storage.getValue(10) == null ? 14 : Storage.getValue(10)]; // if values are null, then "none"
        mIndex=mArray[count];   
        count++;
    }

    // Return the icon string for the menu to use as its label
    function getString() {
        var mIconStrings = ["Steps", "Distance", "Elevation", (Toybox has :Weather)?"Wind Speed":"Not Available", (Toybox has :Weather)?"Humidity":"Not Available", (Toybox has :Weather)?"Precipitation":"Not Available", "Calories",  (ActivityMonitor.getInfo() has :floorsClimbed)?"Floors Climbed":"Not Available", (Activity.getActivityInfo() has :currentOxygenSaturation)?"Pulse Ox":"Not available", "Heart Rate", "Notifications",(System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) ? "Solar Intensity" : "Not available", "Seconds", "Intensity Min.", "None"];
        return mIconStrings[mIndex];
    }
    

    // Advance to the next color state for the drawable
    function nextState(id) {
        var mIconStrings = ["Steps", "Distance", "Elevation", (Toybox has :Weather)?"Wind Speed":"Not Available", (Toybox has :Weather)?"Humidity":"Not Available", (Toybox has :Weather)?"Precipitation":"Not Available", "Calories",  (ActivityMonitor.getInfo() has :floorsClimbed)?"Floors Climbed":"Not Available", (Activity.getActivityInfo() has :currentOxygenSaturation)?"Pulse Ox":"Not available", "Heart Rate", "Notifications",(System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) ? "Solar Intensity" : "Not available", "Seconds", "Intensity Min.", "None"];
        mIndex++;
        if(mIndex >= mIconStrings.size()) {
            mIndex = 0;
        }
		Storage.setValue(id, mIndex); //Storage 9 or 10
        return mIconStrings[mIndex];
    }

    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    function draw(dc) {
        var mIcons = Application.loadResource(Rez.JsonData.mIcons12);
        var iColor=0x55FF00;

        if (Storage.getValue(1) != null) {
			iColor = Storage.getValue(1);
        }
		
        dc.setColor(iColor, Graphics.COLOR_TRANSPARENT);
		if (mIndex < mIcons.size()-1){
			var iconsFont = Application.loadResource(Rez.Fonts.IconsFont);
			var humidityFont = Application.loadResource(Rez.Fonts.HumidityFont);		
			var icon = mIcons[mIndex];
			if (icon.find("R")!=null or icon.find("S")!=null or icon.find("P")!=null){
				dc.drawText( dc.getWidth()/2, dc.getHeight()/3, humidityFont, icon , Graphics.TEXT_JUSTIFY_CENTER);
			} else {
				dc.drawText( dc.getWidth()/2, dc.getHeight()/3, iconsFont, icon , Graphics.TEXT_JUSTIFY_CENTER);
			}
		}
        dc.clear();
    }
}
 

// This is the custom Icon drawable. It fills the icon space with a color to
// to demonstrate its extents. It changes color each time the next state is
// triggered, which is done when the item is selected in this application.
class CustomLeftBottomDataPoint extends WatchUi.Drawable {

    // This constant data stores the color state list.
    //const mIcons = ["A" /*humidityIcon*/, "S" /*precipitationIcon*/,  "6" /*caloriesIcon*/, "1" /*floorsClimbIcon*/, "@" /*pulseOxIcon*/, "3" /*heartRateIcon*/, "5" /*notificationIcon*/, "R" /*solarIcon*/ , "" /*none*/];
    //const mIconStrings = ["Humidity", "Precipitation", "Calories", (ActivityMonitor.getInfo() has :floorsClimbed)?"Floors Climbed":"Not Available", (Activity.getActivityInfo() has :currentOxygenSaturation)?"Pulse Ox":"Not available" , "Heart Rate", "Notification", (System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) ? "Solar Intensity" : "Not available", "None"];
    var mIndex; // 0=stepsIcon, 1=humidityIcon, 2=precipitationIcon, 3=caloriesIcon, 4=floorsClimbIcon, 5=pulseOxIcon, 6=heartRateIcon, 7=notificationIcon, 8=solarIcon, 9=seconds, 10=intensityMin, 11=none

    function initialize() {
        Drawable.initialize({});
        var mArray=[Storage.getValue(11) == null ? 11 : Storage.getValue(11), Storage.getValue(12) == null ? 11 : Storage.getValue(12), Storage.getValue(17) == null ? 11 : Storage.getValue(17)]; // if null, then "none"
        mIndex=mArray[count];   
        count++;
    }

    // Return the icon string for the menu to use as its label
    function getString() {
        var mIconStrings = ["Steps", (Toybox has :Weather)?"Humidity":"Not Available", (Toybox has :Weather)?"Precipitation":"Not Available", "Calories", (ActivityMonitor.getInfo() has :floorsClimbed)?"Floors Climbed":"Not Available", (Activity.getActivityInfo() has :currentOxygenSaturation)?"Pulse Ox":"Not available" , "Heart Rate", "Notifications", (System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) ? "Solar Intensity" : "Not available", "Seconds", "Intensity Min.", "None"];
        return mIconStrings[mIndex];
    }
    
    // Advance to the next color state for the drawable
    function nextState(id) {
        var mIconStrings = ["Steps", (Toybox has :Weather)?"Humidity":"Not Available", (Toybox has :Weather)?"Precipitation":"Not Available", "Calories", (ActivityMonitor.getInfo() has :floorsClimbed)?"Floors Climbed":"Not Available", (Activity.getActivityInfo() has :currentOxygenSaturation)?"Pulse Ox":"Not available" , "Heart Rate", "Notifications", (System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) ? "Solar Intensity" : "Not available", "Seconds", "Intensity Min.", "None"];
        mIndex++;
        if(mIndex >= mIconStrings.size()) {
            mIndex = 0;
        }
		Storage.setValue(id, mIndex);
        return mIconStrings[mIndex];
    }

    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    function draw(dc) {
        var mIcons = Application.loadResource(Rez.JsonData.mIcons9);
        var iColor=0x55FF00;

        if (Storage.getValue(1) != null) {
			iColor = Storage.getValue(1);
        }

		dc.setColor(iColor, Graphics.COLOR_TRANSPARENT);
		if (mIndex < mIcons.size()-1){			
			var iconsFont = Application.loadResource(Rez.Fonts.IconsFont);
			var humidityFont = Application.loadResource(Rez.Fonts.HumidityFont);
			var icon = mIcons[mIndex];
			if (icon.find("R")!=null or icon.find("S")!=null or icon.find("P")!=null){
				dc.drawText( dc.getWidth()/2, dc.getHeight()/3, humidityFont, icon , Graphics.TEXT_JUSTIFY_CENTER);
			} else {
				dc.drawText( dc.getWidth()/2, dc.getHeight()/3, iconsFont, icon , Graphics.TEXT_JUSTIFY_CENTER);
			}
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
        if (Storage.getValue(13) == false or Storage.getValue(13) == null){ 
        	mIndex = 0;
        } else if (Storage.getValue(13) == true) {
            mIndex = 1;
        } else {
        	mIndex=Storage.getValue(13); 
        }        
        //var mArray=[Storage.getValue(9) == null ? 11 : Storage.getValue(9), Storage.getValue(10) == null ? 11 : Storage.getValue(10)];
        //mIndex=mArray[count];   
        //count++;
    }

    // Return the icon string for the menu to use as its label
    function getString() {
        var mHandStrings = ["Standard", "Thicker", "Thinner"];
        return mHandStrings[mIndex];
    }
    

    // Advance to the next color state for the drawable
    function nextState(id) {
        var mHandStrings = ["Standard", "Thicker", "Thinner"];
        mIndex++;
        if(mIndex >= mHandStrings.size()) {
            mIndex = 0;
        }
		Storage.setValue(id, mIndex);
        return mHandStrings[mIndex];
    }


    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    function draw(dc) {
		dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        dc.clear();
    }
}