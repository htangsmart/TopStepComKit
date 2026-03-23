---
sidebar_position: 3
title: Sleep
---

# Sleep

This module provides comprehensive sleep data management and synchronization capabilities for the TopStepComKit iOS SDK. It enables retrieving detailed sleep information from connected devices, including night sleep, daytime naps, sleep stages, and quality metrics. The module supports multiple sleep statistics processing strategies to accommodate different device capabilities and use cases.

## Prerequisites

- Device must support sleep monitoring functionality
- Device must be properly connected and synchronized
- The TSSleepInterface protocol must be implemented by the device manager
- Sleep data synchronization requires appropriate device permissions
- For automatic sleep monitoring configuration, the device must support this feature

## Data Models

### TSSleepDailyModel

Daily aggregated sleep data model containing summary, segments, and raw items.

| Property | Type | Description |
|----------|------|-------------|
| `statisticsRule` | `TSSleepStatisticsRule` | Statistics rule used for processing this sleep record |
| `dailySummary` | `TSSleepSummary *` | Overall daily sleep summary containing all statistics |
| `rawSleepItems` | `NSArray<TSSleepDetailItem *> *` | Raw sleep detail items synced from device before processing |
| `nightSleeps` | `NSArray<TSSleepSegment *> *` | Array of night sleep segments |
| `daytimeSleeps` | `NSArray<TSSleepSegment *> *` | Array of daytime sleep segments (naps) |

### TSSleepDetailItem

Single sleep stage segment with stage type, timing, and date attribution.

| Property | Type | Description |
|----------|------|-------------|
| `stage` | `TSSleepStage` | Sleep stage type (Awake/Light/Deep/REM) |
| `startTime` | `NSTimeInterval` | Unix timestamp of segment start time |
| `duration` | `NSTimeInterval` | Duration of segment in seconds |
| `belongingDate` | `NSTimeInterval` | Timestamp of 00:00:00 of the day this sleep belongs to (uses 20:00 as day boundary) |

### TSSleepSegment

Continuous sleep segment containing period type, summary, and detail items.

| Property | Type | Description |
|----------|------|-------------|
| `periodType` | `TSSleepPeriodType` | Sleep period type (Night or Daytime) |
| `summary` | `TSSleepSummary *` | Statistical summary of this sleep segment |
| `detailItems` | `NSArray<TSSleepDetailItem *> *` | Array of detailed sleep stage items in chronological order |

### TSSleepSummary

Statistical summary of sleep data including duration, quality, and stage composition.

| Property | Type | Description |
|----------|------|-------------|
| `startTime` | `NSTimeInterval` | Unix timestamp of sleep start time |
| `endTime` | `NSTimeInterval` | Unix timestamp of sleep end time |
| `duration` | `NSTimeInterval` | Total duration from start to end in seconds |
| `totalSleepDuration` | `NSTimeInterval` | Total effective sleep time excluding awake periods (seconds) |
| `qualityScore` | `UInt8` | Sleep quality score ranging from 0-100 |
| `awakeDuration` | `NSTimeInterval` | Total awake duration during sleep period (seconds) |
| `lightSleepDuration` | `NSTimeInterval` | Total light sleep duration (seconds) |
| `deepSleepDuration` | `NSTimeInterval` | Total deep sleep duration (seconds) |
| `remDuration` | `NSTimeInterval` | Total REM sleep duration (seconds) |
| `awakePercentage` | `UInt8` | Awake percentage relative to total sleep duration (0-100) |
| `lightSleepPercentage` | `UInt8` | Light sleep percentage relative to total sleep duration (0-100) |
| `deepSleepPercentage` | `UInt8` | Deep sleep percentage relative to total sleep duration (0-100) |
| `remPercentage` | `UInt8` | REM sleep percentage relative to total sleep duration (0-100) |
| `awakeCount` | `UInt16` | Number of awake episodes |
| `lightSleepCount` | `UInt16` | Number of light sleep episodes |
| `deepSleepCount` | `UInt16` | Number of deep sleep episodes |
| `remCount` | `UInt16` | Number of REM episodes |

### TSSleepBasicStrategy

