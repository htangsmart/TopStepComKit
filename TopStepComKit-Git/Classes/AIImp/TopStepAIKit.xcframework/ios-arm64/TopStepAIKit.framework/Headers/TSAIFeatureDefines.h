//
//  TSAIFeatureDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI features exposed by a Context
 * @chinese Context 对业务提供的 AI 功能
 *
 * @discussion
 * [EN]: Legacy discovery-only business-feature bits. Existing values are
 *       frozen for binary compatibility and must not authorize a start.
 *       Their values are independent from peripheral firmware capability
 *       bits exposed by TSPeripheralAIAbility.
 * [CN]: 仅用于兼容性发现查询的旧业务功能位。现有值因二进制
 *       兼容而冻结，不得作为启动授权。这些值与 TSPeripheralAIAbility
 *       中的 TSPeripheralAIScene 等外设固件能力位相互独立。
 */
typedef NS_OPTIONS(NSUInteger, TSAIFeatureOptions) {
    /// @brief No AI feature @chinese 不包含任何 AI 功能
    TSAIFeatureNone                         = 0,

    /// @brief AI text summary @chinese AI 文本总结
    TSAIFeatureAISummary                    = (1UL << 0),

    /// @brief Device-assisted AI chat @chinese 设备参与的 AI 对话
    TSAIFeatureAIChat                       = (1UL << 1),

    /// @brief App text translation @chinese App 文本翻译
    TSAIFeatureTextTranslation              = (1UL << 2),

    /// @brief Text-to-speech synthesis @chinese 文本转语音
    TSAIFeatureSpeechSynthesis              = (1UL << 3),

    /// @brief One-shot PCM recognition @chinese 单次 PCM 语音识别
    TSAIFeaturePCMRecognition               = (1UL << 4),

    /// @brief Audio-file recognition @chinese 音频文件语音识别
    TSAIFeatureFileRecognition              = (1UL << 5),

    /// @brief Device-microphone recognition @chinese 设备麦克风语音识别
    TSAIFeatureDeviceMicRecognition         = (1UL << 6),

    /// @brief Offline speech recognition @chinese 离线语音识别
    TSAIFeatureOfflineRecognition           = (1UL << 7),

    /// @brief App-initiated simultaneous interpretation @chinese App 发起的同声传译
    TSAIFeatureInterpretation               = (1UL << 8),

    /// @brief Device-assisted AI recording @chinese 设备参与的 AI 录音
    TSAIFeatureAIAudioRecording             = (1UL << 9),

    /// @brief Device-assisted call recording @chinese 设备参与的通话录音
    TSAIFeatureCallAudioRecording           = (1UL << 10),

    /// @brief Normal audio recording @chinese 普通录音
    TSAIFeatureNormalAudioRecording         = (1UL << 11),

    /// @brief App-initiated question answering @chinese App 发起的 AI 问答
    TSAIFeatureQuestionAnswering            = (1UL << 12),

    /// @brief Image generation @chinese 图片生成
    TSAIFeatureImageGeneration              = (1UL << 13),

    /// @brief Device-initiated voice translation @chinese 设备发起的语音翻译
    TSAIFeatureDeviceVoiceTranslation       = (1UL << 14),

    /// @brief Device-initiated question answering @chinese 设备发起的 AI 问答
    TSAIFeatureDeviceQuestionAnswering      = (1UL << 15),

    /// @brief Frozen legacy feature mask @chinese 已冻结的旧功能位掩码
    TSAIFeatureAll                          = 0xFFFF,
};

NS_ASSUME_NONNULL_END
