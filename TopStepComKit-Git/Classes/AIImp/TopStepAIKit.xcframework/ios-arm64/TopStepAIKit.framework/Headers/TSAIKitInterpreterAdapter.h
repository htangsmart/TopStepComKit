//
//  TSAIKitInterpreterAdapter.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/30.
//

#import "TSAIInterpreterInterface.h"

@class TSAIContext;
@protocol TSAIInterpreterProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified simultaneous interpretation facade
 * @chinese 统一同声传译门面
 */
@interface TSAIKitInterpreterAdapter : NSObject <TSAIInterpreterInterface>

/**
 * @brief Create an interpreter adapter bound to one Context
 * @chinese 创建绑定到指定 Context 的同声传译适配器
 *
 * @param context
 * EN: Context that owns this adapter
 * CN: 持有当前适配器的 Context
 *
 * @param interpreterProvider
 * EN: Interpreter Provider created for the same Context
 * CN: 为同一 Context 创建的同声传译 Provider
 *
 * @return
 * EN: A Context-bound interpreter adapter
 * CN: 绑定到 Context 的同声传译适配器
 */
- (instancetype)initWithContext:(TSAIContext *)context
            interpreterProvider:(id<TSAIInterpreterProvider>)interpreterProvider
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
