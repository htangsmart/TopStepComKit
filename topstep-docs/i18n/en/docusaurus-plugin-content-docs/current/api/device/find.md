---
sidebar_position: 2
title: PeripheralFind
---

# PeripheralFind Module

The PeripheralFind module provides bidirectional device finding functionality between iPhone and peripheral devices. It enables iPhone to initiate device searches, devices to initiate iPhone searches, and mutual notifications when either party is found. This module supports callback registration for various finding events and state changes.

## Prerequisites

- Device must be connected via Bluetooth
- Device firmware must support finding functionality
- `TSPeripheralFindInterface` must be implemented by the connected device
- All callbacks should be registered before initiating find operations for proper event delivery

## Callback Types

| Callback Name | Signature | Description |
|---------------|-----------|-------------|
| `PeripheralFindPhoneBlock` | `void (^)(void)` | Triggered when device initiates finding iPhone or when device stops finding iPhone. No parameters or return value. |
| `TSCompletionBlock` | `void (^)(NSError *)` | Generic completion callback. Called when an operation completes with optional error information. |

## API Reference

### iPhone initiates device search

```objc
- (void)beginFindPeripheral:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(NSError *)` | Callback invoked immediately after the find command is sent. Register `peripheralHasBeenFound` callback to receive device response notifications. |

**Code Example:**

```objc
id<TSPeripheralFindInterface> findInterface = (id<TSPeripheralFindInterface>)device;

// Register callback to receive device response before starting search
[findInterface registerPeripheralHasBeenFound:^{
    TSLog(@"Device has been found!");
}];

// Start finding the device
[findInterface beginFindPeripheral:^(NSError *error) {
    if (error) {
        TSLog(@"Failed to send find command: %@", error.localizedDescription);
    } else {
        TSLog(@"Find command sent successfully");
    }
}];
```

### iPhone stops device search

```objc
- (void)stopFindPeripheral:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(NSError *)` | Callback invoked when the stop finding operation completes. |

**Code Example:**

```objc
id<TSPeripheralFindInterface> findInterface = (id<TSPeripheralFindInterface>)device;

[findInterface stopFindPeripheral:^(NSError *error) {
    if (error) {
        TSLog(@"Failed to stop finding: %@", error.localizedDescription);
    } else {
        TSLog(@"Find operation stopped successfully");
    }
}];
```

### Register callback for device found response

```objc
- (void)registerPeripheralHasBeenFound:(PeripheralFindPhoneBlock)peripheralHasBeenFound;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `peripheralHasBeenFound` | `void (^)(void)` | Callback triggered when device responds to the find request initiated by `beginFindPeripheral:`. |

**Code Example:**

```objc
id<TSPeripheralFindInterface> findInterface = (id<TSPeripheralFindInterface>)device;

[findInterface registerPeripheralHasBeenFound:^{
    TSLog(@"Device responded to find request - device found!");
    // Update UI to indicate device has been found
}];
```

### Register listener for device finding iPhone

```objc
- (void)registerPeripheralFindPhone:(PeripheralFindPhoneBlock)peripheralFindPhoneBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `peripheralFindPhoneBlock` | `void (^)(void)` | Callback triggered when device initiates a request to find iPhone. |

**Code Example:**

```objc
id<TSPeripheralFindInterface> findInterface = (id<TSPeripheralFindInterface>)device;

[findInterface registerPeripheralFindPhone:^{
    TSLog(@"Device is trying to find iPhone!");
    // Play alert sound or trigger vibration on iPhone
    // Trigger notification to user
}];
```

### Register listener for device stopping iPhone search

```objc
- (void)registerPeripheralStopFindPhone:(PeripheralFindPhoneBlock)peripheralStopFindPhoneBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `peripheralStopFindPhoneBlock` | `void (^)(void)` | Callback triggered when device stops finding iPhone. |

**Code Example:**

```objc
id<TSPeripheralFindInterface> findInterface = (id<TSPeripheralFindInterface>)device;

[findInterface registerPeripheralStopFindPhone:^{
    TSLog(@"Device stopped searching for iPhone");
    // Stop alert sound or vibration
    // Dismiss notification
}];
```

### Notify device that iPhone has been found

```objc
- (void)notifyPeripheralPhoneHasBeenFound:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(NSError *)` | Callback invoked when the notification operation completes. |

**Code Example:**

```objc
id<TSPeripheralFindInterface> findInterface = (id<TSPeripheralFindInterface>)device;

[findInterface notifyPeripheralPhoneHasBeenFound:^(NSError *error) {
    if (error) {
        TSLog(@"Failed to notify device: %@", error.localizedDescription);
    } else {
        TSLog(@"Device notified that iPhone has been found");
    }
}];
```

## Important Notes

1. Register all callbacks before initiating find operations to ensure proper event delivery
2. The `completion` callback in `beginFindPeripheral:` only indicates that the command was sent successfully, not that the device has been found—use the `peripheralHasBeenFound` callback to detect when device responds
3. When the device initiates a find iPhone request (via `registerPeripheralFindPhone:`), respond with `notifyPeripheralPhoneHasBeenFound:` to inform the device that iPhone has been located
4. Bidirectional finding is supported: iPhone can find device and device can find iPhone independently
5. Always call `stopFindPeripheral:` to properly terminate a find operation before starting a new one
6. Multiple callbacks can be registered; ensure they are set up during initialization or connection phase