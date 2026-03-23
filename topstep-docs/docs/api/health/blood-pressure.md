---
sidebar_position: 5
title: 血压
---

# 血压（TSBloodPressure）

TopStepComKit iOS SDK 提供了完整的血压测量和监测功能，支持手动测量、自动监测以及历史数据同步。血压数据包括收缩压和舒张压值，是心血管健康的重要指标。

## 前提条件

- 设备已成功配对并连接
- 设备支持血压测量或监测功能（可通过 `isSupportAutomaticMonitoring` 方法检查）
- 用户已授予相应的健康数据权限

## 数据模型

### TSBPValueItem

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `systolic` | `UInt8` | 收缩压值，单位 mmHg |
| `diastolic` | `UInt8` | 舒张压值，单位 mmHg |
| `isUserInitiated` | `BOOL` | 指示该测量是否为用户主动发起 |
| `timestamp` | `NSTimeInterval` | 测量时间戳（继承自 `TSHealthValueItem`） |

### TSBPDailyModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `maxSystolicItem` | `TSBPValueItem *` | 当天最大收缩压条目 |
| `minSystolicItem` | `TSBPValueItem *` | 当天最小收缩压条目 |
| `maxDiastolicItem` | `TSBPValueItem *` | 当天最大舒张压条目 |
| `minDiastolicItem` | `TSBPValueItem *` | 当天最小舒张压条目 |
| `autoItems` | `NSArray<TSBPValueItem *> *` | 自动监测血压条目数组，按时间升序排列 |
| `date` | `NSTimeInterval` | 日期时间戳（继承自 `TSHealthDailyModel`） |

## 枚举与常量

无

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `void (^)(BOOL success, NSError *_Nullable error)` | 测量开始/停止回调，返回成功状态和错误信息 |
| `void (^)(TSBPValueItem *_Nullable data, NSError *_Nullable error)` | 实时数据回调，返回单次测量结果或错误信息 |
| `TSCompletionBlock` | 完成回调，通常为 `void (^)(NSError *_Nullable error)` |
| `void (^)(TSAutoMonitorBPConfigs *_Nullable configuration, NSError *_Nullable error)` | 配置查询回调，返回自动监测配置或错误信息 |
| `void (^)(NSArray<TSBPValueItem *> *_Nullable bpItems, NSError *_Nullable error)` | 原始数据同步回调，返回血压测量条目数组或错误信息 |
| `void (^)(NSArray<TSBPDailyModel *> *_Nullable dailyModels, NSError *_Nullable error)` | 每日数据同步回调，返回每日聚合数据或错误信息 |

## 接口方法

### 检查设备是否支持手动血压测量

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**返回值**

| 返回值 | 说明 |
|--------|------|
| `BOOL` | 如果设备支持手动血压测量返回 `YES`，否则返回 `NO` |

**代码示例**

```objc
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;
if ([bloodPressure isSupportActivityMeasureByUser]) {
    TSLog(@"设备支持手动血压测量");
} else {
    TSLog(@"设备不支持手动血压测量");
}
```

### 启动血压测量

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSBPValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `measureParam` | `TSActivityMeasureParam *` | 测量活动的参数配置 |
| `startHandler` | `void (^)(BOOL success, NSError *_Nullable error)` | 测量开始回调。`success` 表示是否成功启动，`error` 为启动失败时的错误信息 |
| `dataHandler` | `void (^)(TSBPValueItem *_Nullable data, NSError *_Nullable error)` | 实时数据回调。`data` 为实时测量结果，`error` 为接收失败时的错误信息 |
| `endHandler` | `void (^)(BOOL success, NSError *_Nullable error)` | 测量结束回调。`success` 表示是否正常结束（`YES`）或被中断（`NO`），`error` 为异常结束时的错误信息 |

**代码示例**

```objc
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];

[bloodPressure startMeasureWithParam:param
                     startHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"血压测量已启动");
    } else {
        TSLog(@"启动测量失败: %@", error.localizedDescription);
    }
} dataHandler:^(TSBPValueItem * _Nullable data, NSError * _Nullable error) {
    if (data) {
        TSLog(@"收缩压: %d, 舒张压: %d", data.systolic, data.diastolic);
    } else {
        TSLog(@"接收数据失败: %@", error.localizedDescription);
    }
} endHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"血压测量正常结束");
    } else {
        TSLog(@"血压测量被中断: %@", error.localizedDescription);
    }
}];
```

### 停止血压测量

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSCompletionBlock` | 停止完成回调，error 为失败时的错误信息 |

**代码示例**

```objc
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;

[bloodPressure stopMeasureCompletion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"停止测量失败: %@", error.localizedDescription);
    } else {
        TSLog(@"血压测量已停止");
    }
}];
```

### 检查设备是否支持自动血压监测

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**返回值**

| 返回值 | 说明 |
|--------|------|
| `BOOL` | 如果设备支持自动血压监测返回 `YES`，否则返回 `NO` |

**代码示例**

```objc
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;

