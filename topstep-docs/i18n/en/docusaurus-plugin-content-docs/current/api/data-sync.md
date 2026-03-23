---
sidebar_position: 1
title: DataSync
---

# DataSync

The DataSync module provides a comprehensive framework for synchronizing health data from wearable devices. It supports multiple health metrics including heart rate, blood oxygen, blood pressure, stress levels, sleep data, body temperature, ECG, sports activities, and daily activity monitoring. The module offers both automatic synchronization from the last sync time and flexible configuration-based synchronization with customizable data types, granularity levels, and time ranges.

## Prerequisites

1. Device must be properly connected and authenticated through the TopStepComKit SDK
2. Health data permissions must be granted by the user
3. Device must have health data collected and ready for synchronization
4. Network connectivity must be available for data transfer
5. Configuration object must be valid and properly initialized before synchronization

## Data Models

### TSDataSyncConfig

Configuration model for health data synchronization operations.

| Property | Type | Description |
|----------|------|-------------|
| `options` | `TSDataSyncOption` | Data types to synchronize; can be combined using bitwise OR operations for batch synchronization |
| `granularity` | `TSDataGranularity` | Data granularity level (raw individual measurements or daily aggregated data) |
| `startTime` | `NSTimeInterval` | Start time for synchronization in timestamp format (seconds since 1970); if 0, SDK automatically retrieves last sync time |
| `endTime` | `NSTimeInterval` | End time for synchronization in timestamp format; if 0, defaults to current time |
| `includeUserInitiated` | `BOOL` | Whether to include user-initiated measurements in addition to automatic measurements |

### TSHealthData

Represents synchronized health data results for a specific data type.

| Property | Type | Description |
|----------|------|-------------|
| `option` | `TSDataSyncOption` | Data type indicator (heart rate, blood oxygen, blood pressure, stress, sleep, temperature, ECG, sports, or daily activity) |
| `healthValues` | `NSArray<TSHealthValueModel *> *` | Array of health value models in ascending time order; each element represents one day's aggregated data (or individual measurements for raw granularity); empty when no data available |
| `fetchError` | `NSError *` | Error describing fetch failure for this specific data type; nil when fetch succeeds (even if no data present) |

## Enumerations

### TSDataGranularity

Defines the granularity level for data synchronization.

| Value | Description |
|-------|-------------|
| `TSDataGranularityRaw` | Individual measurements without aggregation |
| `TSDataGranularityDay` | Daily aggregated data |

### TSDataSyncOption

Defines types of health data that can be synchronized from the device. Options can be combined using bitwise OR operations.

| Value | Description |
|-------|-------------|
| `TSDataSyncOptionNone` | No data option |
| `TSDataSyncOptionHeartRate` | Heart rate data |
| `TSDataSyncOptionBloodOxygen` | Blood oxygen (SpO2) data |
| `TSDataSyncOptionBloodPressure` | Blood pressure data |
| `TSDataSyncOptionStress` | Stress level data |
| `TSDataSyncOptionSleep` | Sleep monitoring data |
| `TSDataSyncOptionTemperature` | Body temperature data |
| `TSDataSyncOptionECG` | Electrocardiogram (ECG) data |
| `TSDataSyncOptionSport` | Sports activity data |
| `TSDataSyncOptionDailyActivity` | Daily activity data |
| `TSDataSyncOptionAll` | Combination of all available data options |

## Callback Types

### Synchronization Completion Handler

