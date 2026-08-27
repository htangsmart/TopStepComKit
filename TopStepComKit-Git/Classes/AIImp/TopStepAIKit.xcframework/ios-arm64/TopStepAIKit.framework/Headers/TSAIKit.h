//
//  TSAIKit.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/30.
//

#import <Foundation/Foundation.h>

#import "TSAIContractDefines.h"

@class TSAIContext;
@class TSAIContextConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified AI SDK Context facade
 * @chinese 统一的 AI SDK Context 门面
 */
@interface TSAIKit : NSObject

/**
 * @brief Currently active AI Context
 * @chinese 当前激活的 AI Context
 */
@property (atomic, strong, readonly, nullable) TSAIContext *activeContext;

/**
 * @brief Shared AI SDK facade
 * @chinese 共享 AI SDK 门面
 *
 * @return
 * EN: The process-wide AI SDK facade
 * CN: 进程内共享的 AI SDK 门面
 */
+ (instancetype)sharedInstance;

/**
 * @brief Activate a Context for the given configuration
 * @chinese 按配置激活一个 Context
 *
 * @param configuration
 * EN: Context configuration
 * CN: Context 配置
 *
 * @param completion
 * EN: Completion called after activation finishes
 * CN: 激活完成后的回调
 */
- (void)activateContextWithConfiguration:(TSAIContextConfiguration *)configuration
                              completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Deactivate the currently active Context
 * @chinese 停用当前激活的 Context
 *
 * @param completion
 * EN: Completion called after deactivation finishes
 * CN: 停用完成后的回调
 */
- (void)deactivateActiveContextWithCompletion:(nullable TSAICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
