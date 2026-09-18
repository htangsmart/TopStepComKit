//
//  TSNpkAIDeviceBridge.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import <TopStepAIKit/TSAIDeviceBridge.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device bridge exposing current NPK device capabilities to AIKit
 * @chinese 向 AIKit 暴露当前 NPK 设备能力的桥接器
 *
 * @discussion
 * [EN]: NPK has no device-side AI events or commands. Interpreter support only permits the
 * AIBuds provider to use the phone's built-in microphone, not a device or firmware capability.
 * [CN]: NPK 当前没有设备侧 AI 事件或命令；同声传译支持仅表示允许 AIBuds Provider
 * 使用手机内置麦克风，不代表设备麦克风或固件具备翻译能力。
 */
@interface TSNpkAIDeviceBridge : NSObject <
    TSAIDeviceBridge,
    TSAIAssistantDeviceBridge,
    TSAIInterpreterDeviceBridge,
    TSAISpeechDeviceBridge,
    TSAITranslateDeviceBridge,
    TSAIAudioRecordDeviceBridge
>

@end

NS_ASSUME_NONNULL_END
