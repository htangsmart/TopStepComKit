//
//  TSAIDeviceAISessionBridge.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIChatContent.h"
#import "TSAIDeviceBridge.h"

@class TSAIStartRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Normalized reason for rejecting a device-origin AI start
 * @chinese 拒绝设备发起 AI 请求的标准化原因
 */
typedef NS_ENUM(NSUInteger, TSAIDeviceAIStartRejectionReason) {
    TSAIDeviceAIStartRejectionReasonUnsupported = 0,
    TSAIDeviceAIStartRejectionReasonBusy,
    TSAIDeviceAIStartRejectionReasonAuthenticationFailed,
    TSAIDeviceAIStartRejectionReasonServiceFailed,
    TSAIDeviceAIStartRejectionReasonInvalidRequest,
    TSAIDeviceAIStartRejectionReasonTimeout,
    TSAIDeviceAIStartRejectionReasonOther,
};

/**
 * @brief Result of synchronizing one AI start with a device
 * @chinese 一次 AI 启动与设备同步后的结果
 */
@interface TSAIDeviceAISessionStartResult : NSObject <NSCopying>

/** @brief Whether both sides entered the requested coordination @chinese 双端是否已进入请求的协同状态 */
@property (nonatomic, assign, readonly, getter=isSuccessful) BOOL successful;

/** @brief Whether the device already ended because of its own exception @chinese 设备是否因自身异常已结束 */
@property (nonatomic, assign, readonly) BOOL deviceSideExceptionOccurred;

/** @brief Whether the transport retains a logical device coordination lease after success @chinese 成功后传输层是否仍保留设备逻辑协同占用 */
@property (nonatomic, assign, readonly) BOOL coordinationRetained;

/**
 * @brief Create an immutable synchronization result
 * @chinese 创建不可变的同步结果
 */
+ (instancetype)resultWithSuccess:(BOOL)success
      deviceSideExceptionOccurred:(BOOL)deviceSideExceptionOccurred
             coordinationRetained:(BOOL)coordinationRetained;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/** @brief Completion for device AI start synchronization @chinese 设备 AI 启动同步回调 */
typedef void (^TSAIDeviceAISessionStartCompletion)(
    TSAIDeviceAISessionStartResult * _Nullable result,
    NSError * _Nullable error);

/**
 * @brief Optional transport for direction-aware device AI sessions
 * @chinese 带发起方向的可选设备 AI 会话传输协议
 */
@protocol TSAIDeviceAISessionBridge <TSAIDeviceBridge>

    /**
     * @brief Start an App-origin device session
     * @chinese 启动 App 发起的设备会话
     * @param request EN: Validated App-origin request. CN: 已校验的 App 发起请求。
     * @param completion EN: Device synchronization result. CN: 设备同步结果。
     */
    - (void)startDeviceAISessionWithRequest:(TSAIStartRequest *)request
                                 completion:(TSAIDeviceAISessionStartCompletion)completion;

    /**
     * @brief Accept the matching pending device request
     * @chinese 接受匹配的待处理设备请求
     * @param request EN: Validated device-origin request. CN: 已校验的设备发起请求。
     * @param completion EN: Device synchronization result. CN: 设备同步结果。
     */
    - (void)acceptDeviceAISessionStartRequest:(TSAIStartRequest *)request
                                   completion:(TSAIDeviceAISessionStartCompletion)completion;

    /**
     * @brief Reject the matching pending device request
     * @chinese 拒绝匹配的待处理设备请求
     * @param request EN: Original device-origin request. CN: 原始设备发起请求。
     * @param reason EN: Normalized rejection reason. CN: 标准化拒绝原因。
     * @param completion EN: Optional delivery result. CN: 可选的发送结果。
     */
    - (void)rejectDeviceAISessionStartRequest:(TSAIStartRequest *)request
                                       reason:(TSAIDeviceAIStartRejectionReason)reason
                                   completion:(nullable TSAICompletionBlock)completion;

    /**
     * @brief End an App-controlled device session
     * @chinese 结束 App 控制的设备会话
     * @param request EN: Active session request. CN: 活动会话请求。
     * @param completion EN: Optional device end result. CN: 可选的设备结束结果。
     */
    - (void)endDeviceAISessionWithRequest:(TSAIStartRequest *)request
                               completion:(nullable TSAICompletionBlock)completion;

