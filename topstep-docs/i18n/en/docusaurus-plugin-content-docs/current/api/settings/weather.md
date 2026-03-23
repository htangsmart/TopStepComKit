---
sidebar_position: 6
title: Weather
---

# TSWeather Module

The TSWeather module provides comprehensive weather information management for TopStepComKit devices. It enables you to fetch current weather conditions, manage weather data synchronization, and control weather display settings. The module supports detailed weather parameters including temperature, wind conditions, humidity, UV index, and multi-day/hourly forecasts.

## Prerequisites

- TopStepComKit framework version 1.0 or later
- Connected and authenticated device via TSDeviceManager
- Weather interface implementation conforming to `TSWeatherInterface` protocol
- For weather data push operations: device must be in connected state

## Data Models

### TopStepWeather

Complete weather information model for a location.

| Property | Type | Description |
|----------|------|-------------|
| `timestamp` | `NSTimeInterval` | Unix timestamp when weather information was recorded |
| `updateTimestamp` | `NSTimeInterval` | Unix timestamp when weather information was last updated |
| `sunriseTime` | `NSTimeInterval` | Unix timestamp representing sunrise time (0 if unavailable) |
| `sunsetTime` | `NSTimeInterval` | Unix timestamp representing sunset time (0 if unavailable) |
| `city` | `TSWeatherCity *` | City information for the weather report |
| `dayCode` | `TSWeatherCodeModel *` | Daytime weather code and description |
| `nightCode` | `TSWeatherCodeModel *` | Nighttime weather code and description (optional) |
| `minTemperature` | `SInt8` | Minimum temperature in Celsius |
| `maxTemperature` | `SInt8` | Maximum temperature in Celsius |
| `curTemperature` | `SInt8` | Current temperature in Celsius |
| `airpressure` | `NSInteger` | Atmospheric pressure in hPa |
| `quality` | `NSInteger` | Air quality index (0: Excellent, 1: Good, 2: Light, 3: Moderate, 4: Heavy, 5: Severe) |
| `humidity` | `NSInteger` | Relative humidity percentage (0-100) |
| `uvIndex` | `NSInteger` | UV radiation intensity (0: None, 1-2: Very Low, 3-4: Low, 5-6: Moderate, 7-8: High, 9-10: Very High, 11: Extreme) |
| `windAngle` | `CGFloat` | Wind direction in degrees (0-359) |
| `windScale` | `NSInteger` | Wind scale level (0-18) |
| `windSpeed` | `CGFloat` | Wind speed in m/s |
| `visibility` | `CGFloat` | Visibility in meters |
| `futhureSevenDays` | `NSArray<TSWeatherDay *> *` | Seven-day forecast array ordered by date |
| `futhure24Hours` | `NSArray<TSWeatherHour *> *` | 24-hour forecast array ordered by time |

### TSWeatherCity

City model for weather information.

| Property | Type | Description |
|----------|------|-------------|
| `cityName` | `NSString *` | City name (required) |
| `cityCode` | `NSString *` | City unique identifier code (optional) |
| `latitude` | `double` | City center latitude in decimal degrees (-90.0 to 90.0) |
| `longitude` | `double` | City center longitude in decimal degrees (-180.0 to 180.0) |
| `provinceName` | `NSString *` | Province/state name (optional) |
| `countryName` | `NSString *` | Country name (optional) |

### TSWeatherDay

Daily weather information model.

| Property | Type | Description |
|----------|------|-------------|
| `timestamp` | `NSTimeInterval` | Unix timestamp of weather information |
| `dayCode` | `TSWeatherCodeModel *` | Daytime weather code |
| `nightCode` | `TSWeatherCodeModel *` | Nighttime weather code (optional) |
| `curTemperature` | `SInt8` | Current temperature in Celsius |
| `minTemperature` | `SInt8` | Minimum temperature in Celsius |
| `maxTemperature` | `SInt8` | Maximum temperature in Celsius |
| `airpressure` | `NSInteger` | Atmospheric pressure in hPa |
| `windScale` | `UInt8` | Wind scale level (0-18) |
| `windAngle` | `NSInteger` | Wind direction in degrees (0-359) |
| `windSpeed` | `UInt8` | Wind speed in m/s |
| `humidity` | `UInt8` | Relative humidity percentage (0-100) |
| `uvIndex` | `UInt8` | UV radiation intensity index |
| `visibility` | `CGFloat` | Visibility in meters |

