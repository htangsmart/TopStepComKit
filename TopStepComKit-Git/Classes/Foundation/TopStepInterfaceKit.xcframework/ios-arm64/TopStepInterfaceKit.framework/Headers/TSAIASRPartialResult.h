//
//  TSAIASRPartialResult.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming ASR partial result
 * @chinese 流式语音识别中间结果
 *
 * @discussion
 * [EN]: Emitted multiple times during a single recognition request. The `text`
 *       field carries the cumulative transcription up to the current moment,
 *       not the newly added fragment, so callers can simply assign it to UI
 *       (e.g. `label.text = partial.text`) without manual concatenation.
 *
 *       Streaming ASR may *revise* the tail of the current sentence as more
 *       audio is recognized (e.g. "我去北" → "我去北京" → "我去背景"). Use
 *       `isSentenceFinal` to know when the current sentence has stabilized.
 *
 * [CN]: 单次识别过程中会多次回调。`text` 字段为截至当前时刻的累积识别文本，
 *       并非新增片段，调用方可直接赋值给 UI（如 `label.text = partial.text`），
 *       无需手动拼接。
 *
 *       流式识别过程中，当前句的末尾文本可能被多次修订
 *       （如 "我去北" → "我去北京" → "我去背景"）。
 *       通过 `isSentenceFinal` 判断当前句是否已稳定不再修订。
 */
@interface TSAIASRPartialResult : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by the recognize API)
 * @chinese 任务唯一标识（与识别接口同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief 0-based sentence ordinal number
 * @chinese 当前句的序号（从 0 开始）
 *
 * @discussion
 * [EN]: Ordinal of the sentence this callback corresponds to within the task,
 *       starting at 0. Long audio is automatically segmented; consumers can
 *       use this to commit per-sentence work (e.g. line break, persist).
 * [CN]: 该回调所对应句子在整次任务中的序号，从 0 开始。
 *       长音频会被自动切句，调用方可以据此做"逐句换行/逐句落库"等动作。
 */
@property (nonatomic, assign) NSInteger sentenceNo;

/**
 * @brief 0-based fragment ordinal number within the current sentence
 * @chinese 当前句内的分片序号（从 0 开始）
 *
 * @discussion
 * [EN]: Each sentence may be revised across multiple fragments before it
 *       stabilizes. `fragmentNo` resets to 0 on every new sentence. Useful for
 *       de-duplicating out-of-order callbacks and for debugging.
 * [CN]: 同一句话在稳定前可能经过多次修订回调。
 *       每开始新句时 `fragmentNo` 重置为 0。
 *       可用于丢弃乱序回调以及调试定位。
 */
@property (nonatomic, assign) NSInteger fragmentNo;

/**
 * @brief Cumulative recognized text up to the current moment
 * @chinese 截至当前时刻的累积识别文本
 *
 * @discussion
 * [EN]: Full cumulative transcription, including all finalized sentences and
 *       the current (possibly being revised) one.
 * [CN]: 完整累积识别文本，包含所有已稳定句子与当前（可能仍在修订的）句子。
 */
@property (nonatomic, copy) NSString *text;

/**
 * @brief Whether the current sentence has stabilized
 * @chinese 当前句是否已稳定（不再被修订）
 *
 * @discussion
 * [EN]: `YES` means the current sentence's text will not be revised anymore.
 *       UI typically renders non-final sentences in a lighter style and
 *       commits them when this flag flips to `YES`. The next callback (if any)
 *       starts a new sentence with a new `sentenceNo`.
 * [CN]: `YES` 表示当前句文本已稳定，不会再被修订。
 *       UI 通常对未稳定的句子做浅色/斜体显示，标记为稳定后再固化。
 *       后续若仍有回调，会进入下一个新句（`sentenceNo` 递增）。
 */
@property (nonatomic, assign) BOOL isSentenceFinal;



@end

NS_ASSUME_NONNULL_END
