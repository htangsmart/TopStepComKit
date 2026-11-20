//
//  TSCommandRequest.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/23.
//

#import "TSCommandBase.h"
#import "TSCommandDefines.h"
#import "TSParsedPacket.h"
#import "TSCommandDataWrapper.h"
#import "TSRequestOption.h"

@class TSCommandRequest;
@class TSBleWriteContext;

@protocol TSCommandRequestDelegate <NSObject>

/**
 * @brief 请求发送成功回调
 * @chinese 当请求发送成功时调用
 *
 * @param request 发送成功的请求对象
 *        EN: The request that was sent successfully
 *        CN: 发送成功的请求对象
 */
- (void)commandRequestDidSendSuccess:(TSCommandRequest * _Nonnull)request ;

/**
 * @brief 请求发送失败回调（可能重试）
 * @chinese 当请求发送失败时调用，Manager 会判断是否重试
 *
 * @param request 发送失败的请求对象
 *        EN: The request that failed to send
 *        CN: 发送失败的请求对象
 * @param error 失败的错误信息
 *        EN: Error information describing the failure
 *        CN: 描述失败的错误信息
 *
 * @discussion
 * EN: Called for failures that may be retried (e.g., timeout, network error).
 *     Manager will decide whether to retry based on retry policy.
 * CN: 用于可能重试的失败（如超时、网络错误）。
 *     Manager 会根据重试策略决定是否重试。
 */
- (void)commandRequest:(TSCommandRequest *_Nonnull)request didFailToSendWithError:(NSError * _Nullable)error;

/**
 * @brief 请求最终失败回调（不可重试）
 * @chinese 当请求最终失败时调用，不会重试
 *
 * @param request 最终失败的请求对象
 *        EN: The request that finally failed
 *        CN: 最终失败的请求对象
 * @param error 失败的错误信息
 *        EN: Error information describing the failure
 *        CN: 描述失败的错误信息
 *
 * @discussion
 * EN: Called for final failures that should not be retried (e.g., total timeout, cancellation).
 *     Manager will handle the final failure and proceed to next request.
 * CN: 用于不应重试的最终失败（如总超时、用户取消）。
 *     Manager 会处理最终失败并继续处理下一个请求。
 */
- (void)commandRequest:(TSCommandRequest *_Nonnull)request didFinallyFailWithError:(NSError * _Nullable)error;

@end

/**
 * @brief 请求状态枚举
 * @chinese 请求的当前状态
 */
typedef NS_ENUM(UInt8, TSRequestStatus) {
    TSRequestStatusPending = 0,      // 等待中
    TSRequestStatusProcessing = 1,   // 进行中
    TSRequestStatusSuccess = 2,      // 已完成
    TSRequestStatusFailed = 3,       // 失败
    TSRequestStatusCancelled = 4     // 已取消
};

/**
 * @brief 请求消息类型枚举
 * @chinese 区分请求、响应、通知三种消息类型
 */
typedef NS_ENUM(UInt8, TSRequestType) {
    TSRequestTypeRequest = 0,   // 主动请求
    TSRequestTypeResponse = 1,  // 响应
    TSRequestTypeNotify = 2     // 设备通知
};

/**
 * @brief 请求优先级枚举
 * @chinese 请求优先级类型
 */
typedef NS_ENUM(UInt8, TSRequestPriority) {
    TSRequestPriorityLow = 0,      // 低优先级
    TSRequestPriorityNormal = 1,   // 普通优先级
    TSRequestPriorityHigh = 2,     // 高优先级
    TSRequestPriorityCritical = 3  // 紧急优先级
};

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief 请求进度回调类型
 * @chinese 请求发送过程中的进度回调
 *
 * @discussion
 * [EN]: Progress value is in range [0.0, 1.0]. Called on main thread.
 * [CN]: 进度取值范围为 [0.0, 1.0]。在主线程回调。
 */
typedef void(^TSRequestProgressBlock)(CGFloat progress);

/**
 * @brief 请求状态变更回调类型
 * @chinese 当请求状态变化时触发
 *
 * @discussion
 * [EN]: Notifies state transitions such as Pending → Processing → Success/Failed.
 * [CN]: 用于通知状态变化，如 Pending → Processing → Success/Failed。
 */
typedef void(^TSRequestStateChangedBlock)(TSRequestStatus state);

