---
sidebar_position: 1
title: HealthBase
---

# TSHealthBase

The TSHealthBase module provides comprehensive health data management capabilities for TopStepComKit iOS SDK, including active health measurements (manual monitoring), automatic health monitoring configuration, and real-time data reception. It supports multiple measurement types such as heart rate, blood pressure, blood oxygen, stress, temperature, and ECG, with customizable parameters and automatic monitoring schedules.

## Prerequisites

- Device must be paired and connected via Bluetooth
- User must grant appropriate health data permissions
- Device must support the specific health measurement type being requested
- For automatic monitoring, device must maintain connection (or periodic sync for scheduled measurements)

## Data Models

### TSActivityMeasureParam

Active measurement parameters model for customizing health measurement sessions.

| Property | Type | Description |
|----------|------|-------------|
| `measureType` | `TSActiveMeasureType` | Type of health measurement to perform (e.g., heart rate, blood pressure). Only one type can be active at a time. |
| `interval` | `UInt8` | Sampling interval in seconds. Affects measurement frequency and data granularity. Valid range varies by measurement type. |
| `maxMeasureDuration` | `UInt8` | Maximum measurement duration in seconds. Measurement stops automatically after this duration. Default is 60 seconds. Set to 0 for continuous measurement until manual stop. Minimum valid value is 15 seconds. |

### TSAutoMonitorConfigs

Configuration model for automatic health monitoring with schedule and alert thresholds (used for blood oxygen, stress, temperature).

| Property | Type | Description |
|----------|------|-------------|
| `schedule` | `TSMonitorSchedule *` | Monitor schedule including enable switch, start/end time (minutes from midnight), and interval. |
| `alert` | `TSMonitorAlert *` | Threshold-based alert policy. Unit depends on monitor type (e.g., percent for SpO2, bpm for heart rate, mmHg for blood pressure). Nullable. |

### TSAutoMonitorHRConfigs

Configuration model for automatic heart rate monitoring with resting/exercise alerts and heart rate zones.

| Property | Type | Description |
|----------|------|-------------|
| `schedule` | `TSMonitorSchedule *` | Monitor schedule including enable switch, start/end time (minutes from midnight), and interval. |
| `restHRAlert` | `TSMonitorAlert *` | Threshold-based alert policy for resting heart rate monitoring. Units: bpm (beats per minute). Nullable. |
| `exerciseHRAlert` | `TSMonitorAlert *` | Threshold-based alert policy for exercise heart rate monitoring. Units: bpm (beats per minute). Nullable. |
| `exerciseHRLimitMax` | `UInt8` | Maximum exercise heart rate used to calculate heart rate zones (warm-up, fat burning, aerobic, anaerobic, peak). Recommended range 100-220 bpm. Typically calculated as 220 - age. |

### TSAutoMonitorBPConfigs

Configuration model for automatic blood pressure monitoring with systolic and diastolic thresholds.

| Property | Type | Description |
|----------|------|-------------|
| `schedule` | `TSMonitorSchedule *` | Monitor schedule including enable switch, start/end time (minutes from midnight), and interval. |
| `alert` | `TSMonitorBPAlert *` | Blood pressure threshold-based alert policy with separate systolic and diastolic limits. Units: mmHg (millimeters of mercury). Nullable. |

### TSMonitorSchedule

Schedule configuration for automatic monitoring operations.

| Property | Type | Description |
|----------|------|-------------|
| `enabled` | `BOOL` | Indicates whether the monitoring is enabled. |
| `startTime` | `UInt16` | Start time in minutes from midnight (e.g., 480 for 8 AM). Valid range is 0-1440 minutes (0:00-24:00). |
| `endTime` | `UInt16` | End time in minutes from midnight (e.g., 1200 for 8 PM). Valid range is 0-1440 minutes (0:00-24:00). Must be greater than `startTime`. |
| `interval` | `UInt16` | Interval between monitoring in minutes. Must be a multiple of 5 (5, 10, 15, 20, etc.). |

### TSMonitorAlert

Alert threshold configuration for generic monitoring types (blood oxygen, stress, temperature).

| Property | Type | Description |
|----------|------|-------------|
| `enabled` | `BOOL` | Indicates whether alert checking is enabled for the monitor. |
| `upperLimit` | `UInt16` | Upper threshold for alert decision. Unit depends on monitor type (percent for SpO2, bpm for heart rate, mmHg for blood pressure). |
| `lowerLimit` | `UInt16` | Lower threshold for alert decision. Unit depends on monitor type (percent for SpO2, bpm for heart rate, mmHg for blood pressure). |

