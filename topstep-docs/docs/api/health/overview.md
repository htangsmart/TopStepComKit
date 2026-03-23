---
sidebar_position: 1
title: 健康数据概述
---

# 健康数据概述（TSHealthBase）

TSHealthBase 模块提供了完整的健康数据管理框架，支持自动监测方式。该模块包含实时心率、血压、血氧、压力、体温等多种健康指标的测量和监控功能。

## 前提条件

1. 设备已完成蓝牙配对和连接
2. 设备固件版本支持所需的健康测量功能
3. 用户已授予相关健康数据访问权限
4. 了解各测量类型的基本单位和范围（心率单位 bpm、血压单位 mmHg、血氧单位 %等）

## 数据模型

### TSHealthValueModel

| 属性名 | 类型 | 说明 |
|-------|------|------|
| - | - | 健康数据值的基础模型 |

### TSHealthValueItem

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 数据记录的开始时间戳（Unix 时间戳，单位秒） |
| `endTime` | `NSTimeInterval` | 数据记录的结束时间戳（Unix 时间戳，单位秒） |
| `duration` | `double` | 数据记录的持续时间，单位秒 |
| `valueType` | `TSItemValueType` | 数据点类型（普通、最大值、最小值、静息等） |

### TSHealthDailyModel

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 数据记录的开始时间戳（Unix 时间戳，单位秒） |
| `endTime` | `NSTimeInterval` | 数据记录的结束时间戳（Unix 时间戳，单位秒） |
| `duration` | `double` | 数据记录的持续时间，单位秒 |

### TSMonitorSchedule

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `enabled` | `BOOL` | 监测是否启用 |
| `startTime` | `UInt16` | 开始时间，距零点的分钟数（0-1440，例如 480 表示 8:00） |
| `endTime` | `UInt16` | 结束时间，距零点的分钟数（0-1440，必须大于开始时间） |
| `interval` | `UInt16` | 监测间隔，单位分钟（必须是 5 的倍数） |

### TSMonitorAlert

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `enabled` | `BOOL` | 告警是否启用 |
| `upperLimit` | `UInt16` | 上限阈值 |
| `lowerLimit` | `UInt16` | 下限阈值 |

### TSMonitorBPAlert

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `enabled` | `BOOL` | 血压告警是否启用 |
| `systolicUpperLimit` | `UInt8` | 收缩压上限阈值（mmHg） |
| `systolicLowerLimit` | `UInt8` | 收缩压下限阈值（mmHg） |
| `diastolicUpperLimit` | `UInt8` | 舒张压上限阈值（mmHg） |
| `diastolicLowerLimit` | `UInt8` | 舒张压下限阈值（mmHg） |

### TSAutoMonitorConfigs

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `schedule` | `TSMonitorSchedule *` | 监测计划配置 |
| `alert` | `TSMonitorAlert *` | 告警配置 |

### TSAutoMonitorHRConfigs

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `schedule` | `TSMonitorSchedule *` | 监测计划配置 |
| `restHRAlert` | `TSMonitorAlert *` | 静息心率告警配置 |
| `exerciseHRAlert` | `TSMonitorAlert *` | 运动心率告警配置 |
| `exerciseHRLimitMax` | `UInt8` | 运动心率最大值（用于心率分区计算） |

### TSAutoMonitorBPConfigs

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `schedule` | `TSMonitorSchedule *` | 监测计划配置 |
| `alert` | `TSMonitorBPAlert *` | 血压告警配置 |

## 枚举与常量

### TSItemValueType

| 枚举值 | 数值 | 说明 |
|-------|------|------|
| `TSItemValueTypeNormal` | 0 | 普通原始数据点（自动或手动采集，非派生统计） |
| `TSItemValueTypeMax` | 1 | 当日最大值（由该日普通数据计算得出） |
| `TSItemValueTypeMin` | 2 | 当日最小值（由该日普通数据计算得出） |
| `TSItemValueTypeResting` | 3 | 静息心率（算法基于静息/睡眠时段计算，仅心率使用） |