### TSWeatherHour

Hourly weather information model.

| Property | Type | Description |
|----------|------|-------------|
| `timestamp` | `NSTimeInterval` | Unix timestamp of weather information |
| `weatherCode` | `TSWeatherCodeModel *` | Weather code for the hour |
| `temperature` | `SInt8` | Temperature in Celsius |
| `windScale` | `NSInteger` | Wind scale level (0-18) |
| `uvIndex` | `NSInteger` | UV radiation intensity index |
| `visibility` | `NSInteger` | Visibility in meters |
| `humidity` | `NSInteger` | Relative humidity percentage (0-100) |

### TSWeatherCodeModel

Weather code model representing weather conditions.

| Property | Type | Description |
|----------|------|-------------|
| `code` | `TSWeatherCode` | Weather code enumeration value |
| `name` | `NSString *` | Text description of weather condition |

## Enumerations

### TSWeatherCode

Weather condition codes based on Yahoo Weather standards.

| Code | Value | Description |
|------|-------|-------------|
| `TSWeatherCodeUnknown` | -1 | Unknown weather |
| `TSWeatherCodeTornado` | 0 | Tornado |
| `TSWeatherCodeTropicalStorm` | 1 | Tropical Storm |
| `TSWeatherCodeHurricane` | 2 | Hurricane |
| `TSWeatherCodeStrongStorms` | 3 | Strong Storms |
| `TSWeatherCodeThunderstorms` | 4 | Thunderstorms |
| `TSWeatherCodeRainSnow` | 5 | Rain and Snow |
| `TSWeatherCodeRainSleet` | 6 | Rain and Sleet |
| `TSWeatherCodeWintryMix` | 7 | Wintry Mix |
| `TSWeatherCodeFreezingDrizzle` | 8 | Freezing Drizzle |
| `TSWeatherCodeDrizzle` | 9 | Drizzle |
| `TSWeatherCodeFreezingRain` | 10 | Freezing Rain |
| `TSWeatherCodeShowers` | 11 | Showers |
| `TSWeatherCodeRain` | 12 | Rain |
| `TSWeatherCodeFlurries` | 13 | Flurries |
| `TSWeatherCodeSnowShowers` | 14 | Snow Showers |
| `TSWeatherCodeBlowingSnow` | 15 | Blowing/Drifting Snow |
| `TSWeatherCodeSnow` | 16 | Snow |
| `TSWeatherCodeHail` | 17 | Hail |
| `TSWeatherCodeSleet` | 18 | Sleet |
| `TSWeatherCodeDustSandstorm` | 19 | Blowing Dust/Sandstorm |
| `TSWeatherCodeFoggy` | 20 | Foggy |
| `TSWeatherCodeHaze` | 21 | Haze |
| `TSWeatherCodeSmoke` | 22 | Smoke |
| `TSWeatherCodeBreezy` | 23 | Breezy |
| `TSWeatherCodeWindy` | 24 | Windy |
| `TSWeatherCodeFrigidIceCrystals` | 25 | Frigid/Ice Crystals |
| `TSWeatherCodeOvercast` | 26 | Overcast |
| `TSWeatherCodeMostlyCloudyNight` | 27 | Mostly Cloudy (night) |
| `TSWeatherCodeMostlyCloudyDay` | 28 | Mostly Cloudy (day) |
| `TSWeatherCodePartlyCloudyNight` | 29 | Partly Cloudy (night) |
| `TSWeatherCodePartlyCloudyDay` | 30 | Partly Cloudy (day) |
| `TSWeatherCodeClearNight` | 31 | Clear Night |
| `TSWeatherCodeSunnyDay` | 32 | Sunny Day |
| `TSWeatherCodeFairNight` | 33 | Fair/Mostly Clear (night) |
| `TSWeatherCodeFairDay` | 34 | Fair/Mostly Sunny (day) |
| `TSWeatherCodeMixedRainHail` | 35 | Mixed Rain and Hail |
| `TSWeatherCodeHot` | 36 | Hot |
| `TSWeatherCodeIsolatedThunderstorms` | 37 | Isolated Thunderstorms |
| `TSWeatherCodeScatteredStormDay` | 38 | Scattered Thunderstorms (day) |
| `TSWeatherCodeScatteredShowersDay` | 39 | Scattered Showers (day) |
| `TSWeatherCodeHeavyRain` | 40 | Heavy Rain |
| `TSWeatherCodeScatteredSnowDay` | 41 | Scattered Snow Showers (day) |
| `TSWeatherCodeHeavySnow` | 42 | Heavy Snow |
| `TSWeatherCodeBlizzard` | 43 | Blizzard |
| `TSWeatherCodeNotAvailable` | 44 | Not Available |
| `TSWeatherCodeScatteredShowersNight` | 45 | Scattered Showers (night) |
| `TSWeatherCodeScatteredSnowNight` | 46 | Scattered Snow Showers (night) |
| `TSWeatherCodeScatteredStormNight` | 47 | Scattered Thunderstorms (night) |

