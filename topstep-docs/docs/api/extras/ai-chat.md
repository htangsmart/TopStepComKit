---
sidebar_position: 5
title: AI 聊天 (TSAIChat)
---

# AI 聊天 (TSAIChat)

AI 聊天模块提供了设备端 AI 功能的完整管理接口，包括设备状态查询、音频设置管理、设备查找、AI 聊天会话管理以及音频数据交互等功能。

## 前提条件

1. 设备必须支持 AI 聊天功能，可通过 `isAIDeviceAPISupported` 方法检查
2. 设备需要正常连接并可通信
3. 对于 AI 聊天功能，需要正确处理会话事件和音频数据回调
4. 对于语音唤醒功能，设备需要支持 `allowVoiceWakeUpOnDevice` 功能

## 数据模型

### TSAIDeviceBatteryInfoModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `batteryLevel` | `NSInteger` | 电池电量（0-100） |
| `isCharging` | `BOOL` | 设备是否正在充电 |

### TSAIDeviceStatusInfoModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `leftConnectionStatus` | `TSAIDeviceConnectionStatus` | 左设备连接状态 |
| `rightConnectionStatus` | `TSAIDeviceConnectionStatus` | 右设备连接状态 |
| `leftInCaseStatus` | `TSAIDeviceInCaseStatus` | 左设备在仓状态 |
| `rightInCaseStatus` | `TSAIDeviceInCaseStatus` | 右设备在仓状态 |
| `leftBatteryInfo` | `TSAIDeviceBatteryInfoModel *` | 左设备电池信息 |
| `rightBatteryInfo` | `TSAIDeviceBatteryInfoModel *` | 右设备电池信息 |

### TSAIDeviceFindStatusInfoModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `leftFindStatus` | `TSAIDeviceFindStatus` | 左设备查找状态 |
| `rightFindStatus` | `TSAIDeviceFindStatus` | 右设备查找状态 |

## 枚举与常量

### TSAIChatStatusType - AI 聊天状态类型

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIChatStatusTypeEnterChatGPT` | `0x01` | 进入 AI 聊天 |
| `TSAIChatStatusTypeStartRecording` | `0x02` | 开始录音 |
| `TSAIChatStatusTypeEndRecording` | `0x03` | 结束录音 |
| `TSAIChatStatusTypeExitChatGPT` | `0x04` | 退出 AI 聊天 |
| `TSAIChatStatusTypeReminderOpenApp` | `0x05` | 提醒打开 APP |
| `TSAIChatStatusTypeIdentificationFailed` | `0x06` | 识别失败 |
| `TSAIChatStatusTypeIdentificationSuccessful` | `0x07` | 识别成功 |
| `TSAIChatStatusTypeConfirmContent` | `0x08` | 确认内容 |
| `TSAIChatStatusTypeStartAnswer` | `0x09` | 开始回答 |
| `TSAIChatStatusTypeAnswerCompleted` | `0x0a` | 回答完成 |
| `TSAIChatStatusTypeAnswering` | `0x0b` | 回答中 |
| `TSAIChatStatusTypeAbnormalNoNetWork` | `0x0c` | 异常 - 无网络 |
| `TSAIChatStatusTypeAbnormalSensitiveWord` | `0x0d` | 异常 - 敏感词 |
| `TSAIChatStatusTypeAbnormalCustom` | `0x0e` | 异常 - 自定义 |

### TSAIDevicePresetEQ - 设备预设均衡器类型

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIDevicePresetEQUnknown` | `-1` | 未知 |
| `TSAIDevicePresetEQSoundEffect1` | `0` | 音效 1 |
| `TSAIDevicePresetEQSoundEffect2` | `1` | 音效 2 |
| `TSAIDevicePresetEQSoundEffect3` | `2` | 音效 3 |
| `TSAIDevicePresetEQSoundEffect4` | `3` | 音效 4 |
| `TSAIDevicePresetEQSoundEffect5` | `4` | 音效 5 |
| `TSAIDevicePresetEQSoundEffect6` | `5` | 音效 6 |

