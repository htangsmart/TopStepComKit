---
sidebar_position: 3
title: 屏幕锁
---

# 屏幕锁 (TSPeripheralLock)

屏幕锁模块提供设备屏幕锁和游戏锁的管理功能，支持查询、设置锁的开启状态、密码和时间段限制。通过 `TSPeripheralLockInterface` 协议，开发者可以灵活控制设备的屏幕锁和游戏锁配置。

## 前提条件

1. 已初始化 TopStepComKit SDK
2. 已建立与设备的连接
3. 确认设备支持屏幕锁或游戏锁功能（通过 `isSupportScreenLock` 或 `isSupportGameLock` 检查）
4. 密码必须为 6 位数字字符串（例如 "123456"）

## 数据模型

### TSScreenLockModel（屏幕锁模型）

屏幕锁的数据模型，仅包含开启状态和密码，不支持时间段限制。

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `isEnabled` | `BOOL` | 是否开启锁；YES 表示开启，NO 表示关闭 |
| `password` | `NSString *` | 锁密码字符串（6 位数字类型，例如 "123456"） |

### TSGameLockModel（游戏锁模型）

游戏锁的数据模型，包含开启状态、密码和时间段限制。

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `isEnabled` | `BOOL` | 是否开启锁；YES 表示开启，NO 表示关闭 |
| `password` | `NSString *` | 锁密码字符串（6 位数字类型，例如 "123456"） |
| `start` | `NSInteger` | 开始时间（距离 0 点的分钟偏移数，例如 0 = 00:00，540 = 09:00） |
| `end` | `NSInteger` | 结束时间（距离 0 点的分钟偏移数，例如 60 = 01:00，1439 = 23:59） |

## 回调类型

| 回调名 | 签名 | 说明 |
|-------|------|------|
| `TSScreenLockResultBlock` | `void (^)(TSScreenLockModel * _Nullable model, NSError * _Nullable error)` | 查询屏幕锁信息的回调块；model 为查询结果（成功时有值，失败时为 nil）；error 为错误对象（成功时为 nil） |
| `TSGameLockResultBlock` | `void (^)(TSGameLockModel * _Nullable model, NSError * _Nullable error)` | 查询游戏锁信息的回调块；model 为查询结果（成功时有值，失败时为 nil）；error 为错误对象（成功时为 nil） |
| `TSCompletionBlock` | `void (^)(NSError * _Nullable error)` | 通用完成回调块；error 为错误对象（成功时为 nil） |

## 接口方法

### 检查设备是否支持屏幕锁

```objc
- (BOOL)isSupportScreenLock;
```

检查设备是否支持屏幕锁功能。

**返回值**

| 返回值 | 说明 |
|-------|------|
| `BOOL` | 支持屏幕锁返回 YES，否则返回 NO |

**代码示例**

```objc
id<TSPeripheralLockInterface> lockInterface = [TopStepComKit sharedInstance].peripheralLock;

if ([lockInterface isSupportScreenLock]) {
    TSLog(@"设备支持屏幕锁功能");
} else {
    TSLog(@"设备不支持屏幕锁功能");
}
```

### 查询屏幕锁配置

```objc
- (void)queryScreenLock:(TSScreenLockResultBlock)completion;
```

从设备查询当前屏幕锁的配置信息。

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSScreenLockResultBlock` | 查询完成后的回调块；model 为查询结果，error 为错误对象 |

**代码示例**

```objc
id<TSPeripheralLockInterface> lockInterface = [TopStepComKit sharedInstance].peripheralLock;

[lockInterface queryScreenLock:^(TSScreenLockModel * _Nullable model, NSError * _Nullable error) {
    if (error) {
        TSLog(@"查询屏幕锁失败: %@", error.localizedDescription);
    } else if (model) {
        TSLog(@"屏幕锁已开启: %@", model.isEnabled ? @"YES" : @"NO");
        TSLog(@"屏幕锁密码: %@", model.password);
    }
}];
```

### 设置屏幕锁配置

```objc
- (void)setScreenLock:(TSScreenLockModel *)screenLock completion:(TSCompletionBlock)completion;
```

设置设备的屏幕锁配置。

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `screenLock` | `TSScreenLockModel *` | 屏幕锁模型，包含开启状态和 6 位数字密码 |
| `completion` | `TSCompletionBlock` | 设置完成后的回调块；error 为错误对象（成功时为 nil） |

**代码示例**

```objc
id<TSPeripheralLockInterface> lockInterface = [TopStepComKit sharedInstance].peripheralLock;

