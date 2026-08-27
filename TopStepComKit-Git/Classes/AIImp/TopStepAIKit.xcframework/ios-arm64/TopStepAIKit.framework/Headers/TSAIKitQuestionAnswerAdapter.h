//
//  TSAIKitQuestionAnswerAdapter.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/14.
//

#import "TSAIQuestionAnswerInterface.h"

@class TSAIContext;
@protocol TSAIQuestionAnswerProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified question-answer facade
 * @chinese 统一 AI 问答门面
 */
@interface TSAIKitQuestionAnswerAdapter : NSObject <TSAIQuestionAnswerInterface>

/**
 * @brief Create a question-answer adapter bound to one Context
 * @chinese 创建绑定到指定 Context 的 AI 问答适配器
 *
 * @param context
 * EN: Context that owns this adapter
 * CN: 持有当前适配器的 Context
 *
 * @param questionAnswerProvider
 * EN: Question-answer Provider created for the same Context
 * CN: 为同一 Context 创建的问答 Provider
 *
 * @return
 * EN: A Context-bound question-answer adapter
 * CN: 绑定到 Context 的问答适配器
 */
- (instancetype)initWithContext:(TSAIContext *)context
         questionAnswerProvider:(id<TSAIQuestionAnswerProvider>)questionAnswerProvider
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
