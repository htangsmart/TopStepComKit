---
sidebar_position: 5
title: AIChat
---

# AIChat

The AIChat module provides comprehensive AI device management and interaction capabilities, including device status monitoring, equalizer and noise reduction control, low latency mode configuration, device finding functionality, and AI chat session management with support for both text and voice communication channels.

## Prerequisites

- AI-capable device must be connected and paired with the iOS application
- Device must support AI chat functionality (verify with `isAIDeviceAPISupported`)
- Bluetooth connection must be active and stable
- Appropriate permissions for audio input/output must be granted by the user
- For voice wake-up features, device must support on-device wake-up capability

## Data Models

### TSAIDeviceBatteryInfoModel

Battery information for AI device.

| Property | Type | Description |
|----------|------|-------------|
| `batteryLevel` | `NSInteger` | Battery level from 0 to 100 representing the charge percentage |
| `isCharging` | `BOOL` | Indicates whether the device is currently charging |

### TSAIDeviceStatusInfoModel

Current status information for the AI device.

| Property | Type | Description |
|----------|------|-------------|
| `leftConnectionStatus` | `TSAIDeviceConnectionStatus` | Connection status of the left device |
| `rightConnectionStatus` | `TSAIDeviceConnectionStatus` | Connection status of the right device |
| `leftInCaseStatus` | `TSAIDeviceInCaseStatus` | In-case status of the left device |
| `rightInCaseStatus` | `TSAIDeviceInCaseStatus` | In-case status of the right device |
| `leftBatteryInfo` | `TSAIDeviceBatteryInfoModel *` | Battery information for the left device |
| `rightBatteryInfo` | `TSAIDeviceBatteryInfoModel *` | Battery information for the right device |

### TSAIDeviceFindStatusInfoModel

Find status information for the AI device.

| Property | Type | Description |
|----------|------|-------------|
| `leftFindStatus` | `TSAIDeviceFindStatus` | Find status of the left device |
| `rightFindStatus` | `TSAIDeviceFindStatus` | Find status of the right device |

## Enumerations

### TSAIChatStatusType

AI chat status types during conversation.

| Value | Description |
|-------|-------------|
| `TSAIChatStatusTypeEnterChatGPT` | Enter AI chat session |
| `TSAIChatStatusTypeStartRecording` | Start recording audio input |
| `TSAIChatStatusTypeEndRecording` | End recording audio input |
| `TSAIChatStatusTypeExitChatGPT` | Exit AI chat session |
| `TSAIChatStatusTypeReminderOpenApp` | Reminder to open app |
| `TSAIChatStatusTypeIdentificationFailed` | Speech recognition failed |
| `TSAIChatStatusTypeIdentificationSuccessful` | Speech recognition successful |
| `TSAIChatStatusTypeConfirmContent` | Confirm recognized content |
| `TSAIChatStatusTypeStartAnswer` | Start generating answer |
| `TSAIChatStatusTypeAnswerCompleted` | Answer generation completed |
| `TSAIChatStatusTypeAnswering` | Currently generating answer |
| `TSAIChatStatusTypeAbnormalNoNetWork` | Error: no network connection |
| `TSAIChatStatusTypeAbnormalSensitiveWord` | Error: sensitive word detected |
| `TSAIChatStatusTypeAbnormalCustom` | Error: custom error |

### TSAIDevicePresetEQ

Preset equalizer settings for the device.

| Value | Description |
|-------|-------------|
| `TSAIDevicePresetEQUnknown` | Unknown or unset equalizer |
| `TSAIDevicePresetEQSoundEffect1` | Sound Effect 1 preset |
| `TSAIDevicePresetEQSoundEffect2` | Sound Effect 2 preset |
| `TSAIDevicePresetEQSoundEffect3` | Sound Effect 3 preset |
| `TSAIDevicePresetEQSoundEffect4` | Sound Effect 4 preset |
| `TSAIDevicePresetEQSoundEffect5` | Sound Effect 5 preset |
| `TSAIDevicePresetEQSoundEffect6` | Sound Effect 6 preset |

