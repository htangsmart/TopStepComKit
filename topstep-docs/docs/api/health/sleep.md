---
sidebar_position: 3
title: 睡眠（TSSleep）
---

# 睡眠（TSSleep）

该模块提供从设备同步睡眠数据的方法，包括夜间睡眠和日间小睡（如果支持）。数据包括详细的睡眠阶段、质量指标和全面的睡眠分析。

## 前提条件

1. 已初始化并连接到设备的 TopStepComKit SDK
2. 获得了 `TSSleepInterface` 协议的实现对象
3. 对于自动睡眠监测功能，设备应支持睡眠自动检测

## 数据模型

### TSSleepDailyModel

每日睡眠数据模型，包含该自然日的所有睡眠统计信息。

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `statisticsRule` | `TSSleepStatisticsRule` | 此睡眠记录使用的统计规则 |
| `dailySummary` | `TSSleepSummary *` | 当日睡眠总体汇总 |
| `rawSleepItems` | `NSArray<TSSleepDetailItem *> *` | 原始睡眠数据条目数组（未经处理） |
| `nightSleeps` | `NSArray<TSSleepSegment *> *` | 夜间睡眠段数组 |
| `daytimeSleeps` | `NSArray<TSSleepSegment *> *` | 日间睡眠段数组 |

### TSSleepDetailItem

睡眠详情条目模型类，表示单个睡眠阶段片段。

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `stage` | `TSSleepStage` | 睡眠阶段类型（清醒/浅睡/深睡/快速眼动） |
| `startTime` | `NSTimeInterval` | 开始时间的 Unix 时间戳（秒） |
| `duration` | `NSTimeInterval` | 该阶段持续时长（秒） |
| `belongingDate` | `NSTimeInterval` | 所属日期的 00:00:00 时间戳 |

### TSSleepSegment

睡眠段模型类，表示一个连续的睡眠段。

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `periodType` | `TSSleepPeriodType` | 睡眠时段类型（夜间/日间） |
| `summary` | `TSSleepSummary *` | 此睡眠段的统计汇总 |
| `detailItems` | `NSArray<TSSleepDetailItem *> *` | 按时间顺序的睡眠阶段详情条目 |

### TSSleepSummary

睡眠总结数据模型，包含睡眠数据的统计汇总。

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 睡眠开始时间（Unix 时间戳） |
| `endTime` | `NSTimeInterval` | 睡眠结束时间（Unix 时间戳） |
| `duration` | `NSTimeInterval` | 总持续时间（秒），= `endTime - startTime` |
| `totalSleepDuration` | `NSTimeInterval` | 总有效睡眠时长（秒，不含清醒） |
| `qualityScore` | `UInt8` | 睡眠质量评分（0-100，分数越高质量越好） |
| `awakeDuration` | `NSTimeInterval` | 睡眠期间总清醒时长（秒） |
| `lightSleepDuration` | `NSTimeInterval` | 总浅睡时长（秒） |
| `deepSleepDuration` | `NSTimeInterval` | 总深睡时长（秒） |
| `remDuration` | `NSTimeInterval` | 总 REM 时长（秒） |
| `awakePercentage` | `UInt8` | 清醒时间百分比（0-100） |
| `lightSleepPercentage` | `UInt8` | 浅睡时间百分比（0-100） |
| `deepSleepPercentage` | `UInt8` | 深睡时间百分比（0-100） |
| `remPercentage` | `UInt8` | REM 时间百分比（0-100） |
| `awakeCount` | `UInt16` | 觉醒次数 |
| `lightSleepCount` | `UInt16` | 浅睡次数 |
| `deepSleepCount` | `UInt16` | 深睡次数 |
| `remCount` | `UInt16` | REM 次数 |

### TSAutoMonitorConfigs

自动睡眠监测配置对象（仅作为参数使用，具体属性由设备决定）。

## 枚举与常量

### TSSleepStatisticsRule

