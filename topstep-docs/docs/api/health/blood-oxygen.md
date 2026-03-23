---
sidebar_position: 4
title: 血氧 (TSBloodOxygen)
---

# 血氧 (TSBloodOxygen)

血氧模块提供了血氧测量、自动监测和历史数据同步的完整功能。血氧饱和度（SpO2）是一个重要的生命体征，表示氧气从肺部输送到身体其他部位的效率。通过本模块，您可以进行手动测量、配置自动监测以及同步历史数据。

## 前提条件

1. 设备已配对连接并蓝牙处于可用状态
2. 设备硬件支持血氧测量功能
3. 已完成 SDK 初始化

## 数据模型

### TSBOValueItem（血氧测量条目）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `oxyValue` | `UInt8` | 血氧值，以百分比为单位测量 |
| `isUserInitiated` | `BOOL` | 指示测量是否为用户主动发起 |
| `timestamp` | `NSTimeInterval` | 测量时间戳（继承自 `TSHealthValueItem`） |

**类方法：**

| 方法 | 说明 |
|------|------|
| `+ (NSArray<TSBOValueItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts` | 将数据库字典数组转换为 `TSBOValueItem` 数组 |
| `+ (TSBOValueItem *)valueItemFromDBDict:(NSDictionary *)dict` | 将数据库字典转换为单个 `TSBOValueItem` |

### TSBODailyModel（每日血氧数据）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `maxOxygenItem` | `TSBOValueItem *` | 当天最大血氧条目，包含测量值、时间戳等信息 |
| `minOxygenItem` | `TSBOValueItem *` | 当天最小血氧条目，包含测量值、时间戳等信息 |
| `autoItems` | `NSArray<TSBOValueItem *>` | 设备自动监测的血氧数组，按时间升序排列 |

**实例方法：**

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `- (UInt8)maxOxygenValue` | `UInt8` | 获取当天最大血氧值（%），若 `maxOxygenItem` 为空返回 0 |
| `- (UInt8)minOxygenValue` | `UInt8` | 获取当天最小血氧值（%），若 `minOxygenItem` 为空返回 0 |
| `- (NSArray<TSBOValueItem *> *)allMeasuredItems` | `NSArray<TSBOValueItem *>` | 获取所有测量条目（主动 + 自动），按时间排序 |

## 枚举与常量

无特定枚举或常量定义。血氧值为 `UInt8` 类型（0-100%），时间戳为 `NSTimeInterval` 类型（Unix 时间戳，单位：秒）。

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `void (^)(BOOL success, NSError * _Nullable error)` | 测量开始/结束回调，返回成功状态和错误信息 |
| `void (^)(TSBOValueItem * _Nullable data, NSError * _Nullable error)` | 实时数据回调，返回实时血氧测量数据或错误 |
| `TSCompletionBlock` | 通用完成回调，返回成功状态和错误信息 |
| `void (^)(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error)` | 自动监测配置回调，返回配置对象或错误 |
| `void (^)(NSArray<TSBOValueItem *> * _Nullable boItems, NSError * _Nullable error)` | 原始数据同步回调，返回血氧条目数组或错误 |
| `void (^)(NSArray<TSBODailyModel *> * _Nullable dailyModels, NSError * _Nullable error)` | 每日数据同步回调，返回每日血氧模型数组或错误 |

## 接口方法

### 检查设备是否支持手动血氧测量

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**说明：** 检查设备是否支持用户手动发起的血氧测量功能。

**返回值：** 若设备支持返回 `YES`，否则返回 `NO`

**代码示例：**

```objc
id<TSBloodOxygenInterface> boInterface = [TopStepComKit sharedInstance].bloodOxygen;
BOOL isSupported = [boInterface isSupportActivityMeasureByUser];
if (isSupported) {
    TSLog(@"设备支持手动血氧测量");
} else {
    TSLog(@"设备不支持手动血氧测量");
}
```

---

### 启动血氧测量

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSBOValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `measureParam` | `TSActivityMeasureParam *` | 测量活动的参数配置 |
| `startHandler` | `void (^)(BOOL success, NSError *)` | 测量开始或失败时的回调。`success` 表示是否成功开始，`error` 为失败时的错误信息 |
| `dataHandler` | `void (^)(TSBOValueItem *, NSError *)` | 接收实时测量数据的回调。`data` 为实时血氧数据，`error` 为数据接收失败时的错误 |
| `endHandler` | `void (^)(BOOL success, NSError *)` | 测量结束时的回调。`success` 为 `YES` 表示正常结束，为 `NO` 表示被中断，`error` 为异常结束的错误信息 |

