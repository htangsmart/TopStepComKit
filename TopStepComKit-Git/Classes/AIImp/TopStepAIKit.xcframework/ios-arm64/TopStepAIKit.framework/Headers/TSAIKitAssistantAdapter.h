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

/**
 * @brief Append decoded input to the task belonging to an exact device request
 * @chinese 将解码输入交付给精确设备请求所属的任务
 * @param pcmData
 * EN: Incremental PCM input.
 * CN: 增量 PCM 输入。
 * @param request
 * EN: Original immutable owning request object.
 * CN: 原始不可变所属请求对象。
 * @return
 * EN: Whether input was accepted.
 * CN: 是否接受该输入。
 */
- (BOOL)appendDevicePCMData:(NSData *)pcmData request:(TSAIStartRequest *)request;

/**
 * @brief Finish an exact device request's input once and keep its answer active
 * @chinese 仅结束一次精确设备请求的输入并保留回答阶段
 * @param request
 * EN: Original immutable owning request object.
 * CN: 原始不可变所属请求对象。
 * @return
 * EN: Whether this call finished the input.
 * CN: 本次是否结束了输入。
 */
- (BOOL)finishDeviceInputForRequest:(TSAIStartRequest *)request;

/**
 * @brief Stop only the Provider task belonging to an ended device request
 * @chinese 仅停止已结束设备请求所属的 Provider 任务
 * @param request
 * EN: Original immutable ended request object.
 * CN: 原始不可变已结束请求对象。
 * @param error
 * EN: Terminal failure, if any.
 * CN: 可选的终止错误。
 */
- (void)endDeviceChatForRequest:(TSAIStartRequest *)request error:(nullable NSError *)error;

+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
