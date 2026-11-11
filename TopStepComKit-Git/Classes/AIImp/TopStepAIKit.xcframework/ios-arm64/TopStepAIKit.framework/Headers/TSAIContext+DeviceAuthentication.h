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
 *     Provider has no device-level authentication, and with InvalidParameter when the
 *     information cannot be mapped (for example an unknown product kind).
 * CN: 在主线程异步回调。当前 Provider 没有设备级鉴权时返回 NotSupported；
 *     信息无法映射（如产品类型未知）时返回 InvalidParameter。
 *
 * @discussion
 * [EN]: Replaces the vendor-typed `authenticateWithDeviceInfo:`; the host needs no vendor module.
 * [CN]: 取代带厂商类型的 `authenticateWithDeviceInfo:`，宿主无需引入厂商模块。
 */
- (void)authenticateDeviceWithInfo:(TSAIDeviceAuthenticationInfo *)info
                        completion:(nullable TSAICompletionBlock)completion
    NS_SWIFT_NAME(authenticateDevice(info:completion:));

@end

NS_ASSUME_NONNULL_END
