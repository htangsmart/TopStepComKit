//
//  TSNpkAIDeviceBridge.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import <TopStepAIKit/TSAIDeviceBridge.h>
#import <TopStepAIKit/TSAIDeviceAISessionBridge.h>
#import <TopStepAIKit/TSAIDeviceAICapabilityProviding.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device bridge exposing current NPK device capabilities to AIKit
 * @chinese 向 AIKit 暴露当前 NPK 设备能力的桥接器
 *
 * @discussion
 * [EN]: Device chat, question-answer, recording, single-round translation and AI watch-face
 *       sessions use authenticated information and an owned speech consumer lease.
 *       The framing profile is resolved after OpusHead for a verified firmware mapping;
 *       unknown mappings remain unsupported. Phone-side services preserve their existing behavior.
 * [CN]: 设备对话、问答、录音、单轮翻译及 AI 表盘使用已认证信息和具归属的语音消费者租约；
 *       已核验固件在收到 OpusHead 后解析帧界，未知映射继续按不支持处理。
 *       手机侧服务保持原行为。
 */
@interface TSNpkAIDeviceBridge : NSObject <
    TSAIDeviceBridge,
    TSAIDeviceBusinessLifecycle,
    TSAIDeviceAISessionBridge,
    TSAIDeviceAICapabilityProviding,
    TSAIDeviceQuestionAnswerBridge,
    TSAIAssistantDeviceBridge,
    TSAIInterpreterDeviceBridge,
    TSAIDeviceVoiceTranslationBridge,
    TSAISpeechDeviceBridge,
    TSAITranslateDeviceBridge,
    TSAIAudioRecordDeviceBridge
>

@end

NS_ASSUME_NONNULL_END
