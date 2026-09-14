//
//  TSFitAIEventListener.h
//  TopStepFitKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>
#import <FitCloudKit/FitCloudKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Normalized Fit AI chat session event
 * @chinese 归一化后的 Fit AI 聊天会话事件
 */
typedef NS_ENUM(NSInteger, TSFitAIChatSessionEvent) {
    TSFitAIChatSessionEventUnknown = -1,
    TSFitAIChatSessionEventTerminate = 0,
    TSFitAIChatSessionEventInterrupted,
    TSFitAIChatSessionEventInitiateWithBluetoothSCO,
    TSFitAIChatSessionEventInitiateWithDeviceOpus,
    TSFitAIChatSessionEventInitiateWithPhoneMicrophone,
    TSFitAIChatSessionEventInitiateWithUnknownAudioSource,
};

/**
 * @brief Listener for raw Fit AI events
 * @chinese Fit 原始 AI 事件监听协议
 *
 * @discussion
 * [EN]: Callbacks are invoked synchronously on the event publishing thread.
 * [CN]: 所有回调均在事件发布线程同步执行。
 */
@protocol TSFitAIEventListener <NSObject>

/**
 * @brief Called when a device connection is ready
 * @chinese 设备连接就绪时调用
 *
 * @param deviceIdentifier
 * EN: Connected device identifier
 * CN: 已连接设备标识
 */
- (void)fitAIEventSourceDidConnectDeviceWithIdentifier:(NSString *)deviceIdentifier;

/**
 * @brief Called when the device disconnects
 * @chinese 设备断开连接时调用
 */
- (void)fitAIEventSourceDidDisconnectDevice;

/**
 * @brief Called when authentication data is received
 * @chinese 收到鉴权数据时调用
 *
 * @param data
 * EN: Raw authentication data
 * CN: 原始鉴权数据
 */
- (void)fitAIEventSourceDidReceiveAuthenticationData:(NSData *)data;

/**
 * @brief Called when an AI chat session event is received
 * @chinese 收到 AI 聊天会话事件时调用
 *
 * @param event
 * EN: Normalized Fit AI chat session event
 * CN: 归一化后的 Fit AI 聊天会话事件
 */
- (void)fitAIEventSourceDidReceiveChatSessionEvent:(TSFitAIChatSessionEvent)event;

/**
 * @brief Called when AI chat audio data is received
 * @chinese 收到 AI 聊天音频数据时调用
 *
 * @param opusData
 * EN: Raw Opus data, or nil when unavailable
 * CN: 原始 Opus 数据，不可用时为 nil
 *
 * @param pcmData
 * EN: Decoded PCM data, or nil when unavailable
 * CN: 解码后的 PCM 数据，不可用时为 nil
 */
- (void)fitAIEventSourceDidReceiveChatOpusData:(nullable NSData *)opusData
                                      pcmData:(nullable NSData *)pcmData;

/**
 * @brief Called when audio recording is requested
 * @chinese 请求开始录音时调用
 *
 * @param scene EN: Raw FitCloud audio recording scene. CN: FitCloud 原始录音场景。
 * @param audioSource EN: Audio source selected by the device. CN: 设备选择的音频源。
 */
- (void)fitAIEventSourceDidRequestStartAudioRecordingWithScene:(FitCloudAIAudioRecordingScene)scene
                                                   audioSource:(FitCloudAIAudioSource)audioSource;

/**
 * @brief Called when stopping audio recording is requested
 * @chinese 请求停止录音时调用
 * @param scene EN: Raw scene that ended. CN: 已结束的原始录音场景。
 */
- (void)fitAIEventSourceDidRequestStopAudioRecordingWithScene:
    (FitCloudAIAudioRecordingScene)scene;

/**
 * @brief Called when audio recording is interrupted
 * @chinese 录音被中断时调用
 *
 * @param scene EN: Raw scene that was interrupted. CN: 被中断的原始录音场景。
 * @param reason
 * EN: FitCloud device interruption reason
 * CN: FitCloud 设备中断原因
 */
- (void)fitAIEventSourceDidInterruptAudioRecordingWithScene:
            (FitCloudAIAudioRecordingScene)scene
                                                    reason:
            (FitCloudAIDeviceInterruptionReason)reason;

/**
 * @brief Called when audio recording data is received
 * @chinese 收到录音音频数据时调用
 *
 * @param opusData
 * EN: Raw Opus data, or nil when unavailable
 * CN: 原始 Opus 数据，不可用时为 nil
 *
 * @param pcmData
 * EN: Decoded PCM data, or nil when unavailable
 * CN: 解码后的 PCM 数据，不可用时为 nil
 */
- (void)fitAIEventSourceDidReceiveAudioRecordingOpusData:(nullable NSData *)opusData
                                                 pcmData:(nullable NSData *)pcmData;

@optional

/**
 * @brief Called when the watch enters AI question-answer
 * @chinese 手表进入 AI 问答时调用
 */
- (void)fitAIEventSourceDidEnterAIQuestionAnswer;

/**
 * @brief Called when the watch exits AI question-answer
 * @chinese 手表退出 AI 问答时调用
 */
