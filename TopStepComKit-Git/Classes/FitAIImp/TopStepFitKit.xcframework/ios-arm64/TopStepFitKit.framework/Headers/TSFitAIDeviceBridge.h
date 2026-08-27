//
//  TSFitAIDeviceBridge.h
//  TopStepFitKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import <TopStepAIKit/TSAIDeviceBridge.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device bridge connecting Fit platform capabilities to AIKit
 * @chinese 将 Fit 平台设备能力接入 AIKit 的桥接器
 *
 * @discussion
 * [EN]: Interpreter support permits the AIBuds provider to use the phone's built-in microphone.
 * It does not indicate device-microphone or firmware translation support.
 * [CN]: 同声传译支持仅表示允许 AIBuds Provider 使用手机内置麦克风，
 * 不代表设备麦克风或固件具备翻译能力。
 */
@interface TSFitAIDeviceBridge : NSObject <
    TSAIDeviceBridge,
    TSAIAssistantDeviceBridge,
    TSAIInterpreterDeviceBridge,
    TSAIDeviceQuestionAnswerBridge,
    TSAIDeviceVoiceTranslationBridge,
    TSAISpeechDeviceBridge,
    TSAITranslateDeviceBridge,
    TSAIAudioRecordDeviceBridge
>

@end

NS_ASSUME_NONNULL_END
