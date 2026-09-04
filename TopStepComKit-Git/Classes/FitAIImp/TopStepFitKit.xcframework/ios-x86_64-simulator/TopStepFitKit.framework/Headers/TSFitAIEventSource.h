//
//  TSFitAIEventSource.h
//  TopStepFitKit
//
//  Created by Codex on 2026/7/31.
//

#import "TSFitAIEventListener.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Source for raw Fit AI events
 * @chinese Fit 原始 AI 事件源
 *
 * @discussion
 * [EN]: Listeners are held weakly and callbacks run synchronously on the publishing thread.
 * [CN]: 监听者使用弱引用保存，回调在事件发布线程同步执行。
 */
@interface TSFitAIEventSource : NSObject

/**
 * @brief Shared event source
 * @chinese 共享事件源
 *
 * @return
 * EN: The shared event source
 * CN: 共享事件源
 */
+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Add an event listener
 * @chinese 添加事件监听者
 *
 * @param listener
 * EN: Listener held weakly by the event source
 * CN: 由事件源弱引用保存的监听者
 */
- (void)addListener:(id<TSFitAIEventListener>)listener;

/**
 * @brief Remove an event listener
 * @chinese 移除事件监听者
 *
 * @param listener
 * EN: Listener to remove
 * CN: 要移除的监听者
 */
- (void)removeListener:(id<TSFitAIEventListener>)listener;

/**
 * @brief Publish a device connection event
 * @chinese 发布设备连接事件
 *
 * @param deviceIdentifier
 * EN: Connected device identifier
 * CN: 已连接设备标识
 */
- (void)publishDeviceConnectedWithIdentifier:(NSString *)deviceIdentifier;

/**
 * @brief Publish a device disconnection event
 * @chinese 发布设备断开事件
 */
- (void)publishDeviceDisconnected;

/**
 * @brief Publish authentication data
 * @chinese 发布鉴权数据
 *
 * @param data
 * EN: Raw authentication data
 * CN: 原始鉴权数据
 */
- (void)publishAuthenticationData:(NSData *)data;

/**
 * @brief Publish an AI chat session event
 * @chinese 发布 AI 聊天会话事件
 *
 * @param event
 * EN: Normalized Fit AI chat session event
 * CN: 归一化后的 Fit AI 聊天会话事件
 * @return EN: YES when at least one active listener received it. CN: 至少一个活动监听者收到事件时返回 YES。
 */
- (BOOL)publishChatSessionEvent:(TSFitAIChatSessionEvent)event;

/**
 * @brief Publish AI chat audio data
 * @chinese 发布 AI 聊天音频数据
 *
 * @param opusData
 * EN: Raw Opus data, or nil when unavailable
 * CN: 原始 Opus 数据，不可用时为 nil
 *
 * @param pcmData
 * EN: Decoded PCM data, or nil when unavailable
 * CN: 解码后的 PCM 数据，不可用时为 nil
 */
- (void)publishChatOpusData:(nullable NSData *)opusData
                    pcmData:(nullable NSData *)pcmData;

/**
 * @brief Publish that the watch entered AI question-answer
 * @chinese 发布手表进入 AI 问答事件
 */
- (void)publishAIQuestionAnswerEntered;

/**
 * @brief Publish that the watch exited AI question-answer
 * @chinese 发布手表退出 AI 问答事件
 */
- (void)publishAIQuestionAnswerExited;

/**
 * @brief Publish the beginning of a single AI question voice input
 * @chinese 发布单轮 AI 问答语音输入开始事件
 */
- (void)publishAIQuestionAnswerVoiceBegan;

/**
 * @brief Publish AI question-answer audio data
 * @chinese 发布 AI 问答音频数据
 *
 * @param opusData
 * EN: Raw Opus data, or nil when unavailable
 * CN: 原始 Opus 数据，不可用时为 nil
 *
 * @param pcmData
 * EN: Decoded PCM data, or nil when unavailable
 * CN: 解码后的 PCM 数据，不可用时为 nil
 */
- (void)publishAIQuestionAnswerOpusData:(nullable NSData *)opusData
                                pcmData:(nullable NSData *)pcmData;

/**
 * @brief Publish the end of a single AI question voice input
 * @chinese 发布单轮 AI 问答语音输入结束事件
 */
- (void)publishAIQuestionAnswerVoiceEnded;

/**
 * @brief Publish that the watch confirmed the recognized AI question
 * @chinese 发布手表确认 AI 问答识别问题事件
 */
- (void)publishAIQuestionConfirmed;

/**
 * @brief Publish a request to start audio recording
 * @chinese 发布开始录音请求
 *
 * @param scene EN: Raw FitCloud audio recording scene. CN: FitCloud 原始录音场景。
 * @param audioSource EN: Audio source selected by the device. CN: 设备选择的音频源。
 * @return EN: YES when at least one active listener received it. CN: 至少一个活动监听者收到事件时返回 YES。
 */
