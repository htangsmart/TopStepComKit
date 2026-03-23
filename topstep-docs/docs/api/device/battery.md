---
sidebar_position: 1
title: 设备电量
---

# 设备电量（TSBattery）

TSBattery 模块提供了设备电池管理功能，用于获取设备当前电量及充电状态，并监听电池信息变化。通过该模块可以实时了解设备的电源管理状态。

## 前提条件

1. TopStepComKit iOS SDK 已正确集成到项目中
2. 设备已与 App 建立连接
3. 确保有必要的权限访问设备电池信息

## 数据模型

### TSBatteryModel

电池信息模型，包含设备的电量和充电状态。

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `chargeState` | `TSBatteryState` | 设备充电状态，参考 TSBatteryState 枚举定义 |
| `percentage` | `UInt8` | 电池电量百分比，范围为 0-100 |

#### 初始化方法

```objc
- (instancetype)initWithPercentage:(NSInteger)percentage
                       chargeState:(TSBatteryState)chargeState
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `percentage` | `NSInteger` | 电池电量百分比（0-100） |
| `chargeState` | `TSBatteryState` | 设备当前的充电状态 |

## 枚举与常量

### TSBatteryState

电池充电状态枚举，定义了设备不同的充电状态。

| 枚举值 | 数值 | 说明 |
|--------|------|------|
| `TSBatteryStateUnknown` | 1 | 充电状态未知 |
| `TSBatteryStateCharging` | 2 | 已连接电源并正在充电 |
| `TSBatteryStateUnConnectNoCharging` | 3 | 未连接电源 |
| `TSBatteryStateConnectNotCharging` | 4 | 已连接电源但未在充电 |
| `TSBatteryStateFull` | 5 | 电池已充满 |

## 回调类型

### TSBatteryBlock

电池操作完成或电池信息变化时的回调。

| 回调签名 | 说明 |
|---------|------|
| `void (^)(TSBatteryModel *_Nullable batteryModel, NSError *_Nullable error)` | 电池模型：包含电量和充电状态；错误信息：操作失败时返回，成功时为 nil |

## 接口方法

### 获取当前电池信息

获取设备当前的电池电量和充电状态。

```objc
- (void)getBatteryInfoCompletion:(nullable TSBatteryBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSBatteryBlock` | 获取完成回调，返回电池模型或错误信息 |

**代码示例**

```objc
id<TSBatteryInterface> battery = [TopStepComKit sharedInstance].battery;
[battery getBatteryInfoCompletion:^(TSBatteryModel * _Nullable batteryModel, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取电池信息失败: %@", error.localizedDescription);
        return;
    }
    
    if (batteryModel) {
        TSLog(@"电池电量: %d%%", batteryModel.percentage);
        
        // 根据充电状态判断
        switch (batteryModel.chargeState) {
            case TSBatteryStateUnknown:
                TSLog(@"充电状态: 未知");
                break;
            case TSBatteryStateCharging:
                TSLog(@"充电状态: 充电中");
                break;
            case TSBatteryStateUnConnectNoCharging:
                TSLog(@"充电状态: 未连接电源");
                break;
            case TSBatteryStateConnectNotCharging:
                TSLog(@"充电状态: 已连接但未充电");
                break;
            case TSBatteryStateFull:
                TSLog(@"充电状态: 已充满");
                break;
        }
    }
}];
```

### 监听电池信息变化

注册电池信息变化监听，当设备电量或充电状态发生变化时触发回调。

```objc
- (void)registerBatteryDidChanged:(nullable TSBatteryBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSBatteryBlock` | 电池信息变化回调，返回更新后的电池模型或错误信息 |

**代码示例**

```objc
id<TSBatteryInterface> battery = [TopStepComKit sharedInstance].battery;
[battery registerBatteryDidChanged:^(TSBatteryModel * _Nullable batteryModel, NSError * _Nullable error) {
    if (error) {
        TSLog(@"电池监听失败: %@", error.localizedDescription);
        return;
    }
    
    if (batteryModel) {
        TSLog(@"电池信息更新 - 电量: %d%%", batteryModel.percentage);
        
        // 当电量低于 20% 时提示用户
        if (batteryModel.percentage < 20) {
            TSLog(@"警告: 设备电量即将耗尽，请充电");
        }
        
        // 当电池充满时提示
        if (batteryModel.chargeState == TSBatteryStateFull) {
            TSLog(@"设备电池已充满");
        }
    }
}];
```

## 注意事项

1. `getBatteryInfoCompletion:` 用于主动查询当前电池状态，`registerBatteryDidChanged:` 用于监听变化事件，两者可配合使用。
2. 电池电量百分比范围为 0-100，其中 0 表示电池耗尽，100 表示电池充满。
3. 监听回调会在电池信息发生任何变化时（电量变化或充电状态改变）被触发，频率可能较高，建议避免在回调中执行耗时操作。
4. 回调中的 `batteryModel` 可能为 nil，必须进行非空检查后再访问其属性。
5. 如需停止监听电池变化，应保存对接口的引用并在适当时机取消监听（具体机制取决于 SDK 的生命周期管理）。
6. 错误信息中的错误码和原因需要根据实际返回的 `NSError` 对象进行解析和处理。
7. 不能使用 `init`、`copy` 或 `new` 方法初始化 `TSBatteryModel`，必须使用指定的初始化方法 `initWithPercentage:chargeState:`。