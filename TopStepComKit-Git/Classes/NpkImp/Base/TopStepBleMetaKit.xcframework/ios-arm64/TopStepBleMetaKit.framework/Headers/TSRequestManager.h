//
//  TSRequestManager.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/23.
//

#import "TSCommandBase.h"
#import "TSCommandRequest.h"
#import "TSPackageHandleInterface.h"

@class TSParsedPacket;
@class TSBleWriteContext;

/**
 * @brief Connection session invalidation callback
 * @chinese 连接会话失效回调
 *
 * @param error
 * EN: Error that caused the current connection session to become invalid.
 * CN: 导致当前连接会话失效的错误。
 */
typedef void(^TSRequestSessionInvalidationBlock)(NSError * _Nonnull error);

/**
 * @brief 请求管理器
 * @chinese 负责请求队列管理、调度执行和重试策略
 *
 * @discussion
 * EN: Manages request queue, scheduling, and retry logic. Requests handle execution and timeout,
 *     while Manager handles retry decisions and queue management.
 * CN: 管理请求队列、调度和重试逻辑。Request 负责执行和超时，Manager 负责重试决策和队列管理。
 */
@interface TSRequestManager : TSCommandBase<TSPackageHandleInterface>

/**
 * @brief 是否正在处理请求
 * @chinese 标识管理器是否正在处理请求
 *
 * @discussion
 * EN: Indicates whether the manager is currently processing a request.
 * CN: 标识管理器是否正在处理请求。
 */
@property (nonatomic, assign, readonly) BOOL isProcessing;

/**
 * @brief 获取单例实例
 * @chinese 获取请求管理器的单例实例
 * @return 管理器单例实例
 */
+ (instancetype _Nonnull )sharedManager;


/**
 * @brief 添加请求到队列
 * @chinese 将请求添加到待处理队列，会根据优先级自动排序
 *
 * @param request 要添加的请求对象
 *        EN: The request object to be added
 *        CN: 要添加的请求对象
 *
 * @discussion
 *        EN: The manager only handles queue management and scheduling. Each request manages its own lifecycle including retry logic.
 *        CN: 管理器只处理队列管理和调度。每个请求管理自己的生命周期，包括重试逻辑。
 */
- (void)executeRequest:(TSCommandRequest *_Nonnull)request;

/**
 * @brief Atomically admit a real-time owner against requests and file transfers
 * @chinese 对请求及文件传输原子准入实时所有者
 *
 * @param ownerIdentifier
 * EN: Unique logical session identifier that must never be reused.
 * CN: 不可复用的唯一逻辑会话标识。
 *
 * @param context
 * EN: Immutable current physical target; the operation identifier is not a session identifier.
 * CN: 当前物理目标的不可变上下文，操作标识不作为会话标识。
 *
 * @param completion
 * EN: Called once on the manager queue with a lease or an error; do not synchronously wait for other queues.
 * CN: 在管理队列回调一次，返回租约或错误；不可同步等待其他队列。
 *
 * @discussion
 * [EN]: Admission conservatively rejects unrelated current or queued requests. While active, only
 *       requests configured with the same owner and physical target are accepted.
 * [CN]: 准入保守拒绝无关的当前及排队请求；激活期间仅接纳同所有者及同物理目标的请求。
 */
- (void)beginRealtimeForOwner:(NSString *_Nonnull)ownerIdentifier
                     context:(TSBleWriteContext *_Nonnull)context
                  completion:(void (^_Nonnull)(NSUUID *_Nullable lease, NSError *_Nullable error))completion;

/**
 * @brief Atomically hand the current realtime owner to a PB or TP file operation
 * @chinese 将当前实时所有者原子交给 PB 或 TP 文件事务
 * @param ownerIdentifier EN: Original realtime owner. CN: 原实时所有者。
 * @param upload EN: YES for TP, NO for PB. CN: YES 表示 TP，NO 表示 PB。
 * @param completion EN: Called with the reserved file identity after owned writes drain.
 * CN: 原所有者写入排空后返回文件登记标识。
 */
- (void)convertRealtimeOwner:(NSString *_Nonnull)ownerIdentifier
                    toUpload:(BOOL)upload
                   completion:(void (^_Nonnull)(NSUUID *_Nullable fileOperation,
                                                NSError *_Nullable error))completion;

/**
 * @brief Atomically reclaim a realtime owner from its reserved file operation
 * @chinese 从已完成的文件事务原子回收实时所有者
 * @param ownerIdentifier
 * EN: Original realtime owner. CN: 原实时所有者。
 * @param fileOperation
 * EN: Reserved file operation returned by conversion. CN: 转换返回的文件事务。
 * @param context
 * EN: Original physical target and result admission validator.
 * CN: 原物理目标及结果阶段准入校验。
 * @param completion
 * EN: Called with a new realtime lease or an error.
 * CN: 返回新的实时租约或错误。
 */
