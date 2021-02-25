# MoveToBeActive Garmin Watch Face
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Logo2-MoveToBeActive.png?raw=true)

Garmin Watch Face that was initially meant for the VivoActive 4 series, as I want to replace my current Vivomove HR soon. Even though I'm now going to move (no pun intended) to a more smartwatch kind of device instead of a hybrid, I do prefer the regular/classic look of an analog watch. So that's when I decided to start developing a watch face inspired by the design of the Vivomove series, but adding extra features that will be very useful for my daily type of usage (more health related than activity tracking).

I have tested/adapted this watch face to work with a few other rounded devices, including the new flagship Enduro (see picture below). I will be testing other watches soon an adding support on new releases.

![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Vivomove.jpg?raw=true)![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Arrow.png?raw=true)![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Home.png?raw=true)

## Feature listing:
* Analog hands for Hour and Minutes, but not for Seconds to mimic Vivomove HR (and save battery);
* Garmin Logo;
* Current Date;
* Battery percentage with symbol changing colors depending on battery left: Red (less than 15%), Yellow (between 16 and 30%) and Green (greater than 30%);
* Heart Rate data, showing current value and a symbol that is presented with colors from 7 different rate zones automatically calculated by Garmin based on your gender, current health and age range;
* Notifications count;
* Floors climbed count;
* Distance travelled on the day (km or miles, dependent on watch's selected unit on general config);
* Temperature indicator (if available) in Celsius or Fahrenheit (also dependent on watch's selected units display);
* City name (if available) and current weather condition;
* Bluetooth indicator: Blue (connected to the phone) or Grey (not connected);
* Do not Disturb indicator (only shown if mode is active);
* Blood oxygen percentage, that when activated will temporarily replace the floor climb count. As soon as it deactivates, the floor climb count will show up again (coming soon).

## Release notes:
* 0.1.0 (22/Feb/21)
- [x] Initial public release
* 0.2.0 (23/Feb/21)
- [X] Added temperature, weather condition and city name, as well as anti-alias for hour and minute hands
* 0.3.0 (24/Feb/21)
- [X] Correct bug with battery % on Venu and D2 Air devices (font size issue due to bigger resolution)
* 0.3.5 (Coming soon)
- [ ] Improve alignment of battery % text on different watch sizes and resolutions
* 0.4.0
- [ ] Add the blood oxygen percentage (on supported watches only) when that is activated (usually during the night), temporarily replacing the floor climb count. When pulse ox is disabled, the floor count will show up again. Useful for people that are using pulse ox 24/7 or for those who wake up during the night (mainly those with sleep apnea) and want to check their current blood oxygen percentage.
* 0.5.0
- [ ] Start adding features to the settings page, like giving the ability for the user to chose between different hand colors

## Support this project:
https://paypal.me/pools/c/8x2wuxFwFu


## Watchface examples: (Not real photos, these were taken from the Garmin Watch Simulator)

### Vivoactive 4
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/MoveToBeActive.png?raw=true)

### Enduro
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Enduro.png?raw=true)

### Fenix 6
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Fenix.png?raw=true)

### Fenix 6X Pro
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Fenix6xPro.png?raw=true)

### Fenix 6S Pro
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Fenix6Spro.png?raw=true)

### Forerunner 245
![alt text](https://github.com/fevieira27/MoveToBeActive/blob/main/GitHub/Forerunner245.png?raw=true)


# Inspiration:
* https://github.com/wwarby/walker
* https://github.com/pshriwise/connectiqanalog
* https://github.com/Laverlin/Yet-Another-WatchFace
* https://github.com/warmsound/crystal-face
* https://github.com/darrencroton/SnapshotWatch
* https://github.com/OliverHannover/Formula_1
* https://github.com/tumb1er/ElPrimero
