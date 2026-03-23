---
sidebar_position: 5
title: BloodPressure
---

# Blood Pressure

This module provides comprehensive blood pressure measurement and monitoring capabilities, including manual user-initiated measurements, automatic background monitoring, and historical data synchronization. Blood pressure readings consist of systolic (high) and diastolic (low) values, which are critical indicators of cardiovascular health.

## Prerequisites

- Device must support blood pressure measurement functionality
- User must have granted necessary permissions for health data access
- For automatic monitoring, device must support automatic blood pressure monitoring feature
- Measurement parameters must be properly configured before initiating measurements

## Data Models

### TSBPValueItem

Single blood pressure measurement record containing systolic and diastolic values.

| Property | Type | Description |
|----------|------|-------------|
| `systolic` | `UInt8` | Systolic blood pressure value measured in mmHg |
| `diastolic` | `UInt8` | Diastolic blood pressure value measured in mmHg |
| `isUserInitiated` | `BOOL` | Whether the measurement was initiated by the user (YES) or automatically monitored (NO) |

### TSBPDailyModel

Aggregated daily blood pressure data containing minimum/maximum readings and measurement arrays.

| Property | Type | Description |
|----------|------|-------------|
| `maxSystolicItem` | `TSBPValueItem *` | The measurement item with the highest systolic pressure of the day |
| `minSystolicItem` | `TSBPValueItem *` | The measurement item with the lowest systolic pressure of the day |
| `maxDiastolicItem` | `TSBPValueItem *` | The measurement item with the highest diastolic pressure of the day |
| `minDiastolicItem` | `TSBPValueItem *` | The measurement item with the lowest diastolic pressure of the day |
| `manualItems` | `NSArray<TSBPValueItem *> *` | Array of user-initiated blood pressure measurements, ordered by time ascending |
| `autoItems` | `NSArray<TSBPValueItem *> *` | Array of automatically monitored blood pressure items, ordered by time ascending |

#### TSBPDailyModel Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `maxSystolic` | `UInt8` | Convenience getter for maximum systolic value; returns 0 if maxSystolicItem is nil |
| `minSystolic` | `UInt8` | Convenience getter for minimum systolic value; returns 0 if minSystolicItem is nil |
| `maxDiastolic` | `UInt8` | Convenience getter for maximum diastolic value; returns 0 if maxDiastolicItem is nil |
| `minDiastolic` | `UInt8` | Convenience getter for minimum diastolic value; returns 0 if minDiastolicItem is nil |
| `allMeasuredItems` | `NSArray<TSBPValueItem *> *` | Combined array of manual and auto items, sorted by time |

## Enumerations

None defined in this module.

## Callback Types

### TSCompletionBlock

```objc
typedef void (^TSCompletionBlock)(NSError *_Nullable error);
```

Generic completion handler called when an asynchronous operation completes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError *` | Error information if operation failed; nil if successful |

### Start Handler

```objc
void (^)(BOOL success, NSError * _Nullable error)
```

Called when measurement starts or fails to start.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | YES if measurement started successfully, NO otherwise |
| `error` | `NSError *` | Error information if failed; nil if successful |

### Data Handler

```objc
void (^)(TSBPValueItem * _Nullable data, NSError * _Nullable error)
```

Receives real-time measurement data during active measurement.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `TSBPValueItem *` | Real-time blood pressure measurement data; nil if error occurs |
| `error` | `NSError *` | Error information if data reception fails; nil if successful |

### End Handler

```objc
void (^)(BOOL success, NSError * _Nullable error)
```

Called when measurement ends normally or abnormally.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | YES if measurement ended normally; NO if interrupted |
| `error` | `NSError *` | Error information if measurement ended abnormally; nil if normal end |

### Fetch Auto Monitor Configs Completion

```objc
void (^)(TSAutoMonitorBPConfigs *_Nullable configuration, NSError *_Nullable error)
```

Returns current automatic monitoring configuration or error.

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorBPConfigs *` | Current automatic monitoring configuration; nil if error |
| `error` | `NSError *` | Error information if failed; nil if successful |

### Sync Raw Data Completion

```objc
void (^)(NSArray<TSBPValueItem *> *_Nullable bpItems, NSError *_Nullable error)
```

Returns synchronized raw blood pressure measurements or error.

