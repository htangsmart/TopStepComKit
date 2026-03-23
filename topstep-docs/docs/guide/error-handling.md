---
sidebar_position: 5
title: 错误处理
---

# 错误处理

SDK 所有异步接口均通过 `NSError` 返回错误信息。本文介绍错误的结构、完整错误码及最佳实践。

## 错误结构

SDK 返回的 `NSError` 包含以下字段：

| 字段 | 说明 |
|------|------|
| `domain` | 错误域，格式为 `TS[模块名]ErrorDomain`，如 `TSBleErrorDomain` |
| `code` | 错误码（见下方分类） |
| `userInfo[NSLocalizedDescriptionKey]` | 可读的错误描述 |
| `userInfo[NSUnderlyingErrorKey]` | 底层原始错误（如有） |

## 回调约定

SDK 的回调有两种模式：

### 1. TSCompletionBlock（成功/失败二值）

```objectivec
typedef void(^TSCompletionBlock)(BOOL isSuccess, NSError * _Nullable error);
```

```objectivec
[[TopStepComKit sharedInstance].bleConnector disconnectCompletion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        // 操作成功
    } else {
        [self handleError:error];
    }
}];
```

### 2. 数据回调（仅 error 参数）

```objectivec
[[TopStepComKit sharedInstance].heartRate getHistoryDataFrom:startDate to:endDate
                   completion:^(NSArray *records, NSError *error) {
    if (error) {
        [self handleError:error];
        return;
    }
    // 正常处理 records
}];
```

## 通用错误码（TSErrorCode）

适用于所有模块，定义在 `TSErrorEnum.h`。

### 系统错误（1001–1004）

| 枚举值 | Code | 含义 |
|--------|------|------|
| `eTSErrorUnknown` | 1001 | 未知错误 |
| `eTSErrorSDKInitFailed` | 1002 | SDK 初始化失败 |
| `eTSErrorLicenseIncorrect` | 1003 | SDK 证书错误 |
| `eTSErrorSDKConfigError` | 1004 | SDK 配置错误 |

### 设备状态错误（2001–2006）

| 枚举值 | Code | 含义 | 处理建议 |
|--------|------|------|---------|
| `eTSErrorNotReady` | 2001 | 设备未就绪 | 等待连接完成后重试 |
| `eTSErrorLowBattery` | 2002 | 设备电量过低（< 30%） | 提示用户充电 |
| `eTSErrorUnConnected` | 2003 | 设备未连接 | 提示用户重新连接设备 |
| `eTSErrorNotSupport` | 2004 | 暂不支持此功能 | 隐藏对应功能入口 |
| `eTSErrorNoSpace` | 2005 | 设备空间不足 | 提示用户清理设备存储 |
| `eTSErrorIsBusy` | 2006 | 设备繁忙 | 稍后重试 |

### 参数错误（3001–3004）

| 枚举值 | Code | 含义 |
|--------|------|------|
| `eTSErrorInvalidParam` | 3001 | 参数不存在 |
| `eTSErrorParamError` | 3002 | 参数错误 |
| `eTSErrorInvalidTypeError` | 3003 | 参数类型错误 |
| `eTSErrorParamSizeError` | 3004 | 参数大小错误 |

### 数据操作错误（4001–4004）

| 枚举值 | Code | 含义 |
|--------|------|------|
| `eTSErrorDataGetFailed` | 4001 | 数据获取失败 |
| `eTSErrorDataSetFailed` | 4002 | 数据设置失败 |
| `eTSErrorDataFormatError` | 4003 | 数据格式错误 |
| `eTSErrorDataIsEmpty` | 4004 | 数据为空 |

### 任务错误（5001–5003）

| 枚举值 | Code | 含义 | 处理建议 |
|--------|------|------|---------|
| `eTSErrorPreTaskExecuting` | 5001 | 任务执行中（如 OTA） | 等待任务完成后重试 |
| `eTSErrorTaskExecutionFailed` | 5002 | 任务执行失败 | 提示用户重试 |
| `eTSErrorTaskNotStarted` | 5003 | 任务未开始 | 检查调用时序 |

### 通信错误（6001–6008）

| 枚举值 | Code | 含义 | 处理建议 |
|--------|------|------|---------|
| `eTSErrorTimeoutError` | 6001 | 通信超时 | 重试操作 |
| `eTSErrorTransmissionInterrupted` | 6002 | 数据传输中断 | 检查设备距离，重试 |
| `eTSErrorSignalInterference` | 6003 | 信号干扰或丢失 | 减少干扰源，重试 |
| `eTSErrorPacketLoss` | 6004 | 数据包丢失 | 重试操作 |
| `eTSErrorProtocolMismatch` | 6005 | 通信协议不匹配 | 升级 SDK 或固件 |
| `eTSErrorConnectionReset` | 6006 | 连接被对方重置 | 重新连接设备 |
| `eTSErrorBufferOverflow` | 6007 | 通信缓冲区溢出 | 降低发送频率 |
| `eTSErrorChannelBusy` | 6008 | 通信通道繁忙 | 稍后重试 |