TSScreenLockModel *screenLock = [[TSScreenLockModel alloc] init];
screenLock.isEnabled = YES;
screenLock.password = @"123456";

[lockInterface setScreenLock:screenLock completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置屏幕锁失败: %@", error.localizedDescription);
    } else {
        TSLog(@"屏幕锁设置成功");
    }
}];
```

### 检查设备是否支持游戏锁

```objc
- (BOOL)isSupportGameLock;
```

检查设备是否支持游戏锁功能。

**返回值**

| 返回值 | 说明 |
|-------|------|
| `BOOL` | 支持游戏锁返回 YES，否则返回 NO |

**代码示例**

```objc
id<TSPeripheralLockInterface> lockInterface = [TopStepComKit sharedInstance].peripheralLock;

if ([lockInterface isSupportGameLock]) {
    TSLog(@"设备支持游戏锁功能");
} else {
    TSLog(@"设备不支持游戏锁功能");
}
```

### 查询游戏锁配置

```objc
- (void)queryGameLock:(TSGameLockResultBlock)completion;
```

从设备查询当前游戏锁的配置信息。

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `completion` | `TSGameLockResultBlock` | 查询完成后的回调块；model 为查询结果，error 为错误对象 |

**代码示例**

```objc
id<TSPeripheralLockInterface> lockInterface = [TopStepComKit sharedInstance].peripheralLock;

[lockInterface queryGameLock:^(TSGameLockModel * _Nullable model, NSError * _Nullable error) {
    if (error) {
        TSLog(@"查询游戏锁失败: %@", error.localizedDescription);
    } else if (model) {
        TSLog(@"游戏锁已开启: %@", model.isEnabled ? @"YES" : @"NO");
        TSLog(@"游戏锁密码: %@", model.password);
        TSLog(@"开始时间（分钟偏移）: %ld", (long)model.start);
        TSLog(@"结束时间（分钟偏移）: %ld", (long)model.end);
    }
}];
```

### 设置游戏锁配置

```objc
- (void)setGameLock:(TSGameLockModel *)gameLock completion:(TSCompletionBlock)completion;
```

设置设备的游戏锁配置。

**参数**

| 参数名 | 类型 | 说明 |
|-------|------|------|
| `gameLock` | `TSGameLockModel *` | 游戏锁模型，包含开启状态、6 位数字密码、开始和结束时间 |
| `completion` | `TSCompletionBlock` | 设置完成后的回调块；error 为错误对象（成功时为 nil） |

**代码示例**

```objc
id<TSPeripheralLockInterface> lockInterface = [TopStepComKit sharedInstance].peripheralLock;

TSGameLockModel *gameLock = [[TSGameLockModel alloc] init];
gameLock.isEnabled = YES;
gameLock.password = @"654321";
gameLock.start = 540;    // 09:00
gameLock.end = 1020;     // 17:00

[lockInterface setGameLock:gameLock completion:^(NSError * _Nullable error) {
    if (error) {
        TSLog(@"设置游戏锁失败: %@", error.localizedDescription);
    } else {
        TSLog(@"游戏锁设置成功");
    }
}];
```

## 注意事项

1. 密码必须为恰好 6 位的数字字符串（如 "123456"），不能包含其他字符，否则设置会失败。
2. 在设置锁之前，应先通过 `isSupportScreenLock` 或 `isSupportGameLock` 确认设备支持对应功能。
3. 查询和设置操作均为异步操作，必须通过回调块获取结果，不能阻塞主线程。
4. 游戏锁的时间段用分钟偏移表示，从 0（00:00）到 1439（23:59）；开始时间可以大于结束时间（跨午夜场景）。
5. 关闭锁（`isEnabled = NO`）时，密码字段可以为 nil 或任意值，但建议保持一致以避免混淆。
6. 设置操作后若成功，error 为 nil；若失败，error 包含详细错误信息，建议根据 error 提示用户。
7. 不同设备对密码的处理方式可能存在差异，设置前应确认目标设备的兼容性。