---
sidebar_position: 6
title: Stress
---

# Stress

The Stress module provides comprehensive stress level measurement, automatic monitoring, and historical data synchronization capabilities. It supports both manual user-initiated measurements and automatic background monitoring, allowing apps to track stress patterns and provide health insights to users.

## Prerequisites

- The device must support stress measurement features
- Bluetooth connection to a compatible wearable device must be established
- Appropriate health data permissions must be granted by the user
- For automatic monitoring, the device must support automatic stress monitoring capability

## Data Models

### TSStressValueItem

Individual stress measurement data point.

| Property | Type | Description |
|----------|------|-------------|
| `stressValue` | `UInt8` | The stress level value measured on a scale, typically from 0 to 100 |
| `isUserInitiated` | `BOOL` | A boolean value indicating whether the measurement was taken as initiated by the user |
| `timestamp` | `NSTimeInterval` | The time when the measurement was recorded (inherited from TSHealthValueItem) |
| `valueType` | `TSHealthValueType` | Type indicator for the measurement (inherited from TSHealthValueItem) |

### TSStressDailyModel

Daily aggregated stress data for a single day.

| Property | Type | Description |
|----------|------|-------------|
| `maxStressItem` | `TSStressValueItem *` | The TSStressValueItem representing the highest stress measurement for the day |
| `minStressItem` | `TSStressValueItem *` | The TSStressValueItem representing the lowest stress measurement for the day |
| `manualItems` | `NSArray<TSStressValueItem *>` | Array of user-initiated stress measurements, ordered by time ascending |
| `autoItems` | `NSArray<TSStressValueItem *>` | Array of automatically monitored stress items, ordered by time ascending |
| `date` | `NSDate *` | The date this daily model represents (inherited from TSHealthDailyModel) |

## Enumerations

No public enumerations are defined for this module.

## Callback Types

### Measurement Start Handler

```objc
void (^)(BOOL success, NSError * _Nullable error)
```

Called when stress measurement starts or fails to start.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the measurement started successfully |
| `error` | `NSError *` | Error information if failed, nil if successful |

### Measurement Data Handler

```objc
void (^)(TSStressValueItem * _Nullable data, NSError * _Nullable error)
```

Called to receive real-time measurement data during an active measurement.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `TSStressValueItem *` | Real-time stress measurement data, nil if error occurs |
| `error` | `NSError *` | Error information if data reception fails, nil if successful |

### Measurement End Handler

```objc
void (^)(BOOL success, NSError * _Nullable error)
```

Called when measurement ends (normally or abnormally).

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the measurement ended normally (YES) or was interrupted (NO) |
| `error` | `NSError *` | Error information if measurement ended abnormally, nil if normal end |

### Configuration Completion Handler

```objc
void (^)(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error)
```

Called with the current automatic monitoring configuration or error.

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorConfigs *` | The current automatic monitoring configuration |
| `error` | `NSError *` | Error information if fetch failed, nil if successful |

### Raw Data Sync Completion Handler

```objc
void (^)(NSArray<TSStressValueItem *> * _Nullable stressItems, NSError * _Nullable error)
```

Called with synchronized raw stress measurement items or error.

| Parameter | Type | Description |
|-----------|------|-------------|
| `stressItems` | `NSArray<TSStressValueItem *> *` | Array of synchronized raw stress measurement items |
| `error` | `NSError *` | Error information if synchronization failed, nil if successful |

### Daily Data Sync Completion Handler

```objc
void (^)(NSArray<TSStressDailyModel *> * _Nullable dailyModels, NSError * _Nullable error)
```

Called with synchronized daily stress models or error.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dailyModels` | `NSArray<TSStressDailyModel *> *` | Array of synchronized daily stress models |
| `error` | `NSError *` | Error information if synchronization failed, nil if successful |

## API Reference

### Check Manual Stress Measurement Support

Determines if the connected device supports manual stress measurement initiated by the user.

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**Returns:** `BOOL` — YES if the device supports manual stress measurement, NO otherwise

**Code Example:**

```objc
id<TSStressInterface> stressInterface = (id<TSStressInterface>)healthManager;

if ([stressInterface isSupportActivityMeasureByUser]) {
    TSLog(@"Device supports manual stress measurement");
} else {
    TSLog(@"Device does not support manual stress measurement");
}
```

### Start Stress Measurement

Initiates a stress measurement with specified parameters and handles real-time data feedback through callback blocks.

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSStressValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `measureParam` | `TSActivityMeasureParam *` | Parameters for the measurement activity |
| `startHandler` | `void (^)(BOOL, NSError *)` | Block called when measurement starts or fails to start |
| `dataHandler` | `void (^)(TSStressValueItem *, NSError *)` | Block to receive real-time measurement data |
| `endHandler` | `void (^)(BOOL, NSError *)` | Block called when measurement ends (normally or abnormally) |

**Code Example:**

