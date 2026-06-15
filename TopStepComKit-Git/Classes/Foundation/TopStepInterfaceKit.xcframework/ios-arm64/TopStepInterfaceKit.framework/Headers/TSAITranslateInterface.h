//
//  TSAITranslateInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import "TSKitBaseInterface.h"
#import "TSAITranslateConfig.h"
#import "TSAITranslatePartialResult.h"
#import "TSAITranslateResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming translate partial-result block
 * @chinese 流式翻译中间结果回调
 *
 * @param partial
 * EN: Cumulative partial result emitted during translation
 * CN: 翻译过程中下发的累积中间结果
 *
 * @discussion
 * [EN]: Invoked zero or more times before completion. `partial.text` is
 *       the full cumulative translation so far, not the newly added
 *       fragment. The trailing partial of a successful task carries
 *       `isFinal = YES`.
 * [CN]: 在 completion 回调之前可能被调用零次或多次。
 *       `partial.text` 为截至当前时刻的累积译文，并非新增片段。
 *       任务成功结束时最后一次 partial 的 `isFinal = YES`。
 */
typedef void(^TSAITranslatePartialBlock)(TSAITranslatePartialResult *partial);

/**
 * @brief Streaming translate completion block
 * @chinese 流式翻译完成回调
 *
 * @param result
 * EN: Final translation result; nil on failure or cancellation
 * CN: 最终翻译结果，失败或取消时为 nil
 *
 * @param error
 * EN: Error info; nil on success
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSAITranslateCompletionBlock)(TSAITranslateResult * _Nullable result,
                                            NSError * _Nullable error);

/**
 * @brief AI Translate interface protocol
 * @chinese AI 翻译接口协议
 *
 * @discussion
 * [EN]: Defines AI text-translation capability. The translation is driven
 *       by a large language model and delivered in a streaming fashion:
 *       partial cumulative text via `onPartialResult`, final result via
 *       `completion`. A single `cancelTranslationWithTaskId:` API covers
 *       cancellation of any in-flight task.
 * [CN]: 定义 AI 文本翻译能力。翻译由大模型驱动并以流式方式下发：
 *       通过 `onPartialResult` 回调累积中间译文，通过 `completion` 回调
 *       最终结果；`cancelTranslationWithTaskId:` 用于取消进行中的任务。
 */
@protocol TSAITranslateInterface <TSKitBaseInterface>

#pragma mark - Streaming Translate

/**
 * @brief Translate text in a streaming manner
 * @chinese 以流式方式翻译文本
 *
 * @param text
 * EN: Source text to translate; must not be empty
 * CN: 待翻译文本，不可为空
 *
 * @param config
 * EN: Translate configuration (source / target language)
 * CN: 翻译配置（源语言 / 目标语言）
 *
 * @param onPartialResult
 * EN: Partial-result callback, invoked zero or more times with cumulative
 *     translation during the request. May be nil if the caller only
 *     cares about the final result.
 * CN: 中间结果回调，翻译过程中可能被多次调用，返回累积译文。
 *     若调用方只关心最终结果可传 nil。
 *
 * @param completion
 * EN: Completion handler, invoked exactly once when translation finishes,
 *     fails or is cancelled.
 * CN: 完成回调，翻译完成、失败或取消时调用一次。
 *
 * @return
 * EN: Client-side task identifier, used for log tracing and cancellation
 *     via `cancelTranslationWithTaskId:`. The same taskId is echoed in
 *     every partial and the final result for correlation.
 * CN: 客户端生成的任务标识，用于日志追踪及通过
 *     `cancelTranslationWithTaskId:` 取消任务。
 *     同一 taskId 会回填在每次 partial 与最终 result 中，便于关联。
 *
 * @discussion
 * [EN]: The taskId returned synchronously is generated on the client side
 *       (typically a UUID), independent of any underlying AI SDK / server
 *       task ID. The caller obtains a stable identifier the moment the
 *       request is issued, decoupled from the concrete AI provider.
 *
 *       Unlike streaming ASR, translation does not revise earlier output
 *       — partial `text` only grows. The trailing partial carries
 *       `isFinal = YES`; `completion` remains the authoritative end
 *       signal because it also covers error and cancellation.
 *
 * [CN]: 同步返回的 taskId 由 SDK 客户端生成（通常为 UUID），
 *       与底层 AI SDK 或服务端的任务 ID 无关。
 *       调用方在发起请求的瞬间即可拿到稳定标识，与具体提供方实现解耦。
 *
 *       与流式 ASR 不同，翻译不会修订已下发文本，partial `text` 只增不改。
 *       任务最后一次 partial 的 `isFinal = YES`；
 *       任务结束的权威信号仍为 `completion`（同时覆盖失败与取消路径）。
 */
- (NSString *)translateText:(NSString *)text
                     config:(TSAITranslateConfig *)config
            onPartialResult:(TSAITranslatePartialBlock _Nullable)onPartialResult
                 completion:(TSAITranslateCompletionBlock _Nullable)completion;

/**
 * @brief Cancel a running translate task
 * @chinese 取消一个进行中的翻译任务
 *
 * @param taskId
 * EN: TaskId returned by `translateText:config:onPartialResult:completion:`
 * CN: `translateText:config:onPartialResult:completion:` 返回的 taskId
 *
 * @discussion
 * [EN]: If the task has already completed or the taskId is unknown, the
 *       call is a no-op. The completion handler of a cancelled task is
 *       invoked with a non-nil error indicating cancellation.
 * [CN]: 若任务已完成或 taskId 未知，调用无副作用。
 *       被取消任务的 completion 回调会以非 nil 的取消错误调用。
 */
- (void)cancelTranslationWithTaskId:(NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