### 用户操作错误（7001）

| 枚举值 | Code | 含义 |
|--------|------|------|
| `eTSErrorUserCancelled` | 7001 | 用户取消操作 |

## 蓝牙连接错误码（TSBleConnectionError）

蓝牙专属错误，定义在 `TSErrorEnum.h`，通过 `error.code` 获取。

### 参数错误（9001–9004）

| 枚举值 | Code | 含义 |
|--------|------|------|
| `eTSBleErrorInvalidRandomCode` | 9001 | 二维码参数错误 |
| `eTSBleErrorInvalidUserId` | 9002 | 用户 ID 参数错误 |
| `eTSBleErrorInvalidParam` | 9003 | 参数错误 |
| `eTSBleErrorInvalidHandle` | 9004 | 无效句柄 |

### 通用错误（9101–9106）

| 枚举值 | Code | 含义 | 处理建议 |
|--------|------|------|---------|
| `eTSBleErrorUnknown` | 9101 | 未知错误 | 提示用户重试 |
| `eTSBleErrorTimeout` | 9102 | 连接超时 | 检查设备是否在范围内，重试 |
| `eTSBleErrorDisconnected` | 9103 | 连接意外断开 | 提示用户重新连接 |
| `eTSBleErrorOutOfSpace` | 9104 | 存储空间不足 | 提示用户清理设备 |
| `eTSBleErrorUUIDNotAllowed` | 9105 | UUID 不被允许 | 检查设备兼容性 |
| `eTSBleErrorAlreadyAdvertising` | 9106 | 已在广播中 | 等待广播结束后重试 |

### 权限和系统错误（9201–9206）

| 枚举值 | Code | 含义 | 处理建议 |
|--------|------|------|---------|
| `eTSBleErrorBluetoothOff` | 9201 | 蓝牙未开启 | 提示用户打开系统蓝牙 |
| `eTSBleErrorBluetoothUnsupported` | 9202 | 蓝牙不支持 | 提示设备不支持蓝牙 |
| `eTSBleErrorPermissionDenied` | 9203 | 缺少蓝牙权限 | 引导用户前往「设置」开启蓝牙权限 |
| `eTSBleErrorSystemServiceUnavailable` | 9204 | 系统蓝牙服务不可用 | 提示用户重启手机 |
| `eTSBleErrorBluetoothStateUnknown` | 9205 | 蓝牙状态未知 | 等待蓝牙就绪后重试 |
| `eTSBleErrorBluetoothResetting` | 9206 | 蓝牙正在重置 | 等待重置完成后重试 |

### 连接过程错误（9301–9308）

| 枚举值 | Code | 含义 | 处理建议 |
|--------|------|------|---------|
| `eTSBleErrorConnectionFailed` | 9301 | 连接失败 | 重试连接 |
| `eTSBleErrorGattConnectFailed` | 9302 | GATT 连接失败 | 重启蓝牙后重试 |
| `eTSBleErrorDeviceOutOfRange` | 9303 | 设备不在范围内 | 靠近设备后重试 |
| `eTSBleErrorWeakSignal` | 9304 | 信号太弱 | 靠近设备后重试 |
| `eTSBleErrorSignalLost` | 9305 | 信号丢失 | 靠近设备后重试 |
| `eTSBleErrorConnectionLimitReached` | 9306 | 连接数达到限制 | 断开其他连接后重试 |
| `eTSBleErrorUnknownDevice` | 9307 | 未知设备 | 重新扫描并选择设备 |
| `eTSBleErrorOperationNotSupported` | 9308 | 操作不支持 | 检查设备固件版本 |

### 认证错误（9404–9413、9499）

| 枚举值 | Code | 含义 | 处理建议 |
|--------|------|------|---------|
| `eTSBleErrorEncryptionFailed` | 9404 | 加密失败 | 重新绑定设备 |
| `eTSBleErrorPeerRemovedPairingInfo` | 9405 | 配对信息被移除 | 重新绑定设备 |
| `eTSBleErrorEncryptionTimeout` | 9406 | 加密超时 | 重试连接 |
| `eTSBleErrorUserIdMismatch` | 9407 | 用户 ID 不匹配 | 检查 userId 参数 |
| `eTSBleErrorBindCancelledByUser` | 9408 | 用户取消绑定 | 引导用户重新操作 |
| `eTSBleErrorBindTimeout` | 9409 | 绑定超时 | 重新发起绑定 |
| `eTSBleErrorClassicBluetoothNotConnected` | 9410 | 经典蓝牙未连接 | 检查经典蓝牙连接状态 |
| `eTSBleErrorLowBatteryCannotDeleteData` | 9411 | 电量不足无法删除数据 | 提示用户充电 |
| `eTSBleErrorDeviceFactoryResetting` | 9412 | 设备正在恢复出厂 | 等待恢复完成后重试 |
| `eTSBleErrorFactoryResetRequired` | 9413 | 需要恢复出厂才能重新绑定 | 提示用户在设备上恢复出厂设置 |
| `eTSBleErrorAuthenticationUnknown` | 9499 | 认证失败（未知原因） | 重试连接 |