if ([bloodPressure isSupportAutomaticMonitoring]) {
    TSLog(@"设备支持自动血压监测");
} else {
    TSLog(@"设备不支持自动血压监测");
}
```

### 配置自动血压监测

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorBPConfigs *_Nonnull)configuration
                        completion:(nonnull TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `configuration` | `TSAutoMonitorBPConfigs *` | 自动监测的配置参数 |
| `completion` | `TSCompletionBlock` | 完成回调，配置设置成功或失败时调用 |

**代码示例**

```objc
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;
TSAutoMonitorBPConfigs *config = [[TSAutoMonitorBPConfigs alloc] init];
// 配置自动监测参数

[bloodPressure pushAutoMonitorConfigs:config
                        completion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"自动监测配置已设置");
    } else {
        TSLog(@"设置配置失败: %@", error.localizedDescription);
    }
}];
```

### 获取当前自动血压监测配置

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorBPConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorBPConfigs *_Nullable, NSError *_Nullable)` | 完成回调，返回当前配置或错误信息 |

**代码示例**

```objc
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;

[bloodPressure fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorBPConfigs * _Nullable configuration, NSError * _Nullable error) {
    if (configuration) {
        TSLog(@"当前自动监测配置: %@", configuration);
    } else {
        TSLog(@"获取配置失败: %@", error.localizedDescription);
    }
}];
```

### 同步指定时间范围内的原始血压数据

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSBPValueItem *> *_Nullable bpItems, NSError *_Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 同步开始时间（1970年以来的秒数时间戳） |
| `endTime` | `NSTimeInterval` | 同步结束时间（1970年以来的秒数时间戳） |
| `completion` | `void (^)(NSArray<TSBPValueItem *> *_Nullable, NSError *_Nullable)` | 完成回调，返回血压测量条目数组或错误信息 |

**代码示例**

```objc
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;

NSDate *startDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-86400]; // 24小时前
NSDate *endDate = [NSDate date]; // 现在

[bloodPressure syncRawDataFromStartTime:startDate.timeIntervalSince1970
                              endTime:endDate.timeIntervalSince1970
                           completion:^(NSArray<TSBPValueItem *> * _Nullable bpItems, NSError * _Nullable error) {
    if (bpItems) {
        TSLog(@"同步了 %lu 条血压数据", (unsigned long)bpItems.count);
        for (TSBPValueItem *item in bpItems) {
            TSLog(@"时间: %@, 收缩压: %d, 舒张压: %d, 用户发起: %d",
                  [NSDate dateWithTimeIntervalSince1970:item.timestamp],
                  item.systolic, item.diastolic, item.isUserInitiated);
        }
    } else {
        TSLog(@"同步数据失败: %@", error.localizedDescription);
    }
}];
```

### 同步从指定开始时间至今的原始血压数据

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSBPValueItem *> *_Nullable bpItems, NSError *_Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 同步开始时间（1970年以来的秒数时间戳） |
| `completion` | `void (^)(NSArray<TSBPValueItem *> *_Nullable, NSError *_Nullable)` | 完成回调，返回血压测量条目数组或错误信息 |

**代码示例**

```objc
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;

NSDate *startDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-604800]; // 7天前

[bloodPressure syncRawDataFromStartTime:startDate.timeIntervalSince1970
                           completion:^(NSArray<TSBPValueItem *> * _Nullable bpItems, NSError * _Nullable error) {
    if (bpItems) {
        TSLog(@"同步了 %lu 条血压数据", (unsigned long)bpItems.count);
    } else {
        TSLog(@"同步数据失败: %@", error.localizedDescription);
    }
}];
```

### 同步指定时间范围内的每日血压数据

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSBPDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 同步开始时间，自动规范化为该日 00:00:00（1970年以来的秒数时间戳）。必须早于 `endTime` |
| `endTime` | `NSTimeInterval` | 同步结束时间，自动规范化为该日 23:59:59（1970年以来的秒数时间戳）。必须晚于 `startTime` 且不能在将来 |
| `completion` | `void (^)(NSArray<TSBPDailyModel *> *_Nullable, NSError *_Nullable)` | 完成回调，返回每日血压聚合数据或错误信息。每个 `TSBPDailyModel` 代表一天的数据集合 |

**代码示例**

```objc
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;

NSDate *startDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-604800]; // 7天前
NSDate *endDate = [NSDate date]; // 今天

[bloodPressure syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                                endTime:endDate.timeIntervalSince1970
                             completion:^(NSArray<TSBPDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (dailyModels) {
        TSLog(@"同步了 %lu 天的血压数据", (unsigned long)dailyModels.count);
        for (TSBPDailyModel *dayModel in dailyModels) {
            TSLog(@"日期: %@, 最高收缩压: %d, 最低收缩压: %d",
                  [NSDate dateWithTimeIntervalSince1970:dayModel.date],
                  dayModel.maxSystolic, dayModel.minSystolic);
        }
    } else {
        TSLog(@"同步数据失败: %@", error.localizedDescription);
    }
}];
```

