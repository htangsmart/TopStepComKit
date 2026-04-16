//
//  TSPrayersInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/18.
//

#import "TSKitBaseInterface.h"
#import "TSPrayerConfigs.h"
#import "TSPrayerTimes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Prayer reminder switch enumeration
 * @chinese 祈祷提醒开关枚举
 *
 * @discussion
 * [EN]: Defines the prayer reminder switch types, including:
 *       - Main: Master switch that controls whether the prayer reminder feature is enabled
 *       - Fajr: Dawn prayer reminder switch (before sunrise)
 *       - Sunrise: Sunrise reminder switch (optional, may not be supported by all projects)
 *       - Dhuhr: Noon prayer reminder switch (after the sun passes its zenith)
 *       - Asr: Afternoon prayer reminder switch (in the late part of the afternoon)
 *       - Sunset: Sunset reminder switch (optional, may not be supported by all projects)
 *       - Maghrib: Sunset prayer reminder switch (just after sunset)
 *       - Isha: Night prayer reminder switch (after twilight has disappeared)
 * [CN]: 定义祈祷提醒开关类型，包括：
 *       - Main: 总开关，控制祈祷提醒功能是否启用
 *       - Fajr: 晨礼提醒开关（日出前）
 *       - Sunrise: 日出提醒开关（可选，某些项目可能不支持）
 *       - Dhuhr: 晌礼提醒开关（太阳过中天之后）
 *       - Asr: 晡礼提醒开关（下午晚些时候）
 *       - Sunset: 日落提醒开关（可选，某些项目可能不支持）
 *       - Maghrib: 昏礼提醒开关（日落后）
 *       - Isha: 宵礼提醒开关（黄昏消失后）
 */
typedef NS_ENUM(NSInteger, TSPrayerReminderSwitch) {
    TSPrayerReminderSwitchMain     = 0,   //总开关 Main Switch
    TSPrayerReminderSwitchFajr     = 1,   //晨礼提醒开关 Fajr Reminder Switch
    TSPrayerReminderSwitchSunrise  = 2,   //日出提醒开关 Sunrise Reminder Switch (可选)
    TSPrayerReminderSwitchDhuhr    = 3,   //晌礼提醒开关 Dhuhr Reminder Switch
    TSPrayerReminderSwitchAsr      = 4,   //晡礼提醒开关 Asr Reminder Switch
    TSPrayerReminderSwitchSunset   = 5,   //日落提醒开关 Sunset Reminder Switch (可选)
    TSPrayerReminderSwitchMaghrib  = 6,   //昏礼提醒开关 Maghrib Reminder Switch
    TSPrayerReminderSwitchIsha     = 7    //宵礼提醒开关 Isha Reminder Switch
};

/**
 * @brief Prayer configuration change callback block type
 * @chinese 祈祷配置变化回调块类型
 *
 * @param prayerConfig
 * EN: Updated prayer configuration model, nil if error occurred
 * CN: 更新后的祈祷配置模型，发生错误时为nil
 *
 * @param error
 * EN: Error information, nil when successful
 * CN: 错误信息，成功时为nil
 */
typedef void(^TSPrayerConfigDidChangedBlock)(TSPrayerConfigs * _Nullable prayerConfig, NSError * _Nullable error);

/**
 * @brief Protocol for managing prayer functionality
 * @chinese 祈祷功能管理协议
 *
 * @discussion
 * [EN]: This protocol defines the interface for managing prayer settings in the device.
 *       It provides methods for getting and setting prayer configuration, setting prayer times,
 *       and monitoring prayer configuration changes.
 * [CN]: 该协议定义了设备中祈祷设置管理的接口。
 *       提供了获取和设置祈祷配置、设置祈祷时间、监听祈祷配置变化的方法。
 */
@protocol TSPrayersInterface <TSKitBaseInterface>

/**
 * @brief Get prayer configuration from device
 * @chinese 从设备获取祈祷配置信息
 *
 * @param completion
 * EN: Callback block that returns prayer configuration and any error that occurred
 * CN: 返回祈祷配置和可能发生的错误的回调块
 *
 * @discussion
 * [EN]: Retrieves the current prayer configuration from the connected device.
 *       The configuration includes:
 *       - Overall prayer feature enable/disable status
 *       - Individual prayer time reminder switches (Fajr, Dhuhr, Asr, Maghrib, Isha)
 *       Returns nil for prayerConfig if the operation fails.
 *
 * [CN]: 从已连接的设备获取当前的祈祷配置信息。
 *       配置包括：
 *       - 祈祷功能总开关
 *       - 各个祈祷时间提醒开关（晨礼、晌礼、晡礼、昏礼、宵礼）
 *       如果操作失败，prayerConfig 将返回 nil。
 */
