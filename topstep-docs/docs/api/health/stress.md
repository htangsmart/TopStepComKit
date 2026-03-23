---
sidebar_position: 6
title: 压力
---

# 压力（TSStress）

该模块提供压力水平测量、自动监测和历史数据同步的功能。支持手动压力测量、自动监测配置以及原始数据和日统计数据的同步。

## 前提条件

1. 设备需支持压力测量功能
2. 需要先完成设备连接和初始化
3. 根据具体功能检查设备是否支持手动测量或自动监测

## 数据模型

### TSStressValueItem（压力测量条目）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `stressValue` | `UInt8` | 压力水平值，通常范围为 0-100 |
| `isUserInitiated` | `BOOL` | 指示测量是否由用户主动发起 |
| `timestamp` | `NSTimeInterval` | 测量时间戳（继承自 TSHealthValueItem） |

### TSStressDailyModel（每日压力数据）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `maxStressItem` | `TSStressValueItem *` | 当天最大压力条目 |
| `minStressItem` | `TSStressValueItem *` | 当天最小压力条目 |
| `manualItems` | `NSArray<TSStressValueItem *> *` | 用户主动测量的压力数组，按时间升序排列 |
| `autoItems` | `NSArray<TSStressValueItem *> *` | 设备自动监测的压力数组，按时间升序排列 |

## 枚举与常量

无

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `void (^)(BOOL success, NSError * _Nullable error)` | 操作完成回调，返回成功状态和错误信息 |
| `void (^)(TSStressValueItem * _Nullable data, NSError * _Nullable error)` | 实时数据接收回调，返回压力测量数据或错误 |
| `TSCompletionBlock` | 完成操作回调（详见基础接口定义） |
| `void (^)(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error)` | 配置获取回调，返回监测配置或错误 |
| `void (^)(NSArray<TSStressValueItem *> * _Nullable stressItems, NSError * _Nullable error)` | 原始数据同步回调，返回压力测量条目数组或错误 |
| `void (^)(NSArray<TSStressDailyModel *> * _Nullable dailyModels, NSError * _Nullable error)` | 日数据同步回调，返回每日压力模型数组或错误 |

## 接口方法

### 检查设备是否支持手动压力测量

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**参数：** 无

**返回值：** 如果设备支持手动压力测量返回 `YES`，否则返回 `NO`

**代码示例：**

```objc
id<TSStressInterface> stressInterface = [TopStepComKit sharedInstance].stress;
BOOL isSupport = [stressInterface isSupportActivityMeasureByUser];
if (isSupport) {
    TSLog(@"设备支持手动压力测量");
} else {
    TSLog(@"设备不支持手动压力测量");
}
```

### 开始压力测量

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSStressValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `measureParam` | `TSActivityMeasureParam *` | 测量活动的参数配置 |
| `startHandler` | `void (^)(BOOL, NSError *)` | 测量开始或失败时调用的回调块 |
| `dataHandler` | `void (^)(TSStressValueItem *, NSError *)` | 接收实时测量数据的回调块 |
| `endHandler` | `void (^)(BOOL, NSError *)` | 测量结束时调用的回调块 |

**代码示例：**

```objc
id<TSStressInterface> stressInterface = [TopStepComKit sharedInstance].stress;
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
// 根据需要配置 param 的其他属性

[stressInterface startMeasureWithParam:param
    startHandler:^(BOOL success, NSError *error) {
        if (success) {
            TSLog(@"压力测量已开始");
        } else {
            TSLog(@"压力测量启动失败: %@", error.localizedDescription);
        }
    }
    dataHandler:^(TSStressValueItem *data, NSError *error) {
        if (data) {
            TSLog(@"实时压力值: %d", data.stressValue);
        } else {
            TSLog(@"数据接收失败: %@", error.localizedDescription);
        }
    }
    endHandler:^(BOOL success, NSError *error) {
        if (success) {
            TSLog(@"压力测量已正常结束");
        } else {
            TSLog(@"压力测量异常结束: %@", error.localizedDescription);
        }
    }
];
```

