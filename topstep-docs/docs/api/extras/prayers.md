---
sidebar_position: 4
title: 祈祷时间
---

# 祈祷时间 (TSPrayers)

本模块提供祈祷功能管理接口，包括祈祷配置设置、祈祷时间管理和配置变化监听等功能。支持对晨礼、晌礼、晡礼、昏礼和宵礼等五大祈祷时间的管理，以及可选的日出和日落时间提醒。

## 前提条件

- 设备已连接且支持祈祷功能
- 应用已获得必要的设备通信权限
- 设备端祈祷功能已安装

## 数据模型

### TSPrayerConfigs

祈祷配置模型，包含祈祷功能总开关和各个祈祷时间提醒开关。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `prayerEnable` | `BOOL` | 祈祷功能总开关。当设置为NO时，所有祈祷时间都被禁用。当设置为YES时，单个祈祷时间开关生效 |
| `fajrReminderEnable` | `BOOL` | 晨礼(Fajr)提醒开关。控制是否接收晨礼提醒。仅在prayerEnable为YES时有效 |
| `sunriseReminderEnable` | `BOOL` | 日出提醒开关。控制是否接收日出时间提醒。仅在prayerEnable为YES时有效，某些项目可能不支持 |
| `dhuhrReminderEnable` | `BOOL` | 晌礼(Dhuhr)提醒开关。控制是否接收晌礼提醒。仅在prayerEnable为YES时有效 |
| `asrReminderEnable` | `BOOL` | 晡礼(Asr)提醒开关。控制是否接收晡礼提醒。仅在prayerEnable为YES时有效 |
| `sunsetReminderEnable` | `BOOL` | 日落提醒开关。控制是否接收日落时间提醒。仅在prayerEnable为YES时有效，某些项目可能不支持 |
| `maghribReminderEnable` | `BOOL` | 昏礼(Maghrib)提醒开关。控制是否接收昏礼提醒。仅在prayerEnable为YES时有效 |
| `ishabReminderEnable` | `BOOL` | 宵礼(Isha)提醒开关。控制是否接收宵礼提醒。仅在prayerEnable为YES时有效 |

### TSPrayerTimes

祈祷时间模型，表示特定日期的祈祷时间数据。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `dayTimestamp` | `NSTimeInterval` | 当天00:00:00的时间戳（Unix时间戳，单位为秒）。是计算所有祈祷时间偏移量的基准 |
| `fajrMinutesOffset` | `NSInteger` | 晨礼时间相对于午夜的分钟偏移量。例如早上5:30为330分钟 |
| `sunriseMinutesOffset` | `NSInteger` | 日出时间相对于午夜的分钟偏移量。例如早上6:00为360分钟。可选，某些项目可能不支持 |
| `dhuhrMinutesOffset` | `NSInteger` | 晌礼时间相对于午夜的分钟偏移量。例如中午12:15为735分钟 |
| `asrMinutesOffset` | `NSInteger` | 晡礼时间相对于午夜的分钟偏移量。例如下午3:45为945分钟 |
| `sunsetMinutesOffset` | `NSInteger` | 日落时间相对于午夜的分钟偏移量。例如晚上6:30为1110分钟。可选，某些项目可能不支持 |
| `maghribMinutesOffset` | `NSInteger` | 昏礼时间相对于午夜的分钟偏移量。例如晚上6:20为1100分钟 |
| `ishaMinutesOffset` | `NSInteger` | 宵礼时间相对于午夜的分钟偏移量。例如晚上8:00为1200分钟 |

## 枚举与常量

### TSPrayerReminderSwitch

祈祷提醒开关枚举，定义各个祈祷时间的提醒开关类型。

