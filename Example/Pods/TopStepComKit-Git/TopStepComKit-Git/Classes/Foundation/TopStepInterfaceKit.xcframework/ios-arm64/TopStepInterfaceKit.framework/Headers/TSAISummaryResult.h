//
//  TSAISummaryResult.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming summary final result
 * @chinese 流式总结最终结果
 *
 * @discussion
 * [EN]: Delivered exactly once via the completion handler when summarization
 *       finishes. `text` is the full summary; intermediate updates are
 *       received via the partial-result callback.
 * [CN]: 总结完成后通过 completion 回调一次。`text` 为完整总结文本；
 *       中间过程文本通过 partial 回调接收。
 */
@interface TSAISummaryResult : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by the summarize API)
 * @chinese 任务唯一标识（与总结接口同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Full summary text
 * @chinese 完整总结文本
 */
@property (nonatomic, copy) NSString *text;

/**
 * @brief Summarization elapsed time in seconds
 * @chinese 总结耗时（秒）
 */
@property (nonatomic, assign) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
