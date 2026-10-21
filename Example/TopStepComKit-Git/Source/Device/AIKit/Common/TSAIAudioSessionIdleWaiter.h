//
//  TSAIAudioSessionIdleWaiter.h
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Lets a Demo player configure AVAudioSession only after TopStepAIKit has finished with it
 * @chinese 让 Demo 自带的播放器等 TopStepAIKit 用完音频会话后再自行配置 AVAudioSession
 *
 * @discussion
 * [EN]: Session completions of TopStepAIKit no longer wait for the audio teardown (up to about 1 s).
 *       A player that sets the category or activates the session right after a session ended would
 *       race with that teardown (its deactivation could stop the playback). Check
 *       +isAudioSessionIdle first; when it is NO, wait with +waitForIdleWithLabel:handler:, which
 *       observes TSAIAudioSessionDidBecomeIdleNotification and gives up after a timeout so playback
 *       never hangs. Main thread only.
 * [CN]: TopStepAIKit 的会话 completion 不再等待音频拆除（最长约 1 秒）。会话刚结束就设置类别 / 激活会话
 *       的播放器会与拆除交错（拆除里的反激活可能把播放停掉）。先查看 +isAudioSessionIdle；为 NO 时用
 *       +waitForIdleWithLabel:handler: 等待，它监听 TSAIAudioSessionDidBecomeIdleNotification，
 *       超时后放弃等待，播放不会卡住。仅在主线程使用。
 */
@interface TSAIAudioSessionIdleWaiter : NSObject

/**
 * @brief Whether TopStepAIKit has no audio session work in flight
 * @chinese TopStepAIKit 当前是否没有在用或在拆除音频会话
 *
 * @return
 * EN: `isAudioSessionIdle` of the active Context's audio routing; YES when there is no active Context
 *     or the SDK does not report it
 * CN: 当前 Context 音频路由的 `isAudioSessionIdle`；没有活动 Context 或 SDK 不支持该查询时返回 YES
 */
+ (BOOL)isAudioSessionIdle;

/**
 * @brief Wait until TopStepAIKit is idle, then call back on the main thread
 * @chinese 等 TopStepAIKit 空闲后在主线程回调
 *
 * @discussion
 * [EN]: Never calls back synchronously, even when already idle. Gives up after 3 s and calls back
 *       with `timedOut` = YES. The waiter keeps itself alive until it calls back or is cancelled.
 * [CN]: 不会同步回调，即使当前已空闲。3 秒后放弃等待，以 `timedOut` = YES 回调。等待者在回调或
 *       取消之前自己保持存活。
 *
 * @param label
 * EN: Caller name for logs
 * CN: 调用方名称（日志用）
 *
 * @param handler
 * EN: Called once on the main thread; `timedOut` is YES when the wait gave up
 * CN: 在主线程回调一次；放弃等待时 `timedOut` 为 YES
 *
 * @return
 * EN: The waiter; keep it to cancel the wait
 * CN: 等待者；需要取消等待时保留它
 */
+ (instancetype)waitForIdleWithLabel:(NSString *)label handler:(void (^)(BOOL timedOut))handler;

/**
 * @brief Cancel the wait; the handler is not called
 * @chinese 取消等待，不再回调
 */
- (void)cancel;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
