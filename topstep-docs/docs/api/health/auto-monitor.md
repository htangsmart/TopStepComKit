---
sidebar_position: 11
title: 自动监测
---

# 自动监测（TSAutoMonitor）

TSAutoMonitor 模块提供设备自动监测功能的配置与管理能力，支持心率、血压、血氧、压力和体温等多种监测项的自动监测计划设置和告警阈值配置。

## 前提条件

1. 已初始化 TopStepComKit SDK
2. 设备已连接且配对成功
3. 用户具有设备操作权限
4. 设备支持相应的监测功能

## 数据模型

### TSMonitorSchedule（监测计划）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `enabled` | `BOOL` | 监测是否启用 |
| `startTime` | `UInt16` | 开始时间（从午夜开始的分钟数，有效范围 0-1440） |
| `endTime` | `UInt16` | 结束时间（从午夜开始的分钟数，有效范围 0-1440，必须大于开始时间） |
| `interval` | `UInt16` | 监测间隔（分钟，必须是 5 的倍数） |

### TSMonitorAlert（告警配置）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `enabled` | `BOOL` | 告警是否启用 |
| `upperLimit` | `UInt16` | 上限阈值（单位取决于监测类型） |
| `lowerLimit` | `UInt16` | 下限阈值（单位取决于监测类型） |

### TSMonitorBPAlert（血压告警配置）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `enabled` | `BOOL` | 血压告警是否启用 |
| `systolicUpperLimit` | `UInt8` | 收缩压上限阈值（mmHg） |
| `systolicLowerLimit` | `UInt8` | 收缩压下限阈值（mmHg） |
| `diastolicUpperLimit` | `UInt8` | 舒张压上限阈值（mmHg） |
| `diastolicLowerLimit` | `UInt8` | 舒张压下限阈值（mmHg） |

### TSAutoMonitorConfigs（通用自动监测配置）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `schedule` | `TSMonitorSchedule *` | 监测计划（包含开关、时间和间隔） |
| `alert` | `TSMonitorAlert *` | 告警配置（单位随监测类型而异） |

### TSAutoMonitorHRConfigs（心率自动监测配置）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `schedule` | `TSMonitorSchedule *` | 监测计划（包含开关、时间和间隔） |
| `restHRAlert` | `TSMonitorAlert *` | 静息心率告警配置（单位：bpm） |
| `exerciseHRAlert` | `TSMonitorAlert *` | 运动心率告警配置（单位：bpm） |
| `exerciseHRLimitMax` | `UInt8` | 最大运动心率（用于心率区间计算，建议范围 100-220 bpm） |

### TSAutoMonitorBPConfigs（血压自动监测配置）

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `schedule` | `TSMonitorSchedule *` | 监测计划（包含开关、时间和间隔） |
| `alert` | `TSMonitorBPAlert *` | 血压告警配置（分别设置收缩压和舒张压的上下限，单位：mmHg） |

## 接口方法

### 获取心率自动监测配置

获取设备当前的心率自动监测配置，包括监测计划、静息心率和运动心率的告警阈值，以及心率区间计算的最大值。

```objc
+ (void)fetchHeartRateAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorHRConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorHRConfigs *_Nullable, NSError *_Nullable)` | 完成回调，返回心率监测配置或错误信息 |

**代码示例：**

```objc
[TSAutoMonitorInterface fetchHeartRateAutoMonitorConfigsWithCompletion:^(TSAutoMonitorHRConfigs * _Nullable configs, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取心率监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"监测启用: %@", configs.schedule.enabled ? @"是" : @"否");
        TSLog(@"开始时间: %u 分钟", configs.schedule.startTime);
        TSLog(@"结束时间: %u 分钟", configs.schedule.endTime);
        TSLog(@"间隔: %u 分钟", configs.schedule.interval);
        if (configs.restHRAlert) {
            TSLog(@"静息心率告警 - 启用: %@, 上限: %u bpm, 下限: %u bpm",
                  configs.restHRAlert.enabled ? @"是" : @"否",
                  configs.restHRAlert.upperLimit,
                  configs.restHRAlert.lowerLimit);
        }
        if (configs.exerciseHRAlert) {
            TSLog(@"运动心率告警 - 启用: %@, 上限: %u bpm, 下限: %u bpm",
                  configs.exerciseHRAlert.enabled ? @"是" : @"否",
                  configs.exerciseHRAlert.upperLimit,
                  configs.exerciseHRAlert.lowerLimit);
        }
        TSLog(@"最大运动心率: %u bpm", configs.exerciseHRLimitMax);
    }
}];
```