/**
 * @brief Request callback invoked immediately before the first transmission
 * @chinese 请求首次发送前立即执行的回调
 *
 * @param request
 * [EN]: Request whose sequence ID has been assigned and which is about to be sent.
 * [CN]: 已分配序列号且即将发送的请求。
 *
 * @return
 * [EN]: YES to continue transmission; NO to cancel without sending.
 * [CN]: 返回 YES 继续发送；返回 NO 则不发包并取消请求。
 *
 * @discussion
 * [EN]: This callback is invoked exactly once by TSRequestManager before the first
 *       transmission. It is not invoked again when the request is retried.
 * [CN]: 该回调由 TSRequestManager 在首次发送前执行且仅执行一次，请求重试时不会再次执行。
 */
typedef BOOL(^TSRequestWillStartBlock)(TSCommandRequest *request);

/**
 * @brief Request callback invoked when execution is cancelled
 * @chinese 请求执行被取消时调用的回调
 *
 * @param error
 * [EN]: Error describing the cancellation.
 * [CN]: 描述请求取消原因的错误。
 *
 * @discussion
 * [EN]: This opt-in callback is independent from the normal completion callback.
 *       TSRequestManager takes and clears it before invocation to guarantee at-most-once delivery.
 * [CN]: 该回调为可选能力，与普通完成回调相互独立。
 *       TSRequestManager 调用前会先取出并清空，以保证最多送达一次。
 */
typedef void(^TSRequestCancellationBlock)(NSError *error);

/**
 * @brief 单响应完成回调类型
 * @chinese 针对非分包场景或仅取第一条数据的完成回调
 *
 * @discussion
 * [EN]: Used when request expects a single response payload.
 * [CN]: 用于仅返回单条响应数据的场景。
 */
typedef void(^TSRequestCompletionBlock)(BOOL isSuccess,NSData *_Nullable respondData, NSError *_Nullable error);

/**
 * @brief 多响应完成回调类型
 * @chinese 针对分包/多条指令返回的完成回调，返回对象数组
 *
 * @discussion
 * [EN]: Each element in respondDatas is a complete logical item (e.g., one alarm/contact),
 *       not a byte-fragment. Order follows packet indices.
 * [CN]: respondDatas 中的每个元素均为完整的逻辑对象（如一条闹钟/联系人），
 *       而非原始字节分片，顺序与分包索引一致。
 */
typedef void(^TSRequestListCompletionBlock)(BOOL isSuccess,NSArray <NSData *> *_Nullable respondDatas, NSError *_Nullable error);

/**
 * @brief Deliver a notification with its original host source
 * @chinese 携带原始主机来源交付通知
 *
 * @param success
 * EN: YES for a complete notification; NO for an ingress or assembly error.
 * CN: 完整通知为 YES，入口或组包错误为 NO。
 *
 * @param payloads
 * EN: Immutable completed payloads, or nil for overflow.
 * CN: 不可变的完整载荷；超限时为 nil。
 *
 * @param sourcePacket
 * EN: Original immutable packet; fragmented messages use their completing packet.
 * CN: 原始不可变包；分包消息使用完成组包的包。
 *
 * @param error
 * EN: Notification error, or nil on success.
 * CN: 通知错误，成功时为 nil。
 */
typedef void(^TSRequestNotificationCompletionBlock)(BOOL success,
    NSArray<NSData *> * _Nullable payloads, TSParsedPacket *sourcePacket, NSError * _Nullable error);


/**
 * @brief 蓝牙数据请求对象
 * @chinese 用于描述一次蓝牙数据请求的所有参数、状态和回调
 *
 * @discussion
 * EN: This class represents a complete Bluetooth data request, including command parameters,
 *     payload data, fragmentation strategy, and various callback handlers.
 *     The packetMode property determines how payload data is wrapped and fragmented.
 * CN: 此类表示一个完整的蓝牙数据请求，包括命令参数、载荷数据、分包策略和各种回调处理器。
 *     packetMode 属性决定载荷数据如何包装和分包。
 */
@interface TSCommandRequest : TSCommandBase

/**
 * @brief Immutable logical transport owner
 * @chinese 不可变的逻辑传输所有者
 *
 * @discussion
 * [EN]: Configured once before execution; one unique value belongs to one logical session.
 * [CN]: 在执行前配置一次，每个唯一值对应一个逻辑会话。
 *
 * @note
 * [EN]: Nil means no logical lease; a normal request may still freeze a physical context. Never reuse a finished owner.
 * [CN]: 为 nil 表示没有逻辑租约；普通请求仍可冻结物理上下文。结束后的所有者值不可复用。
 */
