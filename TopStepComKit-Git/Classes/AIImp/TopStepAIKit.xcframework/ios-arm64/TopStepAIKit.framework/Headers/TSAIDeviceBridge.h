//
//  TSAIDeviceBridge.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIContractDefines.h"
#import "TSAIDefines.h"
#import "TSAudioRecordDefines.h"

@protocol TSAIDeviceBridgeEventSink;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Audio channel used by a device-side AI chat session
 * @chinese 设备侧 AI 对话会话使用的音频通道
 */
typedef NS_ENUM(NSInteger, TSAIDeviceBridgeChatAudioChannel) {
    TSAIDeviceBridgeChatAudioChannelUnknown = -1,
    TSAIDeviceBridgeChatAudioChannelSCO = 0,
    TSAIDeviceBridgeChatAudioChannelOpusInA2DPOut = 1,
    TSAIDeviceBridgeChatAudioChannelOpusInOpusOut = 2,
    TSAIDeviceBridgeChatAudioChannelPhoneMicrophone = 3,
};

/**
 * @brief Result type for writing question ASR text back to the device
 * @chinese 向设备回写问题 ASR 文本时使用的结果类型
 */
typedef NS_ENUM(NSInteger, TSAIDeviceQuestionASRResultType) {
    TSAIDeviceQuestionASRResultTypeUnknown = -1,
    TSAIDeviceQuestionASRResultTypeSuccess = 0,
    TSAIDeviceQuestionASRResultTypeCustomError = 1,
    TSAIDeviceQuestionASRResultTypeNetworkUnavailable = 2,
};

/**
 * @brief Result type for writing an AI answer back to the device
 * @chinese 向设备回写 AI 答案时使用的结果类型
 */
typedef NS_ENUM(NSInteger, TSAIDeviceQuestionAnswerResultType) {
    TSAIDeviceQuestionAnswerResultTypeCustomError = 0,
    TSAIDeviceQuestionAnswerResultTypeAnswer = 1,
    TSAIDeviceQuestionAnswerResultTypeNetworkUnavailable = 2,
    TSAIDeviceQuestionAnswerResultTypeUnknownError = 3,
};

/**
 * @brief Text type returned to a device voice-translation session
 * @chinese 回写设备语音翻译会话的文本类型
 */
typedef NS_ENUM(NSInteger, TSAIDeviceVoiceTranslationTextType) {
    TSAIDeviceVoiceTranslationTextTypeUnknown = -1,
    TSAIDeviceVoiceTranslationTextTypeOriginal = 0,
    TSAIDeviceVoiceTranslationTextTypeTranslated = 1,
};

/**
 * @brief Playback command requested by the device for translated speech
 * @chinese 设备请求的译文语音播放指令
 */
typedef NS_ENUM(NSInteger, TSAIDeviceVoicePlaybackState) {
    TSAIDeviceVoicePlaybackStateUnknown = -1,
    TSAIDeviceVoicePlaybackStateStopped = 0,
    TSAIDeviceVoicePlaybackStatePlaying = 1,
    TSAIDeviceVoicePlaybackStatePaused = 2,
    TSAIDeviceVoicePlaybackStateResumed = 3,
};

/**
 * @brief Root protocol bridging one device platform into AIKit
 * @chinese 将一个设备平台桥接到 AIKit 的根协议
 */
@protocol TSAIDeviceBridge <NSObject>

/**
 * @brief Stable platform identifier
 * @chinese 稳定的平台标识
 */
@property (nonatomic, copy, readonly) NSString *platformIdentifier;

/**
 * @brief Current device identifier
 * @chinese 当前设备标识
 */
@property (nonatomic, copy, readonly, nullable) NSString *deviceIdentifier;

/**
 * @brief Whether a device is connected
 * @chinese 当前是否已有设备连接
 * @return EN: YES when connected. CN: 设备已连接时返回 YES。
 */
- (BOOL)isDeviceConnected;

/**
 * @brief Activate event forwarding for one Context lifecycle
 * @chinese 为一次 Context 生命周期激活事件转发
 *
 * @param activationToken EN: Token identifying this activation. CN: 本次激活的标识。
 * @param eventSink EN: Sink receiving device events. CN: 接收设备事件的对象。
 * @param completion EN: Activation completion. CN: 激活完成回调。
 */
- (void)activateWithActivationToken:(NSString *)activationToken
                          eventSink:(id<TSAIDeviceBridgeEventSink>)eventSink
                         completion:(TSAICompletionBlock)completion;

/**
 * @brief Deactivate event forwarding
 * @chinese 停用事件转发
 * @param completion EN: Deactivation completion. CN: 停用完成回调。
 */
- (void)deactivateWithCompletion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Send raw provider authentication data to the device
 * @chinese 向设备发送 Provider 原始鉴权数据
 * @param data EN: Raw authentication data. CN: 原始鉴权数据。
 * @param completion EN: Send completion. Once called, the transport must
 *                    guarantee the command can no longer reach the device.
 *                    CN: 发送完成回调；回调后传输层必须保证该命令不会再到达设备。
 */
