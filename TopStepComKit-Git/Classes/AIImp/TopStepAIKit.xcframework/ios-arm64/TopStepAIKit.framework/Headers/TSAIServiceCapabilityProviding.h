//
//  TSAIServiceCapabilityProviding.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Reports atomic capabilities supplied by an AI service Provider
 * @chinese 报告 AI 服务 Provider 提供的原子能力
 *
 * @discussion
 * [EN]: Implementations must not inspect device capability or runtime state.
 * [CN]: 实现不得读取设备能力或运行时状态。
 */
@protocol TSAIServiceCapabilityProviding <NSObject>

/** @brief Atomic AI service capabilities supplied by the Provider @chinese Provider 提供的 AI 服务原子能力 */
@property (nonatomic, assign, readonly) TSAIServiceCapabilityOptions supportedAIServiceCapabilities;

/**
 * @brief Return whether every requested AI service capability is supported
 * @chinese 返回是否支持全部指定的 AI 服务能力
 *
 * @param capabilities
 * EN: One or more atomic AI service capabilities
 * CN: 一个或多个 AI 服务原子能力
 *
 * @return
 * EN: Supported only for a non-empty, known and fully supported set
 * CN: 仅非空、全部已知且全部受支持时返回 Supported
 */
- (TSAICapabilitySupport)supportForAIServiceCapabilities:(TSAIServiceCapabilityOptions)capabilities;

@end

NS_ASSUME_NONNULL_END
