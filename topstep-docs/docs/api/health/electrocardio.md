---
sidebar_position: 8
title: 心电
---

# 心电 (TSElectrocardio)

心电（ECG/EKG）模块提供心电图测量、自动监测和历史数据同步的功能。通过该模块，可以检测心脏异常、心律不齐和评估整体心脏健康状况。

## 前提条件

- 设备支持心电功能
- 已建立与设备的连接
- 获得必要的权限和授权

## 数据模型

### TSECGValueItem（心电值项）

心电图数据模型，代表单次心电图测量记录。

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `waveformData` | `NSArray<NSNumber *> *` | 原始心电图波形数据点的数组。这些值表示以毫伏(mV)为单位测量的电位 |
| `samplingRate` | `NSInteger` | 心电图记录的采样率(Hz)，消费级设备通常为125Hz、250Hz或500Hz |
| `heartRate` | `NSInteger` | 从心电图计算的心率，单位为每分钟心跳次数(BPM) |
| `hrvMetrics` | `NSDictionary<NSString *, NSNumber *> *` | 心率变异性指标的字典，包含SDNN、RMSSD、pNN50等各种HRV指标 |
| `recordingDuration` | `NSTimeInterval` | 心电图记录的持续时间(秒) |
| `rhythmClassification` | `NSString *` | 心电图节律的分类，例如"正常窦性心律"、"心房颤动"等 |
| `classificationConfidence` | `CGFloat` | 节律分类的置信度(0.0到1.0) |
| `qtInterval` | `NSInteger` | QT间隔，单位为毫秒。表示从Q波开始到T波结束的时间 |
| `qtcInterval` | `NSInteger` | 校正QT间隔(QTc)，单位为毫秒。针对心率校正的QT间隔 |
| `prInterval` | `NSInteger` | PR间隔，单位为毫秒。从P波开始到QRS波群开始的时间 |
| `qrsDuration` | `NSInteger` | QRS持续时间，单位为毫秒。表示心室去极化的时间 |
| `stDeviation` | `CGFloat` | ST段抬高/压低，单位为毫米。正值表示抬高，负值表示压低 |
| `notes` | `NSString *` | 关于心电图的附加说明或观察 |
| `isReviewed` | `BOOL` | 标志，表示记录是否已由医疗专业人员审查 |
| `isUserInitiated` | `BOOL` | 指示测量是否为用户主动发起 |

### TSECGDailyModel（每日心电数据模型）

每日心电数据的聚合模型，代表一天的心电图数据集合。继承自 `TSHealthDailyModel`。

## 枚举与常量

无枚举和常量定义。

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `void (^)(BOOL success, NSError * _Nullable error)` | 测量开始/停止回调。success: 操作是否成功；error: 失败时的错误信息 |
| `void (^)(TSECGValueItem * _Nullable data, NSError * _Nullable error)` | 实时数据回调。data: 实时心电图测量数据；error: 接收失败时的错误信息 |
| `void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error)` | 配置获取回调。configuration: 当前配置；error: 获取失败时的错误信息 |
| `void (^)(NSArray<TSECGValueItem *> *_Nullable ecgItems, NSError *_Nullable error)` | 原始数据同步回调。ecgItems: 同步的原始心电图条目数组；error: 同步失败时的错误信息 |
| `void (^)(NSArray<TSECGDailyModel *> *_Nullable dailyModels, NSError *_Nullable error)` | 每日数据同步回调。dailyModels: 同步的每日数据模型数组；error: 同步失败时的错误信息 |

## 接口方法

### 检查设备是否支持手动心电图测量

检查设备是否具备手动心电图测量功能。

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**返回值**

| 返回值 | 说明 |
|-------|------|
| `BOOL` | 如果设备支持手动心电图测量返回`YES`，否则返回`NO` |

**代码示例**

```objc
id<TSElectrocardioInterface> ecgInterface = [TopStepComKit sharedInstance].electrocardio;
if ([ecgInterface isSupportActivityMeasureByUser]) {
    TSLog(@"设备支持手动心电图测量");
} else {
    TSLog(@"设备不支持手动心电图测量");
}
```

### 开始心电图测量

使用指定参数开始心电图测量，并通过回调接收实时数据和测量状态。

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSECGValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `measureParam` | `TSActivityMeasureParam *` | 测量活动的参数 |
| `startHandler` | `void (^)(BOOL, NSError *)` | 测量开始或失败时调用。success: 测量是否成功开始；error: 失败时的错误信息 |
| `dataHandler` | `void (^)(TSECGValueItem *, NSError *)` | 接收实时测量数据时调用。data: 实时心电图数据；error: 数据接收失败时的错误信息 |
| `endHandler` | `void (^)(BOOL, NSError *)` | 测量结束时调用。success: 是否正常结束(YES)或被中断(NO)；error: 异常结束时的错误信息 |