Base class providing common methods for all sleep statistics strategies.

| Method | Type | Description |
|--------|------|-------------|
| `removeTrailingAwakeItems:` | `void` | Remove awake state items from end of array |
| `separateNightAndDaytimeItems:sleepStartTime:sleepEndTime:` | `NSDictionary *` | Separate sleep data into night and daytime items |
| `isAdjacentToNightSleep:nightItems:` | `BOOL` | Check if item is adjacent to night sleep |
| `splitIntoSegments:` | `NSArray<NSArray<TSSleepDetailItem *> *> *` | Split sleep data into segments (30-minute awake separation) |
| `createSegmentFromItems:periodType:` | `nullable TSSleepSegment *` | Create sleep segment from detail items |
| `filterSegmentsByDuration:minDuration:maxDuration:` | `void` | Filter segments by duration range |
| `createSummaryFromItems:` | `nullable TSSleepSummary *` | Create sleep summary from detail items |

### TSSleepWithoutNapStrategy

Sleep statistics strategy for devices without nap support (Rule 0).

Strategy features:
- Sensor active: 20:00-12:00
- All sleep treated as night sleep
- No nap records

### TSSleepWithNapStrategy

Sleep statistics strategy with nap support (Rule 1).

Strategy features:
- Sensor active: 24 hours
- Night sleep: 20:00-09:00
- Daytime naps: 09:00-20:00
- Valid nap criteria: 20min < duration ≤ 3h

### TSSleepLongestNightStrategy

Sleep statistics strategy using longest continuous night sleep segment (Rule 2).

Strategy features:
- Night sleep: 20:00-08:00 (longest continuous segment)
- Valid naps: 20min < duration ≤ 3h
- All sleep counted in total (including naps)

### TSSleepLongestOnlyStrategy

Sleep statistics strategy using longest continuous sleep segment only (Rule 3).

Strategy features:
- No distinction between night and day
- Uses longest continuous sleep segment
- Other segments are ignored

### TSSleepDataProcessor

Sleep data processor class responsible for processing raw sleep detail items.

| Method | Type | Description |
|--------|------|-------------|
| `processWithStatisticsRule:rawItems:` | `NSArray<TSSleepDailyModel *> *` | Process raw sleep items according to statistics rule |

## Enumerations

### TSSleepStage

Sleep stage type enumeration according to AASM standards.

| Value | Description |
|-------|-------------|
| `TSSleepStageAwake` | Awake stage (value 0) |
| `TSSleepStageLight` | Light sleep stage - N1 and N2 (value 1) |
| `TSSleepStageDeep` | Deep sleep stage - N3, slow-wave sleep (value 2) |
| `TSSleepStageREM` | REM (Rapid Eye Movement) stage - dream sleep (value 3) |

### TSSleepStatisticsRule

Sleep statistics rule type enumeration.

| Value | Description |
|-------|-------------|
| `TSSleepStatisticsRuleWithoutNap` | Basic rule without nap support: sensor active 20:00-12:00, all sleep treated as night sleep (value 0) |
| `TSSleepStatisticsRuleWithNap` | Rule with nap support: sensor active 24h, distinguishes night (20:00-09:00) and day sleep (09:00-20:00) (value 1) |
| `TSSleepStatisticsRuleLongestNight` | Longest night segment rule: uses longest continuous night sleep (20:00-08:00), valid naps counted (value 2) |
| `TSSleepStatisticsRuleLongestOnly` | Longest only rule: no distinction between night/day, uses longest continuous sleep segment only (value 3) |

### TSSleepPeriodType

Sleep period type enumeration based on data time.

| Value | Description |
|-------|-------------|
| `TSSleepPeriodTypeNight` | Night sleep period [20:00-09:00) (value 0) |
| `TSSleepPeriodTypeDaytime` | Daytime sleep period [09:00-20:00) (value 1) |

## Callback Types

### Sleep Configuration Completion Block

```objc
void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error)
```

