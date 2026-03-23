---
sidebar_position: 2
title: 心率（Heart Rate）
---

# 心率 (TSHeartRate)

TSHeartRate 模块提供完整的心率测量、监测、数据同步功能，包括实时心率测量、自动监测、历史数据获取和静息心率分析等能力。

## 前提条件

1. 设备已通过蓝牙连接并配对成功
2. 设备具备心率测量硬件能力
3. 用户已获得必要的健康数据访问权限
4. 对应的协议实现已在连接设备上可用

## 数据模型

### TSHRValueItem

心率测量数据项。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `hrValue` | `UInt8` | 心率值，单位为每分钟心跳次数（BPM） |
| `isUserInitiated` | `BOOL` | 测量是否为用户主动发起 |
| `timestamp` | `NSTimeInterval` | 测量时间戳（继承自TSHealthValueItem） |

### TSHRDailyModel

每日聚合心率数据模型。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `maxHRItem` | `TSHRValueItem *` | 当天最大心率条目 |
| `minHRItem` | `TSHRValueItem *` | 当天最小心率条目 |
| `restingItems` | `NSArray<TSHRValueItem *>` | 静息心率条目数组，按时间升序排列 |
| `autoItems` | `NSArray<TSHRValueItem *>` | 自动监测心率条目数组，按时间升序排列 |

## 枚举与常量

无

## 回调类型

| 回调名 | 签名 | 说明 |
|--------|------|------|
| 测量启动回调 | `void (^)(BOOL success, NSError *)` | 心率测量开始时触发，success表示是否成功启动 |
| 实时数据回调 | `void (^)(TSHRValueItem *, NSError *)` | 接收实时心率测量数据，每次测量时触发 |
| 测量结束回调 | `void (^)(BOOL success, NSError *)` | 测量结束时触发，success表示是否正常结束 |
| 完成回调 | `void (^)(NSError *)` | 操作完成或失败时触发 |
| 配置查询回调 | `void (^)(TSAutoMonitorHRConfigs *, NSError *)` | 返回自动监测配置信息 |
| 原始数据回调 | `void (^)(NSArray<TSHRValueItem *> *, NSError *)` | 返回同步的原始心率数据数组 |
| 每日数据回调 | `void (^)(NSArray<TSHRDailyModel *> *, NSError *)` | 返回同步的每日心率数据数组 |
| 单日数据回调 | `void (^)(TSHRValueItem *, NSError *)` | 返回单日数据（如今日静息心率） |

## 接口方法

### 检查设备是否支持心率预警监测

```objc
- (BOOL)isSupportHeartRateAlert;
```

**说明**

检查连接的设备是否具备心率预警监测功能，允许设备在用户心率超出正常范围或达到潜在危险水平时通知用户。

**返回值**

| 返回值 | 类型 | 说明 |
|--------|------|------|
| result | `BOOL` | `YES`表示支持心率预警，`NO`表示不支持 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];
if ([hrInterface isSupportHeartRateAlert]) {
    TSLog(@"设备支持心率预警监测");
} else {
    TSLog(@"设备不支持心率预警监测");
}
```

---

### 检查设备是否支持加强心率监测

```objc
- (BOOL)isSupportEnhancedMonitoring;
```

**说明**

检查设备是否支持加强心率监测。加强监测提供更频繁和准确的心率测量，具有更高精度和更快响应时间，但消耗更多电池。

**返回值**

| 返回值 | 类型 | 说明 |
|--------|------|------|
| result | `BOOL` | `YES`表示支持加强监测，`NO`表示不支持 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];
if ([hrInterface isSupportEnhancedMonitoring]) {
    TSLog(@"设备支持加强心率监测");
}
```

---

### 检查设备是否支持手动心率测量

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**说明**

检查设备是否支持用户手动发起的心率测量功能。

**返回值**

