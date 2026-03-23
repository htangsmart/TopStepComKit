---
sidebar_position: 3
title: FemaleHealth
---

# FemaleHealth

The FemaleHealth module provides comprehensive female health tracking and management capabilities, including menstrual cycle tracking, pregnancy preparation monitoring, and pregnancy tracking. It allows you to fetch and push female health configurations to the device, and receive notifications when configurations change.

## Prerequisites

- Device must support female health features
- Device must be connected and initialized through the TopStepComKit framework
- User must have appropriate permissions to access female health data

## Data Models

### TSFemaleHealthConfig

Female health configuration model containing tracking mode, cycle information, and reminder settings.

| Property | Type | Description |
|----------|------|-------------|
| `healthMode` | `TSFemaleHealthMode` | Female health tracking mode (Disabled, Menstruation, PregnancyPreparation, or Pregnancy). Default is Disabled. |
| `reminderTimeMinutes` | `NSInteger` | Reminder time offset in minutes from midnight (00:00). Valid range: 0-1439 (0:00 to 23:59). For example, 480 represents 8:00 AM. |
| `reminderAdvanceDays` | `NSInteger` | Number of days in advance to send reminder before the event. Valid range: typically 0-7 days. |
| `pregnancyReminderType` | `TSPregnancyReminderType` | Type of reminder for pregnancy mode: PregnancyDays (based on pregnancy days since conception) or DueDateDays (based on days until due date). Only effective when healthMode is Pregnancy. |
| `menstrualCycleLength` | `NSInteger` | Length of the menstrual cycle in days. Valid range: typically 21-35 days. Average is 28 days. |
| `menstrualPeriodDuration` | `NSInteger` | Duration of menstrual bleeding in days. Valid range: typically 3-7 days. Average is 5 days. |
| `lastPeriodStartTimestamp` | `NSTimeInterval` | Unix timestamp (seconds since 1970) representing the start date of the last menstrual period. Timestamp should represent 00:00:00 of the start date. Value 0 if not set. |
| `menstruationEndDayInCycle` | `NSInteger` | Day number in the cycle when menstruation ends. Valid range: typically 1-7 days. Value 0 indicates menstruation has ended or not started. |
| `reminderSwitches` | `TSFemaleHealthReminderSwitch` | Bit flags indicating which female health reminder switches are turned on. Can be combined using bitwise OR operations. Note: Not supported by all projects. |

## Enumerations

### TSFemaleHealthMode

Female health tracking mode enumeration.

| Value | Name | Description |
|-------|------|-------------|
| 0 | `TSFemaleHealthModeDisabled` | Feature is turned off |
| 1 | `TSFemaleHealthModeMenstruation` | Menstrual cycle tracking mode |
| 2 | `TSFemaleHealthModePregnancyPreparation` | Pregnancy preparation tracking mode |
| 3 | `TSFemaleHealthModePregnancy` | Pregnancy tracking mode |

### TSPregnancyReminderType

Pregnancy reminder type enumeration.

| Value | Name | Description |
|-------|------|-------------|
| 0 | `TSPregnancyReminderTypePregnancyDays` | Reminder based on pregnancy days (days since conception) |
| 1 | `TSPregnancyReminderTypeDueDateDays` | Reminder based on days until due date |

### TSFemaleHealthReminderSwitch

Female health reminder switch bit flags. Can be combined using bitwise OR operations.

| Value | Name | Description |
|-------|------|-------------|
| 0 | `TSFemaleHealthReminderSwitchNone` | No reminder |
| `1 << 0` | `TSFemaleHealthReminderSwitchMenstruationStart` | Menstruation start reminder switch. Fixed time: 8 AM one day before predicted menstruation |
| `1 << 1` | `TSFemaleHealthReminderSwitchMenstruationEnd` | Menstruation end reminder switch. Fixed time: 8 AM on the day menstruation ends |
| `1 << 2` | `TSFemaleHealthReminderSwitchFertileWindowStart` | Fertile window start reminder switch. Fixed time: 8 AM on the day fertile window starts |
| `1 << 3` | `TSFemaleHealthReminderSwitchFertileWindowEnd` | Fertile window end reminder switch. Fixed time: 8 AM on the day fertile window ends |
| Combined | `TSFemaleHealthReminderSwitchAll` | All reminder switches combined |

## Callback Types

### TSFemaleHealthConfigDidChangedBlock

Callback block triggered when female health configuration changes on the device.

