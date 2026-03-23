---
sidebar_position: 4
title: Data Sync Guide
---

# Data Sync Guide

The SDK provides two ways to obtain health data: **real-time measurement** (user-triggered) and **historical data sync** (batch pull). This guide focuses on historical sync strategies.

## Comparison of Data Retrieval Methods

| Method | API | Use Case |
|--------|-----|----------|
| Real-time measurement | `startMeasure` on health modules | One-off user-triggered measurements (heart rate, SpO2, etc.) |
| Historical data sync | `TSDataSyncInterface` | Batch pull of records stored on the device after connecting |
| Auto-monitor config | `TSAutoMonitorInterface` | Configure automatic background collection on the device |

## Historical Data Sync

### When to Sync

Trigger sync at these points in the app lifecycle:

```objectivec
// 1. Immediately after device connects
- (void)onDeviceConnected {
    [self syncHealthData];
}

// 2. When app comes to foreground
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([bleConnect isConnected]) {
        [self syncHealthData];
    }
}

// 3. On user pull-to-refresh
- (void)onPullToRefresh {
    [self syncHealthData];
}
```

### Sync All Health Data

```objectivec
id<TSDataSyncInterface> dataSync = [TopStepComKit sharedInstance].dataSync;

// Sync all supported health data (recommended)
[dataSync syncAllHealthData:^(NSString *dataType, id data, NSError *error) {
    if (error) {
        TSLog(@"Sync %@ failed: %@", dataType, error.localizedDescription);
        return;
    }
    TSLog(@"Sync %@ complete — %lu record(s)", dataType, (unsigned long)[data count]);
    [self saveToLocal:data forType:dataType];
} completion:^(BOOL isSuccess, NSError *error) {
    TSLog(@"Full sync %@", isSuccess ? @"complete" : @"failed");
    [self hideProgressView];
}];
```

### Sync by Time Range

```objectivec
// Sync only the last 7 days of heart rate data
NSDate *endDate   = [NSDate date];
NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-(7 * 24 * 3600)];

id<TSHeartRateInterface> heartRate = [TopStepComKit sharedInstance].heartRate;

[heartRate getHistoryDataFrom:startDate
                           to:endDate
                   completion:^(NSArray *records, NSError *error) {
    if (error) {
        TSLog(@"Heart rate sync failed: %@", error.localizedDescription);
        return;
    }
    TSLog(@"%lu heart rate record(s)", (unsigned long)records.count);
    [self.db insertHeartRateRecords:records];
}];
```

## Incremental Sync Strategy

Avoid full syncs every time by tracking the last sync timestamp:

```objectivec
- (void)incrementalSync {
    // Read last sync date from UserDefaults
    NSDate *lastSyncDate = [[NSUserDefaults standardUserDefaults]
                            objectForKey:@"lastHeartRateSyncDate"];
    if (!lastSyncDate) {
        // First sync: pull last 30 days
        lastSyncDate = [NSDate dateWithTimeIntervalSinceNow:-(30 * 24 * 3600)];
    }

    NSDate *now = [NSDate date];

    [heartRate getHistoryDataFrom:lastSyncDate
                               to:now
                       completion:^(NSArray *records, NSError *error) {
        if (!error && records.count > 0) {
            [self.db insertHeartRateRecords:records];

            // Update last sync date
            [[NSUserDefaults standardUserDefaults] setObject:now
                                                      forKey:@"lastHeartRateSyncDate"];
        }
    }];
}
```

## Data Model Overview

### Two Levels of Granularity

Each health module typically provides two data granularities:

| Granularity | Model Suffix | Description |
|-------------|--------------|-------------|
| Detail records | `ValueItem` / `Record` | Raw measurements with timestamps |
| Daily summary | `DailyModel` | Per-day aggregates (max / min / avg) |

**Heart rate example:**

```objectivec
// TSHRValueItem (detail)
TSHRValueItem *item = records[0];
TSLog(@"Heart rate: %ld bpm at %@", (long)item.value, item.timestamp);

// TSHRDailyModel (daily summary)
TSHRDailyModel *daily = dailyRecords[0];
TSLog(@"Date: %@ — max: %ld min: %ld avg: %ld",
      daily.date,
      (long)daily.maxValue,
      (long)daily.minValue,
      (long)daily.avgValue);
```

## Showing Sync Progress

Provide user-friendly progress feedback:

```objectivec
- (void)syncAllDataWithProgress {
    __block NSInteger completedCount = 0;
    NSInteger totalCount = 5; // heart rate, SpO2, sleep, sport, steps

    [self showProgressViewWithTotal:totalCount];

    // Kick off each module concurrently
    [heartRate getHistoryDataFrom:startDate to:endDate completion:^(NSArray *r, NSError *e) {
        if (!e) [self.db insertHeartRateRecords:r];
        [self updateProgress:++completedCount total:totalCount];
    }];

    [bloodOxygen getHistoryDataFrom:startDate to:endDate completion:^(NSArray *r, NSError *e) {
        if (!e) [self.db insertBloodOxygenRecords:r];
        [self updateProgress:++completedCount total:totalCount];
    }];

    // ... other modules
}
```

## Important Notes

1. Sync must be performed while the device is in `eTSBleStateConnected` state
2. Do not disconnect during sync — doing so may result in incomplete data
3. Device storage is limited; older records may have been overwritten — sync promptly after each connection
4. Large historical syncs can take time — write to the database on a background thread to avoid blocking the main thread
5. Call `isSupport` before syncing each module and skip unsupported ones
