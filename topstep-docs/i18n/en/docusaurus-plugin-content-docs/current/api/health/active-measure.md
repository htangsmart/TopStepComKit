---
sidebar_position: 12
title: ActivityMeasure
---

# TSActivityMeasure Module

The TSActivityMeasure module provides comprehensive active health measurement capabilities, enabling real-time data collection for various health metrics including heart rate, blood pressure, blood oxygen, stress, temperature, and ECG. This module allows developers to initiate custom measurement sessions with configurable parameters, receive real-time measurement data through callbacks, and manage measurement lifecycle events.

## Prerequisites

- Device must be connected and authenticated
- Device must support the specific measurement type being requested
- Measurement parameters must be properly configured before starting
- Observer callbacks should be registered before starting measurement for optimal data reception

## Data Models

### TSActivityMeasureParam

Active measurement parameters model that configures health measurement sessions.

| Property | Type | Description |
|----------|------|-------------|
| `measureType` | `TSActiveMeasureType` | Type of measurement to perform; only one measurement type can be selected at a time |
| `interval` | `UInt8` | Sampling interval in seconds; defines time between consecutive measurements |
| `maxMeasureDuration` | `UInt8` | Maximum measurement duration in seconds; measurement automatically stops after this duration (default: 60, minimum: 15, or 0 for continuous) |

## Enumerations

### TSActiveMeasureType

Enumeration defining different types of health measurements supported by the device.

| Value | Numeric | Description |
|-------|---------|-------------|
| `TSMeasureTypeNone` | 0 | No measurement selected |
| `TSMeasureTypeHeartRate` | 1 | Heart rate monitoring |
| `TSMeasureTypeBloodOxygen` | 2 | Blood oxygen saturation (SpO2) measurement |
| `TSMeasureTypeBloodPressure` | 3 | Systolic and diastolic blood pressure measurement |
| `TSMeasureTypeStress` | 4 | Mental stress level assessment |
| `TSMeasureTypeTemperature` | 5 | Body temperature measurement |
| `TSMeasureTypeECG` | 6 | Electrocardiogram recording |

## Callback Types

### Measurement Data Change Callback

```objc
void(^)(TSHealthValueItem * _Nullable realtimeData, NSError * _Nullable error)
```

Invoked when real-time measurement data is received from the device.

| Parameter | Type | Description |
|-----------|------|-------------|
| `realtimeData` | `TSHealthValueItem * _Nullable` | Real-time measurement data received from device; nil if error occurs |
| `error` | `NSError * _Nullable` | Error information if data reception fails; nil if successful |

### Measurement End Callback

```objc
void(^)(BOOL isFinished, NSError * _Nullable error)
```

Invoked when a measurement session ends.

| Parameter | Type | Description |
|-----------|------|-------------|
| `isFinished` | `BOOL` | Whether the measurement ended normally (YES) or was interrupted (NO) |
| `error` | `NSError * _Nullable` | Error information if measurement ended abnormally; nil if normal end |

## API Reference

### Start health measurement with custom parameters

```objc
+ (void)startMeasureWithParam:(TSActivityMeasureParam *)measureParam 
                   completion:(TSCompletionBlock)completion;
```

Initiates a health measurement session with specified parameters.

| Parameter | Type | Description |
|-----------|------|-------------|
| `measureParam` | `TSActivityMeasureParam *` | Measurement parameters including type, interval, and duration |
| `completion` | `TSCompletionBlock` | Completion callback indicating success or failure of starting measurement |

**Code Example:**

```objc
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.measureType = TSMeasureTypeHeartRate;
param.interval = 1;  // 1 second sampling interval
param.maxMeasureDuration = 60;  // 60 seconds maximum duration

[TSActiveMeasureInterface startMeasureWithParam:param completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to start measurement: %@", error.localizedDescription);
    } else {
        TSLog(@"Measurement started successfully");
    }
}];
```

### Stop ongoing health measurement

```objc
+ (void)stopMeasureWithParam:(TSActivityMeasureParam *)measureParam 
                   completion:(TSCompletionBlock)completion;
```

Stops the currently active health measurement session.

| Parameter | Type | Description |
|-----------|------|-------------|
| `measureParam` | `TSActivityMeasureParam *` | Measurement parameters to identify which measurement to stop |
| `completion` | `TSCompletionBlock` | Completion callback indicating success or failure of stopping measurement |

**Code Example:**

```objc
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.measureType = TSMeasureTypeHeartRate;

[TSActiveMeasureInterface stopMeasureWithParam:param completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to stop measurement: %@", error.localizedDescription);
    } else {
        TSLog(@"Measurement stopped successfully");
    }
}];
```

### Register measurement data change notification

```objc
+ (void)registerMeasurement:(TSActivityMeasureParam *)param
             dataDidChanged:(void(^)(TSHealthValueItem * _Nullable realtimeData, NSError * _Nullable error))dataDidChanged;
```

Registers a notification listener for real-time measurement data reception.

| Parameter | Type | Description |
|-----------|------|-------------|
| `param` | `TSActivityMeasureParam *` | Measurement parameters to identify which measurement data to listen for |
| `dataDidChanged` | `void(^)(TSHealthValueItem * _Nullable, NSError * _Nullable)` | Callback block invoked when measurement data is received |

**Code Example:**

```objc
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.measureType = TSMeasureTypeHeartRate;

[TSActiveMeasureInterface registerMeasurement:param 
                               dataDidChanged:^(TSHealthValueItem * _Nullable realtimeData, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Error receiving measurement data: %@", error.localizedDescription);
    } else if (realtimeData) {
        TSLog(@"Heart Rate: %@ bpm", realtimeData.value);
    }
}];
```

### Register measurement end notification

```objc
+ (void)registerActivityeasureDidFinished:(void(^)(BOOL isFinished, NSError * _Nullable error))didFinished;
```

Registers a notification listener for measurement end events.

| Parameter | Type | Description |
|-----------|------|-------------|
| `didFinished` | `void(^)(BOOL, NSError * _Nullable)` | Callback block invoked when measurement ends |

**Code Example:**

```objc
[TSActiveMeasureInterface registerActivityeasureDidFinished:^(BOOL isFinished, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Measurement ended with error: %@", error.localizedDescription);
    } else if (isFinished) {
        TSLog(@"Measurement completed successfully");
    } else {
        TSLog(@"Measurement was interrupted");
    }
}];
```

## Important Notes

1. **Single Measurement `Type**`: Only one measurement type can be active at a time; starting a new measurement will stop any previously active measurement.

2. **Device Capability `Verification**`: Not all measurement types are supported by all devices; check device capabilities before starting any measurement.

3. **Observer Registration `Timing**`: Register data and end notification observers before starting the measurement to ensure all data is captured from the beginning of the session.

4. **Main Thread `Callbacks**`: All observer callbacks are executed on the main thread; perform UI updates directly without dispatch_async.

5. **Continuous `Measurement**`: Set `maxMeasureDuration` to 0 for continuous measurement until manually stopped; minimum valid value is 15 seconds for timed measurements.

6. **Multiple `Observers**`: Multiple observers can be registered simultaneously for the same measurement; they will all receive callbacks independently.

7. **Measurement Auto-`Stop**`: Measurement automatically stops after reaching the maximum duration; this does not require a manual stop call.

8. **Auto Monitor `Independence**`: Stopping active measurements does not affect auto monitor configurations or scheduled measurements.

9. **No Active `Measurement**`: Calling stop when no measurement is active returns success without errors.

10. **Device `Disconnection**`: Measurement automatically terminates and observers cease receiving data if the device disconnects.