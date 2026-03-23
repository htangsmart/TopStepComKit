---
sidebar_position: 3
title: 闹钟
---

# 闹钟 (TSAlarmClock)

闹钟模块提供设备闹钟的管理功能，包括读取、设置和监听闹钟设置变化。支持多个闹钟、自定义标签、重复设置等功能。

## 前提条件

- 设备必须支持闹钟功能（通过 `supportMaxAlarmCount` 方法检查）
- 已建立与设备的连接
- 已完成 SDK 初始化

## 数据模型

### TSAlarmClockModel

闹钟模型类，用于表示设备闹钟的信息。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `alarmId` | `UInt8` | 设备端分配的闹钟唯一标识符，有效范围：0-255 |
| `identifier` | `NSString *` | APP端生成的闹钟唯一标识符，用于在APP内识别和管理闹钟 |
| `label` | `NSString *` | 闹钟的显示名称，示例："起床"、"吃药"等，最大长度：32字节 |
| `time` | `NSDateComponents *` | 闹钟的时间设置，其中hour：0-23（24小时制），minute：0-59 |
| `isOn` | `BOOL` | 闹钟的开关状态，YES表示启用，NO表示禁用 |
| `supportRemindLater` | `BOOL` | 是否支持贪睡功能，YES表示支持，NO表示不支持 |
| `remark` | `NSString *` | 闹钟的附加说明信息，用于存储额外信息，最大长度由 `supportMaxAlarmRemarkLength` 方法获取 |
| `repeatOptions` | `TSAlarmRepeat` | 闹钟重复选项，使用位掩码表示重复日期 |

## 枚举与常量

### TSAlarmRepeat

闹钟重复选项（位掩码）。可以组合使用多个值来表示在多个日期重复。

| 枚举值 | 说明 |
|--------|------|
| `TSAlarmRepeatNone` | 不重复 |
| `TSAlarmRepeatMonday` | 周一重复 |
| `TSAlarmRepeatTuesday` | 周二重复 |
| `TSAlarmRepeatWednesday` | 周三重复 |
| `TSAlarmRepeatThursday` | 周四重复 |
| `TSAlarmRepeatFriday` | 周五重复 |
| `TSAlarmRepeatSaturday` | 周六重复 |
| `TSAlarmRepeatSunday` | 周日重复 |
| `TSAlarmRepeatWorkday` | 工作日重复（周一至周五） |
| `TSAlarmRepeatWeekend` | 周末重复（周六、周日） |
| `TSAlarmRepeatEveryday` | 每天重复 |

## 回调类型

### TSAlarmClockResultBlock

闹钟操作回调块类型。

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `allAlarmClocks` | `NSArray<TSAlarmClockModel *> *` | 闹钟数组，包含当前所有闹钟设置 |
| `error` | `NSError *` | 操作失败时的错误对象，成功时为nil |

此回调块用于多种闹钟操作，包括获取所有闹钟、设置闹钟、监听闹钟变化。

## 接口方法

### 获取设备支持的最大闹钟数量

获取设备支持的闹钟数量上限。

```objc
- (NSInteger)supportMaxAlarmCount;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| 返回值 | `NSInteger` | 设备支持的最大闹钟数量，返回0表示设备不支持闹钟功能 |

**代码示例：**

```objc
id<TSAlarmClockInterface> alarmClock = [TopStepComKit sharedInstance].alarmClock;

NSInteger maxCount = [alarmClock supportMaxAlarmCount];
if (maxCount > 0) {
    TSLog(@"设备支持最多 %ld 个闹钟", (long)maxCount);
} else {
    TSLog(@"设备不支持闹钟功能");
}
```

### 获取闹钟标签的最大字节长度限制

获取闹钟标签（remark）允许的最大字节长度。

```objc
- (NSInteger)supportMaxAlarmRemarkLength;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| 返回值 | `NSInteger` | 闹钟标签的最大字节长度，返回0表示设备不支持闹钟标签 |

**代码示例：**

