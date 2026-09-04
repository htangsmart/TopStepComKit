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
 * @brief Internal exactly-once state for device AI sessions
 * @chinese 设备 AI 会话的内部单次状态
 */
@interface TSFitAIDeviceBridge (SessionState)

/**
 * @brief Register the only pending Fit device-start request
 * @chinese 登记唯一待应答的 Fit 设备启动请求
 * @param request EN: Request created from the current activation callback. CN: 当前激活回调生成的请求。
 * @param error EN: Busy or invalid request error. CN: 忙碌或非法请求错误。
 * @return EN: YES when the pending slot was registered. CN: 成功登记待应答槽位时返回 YES。
 */
- (BOOL)registerPendingDeviceStartRequest:(TSAIStartRequest *)request
                                    error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Claim the only accept-or-reject response for a request
 * @chinese 占用某请求唯一的 accept 或 reject 应答权
 * @param requestIdentifier EN: Stable request identifier. CN: 稳定请求标识。
 * @param error EN: Duplicate/invalid request error. CN: 重复或非法请求错误。
 * @return EN: YES only for the first response. CN: 仅首次应答返回 YES。
 */
- (BOOL)claimDeviceStartResponseForRequestIdentifier:
        (NSString *)requestIdentifier
                                                  error:
        (NSError * _Nullable * _Nullable)error;

/**
 * @brief Return whether a reject delivery still owns the current response slot
 * @chinese 返回 reject 发送是否仍持有当前应答槽位
 * @param request EN: Request captured by the delivery attempt. CN: 发送尝试捕获的请求。
 * @return EN: YES when the response is still current. CN: 应答仍有效时返回 YES。
 */
- (BOOL)isDeviceStartResponseCurrentForRequest:(TSAIStartRequest *)request;

/**
 * @brief Complete a reject delivery while retaining failures for retry
 * @chinese 完成 reject 发送，并在失败时保留请求供重试
 * @param request EN: Request captured by the delivery attempt. CN: 发送尝试捕获的请求。
 * @param success EN: Whether delivery was confirmed. CN: 是否确认发送成功。
 * @return EN: YES when the response was current. CN: 应答仍有效时返回 YES。
 */
- (BOOL)completeDeviceStartResponseForRequest:(TSAIStartRequest *)request
                                      success:(BOOL)success;

/**
 * @brief Begin an App-origin start transition
 * @chinese 开始 App 发起的启动迁移
 * @param request EN: Validated App-origin request. CN: 已校验的 App 发起请求。
 * @param generation EN: Transition generation used to reject late callbacks. CN: 用于拒绝迟到回调的迁移代次。
 * @param error EN: Busy or invalid transition error. CN: 忙碌或非法迁移错误。
 * @return EN: YES when the in-flight slot is reserved. CN: 成功占用在途槽位时返回 YES。
 */
- (BOOL)beginAppDeviceAISessionStartForRequest:(TSAIStartRequest *)request
                                     generation:(NSUInteger *)generation
                                          error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Atomically claim a pending request for device-origin acceptance
 * @chinese 原子占用待处理请求并开始设备发起的接受迁移
 * @param request EN: Matching device-origin request. CN: 匹配的设备发起请求。
 * @param generation EN: Transition generation used to reject late callbacks. CN: 用于拒绝迟到回调的迁移代次。
 * @param error EN: Duplicate, stale or busy error. CN: 重复、过期或忙碌错误。
 * @return EN: YES when acceptance owns the in-flight slot. CN: 接受操作取得在途槽位时返回 YES。
 */
- (BOOL)claimDeviceStartAcceptanceForRequest:(TSAIStartRequest *)request
                                   generation:(NSUInteger *)generation
                                        error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Complete a start transition only when request and generation still match
 * @chinese 仅请求与代次仍匹配时完成启动迁移
 * @param request EN: Request captured by the transport callback. CN: 传输回调捕获的请求。
 * @param generation EN: Captured transition generation. CN: 捕获的迁移代次。
 * @param coordinationRetained EN: Whether to retain an active device lease. CN: 是否保留活动设备租约。
 * @return EN: YES when the callback was current and consumed. CN: 回调仍有效且已消费时返回 YES。
 */
- (BOOL)completeDeviceAISessionStartForRequest:(TSAIStartRequest *)request
                                     generation:(NSUInteger)generation
                            coordinationRetained:(BOOL)coordinationRetained;

