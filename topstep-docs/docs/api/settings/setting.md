---
sidebar_position: 5
title: 设备设置
---

# 设备设置 (TSSetting)

该模块定义了设备的基本设置操作，包括佩戴习惯、提醒设置、显示设置等功能。所有设置都会持久化保存在设备中，关机后仍然保留。

## 前提条件

1. 已通过 `TopStepComKit` 完成 SDK 初始化
2. 已与设备建立蓝牙连接
3. 已完成 SDK 初始化

## 数据模型

### TSWristWakeUpModel

抬腕亮屏设置模型，用于配置设备的抬腕唤醒屏幕功能。

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `isEnable` | `BOOL` | 抬腕亮屏功能的启用状态。YES 表示功能已启用，NO 表示功能已禁用 |
| `startTime` | `NSInteger` | 抬腕亮屏时间段的开始时间，为从 00:00 开始的分钟数（有效范围：0-1439）。例如 480 表示 08:00 |
| `endTime` | `NSInteger` | 抬腕亮屏时间段的结束时间，为从 00:00 开始的分钟数（有效范围：0-1439）。例如 1320 表示 22:00，必须大于 startTime |

### TSDoNotDisturbModel

勿扰模式配置模型，用于配置设备的勿扰模式，包括全天模式和时段模式。

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `isEnabled` | `BOOL` | 是否启用勿扰模式。YES 表示已启用，NO 表示已禁用 |
| `isTimePeriodMode` | `BOOL` | 是否使用时段模式。YES 表示时段模式（指定时间内勿扰），NO 表示全天模式（24 小时勿扰） |
| `startTime` | `NSInteger` | 勿扰模式的开始时间，为从 00:00 开始的分钟数（有效范围：0-1440）。仅在时段模式下有效，必须小于 endTime |
| `endTime` | `NSInteger` | 勿扰模式的结束时间，为从 00:00 开始的分钟数（有效范围：0-1440）。仅在时段模式下有效，必须大于 startTime |

## 枚举与常量

### TSWearingHabit

设备佩戴习惯类型，定义设备佩戴在哪只手上。此设置会影响屏幕方向、手势识别和抬腕检测。

| 枚举值 | 说明 |
|--------|------|
| `TSWearingHabitLeft` | 左手佩戴 |
| `TSWearingHabitRight` | 右手佩戴 |

## 接口方法

### 设置设备佩戴习惯

```objc
- (void)setWearingHabit:(TSWearingHabit)habit
             completion:(TSCompletionBlock)completion;
```

设置设备佩戴在哪只手上。此设置会影响屏幕显示方向、手势识别方向和抬腕检测。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `habit` | `TSWearingHabit` | 佩戴习惯设置。TSWearingHabitLeft 表示左手佩戴，TSWearingHabitRight 表示右手佩戴 |
| `completion` | `TSCompletionBlock` | 设置完成回调，返回设置是否成功和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting setWearingHabit:TSWearingHabitRight 
                       completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"佩戴习惯设置成功");
    } else {
        TSLog(@"佩戴习惯设置失败: %@", error.localizedDescription);
    }
}];
```

### 获取当前佩戴习惯

```objc
- (void)getCurrentWearingHabit:(void(^)(TSWearingHabit habit, NSError * _Nullable error))completion;
```

从设备获取当前的佩戴习惯设置。用于应用初始化、验证设置更改或同步设置时使用。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `void (^)(TSWearingHabit habit, NSError *)` | 获取完成回调，返回当前佩戴习惯和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getCurrentWearingHabit:^(TSWearingHabit habit, NSError *error) {
    if (error == nil) {
        NSString *habitStr = (habit == TSWearingHabitLeft) ? @"左手" : @"右手";
        TSLog(@"当前佩戴习惯: %@", habitStr);
    } else {
        TSLog(@"获取佩戴习惯失败: %@", error.localizedDescription);
    }
}];
```

### 设置蓝牙断连震动