## Callback Types

### TSCompletionBlock

```objc
typedef void (^TSCompletionBlock)(BOOL success, NSError *_Nullable error);
```

Completion callback for set operations.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Operation success status |
| `error` | `NSError *` | Error object (nil if successful) |

## API Reference

### Fetch current weather information

Retrieves the current weather information from the device, including current conditions, daily forecast, and hourly forecast.

```objc
- (void)fetchWeatherWithCompletion:(void (^)(TopStepWeather *_Nullable weather, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TopStepWeather *, NSError *)` | Callback block with weather data or error |

**Code Example:**

```objc
id<TSWeatherInterface> weatherInterface = [TSWeatherInterface sharedInstance];

[weatherInterface fetchWeatherWithCompletion:^(TopStepWeather *weather, NSError *error) {
    if (error) {
        TSLog(@"Failed to fetch weather: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Current temperature: %d°C", weather.curTemperature);
    TSLog(@"City: %@", weather.city.cityName);
    TSLog(@"Weather condition: %@", weather.dayCode.name);
    TSLog(@"Min/Max: %d/%d°C", weather.minTemperature, weather.maxTemperature);
    TSLog(@"Humidity: %ld%%", (long)weather.humidity);
    TSLog(@"Wind speed: %.1f m/s", weather.windSpeed);
    TSLog(@"7-day forecast available: %lu days", (unsigned long)weather.futhureSevenDays.count);
    TSLog(@"24-hour forecast available: %lu hours", (unsigned long)weather.futhure24Hours.count);
}];
```

### Push weather information to device

Synchronizes weather information to the device for display.

```objc
- (void)pushWeather:(TopStepWeather *)weather completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `weather` | `TopStepWeather *` | Weather information model to synchronize |
| `completion` | `TSCompletionBlock` | Callback indicating success or failure |

**Code Example:**

```objc
// Create weather information
TopStepWeather *weather = [[TopStepWeather alloc] init];
weather.timestamp = [[NSDate date] timeIntervalSince1970];
weather.updateTimestamp = weather.timestamp;
weather.curTemperature = 22;
weather.minTemperature = 15;
weather.maxTemperature = 28;
weather.humidity = 65;
weather.uvIndex = 3;
weather.windScale = 3;
weather.windSpeed = 2.5;
weather.airpressure = 1013;
weather.quality = 1;
weather.visibility = 10000;

// Create city information
TSWeatherCity *city = [TSWeatherCity cityWithName:@"Beijing"];
city.latitude = 39.9042;
city.longitude = 116.4074;
city.cityCode = @"101010100";
weather.city = city;

// Create weather code
TSWeatherCodeModel *dayCode = [TSWeatherCodeModel weatherCodeWithCode:TSWeatherCodePartlyCloudyDay];
weather.dayCode = dayCode;