| 返回值 | 类型 | 说明 |
|--------|------|------|
| result | `BOOL` | `YES` 表示支持手动心率测量，`NO` 表示不支持 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [TopStepComKit sharedInstance].heartRate;
if ([hrInterface isSupportActivityMeasureByUser]) {
    TSLog(@"设备支持手动心率测量");
}
```

---

### 开始心率测量

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSHRValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

**说明**

使用指定参数开始心率测量，提供测量启动、实时数据和测量结束的三个回调处理。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `measureParam` | `TSActivityMeasureParam *` | 测量活动的配置参数 |
| `startHandler` | `void (^)(BOOL, NSError *)` | 测量启动回调，success 表示是否成功启动，error 为失败时的错误信息 |
| `dataHandler` | `void (^)(TSHRValueItem *, NSError *)` | 实时数据回调，data 为实时心率测量数据，error 为数据接收失败时的错误 |
| `endHandler` | `void (^)(BOOL, NSError *)` | 测量结束回调，success 表示是否正常结束，error 为异常结束时的错误信息 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [TopStepComKit sharedInstance].heartRate;

TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.duration = 60; // 测量持续时间60秒

[hrInterface startMeasureWithParam:param
                      startHandler:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"心率测量已启动");
    } else {
        TSLog(@"启动失败: %@", error.localizedDescription);
    }
} dataHandler:^(TSHRValueItem *data, NSError *error) {
    if (data) {
        TSLog(@"实时心率: %d BPM", data.hrValue);
    }
} endHandler:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"心率测量已完成");
    } else {
        TSLog(@"测量异常终止: %@", error.localizedDescription);
    }
}];
```

---

### 停止心率测量

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

**说明**

停止正在进行的心率测量。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSCompletionBlock` | 停止完成回调，error 为失败时的错误信息 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [TopStepComKit sharedInstance].heartRate;

[hrInterface stopMeasureCompletion:^(NSError *error) {
    if (error) {
        TSLog(@"停止测量失败: %@", error.localizedDescription);
    } else {
        TSLog(@"心率测量已停止");
    }
}];
```

---

### 检查设备是否支持自动心率监测

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**说明**

检查设备是否支持自动心率监测功能。

**返回值**

| 返回值 | 类型 | 说明 |
|--------|------|------|
| result | `BOOL` | `YES`表示支持自动监测，`NO`表示不支持 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];
if ([hrInterface isSupportAutomaticMonitoring]) {
    TSLog(@"设备支持自动心率监测");
}
```

---

### 配置自动心率监测

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorHRConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

**说明**

将自动心率监测配置推送到设备。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `configuration` | `TSAutoMonitorHRConfigs *` | 自动监测的配置参数 |
| `completion` | `TSCompletionBlock` | 完成回调，error为失败时的错误信息 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];

TSAutoMonitorHRConfigs *config = [[TSAutoMonitorHRConfigs alloc] init];
config.enableAutomaticMonitoring = YES;
// 配置其他参数...

[hrInterface pushAutoMonitorConfigs:config completion:^(NSError *error) {
    if (error) {
        TSLog(@"配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"自动监测配置已更新");
    }
}];
```

---

### 获取自动心率监测配置

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorHRConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

**说明**

从设备获取当前的自动心率监测配置。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorHRConfigs *, NSError *)` | 完成回调，configuration为当前配置，error为失败时的错误信息 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];

[hrInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorHRConfigs *configuration, NSError *error) {
    if (error) {
        TSLog(@"获取配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"当前自动监测配置已获取");
        // 使用 configuration 对象...
    }
}];
```

---

### 同步原始心率数据（指定时间范围）

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable hrItems, NSError *_Nullable error))completion;
```

**说明**

同步指定时间范围内的原始心率测量数据。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 开始时间戳（秒，1970年以来） |
| `endTime` | `NSTimeInterval` | 结束时间戳（秒，1970年以来） |
| `completion` | `void (^)(NSArray<TSHRValueItem *> *, NSError *)` | 完成回调，hrItems为同步的心率数据数组 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-86400]; // 过去24小时
NSDate *endDate = [NSDate date]; // 现在

[hrInterface syncRawDataFromStartTime:startDate.timeIntervalSince1970
                              endTime:endDate.timeIntervalSince1970
                           completion:^(NSArray<TSHRValueItem *> *hrItems, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else {
        TSLog(@"同步了 %lu 条心率数据", (unsigned long)hrItems.count);
        for (TSHRValueItem *item in hrItems) {
            TSLog(@"时间: %@, 心率: %d BPM", 
                  [NSDate dateWithTimeIntervalSince1970:item.timestamp], 
                  item.hrValue);
        }
    }
}];
```