| 枚举值 | 数值 | 说明 |
|--------|------|------|
| `TSPrayerReminderSwitchMain` | 0 | 祈祷功能总开关，控制整个祈祷提醒功能是否启用 |
| `TSPrayerReminderSwitchFajr` | 1 | 晨礼提醒开关（日出前的晨间祈祷） |
| `TSPrayerReminderSwitchSunrise` | 2 | 日出提醒开关（可选，某些项目可能不支持） |
| `TSPrayerReminderSwitchDhuhr` | 3 | 晌礼提醒开关（太阳过中天之后） |
| `TSPrayerReminderSwitchAsr` | 4 | 晡礼提醒开关（下午晚些时候） |
| `TSPrayerReminderSwitchSunset` | 5 | 日落提醒开关（可选，某些项目可能不支持） |
| `TSPrayerReminderSwitchMaghrib` | 6 | 昏礼提醒开关（日落后） |
| `TSPrayerReminderSwitchIsha` | 7 | 宵礼提醒开关（黄昏消失后的夜间祈祷） |

## 回调类型

### TSPrayerConfigDidChangedBlock

祈祷配置变化回调块类型。

| 参数 | 类型 | 说明 |
|------|------|------|
| `prayerConfig` | `TSPrayerConfigs * _Nullable` | 更新后的祈祷配置模型。发生错误时为nil |
| `error` | `NSError * _Nullable` | 错误信息。操作成功时为nil |

## 接口方法

### 检查祈祷功能是否已安装

```objc
- (void)checkIfPrayerIsInstalled:(void (^)(BOOL isInstalled, NSError * _Nullable error))completion;
```

检查设备是否安装了祈祷功能。此方法将检查设备是否支持祈祷功能以及是否能成功获取祈祷配置。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `void (^)(BOOL, NSError *)` | 检查完成的回调块。isInstalled为YES表示祈祷功能已安装，error为nil表示操作成功 |

**代码示例：**

```objc
id<TSPrayersInterface> prayers = [TopStepComKit sharedInstance].prayer;
[prayers checkIfPrayerIsInstalled:^(BOOL isInstalled, NSError * _Nullable error) {
    if (error) {
        TSLog(@"检查祈祷功能失败: %@", error.localizedDescription);
    } else {
        if (isInstalled) {
            TSLog(@"祈祷功能已安装");
        } else {
            TSLog(@"祈祷功能未安装");
        }
    }
}];
```

### 获取祈祷配置

```objc
- (void)getPrayerConfigCompletion:(void(^)(TSPrayerConfigs * _Nullable prayerConfig, NSError * _Nullable error))completion;
```

从设备获取当前的祈祷配置信息，包括总开关和各个祈祷时间的提醒开关状态。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `void (^)(TSPrayerConfigs *, NSError *)` | 获取完成的回调块。prayerConfig为获取到的配置，error为nil表示操作成功 |

**代码示例：**

```objc
id<TSPrayersInterface> prayers = [TopStepComKit sharedInstance].prayer;
[prayers getPrayerConfigCompletion:^(TSPrayerConfigs * _Nullable prayerConfig, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取祈祷配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"祈祷功能启用: %@", prayerConfig.prayerEnable ? @"YES" : @"NO");
        TSLog(@"晨礼提醒: %@", prayerConfig.fajrReminderEnable ? @"启用" : @"禁用");
        TSLog(@"晌礼提醒: %@", prayerConfig.dhuhrReminderEnable ? @"启用" : @"禁用");
        TSLog(@"晡礼提醒: %@", prayerConfig.asrReminderEnable ? @"启用" : @"禁用");
        TSLog(@"昏礼提醒: %@", prayerConfig.maghribReminderEnable ? @"启用" : @"禁用");
        TSLog(@"宵礼提醒: %@", prayerConfig.ishabReminderEnable ? @"启用" : @"禁用");
    }
}];
```

### 设置祈祷配置

```objc
- (void)setPrayerConfig:(TSPrayerConfigs * _Nonnull)prayerConfig
             completion:(TSCompletionBlock)completion;
```

向设备设置祈祷配置信息。设备将用提供的配置替换现有祈祷配置。

| 参数 | 类型 | 说明 |
|------|------|------|
| `prayerConfig` | `TSPrayerConfigs * _Nonnull` | 要设置的祈祷配置对象，不能为nil |
| `completion` | `TSCompletionBlock` | 设置完成的回调块，error为nil表示操作成功 |

