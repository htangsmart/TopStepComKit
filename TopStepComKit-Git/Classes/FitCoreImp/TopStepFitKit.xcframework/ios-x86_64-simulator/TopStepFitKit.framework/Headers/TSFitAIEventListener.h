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
 * EN: Raw FitCloud chat session event
 * CN: FitCloud 原始聊天会话事件
 */
- (void)fitAIEventSourceDidReceiveChatSessionEvent:(FitCloudAIChatSessionEvent)event;

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
 * @param scene
 * EN: Raw FitCloud audio recording scene
 * CN: FitCloud 原始录音场景
 */
- (void)fitAIEventSourceDidRequestStartAudioRecordingWithScene:(FitCloudAIAudioRecordingScene)scene;

/**
 * @brief Called when stopping audio recording is requested
 * @chinese 请求停止录音时调用
 */
- (void)fitAIEventSourceDidRequestStopAudioRecording;

/**
 * @brief Called when audio recording is interrupted
 * @chinese 录音被中断时调用
 *
 * @param reason
 * EN: Raw FitCloud audio recording interruption reason
 * CN: FitCloud 原始录音中断原因
 */
- (void)fitAIEventSourceDidInterruptAudioRecording:
    (FitCloudAIAudioRecordingTerminateWithInterruptReason)reason;

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

@end

NS_ASSUME_NONNULL_END