### TSAIDeviceNoiseReductionMode - 设备降噪模式类型

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIDeviceNoiseReductionModeUnknown` | `-1` | 未知 |
| `TSAIDeviceNoiseReductionModeOff` | `0` | 关闭 |
| `TSAIDeviceNoiseReductionModeOn` | `1` | 打开 |
| `TSAIDeviceNoiseReductionModeTransparency` | `2` | 通透模式 |

### TSAIDeviceLowLatencyMode - 设备低延迟模式类型

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIDeviceLowLatencyModeUnknown` | `-1` | 未知 |
| `TSAIDeviceLowLatencyModeOff` | `0` | 关闭 |
| `TSAIDeviceLowLatencyModeOn` | `1` | 开启 |

### TSAIDeviceConnectionStatus - 设备连接状态

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIDeviceConnectionStatusUnknown` | `-1` | 未知 |
| `TSAIDeviceConnectionStatusDisconnected` | `0` | 未连接 |
| `TSAIDeviceConnectionStatusConnected` | `1` | 已连接 |

### TSAIDeviceInCaseStatus - 设备在仓状态

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIDeviceInCaseStatusUnknown` | `-1` | 未知 |
| `TSAIDeviceInCaseStatusOut` | `0` | 不在仓 |
| `TSAIDeviceInCaseStatusIn` | `1` | 在仓 |

### TSAIDeviceFindStatus - 设备查找状态

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIDeviceFindStatusUnknown` | `-1` | 未知 |
| `TSAIDeviceFindStatusNotFinding` | `0` | 不在查找状态 |
| `TSAIDeviceFindStatusFinding` | `1` | 处于查找状态 |

### TSAIDeviceFindEvent - 设备查找事件

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIDeviceFindEventUnknown` | `-1` | 未知 |
| `TSAIDeviceFindEventFindLeft` | `0` | 查找左耳 |
| `TSAIDeviceFindEventFindRight` | `1` | 查找右耳 |
| `TSAIDeviceFindEventStopFindLeft` | `2` | 停止查找左耳 |
| `TSAIDeviceFindEventStopFindRight` | `3` | 停止查找右耳 |

### TSAIDeviceSide - 设备左右侧

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIDeviceSideLeft` | `0` | 左耳 |
| `TSAIDeviceSideRight` | `1` | 右耳 |

### TSAIDeviceChatSessionEvent - AI 设备聊天会话事件

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIDeviceChatSessionEventUnknown` | `-1` | 未知 |
| `TSAIDeviceChatSessionEventTerminate` | `0` | 结束当前 AI 聊天会话 |
| `TSAIDeviceChatSessionEventInitiateWithSCO` | `1` | 通过 SCO 发起新 AI 聊天会话 |
| `TSAIDeviceChatSessionEventInitiateWithOpus` | `2` | 通过 Opus 发起新 AI 聊天会话 |

