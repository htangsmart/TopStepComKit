//
//  TSSettingInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//
//  文件说明:
//  设备设置协议，定义佩戴习惯、提醒、显示、勿扰、监测等设置接口。

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"
#import "TSWristWakeUpModel.h"
#import "TSDoNotDisturbModel.h"
#import "TSVibrationIntensityModel.h"
#import "TSAIDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device wearing habit type
 * @chinese 设备佩戴习惯类型
 */
typedef NS_ENUM(NSInteger, TSWearingHabit) {
    /**
     * @brief Left hand wearing
     * @chinese 左手佩戴
     */
    TSWearingHabitLeft = 0,
    /**
     * @brief Right hand wearing
     * @chinese 右手佩戴
     */
    TSWearingHabitRight
};

/**
 * @brief Device settings interface
 * @chinese 设备设置接口
 *
 * @discussion
 * EN: Provides device settings such as wearing habit, reminders, display, DND, and monitoring.
 * CN: 提供佩戴习惯、提醒、显示、勿扰、监测等设备设置能力。
 */
@protocol TSSettingInterface <TSKitBaseInterface>

#pragma mark - Wearing Habit

/**
 * @brief Set device wearing habit
 * @chinese 设置设备佩戴习惯
 *
 * @param habit
 * EN: Wearing habit.
 * CN: 佩戴习惯。
 *
 * @param completion
 * EN: Completion callback; success indicates whether the setting succeeded, error is nil on success.
 * CN: 完成回调；success 表示是否设置成功，成功时 error 为 nil。
 */
- (void)setWearingHabit:(TSWearingHabit)habit
             completion:(TSCompletionBlock)completion;

/**
 * @brief Get current wearing habit
 * @chinese 获取当前佩戴习惯
 *
 * @param completion
 * EN: Completion callback returning the current habit and error.
 * CN: 完成回调，返回当前佩戴习惯和错误信息。
 */
- (void)getCurrentWearingHabit:(void(^)(TSWearingHabit habit, NSError * _Nullable error))completion;

#pragma mark - Bluetooth Disconnection Vibration

/**
 * @brief Set Bluetooth disconnection vibration
 * @chinese 设置蓝牙断连震动
 *
 * @param enabled
 * EN: YES to vibrate when Bluetooth disconnects.
 * CN: YES 表示蓝牙断连时震动。
 *
 * @param completion
 * EN: Completion callback; success indicates whether the setting succeeded, error is nil on success.
 * CN: 完成回调；success 表示是否设置成功，成功时 error 为 nil。
 */
- (void)setBluetoothDisconnectionVibration:(BOOL)enabled
                               completion:(TSCompletionBlock)completion;

/**
 * @brief Get Bluetooth disconnection vibration status
 * @chinese 获取蓝牙断连震动状态
 *
 * @param completion
 * EN: Completion callback returning enabled status and error.
 * CN: 完成回调，返回启用状态和错误信息。
 */
- (void)getBluetoothDisconnectionVibrationStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;

#pragma mark - Vibration Intensity

/**
 * @brief Query whether the device supports vibration intensity setting
 * @chinese 查询设备是否支持震动强度设置
 *
 * @return
 * EN: YES if supported.
 * CN: 支持返回 YES。
 */
- (BOOL)isSupportVibrationIntensity;

/**
 * @brief Get vibration intensity information
 * @chinese 获取震动强度信息
 *
 * @param completion
 * EN: Completion callback returning current level, level count, and error.
 * CN: 完成回调，返回当前档位、档位数量和错误信息。
 */
- (void)getVibrationIntensityInfo:(void(^)(TSVibrationIntensityModel * _Nullable model,
                                           NSError * _Nullable error))completion;

/**
 * @brief Set device vibration intensity level
 * @chinese 设置设备震动强度档位
 *
 * @param level
 * EN: Vibration intensity level index, starting from 0.
 * CN: 震动强度档位索引，从 0 开始。
 *
 * @param completion
 * EN: Completion callback; success indicates whether the setting succeeded, error is nil on success.
 * CN: 完成回调；success 表示是否设置成功，成功时 error 为 nil。
 */
- (void)setVibrationIntensityLevel:(NSInteger)level
                        completion:(TSCompletionBlock)completion;

#pragma mark - Exercise Goal Achievement Reminder

/**
 * @brief Set exercise goal achievement reminder
 * @chinese 设置运动目标达成提醒
 *
 * @param enabled
 * EN: YES to remind when an exercise goal is reached.
 * CN: YES 表示达成运动目标时提醒。
 *
 * @param completion
 * EN: Completion callback; success indicates whether the setting succeeded, error is nil on success.
 * CN: 完成回调；success 表示是否设置成功，成功时 error 为 nil。
 */
- (void)setExerciseGoalReminder:(BOOL)enabled
                    completion:(TSCompletionBlock)completion;

