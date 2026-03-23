---
sidebar_position: 6
title: WorldClock
---

# WorldClock Module

The WorldClock module provides comprehensive functionality for managing world clocks on connected devices. It enables setting, querying, and deleting world clock entries with timezone information, allowing users to track time across multiple cities and regions with support for both 12-hour and 24-hour time formats.

## Prerequisites

- Device must be connected and authenticated before performing world clock operations
- Device firmware must support world clock functionality
- Valid timezone identifiers (IANA timezone database format) must be used for clock configuration

## Data Models

### TSWorldClockModel

World clock model for managing time zone information and city-based time tracking.

| Property | Type | Description |
|----------|------|-------------|
| `clockId` | `UInt8` | Unique identifier for the clock entry (0-255). A random number assigned to each world clock entry. |
| `cityName` | `NSString *` | The name of the city for the world clock. |
| `timeZoneIdentifier` | `NSString *` | The IANA time zone identifier (e.g., "Asia/Shanghai"). |
| `utcOffsetInSeconds` | `NSInteger` | UTC offset in seconds for this time zone. Range is -43200 to +43200. Positive values indicate time zones ahead of UTC, negative values indicate time zones behind UTC. |

## Enumerations

No public enumerations are defined in this module.

## Callback Types

| Type | Description |
|------|-------------|
| `void (^)(NSArray<TSWorldClockModel *> *_Nullable allWorldClocks, NSError * _Nullable error)` | Callback block that returns an array of world clock models and any error that occurred during query operations. |

## API Reference

### Get the maximum number of supported world clocks

Retrieve the maximum number of world clock entries that can be configured on the device.

```objc
- (NSInteger)supportMaxWorldClockCount;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| (return) | `NSInteger` | The maximum number of world clocks that can be set on the device. |

**Code Example:**

```objc
id<TSWorldClockInterface> worldClock = [TopStepComKit sharedInstance].worldClock;
NSInteger maxCount = [worldClock supportMaxWorldClockCount];
TSLog(@"Device supports up to %ld world clocks", (long)maxCount);
```

### Set world clocks for the device

Configure one or more world clock entries on the device. This operation will update the world clock settings with the provided models.

```objc
- (void)setWorldClocks:(NSArray<TSWorldClockModel *> *)worldClocks
            completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `worldClocks` | `NSArray<TSWorldClockModel *> *` | Array of world clock models to be set on the device. |
| `completion` | `TSCompletionBlock` | Callback block to be executed after the operation completes. |

**Code Example:**

```objc
id<TSWorldClockInterface> worldClock = [TopStepComKit sharedInstance].worldClock;

TSWorldClockModel *shanghaiClock = [TSWorldClockModel modelWithClockId:1
                                                               cityName:@"Shanghai"
                                                     timeZoneIdentifier:@"Asia/Shanghai"
                                                     utcOffsetInSeconds:28800];

TSWorldClockModel *newYorkClock = [TSWorldClockModel modelWithClockId:2
                                                                cityName:@"New York"
                                                      timeZoneIdentifier:@"America/New_York"
                                                      utcOffsetInSeconds:-18000];

[worldClock setWorldClocks:@[shanghaiClock, newYorkClock]
                         completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set world clocks: %@", error.localizedDescription);
    } else {
        TSLog(@"World clocks set successfully");
    }
}];
```

### Query all world clocks from the device

Retrieve all world clock entries currently configured on the device.

```objc
- (void)queryWorldClockCompletion:(void(^)(NSArray<TSWorldClockModel *> *_Nullable allWorldClocks, NSError * _Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(NSArray<TSWorldClockModel *> *_Nullable allWorldClocks, NSError * _Nullable error)` | Callback block that returns an array of all world clock models and any error that occurred. |

**Code Example:**

```objc
id<TSWorldClockInterface> worldClock = [TopStepComKit sharedInstance].worldClock;

[worldClock queryWorldClockCompletion:^(NSArray<TSWorldClockModel *> * _Nullable allWorldClocks, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to query world clocks: %@", error.localizedDescription);
    } else {
        for (TSWorldClockModel *clock in allWorldClocks) {
            TSLog(@"Clock: %@ (ID: %d, Offset: %ld seconds)", 
                  clock.cityName, clock.clockId, (long)clock.utcOffsetInSeconds);
        }
    }
}];
```

### Delete a specific world clock from the device

Remove a single world clock entry from the device.

