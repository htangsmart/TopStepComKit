//
//  TSMetaFemaleHealth.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/11/19.
//

#import "TSBusinessBase.h"
#import "PbConfigParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 女性健康配置操作完成回调
 * @chinese 女性健康配置操作完成时的回调
 *
 * @param femaleHealthConfig 女性健康配置数据，成功时不为nil
 *        EN: Female health configuration data, not nil when successful
 *        CN: 女性健康配置数据，成功时不为nil
 *
 * @param error 错误信息，成功时为nil
 *        EN: Error information, nil when successful
 *        CN: 错误信息，成功时为nil
 */
typedef void(^TSMetaFemaleHealthConfigCompletionBlock)(TSMetaFemaleHealthConfig * _Nullable femaleHealthConfig, NSError * _Nullable error);

/**
 * @brief 女性健康配置变化回调
 * @chinese 女性健康配置变化时的回调
 *
 * @param femaleHealthConfig 更新后的女性健康配置数据，发生错误时为nil
 *        EN: Updated female health configuration data, nil if error occurred
 *        CN: 更新后的女性健康配置数据，发生错误时为nil
 *
 * @param error 错误信息，成功时为nil
 *        EN: Error information, nil when successful
 *        CN: 错误信息，成功时为nil
 */
typedef void(^TSMetaFemaleHealthConfigDidChangedBlock)(TSMetaFemaleHealthConfig * _Nullable femaleHealthConfig, NSError * _Nullable error);

@interface TSMetaFemaleHealth : TSBusinessBase

/**
 * @brief 获取女性健康配置信息
 * @chinese 从设备获取当前设置的女性健康配置信息
 *
 * @param completion 完成回调，返回女性健康配置或错误信息
 *        EN: Completion callback with female health configuration or error information
 *        CN: 完成回调，返回女性健康配置或错误信息
 *
 * @discussion
 * EN: Retrieves the current female health configuration from the connected device.
 *     The callback will return a TSMetaFemaleHealthConfig object containing all female health settings on success,
 *     or an error on failure.
 * CN: 从已连接的设备获取当前的女性健康配置信息。
 *     成功时回调将返回包含所有女性健康设置的TSMetaFemaleHealthConfig对象，失败时返回错误信息。
 */
+ (void)fetchFemaleHealthConfigCompletion:(TSMetaFemaleHealthConfigCompletionBlock _Nullable)completion;

/**
 * @brief 设置女性健康配置信息
 * @chinese 向设备设置女性健康配置信息
 *
 * @param femaleHealthConfig 要设置的女性健康配置
 *        EN: Female health configuration to be set
 *        CN: 要设置的女性健康配置
 *
 * @param completion 完成回调，返回设置结果或错误信息
 *        EN: Completion callback with setting result or error information
 *        CN: 完成回调，返回设置结果或错误信息
 *
 * @discussion
 * EN: Sets the female health configuration to the connected device.
 *     The device will replace existing female health configuration with the provided configuration.
 *     If nil is passed, the device will use default configuration.
 * CN: 向已连接的设备设置女性健康配置信息。
 *     设备将用提供的配置替换现有女性健康配置。
 *     如果传入nil，设备将使用默认配置。
 */
+ (void)pushFemaleHealthConfig:(TSMetaFemaleHealthConfig * _Nullable)femaleHealthConfig completion:(TSMetaCompletionBlock _Nullable)completion;

/**
 * @brief 注册女性健康配置变化监听
 * @chinese 注册女性健康配置变化监听
 *
 * @param completion 完成回调，当设备上报女性健康配置变化时触发
 *        EN: Callback invoked when device reports female health configuration changed
 *        CN: 当设备上报女性健康配置变化时触发的回调
 *
 * @discussion
 * EN: Registers a listener for female health configuration change notifications from the device.
 *     The completion callback will be invoked each time the device reports a female health configuration change.
 *     The callback provides the updated female health configuration and any error that occurred.
 *     To stop receiving notifications, call unregisterFemaleHealthConfigDidChanged.
 *
 * CN: 注册设备女性健康配置变化通知的监听器。
 *     每次设备上报女性健康配置变化时，都会调用完成回调。
 *     回调提供更新后的女性健康配置和可能发生的错误。
 *     要停止接收通知，请调用 unregisterFemaleHealthConfigDidChanged。
 *
 * @note
 * EN: Multiple registrations will override previous ones.
 *     Remember to call unregisterFemaleHealthConfigDidChanged when done to avoid memory leaks.
 * CN: 多次注册会覆盖之前的注册。
 *     使用完毕后记得调用 unregisterFemaleHealthConfigDidChanged 以避免内存泄漏。
 */
+ (void)registerFemaleHealthConfigDidChanged:(TSMetaFemaleHealthConfigDidChangedBlock _Nullable)completion;

/**
 * @brief 取消注册女性健康配置变化监听
 * @chinese 取消注册女性健康配置变化监听
 *
 * @discussion
 * EN: Removes the registered female health configuration change listener.
 *     After calling this method, no more change notifications will be received.
 *
 * CN: 移除已注册的女性健康配置变化监听器。
 *     调用此方法后，将不再接收变化通知。
 *
 * @note
 * EN: If no listener is currently registered, calling this method has no effect.
 * CN: 如果当前没有注册监听器，调用此方法不会有任何效果。
 */
+ (void)unregisterFemaleHealthConfigDidChanged;

@end

NS_ASSUME_NONNULL_END
