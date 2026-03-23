---
sidebar_position: 2
title: HeartRate
---

# HeartRate Module

The HeartRate module provides comprehensive heart rate measurement and monitoring capabilities including real-time measurement, automatic monitoring, historical data synchronization, resting heart rate analysis, and heart rate alert monitoring. It supports manual user-initiated measurements, continuous automatic background monitoring, and retrieval of both raw and daily aggregated heart rate data.

## Prerequisites

- The iOS device must be paired and connected with a compatible wearable device that supports heart rate measurement
- The wearable device must have active Bluetooth connection
- For automatic monitoring features, the device must support automatic heart rate monitoring capability
- For heart rate alerts, the device must support heart rate alert monitoring capability
- For resting heart rate data, the device must support resting heart rate monitoring capability

## Data Models

### TSHRValueItem

A single heart rate measurement data point.

| Property | Type | Description |
|----------|------|-------------|
| `hrValue` | `UInt8` | The heart rate value measured in beats per minute (BPM). |
| `isUserInitiated` | `BOOL` | Indicates whether the measurement was initiated by the user (YES) or automatically monitored (NO). |
| `timestamp` | `NSTimeInterval` | Inherited from TSHealthValueItem; timestamp in seconds since 1970. |

### TSHRDailyModel

Daily aggregated heart rate data for a single day.

| Property | Type | Description |
|----------|------|-------------|
| `maxHRItem` | `TSHRValueItem *` | The heart rate item representing the highest measurement for the day. |
| `minHRItem` | `TSHRValueItem *` | The heart rate item representing the lowest measurement for the day. |
| `restingItems` | `NSArray<TSHRValueItem *> *` | Array of resting heart rate items for this day, ordered by time ascending. |
| `manualItems` | `NSArray<TSHRValueItem *> *` | Array of user-initiated heart rate measurements, ordered by time ascending. |
| `autoItems` | `NSArray<TSHRValueItem *> *` | Array of automatically monitored heart rate items, ordered by time ascending. |

#### TSHRDailyModel Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `maxBPM` | `UInt16` | Convenience value derived from maxHRItem.hrValue; returns 0 if maxHRItem is nil. |
| `minBPM` | `UInt16` | Convenience value derived from minHRItem.hrValue; returns 0 if minHRItem is nil. |
| `allMeasuredItems` | `NSArray<TSHRValueItem *> *` | Returns a combined array of manual and auto items, sorted by time. |

## Enumerations

None defined in this module.

## Callback Types

### Measurement Start Handler

```objc
void (^)(BOOL success, NSError *error)
```

Called when heart rate measurement starts or fails to start.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the measurement started successfully. |
| `error` | `NSError *` | Error information if failed; nil if successful. |

### Real-time Measurement Data Handler

```objc
void (^)(TSHRValueItem *data, NSError *error)
```

Receives real-time measurement data during measurement.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `TSHRValueItem *` | Real-time heart rate measurement data; nil if error occurs. |
| `error` | `NSError *` | Error information if data reception fails; nil if successful. |

### Measurement End Handler

```objc
void (^)(BOOL success, NSError *error)
```

Called when measurement ends (normally or abnormally).

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the measurement ended normally (YES) or was interrupted (NO). |
| `error` | `NSError *` | Error information if measurement ended abnormally; nil if normal end. |

### Configuration Completion Handler

```objc
void (^)(TSAutoMonitorHRConfigs *configuration, NSError *error)
```