### TSMonitorBPAlert

Alert threshold configuration specifically for blood pressure monitoring with separate systolic and diastolic limits.

| Property | Type | Description |
|----------|------|-------------|
| `enabled` | `BOOL` | Indicates whether blood pressure alert checking is enabled. |
| `systolicUpperLimit` | `UInt8` | Upper threshold for systolic blood pressure alert in mmHg. |
| `systolicLowerLimit` | `UInt8` | Lower threshold for systolic blood pressure alert in mmHg. |
| `diastolicUpperLimit` | `UInt8` | Upper threshold for diastolic blood pressure alert in mmHg. |
| `diastolicLowerLimit` | `UInt8` | Lower threshold for diastolic blood pressure alert in mmHg. |

### TSHealthValueItem

Health value data item representing a measurement result with timing information and value type classification.

| Property | Type | Description |
|----------|------|-------------|
| `startTime` | `NSTimeInterval` | Unix timestamp (in seconds) indicating when this data record started. Used for tracking the beginning of various activities. |
| `endTime` | `NSTimeInterval` | Unix timestamp (in seconds) indicating when this data record ended. Used with `startTime` to calculate duration and analyze activity patterns. |
| `duration` | `double` | Total duration of this data record in seconds. Can be calculated as (endTime - startTime) or directly provided by the device. |
| `valueType` | `TSItemValueType` | Classifies the sample as Normal raw point, Daily maximum/minimum, or Resting HR. Whether auto or manual is indicated by `isUserInitiated`, which is orthogonal to this enum. |

### TSHealthDailyModel

Health data model for daily or aggregated health records.

| Property | Type | Description |
|----------|------|-------------|
| `startTime` | `NSTimeInterval` | Unix timestamp (in seconds) indicating when this data record started. Used for tracking the beginning of various activities like sleep, exercise, or health measurements. |
| `endTime` | `NSTimeInterval` | Unix timestamp (in seconds) indicating when this data record ended. Used with `startTime` to calculate duration and analyze activity patterns. |
| `duration` | `double` | Total duration of this data record in seconds. Can be calculated as (endTime - startTime) or directly provided by the device. |

## Enumerations

### TSActiveMeasureType

Measurement item type enumeration defining different types of health measurements that can be selected.

| Value | Numeric | Description |
|-------|---------|-------------|
| `TSMeasureTypeNone` | 0 | No measurement selected. |
| `TSMeasureTypeHeartRate` | 1 | Real-time heart rate monitoring. |
| `TSMeasureTypeBloodOxygen` | 2 | Blood oxygen saturation (SpO2) measurement. |
| `TSMeasureTypeBloodPressure` | 3 | Systolic and diastolic blood pressure measurement. |
| `TSMeasureTypeStress` | 4 | Mental stress level assessment. |
| `TSMeasureTypeTemperature` | 5 | Body temperature measurement. |
| `TSMeasureTypeECG` | 6 | Electrocardiogram recording. |

### TSItemValueType

Heart rate data type enumeration distinguishing different sources and types of health value records.

| Value | Numeric | Description |
|-------|---------|-------------|
| `TSItemValueTypeNormal` | 0 | Normal raw point: raw time-series sample (auto or manual), not a derived statistic. |
| `TSItemValueTypeMax` | 1 | Daily maximum derived from normal points of that day. |
| `TSItemValueTypeMin` | 2 | Daily minimum derived from normal points of that day. |
| `TSItemValueTypeResting` | 3 | Resting heart rate derived by algorithm from normal samples in rest/sleep windows. (Heart rate only) |

### TSHealthValueType

Health value type for records distinguishing normal/max/min/resting records stored in health tables.

| Value | Numeric | Description |
|-------|---------|-------------|
| `TSHealthValueTypeNormal` | 0 | Normal data. |
| `TSHealthValueTypeMax` | 1 | Maximum value. |
| `TSHealthValueTypeMin` | 2 | Minimum value. |
| `TSHealthValueTypeResting` | 3 | Resting value (heart rate only). |

## Callback Types

### TSMeasureDataBlock

Block type for receiving measurement data during active measurement sessions.