---

### 同步原始心率数据（从开始时间至今）

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable hrItems, NSError *_Nullable error))completion;
```

**说明**

同步从指定开始时间到现在的原始心率测量数据。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 开始时间戳（秒，1970年以来） |
| `completion` | `void (^)(NSArray<TSHRValueItem *> *, NSError *)` | 完成回调，hrItems为同步的心率数据数组 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-604800]; // 过去7天
[hrInterface syncRawDataFromStartTime:startDate.timeIntervalSince1970
                           completion:^(NSArray<TSHRValueItem *> *hrItems, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else {
        TSLog(@"同步了 %lu 条心率数据", (unsigned long)hrItems.count);
    }
}];
```

---

### 同步每日心率数据（指定时间范围）

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSHRDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**说明**

同步指定时间范围内的每日聚合心率数据。时间参数将自动规范化为日期边界（00:00:00 到 23:59:59），数据按时间升序返回。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 开始时间戳（秒，1970年以来），将规范化为该日00:00:00 |
| `endTime` | `NSTimeInterval` | 结束时间戳（秒，1970年以来），将规范化为该日23:59:59，不能为将来时间 |
| `completion` | `void (^)(NSArray<TSHRDailyModel *> *, NSError *)` | 完成回调，每个TSHRDailyModel代表一天的数据 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-2592000]; // 过去30天
NSDate *endDate = [NSDate date];

[hrInterface syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                                endTime:endDate.timeIntervalSince1970
                             completion:^(NSArray<TSHRDailyModel *> *dailyModels, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else {
        TSLog(@"同步了 %lu 天的数据", (unsigned long)dailyModels.count);
        for (TSHRDailyModel *model in dailyModels) {
            TSLog(@"日期: %@, 最大HR: %d, 最小HR: %d, 自动监测: %lu",
                  [NSDate dateWithTimeIntervalSince1970:model.timestamp],
                  model.maxBPM,
                  model.minBPM,
                  (unsigned long)model.autoItems.count);
        }
    }
}];
```

---

### 同步每日心率数据（从开始时间至今）

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSHRDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**说明**

同步从指定开始时间到现在的每日聚合心率数据。开始时间将自动规范化为该日00:00:00，数据按时间升序返回。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 开始时间戳（秒，1970年以来），将规范化为该日00:00:00 |
| `completion` | `void (^)(NSArray<TSHRDailyModel *> *, NSError *)` | 完成回调，每个TSHRDailyModel代表一天的数据 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-604800]; // 过去7天
[hrInterface syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                             completion:^(NSArray<TSHRDailyModel *> *dailyModels, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else {
        TSLog(@"同步了 %lu 天的数据", (unsigned long)dailyModels.count);
    }
}];
```

---

### 检查设备是否支持静息心率监测

```objc
- (BOOL)isSupportRestingHeartRate;
```

**说明**

检查设备是否支持静息心率监测。静息心率是在完全休息期间（通常在睡眠期间）测量的，是心血管健康和健身水平的重要指标。

**返回值**

| 返回值 | 类型 | 说明 |
|--------|------|------|
| result | `BOOL` | `YES`表示支持静息心率，`NO`表示不支持 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];
if ([hrInterface isSupportRestingHeartRate]) {
    TSLog(@"设备支持静息心率监测");
}
```

---

### 同步原始静息心率数据（指定时间范围）

```objc
- (void)syncRawRestingHeartRateDataFromStartTime:(NSTimeInterval)startTime
                                         endTime:(NSTimeInterval)endTime
                                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable restingHRItems, NSError *_Nullable error))completion;
