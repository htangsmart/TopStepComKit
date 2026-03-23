---
sidebar_position: 4
title: Prayers
---

# TSPrayers Module

The TSPrayers module provides comprehensive prayer functionality management for connected watch devices. It enables developers to configure prayer settings, manage prayer time reminders, set prayer times for multiple days, and monitor prayer configuration changes in real-time.

## Prerequisites

- Connected watch device with prayer feature support
- Valid `TSPrayersInterface` protocol implementation
- Prayer feature installed on the device (verify using `checkIfPrayerIsInstalled:`)
- Proper permissions and device connectivity established

## Data Models

### TSPrayerConfigs

Prayer configuration model representing prayer settings including master switch and individual prayer time reminder switches.

| Property | Type | Description |
|----------|------|-------------|
| `prayerEnable` | `BOOL` | Master switch for the prayer feature. When NO, all prayer reminders are disabled regardless of individual switches. When YES, individual prayer time switches take effect. |
| `fajrReminderEnable` | `BOOL` | Enable/disable Fajr (dawn) prayer reminder. Only effective when `prayerEnable` is YES. |
| `sunriseReminderEnable` | `BOOL` | Enable/disable sunrise reminder. Optional property, may not be supported by all projects. Only effective when `prayerEnable` is YES. |
| `dhuhrReminderEnable` | `BOOL` | Enable/disable Dhuhr (noon) prayer reminder. Only effective when `prayerEnable` is YES. |
| `asrReminderEnable` | `BOOL` | Enable/disable Asr (afternoon) prayer reminder. Only effective when `prayerEnable` is YES. |
| `sunsetReminderEnable` | `BOOL` | Enable/disable sunset reminder. Optional property, may not be supported by all projects. Only effective when `prayerEnable` is YES. |
| `maghribReminderEnable` | `BOOL` | Enable/disable Maghrib (sunset prayer) reminder. Only effective when `prayerEnable` is YES. |
| `ishabReminderEnable` | `BOOL` | Enable/disable Isha (night prayer) reminder. Only effective when `prayerEnable` is YES. |

### TSPrayerTimes

Prayer times model representing prayer times for a specific day with minute offsets from midnight.

| Property | Type | Description |
|----------|------|-------------|
| `dayTimestamp` | `NSTimeInterval` | Unix timestamp representing 00:00:00 of the day. Used as the base timestamp for all prayer time offset calculations. |
| `fajrMinutesOffset` | `NSInteger` | Fajr prayer time offset in minutes from midnight. For example, 330 for 5:30 AM. |
| `sunriseMinutesOffset` | `NSInteger` | Sunrise time offset in minutes from midnight. For example, 360 for 6:00 AM. Optional, may not be supported by all projects. |
| `dhuhrMinutesOffset` | `NSInteger` | Dhuhr prayer time offset in minutes from midnight. For example, 735 for 12:15 PM. |
| `asrMinutesOffset` | `NSInteger` | Asr prayer time offset in minutes from midnight. For example, 945 for 3:45 PM. |
| `sunsetMinutesOffset` | `NSInteger` | Sunset time offset in minutes from midnight. For example, 1110 for 6:30 PM. Optional, may not be supported by all projects. |
| `maghribMinutesOffset` | `NSInteger` | Maghrib prayer time offset in minutes from midnight. For example, 1100 for 6:20 PM. |
| `ishaMinutesOffset` | `NSInteger` | Isha prayer time offset in minutes from midnight. For example, 1200 for 8:00 PM. |

## Enumerations

### TSPrayerReminderSwitch

Prayer reminder switch enumeration defining switch types for different prayer times.

| Value | Description |
|-------|-------------|
| `TSPrayerReminderSwitchMain` | Master switch controlling whether the prayer reminder feature is enabled overall. |
| `TSPrayerReminderSwitchFajr` | Fajr (dawn prayer) reminder switch, active before sunrise. |
| `TSPrayerReminderSwitchSunrise` | Sunrise reminder switch. Optional, may not be supported by all projects. |
| `TSPrayerReminderSwitchDhuhr` | Dhuhr (noon prayer) reminder switch, active after sun passes zenith. |
| `TSPrayerReminderSwitchAsr` | Asr (afternoon prayer) reminder switch, active in late afternoon. |
| `TSPrayerReminderSwitchSunset` | Sunset reminder switch. Optional, may not be supported by all projects. |
| `TSPrayerReminderSwitchMaghrib` | Maghrib (sunset prayer) reminder switch, active just after sunset. |
| `TSPrayerReminderSwitchIsha` | Isha (night prayer) reminder switch, active after twilight disappears. |

## Callback Types

### TSPrayerConfigDidChangedBlock

Callback block triggered when prayer configuration changes on the device.

