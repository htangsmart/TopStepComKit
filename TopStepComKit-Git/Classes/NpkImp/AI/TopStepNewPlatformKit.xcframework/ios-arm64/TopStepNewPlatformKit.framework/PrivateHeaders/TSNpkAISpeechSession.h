//
//  TSNpkAISpeechSession.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/10/27.
//

#import <Foundation/Foundation.h>
#import "TSNpkAISpeechDefines.h"
#import "TSNpkOpusDecoder.h"

@class TSNpkBleConnectionInformation;
@class TSNpkAISpeechSession;
@class TSNpkAIResultFragment;
@class TSMetaAIMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Error domain for the NPK speech transport lifecycle
 * @chinese NPK 语音传输生命周期错误域
 */
FOUNDATION_EXPORT NSErrorDomain const TSNpkAISpeechErrorDomain;

/**
 * @brief Speech transport lifecycle errors
 * @chinese 语音传输生命周期错误
 */
typedef NS_ENUM(NSInteger, TSNpkAISpeechErrorCode) {
    TSNpkAISpeechErrorInvalidArgument = 1000,
    TSNpkAISpeechErrorNotReady,
    TSNpkAISpeechErrorBusy,
    TSNpkAISpeechErrorUnsupported,
    TSNpkAISpeechErrorStaleRequest,
    TSNpkAISpeechErrorOpeningRejected,
    TSNpkAISpeechErrorTimeout,
    TSNpkAISpeechErrorInvalidAudio,
    TSNpkAISpeechErrorOverflow,
    TSNpkAISpeechErrorCancelled,
    TSNpkAISpeechErrorDeviceExited,
    TSNpkAISpeechErrorDisconnected
};

/**
 * @brief Origin of one speech request
 * @chinese 单次语音请求的发起方
 */
typedef NS_ENUM(NSUInteger, TSNpkAISpeechInitiator) {
    TSNpkAISpeechInitiatorApp,
    TSNpkAISpeechInitiatorDevice
};

/**
 * @brief Local speech lifecycle state
 * @chinese 本地语音生命周期状态
 */
typedef NS_ENUM(NSUInteger, TSNpkAISpeechSessionState) {
    TSNpkAISpeechSessionStateIdle,
    TSNpkAISpeechSessionStatePending,
    TSNpkAISpeechSessionStatePreparing,
    TSNpkAISpeechSessionStateOpening,
    TSNpkAISpeechSessionStateAwaitingAudio,
    TSNpkAISpeechSessionStateStreaming,
    TSNpkAISpeechSessionStateInputCompleted,
    TSNpkAISpeechSessionStateEnding,
    TSNpkAISpeechSessionStateCleanupUnknown
};

/**
 * @brief Configuration copied when attaching a speech consumer
 * @chinese 登记语音消费者时复制的配置
 *
 * @discussion
 * [EN]: This is local policy, not a claim about firmware framing or cleanup barriers.
 * [CN]: 此配置是本地策略，不代表固件已经证明帧边界或清场屏障。
 */
@interface TSNpkAISpeechConfiguration : NSObject <NSCopying>

/**
 * @brief Explicitly verified Opus framing mode
 * @chinese 显式核验的 Opus 分帧模式
 *
 * @discussion
 * [EN]: May be supplied explicitly by the device integration, or resolved from a verified
 *       firmware profile after OpusHead arrives.
 * [CN]: 可以由设备集成方显式提供，也可以在收到 OpusHead 后根据已核验固件 profile 解析。
 *
 * @note
 * [EN]: Defaults to Unknown; a verified connection profile resolves it after OpusHead.
 *       An unknown profile never configures or starts the decoder.
 * [CN]: 默认为 Unknown；已核验连接 profile 会在收到 OpusHead 后解析，未知 profile 不会配置或启动解码器。
 */
@property (nonatomic, assign) TSNpkOpusFramingMode framingMode;

/**
 * @brief Preparation deadline in seconds
 * @chinese 准备阶段超时，单位秒
 *
 * @discussion
 * [EN]: Bounds device-request acceptance and transport admission.
 * [CN]: 限制设备请求等待接受及传输准入的时长。
 *
 * @note
 * [EN]: Defaults to 5; must be finite and positive.
 * [CN]: 默认为 5；必须为有限正数。
 */
