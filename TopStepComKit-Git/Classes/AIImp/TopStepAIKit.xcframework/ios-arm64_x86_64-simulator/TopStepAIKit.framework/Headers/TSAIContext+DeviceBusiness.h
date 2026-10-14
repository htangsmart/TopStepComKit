//
//  TSAIContext+DeviceBusiness.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/10/12.
//

#import <Foundation/Foundation.h>

#import "TSAIContext.h"
#import "TSAIDeviceAISessionInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Session handler routes owned by the SDK device business layer
 * @chinese SDK 设备业务层所有的会话处理器路由
 *
 * @discussion
 * [EN]: For `TSAIDeviceBusinessLifecycle` implementers (device bridges) only.
 *       Register inside `bindBusinessServicesToContext:` and unregister inside
 *       `unbindBusinessServicesFromContext:`. Only SDK-owned use cases
 *       (`TSAIDeviceSessionRouteOwnerSDK`) are accepted; the App cannot replace
 *       or remove these routes through `TSAIDeviceAISessionInterface`. An SDK
 *       session override installed by a coordinator still takes precedence
 *       while it is active.
 * [CN]: 仅供 `TSAIDeviceBusinessLifecycle` 实现方（设备桥接）使用。在
 *       `bindBusinessServicesToContext:` 中注册、在
 *       `unbindBusinessServicesFromContext:` 中注销。只接受 SDK 自有用例
 *       （`TSAIDeviceSessionRouteOwnerSDK`）；App 无法通过
 *       `TSAIDeviceAISessionInterface` 替换或移除这些路由。协调器安装的 SDK 会话
 *       覆盖层在其活动期间仍优先。
 */
@interface TSAIContext (DeviceBusiness)

/**
 * @brief Register the SDK route for one SDK-owned device session use case
 * @chinese 注册一个 SDK 自有设备会话用例的 SDK 路由
 *
 * @param useCase
 * EN: Voice translation or watch face
 * CN: 语音翻译或表盘用例
 *
 * @param prepareHandler
 * EN: Local preparation handler; required
 * CN: 本地准备处理器；必填
 *
 * @param activationHandler
 * EN: Called only after both sides are ready; required
 * CN: 仅双端均就绪后调用；必填
 *
 * @param inputCompletionHandler
 * EN: Called after natural voice-input completion; required
 * CN: 语音输入自然结束后调用；必填
 *
 * @param terminationHandler
 * EN: Idempotent local rollback/end handler; required
 * CN: 幂等的本地回滚/结束处理器；必填
 *
 * @param voiceDataHandler
 * EN: Voice-data consumer; required for WatchFace with Opus input
 * CN: 语音数据消费者；WatchFace 使用 Opus 输入时必填
 *
 * @param requiresBusinessCompletion
 * EN: Whether the business reservation is retained after input completes
 * CN: 输入完成后是否保留业务占位
 *
 * @return
 * EN: YES when registered; NO when the use case is not SDK-owned or a required handler is nil
 * CN: 已注册返回 YES；用例不属于 SDK 或必填处理器为 nil 返回 NO
 */
- (BOOL)registerDeviceBusinessSessionHandlerForUseCase:(TSAIUseCase)useCase
                                        prepareHandler:(TSAIDeviceAISessionPrepareHandler)prepareHandler
                                     activationHandler:(TSAIDeviceAISessionActivationHandler)activationHandler
                                inputCompletionHandler:(TSAIDeviceAISessionInputCompletionHandler)inputCompletionHandler
                                    terminationHandler:(TSAIDeviceAISessionTerminationHandler)terminationHandler
                                      voiceDataHandler:(nullable TSAIDeviceAISessionVoiceDataHandler)voiceDataHandler
                            requiresBusinessCompletion:(BOOL)requiresBusinessCompletion;

/**
 * @brief Unregister the SDK route for one SDK-owned device session use case
 * @chinese 注销一个 SDK 自有设备会话用例的 SDK 路由
 *
 * @param useCase
 * EN: Voice translation or watch face; other use cases are ignored
 * CN: 语音翻译或表盘用例；其他用例忽略
 */
- (void)unregisterDeviceBusinessSessionHandlerForUseCase:(TSAIUseCase)useCase;

@end

NS_ASSUME_NONNULL_END