```objc
id<TSAlarmClockInterface> alarmClock = [TopStepComKit sharedInstance].alarmClock;

NSInteger maxLength = [alarmClock supportMaxAlarmRemarkLength];
if (maxLength > 0) {
    TSLog(@"闹钟标签最多支持 %ld 字节", (long)maxLength);
} else {
    TSLog(@"设备不支持闹钟标签");
}
```

### 从设备获取所有闹钟

读取设备上的所有闹钟设置。

```objc
- (void)getAllAlarmClocksCompletion:(_Nullable TSAlarmClockResultBlock)completion;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSAlarmClockResultBlock` | 返回所有闹钟或错误的回调块 |

**代码示例：**

```objc
id<TSAlarmClockInterface> alarmClock = [TopStepComKit sharedInstance].alarmClock;

[alarmClock getAllAlarmClocksCompletion:^(NSArray<TSAlarmClockModel *> *allAlarmClocks, NSError *error) {
    if (error) {
        TSLog(@"获取闹钟失败：%@", error.localizedDescription);
        return;
    }
    
    if (allAlarmClocks.count == 0) {
        TSLog(@"设备上未设置任何闹钟");
        return;
    }
    
    for (TSAlarmClockModel *alarm in allAlarmClocks) {
        TSLog(@"闹钟ID: %d, 时间: %02ld:%02ld, 标签: %@, 启用: %@",
              alarm.alarmId,
              (long)alarm.hour,
              (long)alarm.minute,
              alarm.label ?: @"无",
              alarm.isOn ? @"是" : @"否");
    }
}];
```

### 设置所有闹钟到设备

将闹钟配置同步到设备，覆盖所有现有设置。

```objc
- (void)setAllAlarmClocks:(NSArray<TSAlarmClockModel *> *_Nullable)allAlarmClocks
               completion:(TSCompletionBlock)completion;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `allAlarmClocks` | `NSArray<TSAlarmClockModel *> *` | 要设置的闹钟数组，传nil或空数组将清除所有闹钟 |
| `completion` | `TSCompletionBlock` | 设置操作完成后的回调块 |

**代码示例：**

```objc
id<TSAlarmClockInterface> alarmClock = [TopStepComKit sharedInstance].alarmClock;

// 创建第一个闹钟
TSAlarmClockModel *alarm1 = [[TSAlarmClockModel alloc] init];
alarm1.alarmId = 0;
alarm1.identifier = @"alarm_001";
alarm1.label = @"起床";
alarm1.isOn = YES;
[alarm1 setHour:7 minute:0];
alarm1.repeatOptions = TSAlarmRepeatWorkday;  // 工作日重复
alarm1.remark = @"早上7点起床";

// 创建第二个闹钟
TSAlarmClockModel *alarm2 = [[TSAlarmClockModel alloc] init];
alarm2.alarmId = 1;
alarm2.identifier = @"alarm_002";
alarm2.label = @"吃药";
alarm2.isOn = YES;
[alarm2 setHour:12 minute:30];
alarm2.repeatOptions = TSAlarmRepeatEveryday;  // 每天重复
alarm2.supportRemindLater = YES;

// 设置闹钟数组
NSArray *alarmArray = @[alarm1, alarm2];

[alarmClock setAllAlarmClocks:alarmArray completion:^(NSError *error) {
    if (error) {
        TSLog(@"设置闹钟失败：%@", error.localizedDescription);
        return;
    }
    TSLog(@"闹钟设置成功");
}];
```

### 注册闹钟变化通知

监听设备闹钟设置的变化。

```objc
- (void)registerAlarmClocksDidChangedBlock:(_Nullable TSAlarmClockResultBlock)completion;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSAlarmClockResultBlock` | 闹钟设置发生变化时触发的回调块 |

**代码示例：**

```objc
id<TSAlarmClockInterface> alarmClock = [TopStepComKit sharedInstance].alarmClock;