### TSAIDeviceNoiseReductionMode

Noise reduction mode settings.

| Value | Description |
|-------|-------------|
| `TSAIDeviceNoiseReductionModeUnknown` | Unknown noise reduction mode |
| `TSAIDeviceNoiseReductionModeOff` | Noise reduction off |
| `TSAIDeviceNoiseReductionModeOn` | Noise reduction on |
| `TSAIDeviceNoiseReductionModeTransparency` | Transparency mode (hear ambient sound) |

### TSAIDeviceLowLatencyMode

Low latency mode settings.

| Value | Description |
|-------|-------------|
| `TSAIDeviceLowLatencyModeUnknown` | Unknown low latency mode |
| `TSAIDeviceLowLatencyModeOff` | Low latency mode off |
| `TSAIDeviceLowLatencyModeOn` | Low latency mode on |

### TSAIDeviceConnectionStatus

Device connection status.

| Value | Description |
|-------|-------------|
| `TSAIDeviceConnectionStatusUnknown` | Unknown connection status |
| `TSAIDeviceConnectionStatusDisconnected` | Device is disconnected |
| `TSAIDeviceConnectionStatusConnected` | Device is connected |

### TSAIDeviceInCaseStatus

Device in-case status.

| Value | Description |
|-------|-------------|
| `TSAIDeviceInCaseStatusUnknown` | Unknown in-case status |
| `TSAIDeviceInCaseStatusOut` | Device is out of case |
| `TSAIDeviceInCaseStatusIn` | Device is in case |

### TSAIDeviceFindStatus

Device find status.

| Value | Description |
|-------|-------------|
| `TSAIDeviceFindStatusUnknown` | Unknown find status |
| `TSAIDeviceFindStatusNotFinding` | Device is not in finding mode |
| `TSAIDeviceFindStatusFinding` | Device is currently finding (emitting sound) |

### TSAIDeviceFindEvent

Events related to device finding.

| Value | Description |
|-------|-------------|
| `TSAIDeviceFindEventUnknown` | Unknown find event |
| `TSAIDeviceFindEventFindLeft` | Start finding left device |
| `TSAIDeviceFindEventFindRight` | Start finding right device |
| `TSAIDeviceFindEventStopFindLeft` | Stop finding left device |
| `TSAIDeviceFindEventStopFindRight` | Stop finding right device |

### TSAIDeviceSide

Device side selection.

| Value | Description |
|-------|-------------|
| `TSAIDeviceSideLeft` | Left device/earbud |
| `TSAIDeviceSideRight` | Right device/earbud |

### TSAIDeviceChatSessionEvent

AI chat session events requested by device.

| Value | Description |
|-------|-------------|
| `TSAIDeviceChatSessionEventUnknown` | Unknown chat session event |
| `TSAIDeviceChatSessionEventTerminate` | Terminate current AI chat session |
| `TSAIDeviceChatSessionEventInitiateWithSCO` | Initiate new session via SCO channel |
| `TSAIDeviceChatSessionEventInitiateWithOpus` | Initiate new session via Opus encoding |

### TSAIChatAudioChannel

Audio channel type used for AI chat communication.

| Value | Description |
|-------|-------------|
| `TSAIChatAudioChannelUnknown` | Unknown or unavailable audio channel |
| `TSAIChatAudioChannelSco` | SCO (Synchronous Connection-Oriented) channel |
| `TSAIChatAudioChannelOpusInA2dpOut` | Opus encoded input with A2DP output |
| `TSAIChatAudioChannelOpusInOpusOut` | Opus encoded input and output |

### TSAIEnableState

Enable/disable state.

| Value | Description |
|-------|-------------|
| `TSAIEnableStateUnknown` | Unknown enable state |
| `TSAIEnableStateOff` | Feature is disabled |
| `TSAIEnableStateeOn` | Feature is enabled |

