---
sidebar_position: 11
title: AutoMonitor
---

# AutoMonitor

The AutoMonitor module provides APIs for managing automatic health monitoring configurations on wearable devices. It supports comprehensive monitoring of multiple health metrics including heart rate, blood pressure, blood oxygen, stress levels, and body temperature. This module allows you to fetch current device monitoring settings and push new configurations to enable customized automatic health data collection.

## Prerequisites

- Device must be connected and paired via the SDK's connection interface
- User must have appropriate permissions to access and modify device settings
- Device firmware must support the specific health monitoring features being configured
- All time values must be specified in minutes from midnight (00:00)
- All monitoring intervals must be multiples of 5 minutes

## Data Models

### TSAutoMonitorConfigs

Generic auto monitor configuration model used for blood oxygen, stress, and temperature monitoring.

| Property | Type | Description |
|----------|------|-------------|
| `schedule` | `TSMonitorSchedule *` | Monitor schedule including enable status, start/end times, and interval |
| `alert` | `TSMonitorAlert *` | Threshold-based alert configuration for the monitored metric |

### TSAutoMonitorHRConfigs

Specialized heart rate auto monitor configuration with separate settings for resting and exercise monitoring.

| Property | Type | Description |
|----------|------|-------------|
| `schedule` | `TSMonitorSchedule *` | Monitor schedule including enable status, start/end times, and interval |
| `restHRAlert` | `TSMonitorAlert *` | Alert thresholds for resting heart rate monitoring (bpm) |
| `exerciseHRAlert` | `TSMonitorAlert *` | Alert thresholds for exercise heart rate monitoring (bpm) |
| `exerciseHRLimitMax` | `UInt8` | Maximum exercise heart rate for zone calculation (100-220 bpm) |

### TSAutoMonitorBPConfigs

Blood pressure-specific auto monitor configuration with dual systolic/diastolic alert thresholds.

| Property | Type | Description |
|----------|------|-------------|
| `schedule` | `TSMonitorSchedule *` | Monitor schedule including enable status, start/end times, and interval |
| `alert` | `TSMonitorBPAlert *` | Blood pressure alert configuration with separate systolic and diastolic limits |

### TSMonitorSchedule

Configuration for monitoring schedule timing and frequency.

| Property | Type | Description |
|----------|------|-------------|
| `enabled` | `BOOL` | Enable/disable the monitoring schedule |
| `startTime` | `UInt16` | Start time in minutes from midnight (0-1440, e.g., 480 = 8:00 AM) |
| `endTime` | `UInt16` | End time in minutes from midnight (0-1440, e.g., 1200 = 8:00 PM) |
| `interval` | `UInt16` | Monitoring interval in minutes (must be multiple of 5: 5, 10, 15, etc.) |

### TSMonitorAlert

Generic alert threshold configuration for single-threshold metrics.

| Property | Type | Description |
|----------|------|-------------|
| `enabled` | `BOOL` | Enable/disable alert checking for this metric |
| `upperLimit` | `UInt16` | Upper threshold for alert triggering (unit varies by metric type) |
| `lowerLimit` | `UInt16` | Lower threshold for alert triggering (unit varies by metric type) |

### TSMonitorBPAlert

Specialized alert configuration for blood pressure with separate systolic and diastolic thresholds.

| Property | Type | Description |
|----------|------|-------------|
| `enabled` | `BOOL` | Enable/disable blood pressure alert checking |
| `systolicUpperLimit` | `UInt8` | Upper threshold for systolic pressure (mmHg) |
| `systolicLowerLimit` | `UInt8` | Lower threshold for systolic pressure (mmHg) |
| `diastolicUpperLimit` | `UInt8` | Upper threshold for diastolic pressure (mmHg) |
| `diastolicLowerLimit` | `UInt8` | Lower threshold for diastolic pressure (mmHg) |

## Enumerations

None defined for this module.

## Callback Types

### Completion Block for Heart Rate Configs

```objc
typedef void (^TSAutoMonitorHRConfigsCompletion)(TSAutoMonitorHRConfigs *_Nullable configs, NSError *_Nullable error);
```

Invoked upon completion of heart rate configuration fetch operation.

| Parameter | Type | Description |
|-----------|------|-------------|
| `configs` | `TSAutoMonitorHRConfigs *` | Retrieved heart rate monitor configurations, or nil if error occurred |
| `error` | `NSError *` | Error object if operation failed, nil on success |