Completion block for fetching automatic sleep monitoring configuration.

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorConfigs *_Nullable` | Current sleep monitoring configuration or nil if error |
| `error` | `NSError *_Nullable` | Error object if operation failed, nil if successful |

### Raw Sleep Data Sync Completion Block

```objc
void (^)(NSArray<TSSleepDetailItem *> *_Nullable sleepItems, NSError *_Nullable error)
```

Completion block for raw sleep data synchronization.

| Parameter | Type | Description |
|-----------|------|-------------|
| `sleepItems` | `NSArray<TSSleepDetailItem *> *_Nullable` | Array of raw sleep detail items or nil if error |
| `error` | `NSError *_Nullable` | Error object if operation failed, nil if successful |

### Daily Sleep Data Sync Completion Block

```objc
void (^)(NSArray<TSSleepDailyModel *> *_Nullable sleepModel, NSError *_Nullable error)
```

Completion block for daily aggregated sleep data synchronization.

| Parameter | Type | Description |
|-----------|------|-------------|
| `sleepModel` | `NSArray<TSSleepDailyModel *> *_Nullable` | Array of daily sleep models or nil if error |
| `error` | `NSError *_Nullable` | Error object if operation failed, nil if successful |

## API Reference

### Configure Automatic Sleep Monitoring

Configure the automatic sleep monitoring features on the device.

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `configuration` | `TSAutoMonitorConfigs *` | Configuration object containing sleep monitoring settings |
| `completion` | `TSCompletionBlock` | Completion block called with success status or error |

**Code Example:**

```objc
id<TSSleepInterface> sleepInterface = (id<TSSleepInterface>)deviceManager;

TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];
config.enabled = YES;
// Configure other settings as needed

[sleepInterface pushAutoMonitorConfigs:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to configure sleep monitoring: %@", error.localizedDescription);
    } else {
        TSLog(@"Sleep monitoring configured successfully");
    }
}];
```

### Retrieve Current Sleep Monitoring Configuration

Get the current automatic sleep monitoring configuration from the device.

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSAutoMonitorConfigs *_Nullable, NSError *_Nullable)` | Completion block returning current configuration or error |

**Code Example:**

```objc
id<TSSleepInterface> sleepInterface = (id<TSSleepInterface>)deviceManager;

[sleepInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch sleep monitoring config: %@", error.localizedDescription);
    } else {
        TSLog(@"Sleep monitoring enabled: %@", configuration.enabled ? @"YES" : @"NO");
    }
}];
```

### Synchronize Raw Sleep Data From Start Time

Synchronize raw sleep segments starting from a specific time.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSSleepDetailItem *> *_Nullable sleepItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Unix timestamp (seconds) of the starting point |
| `completion` | `void (^)(NSArray<TSSleepDetailItem *> *_Nullable, NSError *_Nullable)` | Callback returning array of sleep detail items or error |

**Code Example:**

```objc
id<TSSleepInterface> sleepInterface = (id<TSSleepInterface>)deviceManager;

// Start from 7 days ago
NSTimeInterval startTime = [[NSDate dateWithTimeIntervalSinceNow:-7*24*3600] timeIntervalSince1970];

[sleepInterface syncRawDataFromStartTime:startTime completion:^(NSArray<TSSleepDetailItem *> * _Nullable sleepItems, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync raw sleep data: %@", error.localizedDescription);
    } else {
        TSLog(@"Retrieved %ld raw sleep items", (long)sleepItems.count);
        for (TSSleepDetailItem *item in sleepItems) {
            TSLog(@"Stage: %ld, Duration: %.0f seconds", (long)item.stage, item.duration);
        }
    }
}];
```

### Synchronize Raw Sleep Data Within Time Range

Synchronize raw sleep segments within a specific time range.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSSleepDetailItem *> *_Nullable sleepItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Unix timestamp (seconds) of range start (inclusive) |
| `endTime` | `NSTimeInterval` | Unix timestamp (seconds) of range end (exclusive), range is [startTime, endTime) |
| `completion` | `void (^)(NSArray<TSSleepDetailItem *> *_Nullable, NSError *_Nullable)` | Callback returning array of sleep detail items or error |

**Code Example:**

