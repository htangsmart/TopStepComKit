---
sidebar_position: 10
title: 日常活动
---

# 日常活动（TSDailyActivity）

该模块提供每日活动和运动数据的管理功能，包括获取和设置运动目标、同步今天的活动数据、检索历史活动数据等。每日活动跟踪包括步数、距离、卡路里和运动时长等多项指标。

## 前提条件

1. 已正确初始化 TopStepComKit SDK
2. 设备已连接并配对
3. 用户已授权访问健康数据权限
4. 设备支持日常活动数据采集功能

## 数据模型

### TSDailyActivityGoals

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `stepsGoal` | `NSInteger` | 每日步数目标（步），推荐范围：0–100,000 |
| `caloriesGoal` | `NSInteger` | 每日消耗卡路里目标（千卡），推荐范围：50–3,000 |
| `distanceGoal` | `NSInteger` | 每日运动距离目标（米），推荐范围：0–100,000 |
| `activityDurationGoal` | `NSInteger` | 每日活动时长目标（分钟），范围：0–1,440 |
| `exerciseDurationGoal` | `NSInteger` | 每日运动时长目标（分钟），范围：0–1,440 |
| `exerciseTimesGoal` | `NSInteger` | 每日运动次数目标（次），推荐范围：1–50 |
| `activityTimesGoal` | `NSInteger` | 每日活动次数目标（次），推荐范围：1–100 |

### TSDailyActivityItem

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `steps` | `NSInteger` | 当日总步数 |
| `calories` | `NSInteger` | 消耗的总卡路里（小卡） |
| `distance` | `NSInteger` | 总距离（米） |
| `activityDuration` | `NSInteger` | 总活动时长（秒） |
| `exercisesDuration` | `NSInteger` | 运动时长（秒） |
| `exercisesTimes` | `NSInteger` | 运动次数 |
| `activityTimes` | `NSInteger` | 活动次数 |

### TSDailyActivityReminder

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `stepsReminderEnabled` | `BOOL` | 步数目标提醒是否开启 |
| `caloriesReminderEnabled` | `BOOL` | 卡路里目标提醒是否开启 |
| `distanceReminderEnabled` | `BOOL` | 距离目标提醒是否开启 |
| `activityTimesReminderEnabled` | `BOOL` | 活动次数目标提醒是否开启 |
| `activityDurationReminderEnabled` | `BOOL` | 活动时长目标提醒是否开启 |
| `exerciseTimesReminderEnabled` | `BOOL` | 运动次数目标提醒是否开启 |
| `exerciseDurationReminderEnabled` | `BOOL` | 运动时长目标提醒是否开启 |

### TSActivityDailyModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `steps` | `NSInteger` | 当日步数汇总 |
| `calories` | `NSInteger` | 当日卡路里汇总（小卡），只读 |
| `distance` | `NSInteger` | 当日距离汇总（米），只读 |
| `activityDuration` | `NSInteger` | 当日活动时长汇总（秒），只读 |
| `activityTimes` | `NSInteger` | 当日活动次数汇总，只读 |
| `exercisesDuration` | `NSInteger` | 当日运动时长汇总（秒），只读 |
| `exercisesTimes` | `NSInteger` | 当日运动次数汇总，只读 |
| `activityItems` | `NSArray<TSDailyActivityItem *> *` | 当天活动测量条目数组，按时间升序排列 |

## 枚举与常量

### TSDailyActivityType

| 枚举值 | 说明 |
|--------|------|
| `TSDailyActivityTypeStepCount` | 步数 |
| `TSDailyActivityTypeExerciseDuration` | 锻炼时长 |
| `TSDailyActivityTypeActivityCount` | 活动次数 |
| `TSDailyActivityTypeActiveDuration` | 活动时长 |
| `TSDailyActivityTypeDistance` | 距离 |
| `TSDailyActivityTypeCalories` | 卡路里 |

## 接口方法

### 获取支持的每日活动类型

```objc
- (void)fetchSupportedDailyActivityTypesWithCompletion:(void(^)(NSArray<NSNumber *> *_Nullable activityTypes, NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(NSArray<NSNumber *> *_Nullable, NSError *_Nullable)` | 返回支持的活动类型数组或错误的完成回调 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