### TSHealthValueType

| 枚举值 | 数值 | 说明 |
|-------|------|------|
| `TSHealthValueTypeNormal` | 0 | 普通数据 |
| `TSHealthValueTypeMax` | 1 | 最大值 |
| `TSHealthValueTypeMin` | 2 | 最小值 |
| `TSHealthValueTypeResting` | 3 | 静息值（仅心率使用） |

## 回调类型

| 回调类型 | 签名 | 说明 |
|---------|------|------|
| `TSCompletionBlock` | `void (^)(NSError *_Nullable error)` | 操作完成回调，返回错误信息或 nil |
| `TSMeasureDataBlock` | `void (^)(TSHealthValueItem *value)` | 实时测量数据接收回调 |
| 测量数据变化通知 | `void (^)(TSHealthValueItem *_Nullable realtimeData, NSError *_Nullable error)` | 当测量数据接收时触发的回调 |
| 测量结束通知 | `void (^)(BOOL isFinished, NSError *_Nullable error)` | 当测量结束时触发的回调 |

## 接口方法

### 自动监测接口（TSAutoMonitorInterface）

#### 获取心率自动监测配置

```objc
+ (void)fetchHeartRateAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorHRConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorHRConfigs *, NSError *)` | 完成回调，返回心率监测配置或错误信息 |

**代码示例**

```objc
[TSAutoMonitorInterface fetchHeartRateAutoMonitorConfigsWithCompletion:^(`TSAutoMonitorHRConfigs *` _Nullable configs, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"获取心率监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"监测开关: %@", configs.schedule.isEnabled ? @"开启" : @"关闭");
        TSLog(@"开始时间: %d 分钟", configs.schedule.startTime);
        TSLog(@"结束时间: %d 分钟", configs.schedule.endTime);
        TSLog(@"监测间隔: %d 分钟", configs.schedule.interval);
        TSLog(@"最大运动心率: %d bpm", configs.exerciseHRLimitMax);
    }
}];
```

---

#### 推送心率自动监测配置到设备

```objc
+ (void)pushHeartRateAutoMonitorConfig:(`TSAutoMonitorHRConfigs *`)config
                            completion:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSAutoMonitorHRConfigs *` | 要设置的心率自动监测配置 |
| `completion` | `TSCompletionBlock` | 完成回调 |

**代码示例**

```objc
// 创建心率监测配置
TSAutoMonitorHRConfigs *config = [[TSAutoMonitorHRConfigs alloc] init];

// 设置监测计划
config.schedule = [[TSMonitorSchedule alloc] init];
config.schedule.enabled = YES;
config.schedule.startTime = 480;   // 8:00 AM
config.schedule.endTime = 1440;    // 24:00 (午夜)
config.schedule.interval = 15;     // 每15分钟监测一次

// 设置静息心率告警
config.restHRAlert = [[TSMonitorAlert alloc] init];
config.restHRAlert.enabled = YES;
config.restHRAlert.upperLimit = 100;  // 上限 100 bpm
config.restHRAlert.lowerLimit = 50;   // 下限 50 bpm

// 设置运动心率告警
config.exerciseHRAlert = [[TSMonitorAlert alloc] init];
config.exerciseHRAlert.enabled = YES;
config.exerciseHRAlert.upperLimit = 180;  // 上限 180 bpm
config.exerciseHRAlert.lowerLimit = 80;   // 下限 80 bpm

// 设置最大运动心率
config.exerciseHRLimitMax = 190;  // 用于计算心率分区

// 推送配置
[TSAutoMonitorInterface pushHeartRateAutoMonitorConfig:config completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"推送心率监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"心率监测配置已成功推送");
    }
}];
```

---

#### 获取血压自动监测配置

