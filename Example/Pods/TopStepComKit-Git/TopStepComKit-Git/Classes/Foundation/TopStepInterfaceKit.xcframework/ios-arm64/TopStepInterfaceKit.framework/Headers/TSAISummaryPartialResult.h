//
//  TSAISummaryPartialResult.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming summary partial result
 * @chinese 流式总结中间结果
 *
 * @discussion
 * [EN]: Emitted multiple times during a single summarization request. The
 *       `text` field carries the cumulative summary up to the current moment,
 *       so callers can simply assign it to UI (e.g. `label.text = partial.text`)
 *       without manual concatenation.
 *
 *       Unlike streaming ASR, LLM output is append-only — text already
 *       emitted in a previous partial will not be revised. Hence there is no
 *       "is final / is stable" flag here.
 *
 * [CN]: 单次总结过程中会多次回调。`text` 字段为截至当前时刻的累积总结文本，
 *       调用方可直接赋值给 UI（如 `label.text = partial.text`），
 *       无需手动拼接。
 *
 *       与流式 ASR 不同，LLM 输出为追加式 ——
 *       前次 partial 已下发的文本不会被修订，
 *       因此无需"是否稳定"之类的标志位。
 */
@interface TSAISummaryPartialResult : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by the summarize API)
 * @chinese 任务唯一标识（与总结接口同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Cumulative summary text up to the current moment
 * @chinese 截至当前时刻的累积总结文本
 */
@property (nonatomic, copy) NSString *text;

@end

NS_ASSUME_NONNULL_END
