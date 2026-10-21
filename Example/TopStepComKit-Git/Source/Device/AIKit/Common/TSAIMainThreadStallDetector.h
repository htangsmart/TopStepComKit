//
//  TSAIMainThreadStallDetector.h
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief DEBUG main-thread stall detector: logs whenever the main queue was blocked longer than 100 ms
 * @chinese DEBUG 主线程卡顿探测器：主队列被阻塞超过 100 ms 时打印日志
 *
 * @discussion
 * [EN]: A background timer pings the main queue every 50 ms and measures how late the ping runs.
 *       A stall is logged as `[mainStall] main thread blocked xx ms (context=..., xx ms before)`, where
 *       the context is the latest +markContext: (e.g. the press of the hold-to-talk button). Used as a
 *       regression check for the asynchronous audio start. Start / stop are reference counted.
 *       Every method is a no-op in non-DEBUG builds.
 * [CN]: 后台定时器每 50 ms 向主队列投递一次探测，测量它晚了多久执行。卡顿时打印
 *       `[mainStall] main thread blocked xx ms (context=..., xx ms before)`，context 为最近一次
 *       +markContext:（如按住说话的按下）。用作音频异步启动的回归手段。启停按引用计数。
 *       非 DEBUG 构建下所有方法都不做任何事。
 */
@interface TSAIMainThreadStallDetector : NSObject

/**
 * @brief Start monitoring (reference counted)
 * @chinese 开始监测（引用计数）
 *
 * @param owner
 * EN: Who starts it, for logs
 * CN: 启动方名称（日志用）
 */
+ (void)startMonitoringForOwner:(NSString *)owner;

/**
 * @brief Stop monitoring; the timer stops when the last owner stops
 * @chinese 停止监测；最后一个启动方停止后关闭定时器
 *
 * @param owner
 * EN: The name passed to +startMonitoringForOwner:
 * CN: 与 +startMonitoringForOwner: 相同的名称
 */
+ (void)stopMonitoringForOwner:(NSString *)owner;

/**
 * @brief Note what the main thread is about to do; printed with the next stall
 * @chinese 记录主线程接下来要做的事，随下一次卡顿一并打印
 *
 * @param context
 * EN: Short tag such as @"chat.press"
 * CN: 简短标签，如 @"chat.press"
 */
+ (void)markContext:(NSString *)context;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
