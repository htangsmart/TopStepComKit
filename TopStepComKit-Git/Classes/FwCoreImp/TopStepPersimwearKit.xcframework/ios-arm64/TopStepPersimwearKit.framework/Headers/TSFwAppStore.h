//
//  TSFwAppStore.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/12/12.
//

#import "TSFwKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 应用商店管理类（单例模式）
 * @chinese 应用商店管理类（单例模式）
 */
@interface TSFwAppStore : TSFwKitBase<TSAppStoreInterface>

/**
 * @brief 快速获取单例实例
 * @chinese 快速获取单例实例
 *
 * @return TSFwAppStore 单例实例
 *
 * @discussion
 * [EN]: Returns the singleton instance of TSFwAppStore.
 *       This is the recommended way to get the instance.
 *       All calls to `init` or `alloc` will also return the same instance.
 * [CN]: 返回 TSFwAppStore 的单例实例。
 *       这是推荐的获取实例的方式。
 *       所有对 `init` 或 `alloc` 的调用也会返回同一个实例。
 *
 * @code
 * // 推荐使用方式
 * TSFwAppStore *appStore = [TSFwAppStore sharedInstance];
 *
 * // 以下方式也会返回同一个实例
 * TSFwAppStore *appStore2 = [[TSFwAppStore alloc] init];
 * @endcode
 */
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
