//
//  TSAIContextConfiguration.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIContextDefines.h"

@protocol TSAINetworkStatusProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Configuration for creating one AI Context
 * @chinese 创建一个 AI Context 的配置
 */
@interface TSAIContextConfiguration : NSObject

/**
 * @brief Platform identifier used to locate a DeviceBridge
 * @chinese 用于查找 DeviceBridge 的平台标识
 */
@property (nonatomic, copy, readonly) NSString *platformIdentifier;

/**
 * @brief Provider product selected for this Context
 * @chinese 当前 Context 选择的 Provider 产品
 */
@property (nonatomic, assign, readonly) TSAIProviderType providerType;

/**
 * @brief Provider-specific initialization configuration
 * @chinese Provider 专属初始化配置
 */
@property (nonatomic, strong, readonly, nullable) id providerConfiguration;

/**
 * @brief Network status source resolved when the configuration is created
 * @chinese 创建配置时确定的网络状态来源
 * @discussion
 * EN: Uses the SDK shared monitor when no source is injected. Each Context owns
 *     only its observation; removing it must not stop another Context's updates.
 * CN: 未注入时使用 SDK 共享监听器。每个 Context 仅管理自身订阅，移除时不影响其他 Context。
 */
@property (nonatomic, strong, readonly) id<TSAINetworkStatusProvider> networkStatusProvider;

/**
 * @brief Create a Context configuration
 * @chinese 创建 Context 配置
 *
 * @param platformIdentifier
 * EN: Stable platform identifier
 * CN: 稳定的平台标识
 *
 * @param providerType
 * EN: Selected AI provider product
 * CN: 选择的 AI Provider 产品
 *
 * @param providerConfiguration
 * EN: Provider-specific configuration, or nil when not required
 * CN: Provider 专属配置，不需要时为 nil
 *
 * @return
 * EN: A new Context configuration
 * CN: 新的 Context 配置
 */
+ (instancetype)configurationWithPlatformIdentifier:(NSString *)platformIdentifier
                                       providerType:(TSAIProviderType)providerType
                              providerConfiguration:(nullable id)providerConfiguration;

/**
 * @brief Create a Context configuration with an optional network source
 * @chinese 使用可选网络来源创建 Context 配置
 * @param platformIdentifier EN: Stable platform identifier. CN: 稳定的平台标识。
 * @param providerType EN: Selected AI provider product. CN: 选择的 AI Provider 产品。
 * @param providerConfiguration EN: Provider-specific configuration. CN: Provider 专属配置。
 * @param networkStatusProvider
 * EN: Replacement network source; nil selects the SDK shared monitor.
 * CN: 替代的网络来源，nil 表示使用 SDK 共享监听器。
 * @return EN: A new Context configuration. CN: 新的 Context 配置。
 */
+ (instancetype)configurationWithPlatformIdentifier:(NSString *)platformIdentifier
                                       providerType:(TSAIProviderType)providerType
                              providerConfiguration:(nullable id)providerConfiguration
                              networkStatusProvider:(nullable id<TSAINetworkStatusProvider>)networkStatusProvider;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