@property (nonatomic, assign) NSTimeInterval preparationTimeout;

/**
 * @brief Opening-response deadline in seconds
 * @chinese 开启应答超时，单位秒
 *
 * @discussion
 * [EN]: Bounds the original 0x15 to 0x16 transaction.
 * [CN]: 限制原 0x15 到 0x16 开启事务的时长。
 *
 * @note
 * [EN]: Defaults to 5; no same-key response is assumed.
 * [CN]: 默认为 5；不假设同 key 应答。
 */
@property (nonatomic, assign) NSTimeInterval openingTimeout;

/**
 * @brief First decoded audio deadline in seconds
 * @chinese 首段解码音频超时，单位秒
 *
 * @discussion
 * [EN]: Starts after the matching opening response and includes the format header.
 * [CN]: 从匹配的开启应答后开始计时，包含等待格式头的时间。
 *
 * @note
 * [EN]: Defaults to 10; a header alone does not satisfy this deadline.
 * [CN]: 默认为 10；仅收到头部不能满足此期限。
 */
@property (nonatomic, assign) NSTimeInterval firstAudioTimeout;

/**
 * @brief Decoded-audio inactivity deadline in seconds
 * @chinese 解码音频静默超时，单位秒
 *
 * @discussion
 * [EN]: Measures time since the last successfully decoded samples.
 * [CN]: 从最后成功解码的样本开始计时。
 *
 * @note
 * [EN]: Defaults to 5; transport packet counts do not reset it.
 * [CN]: 默认为 5；传输包数量不会重置此期限。
 */
@property (nonatomic, assign) NSTimeInterval inactivityTimeout;

/**
 * @brief Absolute local session deadline in seconds
 * @chinese 本地会话绝对超时，单位秒
 *
 * @discussion
 * [EN]: Also bounds the logical business reservation after normal input completion.
 * [CN]: 同时约束正常输入结束后的逻辑业务占位。
 *
 * @note
 * [EN]: Defaults to 300; must be finite and positive.
 * [CN]: 默认为 300；必须为有限正数。
 */
@property (nonatomic, assign) NSTimeInterval maximumSessionDuration;

@end

/**
 * @brief Immutable identity of a single speech capture
 * @chinese 单次语音采集的不可变身份
 */
@interface TSNpkAISpeechRequest : NSObject <NSCopying>

/**
 * @brief Unique logical request identifier
 * @chinese 唯一逻辑请求标识
 *
 * @discussion
 * [EN]: Also identifies the original transport owner; never reused.
 * [CN]: 同时标识原传输所有者，不会复用。
 *
 * @note
 * [EN]: Nonempty and generated once by the session.
 * [CN]: 非空，由会话创建一次。
 */
@property (nonatomic, copy, readonly) NSString *requestIdentifier;

/**
 * @brief Consumer activation identity
 * @chinese 消费者激活身份
 *
 * @discussion
 * [EN]: Captures the consumer lease that created or received this request.
 * [CN]: 捕获创建或接收本请求的消费者租约。
 *
 * @note
 * [EN]: Historical requests retain their original value after detachment.
 * [CN]: 消费者解绑后，历史请求仍保留原值。
 */
@property (nonatomic, copy, readonly) NSString *activationToken;

/**
 * @brief Unique capture identifier
 * @chinese 唯一采集标识
 *
 * @discussion
 * [EN]: Separates audio callbacks from future captures of the same business scene.
 * [CN]: 将音频回调与同业务场景的后续采集区分。
 *
 * @note
 * [EN]: One value per request; this step supports a single capture only.
 * [CN]: 每个请求一个值；本步仅支持单次采集。
 */
@property (nonatomic, copy, readonly) NSString *captureIdentifier;

/**
 * @brief NPK wire scene
 * @chinese NPK 线协议场景
 *
 * @discussion
 * [EN]: Stores an explicitly validated NPK scene from 0 through 8.
 * [CN]: 保存已显式验证的 NPK 场景，取值 0 至 8。
 *
 * @note
 * [EN]: This value is not an AIKit scene enum.
 * [CN]: 此值不是 AIKit 场景枚举。
 */
@property (nonatomic, assign, readonly) TSNpkAISpeechScene scene;