### 推送心率自动监测配置

将心率自动监测配置发送到设备，设备将应用这些设置进行自动监测。

```objc
+ (void)pushHeartRateAutoMonitorConfig:(TSAutoMonitorHRConfigs *)config
                            completion:(TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSAutoMonitorHRConfigs *` | 要设置的心率监测配置 |
| `completion` | `TSCompletionBlock` | 完成回调，返回操作结果 |

**代码示例：**

```objc
TSAutoMonitorHRConfigs *config = [[TSAutoMonitorHRConfigs alloc] init];

// 设置监测计划
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 480;  // 8:00 AM
schedule.endTime = 1200;   // 8:00 PM
schedule.interval = 10;    // 10 分钟间隔
config.schedule = schedule;

// 设置静息心率告警
TSMonitorAlert *restHRAlert = [[TSMonitorAlert alloc] init];
restHRAlert.enabled = YES;
restHRAlert.upperLimit = 100;  // 上限 100 bpm
restHRAlert.lowerLimit = 40;   // 下限 40 bpm
config.restHRAlert = restHRAlert;

// 设置运动心率告警
TSMonitorAlert *exerciseHRAlert = [[TSMonitorAlert alloc] init];
exerciseHRAlert.enabled = YES;
exerciseHRAlert.upperLimit = 180;  // 上限 180 bpm
exerciseHRAlert.lowerLimit = 100;  // 下限 100 bpm
config.exerciseHRAlert = exerciseHRAlert;

// 设置最大运动心率（220 - 年龄，例如 30 岁为 190）
config.exerciseHRLimitMax = 190;

[TSAutoMonitorInterface pushHeartRateAutoMonitorConfig:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"推送心率监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"心率监测配置已成功推送到设备");
    }
}];
```

### 获取血压自动监测配置

获取设备当前的血压自动监测配置，包括监测计划和血压告警阈值。

```objc
+ (void)fetchBloodPressureAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorBPConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorBPConfigs *_Nullable, NSError *_Nullable)` | 完成回调，返回血压监测配置或错误信息 |

**代码示例：**

```objc
[TSAutoMonitorInterface fetchBloodPressureAutoMonitorConfigsWithCompletion:^(TSAutoMonitorBPConfigs * _Nullable configs, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取血压监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"监测启用: %@", configs.schedule.enabled ? @"是" : @"否");
        TSLog(@"开始时间: %u 分钟", configs.schedule.startTime);
        TSLog(@"结束时间: %u 分钟", configs.schedule.endTime);
        TSLog(@"间隔: %u 分钟", configs.schedule.interval);
        if (configs.alert) {
            TSLog(@"血压告警 - 启用: %@", configs.alert.enabled ? @"是" : @"否");
            TSLog(@"收缩压 - 上限: %u mmHg, 下限: %u mmHg",
                  configs.alert.systolicUpperLimit,
                  configs.alert.systolicLowerLimit);
            TSLog(@"舒张压 - 上限: %u mmHg, 下限: %u mmHg",
                  configs.alert.diastolicUpperLimit,
                  configs.alert.diastolicLowerLimit);
        }
    }
}];
```

### 推送血压自动监测配置

将血压自动监测配置发送到设备，设备将应用这些设置进行自动监测。

```objc
+ (void)pushBloodPressureAutoMonitorConfig:(TSAutoMonitorBPConfigs *)config
                                completion:(TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSAutoMonitorBPConfigs *` | 要设置的血压监测配置 |
| `completion` | `TSCompletionBlock` | 完成回调，返回操作结果 |

**代码示例：**

