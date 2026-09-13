//
//  TSAICapabilityDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Binary support result for an AI capability
 * @chinese AI 能力的二态支持结果
 *
 * @discussion
 * [EN]: Missing, unloaded or unverified capabilities are Unsupported.
 * [CN]: 缺失、未加载或未经验证的能力一律视为不支持。
 */
typedef NS_ENUM(NSUInteger, TSAICapabilitySupport) {
    /// @brief The capability is not supported @chinese 不支持该能力
    TSAICapabilityUnsupported = 0,
    /// @brief The capability is supported @chinese 支持该能力
    TSAICapabilitySupported = 1,
};

/**
 * @brief Atomic capabilities supplied by an AI service Provider
 * @chinese AI 服务 Provider 提供的原子能力
 */
typedef NS_OPTIONS(NSUInteger, TSAIServiceCapabilityOptions) {
    /// @brief No AI service capability @chinese 不包含 AI 服务能力
    TSAIServiceCapabilityNone = 0,
    /// @brief Text summarization @chinese 文本总结
    TSAIServiceCapabilityTextSummarization = (1UL << 0),
    /// @brief Conversational AI @chinese 对话式 AI
    TSAIServiceCapabilityConversation = (1UL << 1),
    /// @brief Text translation @chinese 文本翻译
    TSAIServiceCapabilityTextTranslation = (1UL << 2),
    /// @brief Speech synthesis @chinese 语音合成
    TSAIServiceCapabilitySpeechSynthesis = (1UL << 3),
    /// @brief PCM speech recognition @chinese PCM 语音识别
    TSAIServiceCapabilityPCMRecognition = (1UL << 4),
    /// @brief Audio-file speech recognition @chinese 音频文件语音识别
    TSAIServiceCapabilityFileRecognition = (1UL << 5),
    /// @brief Offline speech recognition @chinese 离线语音识别
    TSAIServiceCapabilityOfflineRecognition = (1UL << 6),
    /// @brief Simultaneous interpretation @chinese 同声传译
    TSAIServiceCapabilityInterpretation = (1UL << 7),
    /// @brief AI recording processing @chinese AI 录音处理
    TSAIServiceCapabilityAudioRecordingProcessing = (1UL << 8),
    /// @brief Question answering @chinese AI 问答
    TSAIServiceCapabilityQuestionAnswering = (1UL << 9),
    /// @brief Image generation @chinese 图片生成
    TSAIServiceCapabilityImageGeneration = (1UL << 10),
};

/**
 * @brief AI business use cases evaluated before an operation starts
 * @chinese AI 操作启动前接受资格校验的业务用例
 */
typedef NS_ENUM(NSUInteger, TSAIUseCase) {
    /// @brief Invalid use case @chinese 非法用例
    TSAIUseCaseInvalid = 0,
    /// @brief Text summary @chinese 文本总结
    TSAIUseCaseTextSummary = 1,
    /// @brief AI chat @chinese AI 对话
    TSAIUseCaseChat = 2,
    /// @brief Text translation @chinese 文本翻译
    TSAIUseCaseTextTranslation = 3,
    /// @brief Speech synthesis @chinese 语音合成
    TSAIUseCaseSpeechSynthesis = 4,
    /// @brief PCM recognition @chinese PCM 语音识别
    TSAIUseCasePCMRecognition = 5,
    /// @brief File recognition @chinese 文件语音识别
    TSAIUseCaseFileRecognition = 6,
    /// @brief Offline recognition @chinese 离线语音识别
    TSAIUseCaseOfflineRecognition = 7,
    /// @brief Phone interpretation @chinese 手机同声传译
    TSAIUseCasePhoneInterpretation = 8,
    /// @brief AI recording @chinese AI 录音
    TSAIUseCaseAIRecording = 9,
    /// @brief Call recording @chinese 通话录音
    TSAIUseCaseCallRecording = 10,
    /// @brief Normal recording @chinese 普通录音
    TSAIUseCaseNormalRecording = 11,
    /// @brief Text question answering @chinese 文本 AI 问答
    TSAIUseCaseTextQuestionAnswer = 12,
    /// @brief Image generation @chinese 图片生成
    TSAIUseCaseImageGeneration = 13,
    /// @brief Voice translation @chinese 语音翻译
    TSAIUseCaseVoiceTranslation = 14,
    /// @brief Voice question answering @chinese 语音 AI 问答
    TSAIUseCaseVoiceQuestionAnswer = 15,
    /// @brief Voice watch-face creation @chinese 语音表盘制作
    TSAIUseCaseWatchFace = 16,
    /// @brief Voice ride hailing @chinese 语音打车
    TSAIUseCaseRideHailing = 17,
};

