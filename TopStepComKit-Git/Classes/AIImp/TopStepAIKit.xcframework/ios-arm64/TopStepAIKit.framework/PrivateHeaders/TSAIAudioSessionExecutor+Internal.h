//
//  TSAIAudioSessionExecutor+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/17.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioSessionArbiter+Internal.h"
#import "TSAISystemAudioDriver+Internal.h"

@class TSAIAudioSessionLeaseRegistry;

NS_ASSUME_NONNULL_BEGIN

/// begin 因执行器卡死而快速失败时的 userInfo 键（值为 @YES）
FOUNDATION_EXPORT NSString * const TSAIAudioSessionExecutorStalledKey;

/// 回退开关的 NSUserDefaults 键：YES 时手机麦驱动完全走旧的内联路径，不经执行器（进程内只读一次）
FOUNDATION_EXPORT NSString * const TSAISystemAudioSyncStartFallbackKey;

/**
 * @brief Whether the synchronous fallback switch is on
 * @chinese 回退开关是否打开（NSUserDefaults `TSAISystemAudioSyncStartFallback`，进程启动后首次使用时读一次）
 */
FOUNDATION_EXPORT BOOL TSAISystemAudioSyncStartFallbackEnabled(void);

/** @brief Whether the caller runs on the audio session executor @chinese 当前是否在音频会话执行器上 */
FOUNDATION_EXPORT BOOL TSAIIsOnAudioSessionExecutor(void);

/// DEBUG 断言：执行器所有的状态只在执行器上读写（`q_` 方法）
#if DEBUG
#define TSAIAssertOnAudioExecutor() NSCAssert(TSAIIsOnAudioSessionExecutor(), @"Must run on the audio session executor")
#else
#define TSAIAssertOnAudioExecutor() do { } while (0)
#endif

/**
 * @brief Process-wide serial executor of audio session writes
 * @chinese 进程级音频会话执行器（串行队列）
 *
 * @discussion
 * EN: SDK writes to AVAudioSession and start / stop of the vendor audio engines run only here.
 *     There is no synchronous interface: the main thread never waits for the executor, directly
 *     or through another queue. Blocks never wait for the main thread either.
 *     - Each block logs its label, queue wait, run time and queue depth when slow; a block running
 *       longer than 1.5 s logs a warning, longer than 8 s marks the executor stalled (new begins
 *       fail fast with TSAIErrorCodeAudioRouteUnavailable + executorStalled) until it returns.
 *       The executor is never replaced: the stuck block would resume and break the total order.
 *     - Teardown blocks enqueued while the App is in the background run inside a background task.
 * CN: SDK 对 AVAudioSession 的写操作、对厂商音频引擎的启停只在这里执行。不提供同步接口：主线程
 *     既不直接也不经其他队列间接等待执行器；执行器上的块也不等待主线程。
 *     - 慢块记录 label、排队时长、执行时长与队列深度；单块超过 1.5 s 打 WARNING，超过 8 s 判定为
 *       卡死：之后新的 begin 立即失败（TSAIErrorCodeAudioRouteUnavailable，userInfo 带 executorStalled），
 *       卡住的块返回后自动解除。不替换执行器：被卡住的块迟早会恢复并继续写状态，换执行器会破坏全序。
 *     - App 在后台时入队的拆除块用 backgroundTask 包住，避免会话停在激活状态被挂起。
 */
@interface TSAIAudioSessionExecutor : NSObject

/** @brief Shared executor @chinese 进程级共享执行器 */
+ (instancetype)sharedExecutor;

/** @brief Lease registry across all phone-mic driver instances @chinese 跨驱动实例的租约登记 */
@property (nonatomic, strong, readonly) TSAIAudioSessionLeaseRegistry *registry;

/** @brief Whether a block has run for more than 8 s @chinese 是否有块执行超过 8 秒（卡死） */
@property (atomic, assign, readonly, getter=isStalled) BOOL stalled;

/** @brief The serial queue (shared queue-specific key; earbuds engine uses it directly in P1b) @chinese 串行队列（共享 queue-specific key） */
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

/** @brief Whether the caller runs on the executor @chinese 当前是否在执行器上 */
- (BOOL)isCurrent;

/**
 * @brief Enqueue a block (FIFO) and return at once
 * @chinese 入队一个块（FIFO）并立即返回
 */
- (void)performAsync:(dispatch_block_t)block label:(NSString *)label;

