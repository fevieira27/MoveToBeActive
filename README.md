# MoveToBeActive Garmin Watch Face
![MoveToBeActive Banner](https://movetobeactive.github.io/img/banner2.jpg)

Garmin Watch Face that was initially meant for the VivoActive 4 series, as I want to replace my current Vivomove HR soon. Even though I'm now going to move (no pun intended) to a more smartwatch kind of device instead of a hybrid, I do prefer the regular/classic look of an analog watch. So that's when I decided to start developing a watch face inspired by the design of the Vivomove series, but adding extra features that will be very useful for my daily type of usage (more health related than activity tracking), but still focusing on maximizing battery life.

<img src="https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Vivomove.jpg?raw=true" height="270"> <img src="https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Arrow.png?raw=true" height="270"> ![MoveToBeActive](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Home4.png?raw=true)

Download the compiled version from Garmin's ConnectIQ store:

[<img src="https://raw.githubusercontent.com/wwarby/walker/master/supporting-files/available-connect-iq-badge.svg" width="350" href="https://apps.garmin.com/en-US/apps/736a2d5a-3b08-4cb1-8358-461f7374b0c8">](https://apps.garmin.com/en-US/apps/736a2d5a-3b08-4cb1-8358-461f7374b0c8)

## Feature listing:
* Analog hands for Hour and Minutes, but not for Seconds to mimic Vivomove HR (and save battery). Design menu has a toggle for standard or thick (30% larger) hands;
* **Current Date** with day of the week and Month;
* **Garmin Logo** that can be hidden on the watch face's config menu;
* **Battery percentage** with symbol changing colors depending on battery left: Red (less than 15%), Yellow (between 15 and 30%) and Green (greater than 31%);
* **Notifications** count: Accent color if at least one notification is available or Grey if no unread notifications;
* **Bluetooth** indicator: Blue (connected to the phone) or Grey (not connected);
* **Alarm** indicator: Accent color (at least one alarm active) or Grey (no alarms);
* **Do not Disturb** indicator (only shown when mode is activate);
* **Location name** of the source of weather data (if available), that can be hidden on the watch face's config menu;
* **Current weather** condition icon;
* **Temperature** indicator (if available) in Celsius or Fahrenheit (also dependent on watch's selected units display);
* **Heart Rate** data, showing last available value (not updated every second when not doing an activity, to save battery) and a symbol that is presented with colors from 7 different rate zones, set up by the user on the watch main settings (Settings - User Profile - Heart Rate - Zones - Based On). Color palette for each zone: Resting / Light Load = grey, Moderate Effort = blue, Weight Control = green, Aerobic = yellow, Anaerobic = orange, High effort = light red and Speed = bright red;
* **Calories** burned;
* **Distance** walked/ran on the day (km or miles, dependent on watch's selected unit on general config): Icon will be displayed in Grey until steps goal has been met, changing to the Accent color of choice;
* **Elevation** (altitude above mean sea level in meters): Derived from the most accurate source (Barometer or GPS) in order of descending accuracy. If no GPS is present, then barometer readings will be used;
* **Wind speed**: Current wind speed in km/h or mph (depending on watch's pace unit settings);
* **Blood oxygen** percentage: will display the current pulse ox if the sensor is active all the time. However, if sensor is activated only while sleeping or on ad-hoc measurements, data point will show last available value. Color palette doesn't follow accent color and is based on 5 zones: Healthy = green, Normal = blue, Low = yellow, Brain Dysfunction = orange, Cyanosis = red;
* **Floors climbed** count: Icon will be displayed in Grey until floors climbed goal has been met, changing to the Accent color of choice;
* **Precipitation** percentage: The current chance of rain/snow precipitation (0-100%), with blue tones color palette based on 4 zones: Low = light blue, Moderate = blue, High = dark blue, Very High = purple;
* **Humidity** percentage: The current relative humidity (0-100%), with color palette based on 3 levels: Healthy = green, Fair = yellow, Poor = red;
* **Solar intensity** percentage: Describes the solar sensor's charge efficiency, only available on Solar Charged watches. It will change colors based on 5 different UV intensity zones: Low = green, Moderate = yellow, High = orange, Very High = red, Extreme = violet.

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

**0.7.0** (13/Mar/21)
- [X] Add alarm icon beside the bluetooth logo when at least one is active. If no alarm has been set, then icon will be hidden
- [X] Added a second sensor for pulse Ox, in case the previous one is null
- [X] Create functions for each data point (big internal code change that will support data point customizations on next release)
- [X] Memory optimizations, reduced average and peak usage by 14%

**1.0.1** (27/Mar/21)
- [X] Revamped settings menu, split between "Design" and "Data Points"
- [X] "Data Points" menu that allows the user to select which data to be displayed in each of the 4 available locations (right bottom and left top, middle and bottom). Available data points (may vary depending on whatch model): Distance, Elevation, Wind Speed, Humidity, Precipitation, Calories, Floors Climbed, Pulse Ox, Heart Rate, Notification and Solar Intensity.
- [X] Added toggle on the "Design" menu to make the hour and minute hans thicker by 30% or return to standard thickness.

**1.1.0** (31/Mar/21)
- [X] Several optimizations that ended up removing 100 lines of code and reducing memory usage by 2%.

**1.2.0** (31/Mar/21)
- [X] Added a toggle on the "data points" menu to choose the activity length type between Steps or Distance.
- [X] Settigs menu bug fixes.

**1.3.0** (4/Apr/21)
- [X] Added color zones for Precipitation percentage (Low, Moderate, High and Very High) and Humidity percentage (Poor, Fair and Healthy).

## Watchface examples: (Not real photos, just taken from Garmin's Watch Simulator)

![Design Menu](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Img4.png?raw=true)
![Data Points Menu](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Img5.png?raw=true)
![Watch Examples](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Img1.png?raw=true)
![Watch Examples](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Img2.png?raw=true)
![Watch Examples](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Img3.png?raw=true)

# Inspiration:
* https://github.com/wwarby/walker
* https://github.com/pshriwise/connectiqanalog
* https://github.com/Laverlin/Yet-Another-WatchFace
* https://github.com/warmsound/crystal-face
* https://github.com/darrencroton/SnapshotWatch
* https://github.com/OliverHannover/Formula_1
* https://github.com/tumb1er/ElPrimero
* https://github.com/douglasr/connectiq-logo-analog
