//
//  TSAIAudioSessionArbiter+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/16.
//

#import <Foundation/Foundation.h>

@protocol TSAIAudioSessionControlling;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Priority of an earbuds-microphone claim
 * @chinese 耳机麦克风持有的优先级
 */
typedef NS_ENUM(NSInteger, TSAIAudioSessionClaimPriority) {
    /// @brief Session started by the device (key press on the case / watch) @chinese 设备发起的会话
    TSAIAudioSessionClaimPriorityDevice = 0,
    /// @brief Session the user started in the App @chinese 用户在 App 中发起的会话
    TSAIAudioSessionClaimPriorityApp = 1,
};

/**
 * @brief One holder of the process audio session
 * @chinese 进程音频会话的一个持有者
 */
@interface TSAIAudioSessionClaim : NSObject

/** @brief Owner name for logs @chinese 持有者名称（日志用） */
@property (nonatomic, copy, readonly) NSString *owner;

/** @brief Priority @chinese 优先级 */
@property (nonatomic, assign, readonly) TSAIAudioSessionClaimPriority priority;

/** @brief Whether this is the exclusive earbuds-microphone claim @chinese 是否为独占的耳机麦克风持有 */
@property (nonatomic, assign, readonly, getter=isExclusive) BOOL exclusive;

/** @brief NO after release or preemption @chinese 释放或被抢占后为 NO */
@property (atomic, assign, readonly, getter=isValid) BOOL valid;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief Process-wide arbiter of the audio session used by AIKit
 * @chinese AIKit 音频会话的进程级仲裁者
 *
 * @discussion
 * EN: - The earbuds microphone has at most one holder. An App claim preempts a device claim;
 *       a claim of the same or lower priority fails with TSAIErrorCodeBusy.
 *     - The session configuration is captured when the first claim arrives and restored when the
 *       last claim leaves (reference counted): preferred input cleared, session deactivated with
 *       NotifyOthersOnDeactivation, category / mode / options put back. When deactivation fails
 *       because audio objects are still running ('!act'), only the category is restored.
 *     - Releasing the earbuds claim always clears the preferred input, so a later built-in-mic
 *       session does not silently pick up the earbuds microphone.
 *     - Users never deactivate the session themselves. The lock only guards the bookkeeping: a
 *       release decides synchronously, while clearing the preferred input and the restore run on
 *       the audio session executor, outside the lock (readers such as the main-thread preflight are
 *       never held up by session I/O). A claim that arrives before a decided restore finished adopts
 *       the original configuration and cancels the rest of that restore.
 * CN: - 耳机麦克风同一时刻最多一个持有者。App 发起的持有可抢占设备发起的持有；
 *       同级或更低优先级的申请返回 TSAIErrorCodeBusy。
 *     - 第一个持有者到来时记下会话配置，最后一个离开时恢复（引用计数）：清除首选输入，
 *       以 NotifyOthersOnDeactivation 释放会话，恢复类别 / 模式 / 选项。
 *       释放因仍有音频对象在运行（'!act'）失败时，只恢复类别。
 *     - 释放耳机持有时总是清除首选输入，避免之后的手机麦会话悄悄用上耳机麦。
 *     - 使用者自己不释放会话。锁只保护记账：释放时在锁内做决定，清除首选输入与会话恢复在锁外、
 *       在音频会话执行器上执行（主线程 preflight 等读取不会被会话 I/O 拖住）；恢复尚未执行完时到来的
 *       新申请沿用原始配置，并作废这次恢复的剩余步骤。
 *     线程安全。
 */
@interface TSAIAudioSessionArbiter : NSObject

/** @brief The controlled audio session @chinese 被仲裁的音频会话 */
@property (nonatomic, strong, readonly) id<TSAIAudioSessionControlling> audioSession;

/** @brief Number of valid claims @chinese 当前有效持有数 */
@property (nonatomic, assign, readonly) NSUInteger claimCount;

/** @brief Current earbuds-microphone holder @chinese 当前的耳机麦克风持有者 */
@property (nonatomic, strong, readonly, nullable) TSAIAudioSessionClaim *earbudsMicrophoneClaim;

/**
 * @brief Process-wide arbiter over [AVAudioSession sharedInstance]
 * @chinese 作用于 [AVAudioSession sharedInstance] 的进程级仲裁者
 */
+ (instancetype)sharedArbiter;

/**
 * @brief Arbiter over the given session (unit tests)
 * @chinese 作用于指定会话的仲裁者（单测用）
 */
- (instancetype)initWithAudioSession:(id<TSAIAudioSessionControlling>)audioSession NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Claim the earbuds microphone
 * @chinese 申请耳机麦克风持有权
 *
 * @param owner
 * EN: Owner name for logs
 * CN: 持有者名称（日志用）
 *
 * @param priority
 * EN: Claim priority
 * CN: 持有优先级
 *
 * @param preemptionHandler
 * EN: Called once on the main queue if a higher-priority claim takes over. The claim is already
 *     invalid by then; the holder must stop its audio and must not release the session itself.
 * CN: 被更高优先级抢占时在主线程回调一次。回调时持有已失效；持有者应停止音频，且不要自行释放会话。
 *
 * @param error
 * EN: TSAIErrorCodeBusy when the microphone is held at the same or a higher priority
 * CN: 已有同级或更高优先级的持有者时为 TSAIErrorCodeBusy
 *
 * @return
 * EN: The claim, or nil on failure
 * CN: 持有凭证；失败时为 nil
 */
- (nullable TSAIAudioSessionClaim *)claimEarbudsMicrophoneForOwner:(NSString *)owner
                                                          priority:(TSAIAudioSessionClaimPriority)priority
                                                 preemptionHandler:(nullable void (^)(void))preemptionHandler
                                                             error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Register a shared holder (another Core-started audio user)
 * @chinese 登记一个共享持有者（Core 发起的其他音频使用者）
 *
 * @discussion
 * EN: Shared holders never conflict; they only keep the session from being restored.
 * CN: 共享持有者之间不冲突，只用于推迟会话恢复。
 */
- (TSAIAudioSessionClaim *)claimSharedSessionForOwner:(NSString *)owner;

/**
 * @brief Release a claim (idempotent; invalid claims are ignored)
 * @chinese 释放持有（幂等；已失效的持有被忽略）
 */
- (void)releaseClaim:(nullable TSAIAudioSessionClaim *)claim;

@end

NS_ASSUME_NONNULL_END