- (void)sendAuthenticationDataToDevice:(NSData *)data
                            completion:(nullable TSAICompletionBlock)completion;

@end

/**
 * @brief Optional device data-channel PCM output capability
 * @chinese 可选的设备数据通道 PCM 输出能力
 *
 * @discussion
 * [EN]: AIKit uses this bridge only for an explicitly resolved Opus output
 *       route. The payload format is fixed to signed Int16 little-endian PCM.
 * [CN]: AIKit 仅在明确解析为 Opus 输出路由时使用此 Bridge。
 *       数据格式固定为有符号 Int16 小端 PCM。
 */
@protocol TSAIDevicePCMOutputBridge <TSAIDeviceBridge>

/**
 * @brief Whether device data-channel PCM playback is currently available
 * @chinese 设备数据通道 PCM 播放当前是否可用
 * @return EN: YES when a playback session can be started. CN: 可启动播放会话时返回 YES。
 */
- (BOOL)isDevicePCMOutputAvailable;

/**
 * @brief Whether device-side echo cancellation is available for this route
 * @chinese 当前路由是否具备设备侧回声消除
 * @return EN: Device-side AEC state. CN: 设备侧 AEC 状态。
 */
- (BOOL)isDeviceSideEchoCancellationAvailable;

/**
 * @brief Start one PCM output session
 * @chinese 启动一个 PCM 输出会话
 * @param taskId EN: AI session identifier. CN: AI 会话标识。
 * @param sampleRate EN: PCM sample rate. CN: PCM 采样率。
 * @param channelCount EN: PCM channel count. CN: PCM 声道数。
 * @param bitsPerSample EN: PCM bits per sample. CN: PCM 位深。
 * @param completion EN: Start completion. CN: 启动完成回调。
 */
- (void)startPCMOutputForTaskId:(NSString *)taskId
                     sampleRate:(NSUInteger)sampleRate
                   channelCount:(NSUInteger)channelCount
                  bitsPerSample:(NSUInteger)bitsPerSample
                     completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Append ordered PCM data
 * @chinese 追加有序 PCM 数据
 * @param pcmData EN: Signed Int16LE PCM bytes. CN: 有符号 Int16LE PCM 数据。
 * @param taskId EN: AI session identifier. CN: AI 会话标识。
 * @param completion EN: Append completion. CN: 追加完成回调。
 */
- (void)appendPCMOutputData:(NSData *)pcmData
                     taskId:(NSString *)taskId
                  completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Finish one PCM output session
 * @chinese 正常结束一个 PCM 输出会话
 * @param taskId EN: AI session identifier. CN: AI 会话标识。
 * @param completion EN: Main-thread finish completion, invoked exactly once
 *                    for success, failure, invalid state, disconnection, or timeout.
 *                    CN: 主线程结束回调；成功、失败、状态非法、断连或超时均保证调用一次。
 */
- (void)finishPCMOutputForTaskId:(NSString *)taskId
                      completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Cancel one PCM output session
 * @chinese 取消一个 PCM 输出会话
 * @param taskId EN: AI session identifier. CN: AI 会话标识。
 * @param completion EN: Main-thread cancel completion. CN: 主线程取消回调。
 */
- (void)cancelPCMOutputForTaskId:(NSString *)taskId
                      completion:(nullable TSAICompletionBlock)completion;

@end

/**
 * @brief Device bridge capability for device-initiated AI question-answer
 * @chinese 设备发起 AI 问答的设备桥接能力
 */
@protocol TSAIDeviceQuestionAnswerBridge <TSAIDeviceBridge>

/**
 * @brief Whether the connected device supports AI question-answer
 * @chinese 当前连接设备是否支持 AI 问答
 * @return EN: YES when supported. CN: 支持时返回 YES。
 */
- (BOOL)isQuestionAnswerSupported;

/**
 * @brief Send the final question ASR result to the device
 * @chinese 向设备发送最终的问题 ASR 结果
 * @param text EN: Recognized question or custom error text. CN: 识别问题或自定义错误文本。
 * @param resultType EN: Normalized ASR result type. CN: 标准化 ASR 结果类型。
 * @param completion EN: Transport completion. CN: 传输完成回调。
 */
- (void)sendQuestionASRText:(nullable NSString *)text
                 resultType:(TSAIDeviceQuestionASRResultType)resultType
                 completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Send a cumulative AI answer snapshot to the device
 * @chinese 向设备发送 AI 答案累计快照
 * @param text EN: Cumulative answer or custom error text. CN: 累计答案或自定义错误文本。
 * @param isFinal EN: Whether this is the terminal snapshot. CN: 是否为终态快照。
 * @param resultType EN: Normalized answer result type. CN: 标准化答案结果类型。
 * @param completion EN: Transport completion. CN: 传输完成回调。
 */
- (void)sendQuestionAnswerText:(nullable NSString *)text
                       isFinal:(BOOL)isFinal
                    resultType:(TSAIDeviceQuestionAnswerResultType)resultType
                    completion:(nullable TSAICompletionBlock)completion;

@end

/**
 * @brief Device bridge capability for AI chat
 * @chinese AI 对话设备桥接能力
 */