```objc
typedef void (^TSMeasureDataBlock)(TSHealthValueItem *value);
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | `TSHealthValueItem *` | Health value item containing the measurement data received from the device. |

### Measurement Data Change Callback

Block type for receiving real-time measurement data changes during active measurement.

```objc
void (^dataDidChanged)(`TSHealthValueItem *` _Nullable realtimeData, `NSError *` _Nullable error)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `realtimeData` | `TSHealthValueItem *` | Real-time measurement data from device. Nil if an error occurs. |
| `error` | `NSError *` | Error information if data reception fails. Nil if successful. |

### Measurement End Callback

Block type for receiving measurement end notifications.

```objc
void (^didFinished)(BOOL isFinished, `NSError *` _Nullable error)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `isFinished` | `BOOL` | Whether the measurement ended normally (YES) or was interrupted (NO). |
| `error` | `NSError *` | Error information if measurement ended abnormally. Nil if normal end. |

## API Reference

### Start Active Health Measurement

Initiates a health measurement session based on provided parameters with custom sampling interval and duration.

```objc
+ (void)startMeasureWithParam:(`TSActivityMeasureParam *`)measureParam 
                   completion:(TSCompletionBlock)completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `measureParam` | `TSActivityMeasureParam *` | Measurement parameters including type, interval, and duration. |
| `completion` | `TSCompletionBlock` | Completion callback indicating success or failure of starting measurement. |

**Example:**

```objc
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.measureType = TSMeasureTypeHeartRate;
param.interval = 1;  // 1 second sampling interval
param.maxMeasureDuration = 60;  // 60 seconds max duration

[TSActiveMeasureInterface startMeasureWithParam:param completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to start measurement: %@", error.localizedDescription);
    } else {
        TSLog(@"Measurement started successfully");
    }
}];
```

### Stop Active Health Measurement

Stops the currently active health measurement session and terminates all ongoing data collection.

```objc
+ (void)stopMeasureWithParam:(`TSActivityMeasureParam *`)measureParam 
                  completion:(TSCompletionBlock)completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `measureParam` | `TSActivityMeasureParam *` | Measurement parameters (should match the type of active measurement). |
| `completion` | `TSCompletionBlock` | Completion callback indicating success or failure of stopping measurement. |

**Example:**

```objc
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.measureType = TSMeasureTypeHeartRate;

[TSActiveMeasureInterface stopMeasureWithParam:param completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to stop measurement: %@", error.localizedDescription);
    } else {
        TSLog(@"Measurement stopped successfully");
    }
}];
```

### Register Real-Time Measurement Data Observer

Registers a notification listener for real-time measurement data changes during active measurement.

```objc
+ (void)registerMeasurement:(`TSActivityMeasureParam *`)param
             dataDidChanged:(void(^)(`TSHealthValueItem *` _Nullable realtimeData, `NSError *` _Nullable error))dataDidChanged;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `param` | `TSActivityMeasureParam *` | Measurement parameters specifying which measurement type's data to observe. |
| `dataDidChanged` | `void (^)(TSHealthValueItem *, NSError *)` | Callback block invoked when measurement data is received. Receives real-time data or error. |

**Example:**

```objc
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.measureType = TSMeasureTypeHeartRate;

[TSActiveMeasureInterface registerMeasurement:param 
                               dataDidChanged:^(`TSHealthValueItem *` _Nullable realtimeData, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Error receiving measurement data: %@", error.localizedDescription);
        return;
    }
    
    if (realtimeData) {
        TSLog(@"Received heart rate: %d bpm", realtimeData.value);
    }
}];
```

### Register Measurement End Notification Observer

Registers a notification listener for measurement end events (completion, interruption, or failure).

