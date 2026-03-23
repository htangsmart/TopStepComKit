---
sidebar_position: 7
title: 体温
---

# 体温 (TSTemperature)

本模块提供体温测量、自动监测和历史数据同步的功能。支持手动温度测量、设备自动监测配置、原始数据和每日聚合数据的同步。

## 前提条件

1. 设备需支持体温相关功能
2. 需获得相应的健康数据权限
3. 对于自动监测功能，设备需支持自动温度监测能力

## 数据模型

### TSTempValueItem

体温测量数据项，代表单次温度测量记录。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `temperature` | `CGFloat` | 温度值，单位为摄氏度。含义取决于 temperatureType：体温（36.1-37.2°C）或腕温（通常低于体温） |
| `temperatureType` | `TSTemperatureType` | 温度测量类型，区分体温和腕温 |
| `isUserInitiated` | `BOOL` | 指示测量是否为用户主动发起 |
| `timestamp` | `NSTimeInterval` | 测量时间戳（继承自 TSHealthValueItem） |

### TSTempDailyModel

每日体温聚合数据模型，代表某一天的温度统计信息。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `maxBodyTempItem` | `TSTempValueItem *` | 当天最高核心体温条目 |
| `minBodyTempItem` | `TSTempValueItem *` | 当天最低核心体温条目 |
| `maxWristTempItem` | `TSTempValueItem *` | 当天最高腕温条目 |
| `minWristTempItem` | `TSTempValueItem *` | 当天最低腕温条目 |
| `manualItems` | `NSArray<TSTempValueItem *>` | 用户主动测量的体温条目数组，按时间升序排列 |
| `autoItems` | `NSArray<TSTempValueItem *>` | 设备自动监测的体温条目数组，按时间升序排列 |

## 枚举与常量

### TSTemperatureType

温度测量类型枚举，区分体温和腕温测量。

| 值 | 说明 |
|----|------|
| `TSTemperatureTypeBody` | 体温（核心体温） |
| `TSTemperatureTypeWrist` | 腕温 |

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `void (^)(BOOL success, NSError * _Nullable error)` | 测量启停回调，success 表示操作成功，error 包含失败信息 |
| `void (^)(TSTempValueItem * _Nullable data, NSError * _Nullable error)` | 实时数据回调，data 为当前测量数据，error 表示接收失败 |
| `TSCompletionBlock` | 完成操作回调 |
| `void (^)(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error)` | 配置获取回调，返回当前监测配置或错误 |
| `void (^)(NSArray<TSTempValueItem *> * _Nullable tempItems, NSError * _Nullable error)` | 原始数据同步回调，返回温度测量条目数组或错误 |
| `void (^)(NSArray<TSTempDailyModel *> * _Nullable dailyModels, NSError * _Nullable error)` | 每日数据同步回调，返回每日聚合数据数组或错误 |

## 接口方法

### 检查是否支持手动测量

检查设备是否支持用户手动启动体温测量功能。

```objc
- (BOOL)isSupportActivityMeasureByUser;
```

**返回值**

| 类型 | 说明 |
|------|------|
| `BOOL` | 支持返回 YES，不支持返回 NO |

**代码示例**

```objc
id<TSTemperatureInterface> tempInterface = [TopStepComKit sharedInstance].temperature;
if ([tempInterface isSupportActivityMeasureByUser]) {
    TSLog(@"设备支持手动温度测量");
} else {
    TSLog(@"设备不支持手动温度测量");
}
```

### 开始温度测量

使用指定参数启动温度测量，支持实时数据回调和测量状态监听。

```objc
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSTempValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `measureParam` | `TSActivityMeasureParam *` | 测量活动的参数配置 |
| `startHandler` | `void (^)(BOOL, NSError *)` | 测量启动回调。success 表示是否成功启动，error 为失败错误信息 |
| `dataHandler` | `void (^)(TSTempValueItem *, NSError *)` | 实时数据回调。data 为当前测量数据，error 为接收失败信息 |
| `endHandler` | `void (^)(BOOL, NSError *)` | 测量结束回调。success 表示是否正常结束，error 为异常结束的错误信息 |

**代码示例**

```objc
id<TSTemperatureInterface> tempInterface = [TopStepComKit sharedInstance].temperature;
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];