```objc
- (void)setBluetoothDisconnectionVibration:(BOOL)enabled
                               completion:(TSCompletionBlock)completion;
```

控制蓝牙连接断开时设备是否震动。此功能帮助用户注意到设备超出蓝牙范围、手机蓝牙被关闭或连接被干扰中断。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `enabled` | `BOOL` | 是否启用蓝牙断连震动。YES 表示启用，NO 表示禁用 |
| `completion` | `TSCompletionBlock` | 设置完成回调，返回设置是否成功和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting setBluetoothDisconnectionVibration:YES 
                                         completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"蓝牙断连震动已启用");
    } else {
        TSLog(@"设置蓝牙断连震动失败: %@", error.localizedDescription);
    }
}];
```

### 获取蓝牙断连震动状态

```objc
- (void)getBluetoothDisconnectionVibrationStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;
```

获取当前的蓝牙断连震动设置。用于初始化应用设置显示、验证设置更改或同步设置。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `void (^)(BOOL enabled, NSError *)` | 获取完成回调，返回蓝牙断连震动状态和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getBluetoothDisconnectionVibrationStatus:^(BOOL enabled, NSError *error) {
    if (error == nil) {
        TSLog(@"蓝牙断连震动状态: %@", enabled ? @"启用" : @"禁用");
    } else {
        TSLog(@"获取蓝牙断连震动状态失败: %@", error.localizedDescription);
    }
}];
```

### 设置运动目标达成提醒

```objc
- (void)setExerciseGoalReminder:(BOOL)enabled
                    completion:(TSCompletionBlock)completion;
```

控制达到运动目标时设备是否提醒。提醒包括震动提醒、屏幕显示和成就消息。目标包括步数、卡路里和距离目标。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `enabled` | `BOOL` | 是否启用运动目标提醒。YES 表示启用，NO 表示禁用 |
| `completion` | `TSCompletionBlock` | 设置完成回调，返回设置是否成功和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting setExerciseGoalReminder:YES 
                              completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"运动目标提醒已启用");
    } else {
        TSLog(@"设置运动目标提醒失败: %@", error.localizedDescription);
    }
}];
```

### 获取运动目标提醒状态

```objc
- (void)getExerciseGoalReminderStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;
```

获取当前的运动目标提醒设置。用于初始化应用设置显示、验证设置更改或同步设置。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `void (^)(BOOL enabled, NSError *)` | 获取完成回调，返回运动目标提醒状态和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getExerciseGoalReminderStatus:^(BOOL enabled, NSError *error) {
    if (error == nil) {
        TSLog(@"运动目标提醒状态: %@", enabled ? @"启用" : @"禁用");
    } else {
        TSLog(@"获取运动目标提醒状态失败: %@", error.localizedDescription);
    }
}];
```

### 设置来电响铃

```objc
- (void)setCallRing:(BOOL)enabled
         completion:(TSCompletionBlock)completion;
```

控制设备对来电的响应行为。启用时，设备会使用默认铃声响铃、震动，并在屏幕显示来电信息。需要蓝牙连接和通话权限。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `enabled` | `BOOL` | 是否启用来电响铃。YES 表示启用，NO 表示禁用 |
| `completion` | `TSCompletionBlock` | 设置完成回调，返回设置是否成功和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting setCallRing:YES 
                  completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"来电响铃已启用");
    } else {
        TSLog(@"设置来电响铃失败: %@", error.localizedDescription);
    }
}];
```

### 获取来电响铃状态

```objc
- (void)getCallRingStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;
```

获取当前的来电响铃设置。用于初始化应用设置显示、验证设置更改或同步设置。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `void (^)(BOOL enabled, NSError *)` | 获取完成回调，返回来电响铃状态和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getCallRingStatus:^(BOOL enabled, NSError *error) {
    if (error == nil) {
        TSLog(@"来电响铃状态: %@", enabled ? @"启用" : @"禁用");
    } else {
        TSLog(@"获取来电响铃状态失败: %@", error.localizedDescription);
    }
}];
```