Provides the current automatic heart rate monitoring configuration.

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorHRConfigs *` | The current automatic monitoring configuration; nil if error occurs. |
| `error` | `NSError *` | Error information if failed; nil if successful. |

### Raw Data Completion Handler

```objc
void (^)(NSArray<TSHRValueItem *> *hrItems, NSError *error)
```

Provides synchronized raw heart rate measurement items.

| Parameter | Type | Description |
|-----------|------|-------------|
| `hrItems` | `NSArray<TSHRValueItem *> *` | Array of synchronized raw heart rate items; nil if error occurs. |
| `error` | `NSError *` | Error information if synchronization failed; nil if successful. |

### Daily Data Completion Handler

```objc
void (^)(NSArray<TSHRDailyModel *> *dailyModels, NSError *error)
```

Provides synchronized daily aggregated heart rate data.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dailyModels` | `NSArray<TSHRDailyModel *> *` | Array of synchronized daily models; nil if error occurs. |
| `error` | `NSError *` | Error information if synchronization failed; nil if successful. |

### Resting Heart Rate Completion Handler

```objc
void (^)(TSHRValueItem *todayRestingHR, NSError *error)
```

Provides today's resting heart rate data.

| Parameter | Type | Description |
|-----------|------|-------------|
| `todayRestingHR` | `TSHRValueItem *` | Today's resting heart rate data; nil if error occurs. |
| `error` | `NSError *` | Error information if synchronization failed; nil if successful. |

## API Reference

### Check heart rate alert support

Determines whether the connected device supports heart rate alert monitoring capabilities.

```objc
- (BOOL)isSupportHeartRateAlert;
```

**`Parameters**`

None

**Return `Value**`

| Type | Description |
|------|-------------|
| `BOOL` | YES if the device supports heart rate alert monitoring; NO otherwise. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
if ([hrInterface isSupportHeartRateAlert]) {
    TSLog(@"Device supports heart rate alert monitoring");
} else {
    TSLog(@"Device does not support heart rate alert monitoring");
}
```

### Check enhanced monitoring support

Determines whether the connected device supports enhanced heart rate monitoring with higher precision and frequency.

```objc
- (BOOL)isSupportEnhancedMonitoring;
```

**`Parameters**`

None

**Return `Value**`

| Type | Description |
|------|-------------|
| `BOOL` | YES if the device supports enhanced heart rate monitoring; NO otherwise. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
if ([hrInterface isSupportEnhancedMonitoring]) {
    TSLog(@"Device supports enhanced heart rate monitoring");
} else {
    TSLog(@"Device does not support enhanced monitoring");
}
```

### Check manual measurement support

Determines whether the device supports user-initiated manual heart rate measurements.

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**`Parameters**`

None

**Return `Value**`

| Type | Description |
|------|-------------|
| `BOOL` | YES if the device supports manual heart rate measurement; NO otherwise. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
if ([hrInterface isSupportActivityMeasureByUser]) {
    TSLog(@"Device supports manual heart rate measurement");
}
```

### Start heart rate measurement

Begins a heart rate measurement session with specified parameters and receives real-time measurement data through callbacks.

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSHRValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `measureParam` | `TSActivityMeasureParam *` | Parameters for the measurement activity including duration and mode. |
| `startHandler` | `void (^)(BOOL, NSError *)` | Block called when measurement starts or fails; receives success status and error if any. |
| `dataHandler` | `void (^)(TSHRValueItem *, NSError *)` | Block called when real-time measurement data is received; receives data item and error if any. |
| `endHandler` | `void (^)(BOOL, NSError *)` | Block called when measurement ends; receives completion status and error if any. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.duration = 300; // 5 minutes

[hrInterface startMeasureWithParam:param
                      startHandler:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Heart rate measurement started");
    } else {
        TSLog(@"Failed to start measurement: %@", error.localizedDescription);
    }
} dataHandler:^(TSHRValueItem *data, NSError *error) {
    if (data) {
        TSLog(@"Heart rate: %d BPM", data.hrValue);
    } else {
        TSLog(@"Data error: %@", error.localizedDescription);
    }
} endHandler:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Measurement completed successfully");
    } else {
        TSLog(@"Measurement ended abnormally: %@", error.localizedDescription);
    }
}];
```

### Stop heart rate measurement

