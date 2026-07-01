//
//  TSAIChatReport.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Reason a chat session ended
 * @chinese 会话结束原因
 */
typedef NS_ENUM(NSInteger, TSAIChatEndReason) {
    /// 未知 / 未设置 (Unknown / unset)
    TSAIChatEndReasonUnknown   = -1,
    /// 调用方主动 stop (Caller invoked stop)
    TSAIChatEndReasonUserStop  = 1,
    /// 因长时间无输入自动结束 (Auto-ended due to no input)
    TSAIChatEndReasonTimeout   = 2,
    /// 调用方 cancel 强制中止 (Caller invoked cancel)
    TSAIChatEndReasonCancelled = 3,
    /// 运行时错误导致结束 (Ended due to runtime error)
    TSAIChatEndReasonError     = 4,
};

/**
 * @brief AI chat session final report
 * @chinese AI 对话会话最终报告
 *
 * @discussion
 * [EN]: Delivered exactly once via the completion handler when the session
 *       ends — whether by user `stop`, auto-timeout, `cancel` or error.
 *       Does not carry the full transcript / audio (those have already been
 *       streamed via `onContent`); summarizes session-level metadata only.
 * [CN]: 会话结束（无论是 `stop`、自动超时、`cancel` 还是出错）时
 *       通过 completion 回调下发一次。
 *       不携带完整文本 / 音频（这些已通过 `onContent` 流式下发），
 *       仅汇总会话级元信息。
 */
@interface TSAIChatReport : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by startChat...)
 * @chinese 任务唯一标识（与 startChat... 同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Session start time
 * @chinese 会话开始时间
 */
@property (nonatomic, copy) NSDate *startTime;

/**
 * @brief Session end time
 * @chinese 会话结束时间
 */
@property (nonatomic, copy) NSDate *endTime;

/**
 * @brief Session duration in seconds
 * @chinese 会话总时长（秒）
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 * @brief Number of completed Q&A rounds
 * @chinese 已完成的问答轮次数
 */
@property (nonatomic, assign) NSInteger roundCount;

/**
 * @brief Reason the session ended
 * @chinese 会话结束原因
 */
@property (nonatomic, assign) TSAIChatEndReason endReason;

@end

NS_ASSUME_NONNULL_END