### 设置抬腕亮屏

```objc
- (void)setRaiseWristToWake:(TSWristWakeUpModel *)model
                completion:(TSCompletionBlock)completion;
```

设置设备的抬腕亮屏功能配置，包括启用/禁用和时间段设置。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `model` | `TSWristWakeUpModel *` | 包含抬腕亮屏设置的模型对象。isEnable 表示是否启用，startTime 和 endTime 为时间段（单位：分钟），范围 0-1439，endTime 必须大于 startTime |
| `completion` | `TSCompletionBlock` | 设置完成回调，返回设置是否成功和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

TSWristWakeUpModel *model = [[TSWristWakeUpModel alloc] init];
model.isEnable = YES;
model.startTime = 480;   // 08:00
model.endTime = 1320;    // 22:00

[setting setRaiseWristToWake:model 
                           completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"抬腕亮屏设置成功");
    } else {
        TSLog(@"抬腕亮屏设置失败: %@", error.localizedDescription);
    }
}];
```

### 获取抬腕亮屏设置

```objc
- (void)getRaiseWristToWakeStatus:(void(^)(TSWristWakeUpModel * _Nullable model, 
                                          NSError * _Nullable error))completion;
```

获取当前的抬腕亮屏设置。用于初始化应用设置显示、验证设置更改或同步设置。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `void (^)(TSWristWakeUpModel *, NSError *)` | 获取完成回调，返回当前设置模型和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getRaiseWristToWakeStatus:^(TSWristWakeUpModel *model, NSError *error) {
    if (error == nil && model != nil) {
        TSLog(@"抬腕亮屏已%@，时间段: %ld-%ld", 
              model.isEnable ? @"启用" : @"禁用", 
              (long)model.startTime, 
              (long)model.endTime);
    } else {
        TSLog(@"获取抬腕亮屏设置失败: %@", error.localizedDescription);
    }
}];
```

### 注册抬腕亮屏配置变化监听

```objc
- (void)registerRaiseWristToWakeDidChanged:(void(^)(TSWristWakeUpModel * _Nullable model,
                                                        NSError * _Nullable error))didChangeBlock;
```

注册监听器以接收抬腕亮屏配置变化的通知。可同时注册多个监听器，配置变化时所有监听器都会被调用。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `didChangeBlock` | `void (^)(TSWristWakeUpModel *, NSError *)` | 配置变化时触发的回调块，返回更新后的设置模型和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting registerRaiseWristToWakeDidChanged:^(TSWristWakeUpModel *model, NSError *error) {
    if (error == nil && model != nil) {
        TSLog(@"抬腕亮屏配置已变化: %@-%@", 
              @(model.startTime), 
              @(model.endTime));
    } else {
        TSLog(@"接收配置变化失败: %@", error.localizedDescription);
    }
}];
```

### 设置勿扰模式

```objc
- (void)setDoNotDisturb:(TSDoNotDisturbModel *)model
                 completion:(TSCompletionBlock)completion;
```

设置设备的勿扰模式配置。可配置全天模式或时段模式。此功能帮助用户在特定时间段保持专注，防止不必要的通知和打扰。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `model` | `TSDoNotDisturbModel *` | 包含勿扰模式设置的模型对象。isEnabled 表示是否启用，isTimePeriodMode 表示是否使用时段模式，startTime 和 endTime 为时间段（仅在时段模式下有效，单位：分钟，范围 0-1440） |
| `completion` | `TSCompletionBlock` | 设置完成回调，返回设置是否成功和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

TSDoNotDisturbModel *model = [[TSDoNotDisturbModel alloc] init];
model.isEnabled = YES;
model.isTimePeriodMode = YES;
model.startTime = 720;   // 12:00 (noon)
model.endTime = 840;     // 14:00 (2:00 PM)

[setting setDoNotDisturb:model 
                      completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"勿扰模式设置成功");
    } else {
        TSLog(@"勿扰模式设置失败: %@", error.localizedDescription);
    }
}];
```