Stops the currently ongoing heart rate measurement session.

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `completion` | `TSCompletionBlock` | Completion block called when measurement stops or fails; `TSCompletionBlock` is `void (^)(NSError *)`. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
[hrInterface stopMeasureCompletion:^(NSError *error) {
    if (!error) {
        TSLog(@"Heart rate measurement stopped");
    } else {
        TSLog(@"Failed to stop measurement: %@", error.localizedDescription);
    }
}];
```

### Check automatic monitoring support

Determines whether the device supports automatic background heart rate monitoring.

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**`Parameters**`

None

**Return `Value**`

| Type | Description |
|------|-------------|
| `BOOL` | YES if the device supports automatic heart rate monitoring; NO otherwise. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
if ([hrInterface isSupportAutomaticMonitoring]) {
    TSLog(@"Device supports automatic heart rate monitoring");
}
```

### Configure automatic monitoring

Sets up automatic heart rate monitoring configuration on the device.

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorHRConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `configuration` | `TSAutoMonitorHRConfigs *` | Configuration parameters for automatic heart rate monitoring. |
| `completion` | `TSCompletionBlock` | Completion block called when configuration is set; `TSCompletionBlock` is `void (^)(NSError *)`. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
TSAutoMonitorHRConfigs *config = [[TSAutoMonitorHRConfigs alloc] init];
config.enabled = YES;
config.interval = 10; // 10 minutes

[hrInterface pushAutoMonitorConfigs:config completion:^(NSError *error) {
    if (!error) {
        TSLog(@"Automatic monitoring configured successfully");
    } else {
        TSLog(@"Failed to configure: %@", error.localizedDescription);
    }
}];
```

### Fetch automatic monitoring configuration

Retrieves the current automatic heart rate monitoring configuration from the device.

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorHRConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorHRConfigs *, NSError *)` | Completion block with current configuration or error. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
[hrInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorHRConfigs *configuration, NSError *error) {
    if (configuration) {
        TSLog(@"Auto monitoring enabled: %@", configuration.enabled ? @"YES" : @"NO");
    } else {
        TSLog(@"Failed to fetch config: %@", error.localizedDescription);
    }
}];
```

### Synchronize raw heart rate data with time range

Synchronizes raw heart rate measurement data within a specified time range from the device.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable hrItems, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization as timestamp in seconds since 1970. |
| `endTime` | `NSTimeInterval` | End time for data synchronization as timestamp in seconds since 1970. |
| `completion` | `void (^)(NSArray *, NSError *)` | Completion block with synchronized raw heart rate items or error. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
NSTimeInterval sevenDaysAgo = now - (7 * 24 * 60 * 60);

[hrInterface syncRawDataFromStartTime:sevenDaysAgo endTime:now completion:^(NSArray<TSHRValueItem *> *hrItems, NSError *error) {
    if (hrItems) {
        TSLog(@"Synced %ld heart rate records", (long)hrItems.count);
        for (TSHRValueItem *item in hrItems) {
            TSLog(@"HR: %d BPM at %@", item.hrValue, [NSDate dateWithTimeIntervalSince1970:item.timestamp]);
        }
    } else {
        TSLog(@"Failed to sync data: %@", error.localizedDescription);
    }
}];
```

### Synchronize raw heart rate data from start time

Synchronizes raw heart rate measurement data from a specified start time until the current time.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable hrItems, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization as timestamp in seconds since 1970. |
| `completion` | `void (^)(NSArray *, NSError *)` | Completion block with synchronized raw heart rate items or error. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
NSTimeInterval oneDayAgo = [[NSDate date] timeIntervalSince1970] - (24 * 60 * 60);

