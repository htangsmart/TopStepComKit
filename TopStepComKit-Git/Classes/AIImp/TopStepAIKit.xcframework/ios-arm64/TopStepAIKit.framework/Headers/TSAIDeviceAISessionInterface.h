//
//  TSAIDeviceAISessionInterface.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIContractDefines.h"

@class TSAIStartRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Prepare local non-UI resources for a device-coordinated AI session
 * @chinese 为设备协同 AI 会话准备本地非 UI 资源
 * @param request EN: Exact reserved request. CN: 已精确占位的请求。
 * @param completion EN: Must be called exactly once when local preparation finishes. CN: 本地准备结束时必须且只能调用一次。
 */
typedef void (^TSAIDeviceAISessionPrepareHandler)(
    TSAIStartRequest *request,
    TSAICompletionBlock completion);

/**
 * @brief Notify that both local and device sides are active
 * @chinese 通知本地与设备两侧均已激活
 * @param request EN: Committed session request. CN: 已提交的会话请求。
 */
typedef void (^TSAIDeviceAISessionActivationHandler)(TSAIStartRequest *request);

/**
 * @brief Notify that device voice input ended normally while downstream work may continue
 * @chinese 通知设备语音输入已自然结束，但下游业务仍可继续
 * @param request EN: Session whose device input lease was released. CN: 已释放设备输入租约的会话请求。
 */
typedef void (^TSAIDeviceAISessionInputCompletionHandler)(TSAIStartRequest *request);

/**
 * @brief Roll back or end local resources for one prepared session
 * @chinese 回滚或结束一次已准备会话的本地资源
 * @param request EN: Session request being terminated. CN: 正在终止的会话请求。
 * @param interrupted EN: Whether termination came from interruption or failure. CN: 是否因中断或失败而终止。
 * @param error EN: Failure reason, or nil for a normal end. CN: 失败原因；正常结束时为 nil。
 */
typedef void (^TSAIDeviceAISessionTerminationHandler)(
    TSAIStartRequest *request,
    BOOL interrupted,
    NSError * _Nullable error);

/**
 * @brief Deliver voice data owned by a committed device session
 * @chinese 下发属于已提交设备会话的语音数据
 * @param request EN: Active session request. CN: 活动会话请求。
 * @param opusData EN: Opus data when available. CN: 可用时的 Opus 数据。
 * @param pcmData EN: Decoded PCM data when available. CN: 可用时的解码 PCM 数据。
 * @param isFinal EN: Whether this is the final voice chunk. CN: 是否为最终语音分片。
 */
typedef void (^TSAIDeviceAISessionVoiceDataHandler)(
    TSAIStartRequest *request,
    NSData * _Nullable opusData,
    NSData * _Nullable pcmData,
    BOOL isFinal);

/**
 * @brief Public orchestration entry for device-coordinated single-round AI sessions
 * @chinese 设备协同单轮 AI 会话的公开编排入口
 *
 * @discussion
 * [EN]: Chat and recording keep their dedicated public interfaces. This protocol
 *       supplies the symmetric App/Device flow for translation, question-answer,
 *       watch-face and ride-hailing sessions. All handlers are delivered on the
 *       main thread. UI may open only from the activation handler.
 * [CN]: 对话与录音继续使用各自专用公开接口。本协议为翻译、问答、表盘和打车
 *       会话提供 App/设备双向对称流程。所有 Handler 均在主线程回调；UI 只能在
 *       activationHandler 中打开。
 */
@protocol TSAIDeviceAISessionInterface <NSObject>

/**
 * @brief Register or unregister the App route for one device session use case
 * @chinese 注册或注销一个设备会话用例的 App 路由
 * @param useCase EN: Voice translation, voice question-answer, watch-face or ride-hailing. CN: 语音翻译、语音问答、表盘或打车用例。
 * @param prepareHandler EN: Local preparation handler; nil unregisters the route. CN: 本地准备 Handler；传 nil 注销该路由。
 * @param activationHandler EN: Called only after both sides are ready. CN: 仅双端均就绪后调用。
 * @param inputCompletionHandler EN: Required when registering. Called after natural voice-input completion; downstream AI work must not be cancelled by this signal. CN: 注册时必填。语音输入自然结束后调用；不得因该信号取消后续 AI 业务。
 * @param terminationHandler EN: Idempotent local rollback/end handler. CN: 幂等的本地回滚/结束 Handler。
 * @param voiceDataHandler EN: Voice-data consumer; required for RideHailing with Opus input and optional otherwise. CN: 语音数据消费者；RideHailing 使用 Opus 输入时必填，其他组合可选。
 */
- (void)registerDeviceAISessionHandlerForUseCase:(TSAIUseCase)useCase
                                  prepareHandler:(nullable TSAIDeviceAISessionPrepareHandler)prepareHandler
                               activationHandler:(nullable TSAIDeviceAISessionActivationHandler)activationHandler
                          inputCompletionHandler:(nullable TSAIDeviceAISessionInputCompletionHandler)inputCompletionHandler
                              terminationHandler:(nullable TSAIDeviceAISessionTerminationHandler)terminationHandler
                                voiceDataHandler:(nullable TSAIDeviceAISessionVoiceDataHandler)voiceDataHandler;

/**
 * @brief Start one App-origin device-coordinated AI session
 * @chinese 启动一次 App 发起的设备协同 AI 会话
 * @param request EN: Exact App-origin request. CN: 精确的 App 发起请求。
 * @param completion EN: Succeeds only after local preparation and device synchronization. CN: 仅本地准备与设备同步均成功后返回成功。
 */
- (void)startDeviceAISessionFromAppWithRequest:(TSAIStartRequest *)request
                                    completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Stop one active App-controlled device AI session
 * @chinese 停止一次 App 控制的活动设备 AI 会话
 * @param request EN: Exact active request returned to handlers. CN: Handler 收到的精确活动请求。
 * @param completion EN: Device synchronization result. CN: 设备同步结果。
 */
- (void)stopDeviceAISessionWithRequest:(TSAIStartRequest *)request
                             completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Enter the device conversation-translation product mode
 * @chinese 进入设备对话翻译产品模式
 * @param mode EN: Pickup layout used by the device product page. CN: 设备产品页面使用的拾音组合。
 * @param completion EN: Device command delivery result. CN: 设备命令发送结果。
 */
- (void)startDeviceConversationTranslationWithMode:(TSAIConversationTranslationMode)mode
                                         completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Leave the device conversation-translation product mode
 * @chinese 退出设备对话翻译产品模式
 * @param completion EN: Device command delivery result. CN: 设备命令发送结果。
 */
- (void)stopDeviceConversationTranslationWithCompletion:
    (nullable TSAICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
