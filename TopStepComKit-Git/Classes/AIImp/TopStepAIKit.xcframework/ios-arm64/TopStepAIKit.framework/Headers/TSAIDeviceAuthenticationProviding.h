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
 * [EN]: Providers that authenticate with device information adopt this protocol and convert
 *       the neutral information into their vendor model. Providers without device-level
 *       authentication do not adopt it.
 * [CN]: 需要设备信息鉴权的 Provider 实现本协议，并自行把中立信息转换为厂商模型；
 *       没有设备级鉴权的 Provider 不实现。
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
