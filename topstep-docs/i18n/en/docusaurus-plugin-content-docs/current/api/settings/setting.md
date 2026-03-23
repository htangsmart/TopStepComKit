---
sidebar_position: 5
title: Setting
---

# Device Setting

The Device Setting module provides comprehensive management of device settings including wearing habits, Bluetooth notifications, exercise reminders, call alerts, wrist wake-up functionality, do-not-disturb mode, and enhanced monitoring options. All settings are persisted on the device and retained after power off.

## Prerequisites

- Device must be connected via Bluetooth
- `TSSettingInterface` protocol must be available from the connected device
- User must have necessary permissions for all settings operations
- Device firmware must support the settings being configured

## Data Models

### TSWristWakeUpModel

Configures the wrist wake-up feature, allowing the device screen to activate when the user raises their wrist during specified time periods.

| Property | Type | Description |
|----------|------|-------------|
| `isEnable` | `BOOL` | Enable status of wrist wake-up feature. YES enables the feature, NO disables it. |
| `startTime` | `NSInteger` | Start time in minutes from midnight (0-1439). Example: 480 = 8:00 AM. Feature is active during the time period from startTime to endTime. |
| `endTime` | `NSInteger` | End time in minutes from midnight (0-1439). Example: 1320 = 10:00 PM. Must be greater than startTime to form a valid time period. |

### TSDoNotDisturbModel

Configures the do-not-disturb mode, allowing users to specify time periods when the device should not send notifications or disturbances.

| Property | Type | Description |
|----------|------|-------------|
| `isEnabled` | `BOOL` | Whether do-not-disturb mode is enabled. YES activates the feature, NO disables it. |
| `isTimePeriodMode` | `BOOL` | Determines the DND mode type. YES = time period mode (specific hours), NO = all-day mode (24/7). |
| `startTime` | `NSInteger` | Start time in minutes from midnight (0-1440). Only effective when time period mode is enabled (isTimePeriodMode = YES). Must be less than endTime. |
| `endTime` | `NSInteger` | End time in minutes from midnight (0-1440). Only effective when time period mode is enabled (isTimePeriodMode = YES). Must be greater than startTime. |

## Enumerations

### TSWearingHabit

Defines which hand the device is worn on, affecting screen orientation and gesture recognition.

| Value | Description |
|-------|-------------|
| `TSWearingHabitLeft` | Device is worn on the left hand. Screen orientation and gesture recognition are adjusted accordingly. |
| `TSWearingHabitRight` | Device is worn on the right hand. Screen orientation and gesture recognition are adjusted accordingly. |

## Callback Types

### TSCompletionBlock

Standard completion callback for setting operations.

```objc
typedef void (^TSCompletionBlock)(BOOL success, NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the operation completed successfully. YES indicates success, NO indicates failure. |
| `error` | `NSError * _Nullable` | Error information if the operation failed. nil if successful. |

## API Reference

### Set device wearing habit

Configures which hand the device is worn on, affecting screen orientation, gesture recognition direction, and raise-wrist detection.

```objc
- (void)setWearingHabit:(TSWearingHabit)habit
             completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `habit` | `TSWearingHabit` | Wearing habit selection. TSWearingHabitLeft for left hand, TSWearingHabitRight for right hand. |
| `completion` | `TSCompletionBlock` | Completion callback with success status and error information if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting setWearingHabit:TSWearingHabitRight completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Wearing habit set successfully to right hand");
    } else {
        TSLog(@"Failed to set wearing habit: %@", error.localizedDescription);
    }
}];
```

### Get current wearing habit

Retrieves the current wearing habit setting from the device.

```objc
- (void)getCurrentWearingHabit:(void(^)(TSWearingHabit habit, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSWearingHabit, NSError * _Nullable)` | Callback block returning the current wearing habit and error if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getCurrentWearingHabit:^(TSWearingHabit habit, NSError *error) {
    if (!error) {
        NSString *habitStr = (habit == TSWearingHabitLeft) ? @"Left hand" : @"Right hand";
        TSLog(@"Current wearing habit: %@", habitStr);
    } else {
        TSLog(@"Failed to get wearing habit: %@", error.localizedDescription);
    }
}];
```

### Set Bluetooth disconnection vibration

Configures whether the device vibrates when the Bluetooth connection is lost.

```objc
- (void)setBluetoothDisconnectionVibration:(BOOL)enabled
                               completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | `BOOL` | Enable vibration on Bluetooth disconnection. YES enables vibration, NO disables it. |
| `completion` | `TSCompletionBlock` | Completion callback with success status and error information if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting setBluetoothDisconnectionVibration:YES completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Bluetooth disconnection vibration enabled");
    } else {
        TSLog(@"Failed to set Bluetooth disconnection vibration: %@", error.localizedDescription);
    }
}];
```

### Get Bluetooth disconnection vibration status

Retrieves the current Bluetooth disconnection vibration setting.

```objc
- (void)getBluetoothDisconnectionVibrationStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(BOOL, NSError * _Nullable)` | Callback block returning the vibration status and error if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getBluetoothDisconnectionVibrationStatus:^(BOOL enabled, NSError *error) {
    if (!error) {
        TSLog(@"Bluetooth disconnection vibration is %@", enabled ? @"enabled" : @"disabled");
    } else {
        TSLog(@"Failed to get Bluetooth disconnection vibration status: %@", error.localizedDescription);
    }
}];
```

### Set exercise goal achievement reminder

Configures whether the device notifies when exercise goals are achieved.

```objc
- (void)setExerciseGoalReminder:(BOOL)enabled
                    completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | `BOOL` | Enable exercise goal reminder. YES enables reminders, NO disables them. |
