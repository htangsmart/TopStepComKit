---
sidebar_position: 1
title: Battery
---

# TSBattery

The TSBattery module provides comprehensive device battery management capabilities, allowing you to retrieve current battery information including charge level and charging status, as well as monitor real-time changes in battery state. This module is essential for applications that need to track device power status and respond to battery state transitions.

## Prerequisites

- Device must be connected and authenticated before battery operations
- Battery information updates are asynchronous and may take a few milliseconds
- Ensure the completion callbacks are properly implemented to handle battery data

## Data Models

### TSBatteryModel

Battery information model containing device power state and charge level.

| Property | Type | Description |
|----------|------|-------------|
| `chargeState` | `TSBatteryState` | Current charging state of the device (see TSBatteryState enum) |
| `percentage` | `UInt8` | Battery charge percentage, ranging from 0 to 100 |

## Enumerations

### TSBatteryState

Defines the charging state of the device battery.

| Value | Numeric | Description |
|-------|---------|-------------|
| `TSBatteryStateUnknown` | 1 | Charging state is unknown or indeterminate |
| `TSBatteryStateCharging` | 2 | Device is connected to power and actively charging |
| `TSBatteryStateUnConnectNoCharging` | 3 | Device is not connected to any power source |
| `TSBatteryStateConnectNotCharging` | 4 | Device is connected to power but not charging |
| `TSBatteryStateFull` | 5 | Battery is fully charged |

## Callback Types

### TSBatteryBlock

```objc
typedef void (^TSBatteryBlock)(TSBatteryModel *_Nullable batteryModel, NSError *_Nullable error);
```

Completion callback for battery operations.

| Parameter | Type | Description |
|-----------|------|-------------|
| `batteryModel` | `TSBatteryModel *` | Battery information model containing level and charging status; `nil` if operation failed |
| `error` | `NSError *` | Error information if the operation failed; `nil` if successful |

## API Reference

### Get current battery information

Retrieve the device's current battery charge level and charging status.

```objc
- (void)getBatteryInfoCompletion:(nullable TSBatteryBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSBatteryBlock` | Callback block invoked when battery information is retrieved |

**Code Example:**

```objc
id<TSBatteryInterface> batteryInterface = [device batteryInterface];

[batteryInterface getBatteryInfoCompletion:^(TSBatteryModel * _Nullable batteryModel, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get battery info: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Battery Percentage: %d%%", batteryModel.percentage);
    
    switch (batteryModel.chargeState) {
        case TSBatteryStateUnknown:
            TSLog(@"Charging state: Unknown");
            break;
        case TSBatteryStateCharging:
            TSLog(@"Charging state: Charging");
            break;
        case TSBatteryStateUnConnectNoCharging:
            TSLog(@"Charging state: Not connected");
            break;
        case TSBatteryStateConnectNotCharging:
            TSLog(@"Charging state: Connected but not charging");
            break;
        case TSBatteryStateFull:
            TSLog(@"Charging state: Full");
            break;
    }
}];
```

### Register battery information change listener

Register a callback to monitor real-time changes in device battery status.

```objc
- (void)registerBatteryDidChanged:(nullable TSBatteryBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSBatteryBlock` | Callback block invoked whenever battery information changes |

**Code Example:**

```objc
id<TSBatteryInterface> batteryInterface = [device batteryInterface];

[batteryInterface registerBatteryDidChanged:^(TSBatteryModel * _Nullable batteryModel, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Battery listener error: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Battery updated - Percentage: %d%%, State: %d", 
          batteryModel.percentage, 
          batteryModel.chargeState);
    
    if (batteryModel.percentage < 20) {
        TSLog(@"Warning: Battery level is low!");
    }
}];
```

## Important Notes

1. Battery percentage values range from 0 to 100 and represent the approximate charge level of the device
2. The `registerBatteryDidChanged:` callback will be triggered whenever the device detects a change in battery state or charge percentage
3. Always check the `error` parameter in callbacks; a `nil` error indicates successful operation
4. Multiple listeners can be registered for battery changes without conflicts
5. Battery information is read-only and cannot be modified through this interface
6. The TSBatteryModel initializer `initWithPercentage:chargeState:` is the designated initializer; default `init` is unavailable
7. TSBatteryModel instances cannot be copied; each query returns a fresh model instance