```objc
void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `results` | `NSArray<TSHealthData *> *` | Array of TSHealthData objects, each containing results for one requested data type; nil or empty only when fatal error occurs |
| `error` | `NSError *` | Non-nil only for fatal errors that prevent operation continuation (e.g., invalid config, network failure, device busy, operation canceled); indicates per-type errors are in individual TSHealthData.fetchError properties |

## API Reference

### Automatically synchronize daily data from last sync time

Automatically synchronizes all types of daily aggregated data from the last recorded sync time to the current time. The SDK automatically calculates the time range based on the stored last sync time.

```objc
- (void)syncDailyDataFromLastTime:(void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(NSArray<TSHealthData *> *, NSError *)` | Callback handler invoked on main thread with per-type results and optional fatal error |

**Code Example:**

```objc
id<TSDataSyncInterface> syncManager = /* obtain from SDK */;

[syncManager syncDailyDataFromLastTime:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Fatal sync error: %@", error.localizedDescription);
        return;
    }
    
    for (TSHealthData *data in results) {
        if (data.fetchError) {
            TSLog(@"Failed to fetch data type %ld: %@", data.option, data.fetchError.localizedDescription);
        } else {
            TSLog(@"Successfully fetched %lu days of data for type %ld", (unsigned long)data.healthValues.count, data.option);
            for (TSHealthValueModel *value in data.healthValues) {
                TSLog(@"  Date: %@, Values: %@", value.date, value.values);
            }
        }
    }
}];
```

### Automatically synchronize raw data from last sync time

Automatically synchronizes all types of raw (non-aggregated) data from the last recorded sync time to the current time. Raw data contains individual measurements and may result in larger data volumes.

```objc
- (void)syncRawDataFromLastTime:(void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(NSArray<TSHealthData *> *, NSError *)` | Callback handler invoked on main thread with per-type results and optional fatal error |

**Code Example:**

```objc
id<TSDataSyncInterface> syncManager = /* obtain from SDK */;

[syncManager syncRawDataFromLastTime:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Fatal sync error: %@", error.localizedDescription);
        return;
    }
    
    TSHealthData *heartRateData = [TSHealthData findHealthDataWithOption:TSDataSyncOptionHeartRate 
                                                                 fromArray:results];
    if (heartRateData && !heartRateData.fetchError) {
        TSLog(@"Heart rate raw data points: %lu", (unsigned long)heartRateData.healthValues.count);
    }
}];
```

### Synchronize health data using configuration

Synchronizes health data from the device using the provided configuration object. The configuration determines data types, granularity, time range, and other synchronization parameters.

```objc
- (void)syncDataWithConfig:(TSDataSyncConfig *_Nonnull)config
                completion:(void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `config` | `TSDataSyncConfig *` | Configuration object containing synchronization parameters; must not be nil |
| `completion` | `void (^)(NSArray<TSHealthData *> *, NSError *)` | Callback handler invoked on main thread with per-type results and optional fatal error |

**Code Example:**

```objc
id<TSDataSyncInterface> syncManager = /* obtain from SDK */;

// Create configuration for syncing heart rate and blood oxygen data
TSDataSyncConfig *config = [[TSDataSyncConfig alloc] initWithOptions:(TSDataSyncOptionHeartRate | TSDataSyncOptionBloodOxygen)
                                                           granularity:TSDataGranularityDay
                                                             startTime:[[NSDate dateWithTimeIntervalSinceNow:-7*24*60*60] timeIntervalSince1970]
                                                               endTime:[[NSDate date] timeIntervalSince1970]];

[syncManager syncDataWithConfig:config completion:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Sync failed with error: %@", error.localizedDescription);
        return;
    }
    
    for (TSHealthData *data in results) {
        if (data.fetchError) {
            TSLog(@"Data fetch error for type %ld: %@", data.option, data.fetchError.localizedDescription);
        } else {
            TSLog(@"Successfully synced %lu records for type %ld", (unsigned long)data.healthValues.count, data.option);
        }
    }
}];
```

### Check if data synchronization is currently in progress

Checks whether any data synchronization operation is currently running. Can be used to prevent multiple simultaneous sync operations and update UI state accordingly.

```objc
- (BOOL)isSyncing;
```

| Return | Type | Description |
|--------|------|-------------|
| Result | `BOOL` | YES if data synchronization is currently active; NO otherwise |

**Code Example:**

```objc
id<TSDataSyncInterface> syncManager = /* obtain from SDK */;

if ([syncManager isSyncing]) {
    TSLog(@"Synchronization is already in progress");
    // Show loading indicator or disable sync button
} else {
    TSLog(@"No synchronization in progress, starting new sync");
    [syncManager syncDailyDataFromLastTime:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
        // Handle results
    }];
}
```

## Important Notes

1. All completion handlers are called on the main thread, allowing direct UI updates without additional dispatch operations.

2. Fatal errors in the completion handler's `error` parameter indicate operations that cannot continue (invalid config, network failure, device busy, or canceled operations). Per-type failures are reported in individual `TSHealthData.fetchError` properties.

3. Empty `healthValues` arrays indicate no data available for that type during the specified time period, which is not an error condition.

4. Configuration validation errors are returned through the completion handler's `error` parameter before any device communication occurs.

5. When `startTime` is 0 in configuration, the SDK automatically retrieves the last sync time from the database; if no previous sync time exists, it defaults to 0 or uses a default time window (e.g., 7 days ago).

6. When `endTime` is 0 in configuration, it defaults to the current time at the moment of the sync call.

7. Data synchronization options can be combined using bitwise OR operations: `TSDataSyncOptionHeartRate | TSDataSyncOptionBloodOxygen | TSDataSyncOptionSleep`.

8. Raw data (TSDataGranularityRaw) may result in significantly larger data volumes compared to daily aggregated data (TSDataGranularityDay) and should be used when individual measurement points are required.

9. Check `isSyncing` before initiating new synchronization operations to prevent multiple concurrent sync operations on the same device.

10. The `includeUserInitiated` property in configuration determines whether manually triggered measurements are included along with automatic background monitoring data.