[hrInterface syncRawDataFromStartTime:oneDayAgo completion:^(NSArray<TSHRValueItem *> *hrItems, NSError *error) {
    if (hrItems) {
        TSLog(@"Synced %ld heart rate records since yesterday", (long)hrItems.count);
    } else {
        TSLog(@"Failed to sync data: %@", error.localizedDescription);
    }
}];
```

### Synchronize daily heart rate data with time range

Synchronizes daily aggregated heart rate data within a specified time range. Time parameters are automatically normalized to day boundaries (00:00:00 to 23:59:59).

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSHRDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time normalized to 00:00:00 of the specified day; must be earlier than endTime. |
| `endTime` | `NSTimeInterval` | End time normalized to 23:59:59 of the specified day; must be later than startTime and not in the future. |
| `completion` | `void (^)(NSArray *, NSError *)` | Completion block with synchronized daily models or error. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
NSTimeInterval thirtyDaysAgo = now - (30 * 24 * 60 * 60);

[hrInterface syncDailyDataFromStartTime:thirtyDaysAgo endTime:now completion:^(NSArray<TSHRDailyModel *> *dailyModels, NSError *error) {
    if (dailyModels) {
        TSLog(@"Synced %ld days of heart rate data", (long)dailyModels.count);
        for (TSHRDailyModel *model in dailyModels) {
            TSLog(@"Date: %@, Max: %d BPM, Min: %d BPM", 
                  [NSDate dateWithTimeIntervalSince1970:model.timestamp],
                  model.maxBPM, model.minBPM);
        }
    } else {
        TSLog(@"Failed to sync daily data: %@", error.localizedDescription);
    }
}];
```

### Synchronize daily heart rate data from start time

Synchronizes daily aggregated heart rate data from a specified start time until the current time. Start time is automatically normalized to 00:00:00 of the specified day.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSHRDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time normalized to 00:00:00 of the specified day. |
| `completion` | `void (^)(NSArray *, NSError *)` | Completion block with synchronized daily models or error. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
NSTimeInterval oneWeekAgo = [[NSDate date] timeIntervalSince1970] - (7 * 24 * 60 * 60);

[hrInterface syncDailyDataFromStartTime:oneWeekAgo completion:^(NSArray<TSHRDailyModel *> *dailyModels, NSError *error) {
    if (dailyModels) {
        for (TSHRDailyModel *model in dailyModels) {
            TSLog(@"Manual measurements: %ld, Auto measurements: %ld, Resting measurements: %ld",
                  (long)model.manualItems.count, 
                  (long)model.autoItems.count, 
                  (long)model.restingItems.count);
        }
    } else {
        TSLog(@"Failed to sync daily data: %@", error.localizedDescription);
    }
}];
```

### Check resting heart rate support

Determines whether the device supports resting heart rate measurement and monitoring.

```objc
- (BOOL)isSupportRestingHeartRate;
```

**`Parameters**`

None

**Return `Value**`

| Type | Description |
|------|-------------|
| `BOOL` | YES if the device supports resting heart rate monitoring; NO otherwise. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
if ([hrInterface isSupportRestingHeartRate]) {
    TSLog(@"Device supports resting heart rate monitoring");
}
```

### Synchronize raw resting heart rate data with time range

Synchronizes raw resting heart rate measurement data within a specified time range from the device.

```objc
- (void)syncRawRestingHeartRateDataFromStartTime:(NSTimeInterval)startTime
                                         endTime:(NSTimeInterval)endTime
                                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable restingHRItems, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization as timestamp in seconds since 1970. |
| `endTime` | `NSTimeInterval` | End time for data synchronization as timestamp in seconds since 1970. |
| `completion` | `void (^)(NSArray *, NSError *)` | Completion block with synchronized resting heart rate items or error. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
NSTimeInterval fourteenDaysAgo = now - (14 * 24 * 60 * 60);

[hrInterface syncRawRestingHeartRateDataFromStartTime:fourteenDaysAgo 
                                              endTime:now 
                                           completion:^(NSArray<TSHRValueItem *> *restingHRItems, NSError *error) {
    if (restingHRItems) {
        TSLog(@"Synced %ld resting heart rate records", (long)restingHRItems.count);
        NSUInteger avgRHR = 0;
        for (TSHRValueItem *item in restingHRItems) {
            avgRHR += item.hrValue;
        }
        TSLog(@"Average resting HR: %lu BPM", (unsigned long)(avgRHR / restingHRItems.count));
    } else {
        TSLog(@"Failed to sync resting HR data: %@", error.localizedDescription);
    }
}];
```

