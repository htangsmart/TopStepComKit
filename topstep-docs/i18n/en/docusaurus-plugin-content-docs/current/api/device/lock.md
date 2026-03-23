---
sidebar_position: 3
title: PeripheralLock
---

# PeripheralLock

The PeripheralLock module provides comprehensive management of device screen lock and game lock functionality. It enables querying and configuring lock settings including enabled/disabled state, password protection, and for game locks, time-based activation windows. Both lock types support 6-digit numeric password protection and are configurable through standardized model objects.

## Prerequisites

- Device must support the respective lock feature (screen lock or game lock)
- TSPeripheralLockInterface protocol must be implemented by the device interface class
- All lock passwords must be exactly 6 digits (numeric characters only: '0'-'9')
- Time values for game lock are specified as minute offsets from 00:00 (0–1439)

## Data Models

### TSScreenLockModel

Screen lock configuration model without time range constraints.

| Property | Type | Description |
|----------|------|-------------|
| `isEnabled` | `BOOL` | Whether the lock is active. YES = enabled, NO = disabled. |
| `password` | `NSString *` | 6-digit numeric password string (e.g., "123456"). Must contain only characters '0'-'9' with length exactly 6. |

### TSGameLockModel

Game lock configuration model with time range support for scheduled locking.

| Property | Type | Description |
|----------|------|-------------|
| `isEnabled` | `BOOL` | Whether the lock is active. YES = enabled, NO = disabled. |
| `password` | `NSString *` | 6-digit numeric password string (e.g., "123456"). Must contain only characters '0'-'9' with length exactly 6. |
| `start` | `NSInteger` | Start time as minute offset from 00:00 (0 = 00:00, 60 = 01:00, 540 = 09:00). |
| `end` | `NSInteger` | End time as minute offset from 00:00 (0 = 00:00, 60 = 01:00, 1439 = 23:59). |

## Enumerations

No enumerations defined for this module.

## Callback Types

### TSScreenLockResultBlock

Callback block invoked when querying screen lock information.

```objc
typedef void(^TSScreenLockResultBlock)(TSScreenLockModel * _Nullable model, NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | `TSScreenLockModel *` | Screen lock model containing enabled state and password; nil if query fails. |
| `error` | `NSError *` | Error object if operation fails; nil if successful. |

### TSGameLockResultBlock

Callback block invoked when querying game lock information.

```objc
typedef void(^TSGameLockResultBlock)(TSGameLockModel * _Nullable model, NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | `TSGameLockModel *` | Game lock model containing enabled state, password, and start/end time offsets; nil if query fails. |
| `error` | `NSError *` | Error object if operation fails; nil if successful. |

### TSCompletionBlock

Standard completion callback for set operations.

```objc
typedef void(^TSCompletionBlock)(NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError *` | Error object if operation fails; nil if successful. |

## API Reference

### Check screen lock support

Determine if the device supports screen lock functionality.

```objc
- (BOOL)isSupportScreenLock;
```

**Return `Value**`

| Type | Description |
|------|-------------|
| `BOOL` | YES if screen lock is supported, NO otherwise. |

**`Example**`

```objc
id<TSPeripheralLockInterface> lockInterface = // ... obtain interface
if ([lockInterface isSupportScreenLock]) {
    TSLog(@"Device supports screen lock");
} else {
    TSLog(@"Screen lock not supported");
}
```

### Query screen lock configuration

Retrieve the current screen lock settings from the device.

```objc
- (void)queryScreenLock:(TSScreenLockResultBlock)completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSScreenLockModel *, NSError *)` | Callback block invoked with screen lock model or error. |

**`Example**`

```objc
id<TSPeripheralLockInterface> lockInterface = // ... obtain interface
[lockInterface queryScreenLock:^(TSScreenLockModel * _Nullable model, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Query failed: %@", error.localizedDescription);
    } else {
        TSLog(@"Screen lock enabled: %@", model.isEnabled ? @"YES" : @"NO");
        TSLog(@"Password: %@", model.password);
    }
}];
```

### Set screen lock configuration

Apply screen lock settings to the device.

```objc
- (void)setScreenLock:(TSScreenLockModel *)screenLock completion:(TSCompletionBlock)completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `screenLock` | `TSScreenLockModel *` | Screen lock model with enabled state and 6-digit numeric password. |
| `completion` | `void (^)(NSError *)` | Callback block invoked when operation completes. |

**`Example**`

```objc
id<TSPeripheralLockInterface> lockInterface = // ... obtain interface

TSScreenLockModel *lockModel = [[TSScreenLockModel alloc] init];
lockModel.isEnabled = YES;
lockModel.password = @"123456";

[lockInterface setScreenLock:lockModel completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Set screen lock failed: %@", error.localizedDescription);
    } else {
        TSLog(@"Screen lock configured successfully");
    }
}];
```

### Check game lock support

Determine if the device supports game lock functionality.

```objc
- (BOOL)isSupportGameLock;
```

**Return `Value**`

| Type | Description |
|------|-------------|
| `BOOL` | YES if game lock is supported, NO otherwise. |

**`Example**`

```objc
id<TSPeripheralLockInterface> lockInterface = // ... obtain interface
if ([lockInterface isSupportGameLock]) {
    TSLog(@"Device supports game lock");
} else {
    TSLog(@"Game lock not supported");
}
```

### Query game lock configuration

Retrieve the current game lock settings including time range from the device.

```objc
- (void)queryGameLock:(TSGameLockResultBlock)completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `completion` | `void (^)(TSGameLockModel *, NSError *)` | Callback block invoked with game lock model or error. |