### 设备状态错误（9501–9506）

| 枚举值 | Code | 含义 | 处理建议 |
|--------|------|------|---------|
| `eTSBleErrorConnectedByOthers` | 9501 | 设备已被其他设备连接 | 提示用户断开其他连接 |
| `eTSBleErrorDeviceAlreadyBound` | 9502 | 设备已被绑定 | 提示用户先解绑 |
| `eTSBleErrorLowBattery` | 9503 | 设备电量过低 | 提示用户充电 |
| `eTSBleErrorDFUMode` | 9504 | 设备进入 DFU 模式 | 等待 DFU 完成或重启设备 |
| `eTSBleErrorDeviceSleeping` | 9505 | 设备处于睡眠模式 | 唤醒设备后重试 |
| `eTSBleErrorTooManyPairedDevices` | 9506 | 配对设备过多 | 删除部分配对记录 |

### 服务和协议错误（9601–9605）

| 枚举值 | Code | 含义 | 处理建议 |
|--------|------|------|---------|
| `eTSBleErrorPeripheralNotFound` | 9601 | 未找到对应外设 | 重新扫描设备 |
| `eTSBleErrorServiceNotFound` | 9602 | 未找到所需服务 | 检查设备固件版本 |
| `eTSBleErrorCharacteristicNotFound` | 9603 | 特征值未找到 | 检查设备固件版本 |
| `eTSBleErrorProtocolVersionMismatch` | 9604 | 协议版本不匹配 | 升级 SDK 或固件 |
| `eTSBleErrorMtuNegotiationFailed` | 9605 | MTU 协商失败 | 重试连接 |

### 用户操作（9701–9702）

| 枚举值 | Code | 含义 |
|--------|------|------|
| `eTSBleErrorDisconnectedByUser` | 9701 | 用户主动断开连接 |
| `eTSBleErrorCancelledByUser` | 9702 | 用户取消连接 |

## 扫描结束原因（TSScanCompletionReason）

| 枚举值 | 含义 | 处理建议 |
|--------|------|---------|
| `eTSScanCompleteReasonTimeout` | 扫描超时 | 提示未找到设备，可重新扫描 |
| `eTSScanCompleteReasonBleNotReady` | 蓝牙未就绪 | 等待蓝牙初始化完成后重试 |
| `eTSScanCompleteReasonPermissionDenied` | 权限被拒绝 | 引导用户开启蓝牙权限 |
| `eTSScanCompleteReasonUserStopped` | 用户主动停止 | 正常结束，无需处理 |
| `eTSScanCompleteReasonSystemError` | 系统错误 | 重启蓝牙后重试 |

## 功能不支持检查

调用功能接口前，先用 `isSupport` 检查设备是否支持：

```objectivec
id<TSHeartRateInterface> heartRate = [TopStepComKit sharedInstance].heartRate;

if (![heartRate isSupport]) {
    TSLog(@"当前设备不支持心率功能");
    return;
}

[heartRate startMeasureWithParam:nil ...];
```

## 统一错误处理

建议封装一个统一的错误处理方法：

```objectivec
- (void)handleSDKError:(NSError *)error context:(NSString *)context {
    if (!error) return;

    TSLog(@"[%@] 错误 domain=%@ code=%ld: %@",
          context,
          error.domain,
          (long)error.code,
          error.localizedDescription);

    switch (error.code) {
        // 权限/蓝牙状态类 → 引导用户操作
        case eTSBleErrorPermissionDenied:
        case eTSBleErrorBluetoothOff:
            [self showBluetoothSettingsAlert];
            break;

        // 超时/信号类 → 可重试
        case eTSBleErrorTimeout:
        case eTSBleErrorSignalLost:
        case eTSErrorTimeoutError:
            [self retryWithDelay];
            break;

        // 设备繁忙 → 稍后重试
        case eTSErrorIsBusy:
        case eTSBleErrorChannelBusy:
            [self scheduleRetry];
            break;

        // 功能不支持 → 隐藏入口
        case eTSErrorNotSupport:
            [self hideUnsupportedFeature:context];
            break;

        default:
            [self showErrorAlert:error.localizedDescription];
            break;
    }
}
```

## 权限错误处理

```objectivec
- (void)showBluetoothSettingsAlert {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"蓝牙未授权"
                         message:@"请前往「设置 → 隐私 → 蓝牙」开启蓝牙权限"
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"去设置"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}
```

## 注意事项

1. **不要忽略 error 参数**：即使 `isSuccess = YES`，仍应先判断 error 再判断 isSuccess
2. **在主线程更新 UI**：SDK 所有回调均在主线程执行，可直接操作 UI
3. **区分可恢复错误和不可恢复错误**：超时类错误可重试，权限类错误需引导用户操作，硬件不支持类错误应隐藏对应功能入口
4. **日志上报**：建议将 `error.domain`、`error.code` 上报到后端，便于排查问题
