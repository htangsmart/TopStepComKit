---
sidebar_position: 4
title: 提醒
---

# 提醒（TSReminders）

提醒模块用于管理设备上的各类提醒，包括内置提醒（久坐、喝水、吃药）和自定义提醒。支持灵活配置提醒时间、重复周期、免打扰设置等功能。

## 前提条件

1. 已成功初始化 TopStepComKit SDK
2. 设备已连接并处于可用状态
3. 对于自定义提醒，需确保设备支持的自定义提醒数量未达上限

## 数据模型

### TSRemindersModel

提醒数据模型，代表设备上的一个提醒。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `reminderId` | `NSString *` | 提醒的唯一标识符。由系统自动分配，请勿手动修改 |
| `reminderName` | `NSString *` | 提醒的名称 |
| `isEnabled` | `BOOL` | 提醒是否启用 |
| `reminderType` | `TSReminderType` | 提醒的类型（未知、久坐、喝水、吃药、自定义） |
| `repeatDays` | `TSReminderDays` | 提醒重复的星期几，支持位运算组合 |
| `timeType` | `TSReminderTimeType` | 时间类型（时间点或时间段） |
| `startTime` | `NSInteger` | 开始时间（分钟制，从 0 开始。如 360 表示 6:00） |
| `endTime` | `NSInteger` | 结束时间（分钟制，从 0 开始。如 720 表示 12:00） |
| `interval` | `NSInteger` | 提醒间隔（分钟） |
| `timePoints` | `NSArray<NSNumber *> *` | 具体时间点数组，每个元素为从 0 开始的分钟数 |
| `notes` | `NSString *` | 提醒备注信息 |
| `isLunchBreakDNDEnabled` | `BOOL` | 是否启用午休免打扰 |
| `lunchBreakDNDStartTime` | `NSInteger` | 午休免打扰开始时间（分钟制，建议值 720） |
| `lunchBreakDNDEndTime` | `NSInteger` | 午休免打扰结束时间（分钟制，建议值 840） |

## 枚举与常量

### TSReminderType（提醒类型）

| 枚举值 | 说明 |
|--------|------|
| `eTSReminderTypeUnknown` | 未知类型 |
| `eTSReminderTypeSedentary` | 久坐提醒 |
| `eTSReminderTypeDrinking` | 喝水提醒 |
| `eTSReminderTypeTakeMedicine` | 吃药提醒 |
| `eTSReminderTypeCustom` | 自定义提醒 |

### TSReminderDays（提醒重复日期）

| 枚举值 | 说明 |
|--------|------|
| `eTSReminderDayMonday` | 星期一 |
| `eTSReminderDayTuesday` | 星期二 |
| `eTSReminderDayWednesday` | 星期三 |
| `eTSReminderDayThursday` | 星期四 |
| `eTSReminderDayFriday` | 星期五 |
| `eTSReminderDaySaturday` | 星期六 |
| `eTSReminderDaySunday` | 星期日 |
| `eTSReminderRepeatWorkday` | 工作日（周一至周五） |
| `eTSReminderRepeatWeekday` | 周末（周六和周日） |
| `eTSReminderRepeatEveryday` | 每天 |

### TSReminderTimeType（提醒时间类型）

| 枚举值 | 说明 |
|--------|------|
| `eTSReminderTimeTypePeriod` | 时间段类型，使用 `startTime`、`endTime` 和 `interval` |
| `eTSReminderTimeTypePoint` | 时间点类型，使用 `timePoints` 数组 |

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `void (^)(TSRemindersModel * _Nullable reminder, NSError * _Nullable error)` | 返回单个提醒模型和错误信息的回调 |
| `void (^)(NSArray<TSRemindersModel *> *reminders, NSError * _Nullable error)` | 返回提醒模型数组和错误信息的回调 |
| `TSCompletionBlock` | 基础完成回调，仅返回错误信息 |

## 接口方法

### 获取设备支持的最大自定义提醒数量

获取当前设备支持的最大自定义提醒数量。

```objc
- (NSInteger)supportMaxCustomeReminders;
```

**参数**

无

**返回值**

设备支持的最大自定义提醒数量

**代码示例**

```objc
id<TSRemindersInterface> reminders = [TopStepComKit sharedInstance].reminder;
NSInteger maxReminders = [reminders supportMaxCustomeReminders];
TSLog(@"设备支持的最大自定义提醒数量: %ld", (long)maxReminders);
```

