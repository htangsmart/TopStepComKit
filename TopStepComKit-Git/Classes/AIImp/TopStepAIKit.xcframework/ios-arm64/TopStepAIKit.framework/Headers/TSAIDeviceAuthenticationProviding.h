//
//  TSAIDeviceAuthenticationProviding.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/11/9.
//

#import <Foundation/Foundation.h>

#import "TSAIContractDefines.h"

@class TSAIDeviceAuthenticationInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Optional root Provider capability: device-level AI service authentication
 * @chinese 根 Provider 的可选能力：设备级 AI 服务鉴权
 *
 * @discussion
 * [EN]: Providers use device information to perform authentication or confirm authorization
 *       already obtained for the current device during activation.
 * [CN]: Provider 使用设备信息执行鉴权，或确认当前设备在激活时已获得的授权。
 */
@protocol TSAIDeviceAuthenticationProviding <NSObject>

/**
 * @brief Authenticate the AI service with neutral device information
 * @chinese 使用中立设备信息鉴权 AI 服务
 *
 * @param info
 * EN: Device information from the host
 * CN: 宿主提供的设备信息
 *
 * @param completion
 * EN: Called once on any queue; the Context forwards it to the main queue
 * CN: 在任意队列回调一次；由 Context 转到主线程
 */
- (void)authenticateDeviceWithInfo:(TSAIDeviceAuthenticationInfo *)info
                        completion:(nullable TSAICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
