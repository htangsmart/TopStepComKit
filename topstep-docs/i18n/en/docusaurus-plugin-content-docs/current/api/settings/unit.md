---
sidebar_position: 2
title: Unit
---

# TSUnit

The TSUnit module provides comprehensive unit management functionality for the TopStepComKit SDK. It enables applications to configure and retrieve various measurement units including length, temperature, weight, time format, and overall unit system preferences. This module supports both metric and imperial unit systems, allowing developers to adapt their applications to different regional preferences and user requirements.

## Prerequisites

- TopStepComKit SDK initialized and connected
- User authenticated and authorized
- Device supports unit configuration operations
- Bluetooth connection established (if device-side changes are required)

## Data Models

No data models are defined in this module.

## Enumerations

### TSLengthUnit

Length unit type enumeration.

| Value | Description |
|-------|-------------|
| `TSLengthUnitMetric` | Metric system (kilometers/meters) |
| `TSLengthUnitImperial` | Imperial system (miles/feet) |

### TSTemperatureUnit

Temperature unit type enumeration.

| Value | Description |
|-------|-------------|
| `TSTemperatureUnitCelsius` | Celsius temperature scale |
| `TSTemperatureUnitFahrenheit` | Fahrenheit temperature scale |

### TSWeightUnit

Weight unit type enumeration.

| Value | Description |
|-------|-------------|
| `TSWeightUnitKG` | Kilogram unit |
| `TSWeightUnitLB` | Pound unit |

### TSTimeFormat

Time format type enumeration.

| Value | Description |
|-------|-------------|
| `TSTimeFormat12Hour` | 12-hour time format |
| `TSTimeFormat24Hour` | 24-hour time format |

### TSUnitSystem

Unit system type enumeration.

| Value | Description |
|-------|-------------|
| `TSUnitSystemMetric` | Metric unit system (kilometers, kilograms, Celsius) |
| `TSUnitSystemImperial` | Imperial unit system (miles, pounds, Fahrenheit) |

## Callback Types

### TSCompletionBlock

```objc
typedef void (^TSCompletionBlock)(NSError * _Nullable error);
```

General completion callback for unit setting operations.

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError * _Nullable` | Error object if operation failed, nil on success |

## API Reference

### Set length unit

Configure the length unit for distance display across the application.

```objc
- (void)setLengthUnit:(TSLengthUnit)unit
           completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `unit` | `TSLengthUnit` | Length unit type (metric/imperial) |
| `completion` | `TSCompletionBlock` | Completion callback invoked when operation finishes |

**Code Example:**

```objc
id<TSUnitInterface> unitManager = [topStepComKit getUnitInterface];

[unitManager setLengthUnit:TSLengthUnitMetric 
                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set length unit: %@", error.localizedDescription);
    } else {
        TSLog(@"Length unit set to metric successfully");
    }
}];
```

### Get current length unit

Retrieve the currently configured length unit.

```objc
- (void)getCurrentLengthUnit:(void(^)(TSLengthUnit unit, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSLengthUnit, NSError *)` | Callback returning current length unit and error if any |

**Code Example:**

```objc
id<TSUnitInterface> unitManager = [topStepComKit getUnitInterface];

[unitManager getCurrentLengthUnit:^(TSLengthUnit unit, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get length unit: %@", error.localizedDescription);
    } else {
        NSString *unitName = (unit == TSLengthUnitMetric) ? @"Metric" : @"Imperial";
        TSLog(@"Current length unit: %@", unitName);
    }
}];
```

### Set temperature unit

Configure the temperature unit for temperature display.

```objc
- (void)setTemperatureUnit:(TSTemperatureUnit)unit
                completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `unit` | `TSTemperatureUnit` | Temperature unit type (Celsius/Fahrenheit) |
| `completion` | `TSCompletionBlock` | Completion callback invoked when operation finishes |

**Code Example:**

```objc
id<TSUnitInterface> unitManager = [topStepComKit getUnitInterface];

[unitManager setTemperatureUnit:TSTemperatureUnitCelsius 
                     completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set temperature unit: %@", error.localizedDescription);
    } else {
        TSLog(@"Temperature unit set to Celsius successfully");
    }
}];
```

### Get current temperature unit

Retrieve the currently configured temperature unit.

```objc
- (void)getCurrentTemperatureUnit:(void(^)(TSTemperatureUnit unit, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSTemperatureUnit, NSError *)` | Callback returning current temperature unit and error if any |

**Code Example:**

```objc
id<TSUnitInterface> unitManager = [topStepComKit getUnitInterface];

[unitManager getCurrentTemperatureUnit:^(TSTemperatureUnit unit, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get temperature unit: %@", error.localizedDescription);
    } else {
        NSString *unitName = (unit == TSTemperatureUnitCelsius) ? @"Celsius" : @"Fahrenheit";
        TSLog(@"Current temperature unit: %@", unitName);
    }
}];
```

### Set weight unit

Configure the weight unit for weight display.

```objc
- (void)setWeightUnit:(TSWeightUnit)unit
           completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `unit` | `TSWeightUnit` | Weight unit type (KG/LB) |