```objc
+ (void)registerActivityeasureDidFinished:(void(^)(BOOL isFinished, `NSError *` _Nullable error))didFinished;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `didFinished` | `void (^)(BOOL, NSError *)` | Callback block invoked when measurement ends. Receives success flag and error information. |

**Example:**

```objc
[TSActiveMeasureInterface registerActivityeasureDidFinished:^(BOOL isFinished, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Measurement ended with error: %@", error.localizedDescription);
    } else if (isFinished) {
        TSLog(@"Measurement completed successfully");
    } else {
        TSLog(@"Measurement was interrupted");
    }
}];
```

### Fetch Heart Rate Auto Monitor Configuration

Retrieves current heart rate auto monitor configurations from the device.

```objc
+ (void)fetchHeartRateAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorHRConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorHRConfigs *, NSError *)` | Completion callback with heart rate monitor configs and error. |

**Example:**

```objc
[TSAutoMonitorInterface fetchHeartRateAutoMonitorConfigsWithCompletion:^(`TSAutoMonitorHRConfigs *` _Nullable configs, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch heart rate monitor config: %@", error.localizedDescription);
        return;
    }
    
    if (configs && configs.schedule) {
        TSLog(@"Monitor enabled: %@", configs.schedule.isEnabled ? @"YES" : @"NO");
        TSLog(@"Start time: %d minutes from midnight", configs.schedule.startTime);
        TSLog(@"End time: %d minutes from midnight", configs.schedule.endTime);
        TSLog(@"Interval: %d minutes", configs.schedule.interval);
        
        if (configs.restHRAlert) {
            TSLog(@"Rest HR alert - Upper: %d, Lower: %d", 
                  configs.restHRAlert.upperLimit, configs.restHRAlert.lowerLimit);
        }
        
        if (configs.exerciseHRAlert) {
            TSLog(@"Exercise HR alert - Upper: %d, Lower: %d", 
                  configs.exerciseHRAlert.upperLimit, configs.exerciseHRAlert.lowerLimit);
        }
        
        TSLog(@"Max exercise HR: %d bpm", configs.exerciseHRLimitMax);
    }
}];
```

### Push Heart Rate Auto Monitor Configuration

Sends heart rate auto monitor configuration to the device.

```objc
+ (void)pushHeartRateAutoMonitorConfig:(`TSAutoMonitorHRConfigs *`)config
                            completion:(TSCompletionBlock)completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `config` | `TSAutoMonitorHRConfigs *` | Heart rate auto monitor configuration to be set on the device. |
| `completion` | `TSCompletionBlock` | Completion callback with operation result. |

**Example:**

```objc
TSAutoMonitorHRConfigs *config = [[TSAutoMonitorHRConfigs alloc] init];

// Configure monitor schedule
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 480;   // 8 AM
schedule.endTime = 1200;    // 8 PM
schedule.interval = 30;     // Every 30 minutes
config.schedule = schedule;

// Configure resting heart rate alert
TSMonitorAlert *restHRAlert = [[TSMonitorAlert alloc] init];
restHRAlert.enabled = YES;
restHRAlert.upperLimit = 80;
restHRAlert.lowerLimit = 40;
config.restHRAlert = restHRAlert;

// Configure exercise heart rate alert
TSMonitorAlert *exerciseHRAlert = [[TSMonitorAlert alloc] init];
exerciseHRAlert.enabled = YES;
exerciseHRAlert.upperLimit = 160;
exerciseHRAlert.lowerLimit = 100;
config.exerciseHRAlert = exerciseHRAlert;

// Set max exercise heart rate (220 - age)
config.exerciseHRLimitMax = 190;

[TSAutoMonitorInterface pushHeartRateAutoMonitorConfig:config completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to push heart rate monitor config: %@", error.localizedDescription);
    } else {
        TSLog(@"Heart rate monitor config pushed successfully");
    }
}];
```

### Fetch Blood Pressure Auto Monitor Configuration

Retrieves current blood pressure auto monitor configurations from the device.

```objc
+ (void)fetchBloodPressureAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorBPConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorBPConfigs *, NSError *)` | Completion callback with blood pressure monitor configs and error. |

**Example:**

```objc
[TSAutoMonitorInterface fetchBloodPressureAutoMonitorConfigsWithCompletion:^(`TSAutoMonitorBPConfigs *` _Nullable configs, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch blood pressure monitor config: %@", error.localizedDescription);
        return;
    }
    
    if (configs && configs.schedule) {
        TSLog(@"Monitor enabled: %@", configs.schedule.isEnabled ? @"YES" : @"NO");
        
        if (configs.alert) {
            TSLog(@"Systolic - Upper: %d, Lower: %d mmHg", 
                  configs.alert.systolicUpperLimit, configs.alert.systolicLowerLimit);
            TSLog(@"Diastolic - Upper: %d, Lower: %d mmHg", 
                  configs.alert.diastolicUpperLimit, configs.alert.diastolicLowerLimit);
        }
    }
}];
```

### Push Blood Pressure Auto Monitor Configuration

Sends blood pressure auto monitor configuration to the device.