| Parameter | Type | Description |
|-----------|------|-------------|
| `bpItems` | `NSArray<TSBPValueItem *> *` | Array of synchronized blood pressure items; nil if error |
| `error` | `NSError *` | Error information if synchronization failed; nil if successful |

### Sync Daily Data Completion

```objc
void (^)(NSArray<TSBPDailyModel *> *_Nullable dailyModels, NSError *_Nullable error)
```

Returns synchronized daily aggregated blood pressure data or error.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dailyModels` | `NSArray<TSBPDailyModel *> *` | Array of daily models; each represents one day's aggregated data; nil if error |
| `error` | `NSError *` | Error information if synchronization failed; nil if successful |

## API Reference

### Check Manual Blood Pressure Measurement Support

Determine whether the device supports user-initiated blood pressure measurements.

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**`Returns**`

| Type | Description |
|------|-------------|
| `BOOL` | YES if the device supports manual blood pressure measurement, NO otherwise |

**`Example**`

```objc
id<TSBloodPressureInterface> bpInterface = /* obtained from TSHealthDataManager */;

if ([bpInterface isSupportActivityMeasureByUser]) {
    TSLog(@"Device supports manual blood pressure measurement");
} else {
    TSLog(@"Device does not support manual blood pressure measurement");
}
```

### Start Blood Pressure Measurement

Initiate a blood pressure measurement with specified parameters and receive real-time data through callbacks.

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSBPValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `measureParam` | `TSActivityMeasureParam *` | Configuration parameters for the measurement activity |
| `startHandler` | `void (^)(BOOL, NSError *)` | Called when measurement starts or fails; receives success status and optional error |
| `dataHandler` | `void (^)(TSBPValueItem *, NSError *)` | Invoked repeatedly during measurement with real-time data or error |
| `endHandler` | `void (^)(BOOL, NSError *)` | Called when measurement completes normally or abnormally |

**`Example**`

```objc
id<TSBloodPressureInterface> bpInterface = /* obtained from TSHealthDataManager */;

TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.duration = 30; // 30 seconds measurement duration

[bpInterface startMeasureWithParam:param
                      startHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Blood pressure measurement started successfully");
    } else {
        TSLog(@"Failed to start measurement: %@", error.localizedDescription);
    }
} dataHandler:^(TSBPValueItem * _Nullable data, NSError * _Nullable error) {
    if (data) {
        TSLog(@"Real-time data - Systolic: %d, Diastolic: %d", 
              data.systolic, data.diastolic);
    } else if (error) {
        TSLog(@"Error receiving data: %@", error.localizedDescription);
    }
} endHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Measurement completed normally");
    } else {
        TSLog(@"Measurement interrupted or failed: %@", 
              error.localizedDescription);
    }
}];
```

### Stop Blood Pressure Measurement

Terminate an ongoing blood pressure measurement.

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `completion` | `TSCompletionBlock` | Block called when measurement stops or fails to stop; receives optional error |

**`Example**`

```objc
id<TSBloodPressureInterface> bpInterface = /* obtained from TSHealthDataManager */;

[bpInterface stopMeasureCompletion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"Measurement stopped successfully");
    } else {
        TSLog(@"Failed to stop measurement: %@", error.localizedDescription);
    }
}];
```

### Check Automatic Monitoring Support

Determine whether the device supports automatic background blood pressure monitoring.

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**`Returns**`

| Type | Description |
|------|-------------|
| `BOOL` | YES if the device supports automatic blood pressure monitoring, NO otherwise |

**`Example**`

```objc
id<TSBloodPressureInterface> bpInterface = /* obtained from TSHealthDataManager */;

if ([bpInterface isSupportAutomaticMonitoring]) {
    TSLog(@"Device supports automatic blood pressure monitoring");
} else {
    TSLog(@"Device does not support automatic blood pressure monitoring");
}
```

### Configure Automatic Blood Pressure Monitoring

Set up automatic blood pressure monitoring parameters on the device.

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorBPConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `configuration` | `TSAutoMonitorBPConfigs *` | Configuration parameters for automatic blood pressure monitoring |
| `completion` | `TSCompletionBlock` | Block called when configuration is set or fails; receives optional error |

**`Example**`

```objc
id<TSBloodPressureInterface> bpInterface = /* obtained from TSHealthDataManager */;