### 停止压力测量

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSCompletionBlock` | 测量停止或失败时调用的完成回调块 |

**代码示例：**

```objc
id<TSStressInterface> stressInterface = [TopStepComKit sharedInstance].stress;
[stressInterface stopMeasureCompletion:^(NSError *error) {
    if (error) {
        TSLog(@"停止测量失败: %@", error.localizedDescription);
    } else {
        TSLog(@"测量已停止");
    }
}];
```

### 检查设备是否支持自动压力监测

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**参数：** 无

**返回值：** 如果设备支持自动压力监测返回 `YES`，否则返回 `NO`

**代码示例：**

```objc
id<TSStressInterface> stressInterface = [TopStepComKit sharedInstance].stress;
BOOL isSupport = [stressInterface isSupportAutomaticMonitoring];
if (isSupport) {
    TSLog(@"设备支持自动压力监测");
} else {
    TSLog(@"设备不支持自动压力监测");
}
```

### 配置自动压力监测

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `configuration` | `TSAutoMonitorConfigs *` | 自动监测的配置参数 |
| `completion` | `TSCompletionBlock` | 配置设置成功或失败时调用的完成回调块 |

**代码示例：**

```objc
id<TSStressInterface> stressInterface = [TopStepComKit sharedInstance].stress;
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];
// 根据需要配置 config 的属性