### Completion Block for Blood Pressure Configs

```objc
typedef void (^TSAutoMonitorBPConfigsCompletion)(TSAutoMonitorBPConfigs *_Nullable configs, NSError *_Nullable error);
```

Invoked upon completion of blood pressure configuration fetch operation.

| Parameter | Type | Description |
|-----------|------|-------------|
| `configs` | `TSAutoMonitorBPConfigs *` | Retrieved blood pressure monitor configurations, or nil if error occurred |
| `error` | `NSError *` | Error object if operation failed, nil on success |

### Completion Block for Generic Configs

```objc
typedef void (^TSAutoMonitorConfigsCompletion)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error);
```

Invoked upon completion of generic configuration fetch operations (blood oxygen, stress, temperature).

| Parameter | Type | Description |
|-----------|------|-------------|
| `configs` | `TSAutoMonitorConfigs *` | Retrieved monitor configurations, or nil if error occurred |
| `error` | `NSError *` | Error object if operation failed, nil on success |

### Operation Completion Block

```objc
typedef void (^TSCompletionBlock)(NSError *_Nullable error);
```

Invoked upon completion of configuration push operations.

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError *` | Error object if operation failed, nil on success |

## API Reference

### Fetch Heart Rate Auto Monitor Configurations

Retrieves the current heart rate auto monitor settings from the connected device.

```objc
+ (void)fetchHeartRateAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorHRConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorHRConfigs *_Nullable, NSError *_Nullable)` | Callback block invoked on main queue with retrieved configs or error |

**Code Example:**

```objc
[TSAutoMonitorInterface fetchHeartRateAutoMonitorConfigsWithCompletion:^(TSAutoMonitorHRConfigs *configs, NSError *error) {
    if (error) {
        TSLog(@"Failed to fetch heart rate configs: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Heart Rate Monitor Enabled: %@", configs.schedule.isEnabled ? @"YES" : @"NO");
    TSLog(@"Start Time: %u minutes from midnight", configs.schedule.startTime);
    TSLog(@"End Time: %u minutes from midnight", configs.schedule.endTime);
    TSLog(@"Interval: %u minutes", configs.schedule.interval);
    
    if (configs.restHRAlert) {
        TSLog(@"Rest HR Alert - Enabled: %@, Upper: %u, Lower: %u",
              configs.restHRAlert.isEnabled ? @"YES" : @"NO",
              configs.restHRAlert.upperLimit,
              configs.restHRAlert.lowerLimit);
    }
    
    if (configs.exerciseHRAlert) {
        TSLog(@"Exercise HR Alert - Enabled: %@, Upper: %u, Lower: %u",
              configs.exerciseHRAlert.isEnabled ? @"YES" : @"NO",
              configs.exerciseHRAlert.upperLimit,
              configs.exerciseHRAlert.lowerLimit);
    }
    
    TSLog(@"Max Exercise HR: %u bpm", configs.exerciseHRLimitMax);
}];
```

### Push Heart Rate Auto Monitor Configuration

Sends heart rate auto monitor configuration to the device.

```objc
+ (void)pushHeartRateAutoMonitorConfig:(TSAutoMonitorHRConfigs *)config
                            completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `config` | `TSAutoMonitorHRConfigs *` | Heart rate monitor configuration to be applied on device |
| `completion` | `TSCompletionBlock` | Callback block invoked on main queue with operation result |

**Code Example:**

```objc
TSAutoMonitorHRConfigs *hrConfig = [[TSAutoMonitorHRConfigs alloc] init];

// Configure schedule
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 480;    // 8:00 AM
schedule.endTime = 1440;     // 24:00 (midnight)
schedule.interval = 10;      // Every 10 minutes
hrConfig.schedule = schedule;

// Configure resting heart rate alert
TSMonitorAlert *restAlert = [[TSMonitorAlert alloc] init];
restAlert.enabled = YES;
restAlert.lowerLimit = 40;   // Alert if below 40 bpm
restAlert.upperLimit = 100;  // Alert if above 100 bpm
hrConfig.restHRAlert = restAlert;

// Configure exercise heart rate alert
TSMonitorAlert *exerciseAlert = [[TSMonitorAlert alloc] init];
exerciseAlert.enabled = YES;
exerciseAlert.lowerLimit = 60;   // Alert if below 60 bpm
exerciseAlert.upperLimit = 180;  // Alert if above 180 bpm
hrConfig.exerciseHRAlert = exerciseAlert;

// Set maximum exercise heart rate for zone calculation
hrConfig.exerciseHRLimitMax = 190;  // 220 - 30 years old

[TSAutoMonitorInterface pushHeartRateAutoMonitorConfig:hrConfig completion:^(NSError *error) {
    if (error) {
        TSLog(@"Failed to push heart rate config: %@", error.localizedDescription);
    } else {
        TSLog(@"Heart rate config pushed successfully");
    }
}];
```

### Fetch Blood Pressure Auto Monitor Configurations

Retrieves the current blood pressure auto monitor settings from the connected device.

```objc
+ (void)fetchBloodPressureAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorBPConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorBPConfigs *_Nullable, NSError *_Nullable)` | Callback block invoked on main queue with retrieved configs or error |

**Code Example:**

```objc
[TSAutoMonitorInterface fetchBloodPressureAutoMonitorConfigsWithCompletion:^(TSAutoMonitorBPConfigs *configs, NSError *error) {
    if (error) {
        TSLog(@"Failed to fetch BP configs: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"BP Monitor Enabled: %@", configs.schedule.isEnabled ? @"YES" : @"NO");
    TSLog(@"Start Time: %u, End Time: %u, Interval: %u min", 
          configs.schedule.startTime, 
          configs.schedule.endTime, 
          configs.schedule.interval);
    
    if (configs.alert) {
        TSLog(@"BP Alert Enabled: %@", configs.alert.isEnabled ? @"YES" : @"NO");
        TSLog(@"Systolic: %u-%u mmHg", 
              configs.alert.systolicLowerLimit, 
              configs.alert.systolicUpperLimit);
        TSLog(@"Diastolic: %u-%u mmHg", 
              configs.alert.diastolicLowerLimit, 
              configs.alert.diastolicUpperLimit);
    }
}];
```

### Push Blood Pressure Auto Monitor Configuration

Sends blood pressure auto monitor configuration to the device.

```objc
+ (void)pushBloodPressureAutoMonitorConfig:(TSAutoMonitorBPConfigs *)config
                                completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `config` | `TSAutoMonitorBPConfigs *` | Blood pressure monitor configuration to be applied on device |
| `completion` | `TSCompletionBlock` | Callback block invoked on main queue with operation result |

**Code Example:**

```objc
TSAutoMonitorBPConfigs *bpConfig = [[TSAutoMonitorBPConfigs alloc] init];

// Configure schedule
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 360;    // 6:00 AM
schedule.endTime = 1320;     // 10:00 PM
schedule.interval = 15;      // Every 15 minutes
bpConfig.schedule = schedule;

// Configure blood pressure alert thresholds
TSMonitorBPAlert *bpAlert = [[TSMonitorBPAlert alloc] init];
bpAlert.enabled = YES;
bpAlert.systolicUpperLimit = 140;    // High BP threshold
bpAlert.systolicLowerLimit = 90;     // Low BP threshold
bpAlert.diastolicUpperLimit = 90;    // High diastolic
bpAlert.diastolicLowerLimit = 60;    // Low diastolic
bpConfig.alert = bpAlert;

[TSAutoMonitorInterface pushBloodPressureAutoMonitorConfig:bpConfig completion:^(NSError *error) {
    if (error) {
        TSLog(@"Failed to push BP config: %@", error.localizedDescription);
    } else {
        TSLog(@"Blood pressure config pushed successfully");
    }
}];
```

### Fetch Blood Oxygen Auto Monitor Configurations

Retrieves the current blood oxygen (SpO2) auto monitor settings from the connected device.

```objc
+ (void)fetchBloodOxygenAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs *_Nullable, NSError *_Nullable)` | Callback block invoked on main queue with retrieved configs or error |

**Code Example:**

```objc
[TSAutoMonitorInterface fetchBloodOxygenAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *configs, NSError *error) {
    if (error) {
        TSLog(@"Failed to fetch blood oxygen configs: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Blood Oxygen Monitor Enabled: %@", configs.schedule.isEnabled ? @"YES" : @"NO");
    TSLog(@"Schedule: %u-%u, Interval: %u min", 
          configs.schedule.startTime, 
          configs.schedule.endTime, 
          configs.schedule.interval);
    
    if (configs.alert) {
        TSLog(@"SpO2 Alert - Enabled: %@, Range: %u%%-%%u%%", 
              configs.alert.isEnabled ? @"YES" : @"NO",
              configs.alert.lowerLimit, 
              configs.alert.upperLimit);
    }
}];
```

### Push Blood Oxygen Auto Monitor Configuration

Sends blood oxygen (SpO2) auto monitor configuration to the device.

```objc
+ (void)pushBloodOxygenAutoMonitorConfig:(TSAutoMonitorConfigs *)config
                            completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `config` | `TSAutoMonitorConfigs *` | Blood oxygen monitor configuration to be applied on device |