### TSAIChatAudioChannel - AI 聊天音频通道类型

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIChatAudioChannelUnknown` | `-1` | 未知 |
| `TSAIChatAudioChannelSco` | `0` | SCO（同步面向连接）通道 |
| `TSAIChatAudioChannelOpusInA2dpOut` | `1` | Opus 编码输入，A2DP 输出通道 |
| `TSAIChatAudioChannelOpusInOpusOut` | `2` | Opus 编码输入，Opus 编码输出通道 |

### TSAIEnableState - 开关状态

| 枚举值 | 原始值 | 说明 |
|--------|--------|------|
| `TSAIEnableStateUnknown` | `-1` | 未知 |
| `TSAIEnableStateOff` | `0` | 关闭 |
| `TSAIEnableStateeOn` | `1` | 开启 |

## 回调类型

| 回调类型 | 说明 |
|---------|------|
| `void (^TSAIDeviceStatusBlock)(TSAIDeviceStatusInfoModel *latestStatusInfo)` | 设备状态变化回调，返回最新状态信息 |
| `void (^TSAIDeviceEqualizerBlock)(BOOL success, TSAIDevicePresetEQ currentEQ, NSError *_Nullable error)` | 均衡器查询回调，返回查询成功状态、当前预设和错误信息 |
| `void (^TSAIDeviceNoiseReductionModeBlock)(BOOL success, TSAIDeviceNoiseReductionMode mode, NSError *_Nullable error)` | 降噪模式查询回调，返回查询成功状态、当前模式和错误信息 |
| `void (^TSAIDeviceLowLatencyModeBlock)(BOOL success, TSAIDeviceLowLatencyMode mode, NSError *_Nullable error)` | 低延迟模式查询回调，返回查询成功状态、当前模式和错误信息 |
| `void (^TSAIDeviceStatusInfoBlock)(BOOL success, TSAIDeviceStatusInfoModel *_Nullable statusInfo, NSError *_Nullable error)` | 设备状态信息查询回调，返回查询成功状态、状态信息和错误信息 |
| `void (^TSAIDeviceFirmwareVersionBlock)(BOOL success, NSString *_Nullable version, NSError *_Nullable error)` | 固件版本查询回调，返回查询成功状态、版本字符串和错误信息 |
| `void (^TSAIDeviceFindStatusInfoBlock)(BOOL success, TSAIDeviceFindStatusInfoModel *_Nullable statusInfo, NSError *_Nullable error)` | 查找状态信息查询回调，返回查询成功状态、状态信息和错误信息 |
| `void (^TSAIDeviceFindEventBlock)(TSAIDeviceFindEvent findEvent)` | 设备查找事件回调，返回查找事件类型 |

## 接口方法

### 检查设备 AI 功能支持

#### 检查设备是否支持 AI 聊天

```objc
- (BOOL)isAIDeviceAPISupported;
```

**参数**

无

**返回值**

| 返回值 | 说明 |
|--------|------|
| `BOOL` | 如果设备支持 AI 聊天则返回 `YES`，否则返回 `NO` |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

if ([aiManager isAIDeviceAPISupported]) {
    TSLog(@"设备支持 AI 聊天功能");
} else {
    TSLog(@"设备不支持 AI 聊天功能");
}
```

### 设备均衡器管理

#### 查询当前均衡器预设