TSAutoMonitorBPConfigs *config = [[TSAutoMonitorBPConfigs alloc] init];
config.enabled = YES;
config.interval = 60; // Monitor every 60 minutes

[bpInterface pushAutoMonitorConfigs:config
                         completion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"Automatic monitoring configured successfully");
    } else {
        TSLog(@"Failed to configure monitoring: %@", 
              error.localizedDescription);
    }
}];
```

### Fetch Current Automatic Monitoring Configuration

Retrieve the current automatic blood pressure monitoring configuration from the device.

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorBPConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorBPConfigs *, NSError *)` | Block called with current configuration or error |

**`Example**`

```objc
id<TSBloodPressureInterface> bpInterface = /* obtained from TSHealthDataManager */;

[bpInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorBPConfigs * _Nullable config, NSError * _Nullable error) {
    if (config) {
        TSLog(@"Current monitoring enabled: %d, interval: %ld minutes",
              config.enabled, (long)config.interval);
    } else {
        TSLog(@"Failed to fetch configuration: %@", 
              error.localizedDescription);
    }
}];
```

### Synchronize Raw Blood Pressure Data with Time Range

Retrieve raw blood pressure measurement records within a specified time range.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSBPValueItem *> *_Nullable bpItems, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for synchronization (seconds since 1970) |
| `endTime` | `NSTimeInterval` | End time for synchronization (seconds since 1970) |
| `completion` | `void (^)(NSArray<TSBPValueItem *> *, NSError *)` | Block called with synchronized items or error |

**`Example**`

```objc
id<TSBloodPressureInterface> bpInterface = /* obtained from TSHealthDataManager */;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-86400]; // 24 hours ago
NSDate *endDate = [NSDate date]; // Now

[bpInterface syncRawDataFromStartTime:[startDate timeIntervalSince1970]
                              endTime:[endDate timeIntervalSince1970]
                           completion:^(NSArray<TSBPValueItem *> * _Nullable items, NSError * _Nullable error) {
    if (items) {
        TSLog(@"Synchronized %lu blood pressure measurements", 
              (unsigned long)items.count);
        for (TSBPValueItem *item in items) {
            TSLog(@"Systolic: %d, Diastolic: %d, User Initiated: %d",
                  item.systolic, item.diastolic, item.isUserInitiated);
        }
    } else {
        TSLog(@"Synchronization failed: %@", error.localizedDescription);
    }
}];
```

### Synchronize Raw Blood Pressure Data from Start Time to Now

Retrieve raw blood pressure measurement records from a specified start time to the current time.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSBPValueItem *> *_Nullable bpItems, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for synchronization (seconds since 1970) |
| `completion` | `void (^)(NSArray<TSBPValueItem *> *, NSError *)` | Block called with synchronized items or error |

**`Example**`

```objc
id<TSBloodPressureInterface> bpInterface = /* obtained from TSHealthDataManager */;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-604800]; // 7 days ago

[bpInterface syncRawDataFromStartTime:[startDate timeIntervalSince1970]
                           completion:^(NSArray<TSBPValueItem *> * _Nullable items, NSError * _Nullable error) {
    if (items) {
        TSLog(@"Synchronized %lu measurements since start date", 
              (unsigned long)items.count);
    } else {
        TSLog(@"Synchronization failed: %@", error.localizedDescription);
    }
}];
```

### Synchronize Daily Blood Pressure Data with Time Range

Retrieve aggregated daily blood pressure data within a specified time range.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSBPDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time (seconds since 1970); automatically normalized to 00:00:00 of specified day; must be earlier than endTime |
| `endTime` | `NSTimeInterval` | End time (seconds since 1970); automatically normalized to 23:59:59 of specified day; must be later than startTime and not in future |
| `completion` | `void (^)(NSArray<TSBPDailyModel *> *, NSError *)` | Block called with daily models (one per day) or error |

**`Example**`