/**
 * @brief Request origin
 * @chinese 请求来源
 *
 * @discussion
 * [EN]: Distinguishes App and device capability masks.
 * [CN]: 用于区分 App 与设备方向能力位图。
 *
 * @note
 * [EN]: Frozen when the request is created.
 * [CN]: 创建请求时冻结。
 */
@property (nonatomic, assign, readonly) TSNpkAISpeechInitiator initiator;

/**
 * @brief Authenticated device identifier
 * @chinese 已认证的设备标识
 *
 * @discussion
 * [EN]: Copies the authenticated physical peripheral UUID string.
 * [CN]: 复制已认证物理外设的 UUID 字符串。
 *
 * @note
 * [EN]: Never replaced by a later selected device.
 * [CN]: 不会替换为后来选择的设备。
 */
@property (nonatomic, copy, readonly) NSString *deviceIdentifier;

/**
 * @brief Original physical connection generation
 * @chinese 原物理连接代次
 *
 * @discussion
 * [EN]: Uses BleMeta's sole physical epoch.
 * [CN]: 使用 BleMeta 的唯一物理代次。
 *
 * @note
 * [EN]: Reconnecting requires a new request even for the same peripheral.
 * [CN]: 即使外设相同，重新连接也必须创建新请求。
 */
@property (nonatomic, assign, readonly) NSUInteger connectionGeneration;

/**
 * @brief Original immutable authenticated information
 * @chinese 原不可变认证信息
 *
 * @discussion
 * [EN]: Carries the original connection owner and raw device declarations.
 * [CN]: 携带原连接所有者和原始设备声明。
 *
 * @note
 * [EN]: Historical information alone does not establish current connection readiness.
 * [CN]: 仅持有历史信息不能证明当前连接就绪。
 */
@property (nonatomic, strong, readonly) TSNpkBleConnectionInformation *connectionInformation;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief Consumer of owned NPK speech events
 * @chinese 具归属 NPK 语音事件的消费者
 *
 * @discussion
 * [EN]: Events run in order on the attached serial queue. Every event retains its original request.
 * [CN]: 事件按序运行在登记的串行队列，每个事件均携带原请求。
 */
@protocol TSNpkAISpeechConsumer <NSObject>
@optional
/**
 * @brief Receive a device request awaiting explicit readiness
 * @chinese 接收等待显式就绪的设备请求
 * @param session
 * EN: Original speech session.
 * CN: 原语音会话。
 * @param request
 * EN: Immutable request to accept or reject once.
 * CN: 只能接受或拒绝一次的不可变请求。
 */
- (void)speechSession:(TSNpkAISpeechSession *)session didReceivePendingRequest:(TSNpkAISpeechRequest *)request;

/**
 * @brief Receive successful opening acknowledgement
 * @chinese 接收开启应答成功事件
 * @param session
 * EN: Original session.
 * CN: 原会话。
 * @param request
 * EN: Original successfully opened request.
 * CN: 原成功开启请求。
 */
- (void)speechSession:(TSNpkAISpeechSession *)session didStartRequest:(TSNpkAISpeechRequest *)request;

/**
 * @brief Receive ordered mono 16 kHz Int16LE PCM
 * @chinese 接收有序的单声道 16 kHz Int16LE PCM
 * @param session
 * EN: Original session.
 * CN: 原会话。
 * @param data
 * EN: Immutable PCM bytes; consume without retaining an unbounded backlog.
 * CN: 不可变 PCM 字节；消费时不可保留无界积压。
 * @param request
 * EN: Original capture identity.
 * CN: 原采集身份。
 */
- (void)speechSession:(TSNpkAISpeechSession *)session
   didReceivePCMData:(NSData *)data
              request:(TSNpkAISpeechRequest *)request;

/**
 * @brief Receive normal input completion after the final PCM
 * @chinese 在最后 PCM 后接收正常输入结束事件
 * @param session
 * EN: Original session.
 * CN: 原会话。
 * @param request
 * EN: Original request; its business reservation remains active.
 * CN: 原请求，其业务占位仍保持有效。
 */
- (void)speechSession:(TSNpkAISpeechSession *)session didCompleteInputForRequest:(TSNpkAISpeechRequest *)request;

