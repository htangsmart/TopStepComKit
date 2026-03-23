---
sidebar_position: 10
title: DailyActivity
---

# DailyActivity

The DailyActivity module provides comprehensive management of daily physical activity and exercise tracking. It allows you to retrieve and configure daily activity goals (steps, calories, distance, activity/exercise duration and frequency), manage reminder notifications, synchronize today's activity data, and access historical activity records within specified time ranges. This module integrates seamlessly with the device to provide real-time activity monitoring and goal-based health tracking.

## Prerequisites

- TopStepComKit SDK properly initialized and connected to a device
- Valid BLE connection with the wearable device
- Device must support daily activity features
- User must have necessary permissions to read/write activity data

## Data Models

### TSActivityDailyModel

Represents aggregated daily activity data with individual activity items.

| Property | Type | Description |
|----------|------|-------------|
| `steps` | `NSInteger` | Daily aggregated steps count |
| `calories` | `NSInteger` | Daily aggregated calories consumed (kilocalories) |
| `distance` | `NSInteger` | Daily aggregated distance in meters |
| `activityDuration` | `NSInteger` | Daily aggregated activity duration in seconds |
| `activityTimes` | `NSInteger` | Daily aggregated activity sessions count |
| `exercisesDuration` | `NSInteger` | Daily aggregated exercise duration in seconds |
| `exercisesTimes` | `NSInteger` | Daily aggregated exercise sessions count |
| `activityItems` | `NSArray<TSDailyActivityItem *> *` | Array of individual activity items for the day, ordered by time ascending |

### TSDailyActivityGoals

Manages user's daily exercise goals for all activity metrics.

| Property | Type | Description |
|----------|------|-------------|
| `stepsGoal` | `NSInteger` | Daily steps target (0–100,000 recommended) |
| `caloriesGoal` | `NSInteger` | Daily calorie consumption target in kcal (50–3,000 recommended) |
| `distanceGoal` | `NSInteger` | Daily distance target in meters (0–100,000 recommended) |
| `activityDurationGoal` | `NSInteger` | Daily activity duration target in minutes (0–1,440) |
| `exerciseDurationGoal` | `NSInteger` | Daily exercise duration target in minutes (0–1,440) |
| `exerciseTimesGoal` | `NSInteger` | Daily exercise frequency target (1–50 recommended) |
| `activityTimesGoal` | `NSInteger` | Daily activity frequency target (1–100 recommended) |

### TSDailyActivityItem

Represents detailed activity statistics for a specific time period.

| Property | Type | Description |
|----------|------|-------------|
| `steps` | `NSInteger` | Total step count |
| `calories` | `NSInteger` | Total calories burned (small kilocalories) |
| `distance` | `NSInteger` | Total distance covered in meters |
| `activityDuration` | `NSInteger` | Total activity duration in seconds |
| `exercisesDuration` | `NSInteger` | Total exercise duration in seconds |
| `exercisesTimes` | `NSInteger` | Number of exercise sessions |
| `activityTimes` | `NSInteger` | Number of activity sessions |

### TSDailyActivityReminder

Stores reminder notification switches for daily activity goals.

| Property | Type | Description |
|----------|------|-------------|
| `stepsReminderEnabled` | `BOOL` | Steps goal reminder enabled |
| `caloriesReminderEnabled` | `BOOL` | Calories goal reminder enabled |
| `distanceReminderEnabled` | `BOOL` | Distance goal reminder enabled |
| `activityTimesReminderEnabled` | `BOOL` | Activity times goal reminder enabled |
| `activityDurationReminderEnabled` | `BOOL` | Activity duration goal reminder enabled |
| `exerciseTimesReminderEnabled` | `BOOL` | Exercise times goal reminder enabled |
| `exerciseDurationReminderEnabled` | `BOOL` | Exercise duration goal reminder enabled |

## Enumerations

### TSDailyActivityType

Defines the types of daily activities displayed on the device.

| Value | Name | Description |
|-------|------|-------------|
| `1` | `TSDailyActivityTypeStepCount` | Step count |
| `2` | `TSDailyActivityTypeExerciseDuration` | Exercise duration |
| `3` | `TSDailyActivityTypeActivityCount` | Activity count |
| `4` | `TSDailyActivityTypeActiveDuration` | Active duration |
| `5` | `TSDailyActivityTypeDistance` | Distance |
| `6` | `TSDailyActivityTypeCalories` | Calories |

## Callback Types

### Activity Types Completion Block