**代码示例：**

```objc
TSPrayerConfigs *config = [[TSPrayerConfigs alloc] init];
config.prayerEnable = YES;
config.fajrReminderEnable = YES;
config.dhuhrReminderEnable = YES;
config.asrReminderEnable = YES;
config.maghribReminderEnable = YES;
config.ishabReminderEnable = YES;
config.sunriseReminderEnable = NO;
config.sunsetReminderEnable = NO;

id<TSPrayersInterface> prayers = [TopStepComKit sharedInstance].prayer;
[prayers setPrayerConfig:config completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置祈祷配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"祈祷配置设置成功");
    }
}];
```

### 设置单个祈祷提醒开关

```objc
- (void)setPrayerReminderEnabled:(TSPrayerReminderSwitch)reminderSwitch
                         enabled:(BOOL)enabled
                      completion:(TSCompletionBlock)completion;
```

根据祈祷提醒开关类型单独设置提醒开关，而不影响其他开关设置。此方法将自动获取当前配置，更新指定开关，并保存回设备。

| 参数 | 类型 | 说明 |
|------|------|------|
| `reminderSwitch` | `TSPrayerReminderSwitch` | 要设置的祈祷提醒开关类型 |
| `enabled` | `BOOL` | 是否启用该开关类型的提醒 |
| `completion` | `TSCompletionBlock` | 设置完成的回调块，error为nil表示操作成功 |

**代码示例：**

```objc
id<TSPrayersInterface> prayers = [TopStepComKit sharedInstance].prayer;

// 启用晨礼提醒
[prayers setPrayerReminderEnabled:TSPrayerReminderSwitchFajr 
                                   enabled:YES 
                                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置晨礼提醒失败: %@", error.localizedDescription);
    } else {
        TSLog(@"晨礼提醒已启用");
    }
}];

// 禁用晌礼提醒
[prayers setPrayerReminderEnabled:TSPrayerReminderSwitchDhuhr 
                                   enabled:NO 
                                completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置晌礼提醒失败: %@", error.localizedDescription);
    } else {
        TSLog(@"晌礼提醒已禁用");
    }
}];
```

### 设置祈祷时间

```objc
- (void)setPrayerTimes:(NSArray<TSPrayerTimes *> * _Nonnull)prayerTimes
            completion:(TSCompletionBlock)completion;
```

向设备设置7天的祈祷时间数据（当天+未来6天）。数组中的每个元素代表一天的祈祷时间，包含所有祈祷相关时间的分钟偏移量。

| 参数 | 类型 | 说明 |
|------|------|------|
| `prayerTimes` | `NSArray<TSPrayerTimes *> * _Nonnull` | 要设置的祈祷时间数组，必须包含7个元素，分别对应当天+未来6天，不能为nil |
| `completion` | `TSCompletionBlock` | 设置完成的回调块，error为nil表示操作成功 |

**代码示例：**

```objc
NSMutableArray<TSPrayerTimes *> *prayerTimesArray = [NSMutableArray array];

// 获取当前日期的00:00:00时间戳
NSDate *today = [NSDate date];
NSCalendar *calendar = [NSCalendar currentCalendar];
NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay 
                                            fromDate:today];
NSDate *todayMidnight = [calendar dateFromComponents:components];
NSTimeInterval todayTimestamp = [todayMidnight timeIntervalSince1970];

// 创建7天的祈祷时间数据
for (int i = 0; i < 7; i++) {
    TSPrayerTimes *prayerTime = [[TSPrayerTimes alloc] init];
    prayerTime.dayTimestamp = todayTimestamp + (i * 24 * 3600);
    
    // 设置各祈祷时间的分钟偏移量
    prayerTime.fajrMinutesOffset = 330;      // 5:30 AM
    prayerTime.sunriseMinutesOffset = 360;   // 6:00 AM
    prayerTime.dhuhrMinutesOffset = 735;     // 12:15 PM
    prayerTime.asrMinutesOffset = 945;       // 3:45 PM
    prayerTime.sunsetMinutesOffset = 1110;   // 6:30 PM
    prayerTime.maghribMinutesOffset = 1100;  // 6:20 PM
    prayerTime.ishaMinutesOffset = 1200;     // 8:00 PM
    
    [prayerTimesArray addObject:prayerTime];
}

id<TSPrayersInterface> prayers = [TopStepComKit sharedInstance].prayer;
[prayers setPrayerTimes:prayerTimesArray completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置祈祷时间失败: %@", error.localizedDescription);
    } else {
        TSLog(@"祈祷时间设置成功");
    }
}];
```