### 创建自定义提醒模板

创建一个新的自定义提醒模板。此方法会自动分配唯一 ID 并设置适当的默认值。

```objc
- (void)createCustomReminderTemplateWithCompletion:(void (^)(TSRemindersModel * _Nullable reminder, NSError * _Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(TSRemindersModel * _Nullable reminder, NSError * _Nullable error)` | 完成回调，返回可用的自定义提醒模型和错误信息 |

**代码示例**

```objc
id<TSRemindersInterface> reminders = [TopStepComKit sharedInstance].reminder;

[reminders createCustomReminderTemplateWithCompletion:^(TSRemindersModel * _Nullable reminder, NSError * _Nullable error) {
    if (error) {
        TSLog(@"创建提醒模板失败: %@", error.localizedDescription);
        return;
    }
    
    // 配置提醒属性
    reminder.reminderName = @"运动提醒";
    reminder.isEnabled = YES;
    reminder.repeatDays = eTSReminderRepeatWorkday; // 工作日提醒
    reminder.timeType = eTSReminderTimeTypePoint;
    reminder.timePoints = @[@(480), @(1200)]; // 8:00 和 20:00
    reminder.notes = @"记得去运动";
    
    // 保存提醒到设备
    [reminders updateReminder:reminder completion:^(NSError * _Nullable error) {
        if (error) {
            TSLog(@"保存提醒失败: %@", error.localizedDescription);
        } else {
            TSLog(@"提醒已保存，ID: %@", reminder.reminderId);
        }
    }];
}];
```

### 获取所有提醒设置

获取设备上的所有提醒设置，包括内置和自定义提醒。

```objc
- (void)getAllRemindersWithCompletion:(void (^)(NSArray<TSRemindersModel *> *reminders, NSError * _Nullable error))completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(NSArray<TSRemindersModel *> *reminders, NSError * _Nullable error)` | 完成回调，返回提醒模型数组和错误信息 |

**代码示例**

```objc
id<TSRemindersInterface> reminders = [TopStepComKit sharedInstance].reminder;

[reminders getAllRemindersWithCompletion:^(NSArray<TSRemindersModel *> *reminders, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取提醒失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"共有 %lu 个提醒", (unsigned long)reminders.count);
    for (TSRemindersModel *reminder in reminders) {
        TSLog(@"提醒名称: %@, 启用状态: %@, 类型: %ld",
              reminder.reminderName,
              reminder.isEnabled ? @"启用" : @"禁用",
              (long)reminder.reminderType);
    }
}];
```

### 批量设置提醒

将提醒数组设置到设备上。

```objc
- (void)setReminders:(NSArray<TSRemindersModel *> *)reminders completion:(TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `reminders` | `NSArray<TSRemindersModel *> *` | 提醒对象数组 |
| `completion` | `TSCompletionBlock` | 完成回调，返回错误信息 |

**代码示例**

```objc
id<TSRemindersInterface> reminders = [TopStepComKit sharedInstance].reminder;

