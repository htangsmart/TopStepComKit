//
//  TSFitKitInit+AIQuestionAnswer.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/12.
//

#import "TSFitKitInit.h"

#import "TSFitAIQuestionAnswerAudioNormalizer.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief FitCloud callback routing for single-turn AI question answering
 * @chinese 单轮 AI 问答的 FitCloud 回调路由
 *
 * @discussion
 * [EN]: FitCloud retains LLM in its callback selector names for ABI
 *       compatibility. This category maps those callbacks only to the
 *       single-turn question-answer domain and never to multi-turn AI chat.
 * [CN]: FitCloud 为保持 ABI 兼容，原始回调 selector 仍使用 LLM 命名。
 *       本类别只将其映射到单轮 AI 问答，不会进入多轮 AI 对话链路。
 */
@interface TSFitKitInit (AIQuestionAnswer)
    <TSFitAIQuestionAnswerAudioNormalizerDelegate>

@end

NS_ASSUME_NONNULL_END