/**
 * @brief Receive an answer request from the original opened Ask capture
 * @chinese 接收原已开启 Ask 采集的答案确认请求
 *
 * @param session
 * EN: Original speech session.
 * CN: 原语音会话。
 *
 * @param request
 * EN: Exact immutable Ask capture, retaining its original connection and consumer lease.
 * CN: 精确的原不可变 Ask 采集，保留原连接及消费者租约。
 *
 * @discussion
 * [EN]: Delivered in order on the consumer queue, with at most one delivery pending.
 *       The consumer validates its final-ASR phase and once-only consumption; this transport
 *       does not cache a signal for a later ASR phase or acknowledge it to firmware.
 * [CN]: 在消费者队列保序交付，至多保留一个待交付事件；消费者校验最终 ASR 阶段及一次消费。
 *       传输层不为未来 ASR 阶段缓存信号，也不向固件发送应答。
 */
- (void)speechSession:(TSNpkAISpeechSession *)session didConfirmQuestionForRequest:(TSNpkAISpeechRequest *)request;

/**
 * @brief Receive an AI action from the original device request
 * @chinese 接收原设备请求下发的 AI 动作
 * @param message EN: Decoded 0x02/0x6E action. CN: 已解析的 0x02/0x6E 动作。
 * @param request EN: Original speech request. CN: 原语音请求。
 */
- (void)speechSession:(TSNpkAISpeechSession *)session
  didReceiveAIMessage:(TSMetaAIMessage *)message
              request:(TSNpkAISpeechRequest *)request;

/**
 * @brief Receive a terminal event after local receive, codec and write barriers
 * @chinese 在本地接收、解码和写屏障后接收终止事件
 * @param session
 * EN: Original session.
 * CN: 原会话。
 * @param request
 * EN: Original ended request.
 * CN: 原已结束请求。
 * @param error
 * EN: Failure or cancellation reason; nil for explicit normal business completion.
 * CN: 失败或取消原因；显式正常业务结束时为 nil。
 */
- (void)speechSession:(TSNpkAISpeechSession *)session
       didEndRequest:(TSNpkAISpeechRequest *)request
                 error:(nullable NSError *)error;
@end

/**
 * @brief Long-lived owner of NPK speech notifications and one active capture
 * @chinese 长期持有 NPK 语音通知并管理单个活动采集的所有者
 *
 * @discussion
 * [EN]: Provider readiness belongs to the consumer. The consumer calls start or accept only after it is ready.
 * [CN]: Provider 就绪由消费者负责；消费者仅在真正就绪后调用 start 或 accept。
 * [EN]: Error completions for retired or unknown consumer leases fall back to the main queue.
 * [CN]: 已解绑或未知消费者租约的错误完成回调使用主队列。
 */
@interface TSNpkAISpeechSession : NSObject

/**
 * @brief Current local lifecycle state
 * @chinese 当前本地生命周期状态
 *
 * @discussion
 * [EN]: A synchronized snapshot of the private control queue state.
 * [CN]: 私有控制队列状态的同步快照。
 *
 * @note
 * [EN]: CleanupUnknown prevents reuse for incomplete or failed cleanup until the physical connection generation changes.
 * [CN]: 未完成或失败的清理会进入 CleanupUnknown，直至物理连接代次变化前阻止复用。
 */
@property (nonatomic, assign, readonly) TSNpkAISpeechSessionState state;

/**
 * @brief Current immutable request snapshot
 * @chinese 当前不可变请求快照
 *
 * @discussion
 * [EN]: Includes pending, opening, input and business phases.
 * [CN]: 包含等待、开启、输入和业务占位阶段。
 *
 * @note
 * [EN]: Nil when there is no local request; retained old values remain historical.
 * [CN]: 无本地请求时为 nil；已持有的旧值仍为历史记录。
 */
@property (nonatomic, strong, readonly, nullable) TSNpkAISpeechRequest *currentRequest;

/**
 * @brief Obtain the long-lived speech owner
 * @chinese 获取长期语音所有者
 * @return
 * EN: Process-local shared owner.
 * CN: 进程内共享所有者。
 */
+ (instancetype)sharedSession;