```objc
- (void)deleteWorldClock:(TSWorldClockModel *)worldClock completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `worldClock` | `TSWorldClockModel *` | The world clock model to be deleted from the device. |
| `completion` | `TSCompletionBlock` | Callback block to be executed after the operation completes. |

**Code Example:**

```objc
id<TSWorldClockInterface> worldClock = [TopStepComKit sharedInstance].worldClock;

TSWorldClockModel *clockToDelete = [TSWorldClockModel modelWithClockId:1
                                                                 cityName:@"Shanghai"
                                                       timeZoneIdentifier:@"Asia/Shanghai"
                                                       utcOffsetInSeconds:28800];

[worldClock deleteWorldClock:clockToDelete completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to delete world clock: %@", error.localizedDescription);
    } else {
        TSLog(@"World clock deleted successfully");
    }
}];
```

### Delete all world clocks from the device

Remove all world clock entries currently configured on the device.

```objc
- (void)deleteAllWorldClockCompletion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Callback block to be executed after the operation completes. |

**Code Example:**

```objc
id<TSWorldClockInterface> worldClock = [TopStepComKit sharedInstance].worldClock;

[worldClock deleteAllWorldClockCompletion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to delete all world clocks: %@", error.localizedDescription);
    } else {
        TSLog(@"All world clocks deleted successfully");
    }
}];
```

### Create a world clock model instance

Initialize a new world clock model with the specified parameters.

```objc
+ (instancetype)modelWithClockId:(UInt8)clockId
                        cityName:(NSString *)cityName
              timeZoneIdentifier:(NSString *)timeZoneIdentifier
              utcOffsetInSeconds:(NSInteger)utcOffsetInSeconds;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `clockId` | `UInt8` | The unique identifier for the clock entry (0-255). |
| `cityName` | `NSString *` | The name of the city. |
| `timeZoneIdentifier` | `NSString *` | The IANA time zone identifier. |
| `utcOffsetInSeconds` | `NSInteger` | The UTC offset in seconds (-43200 to +43200). |
| (return) | `TSWorldClockModel *` | A new TSWorldClockModel instance. |

**Code Example:**

```objc
TSWorldClockModel *tokyoClock = [TSWorldClockModel modelWithClockId:3
                                                            cityName:@"Tokyo"
                                                  timeZoneIdentifier:@"Asia/Tokyo"
                                                  utcOffsetInSeconds:32400];

TSLog(@"Created clock for %@", tokyoClock.cityName);
```

### Compare two world clock models

Check if two world clock models are equal based on their properties.

```objc
- (BOOL)isEqualToWorldClockModel:(TSWorldClockModel *)otherModel;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `otherModel` | `TSWorldClockModel *` | The other world clock model to compare with. |
| (return) | `BOOL` | YES if the models are equal, NO otherwise. |

**Code Example:**

```objc
TSWorldClockModel *clock1 = [TSWorldClockModel modelWithClockId:1
                                                        cityName:@"London"
                                              timeZoneIdentifier:@"Europe/London"
                                              utcOffsetInSeconds:0];

TSWorldClockModel *clock2 = [TSWorldClockModel modelWithClockId:1
                                                        cityName:@"London"
                                              timeZoneIdentifier:@"Europe/London"
                                              utcOffsetInSeconds:0];

if ([clock1 isEqualToWorldClockModel:clock2]) {
    TSLog(@"The two clocks are identical");
} else {
    TSLog(@"The two clocks are different");
}
```

## Important Notes

1. The `clockId` property must be unique for each world clock entry on the device and should be in the range of 0-255.

2. The `timeZoneIdentifier` must be a valid IANA timezone identifier (e.g., "Asia/Shanghai", "America/New_York", "Europe/London"). Invalid identifiers will cause operation failures.

3. The `utcOffsetInSeconds` must be synchronized with the `timeZoneIdentifier`. Mismatched values may result in incorrect time display. Acceptable range is -43200 seconds (UTC-12) to +43200 seconds (UTC+12).

4. Before setting world clocks, check the device's maximum supported count using `supportMaxWorldClockCount` to avoid exceeding device limitations.

5. The `timeFormat` and geographic coordinate properties (`longitude`, `latitude`) are marked as `NS_UNAVAILABLE` and should not be used in current implementation.

6. Always check for errors in callback completion blocks to handle network failures or device-specific errors appropriately.

7. World clock operations are asynchronous; ensure the device remains connected until the completion block is called.

8. When updating world clocks, the entire set of clocks should be provided in `setWorldClocks:completion:` as this typically replaces all existing clocks on the device.

9. The `TSWorldClockModel` class does not support direct initialization via `init`, `new`, or copy operations; use the provided factory methods instead.

10. Query world clocks regularly to synchronize local application state with device settings, as external modifications may occur.