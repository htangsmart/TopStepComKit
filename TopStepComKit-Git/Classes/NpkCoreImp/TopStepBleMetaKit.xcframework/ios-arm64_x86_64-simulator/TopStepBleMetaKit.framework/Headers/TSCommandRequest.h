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