@property (nonatomic, copy, readonly, nullable) NSString *transportOwnerIdentifier;

/**
 * @brief Frozen physical target and write operation identity
 * @chinese 冻结的物理目标及写操作身份
 *
 * @discussion
 * [EN]: The immutable context is shared by validation, transmission and operation cancellation.
 * [CN]: 同一不可变上下文用于归属校验、发送和按操作取消。
 *
 * @note
 * [EN]: Nil for legacy requests; every context-bound request must use a unique operation identifier.
 * [CN]: 原请求为 nil；每个绑定上下文的请求必须使用独立的操作标识。
 */
@property (nonatomic, strong, readonly, nullable) TSBleWriteContext *writeContext;

/**
 * @brief Original multipart index for one separately scheduled payload
 * @chinese 独立调度单载荷的原多包序号
 * @discussion
 * [EN]: Configured once before execution; retained across request retries.
 * [CN]: 执行前配置一次，请求重试时保留。
 * @note
 * [EN]: Defaults to zero; meaningful only when packetFragmentCount is positive.
 * [CN]: 默认为零，仅 packetFragmentCount 为正数时有意义。
 */
@property (nonatomic, assign, readonly) NSUInteger packetFragmentIndex;

/**
 * @brief Original multipart count for one separately scheduled payload
 * @chinese 独立调度单载荷的原多包总数
 * @discussion
 * [EN]: Preserves a complete message's group metadata while the scheduler may insert other commands between packets.
 * [CN]: 保留完整消息的原组元信息，调度器可在完整协议包之间插入其他命令。
 * @note
 * [EN]: Defaults to zero for the legacy wrapping path; positive values require exactly one complete payload.
 * [CN]: 默认为零，沿用历史包装路径；正值要求恰好一份完整载荷。
 */
@property (nonatomic, assign, readonly) NSUInteger packetFragmentCount;

/**
 * @brief Freeze original multipart metadata before request execution
 * @chinese 在请求执行前冻结原多包元信息
 * @param index
 * EN: Original zero-based part index.
 * CN: 原组内从零开始的序号。
 * @param count
 * EN: Positive group count representable by UInt32.
 * CN: 可由 UInt32 表示的正数组总数。
 * @return
 * EN: YES once before start; NO for invalid, repeated or multi-payload configuration.
 * CN: 开始前首次配置成功返回 YES；无效、重复或多载荷配置返回 NO。
 */
- (BOOL)configurePacketFragmentWithIndex:(NSUInteger)index count:(NSUInteger)count;

/**
 * @brief Optional callback delivery queue
 * @chinese 可选的回调交付队列
 *
 * @discussion
 * [EN]: Progress, state and completion callbacks use this queue; manager lifecycle does not wait for it.
 * [CN]: 进度、状态和完成回调使用此队列，管理器生命周期不等待该队列。
 *
 * @note
 * [EN]: Nil defaults to the main queue. Configure a serial queue before execution.
 * [CN]: 为 nil 时默认主队列；应在执行前配置串行队列。
 */
@property (nonatomic, strong, nullable) dispatch_queue_t callbackQueue;

/**
 * @brief Configure transport ownership once before execution
 * @chinese 在执行前一次性配置传输归属
 *
 * @param ownerIdentifier
 * EN: Unique logical owner that has been admitted by the request manager.
 * CN: 已由请求管理器准入的唯一逻辑所有者。
 *
 * @param context
 * EN: Immutable target context with a request-specific operation identifier.
 * CN: 带有本请求独立操作标识的不可变目标上下文。
 *
 * @return
 * EN: YES if configured; NO for invalid parameters, repeated configuration or started requests.
 * CN: 配置成功返回 YES；参数无效、重复配置或请求已开始时返回 NO。
 */
- (BOOL)configureTransportWithOwner:(NSString *)ownerIdentifier context:(TSBleWriteContext *)context;

/**
 * @brief Freeze the physical target of a normal request before execution
 * @chinese 在执行前冻结普通请求的物理目标
 *
 * @param context
 * EN: Original peripheral, nonzero connection generation and nonempty operation identifier.
 * CN: 原始外设、非零连接代次及非空操作标识。
 *
 * @return
 * EN: YES once before execution; NO for invalid or repeated configuration.
 * CN: 执行前首次有效配置返回 YES；参数无效或重复配置返回 NO。
 *
 * @discussion
 * [EN]: Does not acquire a realtime lease. Normal requests remain rejected while another realtime owner is active.
 * [CN]: 不申请实时租约；其他实时所有者占用期间，普通请求仍会被拒绝。
 */
