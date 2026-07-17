//
//  TSFemaleHealthInterface.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/11/19.
//

#import "TSKitBaseInterface.h"
#import "TSFemaleHealthConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Female health configuration change callback block type
 * @chinese 女性健康配置变化回调块类型
 *
 * @param femaleHealthConfig
 * EN: Updated female health configuration model, nil if error occurred
 * CN: 更新后的女性健康配置模型，发生错误时为nil
 *
 * @param error
 * EN: Error information, nil when successful
 * CN: 错误信息，成功时为nil
 */
typedef void(^TSFemaleHealthConfigDidChangedBlock)(TSFemaleHealthConfig * _Nullable femaleHealthConfig, NSError * _Nullable error);

/**
 * @brief Protocol for managing female health functionality
 * @chinese 女性健康功能管理协议
 *
 * @discussion
 * [EN]: This protocol defines the interface for managing female health settings in the device.
 *       It provides methods for getting and setting female health configuration,
 *       and monitoring female health configuration changes.
 * [CN]: 该协议定义了设备中女性健康设置管理的接口。
 *       提供了获取和设置女性健康配置、监听女性健康配置变化的方法。
 */
@protocol TSFemaleHealthInterface <TSKitBaseInterface>

/**
 * @brief Fetch female health configuration from device
 * @chinese 从设备获取女性健康配置信息
 *
 * @param completion
 * EN: Callback block that returns female health configuration and any error that occurred
 * CN: 返回女性健康配置和可能发生的错误的回调块
 *
 * @discussion
 * [EN]: Retrieves the current female health configuration from the connected device.
 *       The configuration includes:
 *       - Health tracking mode (disabled, menstruation, pregnancy preparation, pregnancy)
 *       - Menstrual cycle information (cycle length, duration, last period date)
 *       - Reminder settings (reminder time, advance days, reminder type)
 *       - Pregnancy tracking information (menstruation end day)
 *       Returns nil for femaleHealthConfig if the operation fails.
 *
 * [CN]: 从已连接的设备获取当前的女性健康配置信息。
 *       配置包括：
 *       - 健康追踪模式（关闭、经期、备孕、孕期）
 *       - 月经周期信息（周期长度、经期长度、最近一次经期日期）
 *       - 提醒设置（提醒时间、提前天数、提醒类型）
 *       - 孕期追踪信息（月经结束天数）
 *       如果操作失败，femaleHealthConfig 将返回 nil。
 */
- (void)fetchFemaleHealthConfigWithCompletion:(void(^)(TSFemaleHealthConfig * _Nullable femaleHealthConfig, NSError * _Nullable error))completion;

/**
 * @brief Push female health configuration to device
 * @chinese 向设备推送女性健康配置信息
 *
 * @param femaleHealthConfig
 * EN: Female health configuration to be set (must not be nil)
 * CN: 要设置的女性健康配置（不能为nil）
 *
 * @param completion
 * EN: Callback block to be executed after the operation completes
 * CN: 操作完成后的回调块
 *
 * @discussion
 * [EN]: Pushes the female health configuration to the connected device.
 *       The device will replace existing female health configuration with the provided configuration.
 *       The configuration includes:
 *       - Health tracking mode (disabled, menstruation, pregnancy preparation, pregnancy)
 *       - Menstrual cycle information (cycle length, duration, last period date)
 *       - Reminder settings (reminder time, advance days, reminder type)
 *       - Pregnancy tracking information (menstruation end day)
 *
 * [CN]: 向已连接的设备推送女性健康配置信息。
 *       设备将用提供的配置替换现有女性健康配置。
 *       配置包括：
 *       - 健康追踪模式（关闭、经期、备孕、孕期）
 *       - 月经周期信息（周期长度、经期长度、最近一次经期日期）
 *       - 提醒设置（提醒时间、提前天数、提醒类型）
 *       - 孕期追踪信息（月经结束天数）
 *
 * @note
 * [EN]: The femaleHealthConfig parameter must not be nil. Passing nil will result in an error.
 * [CN]: femaleHealthConfig 参数不能为 nil。传入 nil 将导致错误。
 */
- (void)pushFemaleHealthConfig:(TSFemaleHealthConfig * _Nonnull)femaleHealthConfig
                    completion:(TSCompletionBlock)completion;

/**
 * @brief Register for female health configuration change notifications
 * @chinese 注册女性健康配置变化监听
 *
 * @param completion
 * EN: Callback block that is triggered when female health configuration changes
 *     - femaleHealthConfig: Updated female health configuration model, nil if error occurred
 *     - error: Error information, nil when successful
 *     Pass nil to unregister the notification
 * CN: 女性健康配置发生变化时触发的回调块
 *     - femaleHealthConfig: 更新后的女性健康配置模型，发生错误时为nil
 *     - error: 错误信息，成功时为nil
 *     传入nil可以取消注册通知
 *
 * @discussion
 * [EN]: Monitors device female health configuration changes:
 *       - Triggered when female health configuration is modified on the device
 *       - Provides updated female health configuration model
 *       - To stop receiving notifications, call this method with nil
 *
 * [CN]: 监控设备女性健康配置变化：
 *       - 当设备端女性健康配置被修改时触发
 *       - 提供更新后的女性健康配置模型
 *       - 要停止接收通知，请使用nil调用此方法
 */
- (void)registerFemaleHealthConfigDidChangedBlock:(nullable TSFemaleHealthConfigDidChangedBlock)completion;

/**
 * @brief Unregister female health configuration change notifications
 * @chinese 取消注册女性健康配置变化监听
 *
 * @discussion
 * [EN]: Removes the registered female health configuration change listener.
 *       After calling this method, no more change notifications will be received.
 *       This is equivalent to calling registerFemaleHealthConfigDidChangedBlock: with nil.
 *
 * [CN]: 移除已注册的女性健康配置变化监听器。
 *       调用此方法后，将不再接收变化通知。
 *       等同于使用 nil 调用 registerFemaleHealthConfigDidChangedBlock:。
 *
 * @note
 * [EN]: If no listener is currently registered, calling this method has no effect.
 * [CN]: 如果当前没有注册监听器，调用此方法不会有任何效果。
 */
- (void)unregisterFemaleHealthConfigDidChangedBlock;

@end

NS_ASSUME_NONNULL_END