```objc
id<TSSleepInterface> sleepInterface = (id<TSSleepInterface>)deviceManager;

NSDate *today = [NSDate date];
NSDate *startOfDay = [[NSCalendar currentCalendar] startOfDayForDate:today];
NSDate *startOfYesterday = [startOfDay dateByAddingTimeInterval:-24*3600];

NSTimeInterval startTime = [startOfYesterday timeIntervalSince1970];
NSTimeInterval endTime = [startOfDay timeIntervalSince1970];

[sleepInterface syncRawDataFromStartTime:startTime endTime:endTime completion:^(NSArray<TSSleepDetailItem *> * _Nullable sleepItems, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync sleep data: %@", error.localizedDescription);
    } else {
        NSTimeInterval totalDeepSleep = 0;
        for (TSSleepDetailItem *item in sleepItems) {
            if (item.stage == TSSleepStageDeep) {
                totalDeepSleep += item.duration;
            }
        }
        TSLog(@"Total deep sleep: %.0f seconds (%.1f hours)", totalDeepSleep, totalDeepSleep/3600);
    }
}];
```

### Synchronize Daily Aggregated Sleep Data From Start Time

Synchronize per-day sleep summaries starting from a specific date.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSSleepDailyModel *> *_Nullable sleepModel, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Unix timestamp (seconds) of the starting day |
| `completion` | `void (^)(NSArray<TSSleepDailyModel *> *_Nullable, NSError *_Nullable)` | Callback returning array of daily sleep models or error |

**Code Example:**

```objc
id<TSSleepInterface> sleepInterface = (id<TSSleepInterface>)deviceManager;

// Start from 30 days ago
NSTimeInterval startTime = [[NSDate dateWithTimeIntervalSinceNow:-30*24*3600] timeIntervalSince1970];

[sleepInterface syncDailyDataFromStartTime:startTime completion:^(NSArray<TSSleepDailyModel *> * _Nullable sleepModel, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync daily sleep data: %@", error.localizedDescription);
    } else {
        NSTimeInterval totalSleep = 0;
        UInt8 avgQuality = 0;
        
        for (TSSleepDailyModel *model in sleepModel) {
            totalSleep += model.dailySummary.totalSleepDuration;
            avgQuality += model.dailySummary.qualityScore;
            
            TSLog(@"Date: %@, Sleep: %.1f hours, Quality: %d", 
                  model.timestamp, 
                  model.dailySummary.totalSleepDuration/3600, 
                  model.dailySummary.qualityScore);
        }
        
        TSLog(@"Average daily sleep: %.1f hours, Average quality: %d", 
              totalSleep/(3600*sleepModel.count), 
              avgQuality/sleepModel.count);
    }
}];
```

### Synchronize Daily Aggregated Sleep Data Within Time Range

Synchronize per-day sleep summaries within a specific date range.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSSleepDailyModel *> *_Nullable sleepModel, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Unix timestamp (seconds) of range start day (inclusive) |
| `endTime` | `NSTimeInterval` | Unix timestamp (seconds) of range end day (exclusive), range is [startTime, endTime) |
| `completion` | `void (^)(NSArray<TSSleepDailyModel *> *_Nullable, NSError *_Nullable)` | Callback returning array of daily sleep models or error |

**Code Example:**

```objc
id<TSSleepInterface> sleepInterface = (id<TSSleepInterface>)deviceManager;

NSDate *today = [NSDate date];
NSCalendar *calendar = [NSCalendar currentCalendar];
NSDate *startOfWeek = [calendar dateByAddingUnit:NSCalendarUnitDay value:-7 toDate:today options:0];
NSDate *startOfDay = [calendar startOfDayForDate:startOfWeek];

NSTimeInterval startTime = [startOfDay timeIntervalSince1970];
NSTimeInterval endTime = [[calendar startOfDayForDate:today] timeIntervalSince1970];

[sleepInterface syncDailyDataFromStartTime:startTime endTime:endTime completion:^(NSArray<TSSleepDailyModel *> * _Nullable sleepModel, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync weekly sleep data: %@", error.localizedDescription);
    } else {
        for (TSSleepDailyModel *model in sleepModel) {
            TSSleepSummary *summary = model.dailySummary;
            TSLog(@"Night sleep segments: %ld", (long)model.nightSleeps.count);
            TSLog(@"  Total duration: %.1f hours", summary.totalSleepDuration/3600);
            TSLog(@"  Quality score: %d/100", summary.qualityScore);
            TSLog(@"  Deep sleep: %.1f%% (%.1f hours)", summary.deepSleepPercentage, summary.deepSleepDuration/3600);
            TSLog(@"  Awakenings: %d times", summary.awakeCount);
            
            // Check for naps
            NSArray<TSSleepSegment *> *validNaps = [model validNaps];
            if (validNaps.count > 0) {
                TSLog(@"  Valid naps: %ld", (long)validNaps.count);
            }
        }
    }
}];
```

