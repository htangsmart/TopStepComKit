//
//  TSAIDeviceBridgeEventSink.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIAssistantDefines.h"
#import "TSAIDeviceBridge.h"
#import "TSAudioRecordDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sink receiving normalized events from a platform DeviceBridge
 * @chinese 接收平台 DeviceBridge 标准化事件的协议
 */
@protocol TSAIDeviceBridgeEventSink <NSObject>

/**
 * @brief Notify that the device connected
 * @chinese 通知设备已连接
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidConnectWithActivationToken:(NSString *)activationToken;

/**
 * @brief Notify that the device disconnected
 * @chinese 通知设备已断开
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidDisconnectWithActivationToken:(NSString *)activationToken;

/**
 * @brief Deliver raw authentication data received from the device
 * @chinese 下发从设备收到的原始鉴权数据
 * @param data EN: Raw authentication data. CN: 原始鉴权数据。
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidReceiveAuthenticationData:(NSData *)data
                                 activationToken:(NSString *)activationToken;

/**
 * @brief Deliver a device-side AI chat session event
 * @chinese 下发设备侧 AI 对话会话事件
 * @param event EN: Normalized chat event. CN: 标准化对话事件。
 * @param audioChannel EN: Audio channel selected by the device. CN: 设备选择的音频通道。
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidReceiveChatSessionEvent:(TSAIChatDeviceEvent)event
                                  audioChannel:(TSAIDeviceBridgeChatAudioChannel)audioChannel
                               activationToken:(NSString *)activationToken;

/**
 * @brief Deliver incremental AI chat audio data
 * @chinese 下发增量 AI 对话音频数据
 * @param opusData EN: Opus data, when available. CN: 可用时的 Opus 数据。
 * @param pcmData EN: PCM data, when available. CN: 可用时的 PCM 数据。
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidReceiveChatOpusData:(nullable NSData *)opusData
                                   pcmData:(nullable NSData *)pcmData
                           activationToken:(NSString *)activationToken;

@optional

/**
 * @brief Notify that the device entered the AI question-answer scene
 * @chinese 通知设备已进入 AI 问答场景
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidEnterQuestionAnswerWithActivationToken:
    (NSString *)activationToken;

/**
 * @brief Notify that the device exited the AI question-answer scene
 * @chinese 通知设备已退出 AI 问答场景
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidExitQuestionAnswerWithActivationToken:
    (NSString *)activationToken;

/**
 * @brief Notify that a question voice input began
 * @chinese 通知一轮问题语音输入已经开始
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidBeginQuestionAnswerVoiceWithActivationToken:
    (NSString *)activationToken;

/**
 * @brief Deliver incremental AI question audio
 * @chinese 下发 AI 问答的增量问题音频
 * @param opusData EN: Incremental Opus data, when available. CN: 可用时的增量 Opus 数据。
 * @param pcmData EN: Incremental 16 kHz mono Int16LE PCM. CN: 增量 16 kHz 单声道 Int16LE PCM。
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidReceiveQuestionAnswerOpusData:(nullable NSData *)opusData
                                              pcmData:(nullable NSData *)pcmData
                                      activationToken:(NSString *)activationToken;

/**
 * @brief Notify that the current question voice input stopped
 * @chinese 通知当前问题语音输入已经停止
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidStopQuestionAnswerVoiceWithActivationToken:
    (NSString *)activationToken;

/**
 * @brief Notify that the device confirmed the recognized question
 * @chinese 通知设备已确认识别到的问题
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 * @discussion EN: Reserved for confirmation-capable devices. The current
 *                 coordinator does not wait for this event.
 *             CN: 为支持确认的设备预留；当前编排器不会等待此事件。
 */
- (void)deviceBridgeDidConfirmQuestionAnswerWithActivationToken:
    (NSString *)activationToken;

