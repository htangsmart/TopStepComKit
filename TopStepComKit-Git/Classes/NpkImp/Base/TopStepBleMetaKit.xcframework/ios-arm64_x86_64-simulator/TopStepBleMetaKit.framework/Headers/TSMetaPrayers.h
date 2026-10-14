//
//  TSMetaPrayers.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/11/18.
//

#import "TSBusinessBase.h"
#import "PbSettingParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 祈祷配置操作完成回调
 * @chinese 祈祷配置操作完成时的回调
 *
 * @param prayerConfig 祈祷配置数据，成功时不为nil
 *        EN: Prayer configuration data, not nil when successful
 *        CN: 祈祷配置数据，成功时不为nil
 *
 * @param error 错误信息，成功时为nil
 *        EN: Error information, nil when successful
 *        CN: 错误信息，成功时为nil
 */
typedef void(^TSMetaPrayerConfigCompletionBlock)(TMetaPrayerConfig * _Nullable prayerConfig, NSError * _Nullable error);

/**
 * @brief 祈祷配置变化回调
 * @chinese 祈祷配置变化时的回调
 *
 * @param prayerConfig 更新后的祈祷配置数据，发生错误时为nil
 *        EN: Updated prayer configuration data, nil if error occurred
 *        CN: 更新后的祈祷配置数据，发生错误时为nil
 *
 * @param error 错误信息，成功时为nil
 *        EN: Error information, nil when successful
 *        CN: 错误信息，成功时为nil
 */
typedef void(^TSMetaPrayerConfigDidChangedBlock)(TMetaPrayerConfig * _Nullable prayerConfig, NSError * _Nullable error);

@interface TSMetaPrayers : TSBusinessBase

/**
 * @brief 获取祈祷配置信息
 * @chinese 从设备获取当前设置的祈祷配置信息
 *
 * @param completion 完成回调，返回祈祷配置或错误信息
 *        EN: Completion callback with prayer configuration or error information
 *        CN: 完成回调，返回祈祷配置或错误信息
 *
 * @discussion
 * EN: Retrieves the current prayer configuration from the connected device.
 *     The callback will return a TMetaPrayerConfig object containing all prayer settings on success,
 *     or an error on failure.
 * CN: 从已连接的设备获取当前的祈祷配置信息。
 *     成功时回调将返回包含所有祈祷设置的TMetaPrayerConfig对象，失败时返回错误信息。
 */
+ (void)fetchPrayerConfigCompletion:(TSMetaPrayerConfigCompletionBlock _Nullable)completion;

/**
 * @brief 设置祈祷配置信息
 * @chinese 向设备设置祈祷配置信息
 *
 * @param prayerConfig 要设置的祈祷配置
 *        EN: Prayer configuration to be set
 *        CN: 要设置的祈祷配置
 *
 * @param completion 完成回调，返回设置结果或错误信息
 *        EN: Completion callback with setting result or error information
 *        CN: 完成回调，返回设置结果或错误信息
 *
 * @discussion
 * EN: Sets the prayer configuration to the connected device.
 *     The device will replace existing prayer configuration with the provided configuration.
 *     If nil is passed, the device will use default configuration.
 * CN: 向已连接的设备设置祈祷配置信息。
 *     设备将用提供的配置替换现有祈祷配置。
 *     如果传入nil，设备将使用默认配置。
 */
+ (void)pushPrayerConfig:(TMetaPrayerConfig * _Nullable)prayerConfig completion:(TSMetaCompletionBlock _Nullable)completion;

/**
 * @brief 设置祈祷时间数据
 * @chinese 向设备设置祈祷时间数据
 *
 * @param prayerDayList 要设置的祈祷时间数据列表
 *        EN: Prayer time data list to be set
 *        CN: 要设置的祈祷时间数据列表
 *
 * @param completion 完成回调，返回设置结果或错误信息
 *        EN: Completion callback with setting result or error information
 *        CN: 完成回调，返回设置结果或错误信息
 *
 * @discussion
 * EN: Sets the prayer time data to the connected device.
 *     The device will replace existing prayer time data with the provided data.
 *     If nil is passed, the device will use empty data.
 * CN: 向已连接的设备设置祈祷时间数据。
 *     设备将用提供的数据替换现有祈祷时间数据。
 *     如果传入nil，设备将使用空数据。
 */
+ (void)pushPrayerTimes:(TSMetaPrayerDayList * _Nullable)prayerDayList completion:(TSMetaCompletionBlock _Nullable)completion;

/**
 * @brief 注册祈祷配置变化监听
 * @chinese 注册祈祷配置变化监听
 *
 * @param completion 完成回调，当设备上报祈祷配置变化时触发
 *        EN: Callback invoked when device reports prayer configuration changed
 *        CN: 当设备上报祈祷配置变化时触发的回调
 *
 * @discussion
 * EN: Registers a listener for prayer configuration change notifications from the device.
 *     The completion callback will be invoked each time the device reports a prayer configuration change.
 *     The callback provides the updated prayer configuration and any error that occurred.
 *     To stop receiving notifications, call unregisterPrayerConfigDidChanged.
 *
 * CN: 注册设备祈祷配置变化通知的监听器。
 *     每次设备上报祈祷配置变化时，都会调用完成回调。
 *     回调提供更新后的祈祷配置和可能发生的错误。
 *     要停止接收通知，请调用 unregisterPrayerConfigDidChanged。
 *
 * @note
 * EN: Multiple registrations will override previous ones.
 *     Remember to call unregisterPrayerConfigDidChanged when done to avoid memory leaks.
 * CN: 多次注册会覆盖之前的注册。
 *     使用完毕后记得调用 unregisterPrayerConfigDidChanged 以避免内存泄漏。
 */
+ (void)registerPrayerConfigDidChanged:(TSMetaPrayerConfigDidChangedBlock _Nullable)completion;

/**
 * @brief 取消注册祈祷配置变化监听
 * @chinese 取消注册祈祷配置变化监听
 *
 * @discussion
 * EN: Removes the registered prayer configuration change listener.
 *     After calling this method, no more change notifications will be received.
 *
 * CN: 移除已注册的祈祷配置变化监听器。
 *     调用此方法后，将不再接收变化通知。
 *
 * @note
 * EN: If no listener is currently registered, calling this method has no effect.
 * CN: 如果当前没有注册监听器，调用此方法不会有任何效果。
 */
+ (void)unregisterPrayerConfigDidChanged;

@end

NS_ASSUME_NONNULL_END