- (void)getPrayerConfigCompletion:(void(^)(TSPrayerConfigs * _Nullable prayerConfig, NSError * _Nullable error))completion;

/**
 * @brief Set prayer configuration to device
 * @chinese 向设备设置祈祷配置信息
 *
 * @param prayerConfig
 * EN: Prayer configuration to be set (must not be nil)
 * CN: 要设置的祈祷配置（不能为nil）
 *
 * @param completion
 * EN: Callback block to be executed after the operation completes
 * CN: 操作完成后的回调块
 *
 * @discussion
 * [EN]: Sets the prayer configuration to the connected device.
 *       The device will replace existing prayer configuration with the provided configuration.
 *       The configuration includes:
 *       - Overall prayer feature enable/disable status
 *       - Individual prayer time reminder switches (Fajr, Dhuhr, Asr, Maghrib, Isha)
 *
 * [CN]: 向已连接的设备设置祈祷配置信息。
 *       设备将用提供的配置替换现有祈祷配置。
 *       配置包括：
 *       - 祈祷功能总开关
 *       - 各个祈祷时间提醒开关（晨礼、晌礼、晡礼、昏礼、宵礼）
 *
 * @note
 * [EN]: The prayerConfig parameter must not be nil. Passing nil will result in an error.
 * [CN]: prayerConfig 参数不能为 nil。传入 nil 将导致错误。
 */
- (void)setPrayerConfig:(TSPrayerConfigs * _Nonnull)prayerConfig
             completion:(TSCompletionBlock)completion;

/**
 * @brief Set reminder switch for a specific prayer reminder switch type
 * @chinese 根据祈祷提醒开关类型单独设置提醒开关
 *
 * @param reminderSwitch
 * EN: Prayer reminder switch type to set (Main, Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, or Isha)
 * CN: 要设置的祈祷提醒开关类型（总开关、晨礼、日出、晌礼、晡礼、日落、昏礼或宵礼）
 *
 * @param enabled
 * EN: Whether to enable the reminder for this switch type
 * CN: 是否启用该开关类型的提醒
 *
 * @param completion
 * EN: Callback block to be executed after the operation completes
 * CN: 操作完成后的回调块
 *
 * @discussion
 * [EN]: Sets the reminder switch for a specific prayer reminder switch type individually.
 *       This method allows you to enable or disable reminders for one switch type
 *       without affecting other switch type settings.
 *       The operation will:
 *       1. Get current prayer configuration from device
 *       2. Update the specified switch type's reminder switch
 *       3. Save the updated configuration back to device
 *
 * [CN]: 单独设置指定祈祷提醒开关类型的提醒开关。
 *       此方法允许您启用或禁用某个开关类型的提醒，而不影响其他开关类型的设置。
 *       操作将：
 *       1. 从设备获取当前祈祷配置
 *       2. 更新指定开关类型的提醒开关
 *       3. 将更新后的配置保存回设备
 *
 * @note
 * [EN]: This setting is only effective when the overall prayer feature (prayerEnable) is enabled.
 *       If prayerEnable is NO, this setting will not take effect even if enabled is YES.
 *       Note: Sunrise and Sunset switches may not be supported by all projects.
 * [CN]: 此设置仅在祈祷功能总开关（prayerEnable）启用时有效。
 *       如果 prayerEnable 为 NO，即使 enabled 为 YES，此设置也不会生效。
 *       注意：日出和日落开关可能不被所有项目支持。
 */
- (void)setPrayerReminderEnabled:(TSPrayerReminderSwitch)reminderSwitch
                         enabled:(BOOL)enabled
                      completion:(TSCompletionBlock)completion ;