[dailyActivity fetchSupportedDailyActivityTypesWithCompletion:^(NSArray<NSNumber *> * _Nullable activityTypes, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取支持的活动类型失败: %@", error.localizedDescription);
        return;
    }
    
    for (NSNumber *typeNumber in activityTypes) {
        TSDailyActivityType type = (TSDailyActivityType)[typeNumber integerValue];
        switch (type) {
            case TSDailyActivityTypeStepCount:
                TSLog(@"支持步数追踪");
                break;
            case TSDailyActivityTypeExerciseDuration:
                TSLog(@"支持运动时长");
                break;
            default:
                break;
        }
    }
}];
```

### 获取当前每日运动目标

```objc
- (void)fetchDailyExerciseGoalsWithCompletion:(void(^)(TSDailyActivityGoals *_Nullable goals, NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSDailyActivityGoals *_Nullable, NSError *_Nullable)` | 返回当前目标或错误的完成回调 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

[dailyActivity fetchDailyExerciseGoalsWithCompletion:^(TSDailyActivityGoals * _Nullable goals, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取运动目标失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"当前步数目标: %ld 步", (long)goals.stepsGoal);
    TSLog(@"当前卡路里目标: %ld kcal", (long)goals.caloriesGoal);
    TSLog(@"当前距离目标: %ld 米", (long)goals.distanceGoal);
    TSLog(@"当前活动时长目标: %ld 分钟", (long)goals.activityDurationGoal);
    TSLog(@"当前运动时长目标: %ld 分钟", (long)goals.exerciseDurationGoal);
}];
```

### 设置每日运动目标

```objc
- (void)pushDailyExerciseGoals:(TSDailyActivityGoals *)goalsModel
                    completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `goalsModel` | `TSDailyActivityGoals *` | 包含需设置的目标模型 |
| `completion` | `void (^)(NSError *_Nullable)` | 指示操作是否成功及错误信息的完成回调 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

TSDailyActivityGoals *goals = [[TSDailyActivityGoals alloc] init];
goals.stepsGoal = 8000;
goals.caloriesGoal = 500;
goals.distanceGoal = 5000;
goals.activityDurationGoal = 60;
goals.exerciseDurationGoal = 30;
goals.exerciseTimesGoal = 3;
goals.activityTimesGoal = 10;

[dailyActivity pushDailyExerciseGoals:goals completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置运动目标失败: %@", error.localizedDescription);
        return;
    }
    TSLog(@"运动目标设置成功");
}];
```

### 获取每日运动目标与提醒配置

```objc
- (void)fetchDailyExerciseAllWithCompletion:(void(^)(TSDailyActivityGoals *_Nullable goals,
                                                    TSDailyActivityReminder *_Nullable reminder,
                                                    NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSDailyActivityGoals *_Nullable, TSDailyActivityReminder *_Nullable, NSError *_Nullable)` | 返回目标模型、提醒模型与错误的完成回调 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

[dailyActivity fetchDailyExerciseAllWithCompletion:^(TSDailyActivityGoals * _Nullable goals, TSDailyActivityReminder * _Nullable reminder, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取目标和提醒配置失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"步数目标: %ld", (long)goals.stepsGoal);
    TSLog(@"步数提醒已开启: %@", reminder.stepsReminderEnabled ? @"是" : @"否");
    TSLog(@"卡路里提醒已开启: %@", reminder.caloriesReminderEnabled ? @"是" : @"否");
}];
```

### 原子性设置运动目标与提醒配置

```objc
- (void)pushDailyExerciseGoals:(TSDailyActivityGoals *)goalsModel
                       reminder:(TSDailyActivityReminder *)reminder
                      completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `goalsModel` | `TSDailyActivityGoals *` | 需要设置的目标模型 |
| `reminder` | `TSDailyActivityReminder *` | 需要设置的提醒开关模型 |
| `completion` | `void (^)(NSError *_Nullable)` | 指示操作是否成功及错误信息的完成回调 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

TSDailyActivityGoals *goals = [[TSDailyActivityGoals alloc] init];
goals.stepsGoal = 10000;
goals.caloriesGoal = 600;

TSDailyActivityReminder *reminder = [[TSDailyActivityReminder alloc] init];
reminder.stepsReminderEnabled = YES;
reminder.caloriesReminderEnabled = YES;
reminder.distanceReminderEnabled = NO;

