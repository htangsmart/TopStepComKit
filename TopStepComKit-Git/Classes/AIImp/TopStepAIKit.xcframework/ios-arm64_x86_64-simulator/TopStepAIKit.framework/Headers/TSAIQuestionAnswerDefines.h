//
//  TSAIQuestionAnswerDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/14.
//

#import <Foundation/Foundation.h>

#import "TSAIQuestionAnswerPartialResult.h"
#import "TSAIQuestionAnswerResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Question-answer start callback
 * @chinese AI 问答开始回调
 */
typedef void(^TSAIQuestionAnswerStartBlock)(NSString *taskId,
                                            NSString * _Nullable questionId);

/**
 * @brief Question-answer streaming callback
 * @chinese AI 问答流式结果回调
 */
typedef void(^TSAIQuestionAnswerPartialBlock)(
    TSAIQuestionAnswerPartialResult *partialResult);

/**
 * @brief Question-answer terminal callback
 * @chinese AI 问答终态回调
 */
typedef void(^TSAIQuestionAnswerCompletionBlock)(
    TSAIQuestionAnswerResult * _Nullable result,
    NSError * _Nullable error);

NS_ASSUME_NONNULL_END
