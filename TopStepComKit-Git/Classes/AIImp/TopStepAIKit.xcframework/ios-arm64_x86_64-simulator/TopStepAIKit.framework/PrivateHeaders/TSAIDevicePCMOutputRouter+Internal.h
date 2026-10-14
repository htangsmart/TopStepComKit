//
//  TSAIDevicePCMOutputRouter+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIDeviceBridge.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Serializes one AI session's PCM output to the device bridge
 * @chinese 将单个 AI 会话的 PCM 输出串行转发到设备 Bridge
 */
@interface TSAIDevicePCMOutputRouter : NSObject

/**
 * @brief Create a PCM router
 * @chinese 创建 PCM 输出路由器
 * @param bridge EN: Device PCM output bridge. CN: 设备 PCM 输出 Bridge。
 * @param sessionIdentifier EN: AI session identifier. CN: AI 会话标识。
 * @return EN: A PCM output router. CN: PCM 输出路由器。
 */
- (instancetype)initWithBridge:(id<TSAIDevicePCMOutputBridge>)bridge
             sessionIdentifier:(NSString *)sessionIdentifier;

/**
 * @brief Create a PCM router with a finish timeout
 * @chinese 使用指定结束超时时间创建 PCM 输出路由器
 * @param bridge EN: Device PCM output bridge. CN: 设备 PCM 输出 Bridge。
 * @param sessionIdentifier EN: AI session identifier. CN: AI 会话标识。
 * @param finishTimeout EN: Maximum finish duration in seconds. CN: 最大结束等待秒数。
 * @return EN: A PCM output router. CN: PCM 输出路由器。
 */
- (instancetype)initWithBridge:(id<TSAIDevicePCMOutputBridge>)bridge
             sessionIdentifier:(NSString *)sessionIdentifier
                  finishTimeout:(NSTimeInterval)finishTimeout;

/**
 * @brief Create a PCM router that may defer device playback until resumed
 * @chinese 创建可延迟到恢复后才启动设备播放的 PCM 输出路由器
 * @param bridge EN: Device PCM output bridge. CN: 设备 PCM 输出 Bridge。
 * @param sessionIdentifier EN: AI session identifier. CN: AI 会话标识。
 * @param startSuspended EN: Whether PCM should be buffered before resume. CN: 是否在恢复前缓存 PCM。
 * @return EN: A PCM output router. CN: PCM 输出路由器。
 */
- (instancetype)initWithBridge:(id<TSAIDevicePCMOutputBridge>)bridge
             sessionIdentifier:(NSString *)sessionIdentifier
                startSuspended:(BOOL)startSuspended;

/**
 * @brief Create a PCM router that may defer device playback until resumed
 * @chinese 创建可延迟到恢复后才启动设备播放的 PCM 输出路由器
 * @param bridge EN: Device PCM output bridge. CN: 设备 PCM 输出 Bridge。
 * @param sessionIdentifier EN: AI session identifier. CN: AI 会话标识。
 * @param finishTimeout EN: Maximum finish duration in seconds. CN: 最大结束等待秒数。
 * @param startSuspended EN: Whether PCM should be buffered before resume. CN: 是否在恢复前缓存 PCM。
 * @return EN: A PCM output router. CN: PCM 输出路由器。
 */
- (instancetype)initWithBridge:(id<TSAIDevicePCMOutputBridge>)bridge
             sessionIdentifier:(NSString *)sessionIdentifier
                  finishTimeout:(NSTimeInterval)finishTimeout
                 startSuspended:(BOOL)startSuspended
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Append a 16 kHz mono signed Int16LE PCM chunk
 * @chinese 追加 16 kHz 单声道有符号 Int16LE PCM 分片
 */
- (void)appendPCMData:(NSData *)pcmData;

/** @brief Resume deferred device playback @chinese 恢复被延迟的设备播放 */
- (void)resumeOutput;

/** @brief Finish queued PCM output @chinese 正常结束已排队的 PCM 输出 */
- (void)finish;

/**
 * @brief Finish queued PCM output and observe the real device terminal state
 * @chinese 正常结束已排队的 PCM 输出并观察设备真实终态
 * @param completion EN: Main-thread terminal callback, invoked exactly once within
 *                    the configured finish timeout. CN: 主线程终态回调，在配置的
 *                    结束超时时间内保证调用一次。
 */
- (void)finishWithCompletion:(nullable TSAICompletionBlock)completion;

/** @brief Cancel queued PCM output @chinese 取消已排队的 PCM 输出 */
- (void)cancel;

/**
 * @brief Drop the audio of the current output segment and stop device playback, keeping the router usable
 * @chinese 丢弃当前输出段的音频并结束设备播放，路由器保持可用
 * @param reason EN: Log reason (e.g. newRound / userSpeech / app). CN: 日志原因（如 newRound / userSpeech / app）。
 * @discussion
 * [EN]: Unlike `cancel`, this is not terminal. Queued and buffered PCM is discarded, the device
 *       playback segment is cancelled through the bridge, and PCM appended afterwards automatically
 *       starts a new device playback segment once the cancellation completes. Used for round
 *       switching and barge-in so the device always plays the current round. `finish` / `cancel`
 *       semantics are unchanged.
 * [CN]: 与 `cancel` 不同，本方法不是终态：丢弃已排队 / 缓冲的 PCM，经 Bridge 取消当前设备播放段，
 *       之后追加的 PCM 会在取消完成后自动启动新的设备播放段。用于轮次切换与插话，保证设备始终播放
 *       当前轮。`finish` / `cancel` 语义不变。
 */
- (void)interruptOutputWithReason:(NSString *)reason;

/**
 * @brief Same as `interruptOutputWithReason:`, optionally skipped when the device is not playing
 * @chinese 同 `interruptOutputWithReason:`，可选择在设备没在播放时跳过
 * @param reason EN: Log reason. CN: 日志原因。
 * @param onlyIfPlaying EN: YES evaluates `isLikelyPlaying` on the router queue and does nothing when it is NO.
 *                       CN: YES 时在路由器队列上判断 `isLikelyPlaying`，为 NO 则不做任何事。
 * @discussion
 * [EN]: While finishing (finish already requested, no further segment can follow) an interrupt that is
 *       not skipped behaves like `cancel` (terminal, completion reports Cancelled).
 * [CN]: 收尾中（已请求 finish，之后不会再有新段）未被跳过的打断等同 `cancel`（终态，结束回调为 Cancelled）。
 */
- (void)interruptOutputWithReason:(NSString *)reason onlyIfPlaying:(BOOL)onlyIfPlaying;

/**
 * @brief Whether the device probably still has unplayed audio of the current segment (synchronous)
 * @chinese 设备上是否可能仍有当前输出段未播完的音频（同步查询）
 * @return EN: YES while PCM is buffered / starting, or the estimated playback end (real-time playback from
 *         hand-off plus a 0.5 s device latency allowance) is more than 0.3 s away. CN: 仍有缓冲 / 正在启动，
 *         或预计播完时刻（自送出起按实时播放，另加 0.5 秒设备延迟余量）距今超过 0.3 秒时返回 YES。
 */
- (BOOL)isLikelyPlaying;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