[dailyActivity pushDailyExerciseGoals:goals 
                              reminder:reminder 
                           completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置目标和提醒失败: %@", error.localizedDescription);
        return;
    }
    TSLog(@"目标和提醒设置成功");
}];
```

### 获取每日运动提醒配置

```objc
- (void)fetchDailyExerciseReminderConfigWithCompletion:(void(^)(TSDailyActivityReminder *_Nullable reminder, NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSDailyActivityReminder *_Nullable, NSError *_Nullable)` | 返回提醒开关或错误的完成回调 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

[dailyActivity fetchDailyExerciseReminderConfigWithCompletion:^(TSDailyActivityReminder * _Nullable reminder, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取提醒配置失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"步数提醒: %@", reminder.stepsReminderEnabled ? @"开启" : @"关闭");
    TSLog(@"卡路里提醒: %@", reminder.caloriesReminderEnabled ? @"开启" : @"关闭");
    TSLog(@"距离提醒: %@", reminder.distanceReminderEnabled ? @"开启" : @"关闭");
    TSLog(@"活动时长提醒: %@", reminder.activityDurationReminderEnabled ? @"开启" : @"关闭");
    TSLog(@"运动时长提醒: %@", reminder.exerciseDurationReminderEnabled ? @"开启" : @"关闭");
}];
```

### 设置每日运动提醒配置

```objc
- (void)pushDailyExerciseReminder:(TSDailyActivityReminder *)reminder
                              completion:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `reminder` | `TSDailyActivityReminder *` | 需要设置的提醒开关模型 |
| `completion` | `void (^)(NSError *_Nullable)` | 指示操作是否成功及错误信息的完成回调 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

TSDailyActivityReminder *reminder = [[TSDailyActivityReminder alloc] init];
reminder.stepsReminderEnabled = YES;
reminder.caloriesReminderEnabled = YES;
reminder.distanceReminderEnabled = YES;
reminder.activityTimesReminderEnabled = YES;
reminder.activityDurationReminderEnabled = YES;
reminder.exerciseTimesReminderEnabled = YES;
reminder.exerciseDurationReminderEnabled = YES;

[dailyActivity pushDailyExerciseReminder:reminder completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置提醒配置失败: %@", error.localizedDescription);
        return;
    }
    TSLog(@"提醒配置设置成功");
}];
```

### 同步今天的每日运动数据

```objc
- (void)syncTodayDailyExerciseDataCompletion:(void (^)(TSActivityDailyModel *_Nullable todayActivity, NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSActivityDailyModel *_Nullable, NSError *_Nullable)` | 包含今天的运动数据或错误的完成回调块 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

[dailyActivity syncTodayDailyExerciseDataCompletion:^(TSActivityDailyModel * _Nullable todayActivity, NSError * _Nullable error) {
    if (error) {
        TSLog(@"同步今天的活动数据失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"今天步数: %ld", (long)todayActivity.steps);
    TSLog(@"今天卡路里: %ld", (long)todayActivity.calories);
    TSLog(@"今天距离: %ld 米", (long)todayActivity.distance);
    TSLog(@"今天活动时长: %ld 秒", (long)todayActivity.activityDuration);
    TSLog(@"今天运动时长: %ld 秒", (long)todayActivity.exercisesDuration);
    TSLog(@"今天运动次数: %ld", (long)todayActivity.exercisesTimes);
    TSLog(@"今天活动次数: %ld", (long)todayActivity.activityTimes);
}];
```

### 同步指定时间范围内的原始每日活动数据

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSDailyActivityItem *> *_Nullable activityItems, NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳） |
| `endTime` | `NSTimeInterval` | 数据同步的结束时间（1970年以来的秒数时间戳） |
| `completion` | `void (^)(NSArray<TSDailyActivityItem *> *_Nullable, NSError *_Nullable)` | 包含同步的原始每日活动测量条目或错误的完成回调块 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-7 * 24 * 3600]; // 7 天前
NSDate *endDate = [NSDate date]; // 现在

[dailyActivity syncRawDataFromStartTime:[startDate timeIntervalSince1970]
                                endTime:[endDate timeIntervalSince1970]
                             completion:^(NSArray<TSDailyActivityItem *> * _Nullable activityItems, NSError * _Nullable error) {
    if (error) {
        TSLog(@"同步原始数据失败: %@", error.localizedDescription);
        return;
    }
    
    for (TSDailyActivityItem *item in activityItems) {
        TSLog(@"时间: %@, 步数: %ld, 卡路里: %ld", 
              [NSDate dateWithTimeIntervalSince1970:item.measureTime],
              (long)item.steps,
              (long)item.calories);
    }
}];
```

### 同步从指定时间至今的原始每日活动数据

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSDailyActivityItem *> *_Nullable activityItems, NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳） |
| `completion` | `void (^)(NSArray<TSDailyActivityItem *> *_Nullable, NSError *_Nullable)` | 包含同步的原始每日活动测量条目或错误的完成回调块 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-30 * 24 * 3600]; // 30 天前

[dailyActivity syncRawDataFromStartTime:[startDate timeIntervalSince1970]
                             completion:^(NSArray<TSDailyActivityItem *> * _Nullable activityItems, NSError * _Nullable error) {
    if (error) {
        TSLog(@"同步原始数据失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"获取了 %lu 条活动记录", (unsigned long)activityItems.count);
    for (TSDailyActivityItem *item in activityItems) {
        TSLog(@"步数: %ld, 距离: %ld 米", (long)item.steps, (long)item.distance);
    }
}];
```

### 同步指定时间范围内的每日活动数据

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSActivityDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳），将自动规范化为指定日期的 00:00:00 |
| `endTime` | `NSTimeInterval` | 数据同步的结束时间（1970年以来的秒数时间戳），将自动规范化为指定日期的 23:59:59 |
| `completion` | `void (^)(NSArray<TSActivityDailyModel *> *_Nullable, NSError *_Nullable)` | 完成回调，返回同步的每日活动模型数组或错误 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-14 * 24 * 3600]; // 14 天前
NSDate *endDate = [NSDate date]; // 现在

[dailyActivity syncDailyDataFromStartTime:[startDate timeIntervalSince1970]
                                  endTime:[endDate timeIntervalSince1970]
                               completion:^(NSArray<TSActivityDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (error) {
        TSLog(@"同步每日数据失败: %@", error.localizedDescription);
        return;
    }
    
    for (TSActivityDailyModel *dailyModel in dailyModels) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:dailyModel.startTime];
        TSLog(@"%@: 步数=%ld, 卡路里=%ld, 距离=%ld米, 运动时长=%ld秒",
              date,
              (long)dailyModel.steps,
              (long)dailyModel.calories,
              (long)dailyModel.distance,
              (long)dailyModel.exercisesDuration);
    }
}];
```

### 同步从指定时间至今的每日活动数据

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSActivityDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳），将自动规范化为指定日期的 00:00:00 |
| `completion` | `void (^)(NSArray<TSActivityDailyModel *> *_Nullable, NSError *_Nullable)` | 完成回调，返回同步的每日活动模型数组或错误 |

**代码示例：**

```objc
id<TSDailyActivityInterface> dailyActivity = [tsKitManager getInterface:@protocol(TSDailyActivityInterface)];

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-7 * 24 * 3600]; // 7 天前

[dailyActivity syncDailyDataFromStartTime:[startDate timeIntervalSince1970]
                               completion:^(NSArray<TSActivityDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (error) {
        TSLog(@"同步每日数据失败: %@", error.localizedDescription);
        return;
    }
    
    NSInteger totalSteps = 0;
    for (TSActivityDailyModel *dailyModel in dailyModels) {
        totalSteps += dailyModel.steps;
    }
    TSLog(@"过去7天总步数: %ld", (long)totalSteps);
}];
```

## 注意事项

1. **时间戳格式**：所有时间参数使用 Unix 时间戳（1970年以来的秒数）。建议使用 `NSDate` 的 `timeIntervalSince1970` 属性进行转换。

2. **时间范围自动规范化**：调用 `syncDailyData*` 方法时，startTime 和 endTime 会自动规范化为日期边界（开始时间为 00:00:00，结束时间为 23:59:59）。

3. **目标值范围**：设置运动目标时，应遵循文档中建议的范围值。超出范围的值可能影响设备显示和数据分析的准确性。

4. **原子性操作**：`pushDailyExerciseGoals:reminder:completion:` 方法会原子性地同时写入目标和提醒配置，避免出现中间不一致的状态。建议优先使用此方法而非分别调用两个独立方法。

5. **完成回调线程**：所有完成回调都在主线程中执行，可以直接进行 UI 更新操作。

6. **数据一致性**：`fetchDailyExerciseAllWithCompletion:` 方法在单次请求中同时获取目标和提醒配置，可确保数据的一致性。

7. **历史数据检索**：使用 `syncRawData*` 方法获取原始每日数据，每个条目代表一天的统计；使用 `syncDailyData*` 方法获取已聚合的每日数据。

8. **错误处理**：建议始终检查 completion 块中的 error 参数，并根据错误类型实现相应的错误处理逻辑。