//
// Copyright 2016-2017 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application.Storage;

class AnalogSettingsView extends WatchUi.Menu2InputDelegate { // main menu

 	function initialize() {
        Menu2InputDelegate.initialize();
    }
	
	function onSelect(item) {
        // For IconMenuItems, we will change to the next icon state.
        // This demonstates a custom toggle operation using icons.
        // Static icons can also be used in this layout.
        //System.println(item.getId());
        if(item instanceof IconMenuItem) {
            item.setSubLabel(item.getIcon().nextState());
        } else {
            Storage.setValue(item.getId(), item.isEnabled());       
        }
        
        WatchUi.requestUpdate();
    }
    
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onDone() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
      
}

class AnalogSettingsDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
    
	// Add menu items for demonstrating toggles, checkbox and icon menu items
    //menu.addItem(new WatchUi.MenuItem("Toggles", "sublabel", "toggle", null));
    //menu.addItem(new WatchUi.MenuItem("Checkboxes", null, "check", null));
    //menu.addItem(new WatchUi.MenuItem("Icons", null, "icon", null));
    //menu.addItem(new WatchUi.MenuItem("Custom", null, "custom", null));
    //WatchUi.pushView(menu, new AnalogSettingsDelegate(), WatchUi.SLIDE_UP );

    // Generate a new Menu with a drawable Title
    var menu = new WatchUi.Menu2({:title=>new DrawableMenuTitle()});

    menu.addItem(new WatchUi.MenuItem("Design Options", null, "design", null));
    menu.addItem(new WatchUi.MenuItem("Data Points", null, "datapoints", null));
    WatchUi.pushView(menu, new Menu2TestMenu2Delegate(), WatchUi.SLIDE_UP );	

	}

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
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
		    if (Storage.getValue(5) != null ){
		    	boolean = Storage.getValue(5);
		    } else {
		    	boolean = true;
		    }
		    iconMenu.addItem(new WatchUi.ToggleMenuItem("3,6,9,12 Numbers", {:enabled=>"ON", :disabled=>"OFF"}, 5, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    if (Storage.getValue(7) != null ){
		    	boolean = Storage.getValue(7);
		    } else {
		    	boolean = true;
		    }
		    iconMenu.addItem(new WatchUi.ToggleMenuItem("Location Name", {:enabled=>"ON", :disabled=>"OFF"}, 7, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		//    iconMenu.addItem(new WatchUi.IconMenuItem("Icon 2", drawable2.getString(), "right", drawable2, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
		//    iconMenu.addItem(new WatchUi.IconMenuItem("Icon 3", drawable3.getString(), "default", drawable3, null));
		    WatchUi.pushView(iconMenu, new AnalogSettingsView(), WatchUi.SLIDE_UP );
        } else if( item.getId().equals("datapoints") ) {
		    var dataMenu = new WatchUi.Menu2({:title=>"Data"});
			var drawable2 = new CustomDataPoint();

		    if (Storage.getValue(6) != null ){
		    	boolean = Storage.getValue(6);
		    } else {
		    	boolean = true;
		    }
		    dataMenu.addItem(new WatchUi.ToggleMenuItem("Temperature Type", {:enabled=>"Real Temp.", :disabled=>"Feels Like"}, 6, boolean, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));

/*		    if (Storage.getValue(6) != null ){
		    	boolean = Storage.getValue(8);
		    } else {
		    	boolean = true;
		    }
*/		    
		    dataMenu.addItem(new WatchUi.IconMenuItem("Left Top", drawable2.getString(), 8, drawable2, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
		    
		    WatchUi.pushView(dataMenu, new AnalogSettingsView(), WatchUi.SLIDE_UP );			        	    
	    } else {
            WatchUi.requestUpdate();
        }  
	}

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }  

}


// This is the custom drawable we will use for our main menu title
class DrawableMenuTitle extends WatchUi.Drawable {

    // This constant data stores the color state list.
    const mColors = [0x55FF00, 0xAAFF00, 0xFFFF00, Graphics.COLOR_BLUE, 0x00FFFF, 0xAA55FF, 0xFFAA00/*0xFF5500*/, 0xFF0000, 0xFF55FF, Graphics.COLOR_WHITE];

    function initialize() {
        Drawable.initialize({});
    }

    // Draw the application icon and main menu title
    function draw(dc) {
        var spacing = 2;
        var mIndex;
        
        if (Storage.getValue(2) == false or Storage.getValue(2) == null){ 
        	mIndex = 0;
        } else {
        	mIndex=Storage.getValue(2);
        }        
        
        var appIcon = WatchUi.loadResource(Rez.Drawables.LauncherIcon);        
        var bitmapWidth = appIcon.getWidth();
        var labelWidth = dc.getTextWidthInPixels("Config", Graphics.FONT_SMALL);

        var bitmapX = (dc.getWidth() - (bitmapWidth + spacing + labelWidth)) / 3;
        var bitmapY = (dc.getHeight() - appIcon.getHeight()) / 2;
        var labelX = bitmapX + bitmapWidth + spacing;
        var labelY = dc.getHeight() / 2;

		var color = mColors[mIndex];
        dc.setColor(color, color);
        dc.clear();               
        
        dc.drawBitmap(bitmapX, bitmapY, appIcon);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, labelY, Graphics.FONT_SMALL, "Config", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}


// This is the custom Icon drawable. It fills the icon space with a color to
// to demonstrate its extents. It changes color each time the next state is
// triggered, which is done when the item is selected in this application.
class CustomAccent extends WatchUi.Drawable {

    // This constant data stores the color state list.
    const mColors = [0x55FF00, 0xAAFF00, 0xFFFF00, Graphics.COLOR_BLUE, 0x00FFFF, 0xAA55FF, 0xFFAA00/*0xFF5500*/, 0xFF0000, 0xFF55FF, Graphics.COLOR_WHITE];
    const mColorStrings = ["Green", "Vivomove", "Yellow", "Blue", "Cyan", "Violet", "Orange", "Red", "Pink", "White"];
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
        return mColorStrings[mIndex];
    }
    
    // Return the color code to save in Storage
    function getColor() {
        return mColors[mIndex];
    }

    // Advance to the next color state for the drawable
    function nextState() {
        mIndex++;
        if(mIndex >= mColors.size()) {
            mIndex = 0;
        }
		Storage.setValue(1, getColor());
		Storage.setValue(2, mIndex);
        return mColorStrings[mIndex];
    }

    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    function draw(dc) {
    
		var color = mColors[mIndex];
        dc.setColor(color, color);
        dc.clear();        
        
    }
}



// This is the custom Icon drawable. It fills the icon space with a color to
// to demonstrate its extents. It changes color each time the next state is
// triggered, which is done when the item is selected in this application.
class CustomDataPoint extends WatchUi.Drawable {

    // This constant data stores the color state list.
    const notificationIcon = "5";
    const mIcons = [notificationIcon, notificationIcon, notificationIcon, notificationIcon, notificationIcon, notificationIcon, notificationIcon/*0xFF5500*/, notificationIcon, notificationIcon, notificationIcon, notificationIcon];
    const mIconStrings = ["Solar Intensity", "Wind Speed", "Humidity", "Precipitation", "Elevation", "Calories", "Distance", "Floors Climbed", "Pulse Ox", "Heart Rate", "Notification"];
    var mIndex;

    function initialize() {
        Drawable.initialize({});
        if (Storage.getValue(8) == false or Storage.getValue(8) == true){ 
        	mIndex = 0;
        } else {
        	mIndex=Storage.getValue(8);
        }
        System.println(mIndex);
    }

    // Return the color string for the menu to use as it's sublabel
    function getString() {
        return mIconStrings[mIndex];
    }
    
    // Return the color code to save in Storage
    function getIcon() {
        return mIcons[mIndex];
    }

    // Advance to the next color state for the drawable
    function nextState() {
        mIndex++;
        if(mIndex >= mIcons.size()) {
            mIndex = 0;
        }
		//Storage.setValue(8, getIcon());
		Storage.setValue(8, mIndex);
        return mIconStrings[mIndex];
    }

    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    function draw(dc) {
    	
    	var IconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
		var icon = mIcons[mIndex];
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText( dc.getWidth()/2, dc.getHeight()/2, IconsFont, icon , Graphics.TEXT_JUSTIFY_CENTER);
        dc.clear();        
        
    }
}
