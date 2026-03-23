---
sidebar_position: 4
title: BloodOxygen
---

# TSBloodOxygen

The Blood Oxygen module provides comprehensive blood oxygen (SpO2) measurement and monitoring capabilities. It enables manual measurement initiation, automatic monitoring configuration, and synchronization of both raw and daily aggregated blood oxygen data. Blood oxygen saturation is a critical vital sign that reflects how effectively oxygen is transported from the lungs throughout the body.

## Prerequisites

- Device must support blood oxygen measurement or monitoring features
- Valid Bluetooth connection with the wearable device
- Appropriate permissions for health data access
- Time parameters for data synchronization should be valid Unix timestamps (seconds since 1970)

## Data Models

### TSBOValueItem

Blood oxygen measurement data point representing a single SpO2 reading.

| Property | Type | Description |
|----------|------|-------------|
| `oxyValue` | `UInt8` | The blood oxygen value measured as a percentage (0-100%) |
| `isUserInitiated` | `BOOL` | Indicates whether the measurement was user-initiated (`YES`) or automatically monitored (`NO`) |
| `timestamp` | `NSTimeInterval` | The timestamp of the measurement (inherited from parent class) |

### TSBODailyModel

Aggregated daily blood oxygen data representing all measurements for a single day.

| Property | Type | Description |
|----------|------|-------------|
| `maxOxygenItem` | `TSBOValueItem *` | The blood oxygen item with the maximum value recorded during the day |
| `minOxygenItem` | `TSBOValueItem *` | The blood oxygen item with the minimum value recorded during the day |
| `manualItems` | `NSArray<TSBOValueItem *> *` | Array of user-initiated blood oxygen measurements, sorted by time in ascending order |
| `autoItems` | `NSArray<TSBOValueItem *> *` | Array of automatically monitored blood oxygen items, sorted by time in ascending order |
| `date` | `NSDate *` | The date of this daily model (inherited from parent class) |

### TSAutoMonitorConfigs

Configuration parameters for automatic blood oxygen monitoring.

| Property | Type | Description |
|----------|------|-------------|
| (Defined in related header) | | Refer to TSAutoMonitorConfigs documentation for all available configuration options |

## Enumerations

No enumerations are defined in this module.

## Callback Types

### Measurement Start Handler

```objc
void (^)(BOOL success, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | `YES` if measurement started successfully, `NO` otherwise |
| `error` | `NSError *` | Error information if startup failed; `nil` if successful |

### Real-time Data Handler

```objc
void (^)(TSBOValueItem *_Nullable data, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `TSBOValueItem *` | Real-time blood oxygen measurement data; `nil` if an error occurs |
| `error` | `NSError *` | Error information if data reception fails; `nil` if successful |

### Measurement End Handler

```objc
void (^)(BOOL success, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | `YES` if measurement ended normally, `NO` if interrupted |
| `error` | `NSError *` | Error information if measurement ended abnormally; `nil` if normal termination |

### Completion Handler (Generic)

```objc
void (^)(NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError *` | Error information if operation failed; `nil` if successful |

### Configuration Fetch Handler

```objc
void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorConfigs *` | Current automatic monitoring configuration; `nil` if fetch failed |
| `error` | `NSError *` | Error information if fetch failed; `nil` if successful |

### Raw Data Sync Handler

```objc
void (^)(NSArray<TSBOValueItem *> *_Nullable boItems, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `boItems` | `NSArray<TSBOValueItem *> *` | Array of synchronized raw blood oxygen items; `nil` if sync failed |
| `error` | `NSError *` | Error information if sync failed; `nil` if successful |

### Daily Data Sync Handler

```objc
void (^)(NSArray<TSBODailyModel *> *_Nullable dailyModels, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `dailyModels` | `NSArray<TSBODailyModel *> *` | Array of synchronized daily blood oxygen models; `nil` if sync failed |
| `error` | `NSError *` | Error information if sync failed; `nil` if successful |

## API Reference

### Check if device supports manual blood oxygen measurement

Determines whether the connected device supports user-initiated blood oxygen measurements.

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| (return) | `BOOL` | `YES` if the device supports manual measurement, `NO` otherwise |

**Code Example:**

```objc
id<TSBloodOxygenInterface> boInterface = /* obtained from health manager */;

if ([boInterface isSupportActivityMeasureByUser]) {
    TSLog(@"Device supports manual blood oxygen measurement");
} else {
    TSLog(@"Device does not support manual measurement");
}
```

---

### Start blood oxygen measurement

Initiates a blood oxygen measurement with specified parameters and receives real-time data through callbacks.

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSBOValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `measureParam` | `TSActivityMeasureParam *` | Measurement parameters including timeout and other measurement options |
| `startHandler` | `void (^)(BOOL, NSError *)` | Callback invoked when measurement starts or fails; returns success status and optional error |
| `dataHandler` | `void (^)(TSBOValueItem *, NSError *)` | Callback invoked for each real-time data point received; returns measurement data and optional error |
| `endHandler` | `void (^)(BOOL, NSError *)` | Callback invoked when measurement ends (normally or abnormally); returns end status and optional error |

**Code Example:**

```objc
id<TSBloodOxygenInterface> boInterface = /* obtained from health manager */;
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.timeout = 60; // 60 seconds timeout

[boInterface startMeasureWithParam:param
                     startHandler:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Blood oxygen measurement started successfully");
    } else {
        TSLog(@"Failed to start measurement: %@", error.localizedDescription);
    }
} dataHandler:^(TSBOValueItem *data, NSError *error) {
    if (data) {
        TSLog(@"Real-time SpO2: %d%%", data.oxyValue);
    } else {
        TSLog(@"Data reception error: %@", error.localizedDescription);
    }
} endHandler:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"Measurement completed normally");
    } else {
        TSLog(@"Measurement interrupted or failed: %@", error.localizedDescription);
    }
}];
```

---

### Stop blood oxygen measurement

Terminates an ongoing blood oxygen measurement.

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Callback invoked when measurement stops or fails to stop; returns optional error |

**Code Example:**

```objc
id<TSBloodOxygenInterface> boInterface = /* obtained from health manager */;