/**
 * @brief Register permanent protocol listeners once
 * @chinese 一次性登记永久协议监听
 *
 * @discussion
 * [EN]: Keeps listeners when consumers detach, including the ability to reject unhandled device requests.
 * [CN]: 消费者解绑后保留监听，以继续拒绝无人处理的设备请求。
 */
- (void)startObserving;

/**
 * @brief Attach a weak consumer and freeze its configuration
 * @chinese 登记弱引用消费者并冻结其配置
 * @param consumer
 * EN: Event consumer; PCM handling is required before opening audio.
 * CN: 事件消费者；开启音频前必须实现 PCM 消费。
 * @param queue
 * EN: Caller-owned serial event queue; never the session control or BLE delegate queue.
 * CN: 调用方持有的串行事件队列；不可为会话控制或 BLE 代理队列。
 * @param configuration
 * EN: Configuration copied before asynchronous admission.
 * CN: 异步准入前复制的配置。
 * @param completion
 * EN: Called once on queue with the lease or an error; an existing consumer is never silently replaced.
 * CN: 在 queue 回调一次，返回租约或错误；不会静默替换已有消费者。
 */
- (void)attachConsumer:(id<TSNpkAISpeechConsumer>)consumer
                 queue:(dispatch_queue_t)queue
         configuration:(TSNpkAISpeechConfiguration *)configuration
            completion:(void (^)(NSUUID * _Nullable lease, NSError * _Nullable error))completion;

/**
 * @brief Detach only the original consumer and await its local barriers
 * @chinese 仅解绑原消费者并等待其本地屏障
 * @param lease
 * EN: Original consumer lease; a stale lease cannot detach a newer consumer.
 * CN: 原消费者租约；旧租约不能解绑新消费者。
 * @param completion
 * EN: Called once on the original consumer queue after its barriers; a stale unregistered lease uses main.
 * CN: 原屏障完成后在原消费者队列回调一次；已注销的旧租约使用主队列。
 */
- (void)detachConsumerForLease:(NSUUID *)lease completion:(nullable dispatch_block_t)completion;

/**
 * @brief Start one App-origin Opus capture after consumer readiness
 * @chinese 消费者就绪后启动一次 App 发起的 Opus 采集
 * @param scene
 * EN: Explicit NPK scene declared by the App-origin capability mask.
 * CN: App 方向能力位图声明的显式 NPK 场景。
 * @param lease
 * EN: Current consumer lease.
 * CN: 当前消费者租约。
 * @param completion
 * EN: Called once on the consumer queue after the matching response, or with an error.
 * CN: 收到匹配应答后或失败时，在消费者队列回调一次。
 *
 * @discussion
 * [EN]: Captures authenticated information and the exact peripheral at call entry; changing the connection while queued
 *       returns NotReady instead of rebinding the intent to a later device.
 * [CN]: 在调用入口冻结认证信息及确切外设；排队期间换连接返回 NotReady，不将原意图重绑到后来的设备。
 */
- (void)startScene:(TSNpkAISpeechScene)scene
     consumerLease:(NSUUID *)lease
        completion:(void (^)(TSNpkAISpeechRequest * _Nullable request, NSError * _Nullable error))completion;

/**
 * @brief Start with a caller identity available before opening acknowledgement
 * @chinese 使用开启应答前已确定的调用方标识启动
 * @param scene
 * EN: Declared NPK scene.
 * CN: 已声明的 NPK 场景。
 * @param lease
 * EN: Original consumer lease.
 * CN: 原消费者租约。
 * @param identifier
 * EN: Unique nonempty caller identity, never reused across starts.
 * CN: 非空唯一调用标识，各次启动不得复用。
 * @param completion
 * EN: Original start result on the consumer queue; physical target is frozen at call entry.
 * CN: 消费者队列上的原启动结果；在调用入口冻结物理目标。
 */
- (void)startScene:(TSNpkAISpeechScene)scene
     consumerLease:(NSUUID *)lease
 requestIdentifier:(NSString *)identifier
        completion:(void (^)(TSNpkAISpeechRequest * _Nullable request, NSError * _Nullable error))completion;

