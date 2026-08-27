//
//  TSAIContextConfiguration.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIContextDefines.h"

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

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
