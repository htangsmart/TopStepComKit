---
sidebar_position: 12
title: 主动测量
---

# 主动测量（TSActivityMeasure）

主动测量模块提供对设备进行实时健康数据采集的能力，支持心率、血压、血氧、压力、体温和心电等多种测量类型。通过该模块，应用可以主动发起健康测量任务，实时接收测量数据，并精确控制测量过程。

## 前提条件

1. 已成功集成 TopStepComKit iOS SDK
2. 设备已配对连接且通信正常
3. 检查设备是否支持所需的测量类型
4. 确保应用拥有获取健康数据的必要权限

## 数据模型

### TSActivityMeasureParam

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `measureType` | `TSActiveMeasureType` | 要执行的测量类型。一次只能选择一种测量类型，需根据设备功能选择合适的类型 |
| `interval` | `UInt8` | 采样间隔（秒）。指定连续测量之间的时间间隔，影响测量频率和数据颗粒度 |
| `maxMeasureDuration` | `UInt8` | 最大测量时长（秒）。测量会话的最大持续时间，达到此时长后自动停止。设置为 0 表示持续测量直到手动停止，最小有效值为 15 秒 |

## 枚举与常量

### TSActiveMeasureType

| 枚举值 | 数值 | 说明 |
|--------|------|------|
| `TSMeasureTypeNone` | 0 | 无测量项目 |
| `TSMeasureTypeHeartRate` | 1 | 心率监测 |
| `TSMeasureTypeBloodOxygen` | 2 | 血氧饱和度（SpO2）测量 |
| `TSMeasureTypeBloodPressure` | 3 | 血压（收缩压和舒张压）测量 |
| `TSMeasureTypeStress` | 4 | 精神压力水平评估 |
| `TSMeasureTypeTemperature` | 5 | 体温测量 |
| `TSMeasureTypeECG` | 6 | 心电图记录 |

## 回调类型

| 回调类型 | 签名 | 说明 |
|----------|------|------|
| `TSCompletionBlock` | `void (^)(NSError *)` | 通用完成回调，用于执行结果通知 |
| 测量数据变化回调 | `void (^)(TSHealthValueItem * _Nullable, NSError * _Nullable)` | 实时测量数据回调。参数：实时测量数据（错误时为 nil），错误信息（成功时为 nil） |
| 测量结束回调 | `void (^)(BOOL, NSError * _Nullable)` | 测量会话结束回调。参数：是否正常结束，异常结束时的错误信息 |

## 接口方法

### 使用自定义参数开始健康测量

```objc
+ (void)startMeasureWithParam:(TSActivityMeasureParam *)measureParam 
                   completion:(TSCompletionBlock)completion;
```

**参数说明：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `measureParam` | `TSActivityMeasureParam *` | 测量参数配置对象，包括测量类型、采样间隔和最大时长 |
| `completion` | `TSCompletionBlock` | 完成回调，指示开始测量的成功或失败。若返回的 `error` 为 nil 则表示成功 |

**代码示例：**

```objc
// 创建心率测量参数
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.measureType = TSMeasureTypeHeartRate;      // 选择心率测量
param.interval = 1;                              // 1秒采样间隔
param.maxMeasureDuration = 60;                   // 最多测量60秒

// 开始测量
[TSActiveMeasureInterface startMeasureWithParam:param completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"测量启动失败: %@", error.localizedDescription);
    } else {
        TSLog(@"心率测量已启动");
    }
}];
```

### 停止正在进行的健康测量

```objc
+ (void)stopMeasureWithParam:(TSActivityMeasureParam *)measureParam 
                   completion:(TSCompletionBlock)completion;
```

**参数说明：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `measureParam` | `TSActivityMeasureParam *` | 测量参数配置对象，用于指定要停止的测量类型 |
| `completion` | `TSCompletionBlock` | 完成回调，指示停止测量的成功或失败。若返回的 `error` 为 nil 则表示成功 |

**代码示例：**

```objc
// 创建参数对象用于停止测量
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.measureType = TSMeasureTypeHeartRate;

// 停止测量
[TSActiveMeasureInterface stopMeasureWithParam:param completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"测量停止失败: %@", error.localizedDescription);
    } else {
        TSLog(@"心率测量已停止");
    }
}];
```

### 注册测量数据变化通知

```objc
+ (void)registerMeasurement:(TSActivityMeasureParam *)param
             dataDidChanged:(void(^)(TSHealthValueItem * _Nullable realtimeData, NSError * _Nullable error))dataDidChanged;
```

**参数说明：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `param` | `TSActivityMeasureParam *` | 测量参数配置对象 |
| `dataDidChanged` | `void (^)(TSHealthValueItem * _Nullable, NSError * _Nullable)` | 数据变化回调。参数：实时测量数据（错误时为 nil），接收失败时的错误信息（成功时为 nil） |

**代码示例：**

```objc
// 注册数据变化通知
TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
param.measureType = TSMeasureTypeHeartRate;

[TSActiveMeasureInterface registerMeasurement:param 
                               dataDidChanged:^(TSHealthValueItem * _Nullable realtimeData, NSError * _Nullable error) {
    if (error) {
        TSLog(@"接收测量数据失败: %@", error.localizedDescription);
    } else if (realtimeData) {
        TSLog(@"实时心率: %@", realtimeData.value);
        TSLog(@"测量时间: %@", realtimeData.timestamp);
    }
}];
```

### 注册测量结束通知

```objc
+ (void)registerActivityeasureDidFinished:(void(^)(BOOL isFinished, NSError * _Nullable error))didFinished;
```

**参数说明：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `didFinished` | `void (^)(BOOL, NSError * _Nullable)` | 测量结束回调。参数：是否正常结束（YES 为正常结束，NO 为被中断），异常结束时的错误信息 |

**代码示例：**

```objc
// 注册测量结束通知
[TSActiveMeasureInterface registerActivityeasureDidFinished:^(BOOL isFinished, NSError * _Nullable error) {
    if (error) {
        TSLog(@"测量异常结束: %@", error.localizedDescription);
    } else if (isFinished) {
        TSLog(@"测量正常完成");
    } else {
        TSLog(@"测量被中断");
    }
}];
```

## 注意事项

1. **设备兼容性检查**：并非所有设备都支持所有测量类型，使用前应检查设备功能支持情况

2. **单一测量类型限制**：一次只能激活一种测量类型，启动新的测量类型前需停止当前测量

3. **观察者注册时机**：建议在开始测量前注册观察者，确保不会错过测量过程中的数据回调

4. **多个观察者支持**：可同时注册多个观察者，每个观察者都会接收到相同的数据更新

5. **主线程回调**：所有回调（包括数据更新和测量结束）都会在主线程中调用，可安全更新 UI

6. **时长单位说明**：`maxMeasureDuration` 的单位为秒，设置为 0 表示持续测量，最小有效值为 15 秒

7. **采样间隔有效范围**：`interval` 的有效范围因测量类型而异，应根据具体测量类型选择合适的间隔值

8. **设备连接状态**：设备断开连接时测量会自动停止，观察者仍会收到测量结束回调

9. **应用生命周期**：应用被终止时，所有活跃的测量会自动停止，观察者不再接收数据

10. **错误处理**：务必检查回调中的 `error` 参数，及时处理测量过程中出现的异常情况