// Push to device
id<TSWeatherInterface> weatherInterface = [TSWeatherInterface sharedInstance];
[weatherInterface pushWeather:weather completion:^(BOOL success, NSError *error) {
    if (error) {
        TSLog(@"Failed to push weather: %@", error.localizedDescription);
        return;
    }
    
    if (success) {
        TSLog(@"Weather synchronized successfully");
    }
}];
```

### Enable or disable weather display

Controls whether the device displays weather information.

```objc
- (void)setWeatherEnable:(BOOL)enable completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `enable` | `BOOL` | YES to enable weather display, NO to disable |
| `completion` | `TSCompletionBlock` | Callback indicating success or failure |

**Code Example:**

```objc
id<TSWeatherInterface> weatherInterface = [TSWeatherInterface sharedInstance];

// Enable weather display
[weatherInterface setWeatherEnable:YES completion:^(BOOL success, NSError *error) {
    if (error) {
        TSLog(@"Failed to enable weather: %@", error.localizedDescription);
        return;
    }
    
    if (success) {
        TSLog(@"Weather display enabled");
    }
}];

// Disable weather display
[weatherInterface setWeatherEnable:NO completion:^(BOOL success, NSError *error) {
    if (error) {
        TSLog(@"Failed to disable weather: %@", error.localizedDescription);
        return;
    }
    
    if (success) {
        TSLog(@"Weather display disabled");
    }
}];
```

### Fetch weather display status

Retrieves the current weather display enable/disable status from the device.

```objc
- (void)fetchWeatherEnableWithCompletion:(void (^)(BOOL enabled, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(BOOL, NSError *)` | Callback with enable status and error |

**Code Example:**

```objc
id<TSWeatherInterface> weatherInterface = [TSWeatherInterface sharedInstance];

[weatherInterface fetchWeatherEnableWithCompletion:^(BOOL enabled, NSError *error) {
    if (error) {
        TSLog(@"Failed to fetch weather status: %@", error.localizedDescription);
        return;
    }
    
    if (enabled) {
        TSLog(@"Weather display is enabled");
    } else {
        TSLog(@"Weather display is disabled");
    }
}];
```

### Create city model with name

Creates a city model with the required city name.

```objc
+ (instancetype)cityWithName:(NSString *)cityName;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `cityName` | `NSString *` | The city name (required) |

**Code Example:**

```objc
TSWeatherCity *city = [TSWeatherCity cityWithName:@"Shanghai"];
TSLog(@"Created city: %@", city.cityName);
```

### Create city model with location

Creates a city model with name and geographic coordinates.

```objc
+ (instancetype)cityWithName:(NSString *)cityName
                    latitude:(double)latitude
                   longitude:(double)longitude;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `cityName` | `NSString *` | The city name (required) |
| `latitude` | `double` | City center latitude (-90.0 to 90.0) |
| `longitude` | `double` | City center longitude (-180.0 to 180.0) |

**Code Example:**

```objc
TSWeatherCity *city = [TSWeatherCity cityWithName:@"New York" 
                                         latitude:40.7128 
                                        longitude:-74.0060];
TSLog(@"Created city: %@ at (%f, %f)", city.cityName, city.latitude, city.longitude);
```

### Create weather code model

Creates a weather code model with the specified code.

```objc
+ (instancetype)weatherCodeWithCode:(TSWeatherCode)code;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | `TSWeatherCode` | Weather code enumeration value |

**Code Example:**

```objc
TSWeatherCodeModel *code = [TSWeatherCodeModel weatherCodeWithCode:TSWeatherCodeSunnyDay];
TSLog(@"Weather code: %ld, Name: %@", (long)code.code, code.name);
```

### Get weather name for code

Gets the text description for a specific weather code.

```objc
+ (NSString *)weatherNameForCode:(TSWeatherCode)code;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | `TSWeatherCode` | Weather code enumeration value |

**Code Example:**