[alarmClock registerAlarmClocksDidChangedBlock:^(NSArray<TSAlarmClockModel *> *allAlarmClocks, NSError *error) {
    if (error) {
        TSLog(@"监听闹钟变化失败：%@", error.localizedDescription);
        return;
    }
    
    TSLog(@"闹钟设置已更新，当前闹钟数量：%lu", (unsigned long)allAlarmClocks.count);
    
    for (TSAlarmClockModel *alarm in allAlarmClocks) {
        TSLog(@"闹钟 ID: %d, 时间: %02ld:%02ld, 状态: %@",
              alarm.alarmId,
              (long)alarm.hour,
              (long)alarm.minute,
              alarm.isOn ? @"启用" : @"禁用");
    }
}];
```

### 获取闹钟小时值

获取闹钟对象的小时值。

```objc
- (NSInteger)hour;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| 返回值 | `NSInteger` | 24小时制的小时值（0-23） |

**代码示例：**

```objc
TSAlarmClockModel *alarm = ...; // 获取闹钟对象

NSInteger hour = [alarm hour];
TSLog(@"闹钟时间：%ld 点", (long)hour);
```

### 获取闹钟分钟值

获取闹钟对象的分钟值。

```objc
- (NSInteger)minute;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| 返回值 | `NSInteger` | 分钟值（0-59） |

**代码示例：**

```objc
TSAlarmClockModel *alarm = ...; // 获取闹钟对象

NSInteger minute = [alarm minute];
TSLog(@"闹钟分钟：%ld 分", (long)minute);
```

### 设置闹钟时间

设置闹钟的小时和分钟值。

```objc
- (void)setHour:(NSInteger)hour minute:(NSInteger)minute;
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `hour` | `NSInteger` | 24小时制的小时值（0-23），超出范围会自动调整 |
| `minute` | `NSInteger` | 分钟值（0-59），超出范围会自动调整 |

**代码示例：**

```objc
TSAlarmClockModel *alarm = [[TSAlarmClockModel alloc] init];

// 设置闹钟时间为 06:30
[alarm setHour:6 minute:30];

// 尝试设置无效值，会自动调整
[alarm setHour:25 minute:70];  // 自动调整为 23:59
TSLog(@"调整后的时间：%ld:%02ld", (long)alarm.hour, (long)alarm.minute);

// 获取设置后的时间
NSInteger hour = [alarm hour];
NSInteger minute = [alarm minute];
TSLog(@"闹钟时间：%ld:%02ld", (long)hour, (long)minute);
```

## 注意事项

1. **检查设备支持情况**：在使用闹钟功能前，始终调用 `supportMaxAlarmCount` 检查设备是否支持闹钟，如果返回0则设备不支持。

2. **闹钟数量限制**：不要尝试设置超过 `supportMaxAlarmCount` 返回值数量的闹钟，超出部分会被设备忽略。

3. **标签和备注长度限制**：
   - `label` 属性最大长度为32字节
   - `remark` 属性的最大长度由 `supportMaxAlarmRemarkLength` 方法返回
   - 中文字符在UTF-8编码中通常占3字节，需特别注意长度验证

4. **时间设置自动调整**：调用 `setHour:minute:` 时，如果传入无效值（小时>23或分钟>59），系统会自动调整到有效范围。

5. **重复选项使用**：`repeatOptions` 属性支持位掩码组合，可使用 `|` 操作符组合多个选项，例如 `TSAlarmRepeatMonday | TSAlarmRepeatWednesday` 表示周一和周三重复。

6. **监听器替换**：通过 `registerAlarmClocksDidChangedBlock:` 注册新的监听器时会替换之前的监听器，同一时间只能有一个监听器活跃。

7. **全量覆盖**：调用 `setAllAlarmClocks:completion:` 会覆盖设备上所有现有的闹钟设置，如果需要修改某个闹钟，必须先获取所有闹钟、修改后再设置全量。

8. **错误处理**：所有异步操作都应检查返回的 `error` 参数，不要假设操作一定成功。

9. **连接状态**：闹钟操作需要维持与设备的连接，连接断开会导致操作失败。

10. **标识符管理**：`identifier` 属性是APP端维护的标识符，用于在APP内跟踪和管理闹钟，与设备端的 `alarmId` 不同，两者需分开处理。