- (void)reclaimRealtimeOwner:(NSString *_Nonnull)ownerIdentifier
           fromFileOperation:(NSUUID *_Nonnull)fileOperation
                     context:(TSBleWriteContext *_Nonnull)context
                  completion:(void (^_Nonnull)(NSUUID *_Nullable lease,
                                               NSError *_Nullable error))completion;

/**
 * @brief Close owner admission and drain its original write attempts
 * @chinese 封闭所有者准入并排空其原写尝试
 *
 * @param ownerIdentifier
 * EN: Original admitted owner; cancelling a different owner does not affect current work.
 * CN: 原准入所有者，取消其他所有者不会影响当前任务。
 *
 * @param clean
 * EN: YES only with a verified device cleanup barrier; local drain alone requires NO.
 * CN: 仅有已核验的设备清场屏障时传 YES，只有本地排空时必须传 NO。
 *
 * @param completion
 * EN: Called once on the manager queue after all captured write operations stop submitting fragments.
 * CN: 捕获的全部写操作停止提交分片后，在管理队列回调一次。
 *
 * @discussion
 * [EN]: NO leaves the file guard dirty until the connection generation changes. Notification
 *       listeners have an independent consumer drain and must be removed and drained by their owner.
 * [CN]: NO 会使文件保护器保持脏状态，直到连接代次变化；通知监听需要所有者另行移除并排空消费者。
 */
- (void)cancelRequestsForOwner:(NSString *_Nonnull)ownerIdentifier
        deviceStateKnownClean:(BOOL)clean
                   completion:(nullable dispatch_block_t)completion;

/**
 * @brief 取消指定请求
 * @chinese 根据requestID取消指定的请求
 *
 * @param requestID 要取消的请求ID
 *        EN: The ID of the request to be cancelled
 *        CN: 要取消的请求ID
 */
- (void)cancelRequestWithID:(NSString *_Nonnull)requestID;

/**
 * @brief Cancel one tracked owned request and await its original write barrier
 * @chinese 取消单个仍受调度的具归属请求并等待其原写屏障
 *
 * @param requestID
 * EN: Original request identity; an untracked request is a no-op.
 * CN: 原请求标识；找不到受调度请求时不执行取消。
 *
 * @param completion
 * EN: Called once on the manager queue, after the write barrier when a tracked owned request exists.
 * CN: 在管理队列回调一次；存在受调度的具归属请求时，等待其写屏障。
 * @discussion
 * EN: Owner cleanup may remove indexing before transport drains. Callers retaining the original request
 *     must also await its drainTransportWithCompletion when that distinction matters. Legacy requests are unchanged.
 * CN: 所有者清理可能先移除索引再排空传输；持有原请求且需要区分此状态的调用方，
 *     还须等待该原请求的drainTransportWithCompletion。无归属的旧请求保持原状。
 */
- (void)cancelOwnedRequestWithID:(NSString *_Nonnull)requestID
                    completion:(nullable dispatch_block_t)completion;

/**
 * @brief 取消所有请求
 * @chinese 取消队列中所有待处理和正在处理的请求
 */
- (void)cancelAllRequests;

/**
 * @brief 获取指定请求
 * @chinese 根据requestID获取请求对象
 *
 * @param requestID 请求ID
 *        EN: The request ID
 *        CN: 请求ID
 *
 * @return 请求对象，如果不存在返回nil
 *         EN: The request object, nil if not found
 *         CN: 请求对象，如果不存在返回nil
 */
- (nullable TSCommandRequest *)requestWithID:(NSString *_Nonnull)requestID;

/**
 * @brief 通过序列号查找请求
 * @chinese 根据序列号查找对应的请求对象
 *
 * @param sequenceId 序列号
 *        EN: The sequence ID
 *        CN: 序列号
 *
 * @return 请求对象，如果不存在返回nil
 *         EN: The request object, nil if not found
 *         CN: 请求对象，如果不存在返回nil
 */
- (nullable TSCommandRequest *)requestWithSequenceId:(UInt16)sequenceId;

/**
 * @brief 暂停请求处理
 * @chinese 暂停处理新的请求，当前请求继续执行
 */
- (void)pause;

/**
 * @brief 恢复请求处理
 * @chinese 恢复处理队列中的请求
 */
- (void)resume;

/**
 * @brief 清空请求队列
 * @chinese 清空所有待处理的请求（不包括当前正在处理的请求）
 */
- (void)clearQueue;

