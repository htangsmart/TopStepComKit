//
//  TSAIQuestionAnswerPartialResult.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming partial result for AI question answering
 * @chinese AI 问答流式中间结果
 */
@interface TSAIQuestionAnswerPartialResult : NSObject

/** @brief Client-side task identifier @chinese 客户端任务标识 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Opaque question identifier assigned by the AI service
 * @chinese AI 服务分配的不透明问题标识
 */
@property (nonatomic, copy, nullable) NSString *questionId;

/** @brief Newly generated text in this update @chinese 本次更新新增的文本 */
@property (nonatomic, copy, nullable) NSString *deltaText;

/**
 * @brief Cumulative answer text after applying this update
 * @chinese 应用本次更新后的累积答案文本
 */
@property (nonatomic, copy) NSString *fullText;

/**
 * @brief Whether the Provider marks this as the final answer update
 * @chinese Provider 是否将本次更新标记为最后一次答案更新
 *
 * @discussion
 * [EN]: This flag describes only the stream update. Successful task
 *       completion is delivered separately through the completion block.
 * [CN]: 该标记仅描述流式更新。任务成功终态仍通过 completion 回调下发。
 */
@property (nonatomic, assign) BOOL isFinal;

@end

NS_ASSUME_NONNULL_END
