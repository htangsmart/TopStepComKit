//
//  TSAIDeviceBridgeRegistry.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIDeviceBridge.h"

NS_ASSUME_NONNULL_BEGIN

typedef id<TSAIDeviceBridge> _Nonnull (^TSAIDeviceBridgeFactory)(void);

/**
 * @brief Thread-safe registry of platform DeviceBridge factories
 * @chinese 平台 DeviceBridge 工厂的线程安全注册中心
 */
@interface TSAIDeviceBridgeRegistry : NSObject

/**
 * @brief Return the process-wide DeviceBridge registry
 * @chinese 返回进程内共享的 DeviceBridge 注册中心
 * @return EN: Shared registry. CN: 共享注册中心。
 */
+ (instancetype)sharedRegistry;

/**
 * @brief Register a factory for a platform identifier
 * @chinese 为平台标识注册工厂
 * @param factory EN: Factory creating a fresh bridge. CN: 创建全新 Bridge 的工厂。
 * @param platformIdentifier EN: Stable platform identifier. CN: 稳定的平台标识。
 */
- (void)registerFactory:(TSAIDeviceBridgeFactory)factory
  forPlatformIdentifier:(NSString *)platformIdentifier;

/**
 * @brief Create a DeviceBridge for a platform identifier
 * @chinese 为平台标识创建 DeviceBridge
 * @param platformIdentifier EN: Stable platform identifier. CN: 稳定的平台标识。
 * @return EN: A fresh bridge, or nil if unregistered. CN: 全新 Bridge；未注册时为 nil。
 */
- (nullable id<TSAIDeviceBridge>)createDeviceBridgeForPlatformIdentifier:(NSString *)platformIdentifier;

@end

NS_ASSUME_NONNULL_END