## Callback Types

### TSAIDeviceStatusBlock

```objc
typedef void(^TSAIDeviceStatusBlock)(TSAIDeviceStatusInfoModel *latestStatusInfo);
```

Invoked when device status changes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `latestStatusInfo` | `TSAIDeviceStatusInfoModel *` | Latest device status information model |

### TSAIDeviceEqualizerBlock

```objc
typedef void(^TSAIDeviceEqualizerBlock)(BOOL success, TSAIDevicePresetEQ currentEQ, NSError * _Nullable error);
```

Invoked when equalizer query completes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the query succeeded |
| `currentEQ` | `TSAIDevicePresetEQ` | Current equalizer preset |
| `error` | `NSError * _Nullable` | Error object if query failed, nil on success |

### TSAIDeviceNoiseReductionModeBlock

```objc
typedef void(^TSAIDeviceNoiseReductionModeBlock)(BOOL success, TSAIDeviceNoiseReductionMode mode, NSError * _Nullable error);
```

Invoked when noise reduction mode query completes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the query succeeded |
| `mode` | `TSAIDeviceNoiseReductionMode` | Current noise reduction mode |
| `error` | `NSError * _Nullable` | Error object if query failed, nil on success |

### TSAIDeviceLowLatencyModeBlock

```objc
typedef void(^TSAIDeviceLowLatencyModeBlock)(BOOL success, TSAIDeviceLowLatencyMode mode, NSError * _Nullable error);
```

Invoked when low latency mode query completes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the query succeeded |
| `mode` | `TSAIDeviceLowLatencyMode` | Current low latency mode |
| `error` | `NSError * _Nullable` | Error object if query failed, nil on success |

### TSAIDeviceStatusInfoBlock

```objc
typedef void(^TSAIDeviceStatusInfoBlock)(BOOL success, TSAIDeviceStatusInfoModel * _Nullable statusInfo, NSError * _Nullable error);
```

Invoked when device status information query completes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the query succeeded |
| `statusInfo` | `TSAIDeviceStatusInfoModel * _Nullable` | Device status information model, nil if error |
| `error` | `NSError * _Nullable` | Error object if query failed, nil on success |

### TSAIDeviceFirmwareVersionBlock

```objc
typedef void(^TSAIDeviceFirmwareVersionBlock)(BOOL success, NSString * _Nullable version, NSError * _Nullable error);
```

Invoked when firmware version query completes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the query succeeded |
| `version` | `NSString * _Nullable` | Firmware version string, nil if error |
| `error` | `NSError * _Nullable` | Error object if query failed, nil on success |

### TSAIDeviceFindStatusInfoBlock

```objc
typedef void(^TSAIDeviceFindStatusInfoBlock)(BOOL success, TSAIDeviceFindStatusInfoModel * _Nullable statusInfo, NSError * _Nullable error);
```

Invoked when find status information query completes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `success` | `BOOL` | Whether the query succeeded |
| `statusInfo` | `TSAIDeviceFindStatusInfoModel * _Nullable` | Device find status information model, nil if error |
| `error` | `NSError * _Nullable` | Error object if query failed, nil on success |

### TSAIDeviceFindEventBlock

```objc
typedef void(^TSAIDeviceFindEventBlock)(TSAIDeviceFindEvent findEvent);
```

Invoked when find status changes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `findEvent` | `TSAIDeviceFindEvent` | Find event type |

## API Reference

### Check if device supports AI chat

```objc
- (BOOL)isAIDeviceAPISupported;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| Return | `BOOL` | YES if device supports AI chat, NO otherwise |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
if ([aiManager isAIDeviceAPISupported]) {
    TSLog(@"Device supports AI chat");
} else {
    TSLog(@"Device does not support AI chat");
}
```

### Query current equalizer preset

