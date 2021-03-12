# MoveToBeActive Garmin Watch Face
![MoveToBeActive Logo](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Logo2-MoveToBeActive.png?raw=true)

Garmin Watch Face that was initially meant for the VivoActive 4 series, as I want to replace my current Vivomove HR soon. Even though I'm now going to move (no pun intended) to a more smartwatch kind of device instead of a hybrid, I do prefer the regular/classic look of an analog watch. So that's when I decided to start developing a watch face inspired by the design of the Vivomove series, but adding extra features that will be very useful for my daily type of usage (more health related than activity tracking), but still focusing on maximizing battery life.

<img src="https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Vivomove.jpg?raw=true" height="270"> <img src="https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Arrow.png?raw=true" height="270"> ![MoveToBeActive](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Home3.png?raw=true)

Download the compiled version from Garmin's ConnectIQ store:

[<img src="https://raw.githubusercontent.com/wwarby/walker/master/supporting-files/available-connect-iq-badge.svg" width="350" href="https://apps.garmin.com/en-US/apps/736a2d5a-3b08-4cb1-8358-461f7374b0c8">](https://apps.garmin.com/en-US/apps/736a2d5a-3b08-4cb1-8358-461f7374b0c8)

## Feature listing:
* Analog hands for Hour and Minutes, but not for Seconds to mimic Vivomove HR (and save battery);
* Current Date with day of the week and Month;
* Garmin Logo that can be hidden on the watch face's config menu;
* Battery percentage with symbol changing colors depending on battery left: Red (less than 15%), Yellow (between 15 and 30%) and Green (greater than 31%);
* Notifications count: Accent color if at least one notification is available or Grey if no unread notifications;
* Bluetooth indicator: Blue (connected to the phone) or Grey (not connected);
* Alarm indicator: Accent color (at least one alarm active) or Grey (no alarms);
* Do not Disturb indicator (only shown when mode is activate);
* City name (if available) that can be hidden on the watch face's config menu;
* Current weather condition icon;
* Temperature indicator (if available) in Celsius or Fahrenheit (also dependent on watch's selected units display);
* Top left data point - Can be selected between one of the below:
  - **Heart Rate data**, showing last available value (not updated every second when not doing an activity, to save battery) and a symbol that is presented with colors from 7 different rate zones, set up by the user on the watch main settings (Settings - User Profile - Heart Rate - Zones - Based On);
  - (coming soon) **Calories burned**: Icon will be displayed in Grey until calories goal has been met, changing to the Accent color of choice;
* Middle left data point - Can be selected between one of the below:
  - **Distance** walked/ran on the day (km or miles, dependent on watch's selected unit on general config): Icon will be displayed in Grey until steps goal has been met, changing to the Accent color of choice;
  - (coming soon) **Elevation** (altitude above mean sea level in meters): Derived from the most accurate source (Barometer or GPS) in order of descending accuracy. If no GPS is present, then barometer readings will be used;
  - (coming soon) **Wind speed**: Current wind speed in km/h;
* Bottom left data point - Can be selected between one of the below:
  - **Blood oxygen** percentage: will automatically activate when the sensor is active, temporarily replacing whatever data point was selected for this same position. As soon as it deactivates, the previous data point (setup on the watch face's config menu and listed below) will show up again;
  - **Floors climbed** count: Icon will be displayed in Grey until floors climbed goal has been met, changing to the Accent color of choice;
  - (coming soon) **Precipitation** percentage: The current chance of rain/snow precipitation (0-100%);
  - (coming soon) **Humidity** percentage: The current relative humidity (0-100%);
  - (coming soon) **Solar intensity** percentage: Describes the solar sensor's charge efficiency, if available on the devide (0-100%).

## Support this project:
[<img src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" href="https://paypal.me/pools/c/8x2wuxFwFu">](https://paypal.me/pools/c/8x2wuxFwFu)

## Release notes:
**0.1.0** (22/Feb/21)
- [X] Initial public release

**0.2.0** (23/Feb/21)
- [X] Added temperature, weather condition and city name, as well as anti-alias for hour and minute hands

**0.3.0** (24/Feb/21)
- [X] Correct bug with battery % on Venu and D2 Air devices (font size issue due to bigger resolution)

**0.3.5** (25/Feb/21)
- [X] Improve alignment of battery % text and several other icons and texts for different watch sizes and resolutions

**0.4.0** (26/Fev/21)
- [X] Add the blood oxygen percentage (on supported watches only) when that is activated (usually during the night), temporarily replacing the floor climb count. When pulse ox is disabled, the floor count will show up again. Useful for people that are using pulse ox 24/7 or for those who wake up during the night (mainly those with sleep apnea) and want to check their current blood oxygen percentage

**0.4.5** (04/Mar/21)
- [X] Corrected a bug on the battery icon color and added fixed heart rate zones, in case the user didn't set them up on the watch settings (Settings - User Profile - Heart Rate - Zones - Based On)

**0.4.7** (05/Mar/21)
- [X] When the location name has more than 15 digits in length, the country is now being omitted. In case the final string is still bigger than 21 digits, it is being truncated (just in case)
- [X] The floors climbed icon will now turn green when the goal has been reached on that day
- [X] The steps icon will now turn green when the goal has been reached on that day
- [X] The notification icon will be grey when there is no notification and green when at least one notification is available
- [X] Testing a new tone of green, as it was becoming yellow when the backlight was on (transreflective displays only, AMOLED displays will keep the old green tone)

**0.5.0** (07/Mar/21)
- [X] Corrected inconsistencies with the length and width of the minute and hour hands across different resolutions
- [X] Redesigned hour and minute hands to have even better anti-aliasing
- [X] Added a menu on the watch face settings ("pencil" icon on the watch face selection screen) with an option to cycle through 8 different accent colors
- [X] The colored icons that indicate goal reached (floor climbed & steps) and notification avilable will now follow the same accent color used on the minute hand
- [X] Added support for the Vivoactive 3 Music watch

**0.6.0** (09/Mar/21)
- [X] Add toggle to hide/show Garmin logo
- [X] Add toggle to hide/show Bluetooth logo
- [X] Add toggle to hide hour labels (3, 6, 9, 12), that when hidden would add accent-colored horizontal hash marks on the location where the 3 and 9 numbers were
- [X] Add toggle to hide/show location name
- [X] Add toggle to switch between the current real or feels like temperatures

**0.7.0** (coming soon)
- [ ] Add alarm icon beside the bluetooth logo when at least one is active. If no alarm has been set, then icon will be hidden
- [ ] Create functions for each data point (big internal code change that will support customizations on the next releases)
- [ ] Memory optimizations (especially peak usage, but also a bit on average)

**0.8.0** 
- [ ] Top left data point - Add selector to show: heart rate or calories burned (ActivityMonitor.Info.calories) 
- [ ] Middle left data point - Add selector to show: distance walked, elevation (Sensor.Info.altitude and System.getDeviceSettings().elevationUnits) or wind speed (Weather.CurrentConditions.windSpeed)
- [ ] Bottom left data point - Add selector to show: floors climbed, precipitation percentage (Weather.CurrentConditions.precipitationChance), humidity percentage (Weather.CurrentConditions.relativeHumidity) or solar intensity percentage (for solar powered devices - System.Stats.solarIntensity)

## Watchface examples: (Not real photos, just taken from Garmin's Watch Simulator)

### Vivoactive 4
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/MoveToBeActive.png?raw=true)

### Enduro
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Enduro.png?raw=true)

### Fenix 6S Pro
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Fenix6Spro.png?raw=true)

### Forerunner 745
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Forerunner745.png?raw=true)

### Forerunner 245
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Forerunner245.png?raw=true)

### Venu
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Venu.png?raw=true)

# Inspiration:
* https://github.com/wwarby/walker
* https://github.com/pshriwise/connectiqanalog
* https://github.com/Laverlin/Yet-Another-WatchFace
* https://github.com/warmsound/crystal-face
* https://github.com/darrencroton/SnapshotWatch
* https://github.com/OliverHannover/Formula_1
* https://github.com/tumb1er/ElPrimero
