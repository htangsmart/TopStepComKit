//
//  TSAIKit.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/30.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
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

/**
 * @brief Current microphone permission
 * @chinese 当前麦克风权限
 */
+ (TSAIMicrophonePermissionStatus)microphonePermissionStatus;

/**
 * @brief Request microphone permission (phone and earbuds microphones)
 * @chinese 请求麦克风权限（手机麦与耳机麦共用）
 *
 * @param completion
 * EN: Called on the main queue with the resulting permission. Earbuds microphone statuses
 *     are re-posted afterwards.
 * CN: 在主线程回调结果权限；之后会重新发出耳机麦克风状态通知。
 *
 * @discussion
 * EN: Request it before starting any SDK microphone feature; a session started without
 *     permission fails with 1021 instead of prompting.
 * CN: 在启动任何 SDK 麦克风功能之前请求；未授权时启动会话会以 1021 失败，而不是弹出系统询问。
 */
+ (void)requestMicrophonePermissionWithCompletion:
    (nullable void (^)(TSAIMicrophonePermissionStatus status))completion;

@end

NS_ASSUME_NONNULL_END