```objc
typedef void(^TSPrayerConfigDidChangedBlock)(TSPrayerConfigs * _Nullable prayerConfig, NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `prayerConfig` | `TSPrayerConfigs *` | Updated prayer configuration model. Nil if error occurred. |
| `error` | `NSError *` | Error information. Nil when successful. |

## API Reference

### Check if prayer feature is installed on the device

Verifies whether the prayer feature is installed and available on the connected watch device.

```objc
- (void)checkIfPrayerIsInstalled:(void (^)(BOOL isInstalled, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(BOOL, NSError *)` | Callback block with installation status and error information. |

**Code Example:**

```objc
id<TSPrayersInterface> prayersInterface = /* obtained interface */;

[prayersInterface checkIfPrayerIsInstalled:^(BOOL isInstalled, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to check prayer installation: %@", error.localizedDescription);
        return;
    }
    
    if (isInstalled) {
        TSLog(@"Prayer feature is installed on the device");
    } else {
        TSLog(@"Prayer feature is not installed on the device");
    }
}];
```

### Get prayer configuration from device

Retrieves the current prayer configuration from the connected device.

```objc
- (void)getPrayerConfigCompletion:(void(^)(TSPrayerConfigs * _Nullable prayerConfig, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSPrayerConfigs *, NSError *)` | Callback block returning prayer configuration and error information. |

**Code Example:**

```objc
id<TSPrayersInterface> prayersInterface = /* obtained interface */;

[prayersInterface getPrayerConfigCompletion:^(TSPrayerConfigs * _Nullable prayerConfig, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get prayer configuration: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Prayer enabled: %@", prayerConfig.prayerEnable ? @"YES" : @"NO");
    TSLog(@"Fajr reminder enabled: %@", prayerConfig.fajrReminderEnable ? @"YES" : @"NO");
    TSLog(@"Dhuhr reminder enabled: %@", prayerConfig.dhuhrReminderEnable ? @"YES" : @"NO");
    TSLog(@"Asr reminder enabled: %@", prayerConfig.asrReminderEnable ? @"YES" : @"NO");
    TSLog(@"Maghrib reminder enabled: %@", prayerConfig.maghribReminderEnable ? @"YES" : @"NO");
    TSLog(@"Isha reminder enabled: %@", prayerConfig.ishabReminderEnable ? @"YES" : @"NO");
}];
```

### Set prayer configuration to device

Sends prayer configuration to the connected device, replacing existing settings.

```objc
- (void)setPrayerConfig:(TSPrayerConfigs * _Nonnull)prayerConfig
             completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `prayerConfig` | `TSPrayerConfigs *` | Prayer configuration to be set. Must not be nil. |
| `completion` | `TSCompletionBlock` | Callback block executed after operation completes. |

**Code Example:**

```objc
id<TSPrayersInterface> prayersInterface = /* obtained interface */;

TSPrayerConfigs *config = [[TSPrayerConfigs alloc] init];
config.prayerEnable = YES;
config.fajrReminderEnable = YES;
config.dhuhrReminderEnable = YES;
config.asrReminderEnable = YES;
config.maghribReminderEnable = YES;
config.ishabReminderEnable = YES;
config.sunriseReminderEnable = NO;  // Optional, not all projects support
config.sunsetReminderEnable = NO;   // Optional, not all projects support

[prayersInterface setPrayerConfig:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set prayer configuration: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Prayer configuration set successfully");
}];
```

### Set reminder switch for a specific prayer type

Enables or disables reminder for a specific prayer reminder switch type without affecting others.

```objc
- (void)setPrayerReminderEnabled:(TSPrayerReminderSwitch)reminderSwitch
                         enabled:(BOOL)enabled
                      completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `reminderSwitch` | `TSPrayerReminderSwitch` | Prayer reminder switch type to configure (Main, Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, or Isha). |
| `enabled` | `BOOL` | YES to enable the reminder, NO to disable. |
| `completion` | `TSCompletionBlock` | Callback block executed after operation completes. |

**Code Example:**

```objc
id<TSPrayersInterface> prayersInterface = /* obtained interface */;

// Enable Fajr reminder
[prayersInterface setPrayerReminderEnabled:TSPrayerReminderSwitchFajr
                                   enabled:YES
                                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to enable Fajr reminder: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Fajr reminder enabled successfully");
}];

// Disable Dhuhr reminder
[prayersInterface setPrayerReminderEnabled:TSPrayerReminderSwitchDhuhr
                                   enabled:NO
                                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to disable Dhuhr reminder: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Dhuhr reminder disabled successfully");
}];
```

### Set prayer times to device

Sets prayer times for 7 days (today plus next 6 days) to the connected device.

```objc
- (void)setPrayerTimes:(NSArray<TSPrayerTimes *> * _Nonnull)prayerTimes
            completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `prayerTimes` | `NSArray<TSPrayerTimes *> *` | Array of 7 prayer time objects. Index 0: today, Index 1-6: next 6 days. Must not be nil and must contain exactly 7 elements. |
| `completion` | `TSCompletionBlock` | Callback block executed after operation completes. |

**Code Example:**