```objc
void (^)(NSArray<NSNumber *> *_Nullable activityTypes, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `activityTypes` | `NSArray<NSNumber *> *` | Array of supported activity type values (TSDailyActivityType) |
| `error` | `NSError *` | Error object if operation failed |

### Goals Completion Block

```objc
void (^)(TSDailyActivityGoals *_Nullable goals, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `goals` | `TSDailyActivityGoals *` | Current daily exercise goals |
| `error` | `NSError *` | Error object if operation failed |

### Goals and Reminder Completion Block

```objc
void (^)(TSDailyActivityGoals *_Nullable goals, TSDailyActivityReminder *_Nullable reminder, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `goals` | `TSDailyActivityGoals *` | Current daily exercise goals |
| `reminder` | `TSDailyActivityReminder *` | Current reminder configuration |
| `error` | `NSError *` | Error object if operation failed |

### Reminder Completion Block

```objc
void (^)(TSDailyActivityReminder *_Nullable reminder, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `reminder` | `TSDailyActivityReminder *` | Current reminder switches |
| `error` | `NSError *` | Error object if operation failed |

### Today's Activity Completion Block

```objc
void (^)(TSActivityDailyModel *_Nullable todayActivity, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `todayActivity` | `TSActivityDailyModel *` | Today's aggregated activity data |
| `error` | `NSError *` | Error object if operation failed |

### Activity Items Completion Block

```objc
void (^)(NSArray<TSDailyActivityItem *> *_Nullable activityItems, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `activityItems` | `NSArray<TSDailyActivityItem *> *` | Array of daily activity items |
| `error` | `NSError *` | Error object if operation failed |

### Daily Models Completion Block

```objc
void (^)(NSArray<TSActivityDailyModel *> *_Nullable dailyModels, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `dailyModels` | `NSArray<TSActivityDailyModel *> *` | Array of daily aggregated activity models |
| `error` | `NSError *` | Error object if operation failed |

## API Reference

### Fetch supported daily activity types

Retrieves the list of daily activity types that the device supports and displays.

```objc
- (void)fetchSupportedDailyActivityTypesWithCompletion:(void(^)(NSArray<NSNumber *> *_Nullable activityTypes, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(NSArray<NSNumber *> *, NSError *)` | Completion block returning array of supported activity types |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

[dailyActivity fetchSupportedDailyActivityTypesWithCompletion:^(NSArray<NSNumber *> * _Nullable activityTypes, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch supported activity types: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Supported activity types: %@", activityTypes);
    
    for (NSNumber *typeNumber in activityTypes) {
        TSDailyActivityType type = (TSDailyActivityType)[typeNumber integerValue];
        switch (type) {
            case TSDailyActivityTypeStepCount:
                TSLog(@"Step count supported");
                break;
            case TSDailyActivityTypeExerciseDuration:
                TSLog(@"Exercise duration supported");
                break;
            default:
                break;
        }
    }
}];
```

### Get current daily exercise goals

Retrieves the user's current daily exercise goals from the device.

```objc
- (void)fetchDailyExerciseGoalsWithCompletion:(void(^)(TSDailyActivityGoals *_Nullable goals, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSDailyActivityGoals *, NSError *)` | Completion block returning current goals |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

[dailyActivity fetchDailyExerciseGoalsWithCompletion:^(TSDailyActivityGoals * _Nullable goals, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch exercise goals: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Current Daily Goals:");
    TSLog(@"  Steps: %ld", (long)goals.stepsGoal);
    TSLog(@"  Calories: %ld kcal", (long)goals.caloriesGoal);
    TSLog(@"  Distance: %ld m", (long)goals.distanceGoal);
    TSLog(@"  Activity Duration: %ld min", (long)goals.activityDurationGoal);
    TSLog(@"  Exercise Duration: %ld min", (long)goals.exerciseDurationGoal);
    TSLog(@"  Exercise Frequency: %ld times", (long)goals.exerciseTimesGoal);
    TSLog(@"  Activity Frequency: %ld times", (long)goals.activityTimesGoal);
}];
```

### Set daily exercise goals

Writes user's daily exercise goals to the device.

```objc
- (void)pushDailyExerciseGoals:(TSDailyActivityGoals *)goalsModel
                    completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `goalsModel` | `TSDailyActivityGoals *` | Model containing goals to set |
| `completion` | `TSCompletionBlock` | Completion block indicating success or failure |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

TSDailyActivityGoals *newGoals = [[TSDailyActivityGoals alloc] init];
newGoals.stepsGoal = 10000;
newGoals.caloriesGoal = 500;
newGoals.distanceGoal = 8000;
newGoals.activityDurationGoal = 30;
newGoals.exerciseDurationGoal = 60;
newGoals.exerciseTimesGoal = 1;
newGoals.activityTimesGoal = 10;

[dailyActivity pushDailyExerciseGoals:newGoals completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set exercise goals: %@", error.localizedDescription);
    } else {
        TSLog(@"Exercise goals set successfully");
    }
}];
```

### Fetch daily exercise goals and reminders in one call

Retrieves both daily exercise goals and their reminder switches in a single request.

```objc
- (void)fetchDailyExerciseAllWithCompletion:(void(^)(TSDailyActivityGoals *_Nullable goals,
                                                    TSDailyActivityReminder *_Nullable reminder,
                                                    NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSDailyActivityGoals *, TSDailyActivityReminder *, NSError *)` | Completion block returning goals, reminders, and error |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

[dailyActivity fetchDailyExerciseAllWithCompletion:^(TSDailyActivityGoals * _Nullable goals, TSDailyActivityReminder * _Nullable reminder, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch goals and reminders: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Goals and Reminders Retrieved:");
    TSLog(@"Steps Goal: %ld (Reminder: %@)", (long)goals.stepsGoal, reminder.stepsReminderEnabled ? @"ON" : @"OFF");
    TSLog(@"Calories Goal: %ld (Reminder: %@)", (long)goals.caloriesGoal, reminder.caloriesReminderEnabled ? @"ON" : @"OFF");
    TSLog(@"Distance Goal: %ld (Reminder: %@)", (long)goals.distanceGoal, reminder.distanceReminderEnabled ? @"ON" : @"OFF");
    TSLog(@"Activity Duration Goal: %ld (Reminder: %@)", (long)goals.activityDurationGoal, reminder.activityDurationReminderEnabled ? @"ON" : @"OFF");
    TSLog(@"Exercise Duration Goal: %ld (Reminder: %@)", (long)goals.exerciseDurationGoal, reminder.exerciseDurationReminderEnabled ? @"ON" : @"OFF");
}];
```

### Push daily exercise goals and reminders atomically

Writes both goals and reminder switches in a single atomic operation.

```objc
- (void)pushDailyExerciseGoals:(TSDailyActivityGoals *)goalsModel
                       reminder:(TSDailyActivityReminder *)reminder
                      completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `goalsModel` | `TSDailyActivityGoals *` | Goals model to set |
| `reminder` | `TSDailyActivityReminder *` | Reminder switches model to set |
| `completion` | `TSCompletionBlock` | Completion block indicating success or failure |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

TSDailyActivityGoals *goals = [[TSDailyActivityGoals alloc] init];
goals.stepsGoal = 10000;
goals.caloriesGoal = 500;
goals.distanceGoal = 8000;
goals.activityDurationGoal = 30;
goals.exerciseDurationGoal = 60;
goals.exerciseTimesGoal = 1;
goals.activityTimesGoal = 10;

TSDailyActivityReminder *reminder = [[TSDailyActivityReminder alloc] init];
reminder.stepsReminderEnabled = YES;
reminder.caloriesReminderEnabled = YES;
reminder.distanceReminderEnabled = YES;
reminder.activityDurationReminderEnabled = YES;
reminder.exerciseDurationReminderEnabled = YES;
reminder.exerciseTimesReminderEnabled = YES;
reminder.activityTimesReminderEnabled = YES;

[dailyActivity pushDailyExerciseGoals:goals reminder:reminder completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set goals and reminders: %@", error.localizedDescription);
    } else {
        TSLog(@"Goals and reminders set successfully");
    }
}];
```

### Get current daily exercise reminder switches

Retrieves reminder switches for all exercise goals.

```objc
- (void)fetchDailyExerciseReminderConfigWithCompletion:(void(^)(TSDailyActivityReminder *_Nullable reminder, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSDailyActivityReminder *, NSError *)` | Completion block returning reminder configuration |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

[dailyActivity fetchDailyExerciseReminderConfigWithCompletion:^(TSDailyActivityReminder * _Nullable reminder, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch reminder config: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Current Reminder Settings:");
    TSLog(@"  Steps Reminder: %@", reminder.stepsReminderEnabled ? @"ON" : @"OFF");
    TSLog(@"  Calories Reminder: %@", reminder.caloriesReminderEnabled ? @"ON" : @"OFF");
    TSLog(@"  Distance Reminder: %@", reminder.distanceReminderEnabled ? @"ON" : @"OFF");
    TSLog(@"  Activity Duration Reminder: %@", reminder.activityDurationReminderEnabled ? @"ON" : @"OFF");
    TSLog(@"  Exercise Duration Reminder: %@", reminder.exerciseDurationReminderEnabled ? @"ON" : @"OFF");
    TSLog(@"  Exercise Times Reminder: %@", reminder.exerciseTimesReminderEnabled ? @"ON" : @"OFF");
    TSLog(@"  Activity Times Reminder: %@", reminder.activityTimesReminderEnabled ? @"ON" : @"OFF");
}];
```

### Set daily exercise reminder switches

Writes reminder switches for all exercise goals.

```objc
- (void)pushDailyExerciseReminder:(TSDailyActivityReminder *)reminder
                      completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `reminder` | `TSDailyActivityReminder *` | Reminder switches model to set |
| `completion` | `TSCompletionBlock` | Completion block indicating success or failure |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

TSDailyActivityReminder *reminder = [[TSDailyActivityReminder alloc] init];
reminder.stepsReminderEnabled = YES;
reminder.caloriesReminderEnabled = YES;
reminder.distanceReminderEnabled = NO;
reminder.activityDurationReminderEnabled = YES;
reminder.exerciseDurationReminderEnabled = YES;
reminder.exerciseTimesReminderEnabled = YES;
reminder.activityTimesReminderEnabled = NO;

[dailyActivity pushDailyExerciseReminder:reminder completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to set reminders: %@", error.localizedDescription);
    } else {
        TSLog(@"Reminders set successfully");
    }
}];
```

### Synchronize today's daily exercise data

Retrieves the current day's activity data from the device.

```objc
- (void)syncTodayDailyExerciseDataCompletion:(void (^)(TSActivityDailyModel *_Nullable todayActivity, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `void (^)(TSActivityDailyModel *, NSError *)` | Completion block with today's exercise data |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

[dailyActivity syncTodayDailyExerciseDataCompletion:^(TSActivityDailyModel * _Nullable todayActivity, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync today's data: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Today's Activity Data:");
    TSLog(@"  Steps: %ld", (long)todayActivity.steps);
    TSLog(@"  Calories: %ld kcal", (long)todayActivity.calories);
    TSLog(@"  Distance: %ld m", (long)todayActivity.distance);
    TSLog(@"  Activity Duration: %ld seconds", (long)todayActivity.activityDuration);
    TSLog(@"  Activity Times: %ld", (long)todayActivity.activityTimes);
    TSLog(@"  Exercise Duration: %ld seconds", (long)todayActivity.exercisesDuration);
    TSLog(@"  Exercise Times: %ld", (long)todayActivity.exercisesTimes);
    TSLog(@"  Activity Items Count: %lu", (unsigned long)todayActivity.activityItems.count);
}];
```

### Synchronize raw daily activity data within a specified time range

Retrieves historical daily activity data for the specified time range.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSDailyActivityItem *> *_Nullable activityItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time timestamp in seconds since 1970 |
| `endTime` | `NSTimeInterval` | End time timestamp in seconds since 1970 |
| `completion` | `void (^)(NSArray<TSDailyActivityItem *> *, NSError *)` | Completion block with activity items |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*3600]; // 7 days ago
NSDate *endDate = [NSDate date]; // Now

[dailyActivity syncRawDataFromStartTime:startDate.timeIntervalSince1970
                                         endTime:endDate.timeIntervalSince1970
                                      completion:^(NSArray<TSDailyActivityItem *> * _Nullable activityItems, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync raw data: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Retrieved %lu activity items", (unsigned long)activityItems.count);
    
    for (TSDailyActivityItem *item in activityItems) {
        TSLog(@"Activity Item:");
        TSLog(@"  Steps: %ld", (long)item.steps);
        TSLog(@"  Calories: %ld", (long)item.calories);
        TSLog(@"  Distance: %ld m", (long)item.distance);
        TSLog(@"  Activity Duration: %ld seconds", (long)item.activityDuration);
        TSLog(@"  Exercise Duration: %ld seconds", (long)item.exercisesDuration);
    }
}];
```

### Synchronize raw daily activity data from a specified start time until now

Retrieves historical daily activity data from the specified start time to the current time.

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSDailyActivityItem *> *_Nullable activityItems, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time timestamp in seconds since 1970 |
| `completion` | `void (^)(NSArray<TSDailyActivityItem *> *, NSError *)` | Completion block with activity items |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-30*24*3600]; // 30 days ago

[dailyActivity syncRawDataFromStartTime:startDate.timeIntervalSince1970
                                      completion:^(NSArray<TSDailyActivityItem *> * _Nullable activityItems, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync raw data: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Retrieved %lu activity items from last 30 days", (unsigned long)activityItems.count);
    
    NSInteger totalSteps = 0;
    for (TSDailyActivityItem *item in activityItems) {
        totalSteps += item.steps;
    }
    
    TSLog(@"Total steps in 30 days: %ld", (long)totalSteps);
    TSLog(@"Average steps per day: %ld", (long)(totalSteps / activityItems.count));
}];
```

### Synchronize daily activity data within a specified time range

Retrieves aggregated daily activity data for the specified time range.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSActivityDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time timestamp in seconds since 1970 (normalized to 00:00:00) |
| `endTime` | `NSTimeInterval` | End time timestamp in seconds since 1970 (normalized to 23:59:59) |
| `completion` | `void (^)(NSArray<TSActivityDailyModel *> *, NSError *)` | Completion block with daily models |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*3600]; // 7 days ago
NSDate *endDate = [NSDate date]; // Now

[dailyActivity syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                                           endTime:endDate.timeIntervalSince1970
                                        completion:^(NSArray<TSActivityDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync daily data: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Retrieved %lu days of activity data", (unsigned long)dailyModels.count);
    
    for (TSActivityDailyModel *dailyModel in dailyModels) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:dailyModel.startTime];
        TSLog(@"Date: %@", date);
        TSLog(@"  Steps: %ld", (long)dailyModel.steps);
        TSLog(@"  Calories: %ld", (long)dailyModel.calories);
        TSLog(@"  Distance: %ld m", (long)dailyModel.distance);
        TSLog(@"  Activity Duration: %ld seconds", (long)dailyModel.activityDuration);
        TSLog(@"  Activity Times: %ld", (long)dailyModel.activityTimes);
        TSLog(@"  Exercise Duration: %ld seconds", (long)dailyModel.exercisesDuration);
        TSLog(@"  Exercise Times: %ld", (long)dailyModel.exercisesTimes);
        TSLog(@"  Items: %lu", (unsigned long)dailyModel.activityItems.count);
    }
}];
```

### Synchronize daily activity data from a specified start time until now

Retrieves aggregated daily activity data from the specified start time to the current time.

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSActivityDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Start time timestamp in seconds since 1970 (normalized to 00:00:00) |
| `completion` | `void (^)(NSArray<TSActivityDailyModel *> *, NSError *)` | Completion block with daily models |

**Code Example:**

```objc
id<TSDailyActivityInterface> dailyActivity = [TopStepComKit sharedInstance].dailyActivity;

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-30*24*3600]; // 30 days ago

[dailyActivity syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                                        completion:^(NSArray<TSActivityDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to sync daily data: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Retrieved activity data for %lu days", (unsigned long)dailyModels.count);
    
    // Calculate weekly averages
    NSInteger totalSteps = 0;
    NSInteger totalCalories = 0;
    
    for (TSActivityDailyModel *dailyModel in dailyModels) {
        totalSteps += dailyModel.steps;
        totalCalories += dailyModel.calories;
    }
    
    TSLog(@"Average daily steps: %ld", (long)(totalSteps / dailyModels.count));
    TSLog(@"Average daily calories: %ld", (long)(totalCalories / dailyModels.count));
}];
```

## Important Notes

1. **Time `Normalization**`: Start and end times in daily data synchronization methods are automatically normalized to day boundaries (00:00:00 and 23:59:59 respectively). Specify time using Unix timestamps (seconds since 1970).

2. **Data `Consistency**`: Use `fetchDailyExerciseAllWithCompletion:` and `pushDailyExerciseGoals:reminder:completion:` for atomic read/write operations to avoid intermediate inconsistent states when handling both goals and reminders.

3. **Callback `Execution**`: All completion blocks are invoked on the main thread, making it safe to directly update UI elements within the completion handlers.

4. **Activity vs `Exercise**`: Activity duration tracks all physical movement exceeding a minimum threshold, while exercise duration tracks only dedicated exercise sessions meeting intensity and duration criteria.

5. **Historical Data `Access**`: Use `syncRawDataFromStartTime:endTime:completion:` for detailed item-level data and `syncDailyDataFromStartTime:endTime:completion:` for aggregated daily summaries. Choose based on your analysis needs.

6. **Goal Value `Ranges**`: Adhere to the recommended ranges for each goal type (e.g., 0–100,000 steps, 50–3,000 kcal) to ensure accurate health analysis on the device.

7. **Reminder `Configuration**`: Reminder switches are independent of goals. Users