/**
 * @brief Device-side AI scenes independent from firmware bit positions
 * @chinese 与固件 bit 位置解耦的设备端 AI 场景
 */
typedef NS_ENUM(NSUInteger, TSAIDeviceAIScene) {
    /// @brief Invalid device scene @chinese 非法设备场景
    TSAIDeviceAISceneInvalid = 0,
    /// @brief Chat scene @chinese 对话场景
    TSAIDeviceAISceneChat = 1,
    /// @brief AI recording scene @chinese AI 录音场景
    TSAIDeviceAISceneRecording = 2,
    /// @brief Call recording scene @chinese 通话录音场景
    TSAIDeviceAISceneCallRecording = 3,
    /// @brief Standard translation scene @chinese 标准翻译场景
    TSAIDeviceAISceneTranslation = 4,
    /// @brief Ride-hailing scene @chinese 打车场景
    TSAIDeviceAISceneRideHailing = 5,
    /// @brief Watch-face scene @chinese 表盘场景
    TSAIDeviceAISceneWatchFace = 6,
    /// @brief Question-answer scene @chinese 问答场景
    TSAIDeviceAISceneQuestionAnswer = 7,
    /// @brief Self-side conversation translation @chinese 对话翻译自身侧
    TSAIDeviceAISceneTranslationSelf = 8,
    /// @brief Peer-side conversation translation @chinese 对话翻译对方侧
    TSAIDeviceAISceneTranslationPeer = 9,
};

/**
 * @brief Side that initiates a device-coordinated AI session
 * @chinese 发起设备协同 AI 会话的一侧
 */
typedef NS_ENUM(NSUInteger, TSAISessionInitiator) {
    /// @brief Invalid session initiator @chinese 非法会话发起方
    TSAISessionInitiatorInvalid = 0,
    /// @brief App initiates the device session @chinese App 发起设备会话
    TSAISessionInitiatorApp = 1,
    /// @brief Device initiates the session @chinese 设备发起会话
    TSAISessionInitiatorDevice = 2,
};

/**
 * @brief Discriminator for immutable use-case parameters
 * @chinese 不可变用例参数的类型判别值
 */
typedef NS_ENUM(NSUInteger, TSAIUseCaseParameterKind) {
    /// @brief No typed parameters @chinese 无强类型参数
    TSAIUseCaseParameterKindNone = 0,
    /// @brief Audio-recording parameters @chinese AI 录音参数
    TSAIUseCaseParameterKindAudioRecording = 1,
    /// @brief Voice-translation parameters @chinese 语音翻译参数
    TSAIUseCaseParameterKindVoiceTranslation = 2,
};

/**
 * @brief Voice-translation mode independent from a device Provider
 * @chinese 与设备 Provider 解耦的语音翻译模式
 */
typedef NS_ENUM(NSInteger, TSAIVoiceTranslationMode) {
    /// @brief Invalid translation mode @chinese 非法翻译模式
    TSAIVoiceTranslationModeInvalid = -1,
    /// @brief Standard one-way translation @chinese 标准单向翻译
    TSAIVoiceTranslationModeStandard = 0,
    /// @brief Self-side conversation utterance @chinese 对话翻译自身发言
    TSAIVoiceTranslationModeConversationSelf = 1,
    /// @brief Peer-side conversation utterance @chinese 对话翻译对方发言
    TSAIVoiceTranslationModeConversationPeer = 2,
};

/**
 * @brief Device conversation-translation product mode
 * @chinese 设备对话翻译产品模式
 */
typedef NS_ENUM(NSUInteger, TSAIConversationTranslationMode) {
    /// @brief Invalid or exited mode @chinese 非法或已退出模式
    TSAIConversationTranslationModeInvalid = 0,
    /// @brief Phone and charging case face-to-face mode @chinese 手机与充电仓面对面模式
    TSAIConversationTranslationModeFaceToFace = 1,
    /// @brief Earbuds and charging case private mode @chinese 耳机与充电仓私密模式
    TSAIConversationTranslationModePrivate = 2,
    /// @brief Phone and earbuds portable mode @chinese 手机与耳机便携模式
    TSAIConversationTranslationModePortable = 3,
};

NS_ASSUME_NONNULL_END
