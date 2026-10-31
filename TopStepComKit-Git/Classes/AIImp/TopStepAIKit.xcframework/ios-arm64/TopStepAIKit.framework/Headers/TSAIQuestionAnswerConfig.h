//
//  TSAIQuestionAnswerConfig.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/13.
//

#import <Foundation/Foundation.h>
#import "TSAIQuestionAnswerAgent.h"

@class TSAIAudioRouteConfiguration;
@class TSAIStartRequest;

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
 * @brief Original request expected by a device-voice preparation
 * @chinese 设备语音准备所期望的原请求对象
 *
 * @discussion
 * [EN]: Request-scoped device bridges validate object identity. An asynchronous App prepare handler
 *       must set this to the immutable request supplied to that handler before starting device question answering.
 * [CN]: 使用精确请求的设备桥校验对象身份；异步App准备处理器须在启动设备问答前，将此属性设置为
 *       该处理器收到的原不可变请求对象。
 *
 * @note
 * [EN]: Defaults to nil. A synchronous prepare handler may omit it; text-only tasks and legacy bridges ignore it.
 * [CN]: 默认nil；同步准备处理器可省略，纯文本任务和旧设备桥忽略此值。
 */
@property (nonatomic, strong, nullable) TSAIStartRequest *expectedDeviceRequest;

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
 * @brief AI agent used to answer the question
 * @chinese 回答问题使用的智能体
 *
 * @discussion
 * [EN]: Defaults to Unspecified, which lets the active AI service choose its
 *       default agent. For a device-initiated session, a non-Unspecified agent
 *       selected on the device takes precedence over this value.
 * [CN]: 默认 Unspecified，由当前 AI 服务选择默认智能体。设备发起的问答中，
 *       设备已选择的智能体（非 Unspecified）优先于此值。
 */
@property (nonatomic, assign) TSAIQuestionAnswerAgent agent;

/**
 * @brief Create a configuration using provider defaults
 * @chinese 创建使用 Provider 默认值的配置
 *
 * @return
 * EN: A new configuration whose `agent` is Unspecified
 * CN: `agent` 为 Unspecified 的新配置对象
 */
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