```objc
+ (void)pushBloodPressureAutoMonitorConfig:(`TSAutoMonitorBPConfigs *`)config
                                completion:(TSCompletionBlock)completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `config` | `TSAutoMonitorBPConfigs *` | Blood pressure auto monitor configuration to be set on the device. |
| `completion` | `TSCompletionBlock` | Completion callback with operation result. |

**Example:**

```objc
TSAutoMonitorBPConfigs *config = [[TSAutoMonitorBPConfigs alloc] init];

// Configure monitor schedule
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 0;     // Midnight
schedule.endTime = 1440;    // End of day
schedule.interval = 60;     // Every 60 minutes
config.schedule = schedule;

// Configure blood pressure alert thresholds
TSMonitorBPAlert *alert = [[TSMonitorBPAlert alloc] init];
alert.enabled = YES;
alert.systolicUpperLimit = 140;
alert.systolicLowerLimit = 90;
alert.diastolicUpperLimit = 90;
alert.diastolicLowerLimit = 60;
config.alert = alert;

[TSAutoMonitorInterface pushBloodPressureAutoMonitorConfig:config completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to push blood pressure monitor config: %@", error.localizedDescription);
    } else {
        TSLog(@"Blood pressure monitor config pushed successfully");
    }
}];
```

### Fetch Blood Oxygen Auto Monitor Configuration

Retrieves current blood oxygen (SpO2) auto monitor configurations from the device.

```objc
+ (void)fetchBloodOxygenAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | Completion callback with blood oxygen monitor configs and error. |

**Example:**

```objc
[TSAutoMonitorInterface fetchBloodOxygenAutoMonitorConfigsWithCompletion:^(`TSAutoMonitorConfigs *` _Nullable configs, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch blood oxygen monitor config: %@", error.localizedDescription);
        return;
    }
    
    if (configs && configs.schedule) {
        TSLog(@"Blood oxygen monitor enabled: %@", configs.schedule.isEnabled ? @"YES" : @"NO");
        
        if (configs.alert) {
            TSLog(@"Alert - Upper: %d%%, Lower: %d%%", 
                  configs.alert.upperLimit, configs.alert.lowerLimit);
        }
    }
}];
```

### Push Blood Oxygen Auto Monitor Configuration

Sends blood oxygen (SpO2) auto monitor configuration to the device.

```objc
+ (void)pushBloodOxygenAutoMonitorConfig:(`TSAutoMonitorConfigs *`)config
                            completion:(TSCompletionBlock)completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `config` | `TSAutoMonitorConfigs *` | Blood oxygen auto monitor configuration to be set on the device. |
| `completion` | `TSCompletionBlock` | Completion callback with operation result. |

**Example:**

```objc
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];

// Configure monitor schedule
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 360;   // 6 AM
schedule.endTime = 1380;    // 11 PM
schedule.interval = 30;     // Every 30 minutes
config.schedule = schedule;

// Configure SpO2 alert thresholds (in percentage)
TSMonitorAlert *alert = [[TSMonitorAlert alloc] init];
alert.enabled = YES;
alert.upperLimit = 100;
alert.lowerLimit = 95;  // Alert if SpO2 drops below 95%
config.alert = alert;

[TSAutoMonitorInterface pushBloodOxygenAutoMonitorConfig:config completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to push blood oxygen monitor config: %@", error.localizedDescription);
    } else {
        TSLog(@"Blood oxygen monitor config pushed successfully");
    }
}];
```

### Fetch Stress Auto Monitor Configuration

Retrieves current stress auto monitor configurations from the device.

```objc
+ (void)fetchStressAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | Completion callback with stress monitor configs and error. |

**Example:**

```objc
[TSAutoMonitorInterface fetchStressAutoMonitorConfigsWithCompletion:^(`TSAutoMonitorConfigs *` _Nullable configs, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch stress monitor config: %@", error.localizedDescription);
        return;
    }
    
    if (configs && configs.schedule) {
        TSLog(@"Stress monitor enabled: %@", configs.schedule.isEnabled ? @"YES" : @"NO");
        
        if (configs.alert) {
            TSLog(@"Stress alert - Upper: %d, Lower: %d", 
                  configs.alert.upperLimit, configs.alert.lowerLimit);
        }
    }
}];
```

### Push Stress Auto Monitor Configuration

Sends stress auto monitor configuration to the device.