```objc
id<TSPrayersInterface> prayersInterface = /* obtained interface */;

NSMutableArray<TSPrayerTimes *> *prayerTimesArray = [NSMutableArray arrayWithCapacity:7];

// Create prayer times for 7 days
for (int i = 0; i < 7; i++) {
    TSPrayerTimes *prayerTimes = [[TSPrayerTimes alloc] init];
    
    // Set day timestamp (00:00:00 of each day)
    NSDate *dayDate = [NSDate dateWithTimeIntervalSinceNow:(i * 24 * 3600)];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                               fromDate:dayDate];
    NSDate *startOfDay = [calendar dateFromComponents:components];
    prayerTimes.dayTimestamp = [startOfDay timeIntervalSince1970];
    
    // Set prayer time offsets (in minutes from midnight)
    prayerTimes.fajrMinutesOffset = 330;      // 5:30 AM
    prayerTimes.sunriseMinutesOffset = 360;   // 6:00 AM (optional)
    prayerTimes.dhuhrMinutesOffset = 735;     // 12:15 PM
    prayerTimes.asrMinutesOffset = 945;       // 3:45 PM
    prayerTimes.sunsetMinutesOffset = 1110;   // 6:30 PM (optional)
    prayerTimes.maghribMinutesOffset = 1100;  // 6:20 PM
    prayerTimes.ishaMinutesOffset = 1200;     // 8:00 PM
    
    [prayerTimesArray addObject:prayerTimes];
}

[prayersInterface setPrayerTimes:prayerTimesArray completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set prayer times: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Prayer times set successfully for 7 days");
}];
```

### Register for prayer configuration change notifications

Registers a listener to monitor prayer configuration changes on the device.

```objc
- (void)registerPrayerConfigDidChangedBlock:(nullable TSPrayerConfigDidChangedBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSPrayerConfigDidChangedBlock` | Callback block triggered when prayer configuration changes. Pass nil to unregister. |

**Code Example:**

```objc
id<TSPrayersInterface> prayersInterface = /* obtained interface */;

[prayersInterface registerPrayerConfigDidChangedBlock:^(TSPrayerConfigs * _Nullable prayerConfig, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Prayer configuration change notification error: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Prayer configuration changed on device:");
    TSLog(@"Prayer enabled: %@", prayerConfig.prayerEnable ? @"YES" : @"NO");
    TSLog(@"Fajr reminder: %@", prayerConfig.fajrReminderEnable ? @"YES" : @"NO");
    TSLog(@"Dhuhr reminder: %@", prayerConfig.dhuhrReminderEnable ? @"YES" : @"NO");
    TSLog(@"Asr reminder: %@", prayerConfig.asrReminderEnable ? @"YES" : @"NO");
    TSLog(@"Maghrib reminder: %@", prayerConfig.maghribReminderEnable ? @"YES" : @"NO");
    TSLog(@"Isha reminder: %@", prayerConfig.ishabReminderEnable ? @"YES" : @"NO");
}];
```

### Unregister prayer configuration change notifications

Removes the registered prayer configuration change listener.

```objc
- (void)unregisterPrayerConfigDidChangedBlock;
```

**Code Example:**

```objc
id<TSPrayersInterface> prayersInterface = /* obtained interface */;

[prayersInterface unregisterPrayerConfigDidChangedBlock];

TSLog(@"Prayer configuration change notifications unregistered");
```

## Important Notes

1. **Master Switch Dependency** — Individual prayer reminder settings (Fajr, Dhuhr, Asr, Maghrib, Isha) are only effective when `prayerEnable` is set to YES. If `prayerEnable` is NO, all reminders are disabled regardless of individual switch states.

2. **Optional Properties** — Sunrise and Sunset properties (`sunriseReminderEnable`, `sunsetReminderEnable`, `sunriseMinutesOffset`, `sunsetMinutesOffset`) are optional and may not be supported by all projects. If not supported, these settings will be silently ignored by the device.

3. **Prayer Times Array Requirements** — When setting prayer times using `setPrayerTimes:completion:`, the array must contain exactly 7 elements representing today and the next 6 days. Arrays with fewer or more elements will cause the operation to fail.

4. **Minute Offset Calculation** — Prayer time offsets are calculated in minutes from midnight (00:00:00). For example, 5:30 AM = 5 × 60 + 30 = 330 minutes, and 8:00 PM = 20 × 60 + 0 = 1200 minutes.

5. **Day Timestamp Requirement** — The `dayTimestamp` property in `TSPrayerTimes` must represent midnight (00:00:00) of the intended day. Use calendar methods to ensure accurate timestamp calculation.

6. **Callback Thread Execution** — All completion callbacks are executed on the main thread. Any UI updates should be performed directly in the callback without additional thread switching.

7. **Configuration Change Listener** — To stop receiving prayer configuration change notifications, call `unregisterPrayerConfigDidChangedBlock` or pass nil to `registerPrayerConfigDidChangedBlock:`. Only one listener can be active at a time; registering a new listener will replace the previous one.

8. **Error Handling** — Always check the error parameter in callbacks. A non-nil error indicates operation failure. Common error scenarios include device disconnection, unsupported features, or invalid configuration data.

9. **Individual Switch Updates** — Use `setPrayerReminderEnabled:enabled:completion:` for updating individual prayer reminder switches. This method retrieves current configuration, modifies only the specified switch, and saves back to the device, avoiding conflicts with other settings.

10. **Installation Check** — Before performing any prayer-related operations, verify that the prayer feature is installed on the device using `checkIfPrayerIsInstalled:` to avoid failures on unsupported devices.