/**
 * @brief Get exercise goal reminder status
 * @chinese 获取运动目标提醒状态
 *
 * @param completion
 * EN: Completion callback returning enabled status and error.
 * CN: 完成回调，返回启用状态和错误信息。
 */
- (void)getExerciseGoalReminderStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;

#pragma mark - Call Ring

/**
 * @brief Set call ring
 * @chinese 设置来电响铃
 *
 * @param enabled
 * EN: YES to enable ring for incoming calls.
 * CN: YES 表示启用来电响铃。
 *
 * @param completion
 * EN: Completion callback; success indicates whether the setting succeeded, error is nil on success.
 * CN: 完成回调；success 表示是否设置成功，成功时 error 为 nil。
 */
- (void)setCallRing:(BOOL)enabled
         completion:(TSCompletionBlock)completion;

/**
 * @brief Get call ring status
 * @chinese 获取来电响铃状态
 *
 * @param completion
 * EN: Completion callback returning enabled status and error.
 * CN: 完成回调，返回启用状态和错误信息。
 */
- (void)getCallRingStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;

#pragma mark - Raise Wrist to Wake

/**
 * @brief Query whether the device supports raise wrist to wake screen
 * @chinese 查询设备是否支持抬腕亮屏
 *
 * @return
 * EN: YES if supported.
 * CN: 支持返回 YES。
 */
- (BOOL)isSupportRaiseWristToWake;

/**
 * @brief Set raise wrist to wake screen settings
 * @chinese 设置抬腕亮屏
 *
 * @param model
 * EN: Wake-up configuration, including enable state and valid time range.
 * CN: 抬腕亮屏配置，包含启用状态和生效时间段。
 *
 * @param completion
 * EN: Completion callback; success indicates whether the setting succeeded, error is nil on success.
 * CN: 完成回调；success 表示是否设置成功，成功时 error 为 nil。
 */
- (void)setRaiseWristToWake:(TSWristWakeUpModel *)model
                completion:(TSCompletionBlock)completion;

/**
 * @brief Get raise wrist to wake screen settings
 * @chinese 获取抬腕亮屏设置
 *
 * @param completion
 * EN: Completion callback returning current configuration and error.
 * CN: 完成回调，返回当前配置和错误信息。
 */
- (void)getRaiseWristToWakeStatus:(void(^)(TSWristWakeUpModel * _Nullable model, 
                                          NSError * _Nullable error))completion;

/**
 * @brief Register raise wrist to wake screen configuration change listener
 * @chinese 注册抬腕亮屏配置信息变化监听
 *
 * @param didChangeBlock
 * EN: Callback invoked when the configuration changes, returning updated configuration and error.
 * CN: 配置变化回调，返回更新后的配置和错误信息。
 *
 * @note
 * EN: Keep the block reference if it needs to be unregistered later.
 * CN: 如需后续取消监听，请保留 block 引用。
 */
- (void)registerRaiseWristToWakeDidChanged:(void(^)(TSWristWakeUpModel * _Nullable model,
                                                        NSError * _Nullable error))didChangeBlock;


#pragma mark - Do Not Disturb Mode

/**
 * @brief Set do not disturb mode settings
 * @chinese 设置勿扰模式配置
 *
 * @param model
 * EN: DND configuration, including enable state and valid time range.
 * CN: 勿扰模式配置，包含启用状态和生效时间段。
 *
 * @param completion
 * EN: Completion callback; success indicates whether the setting succeeded, error is nil on success.
 * CN: 完成回调；success 表示是否设置成功，成功时 error 为 nil。
 */
- (void)setDoNotDisturb:(TSDoNotDisturbModel *)model
                 completion:(TSCompletionBlock)completion;

/**
 * @brief Get do not disturb mode settings
 * @chinese 获取勿扰模式配置
 *
 * @param completion
 * EN: Completion callback returning current configuration and error.
 * CN: 完成回调，返回当前配置和错误信息。
 */
- (void)getDoNotDisturbInfo:(void(^)(TSDoNotDisturbModel * _Nullable model,
                                          NSError * _Nullable error))completion;

#pragma mark - Enhanced Monitoring

/**
 * @brief Set enhanced monitoring mode
 * @chinese 设置加强监测模式
 *
 * @param enabled
 * EN: YES to enable higher-frequency monitoring.
 * CN: YES 表示启用更高频率的加强监测。
 *
 * @param completion
 * EN: Completion callback; success indicates whether the setting succeeded, error is nil on success.
 * CN: 完成回调；success 表示是否设置成功，成功时 error 为 nil。
 */
- (void)setEnhancedMonitoring:(BOOL)enabled
                    completion:(TSCompletionBlock)completion;

/**
 * @brief Get enhanced monitoring mode status
 * @chinese 获取加强监测模式状态
 *
 * @param completion
 * EN: Completion callback returning enabled status and error.
 * CN: 完成回调，返回启用状态和错误信息。
 */
- (void)getEnhancedMonitoringStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
