---
sidebar_position: 4
title: 数据同步指南
---

# 数据同步指南

SDK 提供两种方式获取健康数据：**实时测量**（主动触发）和**历史数据同步**（批量拉取）。本文重点介绍历史数据同步的策略和用法。

## 数据获取方式对比

| 方式 | 接口 | 适用场景 |
|------|------|---------|
| 实时主动测量 | 各健康模块的 `startMeasure` | 用户主动触发的单次测量（心率、血氧等） |
| 历史数据同步 | `TSDataSyncInterface` | App 启动后批量拉取设备存储的历史记录 |
| 设备自动监测数据 | `TSAutoMonitorInterface` | 配置设备自动采集的参数 |

## 历史数据同步

### 同步时机

建议在以下时机触发同步：

```objectivec
// 1. 设备连接成功后立即同步
- (void)onDeviceConnected {
    [self syncHealthData];
}

// 2. App 进入前台时同步
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([bleConnect isConnected]) {
        [self syncHealthData];
    }
}

// 3. 用户下拉刷新
- (void)onPullToRefresh {
    [self syncHealthData];
}
```

### 同步数据类型

```objectivec
id<TSDataSyncInterface> dataSync = [TopStepComKit sharedInstance].dataSync;

// 同步所有支持的健康数据（推荐）
[dataSync syncAllHealthData:^(NSString *dataType, id data, NSError *error) {
    if (error) {
        TSLog(@"同步 %@ 失败: %@", dataType, error.localizedDescription);
        return;
    }
    TSLog(@"同步 %@ 成功，数据条数: %lu", dataType, (unsigned long)[data count]);
    [self saveToLocal:data forType:dataType];
} completion:^(BOOL isSuccess, NSError *error) {
    TSLog(@"全量同步%@", isSuccess ? @"完成" : @"失败");
    [self hideProgressView];
}];
```

### 按时间范围同步

```objectivec
// 只同步最近 7 天的心率数据
NSDate *endDate   = [NSDate date];
NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-(7 * 24 * 3600)];

id<TSHeartRateInterface> heartRate = [TopStepComKit sharedInstance].heartRate;

[heartRate getHistoryDataFrom:startDate
                           to:endDate
                   completion:^(NSArray *records, NSError *error) {
    if (error) {
        TSLog(@"心率历史同步失败: %@", error.localizedDescription);
        return;
    }
    TSLog(@"心率记录条数: %lu", (unsigned long)records.count);
    // 保存到本地数据库
    [self.db insertHeartRateRecords:records];
}];
```

## 增量同步策略

避免每次全量同步造成性能浪费，推荐记录最后同步时间戳做增量同步：

```objectivec
- (void)incrementalSync {
    // 从 UserDefaults 读取上次同步时间
    NSDate *lastSyncDate = [[NSUserDefaults standardUserDefaults]
                            objectForKey:@"lastHeartRateSyncDate"];
    if (!lastSyncDate) {
        // 首次同步：拉取最近 30 天
        lastSyncDate = [NSDate dateWithTimeIntervalSinceNow:-(30 * 24 * 3600)];
    }

    NSDate *now = [NSDate date];

    [heartRate getHistoryDataFrom:lastSyncDate
                               to:now
                       completion:^(NSArray *records, NSError *error) {
        if (!error && records.count > 0) {
            [self.db insertHeartRateRecords:records];

            // 更新最后同步时间
            [[NSUserDefaults standardUserDefaults] setObject:now
                                                      forKey:@"lastHeartRateSyncDate"];
        }
    }];
}
```

## 数据模型说明

### 两种数据粒度

各健康模块通常提供两种粒度的数据：

| 粒度 | 模型后缀 | 说明 |
|------|---------|------|
| 明细记录 | `ValueItem` / `Record` | 每条原始测量数据，含时间戳 |
| 每日汇总 | `DailyModel` | 按天聚合的统计数据（最大/最小/平均值） |

**心率示例：**

```objectivec
// TSHRValueItem（明细）
TSHRValueItem *item = records[0];
TSLog(@"心率: %ld bpm，时间: %@", (long)item.value, item.timestamp);

// TSHRDailyModel（每日汇总）
TSHRDailyModel *daily = dailyRecords[0];
TSLog(@"日期: %@ 最高: %ld 最低: %ld 平均: %ld",
      daily.date,
      (long)daily.maxValue,
      (long)daily.minValue,
      (long)daily.avgValue);
```

## 同步进度展示

对用户友好的同步体验：

```objectivec
- (void)syncAllDataWithProgress {
    NSArray *syncTasks = @[
        @"心率",
        @"血氧",
        @"睡眠",
        @"运动",
        @"步数",
    ];

    __block NSInteger completedCount = 0;
    NSInteger totalCount = syncTasks.count;

    // 更新进度 UI
    [self showProgressViewWithTotal:totalCount];

    // 并发发起各模块同步
    [heartRate getHistoryDataFrom:startDate to:endDate completion:^(NSArray *r, NSError *e) {
        if (!e) [self.db insertHeartRateRecords:r];
        [self updateProgress:++completedCount total:totalCount];
    }];

    [bloodOxygen getHistoryDataFrom:startDate to:endDate completion:^(NSArray *r, NSError *e) {
        if (!e) [self.db insertBloodOxygenRecords:r];
        [self updateProgress:++completedCount total:totalCount];
    }];

    // ... 其他模块
}
```

## 注意事项

1. 同步必须在设备连接状态（`eTSBleStateConnected`）下进行
2. 同步过程中不要断开设备，否则会导致数据不完整
3. 设备存储空间有限，部分旧数据可能已被覆盖；建议每次连接后及时同步
4. 大量历史数据同步耗时较长，建议在后台线程处理数据库写入，避免阻塞主线程
5. 同步完成前调用 `isSupport` 检查模块是否受支持，不支持的模块跳过即可
