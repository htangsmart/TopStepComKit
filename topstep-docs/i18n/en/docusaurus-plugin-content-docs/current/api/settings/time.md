---
sidebar_position: 4
title: Time
---

# TSTime

The TSTime module provides comprehensive time management capabilities for connected devices, enabling synchronization of system time, setting of specific times, and configuration of world time zones.

## Prerequisites

- Device must be connected and in a ready state
- Time synchronization requires valid system time on the host device
- World clock configuration requires valid timezone identifiers

## Data Models

### TSWorldClockModel

| Property | Type | Description |
|----------|------|-------------|
| `timezone` | `NSString *` | Timezone identifier (e.g., "America/New_York") |
| `displayName` | `NSString *` | User-friendly timezone display name |
| `offset` | `NSInteger` | UTC offset in seconds |

## Enumerations

No enumerations defined in this module.

## Callback Types

### TSCompletionBlock

```objc
typedef void (^TSCompletionBlock)(NSError * _Nullable error);
```

Completion callback for asynchronous time operations.

| Parameter | Type | Description |
|-----------|------|-------------|
| `error` | `NSError *` | Error object if operation failed, `nil` if successful |

## API Reference

### Set system time to watch

Synchronize current system time from the phone to the connected device. The time format (12/24-hour) is configured separately via `setTimeFormat:completion:` in the Unit Settings module.

```objc
- (void)setSystemTimeWithCompletion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Setting completion callback |

**Code Example:**

```objc
id<TSTimeInterface> timeInterface = (id<TSTimeInterface>)self.kitManager;

[timeInterface setSystemTimeWithCompletion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set system time: %@", error.localizedDescription);
    } else {
        TSLog(@"System time synchronized successfully");
    }
}];
```

### Set specific time to watch

Set a specified time to the connected device. The time format (12/24-hour) is configured separately via `setTimeFormat:completion:` in the Unit Settings module.

```objc
- (void)setSpecificTime:(NSDate *)date
             completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `date` | `NSDate *` | Time to set |
| `completion` | `TSCompletionBlock` | Setting completion callback |

**Code Example:**

```objc
id<TSTimeInterface> timeInterface = (id<TSTimeInterface>)self.kitManager;

// Create a specific date (e.g., 2025-02-20 14:30:00)
NSDateComponents *components = [[NSDateComponents alloc] init];
components.year = 2025;
components.month = 2;
components.day = 20;
components.hour = 14;
components.minute = 30;
components.second = 0;

NSCalendar *calendar = [NSCalendar currentCalendar];
NSDate *specificDate = [calendar dateFromComponents:components];

[timeInterface setSpecificTime:specificDate completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set specific time: %@", error.localizedDescription);
    } else {
        TSLog(@"Specific time set successfully: %@", specificDate);
    }
}];
```

## Important Notes

1. All time operations are asynchronous and require a valid completion block
2. The time format (12/24-hour) is configured via `setTimeFormat:completion:` in the Unit Settings module, independent of time synchronization
3. The device must remain connected throughout the time setting operation
4. System time synchronization uses the current device system time; ensure device time is accurate before synchronization
5. When setting specific times, ensure the `NSDate` object is properly initialized with valid date components
6. Time operations may be rate-limited; avoid sending multiple time requests in rapid succession
7. Device timezone settings should be configured separately if world clock functionality is required