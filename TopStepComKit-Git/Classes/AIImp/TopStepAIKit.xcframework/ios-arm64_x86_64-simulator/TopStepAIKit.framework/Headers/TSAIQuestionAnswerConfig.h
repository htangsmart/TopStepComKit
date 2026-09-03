//
//  TSAIQuestionAnswerConfig.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/13.
//

#import <Foundation/Foundation.h>

@class TSAIAudioRouteConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Configuration for AI question-answer tasks and voice sessions
 * @chinese AI 问答任务与语音会话配置
 *
 * @discussion
 * [EN]: Text and device-voice question answering share business options.
 *       The route is consumed only by the device-voice start entry.
 * [CN]: 文本问答与设备语音问答共用业务配置；音频路由仅由
 *       设备语音问答的 start 入口消费。
 */
@interface TSAIQuestionAnswerConfig : NSObject <NSCopying>

/**
 * @brief Audio route used by a device-voice question-answer session
 * @chinese 设备语音问答会话使用的音频路由
 *
 * @discussion
 * [EN]: `askQuestion:config:` remains text-only and never activates this route.
 * [CN]: `askQuestion:config:` 仍为纯文本入口，不会激活此路由。
 */
@property (nonatomic, copy, nullable) TSAIAudioRouteConfiguration *audioRouteConfiguration;

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