- (void)fitAIEventSourceDidExitAIQuestionAnswer;

/**
 * @brief Called when a single AI question voice input begins
 * @chinese 单轮 AI 问答语音输入开始时调用
 */
- (void)fitAIEventSourceDidBeginAIQuestionAnswerVoice;

/**
 * @brief Called with AI question-answer audio data
 * @chinese 收到 AI 问答音频数据时调用
 *
 * @param opusData
 * EN: Raw Opus data, or nil when unavailable
 * CN: 原始 Opus 数据，不可用时为 nil
 *
 * @param pcmData
 * EN: Decoded PCM data, or nil when unavailable
 * CN: 解码后的 PCM 数据，不可用时为 nil
 */
- (void)fitAIEventSourceDidReceiveAIQuestionAnswerOpusData:(nullable NSData *)opusData
                                                   pcmData:(nullable NSData *)pcmData;

/**
 * @brief Called when a single AI question voice input stops
 * @chinese 单轮 AI 问答语音输入结束时调用
 */
- (void)fitAIEventSourceDidStopAIQuestionAnswerVoice;

/**
 * @brief Called when the watch confirms the recognized AI question
 * @chinese 手表确认 AI 问答识别问题时调用
 */
- (void)fitAIEventSourceDidConfirmAIQuestion;

/**
 * @brief Called when device voice translation begins
 * @chinese 设备语音翻译开始时调用
 */
- (void)fitAIEventSourceDidBeginTranslationVoice;

/**
 * @brief Called with incremental translation audio
 * @chinese 收到翻译增量音频时调用
 * @param opusData EN: Incremental Opus data. CN: 增量 Opus 数据。
 * @param pcmData EN: Incremental decoded PCM data. CN: 增量解码 PCM 数据。
 * @param sourceLanguage EN: Raw source language. CN: 原始源语言。
 * @param targetLanguage EN: Raw target language. CN: 原始目标语言。
 */
- (void)fitAIEventSourceDidReceiveTranslationDeltaOpusData:(nullable NSData *)opusData
                                                    pcmData:(nullable NSData *)pcmData
                                             sourceLanguage:(FITCLOUDLANGUAGE)sourceLanguage
                                             targetLanguage:(FITCLOUDLANGUAGE)targetLanguage;

/**
 * @brief Called when device voice capture stops
 * @chinese 设备翻译采音停止时调用
 * @param opusData EN: Full Opus data. CN: 完整 Opus 数据。
 * @param pcmData EN: Full decoded PCM data. CN: 完整解码 PCM 数据。
 * @param sourceLanguage EN: Raw source language. CN: 原始源语言。
 * @param targetLanguage EN: Raw target language. CN: 原始目标语言。
 */
- (void)fitAIEventSourceDidStopTranslationVoiceWithOpusData:(nullable NSData *)opusData
                                                     pcmData:(nullable NSData *)pcmData
                                              sourceLanguage:(FITCLOUDLANGUAGE)sourceLanguage
                                              targetLanguage:(FITCLOUDLANGUAGE)targetLanguage;

/**
 * @brief Called when the watch requests translated-speech playback state
 * @chinese 手表请求调整译文语音播放状态时调用
 * @param state EN: Raw FitCloud playback state. CN: FitCloud 原始播放状态。
 */
- (void)fitAIEventSourceDidRequestTranslatedVoicePlaybackState:
    (TranslatedTextVoicePlayingState)state;

/**
 * @brief Called when AI watch-face ASR capture begins
 * @chinese AI 表盘 ASR 采音开始时调用
 */
- (void)fitAIEventSourceDidBeginASRVoice;

/**
 * @brief Called with incremental AI watch-face ASR audio
 * @chinese 收到 AI 表盘 ASR 增量音频时调用
 * @param opusData EN: Incremental Opus data. CN: 增量 Opus 数据。
 * @param pcmData EN: Incremental decoded PCM data. CN: 增量解码 PCM 数据。
 */
- (void)fitAIEventSourceDidReceiveASRDeltaOpusData:(nullable NSData *)opusData
                                            pcmData:(nullable NSData *)pcmData;

/**
 * @brief Called when AI watch-face ASR capture stops
 * @chinese AI 表盘 ASR 采音停止时调用
 * @param opusData EN: Full Opus data. CN: 完整 Opus 数据。
 * @param pcmData EN: Full decoded PCM data. CN: 完整解码 PCM 数据。
 */
- (void)fitAIEventSourceDidStopASRVoiceWithOpusData:(nullable NSData *)opusData
                                             pcmData:(nullable NSData *)pcmData;

/**
 * @brief Called when the watch requests an AI watch face
 * @chinese 手表请求生成 AI 表盘时调用
 * @param prompt EN: Prompt reported by the watch, or nil. CN: 手表上报的提示词，可为 nil。
 * @param previewWidth EN: Requested preview width in pixels. CN: 请求的预览图像素宽度。
 * @param previewHeight EN: Requested preview height in pixels. CN: 请求的预览图像素高度。
 */