| `completion` | `TSCompletionBlock` | Callback block invoked on main queue with operation result |

**Code Example:**

```objc
TSAutoMonitorConfigs *o2Config = [[TSAutoMonitorConfigs alloc] init];

// Configure schedule
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 0;      // Midnight (start of day)
schedule.endTime = 1440;     // Midnight (end of day)
schedule.interval = 30;      // Every 30 minutes
o2Config.schedule = schedule;

// Configure blood oxygen alert
TSMonitorAlert *o2Alert = [[TSMonitorAlert alloc] init];
o2Alert.enabled = YES;
o2Alert.lowerLimit = 95;     // Alert if SpO2 drops below 95%
o2Alert.upperLimit = 100;    // Upper limit (typically max 100%)
o2Config.alert = o2Alert;

[TSAutoMonitorInterface pushBloodOxygenAutoMonitorConfig:o2Config completion:^(NSError *error) {
    if (error) {
        TSLog(@"Failed to push blood oxygen config: %@", error.localizedDescription);
    } else {
        TSLog(@"Blood oxygen config pushed successfully");
    }
}];
```

### Fetch Stress Auto Monitor Configurations

Retrieves the current stress auto monitor settings from the connected device.

```objc
+ (void)fetchStressAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs *_Nullable, NSError *_Nullable)` | Callback block invoked on main queue with retrieved configs or error |

