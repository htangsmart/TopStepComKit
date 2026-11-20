//
//  TSAIContext+AIBudsAuthentication.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/8.
//

#import "TSAIContext.h"
#import "TSAIContractDefines.h"

@import AIBudsAIFoundation;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AIBuds authentication operations for an AI Context
 * @chinese AI Context 的 AIBuds 鉴权操作
 */
@interface TSAIContext (AIBudsAuthentication)

/**
 * @brief Authenticate the AIBuds AI service with device information when required
 * @chinese 使用设备信息按需鉴权 AIBuds AI 服务
 *
 * @discussion
 * [EN]: Kept for existing hosts. New code should use `-[TSAIContext authenticateDeviceWithInfo:completion:]`
 *       (TSAIContext+DeviceAuthentication.h), which needs no vendor module.
 * [CN]: 为已有宿主保留。新代码请使用 TSAIContext+DeviceAuthentication.h 的
 *       `authenticateDeviceWithInfo:completion:`，无需引入厂商模块。
 *
 * @param deviceInfo
 * EN: AIBuds AI device information
 * CN: AIBuds AI 设备信息
 *
 * @param completion
 * EN: Completion called asynchronously on the main thread after the authentication check finishes
 * CN: 鉴权检查完成后在主线程异步调用的回调
 */
- (void)authenticateWithDeviceInfo:(AIBudsAIDeviceInfoModel *)deviceInfo
                        completion:(nullable TSAICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