**代码示例：**

```objc
id<TSBloodOxygenInterface> boInterface = [TopStepComKit sharedInstance].bloodOxygen;

TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];

[boInterface startMeasureWithParam:param
                      startHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"血氧测量已启动");
    } else {
        TSLog(@"启动血氧测量失败: %@", error.localizedDescription);
    }
} dataHandler:^(TSBOValueItem * _Nullable data, NSError * _Nullable error) {
    if (data) {
        TSLog(@"实时血氧值: %d%%", data.oxyValue);
    } else {
        TSLog(@"接收数据失败: %@", error.localizedDescription);
    }
} endHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"血氧测量正常结束");
    } else {
        TSLog(@"血氧测量异常结束: %@", error.localizedDescription);
    }
}];
```

---

### 停止血氧测量

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSCompletionBlock` | 测量停止时的完成回调 |

**代码示例：**

```objc
id<TSBloodOxygenInterface> boInterface = [TopStepComKit sharedInstance].bloodOxygen;

[boInterface stopMeasureCompletion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"血氧测量已停止");
    } else {
        TSLog(@"停止血氧测量失败: %@", error.localizedDescription);
    }
}];
```

---

### 检查设备是否支持自动血氧监测

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**说明：** 检查当前连接的设备是否支持自动血氧监测功能。

**返回值：** 若设备支持返回 `YES`，否则返回 `NO`

**代码示例：**

```objc
id<TSBloodOxygenInterface> boInterface = [device getInterface:@protocol(TSBloodOxygenInterface)];

BOOL isSupported = [boInterface isSupportAutomaticMonitoring];
if (isSupported) {
    TSLog(@"设备支持自动血氧监测");
} else {
    TSLog(@"设备不支持自动血氧监测");
}
```

---

### 配置自动血氧监测

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `configuration` | `TSAutoMonitorConfigs *` | 自动血氧监测的配置参数 |
| `completion` | `TSCompletionBlock` | 配置设置成功或失败时的完成回调 |

**代码示例：**

```objc
id<TSBloodOxygenInterface> boInterface = [device getInterface:@protocol(TSBloodOxygenInterface)];

TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];
config.enabled = YES;
// 根据实际需求配置其他参数

[boInterface pushAutoMonitorConfigs:config completion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"自动血氧监测配置已设置");
    } else {
        TSLog(@"设置自动血氧监测配置失败: %@", error.localizedDescription);
    }
}];
```

---

### 获取当前自动血氧监测配置

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | 完成回调，返回当前配置或错误信息 |

**代码示例：**

```objc
id<TSBloodOxygenInterface> boInterface = [device getInterface:@protocol(TSBloodOxygenInterface)];

[boInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
    if (configuration) {
        TSLog(@"已获取自动血氧监测配置");
        // 使用 configuration 对象
    } else {
        TSLog(@"获取自动血氧监测配置失败: %@", error.localizedDescription);
    }
}];
```

---

### 同步指定时间范围内的原始血氧数据

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSBOValueItem *> *_Nullable boItems, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（Unix 时间戳，单位：秒） |
| `endTime` | `NSTimeInterval` | 数据同步的结束时间（Unix 时间戳，单位：秒） |
| `completion` | `void (^)(NSArray<TSBOValueItem *> *, NSError *)` | 完成回调，返回同步的原始血氧测量条目或错误 |

**代码示例：**

```objc
id<TSBloodOxygenInterface> boInterface = [device getInterface:@protocol(TSBloodOxygenInterface)];

NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
NSTimeInterval sevenDaysAgo = now - 7 * 24 * 3600;

[boInterface syncRawDataFromStartTime:sevenDaysAgo
                              endTime:now
                           completion:^(NSArray<TSBOValueItem *> * _Nullable boItems, NSError * _Nullable error) {
    if (boItems) {
        TSLog(@"同步到 %ld 条原始血氧数据", (long)boItems.count);
        for (TSBOValueItem *item in boItems) {
            TSLog(@"血氧值: %d%%, 时间戳: %.0f, 用户主动: %@", 
                  item.oxyValue, item.timestamp, item.isUserInitiated ? @"YES" : @"NO");
        }
    } else {
        TSLog(@"同步原始血氧数据失败: %@", error.localizedDescription);
    }
}];
```

---

### 从指定开始时间同步至今的原始血氧数据

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSBOValueItem *> *_Nullable boItems, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（Unix 时间戳，单位：秒） |
| `completion` | `void (^)(NSArray<TSBOValueItem *> *, NSError *)` | 完成回调，返回同步的原始血氧测量条目或错误 |

**代码示例：**

```objc
id<TSBloodOxygenInterface> boInterface = [device getInterface:@protocol(TSBloodOxygenInterface)];