**代码示例**

```objc
id<TSElectrocardioInterface> ecgInterface = [TopStepComKit sharedInstance].electrocardio;
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];

[ecgInterface startMeasureWithParam:param
                       startHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"心电测量已开始");
    } else {
        TSLog(@"心电测量启动失败: %@", error.localizedDescription);
    }
} dataHandler:^(TSECGValueItem * _Nullable data, NSError * _Nullable error) {
    if (data) {
        TSLog(@"实时心率: %ld BPM", (long)data.heartRate);
    } else {
        TSLog(@"接收数据失败: %@", error.localizedDescription);
    }
} endHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"心电测量正常结束");
    } else {
        TSLog(@"心电测量异常结束: %@", error.localizedDescription);
    }
}];
```

### 停止心电图测量

停止正在进行的心电图测量。

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSCompletionBlock` | 测量停止或无法停止时调用的完成回调 |

**代码示例**

```objc
id<TSElectrocardioInterface> ecgInterface = [TopStepComKit sharedInstance].electrocardio;
[ecgInterface stopMeasureCompletion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"心电测量已停止");
    } else {
        TSLog(@"停止测量失败: %@", error.localizedDescription);
    }
}];
```

### 检查设备是否支持自动心电图监测

检查设备是否具备自动心电图监测功能。

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**返回值**

| 返回值 | 说明 |
|-------|------|
| `BOOL` | 如果设备支持自动心电图监测返回`YES`，否则返回`NO` |

**代码示例**

```objc
id<TSElectrocardioInterface> ecgInterface = [TopStepComKit sharedInstance].electrocardio;
if ([ecgInterface isSupportAutomaticMonitoring]) {
    TSLog(@"设备支持自动心电图监测");
} else {
    TSLog(@"设备不支持自动心电图监测");
}
```

### 配置自动心电图监测

设置或更新自动心电图监测的配置参数。

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `configuration` | `TSAutoMonitorConfigs *` | 自动心电图监测的配置参数 |
| `completion` | `TSCompletionBlock` | 配置设置成功或失败时调用的完成回调 |

**代码示例**

```objc
id<TSElectrocardioInterface> ecgInterface = [TopStepComKit sharedInstance].electrocardio;
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];
// 配置参数...

[ecgInterface pushAutoMonitorConfigs:config completion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"自动监测配置已设置");
    } else {
        TSLog(@"设置配置失败: %@", error.localizedDescription);
    }
}];
```

### 获取自动心电图监测配置

获取设备当前的自动心电图监测配置。

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | 包含当前配置或错误的完成回调 |

**代码示例**

```objc
id<TSElectrocardioInterface> ecgInterface = [TopStepComKit sharedInstance].electrocardio;
[ecgInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
    if (configuration) {
        TSLog(@"获取配置成功");
    } else {
        TSLog(@"获取配置失败: %@", error.localizedDescription);
    }
}];
```

### 同步指定时间范围内的原始心电图数据

同步指定开始时间和结束时间之间的原始心电图测量数据。

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSECGValueItem *> *_Nullable ecgItems, NSError *_Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳） |
| `endTime` | `NSTimeInterval` | 数据同步的结束时间（1970年以来的秒数时间戳） |
| `completion` | `void (^)(NSArray<TSECGValueItem *> *, NSError *)` | 包含同步的原始心电图测量条目或错误的完成回调 |

**代码示例**

```objc
id<TSElectrocardioInterface> ecgInterface = [TopStepComKit sharedInstance].electrocardio;
NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1700000000];
NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1700086400];

[ecgInterface syncRawDataFromStartTime:startDate.timeIntervalSince1970
                               endTime:endDate.timeIntervalSince1970
                            completion:^(NSArray<TSECGValueItem *> * _Nullable ecgItems, NSError * _Nullable error) {
    if (ecgItems) {
        TSLog(@"同步获得 %lu 条原始心电数据", (unsigned long)ecgItems.count);
        for (TSECGValueItem *item in ecgItems) {
            TSLog(@"心率: %ld BPM, 节律: %@", (long)item.heartRate, item.rhythmClassification);
        }
    } else {
        TSLog(@"同步失败: %@", error.localizedDescription);
    }
}];
```

### 从指定开始时间同步至今的原始心电图数据

从指定开始时间同步到当前时间的原始心电图数据。

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSECGValueItem *> *_Nullable ecgItems, NSError *_Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳） |
| `completion` | `void (^)(NSArray<TSECGValueItem *> *, NSError *)` | 包含同步的原始心电图测量条目或错误的完成回调 |

**代码示例**

```objc
id<TSElectrocardioInterface> ecgInterface = [TopStepComKit sharedInstance].electrocardio;
NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1700000000];