### 注册祈祷配置变化监听

```objc
- (void)registerPrayerConfigDidChangedBlock:(nullable TSPrayerConfigDidChangedBlock)completion;
```

注册祈祷配置变化监听。当设备端祈祷配置被修改时，将通过回调块通知应用。传入nil可以取消注册通知。

| 参数 | 类型 | 说明 |
|------|------|------|
| `completion` | `TSPrayerConfigDidChangedBlock` | 配置变化时触发的回调块，传入nil可取消监听 |

**代码示例：**

```objc
id<TSPrayersInterface> prayers = [TopStepComKit sharedInstance].prayer;

// 注册监听
[prayers registerPrayerConfigDidChangedBlock:^(TSPrayerConfigs * _Nullable prayerConfig, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取配置变化失败: %@", error.localizedDescription);
    } else if (prayerConfig) {
        TSLog(@"祈祷配置已更新");
        TSLog(@"祈祷功能启用: %@", prayerConfig.prayerEnable ? @"YES" : @"NO");
        TSLog(@"晨礼提醒: %@", prayerConfig.fajrReminderEnable ? @"启用" : @"禁用");
        TSLog(@"晌礼提醒: %@", prayerConfig.dhuhrReminderEnable ? @"启用" : @"禁用");
    }
}];
```

### 取消祈祷配置变化监听

```objc
- (void)unregisterPrayerConfigDidChangedBlock;
```

移除已注册的祈祷配置变化监听器。调用此方法后，将不再接收配置变化通知。

**代码示例：**

```objc
id<TSPrayersInterface> prayers = [TopStepComKit sharedInstance].prayer;
[prayers unregisterPrayerConfigDidChangedBlock];
TSLog(@"祈祷配置监听已取消");
```

## 注意事项

1. **总开关依赖关系**：单个祈祷提醒开关（`fajrReminderEnable`、`dhuhrReminderEnable`等）仅在祈祷功能总开关（`prayerEnable`）为YES时有效。如果总开关为NO，其他所有开关设置将被忽略。

2. **可选功能支持**：日出（Sunrise）和日落（Sunset）提醒开关是可选功能，不同项目可能有不同的支持情况。如果项目不支持这些功能，相应的设置将被忽略。

3. **祈祷时间数组要求**：设置祈祷时间时，`prayerTimes`数组必须包含恰好7个元素，分别代表当天和未来6天的数据。数组元素过多或过少都将导致操作失败。

4. **时间戳精度**：祈祷时间中的`dayTimestamp`应为当天00:00:00的Unix时间戳（秒级精度）。所有祈祷时间的分钟偏移量都基于此时间戳计算。

5. **分钟偏移量范围**：祈祷时间的分钟偏移量表示从00:00:00到该时间的分钟数。例如，早上5:30应设置为330（5*60+30），下午3:45应设置为945（15*60+45）。

6. **回调线程**：所有回调块都将在主线程执行，可以安全地更新UI。

7. **空值处理**：获取祈祷配置失败时，回调块中的`prayerConfig`参数将为nil，应检查`error`参数获取错误详情。

8. **配置变化监听一次性注册**：每次调用`registerPrayerConfigDidChangedBlock:`都会替换之前注册的监听器。在同一实例上多次注册不同的监听块会覆盖之前的注册。