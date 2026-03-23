---
sidebar_position: 1
title: 数据同步
---

# 数据同步（TSDataSync）

TSDataSync 模块提供设备健康数据同步的完整解决方案，支持心率、血氧、血压、压力、睡眠、体温、心电图、运动和日常活动等多种数据类型的同步。该模块采用灵活的配置系统，支持原始数据和按天聚合数据的多粒度同步，以及自动错误处理机制。

## 前提条件

1. 设备已连接且配对成功
2. 应用已获得必要的健康数据权限
3. SDK 已初始化并完成必要的身份验证
4. 时间同步配置有效（startTime 早于 endTime）

## 数据模型

### TSDataSyncConfig（数据同步配置）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `options` | `TSDataSyncOption` | 要同步的数据类型，支持按位或操作组合多个类型 |
| `granularity` | `TSDataGranularity` | 数据颗粒度，可选值为原始数据（Raw）或每日聚合数据（Day） |
| `startTime` | `NSTimeInterval` | 同步开始时间（时间戳，秒），为 0 时自动从数据库获取上次同步时间 |
| `endTime` | `NSTimeInterval` | 同步结束时间（时间戳，秒），为 0 时默认为当前时间 |
| `includeUserInitiated` | `BOOL` | 是否包含用户主动测量的数据，默认为 YES |

### TSHealthData（健康数据）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `option` | `TSDataSyncOption` | 该健康数据的具体类型（如心率、血氧等） |
| `healthValues` | `NSArray<TSHealthValueModel *> *` | 健康数据值列表，每个元素代表一天或一个原始测量点 |
| `fetchError` | `NSError *` | 数据获取失败时的错误信息，成功时为 nil |

## 枚举与常量

### TSDataGranularity（数据颗粒度）

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `TSDataGranularityRaw` | 原始数据，包含单个测量值，数据量较大 |
| `1` | `TSDataGranularityDay` | 按天聚合的数据，数据量较小 |

### TSDataSyncOption（数据同步选项）

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `TSDataSyncOptionNone` | 无数据选项 |
| `1 << 0` | `TSDataSyncOptionHeartRate` | 心率数据 |
| `1 << 1` | `TSDataSyncOptionBloodOxygen` | 血氧数据 |
| `1 << 2` | `TSDataSyncOptionBloodPressure` | 血压数据 |
| `1 << 3` | `TSDataSyncOptionStress` | 压力水平数据 |
| `1 << 4` | `TSDataSyncOptionSleep` | 睡眠监测数据 |
| `1 << 5` | `TSDataSyncOptionTemperature` | 体温数据 |
| `1 << 6` | `TSDataSyncOptionECG` | 心电图数据 |
| `1 << 7` | `TSDataSyncOptionSport` | 运动活动数据 |
| `1 << 8` | `TSDataSyncOptionDailyActivity` | 日常活动数据 |
| 组合 | `TSDataSyncOptionAll` | 所有数据类型的组合 |

## 回调类型

| 回调签名 | 说明 |
|---------|------|
| `void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error)` | 数据同步完成回调。results 为 `TSHealthData` 数组，每个元素对应一种请求的数据类型；error 仅在致命错误时非空 |

## 接口方法

### 从上次同步时间自动同步每日数据

```objc
- (void)syncDailyDataFromLastTime:(void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error))completion;
```

**参数说明：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(NSArray<TSHealthData *> *, NSError *)` | 完成回调，返回每种数据类型的结果与可选的致命错误 |

**代码示例：**

```objc
// 获取数据同步管理器
id<TSDataSyncInterface> dataSyncManager = [TopStepComKit sharedInstance].dataSync;

// 从上次同步时间开始同步每日数据
[dataSyncManager syncDailyDataFromLastTime:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
    if (error) {
        TSLog(@"致命错误，同步无法继续: %@", error.localizedDescription);
        return;
    }
    
    // 处理同步结果
    for (TSHealthData *healthData in results) {
        if (healthData.fetchError) {
            TSLog(@"数据类型 %ld 获取失败: %@", healthData.option, healthData.fetchError.localizedDescription);
        } else {
            TSLog(@"数据类型 %ld 获取成功，共 %lu 条数据", healthData.option, healthData.healthValues.count);
        }
    }
}];
```

---

### 从上次同步时间自动同步原始数据

```objc
- (void)syncRawDataFromLastTime:(void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error))completion;
```

**参数说明：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(NSArray<TSHealthData *> *, NSError *)` | 完成回调，返回每种数据类型的结果与可选的致命错误 |

**代码示例：**

```objc
// 获取数据同步管理器
id<TSDataSyncInterface> dataSyncManager = [TopStepComKit sharedInstance].dataSync;

// 从上次同步时间开始同步原始数据
[dataSyncManager syncRawDataFromLastTime:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
    if (error) {
        TSLog(@"同步操作致命错误: %@", error.localizedDescription);
        return;
    }
    
    // 获取心率数据
    TSHealthData *heartRateData = [TSHealthData findHealthDataWithOption:TSDataSyncOptionHeartRate
                                                                fromArray:results];
    if (heartRateData && !heartRateData.fetchError) {
        TSLog(@"心率原始数据: %lu 条记录", heartRateData.healthValues.count);
        for (TSHealthValueModel *value in heartRateData.healthValues) {
            TSLog(@"心率: %ld bpm, 时间: %f", value.value, value.timestamp);
        }
    }
}];
```