```objc
+ (void)pushStressAutoMonitorConfig:(`TSAutoMonitorConfigs *`)config
                            completion:(TSCompletionBlock)completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `config` | `TSAutoMonitorConfigs *` | Stress auto monitor configuration to be set on the device. |
| `completion` | `TSCompletionBlock` | Completion callback with operation result. |

**Example:**

```objc
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];

// Configure monitor schedule
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 480;   // 8 AM
schedule.endTime = 1020;    // 5 PM
schedule.interval = 60;     // Every 60 minutes
config.schedule = schedule;

// Configure stress alert thresholds (e.g., 0-100 scale)
TSMonitorAlert *alert = [[TSMonitorAlert alloc] init];
alert.enabled = YES;
alert.upperLimit = 75;   // Alert if stress level exceeds 75
alert.lowerLimit = 25;   // Alert if stress level drops below 25
config.alert = alert;

[TSAutoMonitorInterface pushStressAutoMonitorConfig:config completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to push stress monitor config: %@", error.localizedDescription);
    } else {
        TSLog(@"Stress monitor config pushed successfully");
    }
}];
```

### Fetch Temperature Auto Monitor Configuration

Retrieves current temperature auto monitor configurations from the device.

```objc
+ (void)fetchTemperatureAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | Completion callback with temperature monitor configs and error. |

**Example:**

```objc
[TSAutoMonitorInterface fetchTemperatureAutoMonitorConfigsWithCompletion:^(`TSAutoMonitorConfigs *` _Nullable configs, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch temperature monitor config: %@", error.localizedDescription);
        return;
    }
    
    if (configs && configs.schedule) {
        TSLog(@"Temperature monitor enabled: %@", configs.schedule.isEnabled ? @"YES" : @"NO");
        
        if (configs.alert) {
            TSLog(@"Temperature alert - Upper: %d°C, Lower: %d°C", 
                  configs.alert.upperLimit, configs.alert.lowerLimit);
        }
    }
}];
```

### Push Temperature Auto Monitor Configuration

Sends temperature auto monitor configuration to the device.

```objc
+ (void)pushTemperatureAutoMonitorConfig:(`TSAutoMonitorConfigs *`)config
                            completion:(TSCompletionBlock)completion;
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `config` | `TSAutoMonitorConfigs *` | Temperature auto monitor configuration to be set on the device. |
| `completion` | `TSCompletionBlock` | Completion callback with operation result. |

**Example:**

```objc
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];

// Configure monitor schedule
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 0;     // Midnight
schedule.endTime = 1440;    // End of day (24 hours)
schedule.interval = 120;    // Every 120 minutes
config.schedule = schedule;

// Configure temperature alert thresholds (in Celsius)
TSMonitorAlert *alert = [[TSMonitorAlert alloc] init];
alert.enabled = YES;
alert.upperLimit = 39;      // Alert if temperature exceeds 39°C (fever)
alert.lowerLimit = 36;      // Alert if temperature drops below 36°C (hypothermia)
config.alert = alert;

[TSAutoMonitorInterface pushTemperatureAutoMonitorConfig:config completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"Failed to push temperature monitor config: %@", error.localizedDescription);
    } else {
        TSLog(@"Temperature monitor config pushed successfully");
    }
}];
```

## Important Notes

1. **Active Measurement Limitations**: Only one measurement type can be active at a time. Starting a new measurement will automatically stop any previously active measurement.

2. **Observer Registration**: Multiple observers can be registered simultaneously for the same measurement type. Observers should be registered before starting the measurement to ensure data reception from the beginning.

3. **Callback Thread Safety**: All completion callbacks and notification observers are called on the main thread, making it safe to update UI directly from these callbacks.

4. **Schedule Time Format**: Monitor schedule times use minutes from midnight (00:00). For example: 480 = 8 AM, 1200 = 8 PM. Valid range is 0-1440 minutes.

5. **Interval Constraints**: Monitor interval must be a multiple of 5 minutes (5, 10, 15, 20, 30, etc.).

6. **Minimum Duration**: The minimum valid measurement duration is 15 seconds. Setting `maxMeasureDuration` to 0 enables continuous measurement until manually stopped.

7. **Unit Consistency**: Different metrics use different units:
   - Heart Rate: bpm (beats per minute)
   - Blood Pressure: mmHg (millimeters of mercury)
   - Blood Oxygen: percentage (%)
   - Stress: typically 0-100 scale
   - Temperature: Celsius (°C)

8. **Device Capability Verification**: Not all