- (BOOL)configureTransportWithContext:(TSBleWriteContext *)context;

/**
 * @brief Select bounded serial notification delivery
 * @chinese 选择有界的串行通知交付
 *
 * @param queue
 * EN: Consumer-owned serial queue; decoding must not run on the BLE delegate queue.
 * CN: 消费者持有的串行队列，解码不可运行在 BLE 代理队列。
 *
 * @param maximumPendingBytes
 * EN: Positive byte budget covering pending and currently executing notification payloads.
 * CN: 正数字节预算，覆盖等待中及执行中的通知载荷。
 *
 * @param maximumPendingPackets
 * EN: Positive completed-notification budget; overflow delivers one terminal error.
 * CN: 正数完整通知预算，超限时仅交付一次终止错误。
 *
 * @return
 * EN: YES if configured before any notification was accepted.
 * CN: 在接纳第一条通知前配置成功返回 YES。
 */
- (BOOL)configureNotificationDeliveryOnQueue:(dispatch_queue_t)queue
                       maximumPendingBytes:(NSUInteger)maximumPendingBytes
                     maximumPendingPackets:(NSUInteger)maximumPendingPackets;

/**
 * @brief Invalidate notification fragments and not-yet-claimed deliveries
 * @chinese 使通知分片及尚未取得交付权的事件失效
 */
- (void)invalidatePendingNotifications;

/**
 * @brief Invalidate pending notifications and drain the original consumer queue
 * @chinese 使待交付通知失效并排空原消费者队列
 *
 * @param completion
 * EN: Called once on the configured serial delivery queue after previously queued consumers return.
 * CN: 原先排队的消费者返回后，在配置的串行交付队列回调一次。
 *
 * @discussion
 * [EN]: First stop admission for the consumer being drained, by removing the listener or closing its
 *       separately scoped input gate. Persistent listeners may accept later generations after this barrier.
 * [CN]: 调用前须先停止原消费者的准入，可移除监听器或关闭其独立输入门禁。
 *       长期监听可在此屏障之后接纳后续代次的数据。
 */
- (void)drainNotificationDeliveryWithCompletion:(dispatch_block_t)completion;

/**
 * @brief Notification delivery generation captured while selecting a listener
 * @chinese 选择监听器时捕获的通知交付代次
 *
 * @discussion
 * [EN]: Increases when pending fragments or deliveries are invalidated.
 * [CN]: 分片或等待交付事件失效时递增。
 *
 * @note
 * [EN]: Read atomically with the listener selection; this value is local and never sent on the wire.
 * [CN]: 应与监听器选择一起原子读取，此值只在本地使用，不发送给设备。
 */
@property (nonatomic, assign, readonly) NSUInteger notificationDeliveryGeneration;

/**
 * @brief Accept a packet only for the originally selected listener generation
 * @chinese 仅按原选择的监听代次接纳数据包
 *
 * @param parsedPacket
 * EN: Immutable parsed packet carrying its original physical source.
 * CN: 携带原物理来源的不可变解析包。
 *
 * @param generation
 * EN: Generation captured when selecting this listener.
 * CN: 选择该监听器时捕获的代次。
 */
- (void)handleReceivedNotify:(TSParsedPacket *)parsedPacket deliveryGeneration:(NSUInteger)generation;

/**
 * @brief Validate the frozen owner target before a transport side effect
 * @chinese 在传输副作用发生前校验冻结目标归属
 *
 * @return
 * EN: YES for an uncancelled current owned target, or for the legacy path without ownership.
 * CN: 未取消且仍有效的具归属目标返回 YES，无归属的原路径也返回 YES。
 */
- (BOOL)isTransportOwnershipValid;

/**
 * @brief Bind the original admitted lease before scheduling an owned request
 * @chinese 在调度具归属请求前绑定原准入租约
 *
 * @param validator
 * EN: Nonblocking predicate for a captured lease, owner and generation; never resolve the current lease.
 * CN: 校验捕获的租约、所有者及代次的非阻塞判断，不可重新读取当前租约。
 *
 * @return
 * EN: YES when bound once before execution; NO for repeated binding or an unowned request.
 * CN: 执行前首次绑定返回 YES，重复绑定或无归属请求返回 NO。
 */
- (BOOL)bindTransportAdmissionValidator:(BOOL (^)(void))validator;

