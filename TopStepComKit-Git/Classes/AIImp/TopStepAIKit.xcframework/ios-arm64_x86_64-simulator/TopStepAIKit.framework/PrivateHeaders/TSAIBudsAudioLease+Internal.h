//
//  TSAIBudsAudioLease+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/17.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioSessionExecutor+Internal.h"

@class TSAIBudsSystemAudioDriver;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One start of the phone-mic system audio driver
 * @chinese 手机麦系统音频驱动的一次启动（租约）
 *
 * @discussion
 * EN: append / interrupt enter the executor through the lease and run FIFO; a chunk of a stale
 *     lease ends with the lease's terminal error. interrupt retires the current voice in the
 *     bookkeeping at once (chunks submitted before it are dropped); the vendor interrupt runs on
 *     the executor. stop invalidates at once and tears down on the executor.
 * CN: append / interrupt 经租约进入执行器，按 FIFO 执行；过期租约的分片以租约的终态错误结束。
 *     interrupt 在记账里同步把当前语音标为退场（之前提交的分片一律丢弃），对厂商的打断在执行器上执行。
 *     stop 同步作废，在执行器上拆除。
 */
@interface TSAIBudsAudioLease : TSAIAudioSessionLease

/** @brief Driver that owns the engines @chinese 所属驱动 */
@property (nonatomic, strong, readonly) TSAIBudsSystemAudioDriver *driver;

/** @brief Requested input @chinese 请求的输入通道 */
@property (nonatomic, assign, readonly) TSAIAudioInputChannel inputChannel;

/** @brief Requested output @chinese 请求的输出通道 */
@property (nonatomic, assign, readonly) TSAIAudioOutputChannel outputChannel;

/** @brief Whether the start block was enqueued (teardown is scheduled on invalidation only then) @chinese 是否已入队启动块（只有这时作废才安排拆除） */
@property (atomic, assign, readonly) BOOL startEnqueued;

/** @brief System uptime of begin @chinese begin 时刻（systemUptime） */
@property (nonatomic, assign, readonly) NSTimeInterval beginUptime;

/** @brief System uptime when the engine started (0 before) @chinese 引擎启动完成时刻（之前为 0） */
@property (atomic, assign) NSTimeInterval engineStartedUptime;

/** @brief Create a lease of the driver @chinese 创建驱动的一次启动 */
- (instancetype)initWithDriver:(TSAIBudsSystemAudioDriver *)driver
                  inputChannel:(TSAIAudioInputChannel)inputChannel
                 outputChannel:(TSAIAudioOutputChannel)outputChannel
                         owner:(NSString *)owner
                      priority:(TSAIAudioSessionClaimPriority)priority NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithOwner:(NSString *)owner
                     priority:(TSAIAudioSessionClaimPriority)priority
                   needsInput:(BOOL)needsInput NS_UNAVAILABLE;

/** @brief The start block was enqueued @chinese 启动块已入队 */
- (void)markStartEnqueued;

@end

NS_ASSUME_NONNULL_END