```objc
typedef void(^TSFemaleHealthConfigDidChangedBlock)(
    TSFemaleHealthConfig * _Nullable femaleHealthConfig,
    NSError * _Nullable error
);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `femaleHealthConfig` | `TSFemaleHealthConfig * _Nullable` | Updated female health configuration model. Nil if error occurred. |
| `error` | `NSError * _Nullable` | Error information. Nil when successful. |

## API Reference

### Fetch female health configuration from device

Retrieves the current female health configuration from the connected device, including tracking mode, cycle information, and reminder settings.

```objc
- (void)fetchFemaleHealthConfigWithCompletion:(void(^)(TSFemaleHealthConfig * _Nullable femaleHealthConfig, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSFemaleHealthConfig * _Nullable, NSError * _Nullable)` | Callback block that returns female health configuration and any error that occurred |

**Code Example:**

```objc
id<TSFemaleHealthInterface> femaleHealthInterface = (id<TSFemaleHealthInterface>)device;

[femaleHealthInterface fetchFemaleHealthConfigWithCompletion:^(TSFemaleHealthConfig * _Nullable femaleHealthConfig, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch female health config: %@", error.localizedDescription);
    } else if (femaleHealthConfig) {
        TSLog(@"Health Mode: %ld", (long)femaleHealthConfig.healthMode);
        TSLog(@"Cycle Length: %ld days", (long)femaleHealthConfig.menstrualCycleLength);
        TSLog(@"Period Duration: %ld days", (long)femaleHealthConfig.menstrualPeriodDuration);
        TSLog(@"Reminder Time: %ld minutes from midnight", (long)femaleHealthConfig.reminderTimeMinutes);
    }
}];
```

### Push female health configuration to device

Pushes the female health configuration to the connected device. The device will replace existing configuration with the provided settings.

```objc
- (void)pushFemaleHealthConfig:(TSFemaleHealthConfig * _Nonnull)femaleHealthConfig
                    completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `femaleHealthConfig` | `TSFemaleHealthConfig * _Nonnull` | Female health configuration to be set. Must not be nil. |
| `completion` | `TSCompletionBlock` | Callback block executed after the operation completes |

**Code Example:**

```objc
id<TSFemaleHealthInterface> femaleHealthInterface = (id<TSFemaleHealthInterface>)device;

TSFemaleHealthConfig *config = [[TSFemaleHealthConfig alloc] init];
config.healthMode = TSFemaleHealthModeMenstruation;
config.menstrualCycleLength = 28;
config.menstrualPeriodDuration = 5;
config.reminderTimeMinutes = 480; // 8:00 AM
config.reminderAdvanceDays = 1;
config.reminderSwitches = TSFemaleHealthReminderSwitchMenstruationStart | TSFemaleHealthReminderSwitchMenstruationEnd;

// Set last period start date to today at 00:00:00
NSDate *today = [NSDate date];
NSCalendar *calendar = [NSCalendar currentCalendar];
NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:today];
NSDate *startOfDay = [calendar dateFromComponents:components];
config.lastPeriodStartTimestamp = [startOfDay timeIntervalSince1970];

[femaleHealthInterface pushFemaleHealthConfig:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to push female health config: %@", error.localizedDescription);
    } else {
        TSLog(@"Female health config pushed successfully");
    }
}];
```

### Register for female health configuration change notifications

Registers a callback block to monitor device female health configuration changes. Pass nil to unregister.

```objc
- (void)registerFemaleHealthConfigDidChangedBlock:(nullable TSFemaleHealthConfigDidChangedBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSFemaleHealthConfigDidChangedBlock _Nullable` | Callback block triggered when female health configuration changes. Pass nil to unregister the notification. |

**Code Example:**

```objc
id<TSFemaleHealthInterface> femaleHealthInterface = (id<TSFemaleHealthInterface>)device;

[femaleHealthInterface registerFemaleHealthConfigDidChangedBlock:^(TSFemaleHealthConfig * _Nullable femaleHealthConfig, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Error receiving female health config changes: %@", error.localizedDescription);
    } else if (femaleHealthConfig) {
        TSLog(@"Female health config changed on device");
        TSLog(@"New Health Mode: %ld", (long)femaleHealthConfig.healthMode);
        TSLog(@"Cycle Length: %ld days", (long)femaleHealthConfig.menstrualCycleLength);
    }
}];
```

### Unregister female health configuration change notifications

Removes the registered female health configuration change listener. Equivalent to calling `registerFemaleHealthConfigDidChangedBlock:` with nil.

```objc
- (void)unregisterFemaleHealthConfigDidChangedBlock;
```

**Code Example:**

```objc
id<TSFemaleHealthInterface> femaleHealthInterface = (id<TSFemaleHealthInterface>)device;

[femaleHealthInterface unregisterFemaleHealthConfigDidChangedBlock];
TSLog(@"Unregistered female health config change notifications");
```

## Important Notes

1. The `femaleHealthConfig` parameter in `pushFemaleHealthConfig:completion:` must not be nil. Passing nil will result in an error.

2. The `reminderTimeMinutes` property represents minutes from midnight (00:00). Valid range is 0-1439. For example, 480 = 8:00 AM, 660 = 11:00 AM, 1380 = 23:00 PM.

3. The `menstrualCycleLength` and `menstrualPeriodDuration` properties define the expected menstrual pattern. The cycle length is typically 21-35 days, and period duration is typically 3-7 days.

4. The `lastPeriodStartTimestamp` should represent the start of the day (00:00:00) when the period began. Set it using the start of day timestamp.

5. The `pregnancyReminderType` property is only effective when `healthMode` is set to `TSFemaleHealthModePregnancy`. For other modes, this property is ignored.

6. Reminder switches use bitwise flags and can be combined. Use bitwise OR (|) to enable multiple reminders: `TSFemaleHealthReminderSwitchMenstruationStart | TSFemaleHealthReminderSwitchMenstruationEnd`.

7. All reminder switches have fixed trigger times at 8:00 AM on their respective trigger dates.

8. The `reminderSwitches` property is not supported by all projects. Check your project's capabilities before relying on this feature.

9. To stop receiving female health configuration change notifications, call `unregisterFemaleHealthConfigDidChangedBlock` or pass nil to `registerFemaleHealthConfigDidChangedBlock:`.

10. Device must support female health features and be connected before calling any methods. Check device capabilities before using this interface.