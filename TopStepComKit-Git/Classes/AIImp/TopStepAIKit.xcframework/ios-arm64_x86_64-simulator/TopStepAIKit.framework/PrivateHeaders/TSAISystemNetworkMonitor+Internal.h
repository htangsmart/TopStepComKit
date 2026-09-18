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
 * @brief Return the shared monitor; observation starts on the first subscriber
 * @chinese 返回共享监听器，在第一个订阅者加入时启动监听
 * @return EN: Shared path source. CN: 共享路径来源。
 */
+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
