---
sidebar_position: 8
title: Electrocardio
---

# Electrocardio

The Electrocardio module provides comprehensive electrocardiogram (ECG) measurement and monitoring capabilities for cardiac health assessment. This interface enables manual ECG measurements, automatic monitoring configuration, and synchronization of both raw and daily aggregated ECG data to detect heart abnormalities, arrhythmias, and assess overall cardiac health.

## Prerequisites

- Device must support ECG measurement capabilities
- User must grant necessary health data permissions
- Device must be connected and authenticated before performing measurements
- For automatic monitoring, the device must support automatic ECG monitoring feature

## Data Models

### TSECGValueItem

Raw electrocardiogram measurement data point.

| Property | Type | Description |
|----------|------|-------------|
| `waveformData` | `NSArray<NSNumber *> *` | Array of numerical values representing the ECG waveform in millivolts (mV) |
| `samplingRate` | `NSInteger` | Sampling rate of the ECG recording in Hz (typically 125Hz, 250Hz, or 500Hz) |
| `heartRate` | `NSInteger` | Heart rate calculated from the ECG in beats per minute (BPM) |
| `hrvMetrics` | `NSDictionary<NSString *, NSNumber *> *` | Dictionary containing heart rate variability metrics such as SDNN, RMSSD, pNN50, etc. |
| `recordingDuration` | `NSTimeInterval` | Duration of the ECG recording in seconds |
| `rhythmClassification` | `NSString *` | Algorithm's interpretation of the heart rhythm (e.g., "Normal Sinus Rhythm", "Atrial Fibrillation") |
| `classificationConfidence` | `CGFloat` | Confidence level of the rhythm classification from 0.0 to 1.0 |
| `qtInterval` | `NSInteger` | QT interval in milliseconds, representing ventricular depolarization and repolarization |
| `qtcInterval` | `NSInteger` | Corrected QT interval (QTc) in milliseconds, typically using Bazett's formula |
| `prInterval` | `NSInteger` | PR interval in milliseconds, from start of P wave to start of QRS complex |
| `qrsDuration` | `NSInteger` | QRS duration in milliseconds, representing ventricular depolarization |
| `stDeviation` | `CGFloat` | ST segment elevation/depression in millimeters (positive for elevation, negative for depression) |
| `notes` | `NSString *` | Additional notes or observations about the ECG |
| `isReviewed` | `BOOL` | Flag indicating if the recording has been reviewed by a healthcare professional |
| `isUserInitiated` | `BOOL` | Flag indicating whether the measurement was initiated by the user |

### TSECGDailyModel

Daily aggregated electrocardiogram data. Inherits from `TSHealthDailyModel` and represents one day's aggregated ECG metrics and statistics.

| Property | Type | Description |
|----------|------|-------------|
| (inherited from `TSHealthDailyModel`) | See parent class | All properties from the parent daily model class |

## Enumerations

No public enumerations are defined in this module.

## Callback Types

### TSCompletionBlock

```objc
typedef void (^TSCompletionBlock)(NSError * _Nullable error);
```

Standard completion callback for operations that return only an error status.

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError *` | Error information if operation failed, nil if successful |

### ECG Start Handler

```objc
void(^)(BOOL success, NSError * _Nullable error)
```

Callback for when ECG measurement starts or fails to start.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the measurement started successfully |
| `error` | `NSError *` | Error information if failed, nil if successful |

### ECG Data Handler

```objc
void(^)(TSECGValueItem * _Nullable data, NSError * _Nullable error)
```

Callback to receive real-time ECG measurement data.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `TSECGValueItem *` | Real-time ECG measurement data, nil if error occurs |
| `error` | `NSError *` | Error information if data reception fails, nil if successful |

### ECG End Handler

```objc
void(^)(BOOL success, NSError * _Nullable error)
```

Callback for when ECG measurement ends normally or abnormally.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the measurement ended normally (YES) or was interrupted (NO) |
| `error` | `NSError *` | Error information if measurement ended abnormally, nil if normal end |

### Auto Monitor Config Completion Handler

```objc
void (^)(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error)
```

Callback for automatic ECG monitoring configuration retrieval.

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorConfigs *` | Current automatic ECG monitoring configuration |
| `error` | `NSError *` | Error information if retrieval failed, nil if successful |

### Raw ECG Data Sync Completion Handler

```objc
void (^)(NSArray<TSECGValueItem *> * _Nullable ecgItems, NSError * _Nullable error)
```

Callback for raw ECG data synchronization.

| Parameter | Type | Description |
|-----------|------|-------------|
| `ecgItems` | `NSArray<TSECGValueItem *> *` | Array of synchronized raw ECG measurement items |
| `error` | `NSError *` | Error information if synchronization failed, nil if successful |

### Daily ECG Data Sync Completion Handler

```objc
void (^)(NSArray<TSECGDailyModel *> * _Nullable dailyModels, NSError * _Nullable error)
```