@optional

    /**
     * @brief Cancel production belonging to the original Chat request
     * @chinese 取消原始Chat请求所属的数据生产
     *
     * @param request
     * EN: Exact immutable request being cancelled; equal identifiers do not transfer ownership.
     * CN: 被取消的精确不可变请求；相同标识不转移归属。
     *
     * @discussion
     * [EN]: Call before ending an explicitly cancelled or failed Chat. This seals input and result
     *       production; endDeviceAISessionWithRequest:completion: still waits for actual drain.
     *       Normal completion omits this signal. Bridges that omit it retain their existing behavior.
     * [CN]: 主动取消或失败时先发送本信号，封闭输入和结果生产；实际排空仍由
     *       endDeviceAISessionWithRequest:completion:等待。正常完成不发送；未实现的桥保留旧行为。
     */
    - (void)cancelDeviceAIChatForRequest:(TSAIStartRequest *)request;

    /**
     * @brief Deliver one terminal business error for the original active Chat request
     * @chinese 回传原活动Chat请求的一次终态业务错误
     *
     * @param error
     * EN: Original business failure; transports map only recognized domains and codes.
     * CN: 原业务错误；传输层仅映射已识别的错误域和错误码。
     *
     * @param type
     * EN: Question before valid recognition finishes, or answer after recognition or answer content.
     * CN: 有效识别完成前为问题阶段，识别完成或已有回答内容后为答案阶段。
     *
     * @param request
     * EN: Exact immutable request whose device session has already opened.
     * CN: 设备会话已开启的精确不可变原请求。
     *
     * @param completion
     * EN: Optional local delivery result, once on the main queue; it is not a firmware display acknowledgement.
     * CN: 可选本地发送结果，在主队列完成一次，不代表固件已显示。
     *
     * @discussion
     * [EN]: Seal normal production, drain accepted results, then send the final error. Explicit
     *       cancellation may interrupt delivery; session end must still wait for actual local drain.
     *       Opt-in also requires cancelDeviceAIChatForRequest:. Omission preserves existing behavior.
     * [CN]: 封闭正常生产，排空已接纳结果后发送最终错误。主动取消可中断发送；会话结束仍须
     *       等待真实本地排空。启用时还须实现cancelDeviceAIChatForRequest:；未实现时保留原行为。
     */
    - (void)sendDeviceAIChatError:(NSError *)error
                            type:(TSAIChatContentType)type
                         request:(TSAIStartRequest *)request
                      completion:(nullable TSAICompletionBlock)completion;

    /**
     * @brief Declare support for continuous device-coordinated chat
     * @chinese 声明是否支持设备协同的连续对话
     * @return
     * EN: NO to accept only explicit single-round device chat; omission preserves existing modes.
     * CN: NO 表示仅接纳显式单轮设备对话；未实现时保留现有模式。
     */
    - (BOOL)supportsContinuousDeviceChat;

    /**
     * @brief Opt in to device input capabilities independent of the legacy combined channel
     * @chinese 显式启用独立于旧组合通道的设备输入能力
     * @return
     * EN: YES to query exact supported device-scene inputs separately; omission preserves legacy routes.
     * CN: YES 表示按已接线的设备场景单独查询精确输入能力；未实现时保留旧路由判断。
     */
    - (BOOL)usesIndependentDeviceAudioInputCapabilities;

    /**
     * @brief Require cloud service readiness before device synchronization
     * @chinese 要求云端服务就绪后才同步设备会话
     * @return
     * EN: YES to wait for ServiceReady; omission preserves existing behavior.
     * CN: YES 表示等待 ServiceReady；未实现时保持现有行为。
     */
    - (BOOL)requiresProviderReadyBeforeDeviceSessionStart;

    /**
     * @brief Mirror a cumulative chat text snapshot to the owning device request
     * @chinese 向所属设备请求镜像对话文本的全文累计快照
     * @param text
     * EN: Full question or answer text.
     * CN: 问题或回答的全文。
     * @param type
     * EN: Question or answer content type.
     * CN: 问题或回答类型。
     * @param request
     * EN: Exact owning immutable request object.
     * CN: 精确所属的原始不可变请求对象。
     * @param isFinal
     * EN: Whether this text snapshot is final.
     * CN: 本次文本是否为最终快照。
     */
    - (void)sendDeviceAIChatText:(NSString *)text
                           type:(TSAIChatContentType)type
                        request:(TSAIStartRequest *)request
                        isFinal:(BOOL)isFinal;

    /**
     * @brief Enter the device conversation-translation product mode
     * @chinese 进入设备对话翻译产品模式
     */
    - (void)startDeviceConversationTranslationWithMode:(TSAIConversationTranslationMode)mode
                                            completion:(nullable TSAICompletionBlock)completion;

    /**
     * @brief Leave the device conversation-translation product mode
     * @chinese 退出设备对话翻译产品模式
     */
    - (void)stopDeviceConversationTranslationWithCompletion:
        (nullable TSAICompletionBlock)completion;

    /**
     * @brief Enter the device conversation-translation product mode with both languages
     * @chinese 携带双方语言进入设备对话翻译产品模式
     * @param mode EN: Pickup layout used by the device product page. CN: 设备产品页面使用的拾音组合。
     * @param selfLanguage EN: Language of the local user side. CN: 本机用户侧语言。
     * @param peerLanguage EN: Language of the peer side. CN: 对方侧语言。
     * @param completion EN: Device acknowledgement result. CN: 设备应答结果。
     * @discussion EN: Preferred over the language-less variant when implemented; the device
     *                 shows the languages on its screen.
     *             CN: 实现后优先于无语言的变体被调用；设备据此在屏端显示语言。
     */
    - (void)startDeviceConversationTranslationWithMode:(TSAIConversationTranslationMode)mode
                                          selfLanguage:(TSAILanguage)selfLanguage
                                          peerLanguage:(TSAILanguage)peerLanguage
                                            completion:(nullable TSAICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
