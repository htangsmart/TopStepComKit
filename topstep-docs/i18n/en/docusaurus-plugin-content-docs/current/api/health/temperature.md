---
sidebar_position: 7
title: Temperature
---

# Temperature

The Temperature module provides comprehensive functionality for measuring and monitoring body temperature and wrist temperature. It supports both manual user-initiated measurements and automatic monitoring, with capabilities for real-time data collection and historical data synchronization.

## Prerequisites

- Device must support temperature measurement hardware
- User must have granted necessary permissions for temperature data access
- Active device connection is required for measurement operations
- For automatic monitoring features, the device must support automatic temperature monitoring capability

## Data Models

### TSTempValueItem

Temperature measurement data point representing a single temperature reading.

| Property | Type | Description |
|----------|------|-------------|
| `temperature` | `CGFloat` | Temperature value in Celsius. Meaning depends on temperatureType: core body temperature for TSTemperatureTypeBody, wrist temperature for TSTemperatureTypeWrist. |
| `temperatureType` | `TSTemperatureType` | Measurement type: TSTemperatureTypeBody (core body temperature, normal range 36.1-37.2°C) or TSTemperatureTypeWrist (wrist temperature, typically lower). |
| `isUserInitiated` | `BOOL` | Indicates whether the measurement was initiated by the user. |
| `timestamp` | `NSTimeInterval` | Timestamp of the measurement (inherited from TSHealthValueItem). |

### TSTempDailyModel

Daily aggregated temperature statistics representing one day's temperature data.

| Property | Type | Description |
|----------|------|-------------|
| `maxBodyTempItem` | `TSTempValueItem *` | TSTempValueItem representing the highest body temperature measurement for the day. Nil if no body temperature data exists. |
| `minBodyTempItem` | `TSTempValueItem *` | TSTempValueItem representing the lowest body temperature measurement for the day. Nil if no body temperature data exists. |
| `maxWristTempItem` | `TSTempValueItem *` | TSTempValueItem representing the highest wrist temperature measurement for the day. Nil if no wrist temperature data exists. |
| `minWristTempItem` | `TSTempValueItem *` | TSTempValueItem representing the lowest wrist temperature measurement for the day. Nil if no wrist temperature data exists. |
| `manualItems` | `NSArray<TSTempValueItem *> *` | Array of user-initiated temperature measurements, ordered by time ascending. Empty array if no manual measurements exist. |
| `autoItems` | `NSArray<TSTempValueItem *> *` | Array of automatically monitored temperature items, ordered by time ascending. Empty array if no automatic monitoring data exists. |

## Enumerations

### TSTemperatureType

Temperature measurement type distinguishing between body temperature and wrist temperature.

| Value | Name | Description |
|-------|------|-------------|
| `0` | `TSTemperatureTypeBody` | Core body temperature measurement (normal range: 36.1-37.2°C). |
| `1` | `TSTemperatureTypeWrist` | Wrist temperature measurement (typically lower than body temperature). |

## Callback Types

### Start/Stop Measurement Completion

```objc
void (^)(BOOL success, NSError * _Nullable error)
```

Callback invoked when measurement starts, stops, or ends.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the operation succeeded. |
| `error` | `NSError *` | Error information if failed; nil if successful. |

### Real-time Data Callback

```objc
void (^)(TSTempValueItem * _Nullable data, NSError * _Nullable error)
```

Callback for receiving real-time measurement data during active measurement.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `TSTempValueItem *` | Real-time temperature measurement data; nil if error occurs. |
| `error` | `NSError *` | Error information if data reception fails; nil if successful. |

### Sync Completion Callbacks

```objc
void (^)(NSArray<TSTempValueItem *> * _Nullable tempItems, NSError * _Nullable error)
```

Callback for raw temperature data synchronization.