```objc
id<TSBloodPressureInterface> bpInterface = /* obtained from TSHealthDataManager */;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-2592000]; // 30 days ago
NSDate *endDate = [NSDate date]; // Now

[bpInterface syncDailyDataFromStartTime:[startDate timeIntervalSince1970]
                                endTime:[endDate timeIntervalSince1970]
                             completion:^(NSArray<TSBPDailyModel *> * _Nullable models, NSError * _Nullable error) {
    if (models) {
        TSLog(@"Synchronized data for %lu days", (unsigned long)models.count);
        for (TSBPDailyModel *model in models) {
            TSLog(@"Date: %@, Max Systolic: %d, Min Systolic: %d, "
                  @"Max Diastolic: %d, Min Diastolic: %d, "
                  @"Manual count: %lu, Auto count: %lu",
                  [NSDateFormatter localizedStringFromDate:model.date
                                                 dateStyle:NSDateFormatterMediumStyle
                                                 timeStyle:NSDateFormatterNoStyle],
                  model.maxSystolic, model.minSystolic,
                  model.maxDiastolic, model.minDiastolic,
                  (unsigned long)model.manualItems.count,
                  (unsigned long)model.autoItems.count);
        }
    } else {
        TSLog(@"Synchronization failed: %@", error.localizedDescription);
    }
}];
```

### Synchronize Daily Blood Pressure Data from Start Time to Now

Retrieve aggregated daily blood pressure data from a specified start time to the current time.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSBPDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time (seconds since 1970); automatically normalized to 00:00:00 of specified day |
| `completion` | `void (^)(NSArray<TSBPDailyModel *> *, NSError *)` | Block called with daily models (one per day) or error |

**`Example**`

```objc
id<TSBloodPressureInterface> bpInterface = /* obtained from TSHealthDataManager */;

NSDate *sevenDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-604800];

[bpInterface syncDailyDataFromStartTime:[sevenDaysAgo timeIntervalSince1970]
                             completion:^(NSArray<TSBPDailyModel *> * _Nullable models, NSError * _Nullable error) {
    if (models) {
        TSLog(@"Retrieved blood pressure data for %lu days", 
              (unsigned long)models.count);
        for (TSBPDailyModel *model in models) {
            NSArray<TSBPValueItem *> *allItems = [model allMeasuredItems];
            TSLog(@"Day %@: %lu total measurements", 
                  model.date, (unsigned long)allItems.count);
        }
    } else {
        TSLog(@"Failed to retrieve daily data: %@", 
              error.localizedDescription);
    }
}];
```

## Important Notes

1. **Device Support `Verification**` — Always call `isSupportActivityMeasureByUser` or `isSupportAutomaticMonitoring` before attempting to use the corresponding features, as not all devices support all blood pressure measurement modes.

2. **Time Parameters as Seconds Since 1970** — All time-related parameters (startTime, endTime) use Unix timestamp format (seconds since January 1, 1970). Convert `NSDate` objects using the `timeIntervalSince1970` property.

3. **Automatic Time Normalization for Daily `Data**` — When synchronizing daily data, start time is automatically normalized to 00:00:00 and end time to 23:59:59 of their respective days. The returned data includes complete day boundaries regardless of the exact times specified.

4. **Asynchronous Callbacks on Main `Thread**` — All completion handlers are invoked on the main thread, making it safe to update UI elements directly without additional thread dispatch.

5. **Measurement Parameters `Required**` — The `TSActivityMeasureParam` object passed to `startMeasureWithParam` must be properly initialized with valid measurement parameters; refer to TSActivityMeasureParam documentation for required fields.

6. **Raw vs Daily Data `Distinction**` — Use `syncRawData` methods for individual measurement records with precise timestamps, and `syncDailyData` methods for aggregated daily statistics including maximum/minimum values.

7. **Data Array `Ordering**` — All returned data arrays (manualItems, autoItems, etc.) are ordered by timestamp in ascending order, with earliest measurements first.

8. **Nil Handling in Daily `Models**` — Minimum and maximum item properties in `TSBPDailyModel` may be nil if no measurements of that type exist for the day; always check for nil before accessing properties.

9. **isUserInitiated Property `Distinction**` — The `isUserInitiated` property in `TSBPValueItem` distinguishes between user-triggered measurements (YES) and background automatic monitoring (NO), enabling analysis of different measurement types.

10. **Configuration `Persistence**` — Automatic monitoring configurations pushed to the device persist until explicitly changed; use `fetchAutoMonitorConfigs` to verify current device settings if needed.