睡眠统计规则类型，定义不同的睡眠数据处理规则。

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `TSSleepStatisticsRuleWithoutNap` | 基础规则：不带小睡功能，传感器 20:00-12:00 激活，所有睡眠视为夜间睡眠 |
| `1` | `TSSleepStatisticsRuleWithNap` | 带小睡功能：传感器 24 小时激活，区分夜间（20:00-09:00）和日间（09:00-20:00）睡眠 |
| `2` | `TSSleepStatisticsRuleLongestNight` | 最长夜间段：使用最长连续夜间睡眠段（20:00-08:00），有效小睡计入统计 |
| `3` | `TSSleepStatisticsRuleLongestOnly` | 仅最长段：不区分夜间日间，仅使用最长连续睡眠段 |

### TSSleepStage

睡眠阶段类型枚举，定义不同的睡眠阶段。

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `TSSleepStageAwake` | 清醒阶段 |
| `1` | `TSSleepStageLight` | 浅睡阶段（N1 和 N2 期） |
| `2` | `TSSleepStageDeep` | 深睡阶段（N3 期，慢波睡眠） |
| `3` | `TSSleepStageREM` | 快速眼动阶段（做梦阶段） |

### TSSleepPeriodType

睡眠时段类型枚举，定义睡眠的时段属性。

| 值 | 名称 | 说明 |
|----|------|------|
| `0` | `TSSleepPeriodTypeNight` | 夜间睡眠（20:00-09:00） |
| `1` | `TSSleepPeriodTypeDaytime` | 日间睡眠（09:00-20:00） |

## 接口方法

### 设置自动睡眠监测配置

```objc
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;
```

配置设备上的自动睡眠监测功能，包括监测周期、灵敏度和其他相关设置。

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `configuration` | `TSAutoMonitorConfigs *` | 包含睡眠监测设置的配置对象 |
| `completion` | `TSCompletionBlock` | 返回成功状态或错误的完成回调块 |

**代码示例：**

```objc
id<TSSleepInterface> sleepInterface = // 获取睡眠接口
TSAutoMonitorConfigs *config = [[TSAutoMonitorConfigs alloc] init];
// 设置配置参数...

[sleepInterface pushAutoMonitorConfigs:config completion:^(NSError *_Nullable error) {
    if (error) {
        TSLog(@"设置自动监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"自动监测配置设置成功");
    }
}];
```

### 获取当前自动睡眠监测配置

```objc
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;
```

从设备获取当前的睡眠监测配置，包括与自动睡眠检测和监测相关的所有设置。

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `void (^)(TSAutoMonitorConfigs *, NSError *)` | 返回当前配置或错误的完成回调块 |

**代码示例：**

```objc
id<TSSleepInterface> sleepInterface = // 获取睡眠接口

[sleepInterface fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error) {
    if (error) {
        TSLog(@"获取自动监测配置失败: %@", error.localizedDescription);
    } else {
        TSLog(@"当前配置: %@", configuration);
    }
}];
```

### 同步原始睡眠分段数据（从指定开始时间）

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSSleepDetailItem *> *_Nullable sleepItems, NSError *_Nullable error))completion;
```

从指定时间点开始同步原始睡眠分段数据。返回原始睡眠分段（开始/结束/时长/阶段/时段），适合做细粒度时间线与自定义分析。

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 起始时间的 Unix 时间戳（秒） |
| `completion` | `void (^)(NSArray<TSSleepDetailItem *> *, NSError *)` | 回调返回 `TSSleepDetailItem` 数组或错误信息 |

**代码示例：**

```objc
id<TSSleepInterface> sleepInterface = // 获取睡眠接口

// 获取最近30天的原始睡眠数据
NSDate *now = [NSDate date];
NSTimeInterval startTime = [now timeIntervalSince1970] - (30 * 24 * 3600);