[tempInterface startMeasureWithParam:param
                        startHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"体温测量已启动");
    } else {
        TSLog(@"启动失败: %@", error.localizedDescription);
    }
} dataHandler:^(TSTempValueItem * _Nullable data, NSError * _Nullable error) {
    if (data) {
        TSLog(@"实时温度: %.1f°C (类型: %ld)", data.temperature, (long)data.temperatureType);
    } else if (error) {
        TSLog(@"接收数据失败: %@", error.localizedDescription);
    }
} endHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"体温测量已正常结束");
    } else {
        TSLog(@"异常结束: %@", error.localizedDescription);
    }
}];
```

### 停止温度测量

停止当前正在进行的温度测量。

```objc
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSCompletionBlock` | 测量停止完成回调 |

**代码示例**

```objc
id<TSTemperatureInterface> tempInterface = [TopStepComKit sharedInstance].temperature;
[tempInterface stopMeasureCompletion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"体温测量已停止");
    } else {
        TSLog(@"停止失败: %@", error.localizedDescription);
    }
}];
```

### 检查是否支持自动监测

检查设备是否支持自动体温监测功能。

```objc
- (BOOL)isSupportAutomaticMonitoring;
```

**返回值**

| 类型 | 说明 |
|------|------|
| `BOOL` | 支持返回 YES，不支持返回 NO |

**代码示例**

```objc
id<TSTemperatureInterface> tempInterface = [TopStepComKit sharedInstance].temperature;
if ([tempInterface isSupportAutomaticMonitoring]) {
    TSLog(@"设备支持自动温度监测");
} else {
    TSLog(@"设备不支持自动温度监测");
}
```

### 配置自动监测

设置设备的自动温度监测配置参数。

```objc
- (void)pushAutoMonitorConfig:(TSAutoMonitorConfigs *_Nonnull)configuration
                       completion:(nonnull TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `configuration` | `TSAutoMonitorConfigs *` | 自动监测的配置参数 |
| `completion` | `TSCompletionBlock` | 配置设置完成回调 |

**代码示例**

```objc
id<TSTemperatureInterface> tempInterface = [TopStepComKit sharedInstance].temperature;
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];
config.enabled = YES;

[tempInterface pushAutoMonitorConfig:config completion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"自动监测配置已设置");
    } else {
        TSLog(@"配置失败: %@", error.localizedDescription);
    }
}];
```

### 获取自动监测配置

获取设备当前的自动温度监测配置。

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | 配置获取完成回调，返回当前配置或错误 |

**代码示例**

```objc
id<TSTemperatureInterface> tempInterface = [TopStepComKit sharedInstance].temperature;
[tempInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
    if (configuration) {
        TSLog(@"自动监测已启用: %@", configuration.enabled ? @"是" : @"否");
    } else if (error) {
        TSLog(@"获取配置失败: %@", error.localizedDescription);
    }
}];
```

### 同步指定时间范围内的原始数据

同步指定起止时间范围内的原始温度测量数据。

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSTempValueItem *> *_Nullable tempItems, NSError *_Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 同步开始时间（1970年以来的秒数时间戳） |
| `endTime` | `NSTimeInterval` | 同步结束时间（1970年以来的秒数时间戳） |
| `completion` | `void (^)(NSArray *, NSError *)` | 数据同步完成回调，返回温度数据条目数组或错误 |

**代码示例**

```objc
id<TSTemperatureInterface> tempInterface = [TopStepComKit sharedInstance].temperature;

// 同步过去7天的数据
NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
NSTimeInterval sevenDaysAgo = now - 7 * 24 * 3600;

[tempInterface syncRawDataFromStartTime:sevenDaysAgo
                                endTime:now
                             completion:^(NSArray<TSTempValueItem *> * _Nullable tempItems, NSError * _Nullable error) {
    if (tempItems) {
        TSLog(@"同步获得 %lu 条温度数据", (unsigned long)tempItems.count);
        for (TSTempValueItem *item in tempItems) {
            NSString *type = (item.temperatureType == TSTemperatureTypeBody) ? @"体温" : @"腕温";
            TSLog(@"温度: %.1f°C (%@) - 用户主动: %@", 
                  item.temperature, type, item.isUserInitiated ? @"是" : @"否");
        }
    } else if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    }
}];
```

### 同步从指定时间至今的原始数据

同步从指定开始时间到当前时间的原始温度测量数据。

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSTempValueItem *> *_Nullable tempItems, NSError *_Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 同步开始时间（1970年以来的秒数时间戳） |
| `completion` | `void (^)(NSArray *, NSError *)` | 数据同步完成回调，返回温度数据条目数组或错误 |

**代码示例**

```objc
id<TSTemperatureInterface> tempInterface = [TopStepComKit sharedInstance].temperature;

// 同步过去30天到现在的数据
NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
NSTimeInterval thirtyDaysAgo = now - 30 * 24 * 3600;

[tempInterface syncRawDataFromStartTime:thirtyDaysAgo
                             completion:^(NSArray<TSTempValueItem *> * _Nullable tempItems, NSError * _Nullable error) {
    if (tempItems) {
        TSLog(@"同步获得 %lu 条数据", (unsigned long)tempItems.count);
    } else if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    }
}];
```

### 同步指定时间范围内的每日数据

同步指定起止时间范围内的每日聚合温度数据。时间参数将自动规范化到日期边界。

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSTempDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 同步开始时间（1970年以来的秒数时间戳），自动规范化为当日 00:00:00 |
| `endTime` | `NSTimeInterval` | 同步结束时间（1970年以来的秒数时间戳），自动规范化为当日 23:59:59 |
| `completion` | `void (^)(NSArray *, NSError *)` | 数据同步完成回调，返回每日聚合数据模型数组或错误 |

**代码示例**

```objc
id<TSTemperatureInterface> tempInterface = [TopStepComKit sharedInstance].temperature;

// 同步过去7天的每日数据
NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
NSTimeInterval sevenDaysAgo = now - 7 * 24 * 3600;

[tempInterface syncDailyDataFromStartTime:sevenDaysAgo
                                 endTime:now
                              completion:^(NSArray<TSTempDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (dailyModels) {
        TSLog(@"同步获得 %lu 天的数据", (unsigned long)dailyModels.count);
        for (TSTempDailyModel *daily in dailyModels) {
            TSLog(@"最高体温: %.1f°C, 最低体温: %.1f°C", 
                  [daily maxBodyTemperature], [daily minBodyTemperature]);
            TSLog(@"主动测量: %lu 次, 自动监测: %lu 次", 
                  (unsigned long)daily.manualItems.count, (unsigned long)daily.autoItems.count);
        }
    } else if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    }
}];
```

### 同步从指定时间至今的每日数据

同步从指定开始时间到当前时间的每日聚合温度数据。

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSTempDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 同步开始时间（1970年以来的秒数时间戳），自动规范化为当日 00:00:00 |
| `completion` | `void (^)(NSArray *, NSError *)` | 数据同步完成回调，返回每日聚合数据模型数组或错误 |

**代码示例**

```objc
id<TSTemperatureInterface> tempInterface = [TopStepComKit sharedInstance].temperature;

// 同步过去30天到现在的每日数据
NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
NSTimeInterval thirtyDaysAgo = now - 30 * 24 * 3600;

[tempInterface syncDailyDataFromStartTime:thirtyDaysAgo
                               completion:^(NSArray<TSTempDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
    if (dailyModels) {
        for (TSTempDailyModel *daily in dailyModels) {
            CGFloat maxBody = [daily maxBodyTemperature];
            CGFloat minBody = [daily minBodyTemperature];
            CGFloat maxWrist = [daily maxWristTemperature];
            CGFloat minWrist = [daily minWristTemperature];
            
            TSLog(@"日期: %@", [NSDate dateWithTimeIntervalSince1970:daily.timestamp]);
            TSLog(@"体温范围: %.1f - %.1f°C", minBody, maxBody);
            TSLog(@"腕温范围: %.1f - %.1f°C", minWrist, maxWrist);
            TSLog(@"所有测量项: %lu 条", (unsigned long)[daily allMeasuredItems].count);
        }
    } else if (error) {
        TSLog(@"同步失败: %@", error.localizedDescription);
    }
}];
```

## 注意事项

1. **时间戳格式**：所有时间参数均为 1970 年 1 月 1 日 00:00:00 UTC 以来的秒数，使用 `[[NSDate date] timeIntervalSince1970]` 获取当前时间戳
2. **每日数据规范化**：调用 `syncDailyDataFromStartTime:endTime:completion:` 时，时间参数会自动规范化到日期边界（startTime 规范化为 00:00:00，endTime 规范化为 23:59:59）
3. **数据排序**：同步返回的数据均按时间升序排列
4. **温度类型区分**：体温代表核心体温（正常范围 36.1-37.2°C），腕温通常低于体温
5. **用户主动标记**：`TSTempValueItem` 中的 `isUserInitiated` 标记是否为用户手动发起的测量
6. **异步回调**：所有完成回调均在主线程中执行
7. **设备支持检查**：在使用手动测量或自动监测前，应先调用相应的 `isSupport` 方法确认设备支持
8. **配置管理**：自动监测配置通过 `pushAutoMonitorConfig:completion:` 设置后会保存到设备，可通过 `fetchAutoMonitorConfigsWithCompletion:` 随时查询当前配置
9. **时间范围限制**：`syncDailyDataFromStartTime:endTime:completion:` 中 endTime 不能为未来时间，startTime 必须早于 endTime
10. **合并数据访问**：`TSTempDailyModel` 提供 `allMeasuredItems` 方法便捷获取某一天的所有测量数据（包含手动和自动）