/**
 * @brief Consume a lifecycle-cancellation marker for one stale successful start
 * @chinese 消费迟到启动成功所对应的生命周期补偿标记
 * @param request EN: Request captured by the stale callback. CN: 迟到回调捕获的请求。
 * @return EN: YES when the device must receive a compensating end. CN: 需要向设备补发结束指令时返回 YES。
 */
- (BOOL)consumeDeviceAISessionCompensationForRequest:
    (TSAIStartRequest *)request;

/**
 * @brief Discard compensation when a stale start was definitively rejected
 * @chinese 迟到启动已明确失败时丢弃补偿标记
 * @param request EN: Request captured by the stale callback. CN: 迟到回调捕获的请求。
 */
- (void)discardDeviceAISessionCompensationForRequest:
    (TSAIStartRequest *)request;

/**
 * @brief Claim the only App-origin end command for an active device lease
 * @chinese 占用活动设备租约唯一的 App 结束指令
 * @param request EN: Active request being ended. CN: 正在结束的活动请求。
 * @param generation EN: End-attempt generation used to reject late callbacks. CN: 用于拒绝迟到回调的结束尝试代次。
 * @param error EN: Missing or mismatched active-session error. CN: 活动会话缺失或不匹配错误。
 * @return EN: YES only for the matching active lease. CN: 仅匹配活动租约时返回 YES。
 */
- (BOOL)claimActiveDeviceAISessionEndForRequest:(TSAIStartRequest *)request
                                      generation:(NSUInteger *)generation
                                          error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Complete an end transition while retaining failed leases for retry
 * @chinese 完成结束迁移，并在失败时保留租约供重试
 * @param request EN: Request captured by the end callback. CN: 结束回调捕获的请求。
 * @param generation EN: Captured end-attempt generation. CN: 捕获的结束尝试代次。
 * @param transportSuccess EN: Whether the transport confirmed the end. CN: 传输是否确认结束。
 * @param resolvedSuccess EN: Effective result including a terminal device event. CN: 包含设备终止事件后的最终结果。
 * @return EN: YES when the callback still owns the current end attempt. CN: 回调仍属于当前结束尝试时返回 YES。
 */
- (BOOL)completeDeviceAISessionEndForRequest:(TSAIStartRequest *)request
                                   generation:(NSUInteger)generation
                             transportSuccess:(BOOL)transportSuccess
                              resolvedSuccess:(BOOL *)resolvedSuccess;

/**
 * @brief Reconcile a confirmed end that arrived after its attempt timed out
 * @chinese 对结束尝试超时后迟到的成功结果执行对账
 * @param request EN: Request captured by the late callback. CN: 迟到回调捕获的请求。
 * @param generation EN: Captured end-attempt generation. CN: 捕获的结束尝试代次。
 * @return EN: YES when the active lease was reconciled once. CN: 活动租约被单次对账时返回 YES。
 */
- (BOOL)reconcileLateDeviceAISessionEndForRequest:(TSAIStartRequest *)request
                                        generation:(NSUInteger)generation;

/**
 * @brief Clear a session after a device-origin terminal event
 * @chinese 在设备端终止事件后清除会话
 * @param useCase EN: Ended business use case. CN: 已结束的业务用例。
 */
- (void)clearDeviceAISessionForUseCase:(TSAIUseCase)useCase;

/**
 * @brief Return the exact recording use case held by the only Fit session slot
 * @chinese 返回 Fit 唯一会话槽当前持有的精确录音用例
 * @return EN: AIRecording, CallRecording, or Invalid. CN: AI 录音、通话录音或非法用例。
 */
- (TSAIUseCase)currentAudioRecordingDeviceAISessionUseCase;

/**
 * @brief Return the active request for one exact use case
 * @chinese 返回指定用例的活动请求
 * @param useCase EN: Business use case to match. CN: 需要匹配的业务用例。
 * @return EN: Active request snapshot, or nil when unmatched. CN: 活动请求快照；不匹配时返回 nil。
 */
- (nullable TSAIStartRequest *)activeDeviceAISessionRequestForUseCase:
    (TSAIUseCase)useCase;

@end

/**
 * @brief Internal event delivery methods used by the Fit AI event proxy
 * @chinese 供 Fit AI 事件代理调用的内部事件交付方法
 */
@interface TSFitAIDeviceBridge (EventHandling)

/** @brief Return whether the source proxy belongs to the current activation. @chinese 返回来源代理是否属于当前激活。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 * @return EN: YES for the current activation proxy. CN: 属于当前激活代理时返回 YES。
 */