```objc
id<TSStressInterface> stressInterface = (id<TSStressInterface>)healthManager;
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];

[stressInterface startMeasureWithParam:param
                          startHandler:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Stress measurement started successfully");
    } else {
        TSLog(@"Failed to start stress measurement: %@", error.localizedDescription);
    }
} dataHandler:^(TSStressValueItem *data, NSError *error) {
    if (data) {
        TSLog(@"Real-time stress value: %d", data.stressValue);
    } else {
        TSLog(@"Error receiving data: %@", error.localizedDescription);
    }
} endHandler:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Stress measurement completed normally");
    } else {
        TSLog(@"Stress measurement ended abnormally: %@", error.localizedDescription);
    }
}];
```

### Stop Stress Measurement

Terminates the ongoing stress measurement.

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Completion block called when the measurement stops or fails to stop |

**Code Example:**

```objc
id<TSStressInterface> stressInterface = (id<TSStressInterface>)healthManager;

[stressInterface stopMeasureCompletion:^(NSError *error) {
    if (!error) {
        TSLog(@"Stress measurement stopped successfully");
    } else {
        TSLog(@"Failed to stop stress measurement: %@", error.localizedDescription);
    }
}];
```

### Check Automatic Monitoring Support

Determines if the connected device supports automatic stress monitoring.

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**Returns:** `BOOL` — YES if the device supports automatic stress monitoring, NO otherwise

**Code Example:**

```objc
id<TSStressInterface> stressInterface = (id<TSStressInterface>)healthManager;

if ([stressInterface isSupportAutomaticMonitoring]) {
    TSLog(@"Device supports automatic stress monitoring");
} else {
    TSLog(@"Device does not support automatic stress monitoring");
}
```

### Configure Automatic Monitoring

Sets up automatic stress monitoring with specified parameters.

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorConfigs *` | Configuration parameters for automatic monitoring |
| `completion` | `TSCompletionBlock` | Completion block called when the configuration is set or fails to set |

**Code Example:**

```objc
id<TSStressInterface> stressInterface = (id<TSStressInterface>)healthManager;
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];
config.enabled = YES;

[stressInterface pushAutoMonitorConfigs:config completion:^(NSError *error) {
    if (!error) {
        TSLog(@"Automatic stress monitoring configured successfully");
    } else {
        TSLog(@"Failed to configure automatic monitoring: %@", error.localizedDescription);
    }
}];
```

### Fetch Current Automatic Monitoring Configuration

Retrieves the current automatic stress monitoring configuration from the device.

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | Completion block with the current configuration or error |

**Code Example:**

```objc
id<TSStressInterface> stressInterface = (id<TSStressInterface>)healthManager;

[stressInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *configuration, NSError *error) {
    if (configuration) {
        TSLog(@"Current monitoring enabled: %@", configuration.enabled ? @"YES" : @"NO");
    } else {
        TSLog(@"Failed to fetch configuration: %@", error.localizedDescription);
    }
}];
```

### Synchronize Raw Stress Data (Time Range)

Synchronizes raw stress measurement data within a specified time range.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSStressValueItem *> *_Nullable stressItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970) |
| `endTime` | `NSTimeInterval` | End time for data synchronization (timestamp in seconds since 1970) |
| `completion` | `void (^)(NSArray<TSStressValueItem *> *, NSError *)` | Completion block with synchronized raw stress measurement items or error |

**Code Example:**

```objc
id<TSStressInterface> stressInterface = (id<TSStressInterface>)healthManager;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-86400]; // 24 hours ago
NSDate *endDate = [NSDate date]; // now

[stressInterface syncRawDataFromStartTime:startDate.timeIntervalSince1970
                                  endTime:endDate.timeIntervalSince1970
                               completion:^(NSArray<TSStressValueItem *> *stressItems, NSError *error) {
    if (stressItems) {
        TSLog(@"Synced %lu raw stress measurements", (unsigned long)stressItems.count);
        for (TSStressValueItem *item in stressItems) {
            TSLog(@"Stress: %d at %@", item.stressValue, 
                  [NSDate dateWithTimeIntervalSince1970:item.timestamp]);
        }
    } else {
        TSLog(@"Failed to sync raw data: %@", error.localizedDescription);
    }
}];
```

### Synchronize Raw Stress Data (From Start Time to Now)

Synchronizes raw stress measurement data from a specified start time until the current time.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSStressValueItem *> *_Nullable stressItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970) |
| `completion` | `void (^)(NSArray<TSStressValueItem *> *, NSError *)` | Completion block with synchronized raw stress measurement items or error |

**Code Example:**

```objc
id<TSStressInterface> stressInterface = (id<TSStressInterface>)healthManager;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-604800]; // 7 days ago