| `completion` | `TSCompletionBlock` | Completion callback invoked when operation finishes |

**Code Example:**

```objc
id<TSUnitInterface> unitManager = [topStepComKit getUnitInterface];

[unitManager setWeightUnit:TSWeightUnitKG 
                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set weight unit: %@", error.localizedDescription);
    } else {
        TSLog(@"Weight unit set to kilogram successfully");
    }
}];
```

### Get current weight unit

Retrieve the currently configured weight unit.

```objc
- (void)getCurrentWeightUnit:(void(^)(TSWeightUnit unit, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSWeightUnit, NSError *)` | Callback returning current weight unit and error if any |

**Code Example:**

```objc
id<TSUnitInterface> unitManager = [topStepComKit getUnitInterface];

[unitManager getCurrentWeightUnit:^(TSWeightUnit unit, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get weight unit: %@", error.localizedDescription);
    } else {
        NSString *unitName = (unit == TSWeightUnitKG) ? @"KG" : @"LB";
        TSLog(@"Current weight unit: %@", unitName);
    }
}];
```

### Set time format

Configure the time display format (12-hour or 24-hour).

```objc
- (void)setTimeFormat:(TSTimeFormat)format
           completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `format` | `TSTimeFormat` | Time format type (12/24 hour) |
| `completion` | `TSCompletionBlock` | Completion callback invoked when operation finishes |

**Code Example:**

```objc
id<TSUnitInterface> unitManager = [topStepComKit getUnitInterface];

[unitManager setTimeFormat:TSTimeFormat24Hour 
                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set time format: %@", error.localizedDescription);
    } else {
        TSLog(@"Time format set to 24-hour successfully");
    }
}];
```

### Get current time format

Retrieve the currently configured time format.

```objc
- (void)getCurrentTimeFormat:(void(^)(TSTimeFormat format, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSTimeFormat, NSError *)` | Callback returning current time format and error if any |

**Code Example:**

```objc
id<TSUnitInterface> unitManager = [topStepComKit getUnitInterface];

[unitManager getCurrentTimeFormat:^(TSTimeFormat format, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get time format: %@", error.localizedDescription);
    } else {
        NSString *formatName = (format == TSTimeFormat24Hour) ? @"24-hour" : @"12-hour";
        TSLog(@"Current time format: %@", formatName);
    }
}];
```

### Set unit system

Configure the overall unit system, which sets both length and weight units simultaneously.

```objc
- (void)setUnitSystem:(TSUnitSystem)system
           completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `system` | `TSUnitSystem` | Unit system type (metric/imperial) |
| `completion` | `TSCompletionBlock` | Completion callback invoked when operation finishes |

**Code Example:**

```objc
id<TSUnitInterface> unitManager = [topStepComKit getUnitInterface];

[unitManager setUnitSystem:TSUnitSystemMetric 
                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set unit system: %@", error.localizedDescription);
    } else {
        TSLog(@"Unit system set to metric (km, kg) successfully");
    }
}];
```

### Get current unit system

Retrieve the currently configured unit system.

```objc
- (void)getUnitSystemCompletion:(void(^)(TSUnitSystem system, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSUnitSystem, NSError *)` | Callback returning current unit system and error if any |

**Code Example:**

```objc
id<TSUnitInterface> unitManager = [topStepComKit getUnitInterface];

[unitManager getUnitSystemCompletion:^(TSUnitSystem system, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get unit system: %@", error.localizedDescription);
    } else {
        NSString *systemName = (system == TSUnitSystemMetric) ? @"Metric" : @"Imperial";
        TSLog(@"Current unit system: %@", systemName);
    }
}];
```

## Important Notes

1. **Unit System Consistency**: When using `setUnitSystem:completion:` and `getUnitSystemCompletion:`, avoid mixing with individual length and weight unit setters/getters to maintain consistency across the application.

2. **Asynchronous Operations**: All unit setting and retrieval operations are asynchronous. Always implement the completion callbacks to handle success and error cases appropriately.

3. **Error Handling**: Always check the error parameter in completion callbacks. Operations may fail due to device disconnection, invalid permissions, or network issues.

4. **Device Synchronization**: Unit changes may require synchronization with the connected device. Ensure Bluetooth connection is stable before changing units.

5. **Regional Preferences**: Temperature and time format settings are typically associated with locale settings. Consider user preferences when setting these values.

6. **Metric vs Imperial**: The metric system includes kilometers/meters for length and kilograms for weight. The imperial system includes miles/feet for length and pounds for weight.

7. **Completion Callback Threading**: Completion callbacks may be invoked on background threads. If updating UI elements, dispatch to the main thread using `dispatch_async(dispatch_get_main_queue(), ...)`.