@protocol TSAIAssistantDeviceBridge <TSAIDeviceBridge>

/** @brief Whether AI summary is supported @chinese 是否支持 AI 总结 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isAISummarySupported;

/** @brief Whether AI chat is supported @chinese 是否支持 AI 对话 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isAIChatSupported;

/** @brief Current AI chat audio channel @chinese 当前 AI 对话音频通道 @return EN: Audio channel. CN: 音频通道。 */
- (TSAIDeviceBridgeChatAudioChannel)aiChatAudioChannel;

/** @brief Report successful chat initiation @chinese 回报对话启动成功 @param completion EN: Report completion. CN: 回报完成回调。 */
- (void)reportAIChatSessionInitiateSuccess:(TSAICompletionBlock)completion;

/** @brief Report failed or terminated chat @chinese 回报对话启动失败或已终止 @param completion EN: Report completion. CN: 回报完成回调。 */
- (void)reportAIChatSessionInitiateFailedOrTerminated:(TSAICompletionBlock)completion;
@end

/**
 * @brief Device bridge capability for speech services
 * @chinese AI 语音服务设备桥接能力
 */
@protocol TSAISpeechDeviceBridge <TSAIDeviceBridge>

/** @brief Whether speech services are supported @chinese 是否支持 AI 语音服务 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isSpeechSupported;

/** @brief Whether device-microphone speech recognition is supported @chinese 是否支持设备麦克风语音识别 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isDeviceMicSpeechSupported;

/** @brief Whether offline speech recognition is supported @chinese 是否支持离线语音识别 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isOfflineSpeechSupported;

@end

/**
 * @brief Device bridge capability for text translation
 * @chinese AI 文本翻译设备桥接能力
 */
@protocol TSAITranslateDeviceBridge <TSAIDeviceBridge>

/** @brief Whether text translation is supported @chinese 是否支持 AI 文本翻译 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isTranslationSupported;

@end

/**
 * @brief Device bridge capability for AI interpretation
 * @chinese AI 同声传译设备桥接能力
 */
@protocol TSAIInterpreterDeviceBridge <TSAIDeviceBridge>

/**
 * @brief Whether AI interpretation is supported
 * @chinese 是否支持 AI 同声传译
 * @return EN: Support state. CN: 支持状态。
 */
- (BOOL)isInterpreterSupported;

@end

/**
 * @brief Device bridge capability for watch-initiated voice translation
 * @chinese 手表发起语音翻译的设备桥接能力
 */
@protocol TSAIDeviceVoiceTranslationBridge <TSAIInterpreterDeviceBridge>

/**
 * @brief Whether the connected device supports watch-initiated voice translation
 * @chinese 当前连接设备是否支持手表发起语音翻译
 * @return EN: Support state. CN: 支持状态。
 */
- (BOOL)isSupport;

/**
 * @brief Send an original or translated text snapshot to the device
 * @chinese 向设备发送原文或译文累计快照
 * @param text EN: Cumulative text snapshot. CN: 累计文本快照。
 * @param isFinal EN: Whether the current text snapshot is definitive for its
 *                text type and utterance. CN: 当前类型与句段的文本快照是否已定稿。
 * @param textType EN: Original or translated text type. CN: 原文或译文类型。
 * @param completion EN: Send completion. CN: 发送完成回调。
 */
- (void)sendVoiceTranslationText:(NSString *)text
                         isFinal:(BOOL)isFinal
                        textType:(TSAIDeviceVoiceTranslationTextType)textType
                      completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Report AI authentication failure to the current device
 * @chinese 向当前设备回报 AI 鉴权失败
 * @param completion EN: Report completion. CN: 上报完成回调。
 */
- (void)reportAIAuthenticationFailedWithCompletion:
    (nullable TSAICompletionBlock)completion;

@end

/**
 * @brief Device bridge capability for AI recording
 * @chinese AI 录音设备桥接能力
 */
@protocol TSAIAudioRecordDeviceBridge <TSAIDeviceBridge>

/** @brief Whether AI recording is supported @chinese 是否支持 AI 录音 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isAIAudioRecordingSupported;

/** @brief Whether call recording is supported @chinese 是否支持通话录音 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isCallAudioRecordingSupported;

/** @brief Whether normal recording is supported @chinese 是否支持普通录音 @return EN: Support state. CN: 支持状态。 */
- (BOOL)isNormalAudioRecordingSupported;

/**
 * @brief Report successful AI recording start
 * @chinese 回报 AI 录音启动成功
 * @param scene EN: Active recording scene. CN: 当前录音场景。
 * @param completion EN: Report completion. CN: 回报完成回调。
 */
- (void)reportAIAudioRecordingStartSuccessWithScene:(TSAIAudioRecordScene)scene
                                         completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Report that AI recording stopped
 * @chinese 回报 AI 录音已停止
 * @param completion EN: Report completion. CN: 回报完成回调。
 */
- (void)reportAIAudioRecordingStoppedWithCompletion:(nullable TSAICompletionBlock)completion;
@end

NS_ASSUME_NONNULL_END