// 获取现有提醒
[reminders getAllRemindersWithCompletion:^(NSArray<TSRemindersModel *> *reminders, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取提醒失败: %@", error.localizedDescription);
        return;
    }
    
    // 修改提醒属性
    NSMutableArray *updatedReminders = [NSMutableArray arrayWithArray:reminders];
    if (updatedReminders.count > 0) {
        TSRemindersModel *firstReminder = updatedReminders[0];
        firstReminder.isEnabled = NO;
    }
    
    // 批量设置
    [reminders setReminders:updatedReminders completion:^(NSError * _Nullable error) {
        if (error) {
            TSLog(@"设置提醒失败: %@", error.localizedDescription);
        } else {
            TSLog(@"提醒已设置成功");
        }
    }];
}];
```

### 更新提醒

根据提醒 ID 更新或新增提醒（具备"插入或更新"语义）。

```objc
- (void)updateReminder:(TSRemindersModel *)reminder completion:(TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `reminder` | `TSRemindersModel *` | 包含更新信息的提醒模型 |
| `completion` | `TSCompletionBlock` | 完成回调，返回错误信息 |

**代码示例**

```objc
id<TSRemindersInterface> reminders = [TopStepComKit sharedInstance].reminder;

// 获取所有提醒
[reminders getAllRemindersWithCompletion:^(NSArray<TSRemindersModel *> *reminders, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取提醒失败: %@", error.localizedDescription);
        return;
    }
    
    if (reminders.count > 0) {
        TSRemindersModel *reminder = reminders[0];
        
        // 修改提醒设置
        reminder.reminderName = @"修改后的提醒";
        reminder.isEnabled = YES;
        reminder.timeType = eTSReminderTimeTypePeriod;
        reminder.startTime = 360;    // 6:00
        reminder.endTime = 1200;     // 20:00
        reminder.interval = 60;      // 每小时提醒一次
        reminder.isLunchBreakDNDEnabled = YES;
        reminder.lunchBreakDNDStartTime = 720;
        reminder.lunchBreakDNDEndTime = 840;
        
        // 更新到设备
        [reminders updateReminder:reminder completion:^(NSError * _Nullable error) {
            if (error) {
                TSLog(@"更新提醒失败: %@", error.localizedDescription);
            } else {
                TSLog(@"提醒已更新");
            }
        }];
    }
}];
```

### 删除提醒

根据提醒 ID 删除提醒（仅自定义提醒可删除）。

```objc
- (void)deleteReminderWithId:(NSString *)reminderId completion:(TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `reminderId` | `NSString *` | 要删除的提醒的唯一标识符 |
| `completion` | `TSCompletionBlock` | 完成回调，返回错误信息 |

**代码示例**

```objc
id<TSRemindersInterface> reminders = [TopStepComKit sharedInstance].reminder;

[reminders deleteReminderWithId:@"custom_reminder_001" completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"删除提醒失败: %@", error.localizedDescription);
    } else {
        TSLog(@"提醒已删除");
    }
}];
```

### 验证提醒数组

检查提醒数组中是否存在错误。

```objc
+ (NSError *)doesRemindersHasError:(NSArray<TSRemindersModel *> *)reminders;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `reminders` | `NSArray<TSRemindersModel *> *` | 要验证的提醒模型数组 |

**返回值**

返回第一个发现的错误，如果所有模型都有效则返回 `nil`

**代码示例**

```objc
NSMutableArray *remindersArray = [NSMutableArray array];

// 构建多个提醒
for (NSInteger i = 0; i < 3; i++) {
    TSRemindersModel *reminder = [[TSRemindersModel alloc] init];
    reminder.reminderName = [NSString stringWithFormat:@"提醒%ld", (long)i];
    reminder.isEnabled = YES;
    reminder.repeatDays = eTSReminderRepeatEveryday;
    reminder.timeType = eTSReminderTimeTypePoint;
    reminder.timePoints = @[@(480 + i * 300)];
    [remindersArray addObject:reminder];
}

// 批量验证
NSError *validationError = [TSRemindersModel doesRemindersHasError:remindersArray];
if (validationError) {
    TSLog(@"提醒验证失败: %@", validationError.localizedDescription);
} else {
    TSLog(@"所有提醒验证通过");
}
```

## 注意事项

1. **禁止直接创建实例**：请勿直接使用 `[[TSRemindersModel alloc] init]` 创建提醒实例。应使用 `createCustomReminderTemplateWithCompletion:` 获取自动分配 ID 的提醒模板。

2. **ID 的自动分配**：自定义提醒的 ID 由系统自动分配，请勿手动修改 `reminderId` 属性。

3. **内置提醒的限制**：内置提醒（久坐、喝水、吃药）可以被修改和禁用，但不能被删除。

4. **自定义提醒的管理**：自定义提醒可以完全管理，包括创建、修改和删除。

5. **数量限制**：不同设备型号支持的最大自定义提醒数量不同。使用 `supportMaxCustomeReminders` 方法获取设备支持的最大数量。

6. **时间格式**：所有时间相关属性（`startTime`、`endTime`、`timePoints`）均采用分钟制（0-1439），从 0:00 开始计算。例如 480 表示 8:00，1200 表示 20:00。

7. **重复日期组合**：`repeatDays` 属性支持使用位运算符 `|` 组合多个日期。例如：`eTSReminderDayMonday | eTSReminderDayWednesday | eTSReminderDayFriday` 表示周一、周三、周五。

8. **午休免打扰**：启用午休免打扰后，设备在指定时间段内将不发送该提醒。建议值：开始时间 720（12:00），结束时间 840（14:00）。

9. **批量操作验证**：在批量设置提醒前，应使用 `doesRemindersHasError:` 方法验证提醒数组的有效性。

10. **异步操作处理**：所有提醒操作都是异步执行的，需要在完成回调中处理结果。