/**
 * @brief End a caller-owned start even while acknowledgement is pending
 * @chinese 在等待应答期间也能结束调用方所属启动
 * @param identifier
 * EN: Identity passed to the corresponding start call.
 * CN: 对应启动调用传入的标识。
 * @param lease
 * EN: Original consumer lease; both values must match.
 * CN: 原消费者租约，两项必须匹配。
 * @param completion
 * EN: Consumer-queue completion after local barriers, or a stale-request error.
 * CN: 本地屏障后的消费者队列完成回调，或原请求失效错误。
 */
- (void)endRequestWithIdentifier:(NSString *)identifier consumerLease:(NSUUID *)lease
                     completion:(nullable void (^)(NSError * _Nullable error))completion;

/**
 * @brief Validate an exact request for business result delivery
 * @chinese 核验业务结果交付的精确请求
 * @param request
 * EN: Original capture request; normal input completion retains business ownership.
 * CN: 原采集请求，正常输入结束仍保留业务归属。
 * @return
 * EN: YES while its authenticated business gate remains current and unblocked.
 * CN: 已认证业务门禁仍有效且未封闭时返回 YES。
 */
- (BOOL)isCurrentResultRequest:(TSNpkAISpeechRequest *)request;

/**
 * @brief Send one complete AI-result protocol fragment under the existing owner
 * @chinese 在现有所有者下发送一个完整 AI 结果协议片段
 * @param fragment
 * EN: Immutable payload and common multipart metadata.
 * CN: 不可变载荷与通用分包元数据。
 * @param request
 * EN: Original capture request.
 * CN: 原采集请求。
 * @param groupIdentifier
 * EN: Unique snapshot-group identity; do not reuse it after cancellation or completion.
 * CN: 唯一快照组标识，取消或完成后不得复用。
 * @param completion
 * EN: Called once on the consumer queue for local transmission only; no device display ACK is implied.
 * CN: 仅本地发送终态在消费者队列回调一次，不表示设备显示应答。
 */
- (void)sendAIResultFragment:(TSNpkAIResultFragment *)fragment request:(TSNpkAISpeechRequest *)request
           groupIdentifier:(NSString *)groupIdentifier completion:(void (^)(NSError * _Nullable error))completion;

/**
 * @brief Cancel and drain only the captured result group
 * @chinese 仅取消并排空捕获的原结果组
 * @param groupIdentifier
 * EN: Original group identity; other groups and control requests are untouched.
 * CN: 原组标识，不影响其他组或控制请求。
 * @param request
 * EN: Original capture identity.
 * CN: 原采集标识。
 * @param completion
 * EN: Called once on the consumer queue after original owned write barriers.
 * CN: 原具归属写屏障后在消费者队列回调一次。
 * @discussion
 * [EN]: Cancelling a possibly submitted partial group blocks further results for this capture.
 * [CN]: 取消可能已提交的半组会封闭本次采集的后续结果通道。
 */
- (void)cancelAIResultGroup:(NSString *)groupIdentifier request:(TSNpkAISpeechRequest *)request
                completion:(nullable dispatch_block_t)completion;

/**
 * @brief Accept the exact pending device request once
 * @chinese 仅接受一次精确的待处理设备请求
 * @param request
 * EN: The immutable pending request originally delivered to this consumer.
 * CN: 原先交付给该消费者的不可变待处理请求。
 * @param lease
 * EN: Original consumer lease.
 * CN: 原消费者租约。
 * @param completion
 * EN: Called once on the consumer queue after matching acknowledgement or failure.
 * CN: 匹配应答或失败后，在消费者队列回调一次。
 */
- (void)acceptRequest:(TSNpkAISpeechRequest *)request
        consumerLease:(NSUUID *)lease
           completion:(void (^)(TSNpkAISpeechRequest * _Nullable request, NSError * _Nullable error))completion;

/**
 * @brief Reject the exact pending device request with an App close
 * @chinese 用 App 关闭指令拒绝精确的待处理设备请求
 * @param request
 * EN: Original pending request; already consumed requests are rejected locally.
 * CN: 原待处理请求；已消费的请求会在本地拒绝。
 * @param lease
 * EN: Original consumer lease.
 * CN: 原消费者租约。
 * @param completion
 * EN: Called once after local drain with admission/write failure, or nil for a locally sent rejection.
 * CN: 本地排空后回调一次，返回准入/写入错误；本地拒绝发送完成时为 nil。
 * @discussion
 * [EN]: The consumer still receives Cancelled as the business end reason. No device cleanup ACK is implied.
 * [CN]: 消费者仍收到 Cancelled 业务结束原因；此结果不代表设备清场应答。
 */