[ecgInterface syncRawDataFromStartTime:startDate.timeIntervalSince1970
                            completion:^(NSArray<TSECGValueItem *> * _Nullable ecgItems, NSError * _Nullable error) {
    if (ecgItems) {
        TSLog(@"从指定时间至今同步获得 %lu 条原始心电数据", (unsigned long)ecgItems.count);
    } else {
        TSLog(@"同步失败: %@", error.localizedDescription);
    }
}];
```

### 同步指定时间范围内的每日心电图数据

同步指定开始时间和结束时间之间的每日聚合心电图数据。时间参数将自动规范化为日期边界。

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSECGDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳）。将自动规范化为指定日期的 00:00:00。必须早于结束时间 |
| `endTime` | `NSTimeInterval` | 数据同步的结束时间（1970年以来的秒数时间戳）。将自动规范化为指定日期的 23:59:59。必须晚于开始时间且不能在将来 |
| `completion` | `void (^)(NSArray<TSECGDailyModel *> *, NSError *)` | 完成回调，返回同步的每日心电图模型数组或错误。每个`TSECGDailyModel`代表一天的数据集合 |

**代码示例**

```objc
id<TSElectrocardioInterface> ecgInterface = [TopStepComKit sharedInstance].electrocardio;
NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1700000000];
NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1700518400];

[ecgInterface syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                                 endTime:endDate.timeIntervalSince1970
                              completion:^(NSArray<TSECGDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (dailyModels) {
        TSLog(@"同步获得 %lu 天的每日心电数据", (unsigned long)dailyModels.count);
        for (TSECGDailyModel *dailyModel in dailyModels) {
            TSLog(@"日期: %@", dailyModel.timestamp);
        }
    } else {
        TSLog(@"同步失败: %@", error.localizedDescription);
    }
}];
```

### 从指定开始时间同步至今的每日心电图数据

从指定开始时间同步到当前时间的每日聚合心电图数据。开始时间将自动规范化为日期的 00:00:00。

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSECGDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间（1970年以来的秒数时间戳）。将自动规范化为指定日期的 00:00:00。数据将同步从此时间到当前时间 |
| `completion` | `void (^)(NSArray<TSECGDailyModel *> *, NSError *)` | 完成回调，返回同步的每日心电图模型数组或错误。每个`TSECGDailyModel`代表一天的数据集合 |

**代码示例**

```objc
id<TSElectrocardioInterface> ecgInterface = [TopStepComKit sharedInstance].electrocardio;
NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1700000000];

[ecgInterface syncDailyDataFromStartTime:startDate.timeIntervalSince1970
                              completion:^(NSArray<TSECGDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (dailyModels) {
        TSLog(@"从指定时间至今同步获得 %lu 天的每日心电数据", (unsigned long)dailyModels.count);
    } else {
        TSLog(@"同步失败: %@", error.localizedDescription);
    }
}];
```

## 注意事项

1. 使用手动心电图测量前，必须先调用 `isSupportActivityMeasureByUser` 方法检查设备是否支持该功能。

2. 在调用 `startMeasureWithParam:startHandler:dataHandler:endHandler:` 时，需要提供三个回调处理程序来分别处理测量开始、实时数据和测量结束事件。

3. 实时数据回调 `dataHandler` 可能被多次调用，用于接收持续的心电数据。应在该回调中更新 UI 或进行数据处理。

4. 调用 `stopMeasureCompletion:` 可以主动停止测量。停止后，`endHandler` 回调将被调用。

5. 自动监测配置应在设备支持该功能（通过 `isSupportAutomaticMonitoring` 确认）之前进行验证。

6. 同步原始数据时，数据量可能较大。建议合理设置时间范围以避免过多的网络传输和内存占用。

7. 同步每日数据时，时间参数会自动规范化到日期边界。例如，10:30:00 将被规范化为 00:00:00（开始时间）或 23:59:59（结束时间）。

8. 数据同步的完成回调在主线程中调用，可以直接更新 UI。

9. 所有的 `NSTimeInterval` 时间参数都基于 1970 年 1 月 1 日（UTC）的秒数时间戳。

10. 心率变异性指标 `hrvMetrics` 是一个字典，包含多种HRV度量，具体支持的指标应参考设备文档。

11. `rhythmClassification` 属性的值取决于设备的心律分类算法。常见的分类包括"正常窦性心律"、"心房颤动"等。

12. 时间戳参数应确保准确性，建议使用系统时间或从设备同步的时间，避免本地时钟不准确导致的数据同步问题。