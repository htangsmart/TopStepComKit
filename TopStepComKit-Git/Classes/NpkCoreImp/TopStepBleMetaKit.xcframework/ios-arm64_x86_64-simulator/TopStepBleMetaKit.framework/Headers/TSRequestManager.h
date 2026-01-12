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
 * @brief 取消指定请求
 * @chinese 根据requestID取消指定的请求
 *
 * @param requestID 要取消的请求ID
 *        EN: The ID of the request to be cancelled
 *        CN: 要取消的请求ID
 */
- (void)cancelRequestWithID:(NSString *_Nonnull)requestID;

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

