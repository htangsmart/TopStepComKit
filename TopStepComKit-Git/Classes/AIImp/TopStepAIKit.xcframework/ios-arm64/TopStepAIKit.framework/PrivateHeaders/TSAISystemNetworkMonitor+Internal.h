//
//  TSAISystemNetworkMonitor+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/15.
//

#import <Foundation/Foundation.h>

#import "TSAINetworkStatusProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Default process-shared Network.framework path source
 * @chinese 默认进程共享的 Network.framework 路径来源
 */
@interface TSAISystemNetworkMonitor : NSObject <TSAINetworkStatusProvider>

/**
 * @brief Return the shared monitor; system observation starts as soon as it is created
 * @chinese 返回共享监听器；创建后立即启动系统监听，不依赖首个订阅者
 * @discussion
 * EN: The monitor never stops once started, so `currentStatus` keeps the latest
 *     path snapshot even while no observer is registered. Callers that read
 *     `currentStatus` synchronously before subscribing therefore see a real
 *     status shortly after launch instead of a permanent Unknown.
 * CN: 监听一旦启动就不再停止，因此即使没有任何订阅者，`currentStatus` 也始终保留
 *     最新路径快照；在订阅之前同步读取 `currentStatus` 的调用方，启动后不久即可
 *     得到真实状态，而不是永远的 Unknown。
 * @return EN: Shared path source. CN: 共享路径来源。
 */
+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