Callback for daily ECG data synchronization.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dailyModels` | `NSArray<TSECGDailyModel *> *` | Array of synchronized daily ECG models, each representing one day |
| `error` | `NSError *` | Error information if synchronization failed, nil if successful |

## API Reference

### Check if device supports manual ECG measurement

Check whether the connected device supports manual ECG measurement functionality.

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**Returns:** `BOOL` — YES if the device supports manual ECG measurement, NO otherwise

**Code Example:**

```objc
id<TSElectrocardioInterface> ecgInterface = /* obtained from health kit */;
if ([ecgInterface isSupportActivityMeasureByUser]) {
    TSLog(@"Device supports manual ECG measurement");
} else {
    TSLog(@"Device does not support manual ECG measurement");
}
```

### Start ECG measurement

Start an ECG measurement with specified parameters and receive real-time data updates.

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSECGValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `measureParam` | `TSActivityMeasureParam *` | Parameters for the measurement activity |
| `startHandler` | `void(^)(BOOL success, NSError * _Nullable error)` | Block called when measurement starts or fails to start |
| `dataHandler` | `void(^)(TSECGValueItem * _Nullable data, NSError * _Nullable error)` | Block to receive real-time ECG measurement data |
| `endHandler` | `void(^)(BOOL success, NSError * _Nullable error)` | Block called when measurement ends normally or abnormally |

**Code Example:**

```objc
id<TSElectrocardioInterface> ecgInterface = /* obtained from health kit */;
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];

[ecgInterface startMeasureWithParam:param
    startHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            TSLog(@"ECG measurement started successfully");
        } else {
            TSLog(@"Failed to start measurement: %@", error.localizedDescription);
        }
    }
    dataHandler:^(TSECGValueItem * _Nullable data, NSError * _Nullable error) {
        if (data) {
            TSLog(@"Heart rate: %ld BPM, Rhythm: %@", 
                  (long)data.heartRate, data.rhythmClassification);
        } else if (error) {
            TSLog(@"Error receiving data: %@", error.localizedDescription);
        }
    }
    endHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            TSLog(@"ECG measurement completed normally");
        } else {
            TSLog(@"ECG measurement interrupted or failed: %@", 
                  error.localizedDescription);
        }
    }
];
```

### Stop ECG measurement

Stop the currently ongoing ECG measurement.

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Completion block called when the measurement stops or fails to stop |

**Code Example:**

```objc
id<TSElectrocardioInterface> ecgInterface = /* obtained from health kit */;

[ecgInterface stopMeasureCompletion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"ECG measurement stopped successfully");
    } else {
        TSLog(@"Failed to stop measurement: %@", error.localizedDescription);
    }
}];
```

### Check if device supports automatic ECG monitoring

Check whether the connected device supports automatic ECG monitoring functionality.

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**Returns:** `BOOL` — YES if the device supports automatic ECG monitoring, NO otherwise

**Code Example:**

```objc
id<TSElectrocardioInterface> ecgInterface = /* obtained from health kit */;
if ([ecgInterface isSupportAutomaticMonitoring]) {
    TSLog(@"Device supports automatic ECG monitoring");
} else {
    TSLog(@"Device does not support automatic ECG monitoring");
}
```

### Configure automatic ECG monitoring

Set up or update automatic ECG monitoring configuration on the device.

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorConfigs *` | Configuration parameters for automatic ECG monitoring |
| `completion` | `TSCompletionBlock` | Completion block called when configuration is set or fails to set |

**Code Example:**

```objc
id<TSElectrocardioInterface> ecgInterface = /* obtained from health kit */;
TSAutoMonitorConfigs *configs = [[TSAutoMonitorConfigs alloc] init];
// Configure monitoring settings...

[ecgInterface pushAutoMonitorConfigs:configs completion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"Automatic ECG monitoring configured successfully");
    } else {
        TSLog(@"Failed to configure monitoring: %@", error.localizedDescription);
    }
}];
```

### Fetch current automatic ECG monitoring configuration

Retrieve the current automatic ECG monitoring configuration from the device.

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs * _Nullable, NSError * _Nullable)` | Completion block with current configuration or error |

**Code Example:**

```objc
id<TSElectrocardioInterface> ecgInterface = /* obtained from health kit */;

[ecgInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error) {
    if (configuration) {
        TSLog(@"Current monitoring configuration retrieved");
        // Process configuration...
    } else {
        TSLog(@"Failed to fetch configuration: %@", error.localizedDescription);
    }
}];
```

### Synchronize raw ECG data within a time range

Synchronize raw ECG measurement data within a specified time range.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSECGValueItem *> *_Nullable ecgItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970) |
| `endTime` | `NSTimeInterval` | End time for data synchronization (timestamp in seconds since 1970) |
| `completion` | `void (^)(NSArray<TSECGValueItem *> * _Nullable, NSError * _Nullable)` | Completion block with synchronized raw ECG items or error |

**Code Example:**

```objc
id<TSElectrocardioInterface> ecgInterface = /* obtained from health kit */;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-86400]; // 24 hours ago
NSDate *endDate = [NSDate date]; // now

