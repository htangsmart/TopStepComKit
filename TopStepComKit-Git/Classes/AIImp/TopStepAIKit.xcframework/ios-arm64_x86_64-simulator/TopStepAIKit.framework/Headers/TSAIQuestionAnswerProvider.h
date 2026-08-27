//
//  TSAIQuestionAnswerProvider.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/14.
//

#import "TSAIQuestionAnswerInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Provider contract for single-question AI answering
 * @chinese 单次 AI 问答 Provider 契约
 */
@protocol TSAIQuestionAnswerProvider <NSObject>

/**
 * @brief Whether the active route supports question answering
 * @chinese 当前路由是否支持问答
 *
 * @return
 * EN: YES when supported
 * CN: 支持时返回 YES
 */
- (BOOL)isSupport;

/**
 * @brief Ask one text question and stream its answer
 * @chinese 提交一个文本问题并流式返回答案
 *
 * @param question EN: Non-empty question. CN: 非空问题。
 * @param config EN: Question-answer configuration. CN: 问答配置。
 * @param onStartAnswering EN: Optional start callback. CN: 可选开始回调。
 * @param onPartialResult EN: Optional partial callback. CN: 可选中间结果回调。
 * @param completion EN: Exactly-once terminal callback. CN: 仅一次的终态回调。
 * @return EN: Provider-neutral client task identifier. CN: Provider 无关的客户端任务标识。
 */
- (NSString *)askQuestion:(NSString *)question
                   config:(TSAIQuestionAnswerConfig *)config
         onStartAnswering:(TSAIQuestionAnswerStartBlock _Nullable)onStartAnswering
          onPartialResult:(TSAIQuestionAnswerPartialBlock _Nullable)onPartialResult
               completion:(TSAIQuestionAnswerCompletionBlock _Nullable)completion;

/**
 * @brief Logically cancel one question-answer task
 * @chinese 逻辑取消单个 AI 问答任务
 *
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 */
- (void)cancelQuestionAnswerWithTaskId:(NSString *)taskId;

/**
 * @brief Logically cancel all question-answer tasks
 * @chinese 逻辑取消全部 AI 问答任务
 */
- (void)cancelAllTasks;

@end

NS_ASSUME_NONNULL_END
