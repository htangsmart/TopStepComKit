---
sidebar_position: 4
title: 时间设置
---

# 时间设置（TSTime）

TSTime 模块提供设备时间管理功能，支持系统时间同步、指定时间设置等操作。通过该模块，应用可以将手机时间同步到设备，或设置设备为特定时间。时间格式（12/24小时制）通过单位设置模块的 `setTimeFormat:completion:` 方法配置，详见[单位设置](./unit)。

## 前提条件

1. 已导入 TopStepComKit 框架
2. 已完成 SDK 初始化
3. 设备处于已连接状态

## 数据模型

| 模型名称 | 说明 |
|---------|------|
| `TSWorldClockModel` | 世界时钟数据模型，包含时区相关信息 |

## 接口方法

### 设置系统时间到设备

```objc
- (void)setSystemTimeWithCompletion:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSCompletionBlock` | 设置完成的回调，返回操作结果 |

**功能描述**

将手机当前系统时间同步到设备。时间格式（12/24小时制）需通过单位设置模块的 `setTimeFormat:completion:` 方法单独配置。

**代码示例**

```objc
id<TSTimeInterface> time = [TopStepComKit sharedInstance].time;

[time setSystemTimeWithCompletion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"系统时间设置成功");
    } else {
        TSLog(@"系统时间设置失败: %@", error.localizedDescription);
    }
}];
```

---

### 设置指定时间到设备

```objc
- (void)setSpecificTime:(NSDate *)date
             completion:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `date` | `NSDate *` | 要设置的时间 |
| `completion` | `TSCompletionBlock` | 设置完成的回调，返回操作结果 |

**功能描述**

将指定的时间设置到设备。时间格式（12/24小时制）需通过单位设置模块的 `setTimeFormat:completion:` 方法单独配置。

**代码示例**

```objc
id<TSTimeInterface> time = [TopStepComKit sharedInstance].time;

// 创建一个指定时间（2025年2月20日 14:30:00）
NSDateComponents *components = [[NSDateComponents alloc] init];
components.year = 2025;
components.month = 2;
components.day = 20;
components.hour = 14;
components.minute = 30;
components.second = 0;

NSCalendar *calendar = [NSCalendar currentCalendar];
NSDate *targetDate = [calendar dateFromComponents:components];

[time setSpecificTime:targetDate completion:^(NSError * _Nullable error) {
    if (!error) {
        TSLog(@"指定时间设置成功");
    } else {
        TSLog(@"指定时间设置失败: %@", error.localizedDescription);
    }
}];
```

## 注意事项

1. 所有时间设置操作都是异步执行，务必通过 completion 回调获取执行结果
2. 时间格式（12/24小时制）通过单位设置模块的 `setTimeFormat:completion:` 方法配置，与时间同步相互独立
3. 设置时间前确保设备已连接，否则操作将失败
4. 建议在主线程调用这些接口，completion 回调也会在主线程执行
5. 时间设置可能需要一定的延迟才能在设备上生效，不建议频繁调用