/**
 * @brief Like performAsync but only logs when slow (high-frequency work such as playback appends)
 * @chinese 同 performAsync，但只在慢时记日志（播放追加等高频操作）
 */
- (void)performQuietAsync:(dispatch_block_t)block label:(NSString *)label;

/**
 * @brief Run inline when already on the executor, otherwise enqueue
 * @chinese 已在执行器上时内联执行，否则入队
 */
- (void)performInlineOrAsync:(dispatch_block_t)block label:(NSString *)label;

/**
 * @brief Enqueue a block after a delay (timers of the drivers)
 * @chinese 延时入队（驱动的定时器：采音重建、静默期、终态超时）
 */
- (void)performAfter:(NSTimeInterval)delay block:(dispatch_block_t)block label:(NSString *)label;

/**
 * @brief Enqueue a teardown block; wrapped in a background task while the App is in the background
 * @chinese 入队拆除块；App 在后台时用 backgroundTask 包住
 */
- (void)performTeardownAsync:(dispatch_block_t)block label:(NSString *)label;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief One start of a phone-mic system audio driver, registered in the executor registry
 * @chinese 手机麦系统音频驱动的一次启动，登记在执行器的租约登记里
 *
 * @discussion
 * EN: Invalidation is atomic and may happen on any thread. Whether a result was delivered and
 *     the delivery itself happen on the main queue: the first block to run there wins, and a
 *     success that wins while the lease is already invalid is delivered as the terminal error.
 *     Invalidation releases the handlers (breaking driver → lease → block → driver cycles).
 * CN: 作废是原子的，可在任何线程发生。「是否已投递」的判定和投递本身都在主线程：主线程上先执行的块
 *     胜出；胜出的是成功块而此时租约已作废时，改投终态错误。作废时释放所持回调，断开
 *     driver → 租约 → 闭包 → driver 的循环。子类实现播放 / 打断 / 停止。
 */
@interface TSAIAudioSessionLease : NSObject <TSAISystemAudioLease>

/** @brief Sequence in the registry @chinese 执行器登记中的序号 */
@property (atomic, assign, readonly) uint64_t generation;

/** @brief Owner: feature + route session @chinese 使用方：功能名 + 路由会话标识 */
@property (nonatomic, copy, readonly) NSString *owner;

/** @brief Priority @chinese 优先级 */
@property (nonatomic, assign, readonly) TSAIAudioSessionClaimPriority priority;

/** @brief Whether the route needs input (failure scope) @chinese 路由是否需要输入（决定失败范围） */
@property (nonatomic, assign, readonly) BOOL needsInput;

/** @brief Terminal error once invalid (Cancelled after stop) @chinese 作废原因（stop 之后为 Cancelled） */
@property (atomic, strong, readonly, nullable) NSError *terminalError;

/** @brief Whether the executor finished the start block @chinese 执行器上的启动是否已结束 */
@property (atomic, assign, readonly, getter=isStartFinished) BOOL startFinished;

/** @brief Captured PCM handler (audio thread); nil once invalid @chinese 采音回调（音频线程）；作废后为 nil */
@property (atomic, copy, readonly, nullable) void (^pcmHandler)(NSData *pcmData);

/** @brief Create an unregistered lease @chinese 创建尚未登记的租约 */
- (instancetype)initWithOwner:(NSString *)owner
                     priority:(TSAIAudioSessionClaimPriority)priority
                   needsInput:(BOOL)needsInput NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/** @brief Store the caller's handlers before registration @chinese 登记前保存调用方的回调 */
- (void)setPCMHandler:(nullable void (^)(NSData *pcmData))pcmHandler
            inputLive:(nullable dispatch_block_t)inputLive
         errorHandler:(nullable void (^)(NSError *error))errorHandler
           completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Deliver the start result on the main queue (once; re-checks active there)
 * @chinese 主线程投递启动结果：只一次，投递时复查有效性
 *
 * @discussion
 * EN: A failure invalidates the lease with the error (see -invalidateWithError:), so the queued
 *     chunks that run afterwards end with the same error, after the start failure was delivered.
 * CN: 失败时以该错误作废租约（见 -invalidateWithError:）：之后才执行的排队分片以同一错误结束，
 *     且晚于启动失败的投递（避免 AIPlaybackFailed 发两次）。
 */
- (void)deliverStartResult:(BOOL)success error:(nullable NSError *)error;