**Code Example:**

```objc
[TSAutoMonitorInterface fetchStressAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *configs, NSError *error) {
    if (error) {
        TSLog(@"Failed to fetch stress configs: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Stress Monitor Enabled: %@", configs.schedule.isEnabled ? @"YES" : @"NO");
    TSLog(@"Monitoring from %u to %u minutes, every %u minutes", 
          configs.schedule.startTime, 
          configs.schedule.endTime, 
          configs.schedule.interval);
    
    if (configs.alert) {
        TSLog(@"Stress Alert - Enabled: %@, Level Range: %u-%u", 
              configs.alert.isEnabled ? @"YES" : @"NO",
              configs.alert.lowerLimit, 
              configs.alert.upperLimit);
    }
}];
```

### Push Stress Auto Monitor Configuration

Sends stress auto monitor configuration to the device.

```objc
+ (void)pushStressAutoMonitorConfig:(TSAutoMonitorConfigs *)config
                            completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `config` | `TSAutoMonitorConfigs *` | Stress monitor configuration to be applied on device |
| `completion` | `TSCompletionBlock` | Callback block invoked on main queue with operation result |

**Code Example:**

```objc
TSAutoMonitorConfigs *stressConfig = [[TSAutoMonitorConfigs alloc] init];

// Configure schedule for stress monitoring
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 480;    // 8:00 AM
schedule.endTime = 1200;     // 8:00 PM
schedule.interval = 20;      // Every 20 minutes during work hours
stressConfig.schedule = schedule;

// Configure stress alert
TSMonitorAlert *stressAlert = [[TSMonitorAlert alloc] init];
stressAlert.enabled = YES;
stressAlert.lowerLimit = 0;     // Minimum stress level
stressAlert.upperLimit = 70;    // Alert if stress exceeds 70 (on 0-100 scale)
stressConfig.alert = stressAlert;