```objc
TSAutoMonitorBPConfigs *config = [[TSAutoMonitorBPConfigs alloc] init];

// 设置监测计划
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 420;  // 7:00 AM
schedule.endTime = 1260;   // 9:00 PM
schedule.interval = 15;    // 15 分钟间隔
config.schedule = schedule;

// 设置血压告警阈值
TSMonitorBPAlert *alert = [[TSMonitorBPAlert alloc] init];
alert.enabled = YES;
alert.systolicUpperLimit = 140;     // 收缩压上限 140 mmHg
alert.systolicLowerLimit = 90;      // 收缩压下限 90 mmHg
alert.diastolicUpperLimit = 90;     // 舒张压上限 90 mmHg
alert.diastolicLowerLimit = 60;     // 舒张压下限 60 mmHg
config.alert = alert;

[TSAutoMonitorInterface pushBloodPressureAutoMonitorConfig:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"推送血压监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"血压监测配置已成功推送到设备");
    }
}];
```

### 获取血氧自动监测配置

获取设备当前的血氧（SpO2）自动监测配置，包括监测计划和血氧告警阈值。

```objc
+ (void)fetchBloodOxygenAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *_Nullable, NSError *_Nullable)` | 完成回调，返回血氧监测配置或错误信息 |

**代码示例：**

```objc
[TSAutoMonitorInterface fetchBloodOxygenAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs * _Nullable configs, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取血氧监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"监测启用: %@", configs.schedule.enabled ? @"是" : @"否");
        TSLog(@"开始时间: %u 分钟", configs.schedule.startTime);
        TSLog(@"结束时间: %u 分钟", configs.schedule.endTime);
        TSLog(@"间隔: %u 分钟", configs.schedule.interval);
        if (configs.alert) {
            TSLog(@"血氧告警 - 启用: %@", configs.alert.enabled ? @"是" : @"否");
            TSLog(@"上限: %u%%, 下限: %u%%",
                  configs.alert.upperLimit,
                  configs.alert.lowerLimit);
        }
    }
}];
```

### 推送血氧自动监测配置

将血氧自动监测配置发送到设备，设备将应用这些设置进行自动监测。

```objc
+ (void)pushBloodOxygenAutoMonitorConfig:(TSAutoMonitorConfigs *)config
                            completion:(TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSAutoMonitorConfigs *` | 要设置的血氧监测配置 |
| `completion` | `TSCompletionBlock` | 完成回调，返回操作结果 |

**代码示例：**

```objc
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];

// 设置监测计划
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 0;     // 0:00 AM
schedule.endTime = 1440;    // 24:00 PM（全天监测）
schedule.interval = 30;     // 30 分钟间隔
config.schedule = schedule;

// 设置血氧告警阈值
TSMonitorAlert *alert = [[TSMonitorAlert alloc] init];
alert.enabled = YES;
alert.upperLimit = 100;  // 上限 100%
alert.lowerLimit = 95;   // 下限 95%
config.alert = alert;

[TSAutoMonitorInterface pushBloodOxygenAutoMonitorConfig:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"推送血氧监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"血氧监测配置已成功推送到设备");
    }
}];
```

### 获取压力自动监测配置

获取设备当前的压力自动监测配置，包括监测计划和压力告警阈值。

```objc
+ (void)fetchStressAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *_Nullable, NSError *_Nullable)` | 完成回调，返回压力监测配置或错误信息 |

**代码示例：**

```objc
[TSAutoMonitorInterface fetchStressAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs * _Nullable configs, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取压力监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"监测启用: %@", configs.schedule.enabled ? @"是" : @"否");
        TSLog(@"开始时间: %u 分钟", configs.schedule.startTime);
        TSLog(@"结束时间: %u 分钟", configs.schedule.endTime);
        TSLog(@"间隔: %u 分钟", configs.schedule.interval);
        if (configs.alert) {
            TSLog(@"压力告警 - 启用: %@", configs.alert.enabled ? @"是" : @"否");
            TSLog(@"上限: %u, 下限: %u",
                  configs.alert.upperLimit,
                  configs.alert.lowerLimit);
        }
    }
}];
```

### 推送压力自动监测配置

将压力自动监测配置发送到设备，设备将应用这些设置进行自动监测。

```objc
+ (void)pushStressAutoMonitorConfig:(TSAutoMonitorConfigs *)config
                            completion:(TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSAutoMonitorConfigs *` | 要设置的压力监测配置 |
