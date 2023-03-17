# MoveToBeActive Watch Faces for Garmin
![MoveToBeActive Banner](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/banner%20v3.png?raw=true)

Garmin Watch Face that was inspired by the design of the Vivomove series, adding extra features that will be very useful for my daily type of usage (more health related than activity tracking) and focusing on maximizing battery life.

<img src="https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Vivomove.jpg?raw=true" height="270"> <img src="https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Arrow.png?raw=true" height="270">
<img src="https://raw.githubusercontent.com/fevieira27/MoveToBeActive/main/GitHub/Home-MtbA%20v6.png" height="270">
<!--
[<img src="https://raw.githubusercontent.com/wwarby/walker/master/supporting-files/available-connect-iq-badge.svg" width="350" href="https://apps.garmin.com/en-US/developer/f959cfb4-acb7-4db5-8dfd-92749316d762/apps">](https://apps.garmin.com/en-US/developer/f959cfb4-acb7-4db5-8dfd-92749316d762/apps)
-->

## Feature listing:
* Analog hands for Hour and Minutes, but not for Seconds to mimic Vivomove HR (and save battery). Design menu has a toggle for thinner, standard or thicker hands (around 20-30% difference between each);
* **Current Date** with day of the week and Month;
* **Garmin Logo** that can be hidden on the watch face's config menu;
* **Battery indicator** with symbol changing colors depending on battery left: Red (less than or equal to 20%), Yellow (between 21 and 40%) and Green (greater than 40%). The text can be displayed as remaining % or estimated number of days until running out;
* **Bluetooth** indicator: Blue (connected to the phone) or grey (not connected);
* **Alarm** indicator: Accent color (at least one alarm active) or grey (no alarms);
* **Do not Disturb** indicator (only shown when mode is activate, also activated during sleep hours);
* **Location name** of the source of weather data (if available), that can be hidden on the watch face's config menu;
* **Current weather** condition icon;
* **Temperature** indicator (if available) in Celsius or Fahrenheit (also dependent on watch's selected units display). The temperature number will become blue when that is the minimum temperature for the day, as well as orange when that is the maximum;
* **Colored Tickmarks** following selected accent color. Can be turned on and off (showing gray tickmarks);
* **Colored AOD Mode**: gives the user the option of seeing the AOD mode hands and tickmarks in grayscale or full color (thanks [filmo003](https://github.com/filmo003) for the code);

## Available Data Fields:
* **Notifications** count: Accent color if at least one notification is available or grey if no unread notifications;
* **Heart Rate** data, showing last available value (not updated every second when not doing an activity, to save battery) and a symbol that is presented with colors from 7 different rate zones, set up by the user on the watch main settings (Settings - User Profile - Heart Rate - Zones - Based On). Color palette for each zone: Resting / Light Load = grey, Moderate Effort = blue, Weight Control = green, Aerobic = yellow, Anaerobic = orange, High effort = light red and Speed = bright red;
* **Calories** burned;
* **Steps**: Shows the number of steps on the current day and icon color will also change to the selected Accent when steps goal has been met;
* **Blood oxygen** percentage: will display the current pulse ox if the sensor is active all the time. However, if sensor is activated only while sleeping or on ad-hoc measurements, data point will show last available value. Color palette doesn't follow accent color and is based on 5 zones: Healthy = green, Normal = blue, Low = yellow, Brain Dysfunction = orange, Cyanosis = red;
* **Floors climbed** count: Icon will be displayed in grey until floors climbed goal has been met, changing to the Accent color of choice;
* **Precipitation** percentage: The current chance of rain/snow precipitation (0-100%), with blue tones color palette based on 4 zones: Low = light blue, Moderate = blue, High = dark blue, Very High = purple;
* **Humidity** percentage: The current relative humidity (0-100%), with color palette based on 3 levels: Healthy = green, Fair = yellow, Poor = red;
* **Atmospheric Pressure**: The current barometer read in hPa/millibars or calibrated mean at sea-level, with color palette based on 3 levels: High-pressure = blue, Normal = Gray, Low-pressure = orange;
* **Solar intensity** percentage: Describes the solar sensor's charge efficiency, only available on Solar Charged watches. It will change colors based on 5 different UV intensity zones: Low = green, Moderate = yellow, High = orange, Very High = red, Extreme = violet;
* **Intensity Minutes** per week: The current number of intensity minutes (moderate + 2x vigorous) during the current week. Symbol will turn from grey to the accent color as soon as the weekly intensity minutes goal is reached;
* **Seconds**: Available as a data field, will display seconds count of the current time;
* **VO2 Max** from Running or Cycling (available and 2 separate data fields);
* **Body Battery**;
* **Stress** Level;
* **Respiration** Rate;
* **Recovery Time** in hours;
* **Min/Max Temperature** forecasted for the day (*only available on the left top and middle data points*);
* **Wind speed**: Current wind speed in km/h or mph (depending on watch's pace unit settings), or m/s if selected on the watch face's settings (*only available on the left top and middle data points*);
* **Elevation** (altitude above mean sea level in meters): Derived from the most accurate source (Barometer or GPS) in order of descending accuracy. If no GPS is present, then barometer readings will be used (*only available on the left top and middle data points*);
* **Distance** walked/ran on the day (km or miles, dependent on watch's selected unit on general config): Icon will be displayed in grey until steps goal has been met, changing to the Accent color of choice (*only available on the left top and middle data points*);

## Support this project:
[<img src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" href="https://www.paypal.com/donate/?hosted_button_id=XVZXEH5RVBCZ6">](https://www.paypal.com/donate/?hosted_button_id=XVZXEH5RVBCZ6)

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

**1.4.0** (13/Apr/21)
- [X] Added condition to remove City or Country name when Garmin is incorrectly reporting any of those as "null".

**1.5.0** (15/Apr/21)
- [X] Added new toggle inside the data points menu to show Wind Speed in m/s.

**1.5.5** (20/Apr/21)
- [X] Improved quality of Garmin Logo.

**2.0.0** (25/May/21)
- [X] Improved design of hour and minute hands.
- [X] Always-On-Display low-power mode for AMOLED screens (Venu and D2 Air).
- [X] Replaced Wind Speed icon by wind direction (N, NE, E, SE, S, SW, W, NW).
- [X] Added smaller data field icons for smaller resolutions, as well as bigger icons for AMOLED screens.

**2.1.0** (26/May/21)
- [X] Corrected bug on the color of hour hand and on the always celsius temperature unit option.

**2.2.0** (25/Oct/21)
- [X] Testing a new design of the AOD mode on AMOLED displays to further reduce battery consumption.
- [X] Change the hour numbers and hask marks to a lighter grey (or maybe white?) for better readability on MIP displays only.
- [X] Keep the 6 and 12 hour hash marks in a lighter tone when in AOD mode (AMOLED) for better readability (since all tickmarks have the same size).
- [X] Added an option for thinner hands.

**3.0.0** (30/Dec/21)
- [X] Added an extra data field by moving alarm and bluetooth icons to another position on the watch face (now next to DnD icon).
- [X] Steps and Distance are now 2 distinct data fields with their own icons, so both can now be added together on the watch face.
- [X] Added Weekly Intensity Minutes and Seconds as new data fields available in any of the 5 locations.
- [X] Improvements on the positioning of all icons and data fields, which reduced memory usage, code length and will make future adjustments easier.
- [X] Removed a bug that would show "null" when the temperature was not being returned by Garmin Weather API.
- [X] Removed useless initial settings screen that was based on Garmin's Analog Sample code. Now it will go directly to MtbA settings and then back to watch face.
- [X] Corrected issue where AMOLED watches would not see the data field icon on the settings menu.
- [X] Adjusted colors of the Wind Speed icon to better reflect the Beaufort Scale.
- [X] Reverted AOD to something similar to the previous version, as no battery improvements were perceived when using extremely low brightness.
- [X] Added support for Venu Mercedes-Benz Edition and Descent MK2

**3.0.1** (31/Dec/21)
- [X] Corrected bug with the conversion of temperature to Fahrenheit.

**3.0.2** (3/Jan/22)
- [X] Corrected bug that allowed the Alarm icon to be displayed even when it was disabled on the watch face settings.
- [X] Minor improvements that reduced memory usage by removing unnecessary code and rewriting some calculations.

**3.0.3** (4/Jan/22)
- [X] Added support to the newly launched watch Venu 2 Plus.

**3.0.4** (5/Jan/22)
- [X] Fixed issue on button-based (non-touch) watches which caused a crash on the settings menu when the user reached end of list on a submenu (either layout or data).

**3.0.5** (19/Jan/22)
- [X] Added support for Venu Sq, Venu Sq Music Edition, Fenix 7, Fenix 7S, Fenix 7X, Epix 2.
- [X] Corrected bug that would crash the watch face when the elevation data field was selected, but watch doesn't have a barometer sensor and no GPS data is available.

**3.0.6** (21/Jan/22)
- [X] Updated to SDK 4.0.8 with Garmin bug fixes.
- [X] Improved code to prevent the unlikely chance of no weather information being provided to the watch would cause an error.
- [X] Fixed bug that was not showing the weather location on Venu Sq watches.

**3.0.7** (30/Jan/22)
- [X] Added support for Fenix 5 Plus, Fenix 5S Plus and Fenix 5X Plus (don't support weather, location and temperature);
- [X] Updated to SDK 4.0.9 with Garmin bug fixes.

**3.0.8** (31/Jan/22)
- [X] Fixed bug with battery icon in some watch models.

**3.0.9** (2/Feb/22)
- [X] Added support for ForeRunner 645 Music.

**3.1.0** (8/Feb/22)
- [X] Added support for new D2 Air X10 watch
- [X] Added new option in Layout settings for each 5 min tickmarks to follow the selected accent color.
- [X] Changed notification icon to grey when there are no notifications pending.
- [X] Fixed unlikely case of location name wrapping to a second row on Fenix 6 series watches. Now using truncate when name is too big.
- [X] Fixed battery icon that was too big on Venu Sq watches.
- [X] Fixed the Intensity Minutes icon not showing up on Venu 2, 2 Plus and Epix Gen 2

**4.0.0** (17/Apr/22)
- [X] Added support for new D2 Mach 1 watch.
- [X] Updated to SDK 4.1.2 with Garmin bug fixes.
- [X] Add 5 new data fields applicable for System 5 Garmin update (VO2 Max, Body Battery, Stress, Respiration Rate, Recovery Time).
- [X] Added Atmospheric pressure and Min/Max Temperature data fields. The former requires the watch to have a barometer, while the latter needs to support the weather API (not available on Fenix 5 Series and ForeRunner 645 Music).
- [X] It is now possible to select a bigger font size for the data fields (not supported by Venu Sq).
- [X] Added option to display the remaning battery in estimated number of days (if watch supports it).
- [X] Added option to show the hands and tickmarks on AOD mode following the same colors of when the AOD mode is OFF (AMOLED and LCD displays only).
- [X] The on-watch config menu was revamped, now split into 3 categories (instead of 2): Layout, Data Fields and Base Units.
- [X] Temperature will now become blue in case that is the minimum temperature forecasted for the day, or orange if that is the maximum. All other temperatures will still be displayed in white (as before).

**4.0.1** (1/May/22)
- [X] Added option on the "Base Units" menu to change date format
- [X] Changed the source of atmospheric pressure data, now using the raw data from the barometer instead of a smoothed value (slower to show changes)
- [X] Changed code of the "battery in days" option, trying to fix the zero days bug
- [X] Added one decimal case in the distance data field, even after the user has gone above 10 km/mi in a day
- [X] Code change that will allow better compatibility of new features on future updates (avoiding need to reinstall issue that happened on 4.0.0)

**4.0.2** (12/May/22)
- [X] Corrected battery estimation unit
- [X] Added extra checks to prevent data type errors when the weather station is reporting unexpected data (happening in a few cities every once in a while)
- [X] Updated to SDK 4.1.3 with Garmin bug fixes.

**4.1.0** (27/Oct/22)
- [X] Add option to remove battery, date and weather info.

**4.2.0** (17/Mar/23)
- [X] New data field added: Next Sun Event (12 or 24h format)
- [X] Add color categories to body battery icon, depending on value
- [X] Code improvements to reduce memory usage of the config/customization menu and watch face
- [X] Adapting code to SDK 4.2.2
- [X] Added support for newly released Forerunners: 265, 265s and 965

**4.2.1** (Coming Soon)
- [ ] Add option to show the battery icon in grayscale or following the accent color (instead of green/yellow/red)
- [ ] Convert Atmospheric Pressure to Inches of Mercury when user is not using metric-based units.
- [ ] Give the user the possibility to chose the wind speed to be displayed in knots


## Watchface examples:

![Features Location](https://raw.githubusercontent.com/fevieira27/MoveToBeActive/main/GitHub/CIQ%20Img%203%20v2.jpg)
![Config Menu](https://raw.githubusercontent.com/fevieira27/MoveToBeActive/main/GitHub/CIQ%20Img%202%20v3.jpg)
![Features](https://raw.githubusercontent.com/fevieira27/MoveToBeActive/main/GitHub/CIQ%20Img%201%20v2.jpg)
![Watch Examples](https://raw.githubusercontent.com/fevieira27/MoveToBeActive/main/GitHub/CIQ%20Img%204%20v2.jpg)

# Inspiration:
* https://github.com/wwarby/walker
* https://github.com/pshriwise/connectiqanalog
* https://github.com/Laverlin/Yet-Another-WatchFace
* https://github.com/warmsound/crystal-face
* https://github.com/darrencroton/SnapshotWatch
* https://github.com/OliverHannover/Formula_1
* https://github.com/tumb1er/ElPrimero
* https://github.com/douglasr/connectiq-logo-analog
* https://github.com/douglasr/connectiq-samples