| Parameter | Type | Description |
|-----------|------|-------------|
| `tempItems` | `NSArray<TSTempValueItem *> *` | Array of synchronized raw temperature measurement items; nil on error. |
| `error` | `NSError *` | Error information if synchronization failed; nil on success. |

```objc
void (^)(NSArray<TSTempDailyModel *> * _Nullable dailyModels, NSError * _Nullable error)
```

Callback for daily temperature data synchronization.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dailyModels` | `NSArray<TSTempDailyModel *> *` | Array of synchronized daily temperature models; nil on error. Each element represents one day. |
| `error` | `NSError *` | Error information if synchronization failed; nil on success. |

### Configuration Fetch Callback

```objc
void (^)(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error)
```

Callback for retrieving automatic monitoring configuration.

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorConfigs *` | Current automatic monitoring configuration; nil on error. |
| `error` | `NSError *` | Error information if fetch failed; nil on success. |

## API Reference

### Check manual measurement support

Determines whether the device supports manual temperature measurement initiated by the user.

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**Returns:** `BOOL` — YES if the device supports manual temperature measurement, NO otherwise.

**Code Example:**

```objc
id<TSTemperatureInterface> tempInterface = (id<TSTemperatureInterface>)healthModule;

if ([tempInterface isSupportActivityMeasureByUser]) {
    TSLog(@"Device supports manual temperature measurement");
} else {
    TSLog(@"Device does not support manual temperature measurement");
}
```

### Start temperature measurement

Initiates a temperature measurement with specified parameters and receives real-time data through callbacks.

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSTempValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `measureParam` | `TSActivityMeasureParam *` | Parameters for the measurement activity. |
| `startHandler` | `void (^)(BOOL, NSError *)` | Block called when measurement starts or fails to start. |
| `dataHandler` | `void (^)(TSTempValueItem *, NSError *)` | Block to receive real-time measurement data updates. |
| `endHandler` | `void (^)(BOOL, NSError *)` | Block called when measurement ends (normally or abnormally). |

**Code Example:**

```objc
id<TSTemperatureInterface> tempInterface = (id<TSTemperatureInterface>)healthModule;
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];

[tempInterface startMeasureWithParam:param
                        startHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Temperature measurement started successfully");
    } else {
        TSLog(@"Failed to start measurement: %@", error.localizedDescription);
    }
} dataHandler:^(TSTempValueItem * _Nullable data, NSError * _Nullable error) {
    if (data) {
        TSLog(@"Temperature: %.1f°C, Type: %@", 
              data.temperature,
              data.temperatureType == TSTemperatureTypeBody ? @"Body" : @"Wrist");
    }
} endHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Temperature measurement completed normally");
    } else {
        TSLog(@"Measurement interrupted: %@", error.localizedDescription);
    }
}];
```

### Stop temperature measurement

Stops the ongoing temperature measurement.

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Completion block called when the measurement stops or fails to stop. |

**Code Example:**

```objc
id<TSTemperatureInterface> tempInterface = (id<TSTemperatureInterface>)healthModule;

[tempInterface stopMeasureCompletion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to stop measurement: %@", error.localizedDescription);
    } else {
        TSLog(@"Temperature measurement stopped successfully");
    }
}];
```

### Check automatic monitoring support

Determines whether the device supports automatic temperature monitoring.

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**Returns:** `BOOL` — YES if the device supports automatic temperature monitoring, NO otherwise.

**Code Example:**

```objc
id<TSTemperatureInterface> tempInterface = (id<TSTemperatureInterface>)healthModule;

if ([tempInterface isSupportAutomaticMonitoring]) {
    TSLog(@"Device supports automatic temperature monitoring");
} else {
    TSLog(@"Device does not support automatic temperature monitoring");
}
```

### Configure automatic monitoring

Configures automatic temperature monitoring settings on the device.

```objc
- (void)pushAutoMonitorConfig:(TSAutoMonitorConfigs *_Nonnull)configuration
                   completion:(nonnull TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorConfigs *` | Configuration parameters for automatic monitoring. |