| `completion` | `TSCompletionBlock` | 完成回调，返回操作结果 |

**代码示例：**

```objc
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];

// 设置监测计划
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 480;  // 8:00 AM
schedule.endTime = 1140;   // 7:00 PM
schedule.interval = 20;    // 20 分钟间隔
config.schedule = schedule;

// 设置压力告警阈值
TSMonitorAlert *alert = [[TSMonitorAlert alloc] init];
alert.enabled = YES;
alert.upperLimit = 80;   // 上限 80
alert.lowerLimit = 30;   // 下限 30
config.alert = alert;

[TSAutoMonitorInterface pushStressAutoMonitorConfig:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"推送压力监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"压力监测配置已成功推送到设备");
    }
}];
```

### 获取体温自动监测配置

获取设备当前的体温自动监测配置，包括监测计划和体温告警阈值。

```objc
+ (void)fetchTemperatureAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *_Nullable, NSError *_Nullable)` | 完成回调，返回体温监测配置或错误信息 |

**代码示例：**

```objc
[TSAutoMonitorInterface fetchTemperatureAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs * _Nullable configs, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取体温监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"监测启用: %@", configs.schedule.enabled ? @"是" : @"否");
        TSLog(@"开始时间: %u 分钟", configs.schedule.startTime);
        TSLog(@"结束时间: %u 分钟", configs.schedule.endTime);
        TSLog(@"间隔: %u 分钟", configs.schedule.interval);
        if (configs.alert) {
            TSLog(@"体温告警 - 启用: %@", configs.alert.enabled ? @"是" : @"否");
            TSLog(@"上限: %u℃, 下限: %u℃",
                  configs.alert.upperLimit,
                  configs.alert.lowerLimit);
        }
    }
}];
```

### 推送体温自动监测配置

将体温自动监测配置发送到设备，设备将应用这些设置进行自动监测。

```objc
+ (void)pushTemperatureAutoMonitorConfig:(TSAutoMonitorConfigs *)config
                            completion:(TSCompletionBlock)completion;
```

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSAutoMonitorConfigs *` | 要设置的体温监测配置 |
| `completion` | `TSCompletionBlock` | 完成回调，返回操作结果 |

**代码示例：**

```objc
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];

// 设置监测计划
TSMonitorSchedule *schedule = [[TSMonitorSchedule alloc] init];
schedule.enabled = YES;
schedule.startTime = 360;  // 6:00 AM
schedule.endTime = 1320;   // 10:00 PM
schedule.interval = 60;    // 60 分钟间隔
config.schedule = schedule;

// 设置体温告警阈值
TSMonitorAlert *alert = [[TSMonitorAlert alloc] init];
alert.enabled = YES;
alert.upperLimit = 38;   // 上限 38℃
alert.lowerLimit = 36;   // 下限 36℃
config.alert = alert;

[TSAutoMonitorInterface pushTemperatureAutoMonitorConfig:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"推送体温监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"体温监测配置已成功推送到设备");
    }
}];
```

## 注意事项

1. 所有网络请求均为异步操作，完成回调将在主队列上执行。
2. 时间值采用从午夜（00:00）开始的分钟数表示，有效范围为 0-1440：
   - 0 表示 00:00（午夜）
   - 480 表示 08:00（早上 8 点）
   - 1200 表示 20:00（晚上 8 点）
3. 监测间隔（`interval`）必须是 5 的倍数，常见值有 5、10、15、20、25、30 等。
4. 结束时间（`endTime`）必须大于开始时间（`startTime`），否则设置无效。
5. 心率监测中的最大运动心率（`exerciseHRLimitMax`）用于计算心率区间，建议范围为 100-220 bpm，通常按公式 220 - 年龄 计算。
6. 血压值单位为毫米汞柱（mmHg），血氧值单位为百分比（%），体温值单位为摄氏度（°C）。
7. 确保设置的告警阈值逻辑合理（上限 ≥ 下限），避免阈值设置过于严格导致频繁告警。
8. 在推送配置之前，建议先调用相应的获取方法获得当前配置，以确保用户的修改意图清晰。
9. 某些设备可能不支持所有监测功能，建议在应用中提前检测设备能力。