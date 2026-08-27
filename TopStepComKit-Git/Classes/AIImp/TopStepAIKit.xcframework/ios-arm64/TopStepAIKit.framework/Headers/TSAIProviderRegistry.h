//
//  TSAIProviderRegistry.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIContextDefines.h"
#import "TSAIProvider.h"

NS_ASSUME_NONNULL_BEGIN

typedef id<TSAIProvider> _Nonnull (^TSAIProviderFactory)(void);

/**
 * @brief Thread-safe registry of AI provider factories
 * @chinese AI Provider 工厂的线程安全注册中心
 */
@interface TSAIProviderRegistry : NSObject

/**
 * @brief Return the process-wide provider registry
 * @chinese 返回进程内共享的 Provider 注册中心
 * @return EN: Shared registry. CN: 共享注册中心。
 */
+ (instancetype)sharedRegistry;

/**
 * @brief Register a factory for a provider product type
 * @chinese 为 Provider 产品类型注册工厂
 * @param factory EN: Factory creating a fresh provider. CN: 创建全新 Provider 的工厂。
 * @param providerType EN: Provider product type. CN: Provider 产品类型。
 */
- (void)registerFactory:(TSAIProviderFactory)factory
        forProviderType:(TSAIProviderType)providerType;

/**
 * @brief Create a provider for the requested product type
 * @chinese 为指定产品类型创建 Provider
 * @param providerType EN: Provider product type. CN: Provider 产品类型。
 * @return EN: A fresh provider, or nil if unregistered. CN: 全新 Provider；未注册时为 nil。
 */
- (nullable id<TSAIProvider>)createProviderForType:(TSAIProviderType)providerType;

@end

NS_ASSUME_NONNULL_END