| `completion` | `TSCompletionBlock` | Completion block called when the configuration is set or fails to set. |

**Code Example:**

```objc
id<TSTemperatureInterface> tempInterface = (id<TSTemperatureInterface>)healthModule;
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];
config.enabled = YES;

[tempInterface pushAutoMonitorConfig:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to configure automatic monitoring: %@", error.localizedDescription);
    } else {
        TSLog(@"Automatic monitoring configured successfully");
    }
}];
```

### Fetch automatic monitoring configuration

Retrieves the current automatic temperature monitoring configuration.

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | Completion block with the current configuration or error. |

**Code Example:**

```objc
id<TSTemperatureInterface> tempInterface = (id<TSTemperatureInterface>)healthModule;

[tempInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch configuration: %@", error.localizedDescription);
    } else {
        TSLog(@"Current monitoring enabled: %d", configuration.enabled);
    }
}];
```

### Synchronize raw temperature data (time range)

Synchronizes raw temperature measurement data within a specified time range.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSTempValueItem *> *_Nullable tempItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970). |
| `endTime` | `NSTimeInterval` | End time for data synchronization (timestamp in seconds since 1970). |
| `completion` | `void (^)(NSArray *, NSError *)` | Completion block with synchronized raw temperature items or error. |

**Code Example:**

```objc
id<TSTemperatureInterface> tempInterface = (id<TSTemperatureInterface>)healthModule;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-86400]; // 24 hours ago
NSDate *endDate = [NSDate date];

[tempInterface syncRawDataFromStartTime:startDate.timeIntervalSince1970
                                endTime:endDate.timeIntervalSince1970
                             completion:^(NSArray<TSTempValueItem *> * _Nullable tempItems, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync raw data: %@", error.localizedDescription);
    } else {
        TSLog(@"Synchronized %lu raw temperature items", (unsigned long)tempItems.count);
        for (TSTempValueItem *item in tempItems) {
            TSLog(@"Temp: %.1f°C, Type: %d, Time: %@", 
                  item.temperature, 
                  item.temperatureType,
                  [NSDate dateWithTimeIntervalSince1970:item.timestamp]);
        }
    }
}];
```

### Synchronize raw temperature data (from start time)

Synchronizes raw temperature measurement data from a specified start time until now.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSTempValueItem *> *_Nullable tempItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970). |
| `completion` | `void (^)(NSArray *, NSError *)` | Completion block with synchronized raw temperature items or error. |

**Code Example:**

```objc
id<TSTemperatureInterface> tempInterface = (id<TSTemperatureInterface>)healthModule;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-604800]; // 7 days ago

[tempInterface syncRawDataFromStartTime:startDate.timeIntervalSince1970
                             completion:^(NSArray<TSTempValueItem *> * _Nullable tempItems, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync raw data: %@", error.localizedDescription);
    } else {
        TSLog(@"Synchronized %lu raw temperature items", (unsigned long)tempItems.count);
    }
}];
```

### Synchronize daily temperature data (time range)

Synchronizes daily aggregated temperature data within a specified time range.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSTempDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970). Will be normalized to 00:00:00 of the specified day. Must be earlier than endTime. |
| `endTime` | `NSTimeInterval` | End time for data synchronization (timestamp in seconds since 1970). Will be normalized to 23:59:59 of the specified day. Must be later than startTime and not in the future. |
| `completion` | `void (^)(NSArray *, NSError *)` | Completion block with synchronized daily temperature models or error. Each TSTempDailyModel represents one day's aggregated data. |

**Code Example:**

