//
//  TSFitAIDeviceBridge+Private.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/13.
//

#import "TSFitAIDeviceBridge.h"

#import <TopStepAIKit/TSAIDeviceBridgeEventSink.h>

#import "TSFitAIEventListener.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TSFitAIDeviceBridgeEventDelivery)(
    id<TSAIDeviceBridgeEventSink> eventSink,
    NSString *activationToken);

@class TSFitAIDeviceBridgeEventProxy;
@class TSPeripheralAIAbility;
@class TSPeripheralLimitations;

/**
 * @brief Internal peripheral capability access
 * @chinese 内部外设能力访问
 */
@interface TSFitAIDeviceBridge (Capability)

/**
 * @brief Return the connected peripheral AI ability
 * @chinese 返回当前已连接外设的 AI 能力
 * @return EN: Current ability, or nil when disconnected. CN: 当前能力；设备未连接时返回 nil。
 */
- (nullable TSPeripheralAIAbility *)currentPeripheralAIAbility;

/**
 * @brief Return the connected peripheral limitations
 * @chinese 返回当前已连接外设的限制快照
 * @return EN: Current limitations, or nil when unavailable. CN: 当前限制；不可用时返回 nil。
 */
- (nullable TSPeripheralLimitations *)currentPeripheralLimitations;

@end

/**
 * @brief Internal event delivery methods used by the Fit AI event proxy
 * @chinese 供 Fit AI 事件代理调用的内部事件交付方法
 */
@interface TSFitAIDeviceBridge (EventHandling)

/** @brief Deliver an event from the active proxy. @chinese 交付当前激活代理的事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 * @param delivery EN: Delivery block. CN: 事件交付 Block。
 */
- (void)deliverEventFromProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy
                     delivery:(TSFitAIDeviceBridgeEventDelivery)delivery;
/** @brief Handle a device connection event. @chinese 处理设备连接事件。
 * @param deviceIdentifier EN: Device identifier. CN: 设备标识。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleDeviceConnectedWithIdentifier:(NSString *)deviceIdentifier
                                 eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle a device disconnection event. @chinese 处理设备断开事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleDeviceDisconnectedFromEventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle device authentication data. @chinese 处理设备鉴权数据。
 * @param data EN: Authentication data. CN: 鉴权数据。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleAuthenticationData:(NSData *)data
                      eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle an AI chat session event. @chinese 处理 AI 对话会话事件。
 * @param event EN: FitCloud event. CN: FitCloud 事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleChatSessionEvent:(FitCloudAIChatSessionEvent)event
                    eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle incremental AI chat audio. @chinese 处理 AI 对话增量音频。
 * @param opusData EN: Opus audio. CN: Opus 音频。
 * @param pcmData EN: PCM audio. CN: PCM 音频。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleChatOpusData:(nullable NSData *)opusData
                   pcmData:(nullable NSData *)pcmData
                eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle an audio-recording start request. @chinese 处理录音开始请求。
 * @param scene EN: Recording scene. CN: 录音场景。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleAudioRecordingStartWithScene:(FitCloudAIAudioRecordingScene)scene
                                eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle an audio-recording stop request. @chinese 处理录音停止请求。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleAudioRecordingStopFromEventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle an audio-recording interruption. @chinese 处理录音中断事件。
 * @param reason EN: Interruption reason. CN: 中断原因。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleAudioRecordingInterruption:
    (FitCloudAIAudioRecordingTerminateWithInterruptReason)reason
                                   eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle incremental recording audio. @chinese 处理录音增量音频。
 * @param opusData EN: Opus audio. CN: Opus 音频。
 * @param pcmData EN: PCM audio. CN: PCM 音频。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleAudioRecordingOpusData:(nullable NSData *)opusData
                             pcmData:(nullable NSData *)pcmData
                          eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle voice-translation input start. @chinese 处理语音翻译输入开始事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleTranslationVoiceBeginFromEventProxy:
    (TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle incremental voice-translation audio. @chinese 处理语音翻译增量音频。
 * @param opusData EN: Opus audio. CN: Opus 音频。
 * @param pcmData EN: PCM audio. CN: PCM 音频。
 * @param sourceLanguage EN: Source language. CN: 源语言。
 * @param targetLanguage EN: Target language. CN: 目标语言。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleTranslationDeltaOpusData:(nullable NSData *)opusData
                               pcmData:(nullable NSData *)pcmData
                        sourceLanguage:(FITCLOUDLANGUAGE)sourceLanguage
                        targetLanguage:(FITCLOUDLANGUAGE)targetLanguage
                           eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle voice-translation input stop. @chinese 处理语音翻译输入停止事件。
 * @param opusData EN: Complete Opus audio. CN: 完整 Opus 音频。
 * @param pcmData EN: Complete PCM audio. CN: 完整 PCM 音频。
 * @param sourceLanguage EN: Source language. CN: 源语言。
 * @param targetLanguage EN: Target language. CN: 目标语言。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleTranslationVoiceStopWithOpusData:(nullable NSData *)opusData
                                       pcmData:(nullable NSData *)pcmData
                                sourceLanguage:(FITCLOUDLANGUAGE)sourceLanguage
                                targetLanguage:(FITCLOUDLANGUAGE)targetLanguage
                                   eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle translated-voice playback state. @chinese 处理译文语音播放状态。
 * @param state EN: Playback state. CN: 播放状态。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleTranslatedVoicePlaybackState:(TranslatedTextVoicePlayingState)state
                                  eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle entering the question-answer scene. @chinese 处理进入 AI 问答场景事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleQuestionAnswerEnteredFromEventProxy:
    (TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle exiting the question-answer scene. @chinese 处理退出 AI 问答场景事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleQuestionAnswerExitedFromEventProxy:
    (TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle question voice input start. @chinese 处理问题语音输入开始事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleQuestionAnswerVoiceBeginFromEventProxy:
    (TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle incremental question audio. @chinese 处理问题增量音频。
 * @param opusData EN: Opus audio. CN: Opus 音频。
 * @param pcmData EN: PCM audio. CN: PCM 音频。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleQuestionAnswerOpusData:(nullable NSData *)opusData
                             pcmData:(nullable NSData *)pcmData
                          eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle question voice input stop. @chinese 处理问题语音输入停止事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleQuestionAnswerVoiceStopFromEventProxy:
    (TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle device question confirmation. @chinese 处理设备确认问题事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleQuestionAnswerConfirmedFromEventProxy:
    (TSFitAIDeviceBridgeEventProxy *)eventProxy;

@end

/**
 * @brief Proxy bound to one device-bridge activation
 * @chinese 绑定单次设备桥激活的事件代理
 */
@interface TSFitAIDeviceBridgeEventProxy : NSObject <TSFitAIEventListener>

/** @brief Bridge receiving normalized events. @chinese 接收标准化事件的 Bridge。 */
@property (nonatomic, weak) TSFitAIDeviceBridge *deviceBridge;
/** @brief Activation token owned by this listener. @chinese 此监听器所属的激活令牌。 */
@property (nonatomic, copy) NSString *activationToken;

/**
 * @brief Create an event proxy for one activation
 * @chinese 为单次激活创建事件代理
 * @param deviceBridge EN: Target bridge. CN: 目标 Bridge。
 * @param activationToken EN: Activation token. CN: 激活令牌。
 * @return EN: Initialized proxy. CN: 初始化后的事件代理。
 */
- (instancetype)initWithDeviceBridge:(TSFitAIDeviceBridge *)deviceBridge
                     activationToken:(NSString *)activationToken;

@end

NS_ASSUME_NONNULL_END