### 获取勿扰模式设置

```objc
- (void)getDoNotDisturbInfo:(void(^)(TSDoNotDisturbModel * _Nullable model,
                                          NSError * _Nullable error))completion;
```

获取当前的勿扰模式配置。用于初始化应用设置显示、验证设置更改或同步设置。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `void (^)(TSDoNotDisturbModel *, NSError *)` | 获取完成回调，返回当前设置模型和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getDoNotDisturbInfo:^(TSDoNotDisturbModel *model, NSError *error) {
    if (error == nil && model != nil) {
        if (model.isEnabled) {
            if (model.isTimePeriodMode) {
                TSLog(@"勿扰模式: 时段模式 %ld-%ld", 
                      (long)model.startTime, 
                      (long)model.endTime);
            } else {
                TSLog(@"勿扰模式: 全天模式");
            }
        } else {
            TSLog(@"勿扰模式: 已禁用");
        }
    } else {
        TSLog(@"获取勿扰模式设置失败: %@", error.localizedDescription);
    }
}];
```

### 设置加强监测模式

```objc
- (void)setEnhancedMonitoring:(BOOL)enabled
                    completion:(TSCompletionBlock)completion;
```

启用或禁用设备的加强监测模式。加强监测模式提供更高的监测精度、更频繁的数据采集间隔和更好的数据质量，但会增加电池消耗。此设置影响所有健康监测类型，包括心率、血氧、血压和压力监测。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `enabled` | `BOOL` | 是否启用加强监测模式。YES 表示启用（高精度和频率），NO 表示禁用（标准模式） |
| `completion` | `TSCompletionBlock` | 设置完成回调，返回设置是否成功和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting setEnhancedMonitoring:YES 
                            completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"加强监测模式已启用");
    } else {
        TSLog(@"设置加强监测模式失败: %@", error.localizedDescription);
    }
}];
```

### 获取加强监测模式状态

```objc
- (void)getEnhancedMonitoringStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;
```

获取当前的加强监测模式设置。用于初始化应用设置显示、验证设置更改、同步设置或确定监测行为和数据质量期望。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `void (^)(BOOL enabled, NSError *)` | 获取完成回调，返回加强监测模式状态和错误信息（如果有） |

**代码示例：**

```objc
id<TSSettingInterface> setting = [TopStepComKit sharedInstance].setting;

[setting getEnhancedMonitoringStatus:^(BOOL enabled, NSError *error) {
    if (error == nil) {
        TSLog(@"加强监测模式: %@", enabled ? @"启用" : @"禁用");
    } else {
        TSLog(@"获取加强监测模式状态失败: %@", error.localizedDescription);
    }
}];
```

## 注意事项

1. **蓝牙连接要求** - 所有设置操作都需要与设备保持活跃的蓝牙连接，连接断开时操作将失败

2. **时间段设置** - 在涉及时间段的设置（如抬腕亮屏、勿扰模式）中，结束时间必须大于开始时间，否则设置将被拒绝

3. **时间格式** - 时间以从午夜 00:00 开始的分钟数表示，有效范围为 0-1439（或 1440），例如 480 表示 08:00，1320 表示 22:00

4. **设置持久化** - 所有设置都会立即持久化保存到设备中，设备关闭后仍然保留，无需重复设置

5. **回调线程** - 所有完成回调可能在非主线程中执行，如需更新 UI，应确保在主线程中进行操作

6. **错误处理** - 始终检查回调中的错误对象，nil 表示操作成功，否则根据错误信息判断失败原因

7. **监听器管理** - 注册的配置变化监听器在对象生命周期内保持有效，需要时可注册多个监听器，移除时需使用相同的块引用

8. **加强监测模式** - 启用加强监测模式会增加设备的电池消耗，应根据实际需求权衡精度和续航时间