[sleepInterface syncRawDataFromStartTime:startTime completion:^(NSArray<TSSleepDetailItem *> *_Nullable sleepItems, NSError *_Nullable error) {
    if (error) {
        TSLog(@"同步原始数据失败: %@", error.localizedDescription);
    } else {
        TSLog(@"获取 %lu 个睡眠详情条目", (unsigned long)sleepItems.count);
        
        for (TSSleepDetailItem *item in sleepItems) {
            NSString *stageName;
            switch (item.stage) {
                case TSSleepStageAwake: stageName = @"清醒"; break;
                case TSSleepStageLight: stageName = @"浅睡"; break;
                case TSSleepStageDeep: stageName = @"深睡"; break;
                case TSSleepStageREM: stageName = @"REM"; break;
            }
            TSLog(@"阶段: %@, 时长: %.0f秒", stageName, item.duration);
        }
    }
}];
```

### 同步原始睡眠分段数据（指定时间区间）

```objc
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSSleepDetailItem *> *_Nullable sleepItems, NSError *_Nullable error))completion;
```

在指定时间区间内同步原始睡眠分段数据。适用于限定时间窗口获取原始分段数据的场景。

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 区间开始时间的 Unix 时间戳（秒，含） |
| `endTime` | `NSTimeInterval` | 区间结束时间的 Unix 时间戳（秒，不含）。时间区间为 `[startTime, endTime)` |
| `completion` | `void (^)(NSArray<TSSleepDetailItem *> *, NSError *)` | 回调返回 `TSSleepDetailItem` 数组或错误信息 |

**代码示例：**

```objc
id<TSSleepInterface> sleepInterface = // 获取睡眠接口

// 获取某个特定周的原始睡眠数据
NSDate *weekStart = // 某周的开始日期
NSDate *weekEnd = // 某周的结束日期
NSTimeInterval startTime = [weekStart timeIntervalSince1970];
NSTimeInterval endTime = [weekEnd timeIntervalSince1970];

[sleepInterface syncRawDataFromStartTime:startTime 
                                 endTime:endTime 
                              completion:^(NSArray<TSSleepDetailItem *> *_Nullable sleepItems, NSError *_Nullable error) {
    if (error) {
        TSLog(@"同步原始数据失败: %@", error.localizedDescription);
    } else {
        TSLog(@"该周获取 %lu 个睡眠详情条目", (unsigned long)sleepItems.count);
    }
}];
```

### 同步按天聚合的睡眠数据（从指定开始时间）

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSSleepDailyModel *> *_Nullable sleepModel, NSError *_Nullable error))completion;
```

从指定时间点开始同步按天聚合的睡眠数据。返回每日睡眠汇总（总时长、结构构成、质量指标等）。

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 起始"自然日"的 Unix 时间戳（秒） |
| `completion` | `void (^)(NSArray<TSSleepDailyModel *> *, NSError *)` | 回调返回按天聚合的 `TSSleepDailyModel` 数组或错误信息 |

**代码示例：**

```objc
id<TSSleepInterface> sleepInterface = // 获取睡眠接口

// 获取最近7天的每日睡眠汇总
NSDate *now = [NSDate date];
NSTimeInterval startTime = [now timeIntervalSince1970] - (7 * 24 * 3600);

[sleepInterface syncDailyDataFromStartTime:startTime completion:^(NSArray<TSSleepDailyModel *> *_Nullable sleepModels, NSError *_Nullable error) {
    if (error) {
        TSLog(@"同步每日数据失败: %@", error.localizedDescription);
    } else {
        TSLog(@"获取 %lu 天的睡眠数据", (unsigned long)sleepModels.count);
        
        for (TSSleepDailyModel *dailyModel in sleepModels) {
            TSLog(@"日期: %@", @(dailyModel.dateTime));
            TSLog(@"  统计规则: %ld", (long)dailyModel.statisticsRule);
            
            // 访问每日汇总
            TSSleepSummary *summary = dailyModel.dailySummary;
            TSLog(@"  总睡眠时长: %.0f分钟", summary.totalSleepDuration / 60.0);
            TSLog(@"  睡眠质量评分: %u", summary.qualityScore);
            TSLog(@"  深睡百分比: %u%%", summary.deepSleepPercentage);
            
            // 访问夜间睡眠段
            for (TSSleepSegment *nightSleep in dailyModel.nightSleeps) {
                TSLog(@"  夜间睡眠: %.0f分钟", nightSleep.summary.totalSleepDuration / 60.0);
            }
            
            // 访问有效日间小睡
            NSArray<TSSleepSegment *> *validNaps = [dailyModel validNaps];
            TSLog(@"  有效小睡数: %lu", (unsigned long)validNaps.count);
        }
    }
}];
```

### 同步按天聚合的睡眠数据（指定时间区间）

```objc
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSSleepDailyModel *> *_Nullable sleepModel, NSError *_Nullable error))completion;
```