- (BOOL)publishRequestStartAudioRecordingWithScene:(FitCloudAIAudioRecordingScene)scene
                                        audioSource:(FitCloudAIAudioSource)audioSource;

/**
 * @brief Publish a request to stop audio recording
 * @chinese 发布停止录音请求
 * @param scene EN: Raw scene that ended. CN: 已结束的原始录音场景。
 */
- (void)publishRequestStopAudioRecordingWithScene:
    (FitCloudAIAudioRecordingScene)scene;

/**
 * @brief Publish an audio recording interruption
 * @chinese 发布录音中断事件
 *
 * @param scene EN: Raw scene that was interrupted. CN: 被中断的原始录音场景。
 * @param reason
 * EN: FitCloud device interruption reason
 * CN: FitCloud 设备中断原因
 */
- (void)publishAudioRecordingInterruptionWithScene:
            (FitCloudAIAudioRecordingScene)scene
                                              reason:
            (FitCloudAIDeviceInterruptionReason)reason;

/**
 * @brief Publish audio recording data
 * @chinese 发布录音音频数据
 *
 * @param opusData
 * EN: Raw Opus data, or nil when unavailable
 * CN: 原始 Opus 数据，不可用时为 nil
 *
 * @param pcmData
 * EN: Decoded PCM data, or nil when unavailable
 * CN: 解码后的 PCM 数据，不可用时为 nil
 */
- (void)publishAudioRecordingOpusData:(nullable NSData *)opusData
                              pcmData:(nullable NSData *)pcmData;

/**
 * @brief Publish device voice-translation begin
 * @chinese 发布设备语音翻译开始事件
 */
- (void)publishTranslationVoiceBegan;

/**
 * @brief Publish incremental translation audio
 * @chinese 发布翻译增量音频
 * @param opusData EN: Incremental Opus data. CN: 增量 Opus 数据。
 * @param pcmData EN: Incremental decoded PCM data. CN: 增量解码 PCM 数据。
 * @param sourceLanguage EN: Raw source language. CN: 原始源语言。
 * @param targetLanguage EN: Raw target language. CN: 原始目标语言。
 */
- (void)publishTranslationDeltaOpusData:(nullable NSData *)opusData
                                pcmData:(nullable NSData *)pcmData
                         sourceLanguage:(FITCLOUDLANGUAGE)sourceLanguage
                         targetLanguage:(FITCLOUDLANGUAGE)targetLanguage;

/**
 * @brief Publish device voice-translation stop
 * @chinese 发布设备语音翻译停止事件
 * @param opusData EN: Full Opus data. CN: 完整 Opus 数据。
 * @param pcmData EN: Full decoded PCM data. CN: 完整解码 PCM 数据。
 * @param sourceLanguage EN: Raw source language. CN: 原始源语言。
 * @param targetLanguage EN: Raw target language. CN: 原始目标语言。
 */
- (void)publishTranslationVoiceStoppedWithOpusData:(nullable NSData *)opusData
                                            pcmData:(nullable NSData *)pcmData
                                     sourceLanguage:(FITCLOUDLANGUAGE)sourceLanguage
                                     targetLanguage:(FITCLOUDLANGUAGE)targetLanguage;

/**
 * @brief Publish a translated-speech playback request
 * @chinese 发布译文语音播放请求
 * @param state EN: Raw FitCloud playback state. CN: FitCloud 原始播放状态。
 */
- (void)publishTranslatedVoicePlaybackState:(TranslatedTextVoicePlayingState)state;

/**
 * @brief Publish AI watch-face ASR capture begin
 * @chinese 发布 AI 表盘 ASR 采音开始事件
 */
- (void)publishASRVoiceBegan;

/**
 * @brief Publish incremental AI watch-face ASR audio
 * @chinese 发布 AI 表盘 ASR 增量音频
 * @param opusData EN: Incremental Opus data. CN: 增量 Opus 数据。
 * @param pcmData EN: Incremental decoded PCM data. CN: 增量解码 PCM 数据。
 */
- (void)publishASRDeltaOpusData:(nullable NSData *)opusData
                         pcmData:(nullable NSData *)pcmData;

/**
 * @brief Publish AI watch-face ASR capture stop
 * @chinese 发布 AI 表盘 ASR 采音停止事件
 * @param opusData EN: Full Opus data. CN: 完整 Opus 数据。
 * @param pcmData EN: Full decoded PCM data. CN: 完整解码 PCM 数据。
 */
- (void)publishASRVoiceStoppedWithOpusData:(nullable NSData *)opusData
                                     pcmData:(nullable NSData *)pcmData;

/**
 * @brief Publish an AI watch-face generation request
 * @chinese 发布 AI 表盘生成请求
 * @param prompt EN: Prompt reported by the watch, or nil. CN: 手表上报的提示词，可为 nil。
 * @param previewWidth EN: Requested preview width in pixels. CN: 请求的预览图像素宽度。
 * @param previewHeight EN: Requested preview height in pixels. CN: 请求的预览图像素高度。
 */