```objc
- (void)queryAIDeviceEqualizerWithCompletion:(_Nullable TSAIDeviceEqualizerBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSAIDeviceEqualizerBlock` | 查询结果完成回调，返回成功状态和当前预设和错误信息 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager queryAIDeviceEqualizerWithCompletion:^(BOOL success, TSAIDevicePresetEQ currentEQ, NSError *error) {
    if (success) {
        TSLog(@"当前均衡器预设: %ld", (long)currentEQ);
    } else {
        TSLog(@"查询失败: %@", error.localizedDescription);
    }
}];
```

#### 设置均衡器预设

```objc
- (void)setAIDeviceEqualizer:(TSAIDevicePresetEQ)eq
                  completion:(_Nullable TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `eq` | `TSAIDevicePresetEQ` | 要应用的均衡器预设 |
| `completion` | `TSCompletionBlock` | 操作完成回调 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager setAIDeviceEqualizer:TSAIDevicePresetEQSoundEffect3 completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"均衡器设置成功");
    } else {
        TSLog(@"设置失败: %@", error.localizedDescription);
    }
}];
```

#### 监听均衡器变化

```objc
- (void)registerAIDeviceEqualizerDidChanged:(void(^ _Nullable )(TSAIDevicePresetEQ latestEQ))equalizerBlock;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `equalizerBlock` | `void (^)(TSAIDevicePresetEQ latestEQ)` | 设备均衡器预设变化时触发的回调块 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager registerAIDeviceEqualizerDidChanged:^(TSAIDevicePresetEQ latestEQ) {
    TSLog(@"均衡器已变化为: %ld", (long)latestEQ);
}];
```

### 设备降噪模式管理

#### 查询当前降噪模式

```objc
- (void)queryAIDeviceNoiseReductionModeWithCompletion:(_Nullable TSAIDeviceNoiseReductionModeBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSAIDeviceNoiseReductionModeBlock` | 查询结果完成回调 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager queryAIDeviceNoiseReductionModeWithCompletion:^(BOOL success, TSAIDeviceNoiseReductionMode mode, NSError *error) {
    if (success) {
        NSString *modeStr;
        switch (mode) {
            case TSAIDeviceNoiseReductionModeOff:
                modeStr = @"关闭";
                break;
            case TSAIDeviceNoiseReductionModeOn:
                modeStr = @"打开";
                break;
            case TSAIDeviceNoiseReductionModeTransparency:
                modeStr = @"通透模式";
                break;
            default:
                modeStr = @"未知";
        }
        TSLog(@"当前降噪模式: %@", modeStr);
    } else {
        TSLog(@"查询失败: %@", error.localizedDescription);
    }
}];
```

#### 设置降噪模式

```objc
- (void)setAIDeviceNoiseReductionMode:(TSAIDeviceNoiseReductionMode)mode
                           completion:(_Nullable TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `mode` | `TSAIDeviceNoiseReductionMode` | 要应用的降噪模式 |
| `completion` | `TSCompletionBlock` | 操作完成回调 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager setAIDeviceNoiseReductionMode:TSAIDeviceNoiseReductionModeOn completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"降噪模式设置成功");
    } else {
        TSLog(@"设置失败: %@", error.localizedDescription);
    }
}];
```

#### 监听降噪模式变化

```objc
- (void)registerAIDeviceNoiseReductionModeDidChanged:(void(^ _Nullable )(TSAIDeviceNoiseReductionMode latestMode))noiseReductionModeBlock;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `noiseReductionModeBlock` | `void (^)(TSAIDeviceNoiseReductionMode latestMode)` | 设备降噪模式变化时触发的回调块 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager registerAIDeviceNoiseReductionModeDidChanged:^(TSAIDeviceNoiseReductionMode latestMode) {
    TSLog(@"降噪模式已变化为: %ld", (long)latestMode);
}];
```

### 设备低延迟模式管理

#### 查询当前低延迟模式

```objc
- (void)queryAIDeviceLowLatencyModeWithCompletion:(_Nullable TSAIDeviceLowLatencyModeBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSAIDeviceLowLatencyModeBlock` | 查询结果完成回调 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager queryAIDeviceLowLatencyModeWithCompletion:^(BOOL success, TSAIDeviceLowLatencyMode mode, NSError *error) {
    if (success) {
        NSString *modeStr = (mode == TSAIDeviceLowLatencyModeOn) ? @"开启" : @"关闭";
        TSLog(@"当前低延迟模式: %@", modeStr);
    } else {
        TSLog(@"查询失败: %@", error.localizedDescription);
    }
}];
```

#### 设置低延迟模式

```objc
- (void)setAIDeviceLowLatencyMode:(TSAIDeviceLowLatencyMode)mode
                       completion:(_Nullable TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `mode` | `TSAIDeviceLowLatencyMode` | 要应用的低延迟模式 |
| `completion` | `TSCompletionBlock` | 操作完成回调 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager setAIDeviceLowLatencyMode:TSAIDeviceLowLatencyModeOn completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"低延迟模式设置成功");
    } else {
        TSLog(@"设置失败: %@", error.localizedDescription);
    }
}];
```

#### 监听低延迟模式变化

```objc
- (void)registerAIDeviceLowLatencyModeDidChanged:(void(^ _Nullable)(TSAIDeviceLowLatencyMode latestMode))lowLatencyModeBlock;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `lowLatencyModeBlock` | `void (^)(TSAIDeviceLowLatencyMode latestMode)` | 设备低延迟模式变化时触发的回调块 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager registerAIDeviceLowLatencyModeDidChanged:^(TSAIDeviceLowLatencyMode latestMode) {
    TSLog(@"低延迟模式已变化为: %ld", (long)latestMode);
}];
```

### 设备状态查询

#### 查询设备状态信息

```objc
- (void)queryAIDeviceStatusWithCompletion:(_Nullable TSAIDeviceStatusInfoBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSAIDeviceStatusInfoBlock` | 查询结果完成回调 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager queryAIDeviceStatusWithCompletion:^(BOOL success, TSAIDeviceStatusInfoModel *statusInfo, NSError *error) {
    if (success && statusInfo) {
        TSLog(@"左设备连接状态: %ld", (long)statusInfo.leftConnectionStatus);
        TSLog(@"右设备连接状态: %ld", (long)statusInfo.rightConnectionStatus);
        if (statusInfo.leftBatteryInfo) {
            TSLog(@"左设备电量: %ld%%", (long)statusInfo.leftBatteryInfo.batteryLevel);
        }
        if (statusInfo.rightBatteryInfo) {
            TSLog(@"右设备电量: %ld%%", (long)statusInfo.rightBatteryInfo.batteryLevel);
        }
    } else {
        TSLog(@"查询失败: %@", error.localizedDescription);
    }
}];
```

#### 监听设备状态变化

```objc
- (void)registerAIDeviceStatusDidChanged:(void(^ _Nullable)(TSAIDeviceStatusInfoModel *latestStatusInfo))statusBlock;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `statusBlock` | `void (^)(TSAIDeviceStatusInfoModel *latestStatusInfo)` | 设备状态变化时触发的回调块 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager registerAIDeviceStatusDidChanged:^(TSAIDeviceStatusInfoModel *latestStatusInfo) {
    if (latestStatusInfo.leftBatteryInfo) {
        TSLog(@"左设备电量更新: %ld%%", (long)latestStatusInfo.leftBatteryInfo.batteryLevel);
    }
}];
```

### 固件版本查询

#### 查询固件版本

```objc
- (void)queryAIDeviceFirmwareVersionWithCompletion:(_Nullable TSAIDeviceFirmwareVersionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSAIDeviceFirmwareVersionBlock` | 查询结果完成回调 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager queryAIDeviceFirmwareVersionWithCompletion:^(BOOL success, NSString *version, NSError *error) {
    if (success) {
        TSLog(@"固件版本: %@", version);
    } else {
        TSLog(@"查询失败: %@", error.localizedDescription);
    }
}];
```

### 设备查找功能

#### 查询查找状态信息

```objc
- (void)queryAIDeviceFindStatusInfoWithCompletion:(_Nullable TSAIDeviceFindStatusInfoBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSAIDeviceFindStatusInfoBlock` | 查询结果完成回调 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager queryAIDeviceFindStatusInfoWithCompletion:^(BOOL success, TSAIDeviceFindStatusInfoModel *statusInfo, NSError *error) {
    if (success && statusInfo) {
        TSLog(@"左设备查找状态: %ld", (long)statusInfo.leftFindStatus);
        TSLog(@"右设备查找状态: %ld", (long)statusInfo.rightFindStatus);
    } else {
        TSLog(@"查询失败: %@", error.localizedDescription);
    }
}];
```

#### 触发设备查找功能

```objc
- (void)findAIDeviceWithSide:(TSAIDeviceSide)side
                  completion:(_Nullable TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `side` | `TSAIDeviceSide` | 要查找的设备侧（左或右） |
| `completion` | `TSCompletionBlock` | 操作完成回调 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager findAIDeviceWithSide:TSAIDeviceSideLeft completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"左耳设备查找功能已启动");
    } else {
        TSLog(@"启动失败: %@", error.localizedDescription);
    }
}];
```

#### 停止设备查找功能

```objc
- (void)stopFindAIDeviceWithSide:(TSAIDeviceSide)side
                      completion:(_Nullable TSCompletionBlock)completion;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `side` | `TSAIDeviceSide` | 要停止查找的设备侧（左或右） |
| `completion` | `TSCompletionBlock` | 操作完成回调 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager stopFindAIDeviceWithSide:TSAIDeviceSideLeft completion:^(BOOL success, NSError *error) {
    if (success) {
        TSLog(@"左耳设备查找功能已停止");
    } else {
        TSLog(@"停止失败: %@", error.localizedDescription);
    }
}];
```

#### 监听查找事件

```objc
- (void)registerAIDeviceFindStatusDidChanged:(_Nullable TSAIDeviceFindEventBlock)findEventBlock;
```

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `findEventBlock` | `void (^)(TSAIDeviceFindEvent findEvent)` | 设备查找状态变化时触发的回调块 |

**代码示例**

```objc
id<TSAIManagerInterface> aiManager = ...;

[aiManager registerAIDeviceFindStatusDidChanged:^(TSAIDeviceFindEvent findEvent) {
    switch (findEvent) {
        case TSAIDeviceFindEventFindLeft:
            TSLog(@"开始查找左耳");
            break;
        case TSAIDeviceFindEventFindRight:
            TSLog(@"开始查找右耳");
            break;
        case TSAIDeviceFindEventStopFindLeft:
            TSLog(@"停止查找左耳");
            break;
        case TSAIDeviceFindEventStopFindRight:
            TSLog(@"停止查找右耳");
            break;
        default:
            break;
    }
}];
```

### AI 聊天会话管理

#### 注册 AI 聊天会话事件

```objc