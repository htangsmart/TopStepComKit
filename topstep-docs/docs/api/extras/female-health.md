---
sidebar_position: 3
title: 女性健康
---

# 女性健康（TSFemaleHealth）

提供女性健康配置管理功能，支持月经周期、备孕、孕期等多种追踪模式，包括周期参数设置、提醒配置和实时监听等功能。

## 前提条件

- 已成功连接到支持女性健康功能的设备
- 设备固件版本支持女性健康模块
- 拥有相应的权限访问女性健康数据

## 数据模型

### TSFemaleHealthConfig（女性健康配置模型）

女性健康配置模型，包含健康追踪模式、月经周期信息、提醒设置和孕期追踪信息。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `healthMode` | `TSFemaleHealthMode` | 女性健康追踪模式（关闭、经期、备孕、孕期） |
| `reminderTimeMinutes` | `NSInteger` | 提醒时间相对于午夜的分钟偏移量（0-1439） |
| `reminderAdvanceDays` | `NSInteger` | 提前提醒天数（通常 0-7 天） |
| `pregnancyReminderType` | `TSPregnancyReminderType` | 孕期提醒类型（怀孕天数或预产期倒计时） |
| `menstrualCycleLength` | `NSInteger` | 月经周期长度（天，通常 21-35 天） |
| `menstrualPeriodDuration` | `NSInteger` | 经期长度（天，通常 3-7 天） |
| `lastPeriodStartTimestamp` | `NSTimeInterval` | 最近一次经期开始日期的 Unix 时间戳（秒） |
| `menstruationEndDayInCycle` | `NSInteger` | 月经结束是周期的第几天（1-7 或 0 表示未开始） |
| `reminderSwitches` | `TSFemaleHealthReminderSwitch` | 女性健康提醒开关（可用位标志组合） |

## 枚举与常量

### TSFemaleHealthMode（女性健康模式）

女性健康追踪的不同模式。

| 值 | 说明 |
|----|------|
| `TSFemaleHealthModeDisabled` | 功能关闭 |
| `TSFemaleHealthModeMenstruation` | 经期模式，用于追踪月经周期 |
| `TSFemaleHealthModePregnancyPreparation` | 备孕模式，用于备孕期间追踪 |
| `TSFemaleHealthModePregnancy` | 孕期模式，用于追踪怀孕进度 |

### TSPregnancyReminderType（孕期提醒类型）

孕期模式下的提醒类型定义。

| 值 | 说明 |
|----|------|
| `TSPregnancyReminderTypePregnancyDays` | 基于怀孕天数（自受孕以来的天数）的提醒 |
| `TSPregnancyReminderTypeDueDateDays` | 基于距离预产期天数的提醒 |

### TSFemaleHealthReminderSwitch（提醒开关）

女性健康提醒开关的位标志，支持使用按位或操作组合多个提醒。

| 值 | 说明 |
|----|------|
| `TSFemaleHealthReminderSwitchNone` | 无提醒 |
| `TSFemaleHealthReminderSwitchMenstruationStart` | 经期开始提醒开关，固定时间为经期前一天上午 8 点 |
| `TSFemaleHealthReminderSwitchMenstruationEnd` | 经期结束提醒开关，固定时间为经期结束当天上午 8 点 |
| `TSFemaleHealthReminderSwitchFertileWindowStart` | 易孕期开始提醒开关，固定时间为易孕期开始当天上午 8 点 |
| `TSFemaleHealthReminderSwitchFertileWindowEnd` | 易孕期结束提醒开关，固定时间为易孕期结束当天上午 8 点 |
| `TSFemaleHealthReminderSwitchAll` | 所有提醒开关已启用 |

## 回调类型

### TSFemaleHealthConfigDidChangedBlock

女性健康配置变化回调块类型。

| 参数 | 类型 | 说明 |
|------|------|------|
| `femaleHealthConfig` | `TSFemaleHealthConfig * _Nullable` | 更新后的女性健康配置模型，发生错误时为 nil |
| `error` | `NSError * _Nullable` | 错误信息，成功时为 nil |

## 接口方法

### 获取女性健康配置

从已连接的设备获取当前女性健康配置信息。

```objc
- (void)fetchFemaleHealthConfigWithCompletion:(void(^)(TSFemaleHealthConfig * _Nullable femaleHealthConfig, NSError * _Nullable error))completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSFemaleHealthConfig *, NSError *)` | 回调块，返回女性健康配置和可能发生的错误 |

**代码示例**