NSTimeInterval sevenDaysAgo = [[NSDate date] timeIntervalSince1970] - 7 * 24 * 3600;

[boInterface syncRawDataFromStartTime:sevenDaysAgo
                           completion:^(NSArray<TSBOValueItem *> * _Nullable boItems, NSError * _Nullable error) {
    if (boItems) {
        TSLog(@"同步到 %ld 条原始血氧数据（从7天前至今）", (long)boItems.count);
    } else {
        TSLog(@"同步原始血氧数据失败: %@", error.localizedDescription);
    }
}];
```

---

### 同步指定时间范围内的每日血氧数据

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSBODailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（Unix 时间戳，单位：秒）。将自动规范化为指定日期的 00:00:00 |
| `endTime` | `NSTimeInterval` | 数据同步的结束时间（Unix 时间戳，单位：秒）。将自动规范化为指定日期的 23:59:59 |
| `completion` | `void (^)(NSArray<TSBODailyModel *> *, NSError *)` | 完成回调，返回同步的每日血氧模型数组或错误 |

**代码示例：**

```objc
id<TSBloodOxygenInterface> boInterface = [device getInterface:@protocol(TSBloodOxygenInterface)];

NSDate *now = [NSDate date];
NSDate *sevenDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-7 * 24 * 3600];

[boInterface syncDailyDataFromStartTime:[sevenDaysAgo timeIntervalSince1970]
                               endTime:[now timeIntervalSince1970]
                            completion:^(NSArray<TSBODailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (dailyModels) {
        TSLog(@"同步到 %ld 天的每日血氧数据", (long)dailyModels.count);
        for (TSBODailyModel *dailyModel in dailyModels) {
            TSLog(@"日期: %.0f, 最大值: %d%%, 最小值: %d%%, 自动监测: %ld 次",
                  dailyModel.timestamp,
                  [dailyModel maxOxygenValue],
                  [dailyModel minOxygenValue],
                  (long)dailyModel.autoItems.count);
        }
    } else {
        TSLog(@"同步每日血氧数据失败: %@", error.localizedDescription);
    }
}];
```

---

### 从指定开始时间同步至今的每日血氧数据

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSBODailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（Unix 时间戳，单位：秒）。将自动规范化为指定日期的 00:00:00 |
| `completion` | `void (^)(NSArray<TSBODailyModel *> *, NSError *)` | 完成回调，返回同步的每日血氧模型数组或错误 |

**代码示例：**

```objc
id<TSBloodOxygenInterface> boInterface = [device getInterface:@protocol(TSBloodOxygenInterface)];

NSDate *sevenDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-7 * 24 * 3600];

[boInterface syncDailyDataFromStartTime:[sevenDaysAgo timeIntervalSince1970]
                             completion:^(NSArray<TSBODailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (dailyModels) {
        TSLog(@"同步到 %ld 天的每日血氧数据（从7天前至今）", (long)dailyModels.count);
        for (TSBODailyModel *dailyModel in dailyModels) {
            NSArray<TSBOValueItem *> *allItems = [dailyModel allMeasuredItems];
            TSLog(@"日期: %.0f, 总测量次数: %ld", dailyModel.timestamp, (long)allItems.count);
        }
    } else {
        TSLog(@"同步每日血氧数据失败: %@", error.localizedDescription);
    }
}];
```

---

## 注意事项

1. **时间戳格式：** 所有时间参数均为 Unix 时间戳（自 1970 年 1 月 1 日 00:00:00 UTC 以来的秒数），可通过 `[[NSDate date] timeIntervalSince1970]` 获取当前时间戳。

2. **时间范围自动规范化：** 调用 `syncDailyDataFromStartTime:endTime:completion:` 时，开始时间会自动规范化为指定日期的 00:00:00，结束时间会自动规范化为指定日期的 23:59:59。

3. **血氧值范围：** 血氧值为 `UInt8` 类型，范围为 0-100%，代表血氧饱和度百分比。

4. **完成回调线程：** 完成回调（completion handler）在主线程中调用，可安全地更新 UI。

5. **设备支持性检查：** 在进行配置前，务必使用 `isSupportAutomaticMonitoring` 检查设备是否支持相应功能。

6. **错误处理：** 所有异步操作均应检查返回的 `NSError` 对象，并根据错误代码进行相应处理。

7. **自动监测配置持久化：** 通过 `pushAutoMonitorConfigs:completion:` 设置的配置会下发至设备并持久化，设备重启后配置保持不变。