| `completion` | `TSCompletionBlock` | Completion callback with success status and error information if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting setExerciseGoalReminder:YES completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Exercise goal reminder enabled");
    } else {
        TSLog(@"Failed to set exercise goal reminder: %@", error.localizedDescription);
    }
}];
```

### Get exercise goal reminder status

Retrieves the current exercise goal reminder setting.

```objc
- (void)getExerciseGoalReminderStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(BOOL, NSError * _Nullable)` | Callback block returning the reminder status and error if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getExerciseGoalReminderStatus:^(BOOL enabled, NSError *error) {
    if (!error) {
        TSLog(@"Exercise goal reminder is %@", enabled ? @"enabled" : @"disabled");
    } else {
        TSLog(@"Failed to get exercise goal reminder status: %@", error.localizedDescription);
    }
}];
```

### Set call ring

Configures whether the device rings and vibrates for incoming calls.

```objc
- (void)setCallRing:(BOOL)enabled
         completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | `BOOL` | Enable call ring. YES enables ringing and vibration, NO disables them. |
| `completion` | `TSCompletionBlock` | Completion callback with success status and error information if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting setCallRing:YES completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Call ring enabled");
    } else {
        TSLog(@"Failed to set call ring: %@", error.localizedDescription);
    }
}];
```

### Get call ring status

Retrieves the current call ring setting.

```objc
- (void)getCallRingStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(BOOL, NSError * _Nullable)` | Callback block returning the call ring status and error if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getCallRingStatus:^(BOOL enabled, NSError *error) {
    if (!error) {
        TSLog(@"Call ring is %@", enabled ? @"enabled" : @"disabled");
    } else {
        TSLog(@"Failed to get call ring status: %@", error.localizedDescription);
    }
}];
```

### Set raise wrist to wake screen settings

Configures the wrist wake-up feature with time period settings.

```objc
- (void)setRaiseWristToWake:(TSWristWakeUpModel *)model
                completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | `TSWristWakeUpModel *` | Configuration object containing enable status and time period (startTime and endTime in minutes from midnight). End time must be greater than start time. |
| `completion` | `TSCompletionBlock` | Completion callback with success status and error information if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

TSWristWakeUpModel *model = [[TSWristWakeUpModel alloc] init];
model.isEnable = YES;
model.startTime = 480;   // 8:00 AM
model.endTime = 1320;    // 10:00 PM