```objc
- (void)queryAIDeviceEqualizerWithCompletion:(_Nullable TSAIDeviceEqualizerBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSAIDeviceEqualizerBlock` | Callback block invoked with query result |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager queryAIDeviceEqualizerWithCompletion:^(BOOL success, TSAIDevicePresetEQ currentEQ, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Current EQ: %ld", (long)currentEQ);
    } else {
        TSLog(@"Failed to query EQ: %@", error.localizedDescription);
    }
}];
```

### Set equalizer preset

```objc
- (void)setAIDeviceEqualizer:(TSAIDevicePresetEQ)eq
                  completion:(_Nullable TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `eq` | `TSAIDevicePresetEQ` | The equalizer preset to apply |
| `completion` | `TSCompletionBlock` | Callback block invoked when operation completes |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager setAIDeviceEqualizer:TSAIDevicePresetEQSoundEffect2 
                     completion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"EQ set successfully");
    } else {
        TSLog(@"Failed to set EQ: %@", error.localizedDescription);
    }
}];
```

### Register for equalizer change notifications

```objc
- (void)registerAIDeviceEqualizerDidChanged:(void(^ _Nullable )(TSAIDevicePresetEQ latestEQ))equalizerBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `equalizerBlock` | `void(^ _Nullable )(TSAIDevicePresetEQ)` | Callback invoked when device EQ changes |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager registerAIDeviceEqualizerDidChanged:^(TSAIDevicePresetEQ latestEQ) {
    TSLog(@"Device EQ changed to: %ld", (long)latestEQ);
}];
```

### Query current noise reduction mode

```objc
- (void)queryAIDeviceNoiseReductionModeWithCompletion:(_Nullable TSAIDeviceNoiseReductionModeBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSAIDeviceNoiseReductionModeBlock` | Callback block invoked with query result |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager queryAIDeviceNoiseReductionModeWithCompletion:^(BOOL success, TSAIDeviceNoiseReductionMode mode, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Current noise reduction mode: %ld", (long)mode);
    } else {
        TSLog(@"Failed to query noise reduction mode: %@", error.localizedDescription);
    }
}];
```

### Set noise reduction mode

```objc
- (void)setAIDeviceNoiseReductionMode:(TSAIDeviceNoiseReductionMode)mode
                           completion:(_Nullable TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | `TSAIDeviceNoiseReductionMode` | The noise reduction mode to apply |
| `completion` | `TSCompletionBlock` | Callback block invoked when operation completes |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager setAIDeviceNoiseReductionMode:TSAIDeviceNoiseReductionModeTransparency 
                              completion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Noise reduction mode set successfully");
    } else {
        TSLog(@"Failed to set noise reduction mode: %@", error.localizedDescription);
    }
}];
```

### Register for noise reduction mode change notifications

```objc
- (void)registerAIDeviceNoiseReductionModeDidChanged:(void(^ _Nullable )(TSAIDeviceNoiseReductionMode latestMode))noiseReductionModeBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `noiseReductionModeBlock` | `void(^ _Nullable )(TSAIDeviceNoiseReductionMode)` | Callback invoked when device noise reduction mode changes |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager registerAIDeviceNoiseReductionModeDidChanged:^(TSAIDeviceNoiseReductionMode latestMode) {
    TSLog(@"Device noise reduction mode changed to: %ld", (long)latestMode);
}];
```

### Query current low latency mode

```objc
- (void)queryAIDeviceLowLatencyModeWithCompletion:(_Nullable TSAIDeviceLowLatencyModeBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSAIDeviceLowLatencyModeBlock` | Callback block invoked with query result |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager queryAIDeviceLowLatencyModeWithCompletion:^(BOOL success, TSAIDeviceLowLatencyMode mode, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Current low latency mode: %ld", (long)mode);
    } else {
        TSLog(@"Failed to query low latency mode: %@", error.localizedDescription);
    }
}];
```

### Set low latency mode

```objc
- (void)setAIDeviceLowLatencyMode:(TSAIDeviceLowLatencyMode)mode
                       completion:(_Nullable TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | `TSAIDeviceLowLatencyMode` | The low latency mode to apply |
| `completion` | `TSCompletionBlock` | Callback block invoked when operation completes |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager setAIDeviceLowLatencyMode:TSAIDeviceLowLatencyModeOn 
                          completion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Low latency mode enabled");
    } else {
        TSLog(@"Failed to set low latency mode: %@", error.localizedDescription);
    }
}];
```

### Register for low latency mode change notifications

```objc
- (void)registerAIDeviceLowLatencyModeDidChanged:(void(^ _Nullable)(TSAIDeviceLowLatencyMode latestMode))lowLatencyModeBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `lowLatencyModeBlock` | `void(^ _Nullable)(TSAIDeviceLowLatencyMode)` | Callback invoked when device low latency mode changes |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager registerAIDeviceLowLatencyModeDidChanged:^(TSAIDeviceLowLatencyMode latestMode) {
    TSLog(@"Device low latency mode changed to: %ld", (long)latestMode);
}];
```

### Query device status

```objc
- (void)queryAIDeviceStatusWithCompletion:(_Nullable TSAIDeviceStatusInfoBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSAIDeviceStatusInfoBlock` | Callback block invoked with device status |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager queryAIDeviceStatusWithCompletion:^(BOOL success, TSAIDeviceStatusInfoModel * _Nullable statusInfo, NSError * _Nullable error) {
    if (success && statusInfo) {
        TSLog(@"Left connection: %ld, Right connection: %ld", 
              (long)statusInfo.leftConnectionStatus, 
              (long)statusInfo.rightConnectionStatus);
    } else {
        TSLog(@"Failed to query device status: %@", error.localizedDescription);
    }
}];
```

### Register for device status change notifications

```objc
- (void)registerAIDeviceStatusDidChanged:(void(^ _Nullable)(TSAIDeviceStatusInfoModel *latestStatusInfo))statusBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `statusBlock` | `void(^ _Nullable)(TSAIDeviceStatusInfoModel *)` | Callback invoked when device status changes |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager registerAIDeviceStatusDidChanged:^(TSAIDeviceStatusInfoModel *latestStatusInfo) {
    if (latestStatusInfo.leftBatteryInfo) {
        TSLog(@"Left battery: %ld%%", (long)latestStatusInfo.leftBatteryInfo.batteryLevel);
    }
}];
```

### Query firmware version

```objc
- (void)queryAIDeviceFirmwareVersionWithCompletion:(_Nullable TSAIDeviceFirmwareVersionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSAIDeviceFirmwareVersionBlock` | Callback block invoked with firmware version |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager queryAIDeviceFirmwareVersionWithCompletion:^(BOOL success, NSString * _Nullable version, NSError * _Nullable error) {
    if (success && version) {
        TSLog(@"Firmware version: %@", version);
    } else {
        TSLog(@"Failed to query firmware version: %@", error.localizedDescription);
    }
}];
```

### Query find status

```objc
- (void)queryAIDeviceFindStatusInfoWithCompletion:(_Nullable TSAIDeviceFindStatusInfoBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSAIDeviceFindStatusInfoBlock` | Callback block invoked with find status |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager queryAIDeviceFindStatusInfoWithCompletion:^(BOOL success, TSAIDeviceFindStatusInfoModel * _Nullable statusInfo, NSError * _Nullable error) {
    if (success && statusInfo) {
        TSLog(@"Left finding: %ld", (long)statusInfo.leftFindStatus);
    }
}];
```

### Trigger find device

```objc
- (void)findAIDeviceWithSide:(TSAIDeviceSide)side
                  completion:(_Nullable TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `side` | `TSAIDeviceSide` | The side to find (Left or Right) |
| `completion` | `TSCompletionBlock` | Callback block invoked when operation completes |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager findAIDeviceWithSide:TSAIDeviceSideLeft 
                     completion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Find initiated for left device");
    } else {
        TSLog(@"Failed to initiate find: %@", error.localizedDescription);
    }
}];
```

### Stop find device

```objc
- (void)stopFindAIDeviceWithSide:(TSAIDeviceSide)side
                      completion:(_Nullable TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `side` | `TSAIDeviceSide` | The side to stop finding (Left or Right) |
| `completion` | `TSCompletionBlock` | Callback block invoked when operation completes |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager stopFindAIDeviceWithSide:TSAIDeviceSideLeft 
                         completion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Find stopped for left device");
    } else {
        TSLog(@"Failed to stop find: %@", error.localizedDescription);
    }
}];
```

### Register for find status change notifications

```objc
- (void)registerAIDeviceFindStatusDidChanged:(_Nullable TSAIDeviceFindEventBlock)findEventBlock;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `findEventBlock` | `TSAIDeviceFindEventBlock` | Callback invoked when find status changes |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager registerAIDeviceFindStatusDidChanged:^(TSAIDeviceFindEvent findEvent) {
    switch (findEvent) {
        case TSAIDeviceFindEventFindLeft:
            TSLog(@"Finding left device");
            break;
        case TSAIDeviceFindEventStopFindLeft:
            TSLog(@"Stopped finding left device");
            break;
        default:
            break;
    }
}];
```

### Register for AI-chat session events

```objc
- (void)registerOnAIChatSessionEvent:(void(^_Nullable)(TSAIDeviceChatSessionEvent event))block;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `block` | `void(^_Nullable)(TSAIDeviceChatSessionEvent)` | Callback invoked when device requests AI-chat event |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager registerOnAIChatSessionEvent:^(TSAIDeviceChatSessionEvent event) {
    switch (event) {
        case TSAIDeviceChatSessionEventInitiateWithSCO:
            TSLog(@"Device requests to initiate AI chat via SCO");
            break;
        case TSAIDeviceChatSessionEventTerminate:
            TSLog(@"Device requests to terminate AI chat");
            break;
        default:
            break;
    }
}];
```

### Register for delta voice data

```objc
- (void)registerOnAIChatDeltaOpusVoiceData:(void(^_Nullable)(NSData * _Nullable deltaOpusVoiceData, NSData * _Nullable deltaVoiceData))block;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `block` | `void(^_Nullable)(NSData *, NSData *)` | Callback with Opus and PCM voice data |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager registerOnAIChatDeltaOpusVoiceData:^(NSData * _Nullable deltaOpusVoiceData, NSData * _Nullable deltaVoiceData) {
    if (deltaVoiceData) {
        TSLog(@"Received %lu bytes of PCM audio data", (unsigned long)deltaVoiceData.length);
    }
}];
```

### Send AI bridge data

```objc
- (void)sendAIBridgeData:(NSData *)data;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `NSData *` | The AI bridge data to send |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
NSData *aiBridgeData = [[NSData alloc] initWithBytes:"AI_DATA" length:7];
[aiManager sendAIBridgeData:aiBridgeData];
```

### Register for received AI bridge data

```objc
- (void)registerOnAIBridgeDataReceived:(void(^ _Nullable)(NSData *data))block;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `block` | `void(^ _Nullable)(NSData *)` | Callback when AI bridge data is received |

**Code Example:**

```objc
id<TSAIManagerInterface> aiManager = [tsDevice getInterface:@protocol(TSAIManagerInterface)];
[aiManager registerOnAIBridgeDataReceived:^(NSData *data) {
    TSLog(@"Received AI bridge data: %lu bytes", (unsigned long)data.length);
}];
```

### Send WP auth bridge data

```objc
- (void)sendWPAuthBridgeData:(NSData *)data;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `NSData *` | The WP auth bridge data to send |

**Code Example:**

```objc
id<TSAI