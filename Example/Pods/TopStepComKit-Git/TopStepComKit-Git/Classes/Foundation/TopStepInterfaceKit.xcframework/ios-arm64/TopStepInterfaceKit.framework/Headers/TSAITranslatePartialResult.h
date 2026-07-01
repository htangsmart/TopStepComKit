//
//  TSAITranslatePartialResult.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming translate partial result
 * @chinese 流式翻译中间结果
 *
 * @discussion
 * [EN]: Emitted multiple times during a single translate request. The
 *       `text` field carries the cumulative translated text up to the
 *       current moment, not the newly added fragment, so callers can
 *       simply assign it to UI (e.g. `label.text = partial.text`) without
 *       manual concatenation.
 *
 *       Unlike streaming ASR, translation does not revise earlier output
 *       — the cumulative text only grows. The trailing partial of a task
 *       has `isFinal = YES`; callers may use either this flag or the
 *       outer `completion` block to know when streaming ends, but
 *       `completion` is the authoritative signal (it also covers error
 *       and cancellation paths).
 *
 * [CN]: 单次翻译过程中会多次回调。`text` 字段为截至当前时刻的累积译文，
 *       并非新增片段，调用方可直接赋值给 UI（如 `label.text = partial.text`），
 *       无需手动拼接。
 *
 *       与流式 ASR 不同，翻译不会修订已下发文本，累积文本只增不改。
 *       任务最后一次 partial 的 `isFinal = YES`；调用方可凭此标志
 *       或外层 `completion` 判定流式结束，但 `completion` 才是权威信号
 *       （同时覆盖失败与取消路径）。
 */
@interface TSAITranslatePartialResult : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by the translate API)
 * @chinese 任务唯一标识（与翻译接口同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Cumulative translated text up to the current moment
 * @chinese 截至当前时刻的累积译文
 *
 * @discussion
 * [EN]: Full cumulative translation. UI can render directly without
 *       manual concatenation.
 * [CN]: 完整累积译文，UI 可直接渲染，无需手动拼接。
 */
@property (nonatomic, copy) NSString *text;

/**
 * @brief Backend-detected source language
 * @chinese 后端检测到的源语言
 *
 * @discussion
 * [EN]: When `TSAITranslateConfig.sourceLanguage` is `Auto`, this carries
 *       the language the backend actually detected. When the caller
 *       specified a concrete source language, this echoes that value.
 *       May be `TSAILanguageUnknown` if detection has not converged
 *       on the first few partials.
 * [CN]: 当 `TSAITranslateConfig.sourceLanguage` 为 `Auto` 时，
 *       该字段为后端实际检测到的语言；调用方显式指定时，回显该值。
 *       前几次 partial 中检测可能尚未稳定，此时可能为
 *       `TSAILanguageUnknown`。
 */
@property (nonatomic, assign) TSAILanguage detectedSourceLanguage;

/**
 * @brief Whether this is the last partial of the streaming sequence
 * @chinese 是否为流式序列的最后一次 partial
 *
 * @discussion
 * [EN]: `YES` on the final partial of a successful task; `NO` otherwise.
 *       `completion` remains the authoritative signal for task end
 *       because it also covers error and cancellation, but consumers
 *       that only care about the success path may rely on this flag.
 * [CN]: 任务成功结束时最后一次 partial 为 `YES`，其余为 `NO`。
 *       任务结束的权威信号仍为 `completion`（同时覆盖失败与取消），
 *       仅关注成功路径的调用方可依赖此标志。
 */
@property (nonatomic, assign) BOOL isFinal;

@end

NS_ASSUME_NONNULL_END
