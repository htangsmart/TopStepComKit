//
//  TSAIQuestionAnswerResult.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Final result of an AI question-answer request
 * @chinese AI 问答请求的最终结果
 *
 * @discussion
 * [EN]: Delivered exactly once through the completion block after the AI
 *       service confirms that answering has finished successfully.
 * [CN]: AI 服务确认答题成功结束后，通过 completion 回调且仅下发一次。
 */
@interface TSAIQuestionAnswerResult : NSObject

/** @brief Client-side task identifier @chinese 客户端任务标识 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Opaque question identifier assigned by the AI service
 * @chinese AI 服务分配的不透明问题标识
 */
@property (nonatomic, copy, nullable) NSString *questionId;

/** @brief Complete generated answer @chinese 完整生成答案 */
@property (nonatomic, copy) NSString *answerText;

@end

NS_ASSUME_NONNULL_END