[ecgInterface syncRawDataFromStartTime:[startDate timeIntervalSince1970]
                               endTime:[endDate timeIntervalSince1970]
                            completion:^(NSArray<TSECGValueItem *> *_Nullable ecgItems, NSError *_Nullable error) {
    if (ecgItems) {
        TSLog(@"Synchronized %lu raw ECG items", (unsigned long)ecgItems.count);
        for (TSECGValueItem *item in ecgItems) {
            TSLog(@"Heart rate: %ld BPM, Duration: %.1f seconds", 
                  (long)item.heartRate, item.recordingDuration);
        }
    } else {
        TSLog(@"Failed to synchronize raw data: %@", error.localizedDescription);
    }
}];
```

### Synchronize raw ECG data from start time to now

Synchronize raw ECG measurement data from a specified start time until the current time.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSECGValueItem *> *_Nullable ecgItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970) |
| `completion` | `void (^)(NSArray<TSECGValueItem *> * _Nullable, NSError * _Nullable)` | Completion block with synchronized raw ECG items or error |

**Code Example:**

```objc
id<TSElectrocardioInterface> ecgInterface = /* obtained from health kit */;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-604800]; // 7 days ago

[ecgInterface syncRawDataFromStartTime:[startDate timeIntervalSince1970]
                            completion:^(NSArray<TSECGValueItem *> *_Nullable ecgItems, NSError *_Nullable error) {
    if (ecgItems) {
        TSLog(@"Synchronized %lu raw ECG items from the past 7 days", 
              (unsigned long)ecgItems.count);
    } else {
        TSLog(@"Failed to synchronize data: %@", error.localizedDescription);
    }
}];
```

### Synchronize daily ECG data within a time range

Synchronize daily aggregated ECG data within a specified time range.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSECGDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970), will be normalized to 00:00:00 of the specified day |
| `endTime` | `NSTimeInterval` | End time for data synchronization (timestamp in seconds since 1970), will be normalized to 23:59:59 of the specified day, must be later than startTime and not in the future |
| `completion` | `void (^)(NSArray<TSECGDailyModel *> * _Nullable, NSError * _Nullable)` | Completion block with synchronized daily ECG models or error |

**Code Example:**

```objc
id<TSElectrocardioInterface> ecgInterface = /* obtained from health kit */;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-2592000]; // 30 days ago
NSDate *endDate = [NSDate date]; // today

[ecgInterface syncDailyDataFromStartTime:[startDate timeIntervalSince1970]
                                endTime:[endDate timeIntervalSince1970]
                             completion:^(NSArray<TSECGDailyModel *> *_Nullable dailyModels, NSError *_Nullable error) {
    if (dailyModels) {
        TSLog(@"Synchronized %lu days of daily ECG data", (unsigned long)dailyModels.count);
        for (TSECGDailyModel *dailyModel in dailyModels) {
            TSLog(@"Date: %@", dailyModel.timestamp);
        }
    } else {
        TSLog(@"Failed to synchronize daily data: %@", error.localizedDescription);
    }
}];
```

### Synchronize daily ECG data from start time to now

Synchronize daily aggregated ECG data from a specified start time until the current time.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSECGDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time for data synchronization (timestamp in seconds since 1970), will be normalized to 00:00:00 of the specified day |
| `completion` | `void (^)(NSArray<TSECGDailyModel *> * _Nullable, NSError * _Nullable)` | Completion block with synchronized daily ECG models or error |

**Code Example:**

```objc
id<TSElectrocardioInterface> ecgInterface = /* obtained from health kit */;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-2592000]; // 30 days ago

[ecgInterface syncDailyDataFromStartTime:[startDate timeIntervalSince1970]
                              completion:^(NSArray<TSECGDailyModel *> *_Nullable dailyModels, NSError *_Nullable error) {
    if (dailyModels) {
        TSLog(@"Synchronized %lu days of daily ECG data from the past 30 days", 
              (unsigned long)dailyModels.count);
    } else {
        TSLog(@"Failed to synchronize daily data: %@", error.localizedDescription);
    }
}];
```

## Important Notes

1. Always check device capability before attempting manual or automatic ECG measurements using `isSupportActivityMeasureByUser` or `isSupportAutomaticMonitoring` methods.

2. ECG measurements are asynchronous operations. Use the provided handler blocks to track progress and receive real-time data updates during measurement.

3. Time parameters for synchronization methods use UNIX timestamp (seconds since January 1, 1970). Use `NSDate` methods like `timeIntervalSince1970` to convert dates.

4. Daily data synchronization automatically normalizes time boundaries to midnight (00:00:00) for start time and 23:59:59 for end time of the specified days.

5. Completion and handler blocks are executed on the main thread, making it safe to update UI directly within the blocks.

6. All ECG data synchronization operations should be performed after the device is properly connected and authenticated.

7. The `isUserInitiated` property in `TSECGValueItem` indicates whether the measurement was manually triggered by the user or initiated by automatic monitoring.

8. Rhythm classification and confidence scores provide algorithmic interpretations but may require professional medical review for clinical use.

9. Heart rate variability (HRV) metrics are provided in dictionary format with metric names as keys and numerical values as values (e.g., "SDNN", "RMSSD", "pNN50").

10. When stopping a measurement, ensure the completion block is handled appropriately, as stopping may take time and can fail if the device is disconnected.