/**
 * @brief Notify that the device began a voice-translation round
 * @chinese 通知设备已开始一轮语音翻译
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidBeginVoiceTranslationWithActivationToken:
    (NSString *)activationToken;

/**
 * @brief Deliver incremental device voice-translation audio
 * @chinese 下发设备语音翻译的增量音频
 * @param opusData EN: Incremental Opus data, when available. CN: 可用时的增量 Opus 数据。
 * @param pcmData EN: Incremental 16 kHz Int16 mono PCM used only when the
 *                    stop event has no complete PCM. CN: 增量 16 kHz Int16
 *                    单声道 PCM，仅在 stop 未携带完整 PCM 时兜底。
 * @param sourceLanguage EN: Source language selected by the device. CN: 设备选择的源语言。
 * @param targetLanguage EN: Target language selected by the device. CN: 设备选择的目标语言。
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidReceiveVoiceTranslationOpusData:(nullable NSData *)opusData
                                                pcmData:(nullable NSData *)pcmData
                                         sourceLanguage:(TSAILanguage)sourceLanguage
                                         targetLanguage:(TSAILanguage)targetLanguage
                                        activationToken:(NSString *)activationToken;

/**
 * @brief Notify that device voice capture stopped
 * @chinese 通知设备语音翻译采音已经停止
 * @param opusData EN: Complete Opus data for this round. CN: 本轮完整 Opus 数据。
 * @param pcmData EN: Complete PCM for this round and the authoritative ASR
 *                    input when present. CN: 本轮完整 PCM；存在时作为 ASR
 *                    的权威输入。
 * @param sourceLanguage EN: Source language selected by the device. CN: 设备选择的源语言。
 * @param targetLanguage EN: Target language selected by the device. CN: 设备选择的目标语言。
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidStopVoiceTranslationWithOpusData:(nullable NSData *)opusData
                                                pcmData:(nullable NSData *)pcmData
                                         sourceLanguage:(TSAILanguage)sourceLanguage
                                         targetLanguage:(TSAILanguage)targetLanguage
                                        activationToken:(NSString *)activationToken;

/**
 * @brief Deliver a translated-speech playback command from the device
 * @chinese 下发设备请求的译文语音播放指令
 * @param state EN: Normalized playback command. CN: 标准化播放指令。
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidRequestVoiceTranslationPlaybackState:
            (TSAIDeviceVoicePlaybackState)state
                                             activationToken:
            (NSString *)activationToken;

@required

/**
 * @brief Deliver a device request to start AI recording
 * @chinese 下发设备请求开始 AI 录音事件
 * @param scene EN: Requested recording scene. CN: 请求的录音场景。
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidRequestStartAudioRecordingWithScene:(TSAIAudioRecordScene)scene
                                           activationToken:(NSString *)activationToken;

/**
 * @brief Deliver a device request to stop AI recording
 * @chinese 下发设备请求停止 AI 录音事件
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidRequestStopAudioRecordingWithActivationToken:(NSString *)activationToken;

/**
 * @brief Deliver an AI recording interruption
 * @chinese 下发 AI 录音中断事件
 * @param reason EN: Normalized interruption reason. CN: 标准化中断原因。
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidInterruptAudioRecording:(TSAIAudioRecordInterruptReason)reason
                               activationToken:(NSString *)activationToken;

/**
 * @brief Deliver incremental AI recording audio data
 * @chinese 下发增量 AI 录音音频数据
 * @param opusData EN: Opus data, when available. CN: 可用时的 Opus 数据。
 * @param pcmData EN: PCM data, when available. CN: 可用时的 PCM 数据。
 * @param activationToken EN: Activation that produced the event. CN: 产生事件的激活标识。
 */
- (void)deviceBridgeDidReceiveAudioRecordingOpusData:(nullable NSData *)opusData
                                             pcmData:(nullable NSData *)pcmData
                                     activationToken:(NSString *)activationToken;

@end

NS_ASSUME_NONNULL_END