/**
 * @brief Deliver a request terminal callback once
 * @chinese 仅交付一次请求终态回调
 *
 * @param error
 * EN: Failure or cancellation error; nil indicates success.
 * CN: 失败或取消错误，为 nil 表示成功。
 *
 * @param status
 * EN: Final success, failure or cancellation status.
 * CN: 最终成功、失败或取消状态。
 */
- (void)deliverTerminalWithError:(nullable NSError *)error status:(TSRequestStatus)status;

/**
 * @brief Wait for the original active write attempt to stop submitting fragments
 * @chinese 等待原活动写尝试停止提交分片
 *
 * @param completion
 * EN: Invoked once after the write queue barrier; owned requests do not depend on the main queue.
 * CN: 写队列屏障后回调一次，具归属请求不依赖主队列。
 *
 * @discussion
 * [EN]: This is a local transport barrier and does not prove that the device has cleared its state.
 * [CN]: 此方法仅提供本地传输屏障，不能证明设备状态已清场。
 */
- (void)drainTransportWithCompletion:(nullable dispatch_block_t)completion;

// ==================== 基础标识信息 ====================

/**
 * @brief 请求唯一标识，自动生成UUID
 * @chinese 每个请求唯一标识，自动生成
 *
 * @discussion
 * EN: Unique identifier for each request, automatically generated as a UUID string.
 * CN: 每个请求的唯一标识，自动生成UUID字符串。
 */
@property (nonatomic, copy) NSString *requestID;

/**
 * @brief 请求消息类型
 * @chinese 区分本对象是请求、响应还是通知
 *
 * @discussion
 * EN: Type of the request message (request, response, notify).
 * CN: 请求消息类型（请求、响应、通知）。
 */
@property (nonatomic, assign) TSRequestType requestType;

/**
 * @brief 请求状态
 * @chinese 请求的当前状态（如：等待、进行中、完成、失败、已取消等）
 *
 * @discussion
 * EN: Current status of the request (pending, processing, completed, failed, cancelled, etc.).
 * CN: 请求的当前状态（等待、进行中、完成、失败、已取消等）。
 *
 * @note
 * EN: Retry logic is now managed by TSRequestManager, not by the request itself.
 * CN: 重试逻辑现在由 TSRequestManager 管理，而不是请求本身。
 */
@property (nonatomic, assign) TSRequestStatus status;

/**
 * @brief 请求优先级
 * @chinese 请求的优先级，数值越大优先级越高
 *
 * @discussion
 * EN: Priority of the request, higher value means higher priority.
 * CN: 请求的优先级，数值越大优先级越高。
 *
 * @note
 * EN: Used for scheduling requests in the manager.
 * CN: 用于管理器中请求的调度。
 */
@property (nonatomic, assign) TSRequestPriority priority;

/**
 * @brief 请求序列号
 * @chinese 每个请求的唯一序列号，自动递增
 *
 * @discussion
 * EN: Unique sequence number for each request, automatically incremented.
 * CN: 每个请求的唯一序列号，自动递增。
 *
 * @note
 * EN: This is used to match responses with their corresponding requests.
 * CN: 用于将响应与其对应的请求进行匹配。
 */
@property (nonatomic, assign) UInt16 sequenceId;

// ==================== 命令相关 ====================

/**
 * @brief 请求命令类型
 * @chinese 请求的主命令类型
 *
 * @discussion
 * EN: Main command type for the request.
 * CN: 请求的主命令类型。
 */
@property (nonatomic, assign) TSRequestCommand requestCommand;

/**
 * @brief 数据包分包模式
 * @chinese 控制数据包的分包策略
 *
 * @discussion
 * EN: Defines the packet fragmentation strategy for this request.
 *     - eTSPacketModeObject: Single object packet mode, payload contains only object data
 *     - eTSPacketModeList: List packet mode, payload contains fragmentation info + object data
 * CN: 定义此请求的数据包分包策略。
 *     - eTSPacketModeObject：对象分包模式，载荷只包含对象数据
 *     - eTSPacketModeList：列表分包模式，载荷包含分包信息 + 对象数据
 *
 * @note
 * EN: This property determines how the payload data will be wrapped and fragmented
 *     when the request is sent to the device.
 * CN: 此属性决定请求发送到设备时载荷数据如何包装和分包。
 */
@property (nonatomic, assign) TSPacketMode packetMode;

/**
 * @brief 请求Key
 * @chinese 具体的子命令或功能Key
 *
 * @discussion
 * EN: Sub-command or function key for the request.
 * CN: 请求的子命令或功能Key。
 */