```objc
+ (void)fetchBloodPressureAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorBPConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorBPConfigs *, NSError *)` | 完成回调，返回血压监测配置或错误信息 |

**代码示例**

```objc
[TSAutoMonitorInterface fetchBloodPressureAutoMonitorConfigsWithCompletion:^(`TSAutoMonitorBPConfigs *` _Nullable configs, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"获取血压监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"监测开关: %@", configs.schedule.isEnabled ? @"开启" : @"关闭");
        TSLog(@"收缩压上限: %d mmHg", configs.alert.systolicUpperLimit);
        TSLog(@"收缩压下限: %d mmHg", configs.alert.systolicLowerLimit);
        TSLog(@"舒张压上限: %d mmHg", configs.alert.diastolicUpperLimit);
        TSLog(@"舒张压下限: %d mmHg", configs.alert.diastolicLowerLimit);
    }
}];
```

---

#### 推送血压自动监测配置到设备

```objc
+ (void)pushBloodPressureAutoMonitorConfig:(`TSAutoMonitorBPConfigs *`)config
                                completion:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSAutoMonitorBPConfigs *` | 要设置的血压自动监测配置 |
| `completion` | `TSCompletionBlock` | 完成回调 |

**代码示例**

```objc
// 创建血压监测配置
TSAutoMonitorBPConfigs *config = [[TSAutoMonitorBPConfigs alloc] init];

// 设置监测计划
config.schedule = [[TSMonitorSchedule alloc] init];
config.schedule.enabled = YES;
config.schedule.startTime = 480;   // 8:00 AM
config.schedule.endTime = 1200;    // 20:00 (下午8点)
config.schedule.interval = 30;     // 每30分钟监测一次

// 设置血压告警阈值
config.alert = [[TSMonitorBPAlert alloc] init];
config.alert.enabled = YES;
config.alert.systolicUpperLimit = 140;    // 收缩压上限 140 mmHg
config.alert.systolicLowerLimit = 90;     // 收缩压下限 90 mmHg
config.alert.diastolicUpperLimit = 90;    // 舒张压上限 90 mmHg
config.alert.diastolicLowerLimit = 60;    // 舒张压下限 60 mmHg

// 推送配置
[TSAutoMonitorInterface pushBloodPressureAutoMonitorConfig:config completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"推送血压监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"血压监测配置已成功推送");
    }
}];
```

---

#### 获取血氧自动监测配置

```objc
+ (void)fetchBloodOxygenAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | 完成回调，返回血氧监测配置或错误信息 |

**代码示例**

```objc
[TSAutoMonitorInterface fetchBloodOxygenAutoMonitorConfigsWithCompletion:^(`TSAutoMonitorConfigs *` _Nullable configs, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"获取血氧监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"血氧上限: %d %%", configs.alert.upperLimit);
        TSLog(@"血氧下限: %d %%", configs.alert.lowerLimit);
    }
}];
```

---

#### 推送血氧自动监测配置到设备

```objc
+ (void)pushBloodOxygenAutoMonitorConfig:(`TSAutoMonitorConfigs *`)config
                            completion:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSAutoMonitorConfigs *` | 要设置的血氧自动监测配置 |
| `completion` | `TSCompletionBlock` | 完成回调 |

**代码示例**

```objc
// 创建血氧监测配置
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];

// 设置监测计划
config.schedule = [[TSMonitorSchedule alloc] init];
config.schedule.enabled = YES;
config.schedule.startTime = 480;   // 8:00 AM
config.schedule.endTime = 1440;    // 24:00 (午夜)
config.schedule.interval = 60;     // 每60分钟监测一次

// 设置血氧告警阈值
config.alert = [[TSMonitorAlert alloc] init];
config.alert.enabled = YES;
config.alert.upperLimit = 100;     // 上限 100%
config.alert.lowerLimit = 95;      // 下限 95%