```objc
NSString *weatherName = [TSWeatherCodeModel weatherNameForCode:TSWeatherCodeRain];
TSLog(@"Weather description: %@", weatherName);
```

### Create daily weather model with basic information

Creates a daily weather model with essential weather parameters.

```objc
+ (instancetype)modelWithDayCode:(TSWeatherCodeModel *)dayCode
                        nightCode:(nullable TSWeatherCodeModel *)nightCode
                          curTemp:(SInt8)curTemp
                          minTemp:(SInt8)minTemp
                          maxTemp:(SInt8)maxTemp;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `dayCode` | `TSWeatherCodeModel *` | Daytime weather code |
| `nightCode` | `TSWeatherCodeModel *` | Nighttime weather code (optional) |
| `curTemp` | `SInt8` | Current temperature in Celsius |
| `minTemp` | `SInt8` | Minimum temperature in Celsius |
| `maxTemp` | `SInt8` | Maximum temperature in Celsius |

**Code Example:**

```objc
TSWeatherCodeModel *dayCode = [TSWeatherCodeModel weatherCodeWithCode:TSWeatherCodeSunnyDay];
TSWeatherCodeModel *nightCode = [TSWeatherCodeModel weatherCodeWithCode:TSWeatherCodeClearNight];

TSWeatherDay *day = [TSWeatherDay modelWithDayCode:dayCode 
                                          nightCode:nightCode 
                                            curTemp:22 
                                            minTemp:15 
                                            maxTemp:28];

TSLog(@"Daily weather: %@ / %@, Temp: %d°C", day.dayCode.name, day.nightCode.name, day.curTemperature);
```

### Create daily weather model with complete information

Creates a daily weather model with all weather parameters.

```objc
+ (instancetype)modelWithDayCode:(TSWeatherCodeModel *)dayCode
                        nightCode:(nullable TSWeatherCodeModel *)nightCode
                          curTemp:(SInt8)curTemp
                          minTemp:(SInt8)minTemp
                          maxTemp:(SInt8)maxTemp
                      airpressure:(NSInteger)airpressure
                        windScale:(NSInteger)windScale
                        windAngle:(NSInteger)windAngle
                        windSpeed:(NSInteger)windSpeed
                         humidity:(NSInteger)humidity
                          uvIndex:(NSInteger)uvIndex
                       visibility:(CGFloat)visibility;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `dayCode` | `TSWeatherCodeModel *` | Daytime weather code |
| `nightCode` | `TSWeatherCodeModel *` | Nighttime weather code (optional) |
| `curTemp` | `SInt8` | Current temperature in Celsius |
| `minTemp` | `SInt8` | Minimum temperature in Celsius |
| `maxTemp` | `SInt8` | Maximum temperature in Celsius |
| `airpressure` | `NSInteger` | Atmospheric pressure in hPa |
| `windScale` | `NSInteger` | Wind scale level (0-18) |
| `windAngle` | `NSInteger` | Wind direction in degrees |
| `windSpeed` | `NSInteger` | Wind speed in m/s |
| `humidity` | `NSInteger` | Relative humidity percentage |
| `uvIndex` | `NSInteger` | UV radiation intensity |
| `visibility` | `CGFloat` | Visibility in meters |

**Code Example:**

```objc
TSWeatherCodeModel *dayCode = [TSWeatherCodeModel weatherCodeWithCode:TSWeatherCodePartlyCloudyDay];
TSWeatherCodeModel *nightCode = [TSWeatherCodeModel weatherCodeWithCode:TSWeatherCodeClearNight];

TSWeatherDay *day = [TSWeatherDay modelWithDayCode:dayCode 
                                          nightCode:nightCode 
                                            curTemp:22 
                                            minTemp:15 
                                            maxTemp:28 
                                        airpressure:1013 
                                          windScale:3 
                                          windAngle:180 
                                          windSpeed:2 
                                           humidity:65 
                                            uvIndex:3 
                                         visibility:10000];

TSLog(@"Complete weather data: Pressure=%ld hPa, Wind=%d, Humidity=%ld%%", 
      (long)day.airpressure, day.windScale, (long)day.humidity);
```