- (void)rejectRequest:(TSNpkAISpeechRequest *)request
        consumerLease:(NSUUID *)lease
           completion:(nullable void (^)(NSError * _Nullable error))completion;

/**
 * @brief Close recording input and drain accepted audio without ending its business reservation
 * @chinese 关闭录音输入并排空已接纳音频，保留业务占位
 *
 * @param request
 * EN: Exact original recording request whose input has opened.
 * CN: 已开启输入的原始录音请求对象。
 *
 * @param lease
 * EN: Original consumer lease, never rebound to a later consumer.
 * CN: 原消费者租约，不重新绑定后来的消费者。
 *
 * @param completion
 * EN: Called once on the original consumer queue after local close and ordered input-completed delivery,
 *     or after termination barriers with its original error. Repeated calls share the same local drain.
 * CN: 本地关闭及有序输入完成交付后，在原消费者队列回调一次；若终止则在终止屏障后返回原错误。
 *     重复调用等待同一次本地排空。
 *
 * @discussion
 * [EN]: Only the recording scene supports this entry. Provider finalization must follow the ordered
 *       input-completed event; this completion is not a firmware cleanup acknowledgement.
 * [CN]: 本入口仅支持录音场景。Provider收尾应跟随有序的输入完成事件；本回调不是固件清场应答。
 */
- (void)closeInputForRequest:(TSNpkAISpeechRequest *)request
              consumerLease:(NSUUID *)lease
                 completion:(nullable void (^)(NSError * _Nullable error))completion;

/**
 * @brief End the original logical request and await local cleanup
 * @chinese 结束原逻辑请求并等待本地清理
 * @param request
 * EN: Original pending, opening, streaming or input-completed request.
 * CN: 原等待、开启、输入中或输入已完成的请求。
 * @param lease
 * EN: Original consumer lease.
 * CN: 原消费者租约。
 * @param completion
 * EN: Called once on the consumer queue after local barriers; incomplete or failed cleanup remains isolated.
 * CN: 本地屏障后在消费者队列回调一次；未完成或失败的清理继续隔离。
 */
- (void)endRequest:(TSNpkAISpeechRequest *)request
     consumerLease:(NSUUID *)lease
        completion:(nullable void (^)(NSError * _Nullable error))completion;

/**
 * @brief Convert the original realtime owner to an exclusive file operation
 * @chinese 将原实时所有者转换为独占文件事务
 * @param request EN: Input-completed request. CN: 已完成输入的原请求。
 * @param upload EN: YES for TP, NO for PB. CN: YES 表示 TP，NO 表示 PB。
 * @param completion EN: Returns the reserved file operation after owned writes drain.
 * CN: 原所有者写入排空后返回文件登记。
 */
- (void)handoffRealtimeToFileForRequest:(TSNpkAISpeechRequest *)request
                                toUpload:(BOOL)upload
                               completion:(void (^)(NSUUID * _Nullable fileOperation,
                                                    NSError * _Nullable error))completion;

/**
 * @brief Re-admit the original realtime owner after a file operation finishes
 * @chinese 文件事务结束后重新准入原实时所有者
 * @param request EN: Original request. CN: 原请求。
 * @param completion EN: Called after the owner is admitted or rejected.
 * CN: 所有者重新准入或失败后回调。
 */
- (void)resumeRealtimeForRequest:(TSNpkAISpeechRequest *)request
                       completion:(void (^)(NSError * _Nullable error))completion;

/**
 * @brief Reclaim the realtime owner from a completed file operation
 * @chinese 从已完成的文件事务原子回收原实时所有者
 * @param request
 * EN: Original request. CN: 原始请求。
 * @param fileOperation
 * EN: Reserved file operation returned by the handoff. CN: handoff 返回的文件事务。
 * @param completion
 * EN: Called after the owner is reclaimed or rejected.
 * CN: 实时所有者回收成功或失败后回调。
 */
- (void)resumeRealtimeForRequest:(TSNpkAISpeechRequest *)request
                   fileOperation:(NSUUID *)fileOperation
                       completion:(void (^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