```

**说明**

同步指定时间范围内的原始静息心率测量数据。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 开始时间戳（秒，1970年以来） |
| `endTime` | `NSTimeInterval` | 结束时间戳（秒，1970年以来） |
| `completion` | `void (^)(NSArray<TSHRValueItem *> *, NSError *)` | 完成回调，restingHRItems为同步的静息心率数据 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-2592000]; // 过去30天
NSDate *endDate = [NSDate date];

[hrInterface syncRawRestingHeartRateDataFromStartTime:startDate.timeIntervalSince1970
                                              endTime:endDate.timeIntervalSince1970
                                           completion:^(NSArray<TSHRValueItem *> *restingHRItems, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else {
        TSLog(@"同步了 %lu 条静息心率数据", (unsigned long)restingHRItems.count);
        for (TSHRValueItem *item in restingHRItems) {
            TSLog(@"时间: %@, 静息心率: %d BPM", 
                  [NSDate dateWithTimeIntervalSince1970:item.timestamp], 
                  item.hrValue);
        }
    }
}];
```

---

### 同步原始静息心率数据（从开始时间至今）

```objc
- (void)syncRawRestingHeartRateDataFromStartTime:(NSTimeInterval)startTime
                                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable restingHRItems, NSError *_Nullable error))completion;
```

**说明**

同步从指定开始时间到现在的原始静息心率测量数据。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 开始时间戳（秒，1970年以来） |
| `completion` | `void (^)(NSArray<TSHRValueItem *> *, NSError *)` | 完成回调，restingHRItems为同步的静息心率数据 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];

NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-604800]; // 过去7天
[hrInterface syncRawRestingHeartRateDataFromStartTime:startDate.timeIntervalSince1970
                                           completion:^(NSArray<TSHRValueItem *> *restingHRItems, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else {
        TSLog(@"同步了 %lu 条静息心率数据", (unsigned long)restingHRItems.count);
    }
}];
```

---

### 同步今天的静息心率数据

```objc
- (void)syncTodayRestingHeartRateDataWithCompletion:(nonnull void (^)(TSHRValueItem *_Nullable todayRestingHR, NSError *_Nullable error))completion;
```

**说明**

同步当天的静息心率数据，包括今天记录的所有静息心率测量值。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSHRValueItem *, NSError *)` | 完成回调，todayRestingHR为今天的静息心率数据 |

**代码示例**

```objc
id<TSHeartRateInterface> hrInterface = [peripheralManager getInterface:TSHeartRateInterface];

[hrInterface syncTodayRestingHeartRateDataWithCompletion:^(TSHRValueItem *todayRestingHR, NSError *error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    } else if (todayRestingHR) {
        TSLog(@"今天的静息心率: %d BPM", todayRestingHR.hrValue);
    } else {
        TSLog(@"今天暂无静息心率数据");
    }
}];
```

---

## 注意事项

1. **时间戳格式**：所有时间参数均为 `NSTimeInterval` 类型，表示自 1970 年 1 月 1 日 00:00:00 UTC 以来的秒数。可使用 `NSDate` 的 `timeIntervalSince1970` 属性进行转换。

2. **时间范围验证**：同步数据时，`startTime` 必须小于 `endTime`，`endTime` 不能设置为未来时间，否则请求可能被拒绝。

3. **日期自动规范化**：调用 `syncDailyDataFromStartTime:endTime:completion:` 时，开始时间会自动调整为该日的 00:00:00，结束时间会自动调整为该日的 23:59:59。

4. **回调线程**：完成回调均在主线程中调用，可安全更新 UI。

5. **设备兼容性检查**：在使用特定功能前，应通过对应的支持检查方法（如 `isSupportEnhancedMonitoring`）验证设备能力。

6. **数据排序**：所有返回的数据数组均按时间升序排列，便于时序分析。

7. **静息心率定义**：静息心率通常在睡眠或完全放松状态下测量，自动监测配置应合理设定静息检测参数以获得准确数据。

8. **自动监测配置**：推送新配置后，设备上次同步的旧配置会被覆盖；获取配置前应确保设备已连接，否则返回的可能是缓存的上次配置。

9. **错误处理**：所有回调中的 `error` 参数为非空时，应检查 `error.code` 和 `error.localizedDescription` 了解具体失败原因，不应对 `nil` 的 data 字段进行操作。