- (void)publishRequestGenerateAIWatchFaceWithPrompt:(nullable NSString *)prompt
                                        previewWidth:(NSInteger)previewWidth
                                       previewHeight:(NSInteger)previewHeight;

/**
 * @brief Publish the watch's AI watch-face photo confirmation
 * @chinese 发布手表对 AI 表盘图片的确认结果
 * @param confirmed EN: Whether the watch accepted the photo. CN: 手表是否接受该图片。
 */
- (void)publishAIWatchFacePhotoConfirmation:(BOOL)confirmed;

/** @brief Publish a device translation start request. @chinese 发布设备语音翻译启动请求。
 * @param mode EN: Requested mode. CN: 请求的模式。
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 * @return EN: YES when at least one listener received the event. CN: 至少一个监听者接收事件时返回 YES。
 */
- (BOOL)publishRequestStartTranslationWithMode:(FitCloudAITranslationVoiceMode)mode
                                     audioSource:(FitCloudAIAudioSource)audioSource;

/** @brief Publish device translation cancellation. @chinese 发布设备语音翻译取消事件。
 * @param mode EN: Canceled mode. CN: 被取消的模式。
 * @param reason EN: Device interruption reason. CN: 设备中断原因。
 */
- (void)publishTranslationCancellationWithMode:(FitCloudAITranslationVoiceMode)mode
                                         reason:(FitCloudAIDeviceInterruptionReason)reason;

/** @brief Publish a translation exit request. @chinese 发布语音翻译退出请求。
 * @param mode EN: Translation mode being exited. CN: 正在退出的翻译模式。
 */
- (void)publishRequestExitTranslationWithMode:(FitCloudAITranslationVoiceMode)mode;

/** @brief Publish a device question-answer start request. @chinese 发布设备 AI 问答启动请求。
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 * @return EN: YES when at least one listener received the event. CN: 至少一个监听者接收事件时返回 YES。
 */
- (BOOL)publishRequestStartAIQuestionAnswerWithAudioSource:
    (FitCloudAIAudioSource)audioSource;

/** @brief Publish device question-answer cancellation. @chinese 发布设备 AI 问答取消事件。
 * @param reason EN: Device interruption reason. CN: 设备中断原因。
 */
- (void)publishAIQuestionAnswerCancellationWithReason:
    (FitCloudAIDeviceInterruptionReason)reason;

/** @brief Publish a question-answer exit request. @chinese 发布 AI 问答退出请求。 */
- (void)publishRequestExitAIQuestionAnswer;

/** @brief Publish a device AI watch-face start request. @chinese 发布设备 AI 表盘启动请求。
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 * @return EN: YES when at least one listener received the event. CN: 至少一个监听者接收事件时返回 YES。
 */
- (BOOL)publishRequestStartAIWatchFaceWithAudioSource:
    (FitCloudAIAudioSource)audioSource;

/** @brief Publish device AI watch-face cancellation. @chinese 发布设备 AI 表盘取消事件。
 * @param reason EN: Device interruption reason. CN: 设备中断原因。
 */
- (void)publishAIWatchFaceCancellationWithReason:
    (FitCloudAIDeviceInterruptionReason)reason;

/** @brief Publish an AI watch-face exit request. @chinese 发布 AI 表盘退出请求。 */
- (void)publishRequestExitAIWatchFace;

/** @brief Publish a device voice ride-hailing start request. @chinese 发布设备语音打车启动请求。
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 * @return EN: YES when at least one listener received the event. CN: 至少一个监听者接收事件时返回 YES。
 */
- (BOOL)publishRequestStartVoiceRideHailingWithAudioSource:
    (FitCloudAIAudioSource)audioSource;

/** @brief Publish device voice ride-hailing cancellation. @chinese 发布设备语音打车取消事件。
 * @param reason EN: Device interruption reason. CN: 设备中断原因。
 */
- (void)publishVoiceRideHailingCancellationWithReason:
    (FitCloudAIDeviceInterruptionReason)reason;

/** @brief Publish a voice ride-hailing exit request. @chinese 发布语音打车退出请求。 */
- (void)publishRequestExitVoiceRideHailing;

/** @brief Publish voice ride-hailing audio. @chinese 发布语音打车音频。
 * @param opusData EN: Opus data when available. CN: 可用时的 Opus 数据。
 * @param pcmData EN: Decoded PCM data when available. CN: 可用时的解码 PCM 数据。
 * @param isFinal EN: Whether this is the final voice chunk. CN: 是否为最终语音分片。
 */
- (void)publishVoiceRideHailingOpusData:(nullable NSData *)opusData
                                 pcmData:(nullable NSData *)pcmData
                                 isFinal:(BOOL)isFinal;

@end

NS_ASSUME_NONNULL_END
