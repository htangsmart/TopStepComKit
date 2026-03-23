---
sidebar_position: 2
title: 查找设备
---

# 查找设备（TSPeripheralFind）

TSPeripheralFind 模块提供了 iPhone 与外围设备之间的相互查找功能。通过该模块，您可以实现 iPhone 查找设备、设备查找 iPhone 等互查场景，满足防丢等应用需求。

## 前提条件

1. 已成功初始化 TopStepComKit SDK
2. 已建立与外围设备的蓝牙连接
3. 外围设备支持查找功能
4. 应用具有必要的权限（根据平台要求）

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `void (^)(void)` | 设备查找 iPhone 或设备响应查找请求时的回调，不携带参数 |

## 接口方法

### iPhone 开启查找外围设备

```objc
- (void)beginFindPeripheral:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSCompletionBlock` | 指令发送完成的回调。该回调会在指令发送后立即触发，不代表设备已响应 |

**代码示例**

```objc
id<TSPeripheralFindInterface> findInterface = [TopStepComKit sharedInstance].peripheralFind;

// 先注册设备响应回调
[findInterface registerPeripheralHasBeenFound:^{
    TSLog(@"设备已响应查找请求");
}];

// 开始查找设备
[findInterface beginFindPeripheral:^(NSError *error) {
    if (error) {
        TSLog(@"查找指令发送失败: %@", error.localizedDescription);
    } else {
        TSLog(@"查找指令发送成功，等待设备响应...");
    }
}];
```

---

### iPhone 停止查找外围设备

```objc
- (void)stopFindPeripheral:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSCompletionBlock` | 停止查找操作完成的回调 |

**代码示例**

```objc
id<TSPeripheralFindInterface> findInterface = [TopStepComKit sharedInstance].peripheralFind;

[findInterface stopFindPeripheral:^(NSError *error) {
    if (error) {
        TSLog(@"停止查找失败: %@", error.localizedDescription);
    } else {
        TSLog(@"已停止查找设备");
    }
}];
```

---

### 注册设备已被找到的回调

```objc
- (void)registerPeripheralHasBeenFound:(PeripheralFindPhoneBlock)peripheralHasBeenFound;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `peripheralHasBeenFound` | `void (^)(void)` | 当设备响应查找请求时触发的回调 |

**代码示例**

```objc
id<TSPeripheralFindInterface> findInterface = [TopStepComKit sharedInstance].peripheralFind;

[findInterface registerPeripheralHasBeenFound:^{
    TSLog(@"设备已被找到，设备已响应查找请求");
    // 可在此更新 UI，如停止搜索动画
}];
```

---

### 注册设备发起查找 iPhone 的回调

```objc
- (void)registerPeripheralFindPhone:(PeripheralFindPhoneBlock)peripheralFindPhoneBlock;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `peripheralFindPhoneBlock` | `void (^)(void)` | 当设备发起查找 iPhone 请求时触发的回调 |

**代码示例**

```objc
id<TSPeripheralFindInterface> findInterface = [TopStepComKit sharedInstance].peripheralFind;

[findInterface registerPeripheralFindPhone:^{
    TSLog(@"设备正在查找 iPhone");
    // 可在此播放提示音、闪烁屏幕等提醒操作
}];
```

---

### 注册设备停止查找 iPhone 的回调

```objc
- (void)registerPeripheralStopFindPhone:(PeripheralFindPhoneBlock)peripheralStopFindPhoneBlock;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `peripheralStopFindPhoneBlock` | `void (^)(void)` | 当设备停止查找 iPhone 时触发的回调 |

**代码示例**

```objc
id<TSPeripheralFindInterface> findInterface = [TopStepComKit sharedInstance].peripheralFind;

[findInterface registerPeripheralStopFindPhone:^{
    TSLog(@"设备已停止查找 iPhone");
    // 可在此停止提示音、取消屏幕闪烁等操作
}];
```

---

### 通知设备 iPhone 已被找到

```objc
- (void)notifyPeripheralPhoneHasBeenFound:(TSCompletionBlock)completion;
```

**参数说明**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSCompletionBlock` | 通知操作完成的回调 |

**代码示例**

```objc
id<TSPeripheralFindInterface> findInterface = [TopStepComKit sharedInstance].peripheralFind;

// 当设备在查找 iPhone 时，通知设备已找到
[findInterface notifyPeripheralPhoneHasBeenFound:^(NSError *error) {
    if (error) {
        TSLog(@"通知设备失败: %@", error.localizedDescription);
    } else {
        TSLog(@"已通知设备 iPhone 已被找到");
    }
}];
```

---

## 使用流程示例

```objc
id<TSPeripheralFindInterface> findInterface = [TopStepComKit sharedInstance].peripheralFind;

// 1. 注册所有回调（建议在初始化时注册一次）
[findInterface registerPeripheralHasBeenFound:^{
    TSLog(@"设备已响应查找请求");
}];

[findInterface registerPeripheralFindPhone:^{
    TSLog(@"设备正在查找 iPhone，开始播放提示音");
    // 播放提示音、闪烁屏幕等
}];

[findInterface registerPeripheralStopFindPhone:^{
    TSLog(@"设备已停止查找 iPhone");
    // 停止提示音、取消闪烁等
}];

// 2. 当用户点击"查找设备"时
[findInterface beginFindPeripheral:^(NSError *error) {
    if (!error) {
        TSLog(@"开始查找设备");
    }
}];

// 3. 当用户点击"停止查找"时
[findInterface stopFindPeripheral:^(NSError *error) {
    if (!error) {
        TSLog(@"停止查找设备");
    }
}];

// 4. 当设备在查找 iPhone 时，响应通知
[findInterface notifyPeripheralPhoneHasBeenFound:^(NSError *error) {
    if (!error) {
        TSLog(@"已通知设备");
    }
}];
```

## 注意事项

1. 在调用 `beginFindPeripheral:` 之前，应先通过 `registerPeripheralHasBeenFound:` 注册设备响应回调，否则会错过设备的响应事件
2. `TSCompletionBlock` 回调仅表示指令发送完成，不代表设备已执行或响应，请不要在 completion 中假设操作成功
3. 设备查找 iPhone 和 iPhone 查找设备是独立的两个流程，可以同时进行
4. 在设备断开连接后，所有已注册的回调将失效，重新连接设备后需要重新注册
5. 建议在应用生命周期的适当阶段（如 `viewDidLoad`）注册回调，避免重复注册
6. 调用 `notifyPeripheralPhoneHasBeenFound:` 应该在收到 `registerPeripheralFindPhone:` 的回调后进行，即设备正在查找 iPhone 时
7. 不同设备可能对查找功能的支持程度不同，应根据设备实际情况处理