/**
 * @brief First captured buffer (audio thread): CAS once, deliver inputLive on the main queue
 * @chinese 首个采音缓冲（音频线程）：CAS 判定一次，在主线程投递 inputLive
 */
- (void)noteCapturedBuffer;

/**
 * @brief Report a non-terminal runtime error on the main queue (after a successful start)
 * @chinese 在主线程报告不作废租约的运行期错误（启动成功之后才投递，之前的暂存到启动成功后）
 */
- (void)deliverRuntimeError:(NSError *)error;

/**
 * @brief Invalidate atomically and deliver the terminal result on the main queue
 * @chinese 原子作废，释放回调，在主线程投递终态
 *
 * @discussion
 * EN: Before the start result: completion(NO, error). After a successful start: errorOccurred(error)
 *     unless the error is Cancelled (stop / same-owner replacement). Returns YES only for the call
 *     that invalidated.
 * CN: 启动结果投递前：completion(NO, error)；启动成功之后：除 Cancelled（stop / 同 owner 替换）外
 *     走 errorOccurred(error)。只有真正作废的那次调用返回 YES。
 */
- (BOOL)invalidateWithError:(NSError *)error;

/**
 * @brief Arm the start watchdog, counted from now (the executor began the block)
 * @chinese 启动看门狗：从现在（执行器开始执行该块）起计时，不含排队时间；超时以 1012 作废租约
 */
- (void)armStartWatchdogWithTimeout:(NSTimeInterval)timeout;

/** @brief The executor finished the start block; disarms the watchdog @chinese 执行器上的启动已结束，解除看门狗 */
- (void)markStartFinished;

/**
 * @brief Subclass hook, called once on the invalidating thread before the registry is updated
 * @chinese 子类钩子：在作废线程上调用一次，早于登记更新（用于安排拆除）
 */
- (void)leaseDidInvalidateWithError:(NSError *)error;

/**
 * @brief Subclass hook on the main queue right before inputLive is delivered (diagnostics)
 * @chinese 子类钩子：主线程投递 inputLive 之前调用（诊断打点）
 */
- (void)leaseWillDeliverInputLive;

@end

/**
 * @brief Single phone-mic user across driver instances
 * @chinese 租约登记：跨驱动实例，同一时刻只有一个手机麦使用方
 *
 * @discussion
 * EN: Same rules as the earbuds arbiter: an App lease preempts a device lease (the preempted one
 *     ends with 1023 Preempted); a lease of the same or lower priority from another owner is Busy;
 *     the same owner replaces its own lease (Cancelled). After the registry is empty and every
 *     teardown finished, TSAIAudioSessionDidBecomeIdleNotification is posted on the main queue.
 *     Teardowns counted: phone-mic leases and the asynchronous stop of the earbuds engine (P1b).
 * CN: 规则与耳机仲裁者一致：App 可以抢 Device（被抢方以 1023 · Preempted 结束）；其他 owner 的同级或
 *     更低请求为 Busy；同一 owner 重新 begin 替换自己的旧租约（Cancelled）。登记清空且拆除全部完成后，
 *     在主线程发出 TSAIAudioSessionDidBecomeIdleNotification。计入的拆除：手机麦租约，以及耳机引擎的
 *     异步停止（P1b）。线程安全。
 */
@interface TSAIAudioSessionLeaseRegistry : NSObject

/** @brief Current registered lease @chinese 当前登记的租约 */
@property (atomic, strong, readonly, nullable) TSAIAudioSessionLease *currentLease;

/** @brief No lease and no pending teardown @chinese 没有登记的租约且没有待完成的拆除 */
@property (atomic, assign, readonly, getter=isIdle) BOOL idle;

/** @brief Busy error for a would-be begin, nil when it may proceed @chinese 预检：会被拒绝时返回 Busy，否则 nil */
- (nullable NSError *)arbitrationErrorForOwner:(NSString *)owner
                                      priority:(TSAIAudioSessionClaimPriority)priority;

/**
 * @brief Register a new lease atomically: replace, preempt or reject (Busy) the current one
 * @chinese 原子登记：替换或抢占当前租约，或以 Busy 拒绝新租约（新租约随即作废）
 */
- (void)registerLease:(TSAIAudioSessionLease *)lease;

/** @brief A teardown was scheduled @chinese 已安排一次拆除 */
- (void)beginTeardown;

/** @brief A teardown finished (executor) @chinese 一次拆除完成（执行器上） */
- (void)endTeardown;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