```objc
id<TSFemaleHealthInterface> femaleHealthInterface = [TopStepComKit sharedInstance].femaleHealth;

[femaleHealthInterface fetchFemaleHealthConfigWithCompletion:^(TSFemaleHealthConfig * _Nullable femaleHealthConfig, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取女性健康配置失败: %@", error.localizedDescription);
        return;
    }
    
    if (femaleHealthConfig) {
        TSLog(@"健康模式: %ld", (long)femaleHealthConfig.healthMode);
        TSLog(@"月经周期: %ld 天", (long)femaleHealthConfig.menstrualCycleLength);
        TSLog(@"经期长度: %ld 天", (long)femaleHealthConfig.menstrualPeriodDuration);
        TSLog(@"提醒时间: %ld 分钟偏移", (long)femaleHealthConfig.reminderTimeMinutes);
    }
}];
```

### 向设备推送女性健康配置

将女性健康配置推送到已连接的设备。

```objc
- (void)pushFemaleHealthConfig:(TSFemaleHealthConfig * _Nonnull)femaleHealthConfig
                    completion:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `femaleHealthConfig` | `TSFemaleHealthConfig *` | 要设置的女性健康配置（不能为 nil） |
| `completion` | `TSCompletionBlock` | 操作完成后的回调块 |

**代码示例**

```objc
// 创建女性健康配置
TSFemaleHealthConfig *config = [[TSFemaleHealthConfig alloc] init];
config.healthMode = TSFemaleHealthModeMenstruation;
config.menstrualCycleLength = 28;
config.menstrualPeriodDuration = 5;
config.reminderTimeMinutes = 480;  // 8:00 AM
config.reminderAdvanceDays = 1;
config.reminderSwitches = TSFemaleHealthReminderSwitchMenstruationStart | 
                          TSFemaleHealthReminderSwitchMenstruationEnd;

// 获取接口
id<TSFemaleHealthInterface> femaleHealthInterface = [TopStepComKit sharedInstance].femaleHealth;

// 推送配置到设备
[femaleHealthInterface pushFemaleHealthConfig:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"推送女性健康配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"女性健康配置已成功推送到设备");
    }
}];
```

### 注册女性健康配置变化监听

监听设备女性健康配置的变化，当设备端配置被修改时触发回调。

```objc
- (void)registerFemaleHealthConfigDidChangedBlock:(nullable TSFemaleHealthConfigDidChangedBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSFemaleHealthConfigDidChangedBlock` | 女性健康配置发生变化时触发的回调块，传入 nil 可以取消注册 |

**代码示例**

```objc
id<TSFemaleHealthInterface> femaleHealthInterface = [TopStepComKit sharedInstance].femaleHealth;

[femaleHealthInterface registerFemaleHealthConfigDidChangedBlock:^(TSFemaleHealthConfig * _Nullable femaleHealthConfig, NSError * _Nullable error) {
    if (error) {
        TSLog(@"女性健康配置监听出错: %@", error.localizedDescription);
        return;
    }
    
    if (femaleHealthConfig) {
        TSLog(@"女性健康配置已更新");
        TSLog(@"当前健康模式: %ld", (long)femaleHealthConfig.healthMode);
        TSLog(@"提醒时间: %ld 分钟偏移", (long)femaleHealthConfig.reminderTimeMinutes);
        TSLog(@"提醒开关: %ld", (long)femaleHealthConfig.reminderSwitches);
    }
}];
```

### 取消注册女性健康配置变化监听

移除已注册的女性健康配置变化监听器。

```objc
- (void)unregisterFemaleHealthConfigDidChangedBlock;
```

**代码示例**

```objc
id<TSFemaleHealthInterface> femaleHealthInterface = [TopStepComKit sharedInstance].femaleHealth;

// 停止接收女性健康配置变化通知
[femaleHealthInterface unregisterFemaleHealthConfigDidChangedBlock];

TSLog(@"已取消女性健康配置变化监听");
```

## 注意事项

1. **配置参数范围**：月经周期长度通常为 21-35 天，经期长度通常为 3-7 天，提醒时间偏移范围为 0-1439 分钟（对应 0:00-23:59）
2. **空值处理**：`pushFemaleHealthConfig:completion:` 方法的 `femaleHealthConfig` 参数不能为 nil，否则会导致错误
3. **时间戳格式**：`lastPeriodStartTimestamp` 使用 Unix 时间戳（秒），应表示日期的 00:00:00 时刻
4. **提醒开关组合**：`reminderSwitches` 属性支持使用按位或操作组合多个提醒开关，例如 `TSFemaleHealthReminderSwitchMenstruationStart | TSFemaleHealthReminderSwitchMenstruationEnd`
5. **孕期提醒类型**：`pregnancyReminderType` 属性仅在 `healthMode` 设置为 `TSFemaleHealthModePregnancy` 时有效
6. **监听回调**：调用 `registerFemaleHealthConfigDidChangedBlock:` 时传入 nil 等同于调用 `unregisterFemaleHealthConfigDidChangedBlock`，用于取消监听
7. **功能兼容性**：提醒开关功能可能不被所有项目支持，请根据实际项目情况确认
8. **设备连接**：所有操作都需要在设备成功连接的状态下进行，否则会返回连接相关的错误