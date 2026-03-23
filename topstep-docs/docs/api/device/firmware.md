---
sidebar_position: 4
title: 固件升级
---

# 固件升级（TSFirmwareUpgrade）

TSFirmwareUpgrade 模块提供完整的设备固件升级功能，包括升级条件检查、升级过程管理和升级取消等操作。通过此模块，您可以安全地为设备升级固件，并实时监控升级进度。

## 前提条件

1. 设备已与应用成功连接
2. 拥有有效的固件升级文件（`.bin` 或相应格式）
3. 设备电量充足（建议 30% 以上）
4. 应用具有读取本地文件的权限
5. 网络连接稳定（如需从远程服务器下载固件文件）

## 数据模型

| 属性名 | 类型 | 说明 |
|--------|------|------|
| （继承自 TSFileTransferModel） | `TSFileTransferModel *` | 固件升级模型，包含固件文件路径、设备标识等升级信息 |

## 枚举与常量

| 常量名 | 值 | 说明 |
|--------|-----|------|
| 进度范围 | `0-100` | 升级进度百分比，0 表示开始，100 表示完成 |

## 回调类型

| 回调类型 | 签名 | 说明 |
|---------|------|------|
| `TSFileTransferProgressBlock` | `void (^)(NSInteger progress)` | 升级进度回调，返回当前进度百分比（0-100） |
| `TSFileTransferSuccessBlock` | `void (^)(void)` | 升级成功回调 |
| `TSFileTransferFailureBlock` | `void (^)(NSError *error)` | 升级失败回调，返回错误信息 |
| `TSCompletionBlock` | `void (^)(BOOL success, NSError *_Nullable error)` | 通用完成回调 |

## 接口方法

### 检查固件升级条件

此方法在开始固件升级前检查各种条件，包括设备电量、固件文件有效性、版本兼容性、设备连接状态和升级状态。

```objc
- (void)checkFirmwareUpgradeConditions:(TSFileTransferModel *)model 
                             completion:(void (^)(BOOL canUpgrade, NSError * _Nullable error))completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `model` | `TSFileTransferModel *` | 包含升级信息的固件升级模型 |
| `completion` | `void (^)(BOOL canUpgrade, NSError * _Nullable error)` | 检查完成的回调，canUpgrade 表示是否可升级，error 为失败时的错误信息 |

**代码示例：**

```objc
TSFileTransferModel *upgradeModel = [[TSFileTransferModel alloc] init];
upgradeModel.filePath = @"/path/to/firmware.bin";
upgradeModel.deviceId = @"device123";

[self.firmwareUpgradeInterface checkFirmwareUpgradeConditions:upgradeModel 
                                                  completion:^(BOOL canUpgrade, NSError *error) {
    if (canUpgrade) {
        TSLog(@"设备可以升级");
        // 可以继续开始升级
    } else {
        TSLog(@"设备不能升级，错误：%@", error.localizedDescription);
    }
}];
```

### 开始固件升级

此方法启动固件升级过程。升级进度会通过进度回调多次报告，成功或失败时分别调用对应的回调。

```objc
- (void)startFirmwareUpgrade:(TSFileTransferModel *)model
                    progress:(nullable TSFileTransferProgressBlock)progress
                     success:(nullable TSFileTransferSuccessBlock)success
                     failure:(nullable TSFileTransferFailureBlock)failure;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `model` | `TSFileTransferModel *` | 包含升级信息的固件升级模型 |
| `progress` | `TSFileTransferProgressBlock` | 进度回调，返回当前升级进度（0-100），在升级过程中会被多次调用 |
| `success` | `TSFileTransferSuccessBlock` | 成功回调，当升级成功完成时调用 |
| `failure` | `TSFileTransferFailureBlock` | 失败回调，当升级失败或被取消时调用 |

**代码示例：**

```objc
TSFileTransferModel *upgradeModel = [[TSFileTransferModel alloc] init];
upgradeModel.filePath = @"/path/to/firmware.bin";
upgradeModel.deviceId = @"device123";

[self.firmwareUpgradeInterface startFirmwareUpgrade:upgradeModel
    progress:^(NSInteger progress) {
        TSLog(@"升级进度：%ld%%", (long)progress);
        // 更新 UI 进度条
        self.progressView.progress = progress / 100.0;
    }
    success:^{
        TSLog(@"固件升级成功");
        // 显示成功提示
        [self showAlertWithMessage:@"固件升级成功，请重启设备"];
    }
    failure:^(NSError *error) {
        TSLog(@"固件升级失败：%@", error.localizedDescription);
        // 显示失败提示
        [self showAlertWithMessage:[NSString stringWithFormat:@"升级失败：%@", error.localizedDescription]];
    }
];
```

### 取消固件升级

此方法用于取消当前正在进行的固件升级过程。

```objc
- (void)cancelFirmwareUpgrade:(TSCompletionBlock)completion;
```

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `void (^)(BOOL success, NSError *_Nullable error)` | 完成回调，success 表示取消是否成功，error 为失败时的错误信息 |

**代码示例：**

```objc
[self.firmwareUpgradeInterface cancelFirmwareUpgrade:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"固件升级已取消");
        [self showAlertWithMessage:@"升级已取消"];
    } else {
        TSLog(@"取消升级失败：%@", error.localizedDescription);
        [self showAlertWithMessage:[NSString stringWithFormat:@"取消失败：%@", error.localizedDescription]];
    }
}];
```

## 注意事项

1. **设备连接**：升级过程中请勿断开设备连接，断开连接会导致升级失败
2. **应用前台运行**：升级过程中请保持应用在前台运行，后台可能导致升级中断
3. **电量要求**：升级前请确保设备电量在 30% 以上，低电量可能导致升级失败或设备损坏
4. **禁止关闭设备**：升级过程中请勿关闭或重启设备，否则可能导致设备固件损坏
5. **条件检查**：开始升级前必须先调用 `checkFirmwareUpgradeConditions:completion:` 方法检查升级条件
6. **取消操作**：在关键升级阶段取消可能会使设备处于不稳定状态，请谨慎操作
7. **文件有效性**：确保提供的固件文件来自官方渠道，损坏或不兼容的文件会导致升级失败
8. **单次升级**：同一时间仅支持一个设备的升级过程，多设备升级需按顺序进行
9. **进度回调频率**：进度回调的调用频率取决于固件文件大小和设备性能，不应在回调中执行耗时操作
10. **错误处理**：务必处理升级过程中的所有错误回调，以便及时通知用户或采取补救措施