### Synchronize raw resting heart rate data from start time

Synchronizes raw resting heart rate measurement data from a specified start time until the current time.

```objc
- (void)syncRawRestingHeartRateDataFromStartTime:(NSTimeInterval)startTime
                                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable restingHRItems, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization as timestamp in seconds since 1970. |
| `completion` | `void (^)(NSArray *, NSError *)` | Completion block with synchronized resting heart rate items or error. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
NSTimeInterval thirtySaysAgo = [[NSDate date] timeIntervalSince1970] - (30 * 24 * 60 * 60);

[hrInterface syncRawRestingHeartRateDataFromStartTime:thirtySaysAgo 
                                           completion:^(NSArray<TSHRValueItem *> *restingHRItems, NSError *error) {
    if (restingHRItems) {
        TSLog(@"Synced %ld resting heart rate records from past 30 days", (long)restingHRItems.count);
    } else {
        TSLog(@"Failed to sync resting HR data: %@", error.localizedDescription);
    }
}];
```

### Synchronize today's resting heart rate

Retrieves the current day's resting heart rate data from the device.

```objc
- (void)syncTodayRestingHeartRateDataWithCompletion:(nonnull void (^)(TSHRValueItem *_Nullable todayRestingHR, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSHRValueItem *, NSError *)` | Completion block with today's resting heart rate data or error. |

**Code `Example**`

```objc
id<TSHeartRateInterface> hrInterface = /* obtained interface */;
[hrInterface syncTodayRestingHeartRateDataWithCompletion:^(TSHRValueItem *todayRestingHR, NSError *error) {
    if (todayRestingHR) {
        TSLog(@"Today's resting heart rate: %d BPM", todayRestingHR.hrValue);
    } else if (error) {
        TSLog(@"Failed to sync today's resting HR: %@", error.localizedDescription);
    } else {
        TSLog(@"No resting heart rate data for today");
    }
}];
```

## Important Notes

1. All time parameters are in seconds since the Unix epoch (January 1, 1970) and must be valid `NSTimeInterval` values.

2. For `syncDailyDataFromStartTime:endTime:completion:`, both start and end times are automatically normalized to day boundaries (00:00:00 and 23:59:59 respectively); the end time must not be in the future.

3. Heart rate measurements are returned in beats per minute (BPM) as `UInt8` values in `TSHRValueItem` objects; typical healthy resting heart rate ranges from 60 to 100 BPM.

4. The `startHandler` callback in `startMeasureWithParam:startHandler:dataHandler:endHandler:` indicates whether the measurement was initiated on the device; the `dataHandler` receives real-time updates and may be called multiple times; the `endHandler` distinguishes between normal completion (success=YES) and interruption (success=NO).

5. Manual measurements (user-initiated) and automatic measurements (background monitoring) are distinguished by the `isUserInitiated` property in `TSHRValueItem`; daily models separate these into `manualItems` and `autoItems` arrays.

6. Resting heart rate data is typically measured during sleep or complete rest periods and is a key indicator of cardiovascular fitness; this data is separated from normal heart rate measurements in dedicated synchronization methods.

7. Daily data synchronization returns an ordered array with each `TSHRDailyModel` representing exactly one calendar day; use `allMeasuredItems` method to get combined manual and automatic measurements for a day.

8. All completion handlers are called on the main thread; avoid blocking operations within callback blocks to maintain UI responsiveness.

9. Device capability checks (`isSupportHeartRateAlert`, `isSupportEnhancedMonitoring`, etc.) should be performed before attempting corresponding operations; attempting unsupported operations will result in errors.

10. Automatic monitoring configuration must be pushed to the device using `pushAutoMonitorConfigs:completion:` after changes; use `fetchAutoMonitorConfigsWithCompletion:` to verify the current configuration on the device.