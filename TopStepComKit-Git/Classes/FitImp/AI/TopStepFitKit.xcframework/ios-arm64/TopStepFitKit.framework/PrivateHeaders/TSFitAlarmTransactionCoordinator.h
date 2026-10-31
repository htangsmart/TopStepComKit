#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const TSFitAlarmTransactionErrorDomain;

/**
 * @brief Alarm transaction failures
 * @chinese 闹钟事务错误
 */
typedef NS_ENUM(NSInteger, TSFitAlarmTransactionErrorCode) {
    TSFitAlarmTransactionErrorCodeInvalidated = 7601,
    TSFitAlarmTransactionErrorCodeTimeout,
    TSFitAlarmTransactionErrorCodeUncertain,
    TSFitAlarmTransactionErrorCodeUnavailable,
    TSFitAlarmTransactionErrorCodeInvalidResponse,
};

/**
 * @brief Device list participating in the same transaction
 * @chinese 参加同一设备事务的列表类型
 */
typedef NS_ENUM(NSInteger, TSFitAlarmListKind) {
    TSFitAlarmListKindAlarms,
    TSFitAlarmListKindSchedules,
    TSFitAlarmListKindSchedulesV2,
};

/**
 * @brief Raw device transport, injectable for deterministic interleaving tests
 * @chinese 可注入的原始设备传输，便于确定性交错测试
 */
@protocol TSFitAlarmTransport <NSObject>
/**
 * @brief Read one device list
 * @chinese 读取设备列表
 * @param kind
 * EN: Exact list type.
 * CN: 明确的列表类型。
 * @param completion
 * EN: Vendor outcome, possibly synchronous or on another queue.
 * CN: 可同步或在其他队列返回的厂商结果。
 */
- (void)readListOfKind:(TSFitAlarmListKind)kind
           completion:(void (^)(BOOL success, NSArray *_Nullable values, NSError *_Nullable error))completion;
/**
 * @brief Replace one device list
 * @chinese 替换设备列表
 * @param values
 * EN: Complete replacement list.
 * CN: 完整替换列表。
 * @param kind
 * EN: Exact list type.
 * CN: 明确的列表类型。
 * @param completion
 * EN: Actual transport acknowledgement.
 * CN: 真实传输回执。
 */
- (void)writeList:(NSArray *)values kind:(TSFitAlarmListKind)kind
      completion:(void (^)(BOOL success, NSError *_Nullable error))completion;
@end

/**
 * @brief One device-bound asynchronous read/modify/write transaction
 * @chinese 绑定设备的异步读改写事务
 */
@interface TSFitAlarmTransaction : NSObject
/**
 * @brief Read without re-enqueueing the enclosing transaction
 * @chinese 在当前事务内读取，不重复入队
 * @param kind
 * EN: Device list type.
 * CN: 设备列表类型。
 * @param completion
 * EN: Main-thread, single-step result. Late callbacks are ignored.
 * CN: 主线程单次步骤结果，忽略迟到回调。
 */
- (void)readListOfKind:(TSFitAlarmListKind)kind
           completion:(void (^)(NSArray *_Nullable values, NSError *_Nullable error))completion;
/**
 * @brief Validate ownership and write within this transaction
 * @chinese 校验归属后在当前事务内写入
 * @param values
 * EN: Replacement list.
 * CN: 替换列表。
 * @param kind
 * EN: Device list type.
 * CN: 设备列表类型。
 * @param completion
 * EN: Main-thread actual transport result.
 * CN: 主线程真实传输结果。
 */
- (void)writeList:(NSArray *)values kind:(TSFitAlarmListKind)kind
      completion:(void (^)(BOOL success, NSError *_Nullable error))completion;
/**
 * @brief Finish and release the enclosing transaction exactly once
 * @chinese 单次结束并释放当前事务
 * @param value
 * EN: Optional business result.
 * CN: 可空的业务结果。
 * @param error
 * EN: Optional failure.
 * CN: 可空的错误。
 */
- (void)finishWithValue:(nullable id)value error:(nullable NSError *)error;
@end

/**
 * @brief Shared device transaction owner for App and AI alarm writers
 * @chinese App 与 AI 闹钟写入共用的设备事务所有者
 */
@interface TSFitAlarmTransactionCoordinator : NSObject
/**
 * @brief Process-wide owner used by production App and AI entry points
 * @chinese 生产 App 与 AI 入口共用的进程级所有者
 * @return
 * EN: Shared coordinator.
 * CN: 共享协调器。
 */
+ (instancetype)sharedInstance;
/**
 * @brief Construct with a transport and deterministic clock scheduling
 * @chinese 注入传输与确定性时钟调度
 * @param transport
 * EN: Raw transport.
 * CN: 原始传输。
 * @param identityProvider
 * EN: Thread-safe current device identity, nil while unavailable.
 * CN: 线程安全的当前设备身份，不可用时为 nil。
 * @param timeout
 * EN: Positive whole-transaction deadline in seconds.
 * CN: 正数，整个事务截止秒数。
 * @param scheduler
 * EN: Schedules a main-thread deadline without sleeping.
 * CN: 不阻塞地调度主线程截止回调。
 * @return
 * EN: Independent coordinator.
 * CN: 独立协调器。
 */
- (instancetype)initWithTransport:(id<TSFitAlarmTransport>)transport
                identityProvider:(NSString *_Nullable (^)(void))identityProvider
                         timeout:(NSTimeInterval)timeout
                       scheduler:(void (^)(NSTimeInterval delay, dispatch_block_t deadline))scheduler;
/**
 * @brief Serialize a complete operation against its receipt-time device
 * @chinese 按接收时的设备身份串行执行完整操作
 * @param operation
 * EN: Main-thread business steps. Use the supplied transaction for all I/O.
 * CN: 主线程业务步骤，全部读写使用传入事务。
 * @param completion
 * EN: One main-thread result, after releasing this logical operation.
 * CN: 释放本次逻辑操作后，主线程返回一次结果。
 */
- (void)enqueueOperation:(void (^)(TSFitAlarmTransaction *transaction))operation
             completion:(void (^)(id _Nullable value, NSError *_Nullable error))completion;
/**
 * @brief Invalidate queued and active work when the transport changes
 * @chinese 传输变化时使排队和活动操作失效
 */
- (void)invalidateTransport;
@end

NS_ASSUME_NONNULL_END