[TSAutoMonitorInterface pushStressAutoMonitorConfig:stressConfig completion:^(NSError *error) {
    if (error) {
        TSLog(@"Failed to push stress config: %@", error.localizedDescription);
    } else {
        TSLog(@"Stress config pushed successfully");
    }
}];
```

### Fetch Temperature Auto Monitor Configurations

Retrieves the current body temperature auto monitor settings from the connected device.

```objc
+ (void)fetchTemperatureAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs *_Nullable, NSError *_Nullable)` | Callback block invoked on main queue with retrieved configs or error |

**Code Example:**

```objc
[TSAutoMonitorInterface fetchTemperatureAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *configs, NSError *error) {
    if (error) {
        TSLog(@"Failed to fetch temperature configs: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Temperature Monitor Enabled: %@", configs.schedule.isEnabled ? @"YES" : @"NO");
    TSLog(@"Schedule: %u-%u minutes, Interval: %u min", 
          configs.schedule.startTime, 
          configs.schedule.endTime, 
          configs.schedule.interval);
    
    if (configs.alert) {
        TSLog(@"Temp Alert - Enabled: %@, Range: %u°C-%%u°C", 
              configs.alert.isEnabled ? @"YES" : @"NO",
              configs.alert.lowerLimit, 
              configs.alert.upperLimit);
    }
}];
```

### Push Temperature Auto Monitor Configuration

Sends body temperature auto monitor configuration to the device.

```objc
+ (void)pushTemperatureAutoMonitorConfig:(TSAutoMonitorConfigs *)config
                            completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `config` | `TSAutoMonitorConfigs *` | Temperature monitor configuration to be applied on device |
| `completion` | `TSCompletionBlock` | Callback block invoked on main queue with operation result |

**Code Example:**

```objc
TSAutoMonitorConfigs *tempConfig = [[TSAutoMonitorConfigs alloc] init];

// Configure schedule
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 0;      // All day monitoring
schedule.endTime = 1440;
schedule.interval = 60;      // Check every hour
tempConfig.schedule = schedule;

// Configure temperature alert thresholds
TSMonitorAlert *tempAlert = [[TSMonitorAlert alloc] init];
tempAlert.enabled = YES;
tempAlert.lowerLimit = 36;   // Alert if below 36°C (hypothermia)
tempAlert.upperLimit = 38;   // Alert if above 38°C (fever)
tempConfig.alert = tempAlert;

[TSAutoMonitorInterface pushTemperatureAutoMonitorConfig:tempConfig completion:^(NSError *error) {
    if (error) {
        TSLog(@"Failed to push temperature config: %@", error.localizedDescription);
    } else {
        TSLog(@"Temperature config pushed successfully");
    }
}];
```

## Important Notes

1. All time values in `TSMonitorSchedule` must be specified in minutes from midnight (00:00). For example, 480 represents 8:00 AM and 1200 represents 8:00 PM.

2. The monitoring `interval` property must be a multiple of 5 minutes. Valid values are: 5, 10, 15, 20, 25, 30, etc. The device will not accept intervals that are not multiples of 5.

3. The `endTime` value must always be greater than `startTime`. When setting up 24-hour monitoring, use `startTime: 0` and `endTime: 1440`.

4. All operations are asynchronous and invoke their completion blocks on the main dispatch queue. Always ensure UI updates are performed in the completion handler.

5. For heart rate monitoring, the `exerciseHRLimitMax` is typically calculated as 220 minus the user's age. Valid range is 100-220 bpm. This value is used to calculate heart rate zones.

6. Blood pressure thresholds use separate systolic and diastolic limits measured in millimeters of mercury (mmHg). Typical normal ranges are systolic 90-120 and diastolic 60-80.

7. Blood oxygen (SpO2) values are measured in percentage (%) with typical healthy range being 95-100%. Alert thresholds should generally be set with `lowerLimit` for minimum acceptable oxygen and `upperLimit` for maximum.

8. Stress levels are typically measured on a 0-100 scale. The exact scale and interpretation may vary based on device implementation.

9. Temperature values are measured in Celsius (°C). Normal body temperature range is approximately 36.1-37.2°C, with fever typically defined as above 38°C.

10. Heart rate values are measured in beats per minute (bpm). Normal resting heart rate for adults ranges from 60-100 bpm, while exercise heart rate varies based on intensity and fitness level.

11. When creating alert configurations, ensure that `lowerLimit` is less than `upperLimit` for proper alert behavior. Setting `enabled` to false will disable alerting for that specific metric.

12. Device connectivity must be maintained throughout fetch and push operations. If the device disconnects during an operation, the completion block will be called with an appropriate error.