@property (nonatomic, assign) UInt8 requestKey;

/**
 * @brief 是否等待响应
 * @chinese 标识该请求是否需要等待设备响应
 *
 * @discussion
 * EN: Indicates whether this request needs to wait for a device response.
 * CN: 标识该请求是否需要等待设备响应。
 *
 * @note
 * EN: If YES, the request will only complete after receiving a response or timing out.
 *     If NO, the request will complete immediately after sending.
 * CN: 如果为YES，请求将在收到响应或超时后才完成。
 *     如果为NO，请求将在发送完成后立即完成。
 */
@property (nonatomic, assign) BOOL waitForResponse;

/**
 * @brief Clear duplicate pending requests
 * @chinese 清除重复的待处理请求
 *
 * @discussion
 * EN: If YES, before adding this request to the queue, all pending requests with the same
 *     command and key will be removed from the queue first.
 *     If NO, this request will be added to the queue directly without affecting existing requests.
 * CN: 如果为YES，在将此请求加入队列之前，会先从队列中移除所有具有相同 command 和 key 的待处理请求。
 *     如果为NO，此请求将直接加入队列，不影响现有请求。
 *
 * @note
 * EN: Default is NO. Set to YES when you want the latest request to replace previous same commands.
 *     This is useful for settings that should only keep the latest value.
 * CN: 默认为NO。当您希望最新请求替换之前的相同命令时设置为YES。
 *     这对于只需保留最新值的设置非常有用。
 */
@property (nonatomic, assign) BOOL clearsDuplicate;

// ==================== 配置对象 ====================

/**
 * @brief 配置对象
 * @chinese 请求的配置对象，包含超时和重试等配置
 *
 * @discussion
 * EN: Configuration object for this request. If nil, uses [TSRequestOption defaultOption].
 * CN: 此请求的配置对象。如果为 nil，则使用 [TSRequestOption defaultOption]。
 *
 * @note
 * EN: Set this property to use custom configuration for this specific request.
 *     Leave it nil to use default configuration.
 *     You can use factory methods like [TSRequestOption otaOption] for common scenarios.
 * CN: 设置此属性可为该请求使用自定义配置。
 *     保留为 nil 则使用默认配置。
 *     可以使用工厂方法如 [TSRequestOption otaOption] 用于常见场景。
 */
@property (nonatomic, strong, nullable) TSRequestOption *option;

// ==================== 超时和重试配置 ====================

/**
 * @brief 请求总超时时间，单位秒
 * @chinese 请求总超时时间，单位为秒
 *
 * @discussion
 * EN: Total timeout interval for the request (including all retries), in seconds.
 *     This is the absolute timeout - if exceeded, request fails immediately.
 *     Timer starts when request begins execution (not when created).
 * CN: 请求的总超时时间（包括所有重试），单位为秒。
 *     这是绝对超时 - 超过后请求立即失败。
 *     计时从请求开始执行时开始（不是创建时）。
 *
 * @note
 * EN: Default is 30 seconds. This is enforced by requestTimeoutTimer (failsafe).
 * CN: 默认为 30 秒。由 requestTimeoutTimer 保证（兜底保护）。
 */
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

/**
 * @brief 响应超时时间，单位秒
 * @chinese 等待响应的超时时间，单位为秒
 *
 * @discussion
 * EN: Timeout for waiting device response after data is sent, in seconds.
 *     This is independent from total timeout.
 * CN: 数据发送完成后等待设备响应的超时时间，单位为秒。
 *     与总超时时间独立。
 *
 * @note
 * EN: Default is 10 seconds. This is enforced by responseTimer.
 * CN: 默认为 10 秒。由 responseTimer 保证。
 */
@property (nonatomic, assign) NSTimeInterval responseTimeoutInterval;

/**
 * @brief 重试间隔时间
 * @chinese 重试之间的等待时间，单位秒
 *
 * @discussion
 * EN: Wait time between retries, in seconds. If not set, reads from option.
 * CN: 重试之间的等待时间，单位秒。如果未设置，从 option 读取。
 *
 * @note
 * EN: Default value is read from option.defaultRequestRetryInterval (typically 0.5s).
 * CN: 默认值从 option.defaultRequestRetryInterval 读取（通常为0.5秒）。
 */
@property (nonatomic, assign) NSTimeInterval retryInterval;