在指定时间区间内同步按天聚合的睡眠数据。适用于限定日期范围获取按天汇总数据。

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `startTime` | `NSTimeInterval` | 区间起始"自然日"的 Unix 时间戳（秒，含） |
| `endTime` | `NSTimeInterval` | 区间结束"自然日"的 Unix 时间戳（秒，不含）。日期区间为 `[startTime, endTime)` |
| `completion` | `void (^)(NSArray<TSSleepDailyModel *> *, NSError *)` | 回调返回按天聚合的 `TSSleepDailyModel` 数组或错误信息 |

**代码示例：**

```objc
id<TSSleepInterface> sleepInterface = // 获取睡眠接口

// 获取某个月份的睡眠数据
NSDate *monthStart = // 月份开始日期
NSDate *monthEnd = // 月份结束日期
NSTimeInterval startTime = [monthStart timeIntervalSince1970];
NSTimeInterval endTime = [monthEnd timeIntervalSince1970];

[sleepInterface syncDailyDataFromStartTime:startTime 
                                   endTime:endTime 
                                completion:^(NSArray<TSSleepDailyModel *> *_Nullable sleepModels, NSError *_Nullable error) {
    if (error) {
        TSLog(@"同步每日数据失败: %@", error.localizedDescription);
    } else {
        // 计算月度统计
        NSTimeInterval totalDuration = 0;
        UInt8 totalQualityScore = 0;
        NSInteger validDays = 0;
        
        for (TSSleepDailyModel *dailyModel in sleepModels) {
            TSSleepSummary *summary = dailyModel.dailySummary;
            if (summary) {
                totalDuration += summary.totalSleepDuration;
                totalQualityScore += summary.qualityScore;
                validDays++;
            }
        }
        
        if (validDays > 0) {
            NSTimeInterval avgDuration = totalDuration / validDays;
            UInt8 avgQualityScore = totalQualityScore / validDays;
            TSLog(@"月度平均睡眠时长: %.1f小时", avgDuration / 3600.0);
            TSLog(@"月度平均睡眠质量评分: %u", avgQualityScore);
        }
    }
}];
```

### 获取有效日间小睡

```objc
- (NSArray<TSSleepSegment *> *)validNaps;
```

从 `TSSleepDailyModel` 对象中获取仅有效的日间小睡。

**代码示例：**

```objc
TSSleepDailyModel *dailyModel = // 获取的每日睡眠模型

// 获取有效小睡（20分钟 < 时长 <= 3小时）
NSArray<TSSleepSegment *> *validNaps = [dailyModel validNaps];
TSLog(@"本日有效小睡数: %lu", (unsigned long)validNaps.count);

for (TSSleepSegment *nap in validNaps) {
    TSLog(@"小睡时长: %.0f分钟, 质量评分: %u", 
          nap.summary.totalSleepDuration / 60.0,
          nap.summary.qualityScore);
}
```

## 注意事项

1. **时间戳格式**：所有时间参数均为 Unix 时间戳（秒），不是毫秒。

2. **睡眠日期定义**：睡眠数据以 20:00 为跨天分隔线 `[20:00→20:00)`，例如：
   - 2025-11-19 21:00 的睡眠归属于 2025-11-20 的数据
   - 2025-11-20 08:00 的睡眠也归属于 2025-11-20 的数据
   - 2025-11-20 21:00 的睡眠归属于 2025-11-21 的数据

3. **统计规则**：不同设备可能使用不同的睡眠统计规则，可通过 `TSSleepDailyModel.statisticsRule` 属性查看当前规则。

4. **有效小睡标准**：仅时长在 20 分钟到 3 小时之间的日间睡眠才被认为是有效小睡，其他被视为无效小睡或噪声数据。

5. **原始数据与聚合数据**：
   - 原始数据（`syncRawData*`）适合做细粒度分析和自定义处理
   - 聚合数据（`syncDailyData*`）已按规则处理，可直接用于展示和统计

6. **回调线程**：完成回调可能在后台线程执行，如需更新 UI 应切换到主线程。

7. **时间范围**：使用 `[startTime, endTime)` 形式的半开区间，结束时间不含在范围内。

8. **自动监测配置**：推送的配置会同步到设备，设备重启后仍保留这些配置。