---

### 使用配置同步健康数据

```objc
- (void)syncDataWithConfig:(TSDataSyncConfig *_Nonnull)config
                completion:(void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error))completion;
```

**参数说明：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSDataSyncConfig *` | 包含所有同步参数的配置对象，不能为 nil |
| `completion` | `void (^)(NSArray<TSHealthData *> *, NSError *)` | 完成回调，返回每种数据类型的结果与可选的致命错误 |

**代码示例：**

```objc
// 获取数据同步管理器
id<TSDataSyncInterface> dataSyncManager = [TopStepComKit sharedInstance].dataSync;

// 创建配置：同步过去 7 天的心率和血氧每日数据
NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
NSTimeInterval startTime = endTime - (7 * 24 * 60 * 60);

TSDataSyncConfig *config = [[TSDataSyncConfig alloc] initWithOptions:(TSDataSyncOptionHeartRate | TSDataSyncOptionBloodOxygen)
                                                            granularity:TSDataGranularityDay
                                                              startTime:startTime
                                                                endTime:endTime];

[dataSyncManager syncDataWithConfig:config
                         completion:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
    if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
        return;
    }
    
    // 处理心率数据
    TSHealthData *heartRateData = [TSHealthData findHealthDataWithOption:TSDataSyncOptionHeartRate
                                                                fromArray:results];
    if (heartRateData && !heartRateData.fetchError) {
        for (TSHealthValueModel *value in heartRateData.healthValues) {
            TSLog(@"日期: %f, 心率: %ld bpm", value.timestamp, value.value);
        }
    }
    
    // 处理血氧数据
    TSHealthData *spO2Data = [TSHealthData findHealthDataWithOption:TSDataSyncOptionBloodOxygen
                                                            fromArray:results];
    if (spO2Data && !spO2Data.fetchError) {
        TSLog(@"血氧数据: %lu 天", spO2Data.healthValues.count);
    }
}];
```

**便捷方法示例：**

```objc
// 方法 1: 创建原始数据同步配置
NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
NSTimeInterval startTime = endTime - (24 * 60 * 60);  // 过去 24 小时
TSDataSyncConfig *rawConfig = [TSDataSyncConfig configForRawDataWithOptions:TSDataSyncOptionHeartRate
                                                                   startTime:startTime
                                                                     endTime:endTime];

// 方法 2: 创建每日数据同步配置
TSDataSyncConfig *dailyConfig = [TSDataSyncConfig configForDailyDataWithOptions:(TSDataSyncOptionHeartRate | TSDataSyncOptionBloodOxygen)
                                                                       startTime:startTime
                                                                         endTime:endTime];

// 方法 3: 创建从指定时间到当前时间的同步配置
TSDataSyncConfig *configFromTime = [TSDataSyncConfig configWithOptions:TSDataSyncOptionAll
                                                             granularity:TSDataGranularityDay
                                                               startTime:startTime];
```

---

### 检查数据同步状态

```objc
- (BOOL)isSyncing;
```

**返回值说明：**

| 返回值 | 说明 |
|--------|------|
| `YES` | 数据同步正在进行中 |
| `NO` | 数据同步未进行或已完成 |

**代码示例：**

```objc
// 获取数据同步管理器
id<TSDataSyncInterface> dataSyncManager = [TopStepComKit sharedInstance].dataSync;

// 检查同步状态
if ([dataSyncManager isSyncing]) {
    TSLog(@"正在同步数据，请勿重复操作");
} else {
    TSLog(@"没有正在进行的同步操作，可以开始新的同步");
    
    // 创建配置并开始同步
    TSDataSyncConfig *config = [[TSDataSyncConfig alloc] init];
    [dataSyncManager syncDataWithConfig:config
                             completion:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
        if (!error) {
            TSLog(@"同步完成");
        }
    }];
}
```

---

## 注意事项

1. **线程安全** - 所有完成回调均在主线程执行，UI 操作应直接在回调中进行，无需额外的线程切换

2. **防止重复同步** - 调用同步方法前应检查 `isSyncing` 方法确认无同步操作进行中，避免多个同步操作同时进行

3. **配置验证** - `TSDataSyncConfig` 会在同步前自动验证，配置无效会通过 completion 的 error 参数返回

4. **错误处理** - completion 的 error 仅在无法继续的致命错误时非空；单个数据类型的错误通过 `TSHealthData.fetchError` 返回

5. **时间范围** - startTime 和 endTime 均为时间戳格式（秒）；startTime 必须早于 endTime；若 startTime 为 0，SDK 自动从数据库获取上次同步时间

6. **数据颗粒度** - 原始数据（Raw）包含单个测量值，数据量较大；每日数据（Day）为聚合数据，数据量较小

7. **数据类型组合** - 支持使用按位或（|）操作组合多个数据类型进行批量同步，如 `TSDataSyncOptionHeartRate | TSDataSyncOptionBloodOxygen`

8. **内存管理** - 大量原始数据同步可能占用较大内存，建议按时间段分批同步

9. **用户主动测量** - `includeUserInitiated` 属性控制是否包含用户手动测量的数据，不影响自动监测数据

10. **同步时间** - 从上次同步时间开始的自动同步方法会检查数据库记录，若未找到上次同步时间，SDK 可能使用默认时间（如 7 天前）或返回错误