/**
 * @brief 清理所有请求状态
 * @chinese 清理所有请求状态，包括当前正在处理的请求和队列中的所有请求
 *
 * @discussion
 * [EN]: Clears all request states including the current request and all queued requests.
 *       Used when disconnecting to ensure a clean state for reconnection.
 * [CN]: 清理所有请求状态，包括当前正在处理的请求和队列中的所有请求。
 *       用于断开连接时确保状态干净，以便重新连接。
 *
 * @note
 * [EN]: This method should be called when disconnecting to ensure a fresh start on reconnection.
 * [CN]: 断开连接时应调用此方法，以确保重新连接时有一个全新的开始。
 */
- (void)clearAllRequests;

/**
 * @brief Clear requests and wait for captured owned writes to drain
 * @chinese 清理请求并等待捕获的具归属写操作排空
 *
 * @param completion
 * EN: Runs once on the main queue after local owned-write barriers and legacy main-queue callbacks.
 * CN: 在本地具归属写屏障及原主队列请求回调之后，在主队列执行一次。
 *
 * @discussion
 * [EN]: Legacy default-main callbacks preserve FIFO before completion. An opt-in owned request's
 *       custom callback queue is independent and is not waited upon. Persistent notification consumers
 *       require their separate remove-listener and consumer-drain barrier.
 * [CN]: 原默认主队列回调仍按 FIFO 先于 completion 执行；具归属请求选择的自定义回调队列
 *       独立交付，不等待该队列。长期通知消费者须另行移除监听器并等待消费者排空屏障。
 */
- (void)clearAllRequestsWithCompletion:(nullable dispatch_block_t)completion;

/**
 * @brief Clear requests only if ownership is still valid when the manager queue executes
 * @chinese 仅在管理队列实际执行时归属仍有效才清理请求
 *
 * @param validator
 * EN: Optional nonblocking predicate evaluated on the manager queue immediately before clearing.
 * CN: 可选非阻塞判断，在管理队列清理前立即执行。
 *
 * @param completion
 * EN: Called once on the main queue after clearing or skipping an invalid owner.
 * CN: 完成清理或跳过失效所有者后，在主队列回调一次。
 */
- (void)clearAllRequestsWithValidator:(nullable BOOL (^)(void))validator
                         completion:(nullable dispatch_block_t)completion;

/**
 * @brief Add a persistent connection session invalidation handler
 * @chinese 添加持续生效的连接会话失效处理器
 *
 * @param identifier
 * EN: Unique identifier used to replace or remove the handler.
 * CN: 用于替换或移除处理器的唯一标识。
 * @param handler
 * EN: Handler invoked synchronously before clear-all completion callbacks are enqueued.
 * CN: 在清理全部请求的完成回调入队前同步调用的处理器。
 */
- (void)addSessionInvalidationHandlerWithIdentifier:(NSString * _Nonnull)identifier
                                            handler:(TSRequestSessionInvalidationBlock _Nonnull)handler;

/**
 * @brief Remove a connection session invalidation handler
 * @chinese 移除连接会话失效处理器
 *
 * @param identifier
 * EN: Identifier supplied when the handler was added.
 * CN: 添加处理器时使用的标识。
 */
- (void)removeSessionInvalidationHandlerWithIdentifier:(NSString * _Nonnull)identifier;

/**
 * @brief 获取队列中请求数量
 * @chinese 获取当前队列中待处理请求的数量
 * @return 队列中请求数量
 */
- (NSUInteger)queueCount;


#pragma mark - 序列号管理

/**
 * @brief Generate next sequence ID
 * @chinese 生成下一个可用的序列号
 *
 * @return 
 * EN: Next sequence ID (1-65535, cycling)
 * CN: 下一个序列号（1-65535，循环使用）
 *
 * @discussion
 * EN: Thread-safe method using os_unfair_lock for high performance.
 *     Sequence IDs cycle from 1 to 65535, skipping 0 (invalid).
 * CN: 使用 os_unfair_lock 的线程安全方法，保证高性能。
 *     序列号在 1 到 65535 之间循环，跳过 0（无效值）。
 *
 * @note
 * EN: This is an instance method for better encapsulation and testability.
 * CN: 这是一个实例方法，便于封装和测试。
 */
- (UInt16)generateNextSequenceId;

/**
 * @brief Reset sequence ID counter
 * @chinese 重置序列号计数器到初始值
 *
 * @discussion
 * EN: Resets the sequence ID counter to initial value (0).
 *     Next call to generateNextSequenceId will return 1.
 *     Thread-safe using os_unfair_lock for high performance.
 * CN: 重置序列号计数器到初始值（0）。
 *     下次调用 generateNextSequenceId 将返回 1。
 *     使用 os_unfair_lock 保证线程安全和高性能。
 *
 * @note
 * EN: Use after device binding to start a new sequence for the binding session.
 * CN: 在设备绑定后使用，为绑定会话开始新的序列。
 */
- (void)resetSequenceIdCounter;


@end