/**
 * @brief 最大重试次数
 * @chinese 请求失败时的最大重试次数
 *
 * @discussion
 * EN: Maximum retry count when request fails. If not set, reads from option.
 * CN: 请求失败时的最大重试次数。如果未设置，从 option 读取。
 *
 * @note
 * EN: Default value is read from option.defaultRequestRetryCount (typically 2).
 * CN: 默认值从 option.defaultRequestRetryCount 读取（通常为2）。
 */
@property (nonatomic, assign) NSUInteger maxRetryCount;

// ==================== 时间记录 ====================

/**
 * @brief 请求开始执行时间
 * @chinese 记录请求开始执行的时间
 *
 * @discussion
 * EN: The time when the request started execution (not when created).
 *     Used for timeout calculation. Set once on first execution, not reset on retry.
 * CN: 请求开始执行的时间（不是创建时间）。
 *     用于超时计算。在首次执行时设置一次，重试时不重置。
 *
 * @note
 * EN: This ensures total timeout includes all retry attempts.
 * CN: 这确保总超时时间包含所有重试尝试。
 */
@property (nonatomic, strong) NSDate *startTime;

// ==================== 数据相关 ====================

/**
 * @brief 原始负载数组
 * @chinese 待发送的原始负载数据集合
 *
 * @discussion
 * [EN]: If array.count == 1 → single-payload mode; if > 1 → multi-payload mode.
 * [CN]: 当数组元素为1时表示单负载模式；大于1时表示多负载模式。
 */
@property (nonatomic, strong) NSArray<NSData *> *allPayloads;

/**
 * @brief 接收到的分包数据缓存
 * @chinese 用于存储接收到的分包数据，等待完整数据拼接
 */
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, NSData *> *receivedPacketCache;

/**
 * @brief 接收到的响应数据
 * @chinese 存储已接收的响应数据数组
 */
@property (nonatomic, strong, nullable) NSMutableArray<NSData *> *receivedResponseDatas;

// ==================== 回调和代理 ====================

/**
 * @brief 请求代理
 * @chinese 用于接收发送成功/失败等委托事件
 */
@property (nonatomic, weak) id<TSCommandRequestDelegate> delegate;

/**
 * @brief 进度回调
 * @chinese 发送过程中分包进度的回调
 */
@property (nonatomic, copy) TSRequestProgressBlock requestProgressBlock;

/**
 * @brief 状态变更回调
 * @chinese 请求生命周期状态变化的回调
 */
@property (nonatomic, copy) TSRequestStateChangedBlock requestStateChangedBlock;

/**
 * @brief 完成回调（数组）
 * @chinese 当请求完成时返回对象数组（分包/多指令）
 */
@property (nonatomic, copy) TSRequestListCompletionBlock requestListCompletionBlock;

/**
 * @brief Optional source-aware notification callback
 * @chinese 可选的带来源通知回调
 *
 * @discussion
 * [EN]: Frozen with the payload before queueing. When set, notification delivery uses this callback
 *       instead of requestListCompletionBlock; request terminal delivery is unchanged.
 * [CN]: 与载荷一起在入队前冻结。设置后通知使用此回调替代 requestListCompletionBlock，
 *       请求终态交付规则不变。
 *
 * @note
 * [EN]: Defaults to nil. Uses callbackQueue or main; retain the original packet across later dispatches.
 * [CN]: 默认为 nil；使用 callbackQueue 或主队列，后续异步转发须保留原包。
 */
@property (nonatomic, copy, nullable) TSRequestNotificationCompletionBlock notificationCompletionBlock;

/**
 * @brief Callback invoked once immediately before the request starts
 * @chinese 请求首次开始执行前调用一次的回调
 *
 * @discussion
 * [EN]: The sequence ID is available when this callback runs. The manager clears
 *       the block after invocation so retries cannot repeat preparation work.
 * [CN]: 此回调执行时序列号已经可用。管理器执行后会清空该回调，
 *       避免重试时重复执行准备工作。
 */
@property (nonatomic, copy, nullable) TSRequestWillStartBlock requestWillStartBlock;

/**
 * @brief Callback invoked when the request is cancelled by the manager
 * @chinese 请求被管理器取消时调用的回调
 *
 * @discussion
 * [EN]: This callback does not change the behavior of the normal completion callback.
 * [CN]: 该回调不会改变普通完成回调的既有行为。
 */
@property (nonatomic, copy, nullable) TSRequestCancellationBlock requestCancellationBlock;