### Create hourly weather model with basic information

Creates an hourly weather model with essential parameters.

```objc
+ (instancetype)modelWithDayCode:(TSWeatherCodeModel *)dayCode
                     temperature:(SInt8)temperature
                       windScale:(NSInteger)windScale;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `dayCode` | `TSWeatherCodeModel *` | Weather code for the hour |
| `temperature` | `SInt8` | Temperature in Celsius |
| `windScale` | `NSInteger` | Wind scale level (0-18) |

**Code Example:**

```objc
TSWeatherCodeModel *code = [TSWeatherCodeModel weatherCodeWithCode:TSWeatherCodeRain];

TSWeatherHour *hour = [TSWeatherHour modelWithDayCode:code 
                                          temperature:18 
                                            windScale:4];

TSLog(@"Hourly weather: %@, Temp: %d°C, Wind scale: %ld", 
      hour.weatherCode.name, hour.temperature, (long)hour.windScale);
```

### Create hourly weather model with complete information

Creates an hourly weather model with all weather parameters.

```objc
+ (instancetype)modelWithCode:(TSWeatherCodeModel *)code
                     temperature:(SInt8)temperature
                       windScale:(NSInteger)windScale
                         uvIndex:(NSInteger)uvIndex
                      visibility:(CGFloat)visibility
                        humidity:(NSInteger)humidity;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | `TSWeatherCodeModel *` | Weather code |
| `temperature` | `SInt8` | Temperature in Celsius |
| `windScale` | `NSInteger` | Wind scale level (0-18) |
| `uvIndex` | `NSInteger` | UV radiation intensity |
| `visibility` | `CGFloat` | Visibility in meters |
| `humidity` | `NSInteger` | Relative humidity percentage |

**Code Example:**

```objc
TSWeatherCodeModel *code = [TSWeatherCodeModel weatherCodeWithCode:TSWeatherCodePartlyCloudyDay];

TSWeatherHour *hour = [TSWeatherHour modelWithCode:code 
                                        temperature:20 
                                          windScale:2 
                                            uvIndex:4 
                                         visibility:8000 
                                           humidity:70];

TSLog(@"Hourly details: UV=%ld, Visibility=%dm, Humidity=%ld%%", 
      (long)hour.uvIndex, (int)hour.visibility, (long)hour.humidity);
```

## Important Notes

1. **Weather Synchronization**: The device must be connected and authenticated before pushing weather information using `pushWeather:completion:`. Connection status should be verified beforehand.

2. **Temperature Unit**: All temperature values in the weather models use Celsius (°C). Conversion to Fahrenheit or other units should be done on the client side if needed.

3. **Timestamp Format**: Timestamps should be in Unix format (seconds since January 1, 1970 UTC). Use `[[NSDate date] timeIntervalSince1970]` to generate current timestamp.

4. **Weather Codes**: Use the `TSWeatherCode` enumeration values when setting weather codes. The codes follow Yahoo Weather standards for consistency across platforms.

5. **Array Ordering**: The `futhureSevenDays` array is ordered by date with the first element representing today. Similarly, `futhure24Hours` is ordered by time with the first element being the current hour.

6. **Optional Properties**: The `nightCode` property in weather models is optional and may be `nil` if nighttime weather information is not available. Always check for `nil` before accessing this property.

7. **Enable/Disable Status**: Weather display status can be toggled using `setWeatherEnable:completion:` and verified using `fetchWeatherEnableWithCompletion:`. A disabled state will prevent the device from displaying any weather information.

8. **City Model Required**: The `city` property in `TopStepWeather` is required for weather display. At minimum, provide the city name using `[TSWeatherCity cityWithName:]`.

9. **Wind Direction**: Wind direction angle uses standard geographic convention: 0/360 = North, 90 = East, 180 = South, 270 = West. Values should be in the range 0-359 degrees.

10. **UV Index Range**: UV index values typically range from 0 (no exposure) to 11+ (extreme exposure). Device firmware may limit the range for safety, so validate values before pushing to device.