//
//  TSAIQuestionAnswerConfig.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Configuration for a single AI question-answer request
 * @chinese 单次 AI 问答请求配置
 *
 * @discussion
 * [EN]: Carries provider-neutral options for a text question. It is separate
 *       from `TSAIChatConfig` because question answering does not start a
 *       device-microphone chat session or configure VAD and TTS behavior.
 * [CN]: 承载文本问答的厂商无关配置。该配置独立于 `TSAIChatConfig`，
 *       因为问答不会启动设备麦克风对话会话，也不配置 VAD 或 TTS 行为。
 */
@interface TSAIQuestionAnswerConfig : NSObject

/**
 * @brief Optional AI agent identifier
 * @chinese 可选的 AI 角色标识
 *
 * @discussion
 * [EN]: The identifier value is defined by the active AI service. A nil value
 *       lets that service select its default agent.
 * [CN]: 标识取值由当前 AI 服务定义。为 nil 时由该服务选择默认角色。
 */
@property (nonatomic, copy, nullable) NSString *agentId;

/**
 * @brief Create a configuration using provider defaults
 * @chinese 创建使用 Provider 默认值的配置
 *
 * @return
 * EN: A new configuration whose `agentId` is nil
 * CN: `agentId` 为 nil 的新配置对象
 */
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