**`Example**`

```objc
id<TSPeripheralLockInterface> lockInterface = // ... obtain interface
[lockInterface queryGameLock:^(TSGameLockModel * _Nullable model, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Query failed: %@", error.localizedDescription);
    } else {
        TSLog(@"Game lock enabled: %@", model.isEnabled ? @"YES" : @"NO");
        TSLog(@"Start time: %ld minutes", (long)model.start);
        TSLog(@"End time: %ld minutes", (long)model.end);
        TSLog(@"Password: %@", model.password);
    }
}];
```

### Set game lock configuration

Apply game lock settings including time range to the device.

```objc
- (void)setGameLock:(TSGameLockModel *)gameLock completion:(TSCompletionBlock)completion;
```

**`Parameters**`

| Name | Type | Description |
|------|------|-------------|
| `gameLock` | `TSGameLockModel *` | Game lock model with enabled state, 6-digit numeric password, and start/end time offsets. |
| `completion` | `void (^)(NSError *)` | Callback block invoked when operation completes. |

**`Example**`

```objc
id<TSPeripheralLockInterface> lockInterface = // ... obtain interface

TSGameLockModel *gameLockModel = [[TSGameLockModel alloc] init];
gameLockModel.isEnabled = YES;
gameLockModel.password = @"654321";
gameLockModel.start = 540;    // 09:00
gameLockModel.end = 720;      // 12:00

[lockInterface setGameLock:gameLockModel completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Set game lock failed: %@", error.localizedDescription);
    } else {
        TSLog(@"Game lock configured successfully");
    }
}];
```

## Important Notes

1. **Password Format `Requirement**`: All lock passwords must be exactly 6 digits. Only numeric characters ('0'-'9') are allowed. Passwords with incorrect format will cause configuration failures.

2. **Time `Representation**`: Game lock start and end times use minute offsets from 00:00 (midnight). Valid range is 0–1439 minutes (0 = 00:00, 1439 = 23:59).

3. **Device Support `Verification**`: Always check device capability before attempting lock operations using `isSupportScreenLock` or `isSupportGameLock` methods to avoid runtime failures.

4. **Model `Difference**`: TSScreenLockModel is used exclusively for screen lock (no time constraints), while TSGameLockModel supports both screen and game lock scenarios with optional time-based activation windows.

5. **Callback `Handling**`: Always check the `error` parameter in completion callbacks before accessing model data. A nil model with nil error does not indicate success—verify error is nil for successful operations.

6. **Asynchronous `Operations**`: All query and set operations are asynchronous. Do not assume operations complete immediately; always use callbacks to handle results.