/**
 * @brief 初始化请求对象（数组回调）
 * @chinese 创建支持多响应数据（数组）回调的请求对象
 *
 * @param command
 *        EN: Main command code to execute
 *        CN: 主命令类型
 * @param key
 *        EN: Sub-command key
 *        CN: 子命令Key
 * @param packetMode
 *        EN: Packet fragmentation mode for this request
 *        CN: 此请求的数据包分包模式
 * @param allPayloads
 *        EN: Payload list to send
 *        CN: 要发送的负载数组
 * @param option
 *        EN: Configuration option for this request. If nil, uses [TSRequestOption defaultOption]
 *        CN: 此请求的配置选项。如果为 nil，则使用 [TSRequestOption defaultOption]
 * @param progress
 *        EN: Progress callback (0.0~1.0)
 *        CN: 进度回调（0.0~1.0）
 * @param stateChanged
 *        EN: State change callback
 *        CN: 状态变化回调
 * @param completion
 *        EN: Completion callback returning array objects
 *        CN: 完成回调，返回对象数组
 */
- (instancetype)initRequestWithCommand:(TSRequestCommand)command
                            requestKey:(UInt8)key
                            packetMode:(TSPacketMode)packetMode
                           allPayloads:(NSArray<NSData *> *_Nullable)allPayloads
                                option:(TSRequestOption *_Nullable)option
                              progress:(TSRequestProgressBlock _Nullable)progress
                          stateChanged:(TSRequestStateChangedBlock _Nullable)stateChanged
                            completion:(TSRequestListCompletionBlock _Nullable)completion NS_DESIGNATED_INITIALIZER;


// 禁用init、new、copy、mutableCopy等方法
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

/**
 * @brief 取消请求
 * @chinese 主动取消该请求
 */
- (void)cancel;

/**
 * @brief 重置请求状态
 * @chinese 重置请求对象的所有状态和数据
 */
- (void)reset;

/**
 * @brief 开始执行请求
 * @chinese 开始执行请求
 *
 * @discussion
 * EN: Executes the request. Retry logic is handled by TSRequestManager.
 * CN: 执行请求。重试逻辑由 TSRequestManager 处理。
 */
- (void)startExecution;

/**
 * @brief 处理收到的响应数据
 * @chinese 当从设备收到响应数据时调用此方法
 *
 * @param parsedPacket 响应数据
 *        EN: Response data received from device
 *        CN: 从设备收到的响应数据
 */
- (void)handleReceivedResponse:(TSParsedPacket *)parsedPacket;

/**
 * @brief 处理通知的响应数据
 * @chinese 当从设备收到通知数据时调用此方法
 *
 * @param parsedPacket 通知数据
 *        EN: Notify data received from device
 *        CN: 从设备收到的通知数据
 */
- (void)handleReceivedNotify:(TSParsedPacket *)parsedPacket;

/**
 * @brief 处理收到的错误信息
 * @chinese 当从设备收到错误响应时调用此方法
 *
 * @param error 错误信息
 *        EN: Error information received from device
 *        CN: 从设备收到的错误信息
 */
- (void)handleReceivedError:(NSError *)error;

/**
 * @brief 停止发送数据
 * @chinese 停止当前请求的数据发送流程
 */
- (void)stopSending;

/**
 * @brief 停止所有定时器
 * @chinese 停止请求的所有定时器（requestTimeoutTimer + responseTimeoutTimer）
 *
 * @discussion
 * EN: Stops all timers (requestTimeoutTimer + responseTimeoutTimer).
 *     Typically called by TSRequestManager when the request is finally done.
 * CN: 停止所有定时器（requestTimeoutTimer + responseTimeoutTimer）。
 *     通常由 TSRequestManager 在请求最终完成时调用。
 *
 * @note
 * EN: This method is public to allow TSRequestManager to manage request lifecycle.
 * CN: 此方法公开以允许 TSRequestManager 管理请求生命周期。
 */
- (void)stopAllTimers;

/**
 * @brief 判断两个请求是否相等
 * @chinese 根据命令类型、子命令、分包模式和数据内容判断
 *
 * @param request 要比较的请求对象
 *        EN: Request object to compare with
 *        CN: 要比较的请求对象
 * @return 是否相等
 *         EN: YES if requests are equal, NO otherwise
 *         CN: 如果请求相等返回YES，否则返回NO
 *
 * @discussion
 * EN: Two requests are considered equal if they have the same command, key,
 *     packetMode, and payload data content.
 * CN: 如果两个请求具有相同的命令、键、分包模式和载荷数据内容，则认为它们相等。
 */
- (BOOL)isEqual:(TSCommandRequest *)request;

    
- (void)logRequestFailedWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