[boInterface stopMeasureCompletion:^(NSError *error) {
    if (!error) {
        TSLog(@"Measurement stopped successfully");
    } else {
        TSLog(@"Failed to stop measurement: %@", error.localizedDescription);
    }
}];
```

---

### Check if device supports automatic blood oxygen monitoring

Determines whether the connected device supports automatic blood oxygen monitoring.

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| (return) | `BOOL` | `YES` if the device supports automatic monitoring, `NO` otherwise |

**Code Example:**

```objc
id<TSBloodOxygenInterface> boInterface = /* obtained from health manager */;

if ([boInterface isSupportAutomaticMonitoring]) {
    TSLog(@"Device supports automatic blood oxygen monitoring");
} else {
    TSLog(@"Device does not support automatic monitoring");
}
```

---

### Configure automatic blood oxygen monitoring

Sets the configuration parameters for automatic blood oxygen monitoring on the device.

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorConfigs *` | Configuration parameters for automatic monitoring |
| `completion` | `TSCompletionBlock` | Callback invoked when configuration is set or fails; returns optional error |

**Code Example:**

```objc
id<TSBloodOxygenInterface> boInterface = /* obtained from health manager */;
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];
// Configure monitoring parameters as needed

[boInterface pushAutoMonitorConfigs:config completion:^(NSError *error) {
    if (!error) {
        TSLog(@"Automatic monitoring configuration updated successfully");
    } else {
        TSLog(@"Failed to update configuration: %@", error.localizedDescription);
    }
}];
```

---

### Get current automatic blood oxygen monitoring configuration

Retrieves the current automatic monitoring configuration from the device.

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | Callback invoked with current configuration or error |

**Code Example:**

```objc
id<TSBloodOxygenInterface> boInterface = /* obtained from health manager */;

[boInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *configuration, NSError *error) {
    if (configuration) {
        TSLog(@"Current monitoring configuration retrieved");
        // Process configuration...
    } else {
        TSLog(@"Failed to fetch configuration: %@", error.localizedDescription);
    }
}];
```

---

### Synchronize raw blood oxygen data (time range)

Synchronizes raw blood oxygen measurement data within a specified time range.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSBOValueItem *> *_Nullable boItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for synchronization (Unix timestamp in seconds since 1970) |
| `endTime` | `NSTimeInterval` | End time for synchronization (Unix timestamp in seconds since 1970) |
| `completion` | `void (^)(NSArray<TSBOValueItem *> *, NSError *)` | Callback with synchronized raw data items or error |

**Code Example:**

```objc
id<TSBloodOxygenInterface> boInterface = /* obtained from health manager */;

NSTimeInterval startTime = [[NSDate dateWithTimeIntervalSinceNow:-86400] timeIntervalSince1970]; // 24 hours ago
NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970]; // Now

[boInterface syncRawDataFromStartTime:startTime
                              endTime:endTime
                           completion:^(NSArray<TSBOValueItem *> *boItems, NSError *error) {
    if (boItems) {
        TSLog(@"Synchronized %lu raw blood oxygen measurements", (unsigned long)boItems.count);
        for (TSBOValueItem *item in boItems) {
            TSLog(@"SpO2: %d%% at %f", item.oxyValue, item.timestamp);
        }
    } else {
        TSLog(@"Failed to sync raw data: %@", error.localizedDescription);
    }
}];
```

---

### Synchronize raw blood oxygen data (from start time)

Synchronizes raw blood oxygen measurement data from a specified start time to the current time.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSBOValueItem *> *_Nullable boItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for synchronization (Unix timestamp in seconds since 1970) |
| `completion` | `void (^)(NSArray<TSBOValueItem *> *, NSError *)` | Callback with synchronized raw data items or error |

**Code Example:**

