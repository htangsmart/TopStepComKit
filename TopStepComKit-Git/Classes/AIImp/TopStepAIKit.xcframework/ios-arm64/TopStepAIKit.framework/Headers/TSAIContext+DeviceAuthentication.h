//
//  TSAIContext+DeviceAuthentication.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/11/9.
//

#import <Foundation/Foundation.h>

#import "TSAIContext.h"
#import "TSAIContractDefines.h"
#import "TSAIDeviceAuthenticationInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Provider-neutral device authentication for an AI Context
 * @chinese AI Context 与 Provider 无关的设备鉴权
 */
@interface TSAIContext (DeviceAuthentication)

/**
 * @brief Authenticate the active Provider's AI service with device information
 * @chinese 使用设备信息鉴权当前 Provider 的 AI 服务
 *
 * @param info
 * EN: Device information read from TopStepComKit after connection
 * CN: 连接成功后从 TopStepComKit 读取的设备信息
 *
 * @param completion
 * EN: Called asynchronously on the main thread. Fails with NotSupported when the active
 *     Provider does not implement device authentication, and with InvalidParameter when
 *     the information is invalid for that Provider.
 * CN: 在主线程异步回调。当前 Provider 未实现设备鉴权时返回 NotSupported，
 *     设备信息不符合当前 Provider 要求时返回 InvalidParameter。
 *
 * @discussion
 * [EN]: Call after activating the Context. AIBuds may report success when device-initiated
 *       authentication is prepared. WoQi confirms the authorization obtained during activation
 *       for the current device and verifies the MAC when supplied. Use authorizationState
 *       to determine final authorization.
 * [CN]: 激活 Context 后调用。AIBuds 的设备发起模式可在准备完成时回调成功。
 *       WoQi 确认当前设备在激活时获得的授权，并校验宿主提供的 MAC。最终鉴权状态以
 *       authorizationState 为准。
 */
- (void)authenticateDeviceWithInfo:(TSAIDeviceAuthenticationInfo *)info
                        completion:(nullable TSAICompletionBlock)completion
    NS_SWIFT_NAME(authenticateDevice(info:completion:));

@end

NS_ASSUME_NONNULL_END