[setting setRaiseWristToWake:model completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Raise wrist to wake configured successfully");
    } else {
        TSLog(@"Failed to set raise wrist to wake: %@", error.localizedDescription);
    }
}];
```

### Get raise wrist to wake screen settings

Retrieves the current wrist wake-up configuration.

```objc
- (void)getRaiseWristToWakeStatus:(void(^)(TSWristWakeUpModel * _Nullable model, 
                                          NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSWristWakeUpModel * _Nullable, NSError * _Nullable)` | Callback block returning the current configuration model and error if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getRaiseWristToWakeStatus:^(TSWristWakeUpModel *model, NSError *error) {
    if (!error && model) {
        TSLog(@"Wrist wake enabled: %@, Start: %ld, End: %ld",
              model.isEnable ? @"YES" : @"NO", 
              (long)model.startTime, 
              (long)model.endTime);
    } else {
        TSLog(@"Failed to get raise wrist to wake status: %@", error.localizedDescription);
    }
}];
```

### Register raise wrist to wake screen configuration change listener

Registers a listener for configuration changes to the wrist wake-up feature.

```objc
- (void)registerRaiseWristToWakeDidChanged:(void(^)(TSWristWakeUpModel * _Nullable model,
                                                        NSError * _Nullable error))didChangeBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `didChangeBlock` | `void (^)(TSWristWakeUpModel * _Nullable, NSError * _Nullable)` | Callback block invoked when configuration changes, returning updated model and error if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting registerRaiseWristToWakeDidChanged:^(TSWristWakeUpModel *model, NSError *error) {
    if (!error && model) {
        TSLog(@"Wrist wake configuration changed - Enabled: %@, Start: %ld, End: %ld",
              model.isEnable ? @"YES" : @"NO",
              (long)model.startTime,
              (long)model.endTime);
    } else {
        TSLog(@"Configuration change notification error: %@", error.localizedDescription);
    }
}];
```

### Set do not disturb mode settings

Configures the do-not-disturb mode with time period or all-day settings.

```objc
- (void)setDoNotDisturb:(TSDoNotDisturbModel *)model
                 completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | `TSDoNotDisturbModel *` | Configuration object containing enable status, mode type (time period or all-day), and time settings (startTime and endTime in minutes from midnight). |
| `completion` | `TSCompletionBlock` | Completion callback with success status and error information if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

TSDoNotDisturbModel *dndModel = [[TSDoNotDisturbModel alloc] init];
dndModel.isEnabled = YES;
dndModel.isTimePeriodMode = YES;
dndModel.startTime = 720;   // 12:00 PM
dndModel.endTime = 840;     // 2:00 PM

[setting setDoNotDisturb:dndModel completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Do not disturb mode configured successfully");
    } else {
        TSLog(@"Failed to set do not disturb: %@", error.localizedDescription);
    }
}];
```

### Get do not disturb mode settings

Retrieves the current do-not-disturb mode configuration.

```objc
- (void)getDoNotDisturbInfo:(void(^)(TSDoNotDisturbModel * _Nullable model,
                                          NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSDoNotDisturbModel * _Nullable, NSError * _Nullable)` | Callback block returning the current configuration model and error if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getDoNotDisturbInfo:^(TSDoNotDisturbModel *model, NSError *error) {
    if (!error && model) {
        NSString *mode = model.isTimePeriodMode ? @"Time period" : @"All-day";
        TSLog(@"DND enabled: %@, Mode: %@, Start: %ld, End: %ld",
              model.isEnabled ? @"YES" : @"NO",
              mode,
              (long)model.startTime,
              (long)model.endTime);
    } else {
        TSLog(@"Failed to get do not disturb info: %@", error.localizedDescription);
    }
}];
```

### Set enhanced monitoring mode

Configures enhanced monitoring mode for higher precision health monitoring with increased data collection frequency.

```objc
- (void)setEnhancedMonitoring:(BOOL)enabled
                    completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | `BOOL` | Enable enhanced monitoring mode. YES enables high-precision monitoring with more frequent data collection, NO uses standard monitoring. |
| `completion` | `TSCompletionBlock` | Completion callback with success status and error information if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting setEnhancedMonitoring:YES completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Enhanced monitoring mode enabled");
    } else {
        TSLog(@"Failed to set enhanced monitoring: %@", error.localizedDescription);
    }
}];
```

### Get enhanced monitoring mode status

Retrieves the current enhanced monitoring mode setting.

```objc
- (void)getEnhancedMonitoringStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(BOOL, NSError * _Nullable)` | Callback block returning the monitoring mode status and error if any. |

**Code Example:**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getEnhancedMonitoringStatus:^(BOOL enabled, NSError *error) {
    if (!error) {
        TSLog(@"Enhanced monitoring is %@", enabled ? @"enabled" : @"disabled");
    } else {
        TSLog(@"Failed to get enhanced monitoring status: %@", error.localizedDescription);
    }
}];
```

## Important Notes

1. **Bluetooth Connection Requirement** — All setting operations require an active Bluetooth connection with the device. Ensure the device is properly connected before calling any setting methods.

2. **Time Period Validation** — When setting time periods (wrist wake-up and do-not-disturb), the end time must always be greater than the start time. Times are specified in minutes from midnight (0-1440), where 480 = 8:00 AM and 1320 = 10:00 PM.

3. **Persistence** — All settings are automatically persisted on the device and will be retained even after the device is powered off. Settings do not need to be reapplied after reconnection.

4. **Completion Handler Timing** — Completion handlers are called asynchronously. Do not assume settings are applied immediately; wait for the completion callback before performing dependent operations.

5. **Error Handling** — Always check the `error` parameter in completion callbacks. Errors typically indicate connection issues, device-side problems, or invalid parameter values.

6. **Multiple Listeners** — Multiple listeners can be registered for configuration change events (e.g., wrist wake-up changes) simultaneously. Each listener receives notifications independently.

7. **Enhanced Monitoring Battery Impact** — Enabling enhanced monitoring mode increases battery consumption due to more frequent data collection. Inform users of this trade-off when providing settings UI.

8. **Do-Not-Disturb Mode Types** — Use `isTimePeriodMode = YES` for scheduled quiet hours (with startTime and endTime), and `isTimePeriodMode = NO` for all-day do-not-disturb mode where time settings are ignored.

9. **Setting Synchronization** — After successful setting changes, retrieve the setting again using the corresponding getter method to confirm the device applied the change correctly.

10. **User Permissions** — Ensure your app has necessary system permissions before setting features like call ring, as some settings depend on system capabilities and user-granted permissions.