// 推送配置
[TSAutoMonitorInterface pushBloodOxygenAutoMonitorConfig:config completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"推送血氧监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"血氧监测配置已成功推送");
    }
}];
```

---

#### 获取压力自动监测配置

```objc
+ (void)fetchStressAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | 完成回调，返回压力监测配置或错误信息 |

**代码示例**

```objc
[TSAutoMonitorInterface fetchStressAutoMonitorConfigsWithCompletion:^(`TSAutoMonitorConfigs *` _Nullable configs, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"获取压力监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"压力上限: %d", configs.alert.upperLimit);
        TSLog(@"压力下限: %d", configs.alert.lowerLimit);
    }
}];
```

---

#### 推送压力自动监测配置到设备

```objc
+ (void)pushStressAutoMonitorConfig:(`TSAutoMonitorConfigs *`)config
                            completion:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSAutoMonitorConfigs *` | 要设置的压力自动监测配置 |
| `completion` | `TSCompletionBlock` | 完成回调 |

**代码示例**

```objc
// 创建压力监测配置
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];

// 设置监测计划
config.schedule = [[TSMonitorSchedule alloc] init];
config.schedule.enabled = YES;
config.schedule.startTime = 480;   // 8:00 AM
config.schedule.endTime = 1440;    // 24:00 (午夜)
config.schedule.interval = 30;     // 每30分钟监测一次

// 设置压力告警阈值
config.alert = [[TSMonitorAlert alloc] init];
config.alert.enabled = YES;
config.alert.upperLimit = 75;      // 上限 75（高压力）
config.alert.lowerLimit = 25;      // 下限 25（低压力）

// 推送配置
[TSAutoMonitorInterface pushStressAutoMonitorConfig:config completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"推送压力监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"压力监测配置已成功推送");
    }
}];
```

---

#### 获取体温自动监测配置

```objc
+ (void)fetchTemperatureAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorConfigs *_Nullable configs, NSError *_Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | 完成回调，返回体温监测配置或错误信息 |

**代码示例**

```objc
[TSAutoMonitorInterface fetchTemperatureAutoMonitorConfigsWithCompletion:^(`TSAutoMonitorConfigs *` _Nullable configs, `NSError *` _Nullable error) {
    if (error) {
        TSLog(@"获取体温监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"体温上限: %.1f°C", configs.alert.upperLimit / 10.0);
        TSLog(@"体温下限: %.1f°C", configs.alert.lowerLimit / 10.0);
    }
}];
```

---

#### 推送体温自动监测配置到设备

```objc
+ (void)pushTemperatureAutoMonitorConfig:(`TSAutoMonitorConfigs *`)config
                            completion:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `config` | `TSAutoMonitorConfigs *` | 要设置的体温自动监测配置 |
| `completion` | `TSCompletionBlock` | 完成回调 |

**代码示例**

```objc
// 创建体温监测配置
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];

// 设置监测计划
config.schedule = [[TSMonitorSchedule alloc] init];
config.schedule.enabled = YES;
config.schedule.startTime = 480;   // 8:00 AM
config.schedule.endTime = 1440;    // 24:00 (午夜)
config.schedule.interval = 60;     // 每60分钟监测一次

// 设置体温告警阈值（假设以 0.1°C 为单位存储）
config.alert = [[TSMonitorAlert alloc] init];
config.alert.enabled = YES;
config.alert.upperLimit = 380;     // 38.0°C
config.alert.lowerLimit = 360;     // 36.0°C

// 推送配置
[TSAutoMonitorInterface pushTemperatureAutoMonitorConfig:config completion:^(`NSError *` _Nullable error) {
    if (error) {
        TSLog(@"推送体温监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"体温监测配置已成功推送");
    }
}];
```

---

## 注意事项

1. **监测计划时间格式**
   时间以分钟数表示，距离午夜（00:00）的偏移量。例如，480 表示 08:00，1200 表示 20:00。有效范围为 0-1440。

2. **监测间隔的要求**
   监测间隔（`TSMonitor