### Get Valid Daytime Naps

Get only valid naps from daily sleep data.

```objc
- (NSArray<TSSleepSegment *> *)validNaps;
```

**Code Example:**

```objc
// Assuming you have a TSSleepDailyModel instance
TSSleepDailyModel *sleepModel = // ... obtained from sync operation

NSArray<TSSleepSegment *> *validNaps = [sleepModel validNaps];

for (TSSleepSegment *nap in validNaps) {
    TSLog(@"Nap - Start: %@, Duration: %.0f minutes, Quality: %d", 
          [NSDate dateWithTimeIntervalSince1970:nap.summary.startTime],
          nap.summary.totalSleepDuration/60,
          nap.summary.qualityScore);
}
```

## Important Notes

1. **Time Format and `Timestamps**`: All timestamps are Unix timestamps (seconds since 1970-01-01). Use `[date timeIntervalSince1970]` to convert NSDate to timestamp and `[NSDate dateWithTimeIntervalSince1970:timestamp]` to convert back.

2. **Day Boundary `Definition**`: Sleep data uses 20:00 (8 PM) as the day boundary, not midnight. A sleep session at 21:00 on 2025-11-19 belongs to 2025-11-20. The `belongingDate` property contains the 00:00:00 timestamp of the assigned date.

3. **Time Range `Specification**`: Time ranges use [startTime, endTime) notation, meaning startTime is inclusive but endTime is exclusive. This is important when fetching consecutive time periods.

4. **Sleep Stages and AASM `Standards**`: The module follows American Academy of Sleep Medicine (AASM) standards with four sleep stages: Awake, Light (N1+N2), Deep (N3), and REM. Raw data contains detailed stage transitions while summaries provide aggregated statistics.

5. **Nap Validity `Criteria**`: Daytime naps are considered valid if their duration is between 20 minutes (exclusive) and 3 hours (inclusive). The `validNaps` method filters daytime sleep segments based on this criterion, and only valid naps are included in daily summary statistics.

6. **Statistics Rules and Device `Compatibility**`: Different devices support different statistics rules (Basic/WithNap/LongestNight/LongestOnly). The `statisticsRule` property in TSSleepDailyModel indicates which rule was used for processing. Ensure your processing logic accounts for the device's supported rule.

7. **Raw Data and `Processing**`: Raw sleep items (`rawSleepItems`) represent original data from the device before processing. Daily models contain both raw items and processed segments. Use raw items for custom analysis and segments for standard summaries.

8. **Sleep `Segments**`: Sleep data is split into segments by 30-minute awake periods. Night and daytime segments are separate with distinct time windows (night: 20:00-09:00, daytime: 09:00-20:00). Use `periodType` to distinguish between them.

9. **Quality `Score**`: Sleep quality score ranges from 0-100 and is calculated based on sleep duration, deep sleep percentage, and number of awakenings. A higher score indicates better sleep quality.

10. **Synchronization `Completeness**`: When syncing raw data, use the time range variant to limit network traffic. For daily summaries, prefer the range-based method over fetching from a start time to ensure consistent data retrieval across application restarts.

11. **Error `Handling**`: Always check the error parameter in completion blocks before using the returned data. Network failures, device disconnection, or insufficient permissions may cause synchronization to fail.

12. **Data `Privacy**`: Sleep data is sensitive personal health information. Ensure appropriate access controls and secure storage when handling synchronized sleep data.