```objc
id<TSBloodOxygenInterface> boInterface = /* obtained from health manager */;

NSTimeInterval startTime = [[NSDate dateWithTimeIntervalSinceNow:-604800] timeIntervalSince1970]; // 7 days ago

[boInterface syncRawDataFromStartTime:startTime
                           completion:^(NSArray<TSBOValueItem *> *boItems, NSError *error) {
    if (boItems) {
        TSLog(@"Synchronized %lu raw measurements from start time", (unsigned long)boItems.count);
    } else {
        TSLog(@"Sync failed: %@", error.localizedDescription);
    }
}];
```

---

### Synchronize daily blood oxygen data (time range)

Synchronizes aggregated daily blood oxygen data within a specified time range.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSBODailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for synchronization; automatically normalized to 00:00:00 of the specified day |
| `endTime` | `NSTimeInterval` | End time for synchronization; automatically normalized to 23:59:59 of the specified day |
| `completion` | `void (^)(NSArray<TSBODailyModel *> *, NSError *)` | Callback with daily models or error; called on the main thread |

**Code Example:**

```objc
id<TSBloodOxygenInterface> boInterface = /* obtained from health manager */;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-2592000]; // 30 days ago
NSDate *endDate = [NSDate date]; // Today

[boInterface syncDailyDataFromStartTime:[startDate timeIntervalSince1970]
                                endTime:[endDate timeIntervalSince1970]
                             completion:^(NSArray<TSBODailyModel *> *dailyModels, NSError *error) {
    if (dailyModels) {
        TSLog(@"Synchronized %lu days of blood oxygen data", (unsigned long)dailyModels.count);
        for (TSBODailyModel *dailyModel in dailyModels) {
            TSLog(@"Date: %@, Max: %d%%, Min: %d%%", 
                  dailyModel.date, 
                  [dailyModel maxOxygenValue], 
                  [dailyModel minOxygenValue]);
        }
    } else {
        TSLog(@"Failed to sync daily data: %@", error.localizedDescription);
    }
}];
```

---

### Synchronize daily blood oxygen data (from start time)

Synchronizes aggregated daily blood oxygen data from a specified start time to the current time.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSBODailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for synchronization; automatically normalized to 00:00:00 of the specified day |
| `completion` | `void (^)(NSArray<TSBODailyModel *> *, NSError *)` | Callback with daily models or error; called on the main thread |

**Code Example:**

```objc
id<TSBloodOxygenInterface> boInterface = /* obtained from health manager */;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-604800]; // 7 days ago

[boInterface syncDailyDataFromStartTime:[startDate timeIntervalSince1970]
                             completion:^(NSArray<TSBODailyModel *> *dailyModels, NSError *error) {
    if (dailyModels) {
        TSLog(@"Synchronized %lu days of data", (unsigned long)dailyModels.count);
        for (TSBODailyModel *model in dailyModels) {
            NSArray<TSBOValueItem *> *allItems = [model allMeasuredItems];
            TSLog(@"Day %@: %lu total measurements", model.date, (unsigned long)allItems.count);
        }
    } else {
        TSLog(@"Failed to sync daily data: %@", error.localizedDescription);
    }
}];
```

---

## Important Notes

1. **Timestamp `Format**`: All time parameters (`startTime`, `endTime`) are Unix timestamps in seconds since 1970 (January 1, 1970 UTC). Use `NSDate`'s `timeIntervalSince1970` property to convert dates to timestamps.

2. **Daily Data `Normalization**`: When calling daily data synchronization methods, start and end times are automatically normalized to day boundaries. `startTime` is normalized to 00:00:00 and `endTime` is normalized to 23:59:59 of their respective days.

3. **Thread `Safety**`: Completion handlers for synchronization operations are always invoked on the main thread, making it safe to perform UI updates directly within these blocks.

4. **Measurement `Duration**`: Manual measurements may take time to complete. Always provide reasonable timeout values in `TSActivityMeasureParam` and implement the `endHandler` to detect measurement completion.

5. **Real-time Data `Streaming**`: The `dataHandler` in `startMeasureWithParam:startHandler:dataHandler:endHandler:` is called multiple times during measurement, providing real-time progress. Do not perform heavy operations within this callback.

6. **Device Support `Checks**`: Always verify device capabilities using `isSupportActivityMeasureByUser` and `isSupportAutomaticMonitoring` before attempting measurement or monitoring operations.

7. **Data `Ordering**`: Raw data from sync operations is provided in ascending time order (oldest to newest). Daily aggregated data includes pre-computed min/max values for convenience.

8. **Error `Handling**`: All operations may fail due to connectivity issues, device limitations, or synchronization errors. Always check the error parameter in completion blocks and implement appropriate error handling logic.

9. **Configuration `Persistence**`: Automatic monitoring configurations set via `pushAutoMonitorConfigs:completion:` are persisted on the device. Use `fetchAutoMonitorConfigsWithCompletion:` to verify the current configuration state.

10. **Data `Types**`: Use `UInt8` for blood oxygen percentage values (0-100%). The `TSBOValueItem` class provides properties for oxygen value and user-initiation status, while `TSBODailyModel` aggregates measurements with minimum, maximum, and item arrays.