[stressInterface syncRawDataFromStartTime:startDate.timeIntervalSince1970
                               completion:^(NSArray<TSStressValueItem *> *stressItems, NSError *error) {
    if (stressItems) {
        TSLog(@"Synced %lu raw stress measurements from last 7 days", (unsigned long)stressItems.count);
    } else {
        TSLog(@"Failed to sync raw data: %@", error.localizedDescription);
    }
}];
```

### Synchronize Daily Stress Data (Time Range)

Synchronizes daily aggregated stress data within a specified time range with automatic normalization to day boundaries.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSStressDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970). Will be automatically normalized to 00:00:00 of the specified day |
| `endTime` | `NSTimeInterval` | End time for data synchronization (timestamp in seconds since 1970). Will be automatically normalized to 23:59:59 of the specified day |
| `completion` | `void (^)(NSArray<TSStressDailyModel *> *, NSError *)` | Completion block with synchronized daily stress models or error |

**Code Example:**

```objc
id<TSStressInterface> stressInterface = (id<TSStressInterface>)healthManager;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-2592000]; // 30 days ago
NSDate *endDate = [NSDate date]; // now

[stressInterface syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                                   endTime:endDate.timeIntervalSince1970
                                completion:^(NSArray<TSStressDailyModel *> *dailyModels, NSError *error) {
    if (dailyModels) {
        TSLog(@"Synced %lu daily stress reports", (unsigned long)dailyModels.count);
        for (TSStressDailyModel *dailyModel in dailyModels) {
            TSLog(@"Date: %@, Max Stress: %d, Min Stress: %d", 
                  dailyModel.date, [dailyModel maxStress], [dailyModel minStress]);
        }
    } else {
        TSLog(@"Failed to sync daily data: %@", error.localizedDescription);
    }
}];
```

### Synchronize Daily Stress Data (From Start Time to Now)

Synchronizes daily aggregated stress data from a specified start time until the current time.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSStressDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970). Will be automatically normalized to 00:00:00 of the specified day |
| `completion` | `void (^)(NSArray<TSStressDailyModel *> *, NSError *)` | Completion block with synchronized daily stress models or error |

**Code Example:**

```objc
id<TSStressInterface> stressInterface = (id<TSStressInterface>)healthManager;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-604800]; // 7 days ago

[stressInterface syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                                completion:^(NSArray<TSStressDailyModel *> *dailyModels, NSError *error) {
    if (dailyModels) {
        TSLog(@"Synced %lu days of stress data", (unsigned long)dailyModels.count);
        for (TSStressDailyModel *dailyModel in dailyModels) {
            NSArray *allItems = [dailyModel allMeasuredItems];
            TSLog(@"Date: %@, Total measurements: %lu", dailyModel.date, (unsigned long)allItems.count);
        }
    } else {
        TSLog(@"Failed to sync daily data: %@", error.localizedDescription);
    }
}];
```

## TSStressDailyModel Convenience Methods

### Get Maximum Stress Level Value

```objc
- (UInt8)maxStress;
```

**Returns:** `UInt8` — Maximum stress level value for the day (0 if maxStressItem is nil)

### Get Minimum Stress Level Value

```objc
- (UInt8)minStress;
```

**Returns:** `UInt8` — Minimum stress level value for the day (0 if minStressItem is nil)

### Get All Measured Items

```objc
- (NSArray<TSStressValueItem *> *)allMeasuredItems;
```

**Returns:** `NSArray<TSStressValueItem *>` — Combined array of manual and auto items, sorted by time

**Code Example:**

```objc
TSStressDailyModel *dailyModel = /* obtained from sync completion */;

UInt8 maxValue = [dailyModel maxStress];
UInt8 minValue = [dailyModel minStress];
NSArray<TSStressValueItem *> *allItems = [dailyModel allMeasuredItems];

TSLog(@"Daily stress - Max: %d, Min: %d, Total measurements: %lu", 
      maxValue, minValue, (unsigned long)allItems.count);
```

## Important Notes

1. All timestamp parameters are in seconds since 1970 (Unix epoch time). Convert `NSDate` objects using the `timeIntervalSince1970` property.

2. For daily data synchronization, time parameters are automatically normalized to day boundaries (00:00:00 to 23:59:59). Manual time adjustment is not required.

3. The `startTime` parameter must always be earlier than `endTime` for time range methods. The `endTime` for daily data cannot be in the future.

4. Stress values are measured on a scale from 0 to 100, where higher values indicate greater stress levels.

5. The `isUserInitiated` property in `TSStressValueItem` distinguishes between manual measurements (YES) and automatic monitoring data (NO).

6. Real-time measurement data is provided through the `dataHandler` callback during an active measurement. Multiple data points may be received during a single measurement session.

7. Completion handlers for data synchronization are called on the main thread, making it safe to update UI directly.

8. Before initiating manual or automatic stress measurements, always verify device support using `isSupportActivityMeasureByUser` or `isSupportAutomaticMonitoring` methods.

9. The `TSStressDailyModel.allMeasuredItems` method returns a combined, time-sorted array of both manual (`manualItems`) and automatic (`autoItems`) measurements for convenient data processing.

10. Automatic monitoring configuration can be fetched at any time using `fetchAutoMonitorConfigsWithCompletion:` to verify the current device settings.