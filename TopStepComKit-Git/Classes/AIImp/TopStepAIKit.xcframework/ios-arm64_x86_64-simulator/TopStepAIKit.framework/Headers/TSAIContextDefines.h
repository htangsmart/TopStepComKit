//
//  TSAIContextDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI provider product type
 * @chinese AI Provider 产品类型
 */
typedef NS_ENUM(NSUInteger, TSAIProviderType) {
    TSAIProviderTypeUnknown = 0,
    TSAIProviderTypeAIBuds,
    TSAIProviderTypeAliAI,
};

/**
 * @brief AI Context lifecycle state
 * @chinese AI Context 生命周期状态
 */
typedef NS_ENUM(NSInteger, TSAIContextState) {
    TSAIContextStateInactive = 0,
    TSAIContextStateActivating,
    TSAIContextStateActive,
    TSAIContextStateDeactivating,
    TSAIContextStateFailed,
};

/**
 * @brief AI provider authorization state
 * @chinese AI Provider 鉴权状态
 */
typedef NS_ENUM(NSInteger, TSAIAuthorizationState) {
    TSAIAuthorizationStateUnknown = 0,
    TSAIAuthorizationStateDisconnected,
    TSAIAuthorizationStateAuthenticating,
    TSAIAuthorizationStateAuthenticated,
    TSAIAuthorizationStateFailed,
};

/**
 * @brief Fit platform identifier
 * @chinese Fit 平台标识
 */
FOUNDATION_EXPORT NSString * const TSAIPlatformIdentifierFit;

/**
 * @brief NewPlatform platform identifier
 * @chinese NewPlatform 平台标识
 */
FOUNDATION_EXPORT NSString * const TSAIPlatformIdentifierNewPlatform;

/**
 * @brief Persimwear platform identifier
 * @chinese Persimwear 平台标识
 */
FOUNDATION_EXPORT NSString * const TSAIPlatformIdentifierPersimwear;

NS_ASSUME_NONNULL_END
