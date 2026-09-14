//
//  TSAIKitAssistantAdapter.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/30.
//

#import "TSAIAssistantInterface.h"

@class TSAIContext;
@class TSAIStartRequest;
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
/**
 * @brief Cancel local preparation after the orchestrator claims cancellation
 * @chinese 编排器取得取消权后回滚本地准备资源
 * @param request EN: Exact request. CN: 精确请求。
 * @param failure EN: Cancellation reason. CN: 取消原因。
 * @param completion EN: Local rollback result. CN: 本地回滚结果。
 */
- (void)cancelPreparationForRequest:(TSAIStartRequest *)request
                            failure:(NSError *)failure
                         completion:(TSAICompletionBlock)completion;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