/**
 * @brief Set prayer times to device
 * @chinese 向设备设置祈祷时间数据
 *
 * @param prayerTimes
 * EN: Array of prayer times to be set, where each element represents one day's prayer times (must not be nil, must contain exactly 7 elements: today + next 6 days)
 * CN: 要设置的祈祷时间数组，每个元素代表一天的祈祷时间（不能为nil，必须包含7个元素：当天+未来6天）
 *
 * @param completion
 * EN: Callback block to be executed after the operation completes
 * CN: 操作完成后的回调块
 *
 * @discussion
 * [EN]: Sets prayer times for 7 days (today + next 6 days) to the connected device.
 *       Each TSPrayerTimes object in the array represents prayer times for one day, including:
 *       - Day timestamp (00:00:00 of the day)
 *       - Minute offsets from midnight for 7 prayer-related times (Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha)
 *       The array must contain exactly 7 elements:
 *       - Index 0: Today's prayer times
 *       - Index 1-6: Next 6 days' prayer times
 *       The device will replace existing prayer times with the provided data.
 *
 * [CN]: 向已连接的设备设置7天的祈祷时间数据（当天+未来6天）。
 *       数组中的每个 TSPrayerTimes 对象代表一天的祈祷时间，包括：
 *       - 日期时间戳（当天的00:00:00）
 *       - 7个祈祷相关时间相对于午夜的分钟偏移量（晨礼、日出、晌礼、晡礼、日落、昏礼、宵礼）
 *       数组必须包含7个元素：
 *       - 索引0：当天的祈祷时间
 *       - 索引1-6：未来6天的祈祷时间
 *       设备将用提供的数据替换现有祈祷时间数据。
 *
 * @note
 * [EN]: The prayerTimes parameter must not be nil and must contain exactly 7 elements.
 *       If the array contains fewer or more than 7 elements, the operation will fail.
 *       Each TSPrayerTimes object should have a valid dayTimestamp and prayer time offsets.
 *       Note: Sunrise and Sunset offsets are optional and may not be supported by all projects.
 * [CN]: prayerTimes 参数不能为 nil，且必须包含7个元素。
 *       如果数组包含少于或多于7个元素，操作将失败。
 *       每个 TSPrayerTimes 对象应具有有效的 dayTimestamp 和祈祷时间偏移量。
 *       注意：日出和日落偏移量是可选的，某些项目可能不支持。
 */
- (void)setPrayerTimes:(NSArray<TSPrayerTimes *> * _Nonnull)prayerTimes
            completion:(TSCompletionBlock)completion;

/**
 * @brief Register for prayer configuration change notifications
 * @chinese 注册祈祷配置变化监听
 *
 * @param completion
 * EN: Callback block that is triggered when prayer configuration changes
 *     - prayerConfig: Updated prayer configuration model, nil if error occurred
 *     - error: Error information, nil when successful
 *     Pass nil to unregister the notification
 * CN: 祈祷配置发生变化时触发的回调块
 *     - prayerConfig: 更新后的祈祷配置模型，发生错误时为nil
 *     - error: 错误信息，成功时为nil
 *     传入nil可以取消注册通知
 *
 * @discussion
 * [EN]: Monitors device prayer configuration changes:
 *       - Triggered when prayer configuration is modified on the device
 *       - Provides updated prayer configuration model
 *       - To stop receiving notifications, call this method with nil
 *
 * [CN]: 监控设备祈祷配置变化：
 *       - 当设备端祈祷配置被修改时触发
 *       - 提供更新后的祈祷配置模型
 *       - 要停止接收通知，请使用nil调用此方法
 */
- (void)registerPrayerConfigDidChangedBlock:(nullable TSPrayerConfigDidChangedBlock)completion;

/**
 * @brief Unregister prayer configuration change notifications
 * @chinese 取消注册祈祷配置变化监听
 *
 * @discussion
 * [EN]: Removes the registered prayer configuration change listener.
 *       After calling this method, no more change notifications will be received.
 *       This is equivalent to calling registerPrayerConfigDidChangedBlock: with nil.
 *
 * [CN]: 移除已注册的祈祷配置变化监听器。
 *       调用此方法后，将不再接收变化通知。
 *       等同于使用 nil 调用 registerPrayerConfigDidChangedBlock:。
 *
 * @note
 * [EN]: If no listener is currently registered, calling this method has no effect.
 * [CN]: 如果当前没有注册监听器，调用此方法不会有任何效果。
 */
- (void)unregisterPrayerConfigDidChangedBlock;

@end

NS_ASSUME_NONNULL_END