```objc
id<TSTemperatureInterface> tempInterface = (id<TSTemperatureInterface>)healthModule;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-2592000]; // 30 days ago
NSDate *endDate = [NSDate date];

[tempInterface syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                                 endTime:endDate.timeIntervalSince1970
                              completion:^(NSArray<TSTempDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync daily data: %@", error.localizedDescription);
    } else {
        TSLog(@"Synchronized %lu days of temperature data", (unsigned long)dailyModels.count);
        for (TSTempDailyModel *dailyModel in dailyModels) {
            TSLog(@"Date: %@", [NSDate dateWithTimeIntervalSince1970:dailyModel.timestamp]);
            TSLog(@"  Max Body Temp: %.1f°C", [dailyModel maxBodyTemperature]);
            TSLog(@"  Min Body Temp: %.1f°C", [dailyModel minBodyTemperature]);
            TSLog(@"  Manual items: %lu", (unsigned long)dailyModel.manualItems.count);
            TSLog(@"  Auto items: %lu", (unsigned long)dailyModel.autoItems.count);
        }
    }
}];
```

### Synchronize daily temperature data (from start time)

Synchronizes daily aggregated temperature data from a specified start time until now.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSTempDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970). Will be normalized to 00:00:00 of the specified day. |
| `completion` | `void (^)(NSArray *, NSError *)` | Completion block with synchronized daily temperature models or error. Each TSTempDailyModel represents one day's aggregated data. |

**Code Example:**

```objc
id<TSTemperatureInterface> tempInterface = (id<TSTemperatureInterface>)healthModule;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-2592000]; // 30 days ago

[tempInterface syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                               completion:^(NSArray<TSTempDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync daily data: %@", error.localizedDescription);
    } else {
        TSLog(@"Synchronized %lu days of temperature data", (unsigned long)dailyModels.count);
        for (TSTempDailyModel *dailyModel in dailyModels) {
            NSArray<TSTempValueItem *> *allItems = [dailyModel allMeasuredItems];
            TSLog(@"Date: %@, Total measurements: %lu", 
                  [NSDate dateWithTimeIntervalSince1970:dailyModel.timestamp],
                  (unsigned long)allItems.count);
        }
    }
}];
```

## Important Notes

1. **Device Support `Validation**`: Always verify device capability using `isSupportActivityMeasureByUser` and `isSupportAutomaticMonitoring` before attempting operations. Attempting unsupported operations will result in errors.

2. **Measurement `States**`: Only one active measurement can run at a time. Calling `startMeasureWithParam:startHandler:dataHandler:endHandler:` while another measurement is in progress will fail. Use `stopMeasureCompletion:` to properly terminate the current measurement.

3. **Time Interval `Handling**`: All time parameters are specified as `NSTimeInterval` (seconds since January 1, 1970). Use `NSDate` methods such as `timeIntervalSince1970` for conversion.

4. **Daily Data `Normalization**`: The `syncDailyDataFromStartTime:endTime:completion:` method automatically normalizes time parameters to day boundaries (00:00:00 to 23:59:59). Ensure startTime is earlier than endTime, and endTime is not in the future.

5. **Callback `Threading**`: Completion handlers are called on the main thread. Perform UI updates directly without additional thread dispatch in completion blocks.

6. **Temperature `Types**`: Results contain both body temperature (TSTemperatureTypeBody, normal range 36.1-37.2°C) and wrist temperature (TSTemperatureTypeWrist) measurements. Interpret values according to their type.

7. **Historical Data `Sync**`: Raw data synchronization (`syncRawDataFromStartTime:endTime:completion:`) returns individual measurements, while daily data synchronization returns aggregated statistics with min/max values for the day.

8. **Manual vs `Automatic**`: The `TSTempDailyModel` separates user-initiated measurements (`manualItems`) from automatic monitoring data (`autoItems`). Use `allMeasuredItems` to retrieve combined data in chronological order.

9. **Real-time Data During `Measurement**`: The `dataHandler` block receives incremental measurement data during active measurement. Data reception errors are indicated through the error parameter without stopping the measurement session.

10. **Error `Handling**`: Implement proper error handling for all async operations. Network connectivity issues, device disconnection, or hardware failures may cause errors during synchronization or measurement operations.