[stressInterface pushAutoMonitorConfigs:config completion:^(NSError *error) {
    if (error) {
        TSLog(@"配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"自动监测配置已更新");
    }
}];
```

### 获取当前自动监测配置

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | 包含当前配置或错误的完成回调块 |

**代码示例：**

```objc
id<TSStressInterface> stressInterface = [TopStepComKit sharedInstance].stress;
[stressInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *configuration, NSError *error) {
    if (error) {
        TSLog(@"获取配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"已获取自动监测配置");
    }
}];
```

### 同步指定时间范围内的原始压力数据

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSStressValueItem *> *_Nullable stressItems, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳） |
| `endTime` | `NSTimeInterval` | 数据同步的结束时间（1970年以来的秒数时间戳） |
| `completion` | `void (^)(NSArray<TSStressValueItem *> *, NSError *)` | 包含同步的原始压力测量条目或错误的完成回调块 |

**代码示例：**

```objc
id<TSStressInterface> stressInterface = [TopStepComKit sharedInstance].stress;

NSDate *today = [NSDate date];
NSDate *oneWeekAgo = [today dateByAddingTimeInterval:-7 * 24 * 3600];

[stressInterface syncRawDataFromStartTime:oneWeekAgo.timeIntervalSince1970
                                 endTime:today.timeIntervalSince1970
                              completion:^(NSArray<TSStressValueItem *> *stressItems, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else {
        TSLog(@"已同步 %lu 条原始压力数据", (unsigned long)stressItems.count);
        for (TSStressValueItem *item in stressItems) {
            TSLog(@"压力值: %d, 时间: %@", item.stressValue, [NSDate dateWithTimeIntervalSince1970:item.timestamp]);
        }
    }
}];
```

### 同步从指定开始时间至今的原始压力数据

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSStressValueItem *> *_Nullable stressItems, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳） |
| `completion` | `void (^)(NSArray<TSStressValueItem *> *, NSError *)` | 包含同步的原始压力测量条目或错误的完成回调块 |

**代码示例：**

```objc
id<TSStressInterface> stressInterface = [TopStepComKit sharedInstance].stress;

NSDate *oneMonthAgo = [[NSDate date] dateByAddingTimeInterval:-30 * 24 * 3600];

[stressInterface syncRawDataFromStartTime:oneMonthAgo.timeIntervalSince1970
                              completion:^(NSArray<TSStressValueItem *> *stressItems, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else {
        TSLog(@"已同步 %lu 条原始压力数据（从 %@ 至今）", 
              (unsigned long)stressItems.count, 
              oneMonthAgo);
    }
}];
```

### 同步指定时间范围内的每日压力数据

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSStressDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳），将自动规范化为指定日期的 00:00:00 |
| `endTime` | `NSTimeInterval` | 数据同步的结束时间（1970年以来的秒数时间戳），将自动规范化为指定日期的 23:59:59 |
| `completion` | `void (^)(NSArray<TSStressDailyModel *> *, NSError *)` | 完成回调，返回同步的每日压力模型数组或错误 |

**代码示例：**

```objc
id<TSStressInterface> stressInterface = [TopStepComKit sharedInstance].stress;

NSDate *today = [NSDate date];
NSDate *sevenDaysAgo = [today dateByAddingTimeInterval:-7 * 24 * 3600];

[stressInterface syncDailyDataFromStartTime:sevenDaysAgo.timeIntervalSince1970
                                   endTime:today.timeIntervalSince1970
                                completion:^(NSArray<TSStressDailyModel *> *dailyModels, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else {
        TSLog(@"已同步 %lu 天的每日压力数据", (unsigned long)dailyModels.count);
        for (TSStressDailyModel *daily in dailyModels) {
            TSLog(@"日期: %@, 最大压力: %d, 最小压力: %d", 
                  [NSDate dateWithTimeIntervalSince1970:daily.date],
                  daily.maxStress,
                  daily.minStress);
        }
    }
}];
```

### 同步从指定开始时间至今的每日压力数据

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSStressDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳），将自动规范化为指定日期的 00:00:00 |
| `completion` | `void (^)(NSArray<TSStressDailyModel *> *, NSError *)` | 完成回调，返回同步的每日压力模型数组或错误 |

**代码示例：**

```objc
id<TSStressInterface> stressInterface = [TopStepComKit sharedInstance].stress;

NSDate *startDate = [[NSDate date] dateByAddingTimeInterval:-30 * 24 * 3600];

[stressInterface syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                                completion:^(NSArray<TSStressDailyModel *> *dailyModels, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else {
        TSLog(@"已同步 %lu 天的每日压力数据（从 %@ 至今）", 
              (unsigned long)dailyModels.count, 
              startDate);
        
        for (TSStressDailyModel *daily in dailyModels) {
            TSLog(@"========== 日期: %@ ==========", 
                  [NSDate dateWithTimeIntervalSince1970:daily.date]);
            TSLog(@"最大压力值: %d", daily.maxStress);
            TSLog(@"最小压力值: %d", daily.minStress);
            TSLog(@"手动测量条目数: %lu", (unsigned long)daily.manualItems.count);
            TSLog(@"自动监测条目数: %lu", (unsigned long)daily.autoItems.count);
            
            NSArray *allItems = [daily allMeasuredItems];
            TSLog(@"总测量条目数: %lu", (unsigned long)allItems.count);
        }
    }
}];
```

## TSStressDailyModel 便捷方法

### 获取最大压力值

```objc
- (UInt8)maxStress;
```

**返回值：** 当天最大压力值，如果无数据返回 0

### 获取最小压力值

```objc
- (UInt8)minStress;
```

**返回值：** 当天最小压力值，如果无数据返回 0

### 获取所有测量条目

```objc
- (NSArray<TSStressValueItem *> *)allMeasuredItems;
```

**返回值：** 合并后的主动和自动测量条目数组，按时间排序

## 注意事项

1. 开始压力测量前，务必先调用 `isSupportActivityMeasureByUser` 检查设备是否支持手动测量
2. 配置自动监测前，需先调用 `isSupportAutomaticMonitoring` 检查设备是否支持该功能
3. 时间参数使用 UNIX 时间戳（1970年以来的秒数），可通过 `NSDate` 的 `timeIntervalSince1970` 属性获取
4. 日数据同步时，时间参数会自动规范化为日期边界（00:00:00 到 23:59:59），无需手动计算
5. 所有完成回调均在主线程调用，可直接进行 UI 更新
6. 数据同步过程中应检查错误对象，仅在 error 为 nil 时数据才有效
7. 原始数据和日数据同步可能耗时较长，建议在后台线程调用或显示加载提示
8. `startTime` 必须早于 `endTime`，且日数据同步的 `endTime` 不能在将来
9. 手动测量进行中调用 `stopMeasureCompletion:` 会正常中断测量，完成回调的 success 为 NO
10. 获取的日数据中，`manualItems` 和 `autoItems` 均按时间升序排列，可直接用于时间序列分析