- (BOOL)isCurrentEventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Deliver an event from the active proxy. @chinese 交付当前激活代理的事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 * @param delivery EN: Delivery block. CN: 事件交付 Block。
 * @return EN: YES when an active sink received the event. CN: 活动 Sink 收到事件时返回 YES。
 */
- (BOOL)deliverEventFromProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy
                     delivery:(TSFitAIDeviceBridgeEventDelivery)delivery;
/** @brief Deliver a late successful end as a no-echo terminal event. @chinese 将迟到的结束成功作为无回声终止事件交付。
 * @param request EN: Reconciled request. CN: 已对账请求。
 */
- (void)deliverReconciledDeviceAISessionEndForRequest:(TSAIStartRequest *)request;
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
 * @param event EN: Normalized Fit AI event. CN: 归一化后的 Fit AI 事件。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleChatSessionEvent:(TSFitAIChatSessionEvent)event
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
 * @param audioSource EN: Device-selected audio source. CN: 设备选择的音频源。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleAudioRecordingStartWithScene:(FitCloudAIAudioRecordingScene)scene
                               audioSource:(FitCloudAIAudioSource)audioSource
                                eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle an audio-recording stop request. @chinese 处理录音停止请求。
 * @param scene EN: Recording scene that ended. CN: 已结束的录音场景。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleAudioRecordingStopWithScene:(FitCloudAIAudioRecordingScene)scene
                               eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle an audio-recording interruption. @chinese 处理录音中断事件。
 * @param reason EN: Interruption reason. CN: 中断原因。
 * @param scene EN: Recording scene that was interrupted. CN: 被中断的录音场景。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleAudioRecordingInterruption:
    (FitCloudAIDeviceInterruptionReason)reason
                                         scene:
    (FitCloudAIAudioRecordingScene)scene
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

/** @brief Handle a device translation start request. @chinese 处理设备语音翻译启动请求。
 * @param mode EN: Requested Fit translation mode. CN: 请求的 Fit 翻译模式。
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleTranslationStartWithMode:(FitCloudAITranslationVoiceMode)mode
                           audioSource:(FitCloudAIAudioSource)audioSource
                            eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;

/** @brief Handle a device question-answer start request. @chinese 处理设备 AI 问答启动请求。
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleQuestionAnswerStartWithAudioSource:(FitCloudAIAudioSource)audioSource
                                      eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;

/** @brief Handle a device AI watch-face start request. @chinese 处理设备 AI 表盘启动请求。
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleAIWatchFaceStartWithAudioSource:(FitCloudAIAudioSource)audioSource
                                   eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;

/** @brief Handle a device voice ride-hailing start request. @chinese 处理设备语音打车启动请求。
 * @param audioSource EN: Requested audio source. CN: 请求的音频源。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleVoiceRideHailingStartWithAudioSource:
        (FitCloudAIAudioSource)audioSource
                                        eventProxy:
        (TSFitAIDeviceBridgeEventProxy *)eventProxy;

/** @brief Handle voice ride-hailing audio. @chinese 处理语音打车音频。
 * @param opusData EN: Opus data when available. CN: 可用时的 Opus 数据。
 * @param pcmData EN: Decoded PCM data when available. CN: 可用时的解码 PCM 数据。
 * @param isFinal EN: Whether this is the final voice chunk. CN: 是否为最终语音分片。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleVoiceRideHailingOpusData:(nullable NSData *)opusData
                                pcmData:(nullable NSData *)pcmData
                                isFinal:(BOOL)isFinal
                             eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;

/** @brief Handle an exact single-round terminal event. @chinese 处理精确的单轮终止事件。
 * @param useCase EN: Ended AI use case. CN: 已终止的 AI 用例。
 * @param interrupted EN: Whether the device interrupted the session. CN: 设备是否中断会话。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleSingleRoundSessionEndedForUseCase:(TSAIUseCase)useCase
                                     interrupted:(BOOL)interrupted
                                      eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;
/** @brief Handle natural completion of one device input round. @chinese 处理一次设备输入自然完成。
 * @param useCase EN: Completed business use case. CN: 输入已完成的业务用例。
 * @param eventProxy EN: Source proxy. CN: 事件源代理。
 */
- (void)handleSingleRoundInputCompletedForUseCase:(TSAIUseCase)useCase
                                        eventProxy:(TSFitAIDeviceBridgeEventProxy *)eventProxy;

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