### 同步从指定开始时间至今的每日血压数据

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSBPDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 同步开始时间，自动规范化为该日 00:00:00（1970年以来的秒数时间戳）。数据将从此时间同步至当前时间 |
| `completion` | `void (^)(NSArray<TSBPDailyModel *> *_Nullable, NSError *_Nullable)` | 完成回调，返回每日血压聚合数据或错误信息。每个 `TSBPDailyModel` 代表一天的数据集合 |

**代码示例**

```objc
id<TSBloodPressureInterface> bloodPressure = [TopStepComKit sharedInstance].bloodPressure;

NSDate *startDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-2592000]; // 30天前

[bloodPressure syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                             completion:^(NSArray<TSBPDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (dailyModels) {
        TSLog(@"同步了 %lu 天的血压数据至今", (unsigned long)dailyModels.count);
        for (TSBPDailyModel *dayModel in dailyModels) {
            NSUInteger totalCount = dayModel.manualItems.count + dayModel.autoItems.count;
            TSLog(@"日期: %@, 总测量次数: %lu",
                  [NSDate dateWithTimeIntervalSince1970:dayModel.date],
                  (unsigned long)totalCount);
        }
    } else {
        TSLog(@"同步数据失败: %@", error.localizedDescription);
    }
}];
```

## TSBPDailyModel 方法

### 获取最大收缩压值

```objc
- (UInt8)maxSystolic;
```

**返回值**

| 返回值 | 说明 |
|--------|------|
| `UInt8` | 最大收缩压值，当 `maxSystolicItem` 为空时返回 `0` |

### 获取最小收缩压值

```objc
- (UInt8)minSystolic;
```

**返回值**

| 返回值 | 说明 |
|--------|------|
| `UInt8` | 最小收缩压值，当 `minSystolicItem` 为空时返回 `0` |

### 获取最大舒张压值

```objc
- (UInt8)maxDiastolic;
```

**返回值**

| 返回值 | 说明 |
|--------|------|
| `UInt8` | 最大舒张压值，当 `maxDiastolicItem` 为空时返回 `0` |

### 获取最小舒张压值

```objc
- (UInt8)minDiastolic;
```

**返回值**

| 返回值 | 说明 |
|--------|------|
| `UInt8` | 最小舒张压值，当 `minDiastolicItem` 为空时返回 `0` |

### 获取所有测量条目

```objc
- (NSArray<TSBPValueItem *> *)allMeasuredItems;
```

**返回值**

| 返回值 | 说明 |
|--------|------|
| `NSArray<TSBPValueItem *> *` | 合并后的主动和自动测量条目数组，按时间排序 |

**代码示例**

```objc
TSBPDailyModel *dailyModel = /* 获取每日血压模型 */;

TSLog(@"最大收缩压: %d", [dailyModel maxSystolic]);
TSLog(@"最小收缩压: %d", [dailyModel minSystolic]);
TSLog(@"最大舒张压: %d", [dailyModel maxDiastolic]);
TSLog(@"最小舒张压: %d", [dailyModel minDiastolic]);

NSArray<TSBPValueItem *> *allItems = [dailyModel allMeasuredItems];
TSLog(@"当天总测量次数: %lu", (unsigned long)allItems.count);
```

## 注意事项

1. **权限检查**：在启动测量前，务必使用 `isSupportActivityMeasureByUser` 方法检查设备是否支持该功能，避免调用不支持的功能导致错误。

2. **时间戳格式**：所有时间参数使用 Unix 时间戳（1970年以来的秒数）。可使用 `NSDate` 的 `timeIntervalSince1970` 属性获取当前时间的时间戳。

3. **每日数据时间规范化**：在调用 `syncDailyDataFromStartTime:endTime:completion:` 时，系统会自动将 `startTime` 规范化为指定日期的 00:00:00，将 `endTime` 规范化为 23:59:59，无需手动处理。

4. **数据排序**：返回的数据按照时间升序排列。`TSBPDailyModel` 中的 `manualItems` 和 `autoItems` 均按时间升序排列。

5. **回调线程**：完成回调通常在主线程中调用，可以安全地更新 UI。

6. **错误处理**：始终检查回调中的 `error` 参数。如果 `error` 不为 `nil`，则操作失败，数据参数可能为 `nil`。

7. **测量约束**：
   - 同一时间只能进行一次血压测量
   - 启动新的测量前应先停止现有测量
   - 测量过程中保持设备和用户手臂的正确位置以获得准确的测量结果

8. **自动监测配置**：修改自动监测配置后，设备需要一定时间来应用新的配置。建议在配置设置后稍等片刻再启动其他操作。

9. **数据缓存**：设备内部通常有有限的数据存储空间，建议定期同步历史数据到应用本地存储以避免数据丢失。

10. **日期范围限制**：`endTime` 不能设置为未来时间，同步每日数据时应确保 `startTime` 早于 `endTime`。

```
</markdown>