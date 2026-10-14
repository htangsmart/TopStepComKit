//
//  TSAIQuestionAnswerAgent.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI agent used by single-turn question answering
 * @chinese 单轮 AI 问答使用的智能体
 *
 * @discussion
 * [EN]: Provider-neutral agent selection. Each Provider maps the value to its
 *       own identifier; Unspecified lets the active AI service choose its default.
 * [CN]: 厂商无关的智能体选择，由各 Provider 映射为自身标识；
 *       Unspecified 表示由当前 AI 服务选择默认智能体。
 */
typedef NS_ENUM(NSInteger, TSAIQuestionAnswerAgent) {
    /// @brief No agent selected @chinese 未指定，使用服务默认智能体
    TSAIQuestionAnswerAgentUnspecified = 0,
    /// @brief Doubao @chinese 豆包
    TSAIQuestionAnswerAgentDoubao = 1,
    /// @brief DeepSeek @chinese DeepSeek
    TSAIQuestionAnswerAgentDeepSeek = 2,
    /// @brief ChatGLM (Zhipu) @chinese 智谱清言
    TSAIQuestionAnswerAgentChatGLM = 3,
    /// @brief ERNIE Bot @chinese 文心一言
    TSAIQuestionAnswerAgentERNIEBot = 4,
    /// @brief Qwen @chinese 通义千问
    TSAIQuestionAnswerAgentQwen = 5,
    /// @brief Spark @chinese 讯飞星火
    TSAIQuestionAnswerAgentSpark = 6,
    /// @brief Kimi @chinese Kimi
    TSAIQuestionAnswerAgentKimi = 7,
};

NS_ASSUME_NONNULL_END
