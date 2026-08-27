//
//  TSFitKitInit+Private.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/12.
//

#import "TSFitKitInit.h"

@class TSFitAIChatSessionGate;
@class TSFitAIQuestionAnswerAudioNormalizer;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal access shared by TSFitKitInit categories
 * @chinese TSFitKitInit 各类别共享的内部访问接口
 */
@interface TSFitKitInit (Private)

/**
 * @brief Current AI-chat session gate
 * @chinese 当前 AIChat 会话门禁
 * @return EN: The current session gate. CN: 当前会话门禁。
 */
- (TSFitAIChatSessionGate *)aiChatSessionGate;

/**
 * @brief Current question-answer audio normalizer
 * @chinese 当前 AI 问答音频归一化器
 * @return EN: The current audio normalizer. CN: 当前音频归一化器。
 */
- (TSFitAIQuestionAnswerAudioNormalizer *)questionAnswerAudioNormalizer;

/**
 * @brief Dispatch one callback to the Core delegate route
 * @chinese 向 Core delegate 链路分发一次回调
 * @param params EN: Callback routing parameters. CN: 回调路由参数。
 */
- (void)performDelegateSelectorWithParams:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