- (void)fitAIEventSourceDidRequestGenerateAIWatchFaceWithPrompt:(nullable NSString *)prompt
                                                   previewWidth:(NSInteger)previewWidth
                                                  previewHeight:(NSInteger)previewHeight;

/**
 * @brief Called with the watch's AI watch-face photo confirmation
 * @chinese 收到手表对 AI 表盘图片的确认结果时调用
 * @param confirmed EN: Whether the watch accepted the photo. CN: 手表是否接受该图片。
 */
- (void)fitAIEventSourceDidConfirmAIWatchFacePhoto:(BOOL)confirmed;

/**
 * @brief Called when the device requests a translation voice session
 * @chinese 设备请求开始一轮语音翻译时调用
 * @param mode EN: Requested translation mode. CN: 请求的翻译模式。
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 */
- (void)fitAIEventSourceDidRequestStartTranslationWithMode:
            (FitCloudAITranslationVoiceMode)mode
                                                audioSource:
            (FitCloudAIAudioSource)audioSource;

/**
 * @brief Called when the device cancels a translation voice session
 * @chinese 设备取消一轮语音翻译时调用
 * @param mode EN: Canceled translation mode. CN: 被取消的翻译模式。
 * @param reason EN: Device interruption reason. CN: 设备中断原因。
 */
- (void)fitAIEventSourceDidCancelTranslationWithMode:
            (FitCloudAITranslationVoiceMode)mode
                                                    reason:
            (FitCloudAIDeviceInterruptionReason)reason;

/**
 * @brief Called when the device requests to exit translation
 * @chinese 设备请求退出语音翻译时调用
 * @param mode EN: Translation mode being exited. CN: 正在退出的翻译模式。
 */
- (void)fitAIEventSourceDidRequestExitTranslationWithMode:
    (FitCloudAITranslationVoiceMode)mode;

/**
 * @brief Called when the device requests a single-turn question-answer session
 * @chinese 设备请求开始一轮 AI 问答时调用
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 */
- (void)fitAIEventSourceDidRequestStartAIQuestionAnswerWithAudioSource:
    (FitCloudAIAudioSource)audioSource;

/**
 * @brief Called when the device cancels question-answer voice input
 * @chinese 设备取消 AI 问答语音输入时调用
 * @param reason EN: Device interruption reason. CN: 设备中断原因。
 */
- (void)fitAIEventSourceDidCancelAIQuestionAnswerWithReason:
    (FitCloudAIDeviceInterruptionReason)reason;

/**
 * @brief Called when the device requests to exit question-answer
 * @chinese 设备请求退出 AI 问答时调用
 */
- (void)fitAIEventSourceDidRequestExitAIQuestionAnswer;

/**
 * @brief Called when the device requests an AI watch-face voice session
 * @chinese 设备请求开始一轮 AI 表盘语音输入时调用
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 */
- (void)fitAIEventSourceDidRequestStartAIWatchFaceWithAudioSource:
    (FitCloudAIAudioSource)audioSource;

/**
 * @brief Called when the device cancels AI watch-face voice input
 * @chinese 设备取消 AI 表盘语音输入时调用
 * @param reason EN: Device interruption reason. CN: 设备中断原因。
 */
- (void)fitAIEventSourceDidCancelAIWatchFaceWithReason:
    (FitCloudAIDeviceInterruptionReason)reason;

/**
 * @brief Called when the device requests to exit AI watch-face input
 * @chinese 设备请求退出 AI 表盘语音输入时调用
 */
- (void)fitAIEventSourceDidRequestExitAIWatchFace;

/**
 * @brief Called when the device requests a voice ride-hailing session
 * @chinese 设备请求开始一轮语音打车时调用
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 */
- (void)fitAIEventSourceDidRequestStartVoiceRideHailingWithAudioSource:
    (FitCloudAIAudioSource)audioSource;

/**
 * @brief Called when the device cancels voice ride-hailing input
 * @chinese 设备取消语音打车输入时调用
 * @param reason EN: Device interruption reason. CN: 设备中断原因。
 */
- (void)fitAIEventSourceDidCancelVoiceRideHailingWithReason:
    (FitCloudAIDeviceInterruptionReason)reason;

/**
 * @brief Called when the device requests to exit voice ride-hailing
 * @chinese 设备请求退出语音打车时调用
 */
- (void)fitAIEventSourceDidRequestExitVoiceRideHailing;

/**
 * @brief Called when voice ride-hailing audio data is received
 * @chinese 收到语音打车音频数据时调用
 * @param opusData EN: Opus data when available. CN: 可用时的 Opus 数据。
 * @param pcmData EN: Decoded PCM data when available. CN: 可用时的解码 PCM 数据。
 * @param isFinal EN: Whether this is the final voice chunk. CN: 是否为最终语音分片。
 */
- (void)fitAIEventSourceDidReceiveVoiceRideHailingOpusData:
        (nullable NSData *)opusData
                                                   pcmData:
        (nullable NSData *)pcmData
                                                   isFinal:
        (BOOL)isFinal;

@end

NS_ASSUME_NONNULL_END
