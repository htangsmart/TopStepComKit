//
//  TSAIAudioRouteConfiguration.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable input and output route requested for one AI session
 * @chinese 单次 AI 会话请求的不可变输入输出路由
 */
@interface TSAIAudioRouteConfiguration : NSObject <NSCopying>

/** @brief Requested input channel @chinese 请求的输入通道 */
@property (nonatomic, assign, readonly) TSAIAudioInputChannel inputChannel;

/** @brief Requested output channel @chinese 请求的输出通道 */
@property (nonatomic, assign, readonly) TSAIAudioOutputChannel outputChannel;

/** @brief Policy used when the complete route is unavailable @chinese 完整路由不可用时采用的策略 */
@property (nonatomic, assign, readonly) TSAIAudioRouteUnavailablePolicy routeUnavailablePolicy;

/**
 * @brief Create an immutable route configuration
 * @chinese 创建不可变音频路由配置
 * @param inputChannel EN: Requested input channel. CN: 请求的输入通道。
 * @param outputChannel EN: Requested output channel. CN: 请求的输出通道。
 * @param policy EN: Unavailable-route policy. CN: 路由不可用策略。
 * @return EN: A new immutable configuration. CN: 新的不可变配置对象。
 */
+ (instancetype)configurationWithInputChannel:(TSAIAudioInputChannel)inputChannel
                                outputChannel:(TSAIAudioOutputChannel)outputChannel
                       routeUnavailablePolicy:(TSAIAudioRouteUnavailablePolicy)policy;

/**
 * @brief Create the backward-compatible automatic route
 * @chinese 创建兼容旧行为的自动路由
 * @return EN: Automatic/Automatic with UseAutomaticRoute. CN: 使用自动重选策略的自动输入输出路由。
 */
+ (instancetype)defaultConfiguration;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
