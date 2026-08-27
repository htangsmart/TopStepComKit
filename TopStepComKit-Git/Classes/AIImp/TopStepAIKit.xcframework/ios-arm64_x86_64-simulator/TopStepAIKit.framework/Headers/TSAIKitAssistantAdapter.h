//
//  TSAIKitAssistantAdapter.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/30.
//

#import "TSAIAssistantInterface.h"

@class TSAIContext;
@protocol TSAIAssistantProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified AI assistant facade
 * @chinese 统一 AI 助手门面
 */
@interface TSAIKitAssistantAdapter : NSObject <TSAIAssistantInterface>

/**
 * @brief Create an assistant adapter bound to one Context
 * @chinese 创建绑定到指定 Context 的 AI 助手适配器
 *
 * @param context
 * EN: Context that owns this adapter
 * CN: 持有当前适配器的 Context
 *
 * @param assistantProvider
 * EN: Assistant Provider created for the same Context
 * CN: 为同一 Context 创建的 AI 助手 Provider
 *
 * @return
 * EN: A Context-bound assistant adapter
 * CN: 绑定到 Context 的 AI 助手适配器
 */
- (instancetype)initWithContext:(TSAIContext *)context
              assistantProvider:(id<TSAIAssistantProvider>)assistantProvider
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
