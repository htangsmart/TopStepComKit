//
//  TSSettingInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//
//  文件说明:
//  设备设置管理协议，定义了设备的基本设置操作，包括佩戴习惯、提醒设置、显示设置等功能

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"
#import "TSWristWakeUpModel.h"
#import "TSDoNotDisturbModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device wearing habit type
 * @chinese 设备佩戴习惯类型
 *
 * @discussion
 * EN: Defines which hand the device is worn on.
 *     This affects screen orientation and gesture recognition.
 * CN: 定义设备佩戴在哪只手上。
 *     这会影响屏幕方向和手势识别。
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
 * EN: This interface defines all device settings operations, including:
 *     1. Wearing habit (left/right hand)
 *     2. Bluetooth disconnection vibration
 *     3. Exercise goal achievement reminder
 *     4. Call ring settings
 *     5. Raise wrist to wake screen
 *     6. Weather display settings
 *     All settings are persisted on the device and will be retained after power off.
 *
 * CN: 该接口定义了所有设备设置相关的操作，包括：
 *     1. 佩戴习惯（左手/右手）
 *     2. 蓝牙断连震动
 *     3. 运动目标达成提醒
 *     4. 来电响铃设置
 *     5. 抬腕亮屏
 *     6. 天气显示设置
 *     所有设置都会持久化保存在设备中，关机后仍然保留。
 */
@protocol TSSettingInterface <TSKitBaseInterface>

#pragma mark - Wearing Habit

/**
 * @brief Set device wearing habit
 * @chinese 设置设备佩戴习惯
 * 
 * @param habit 
 * EN: Wearing habit (left/right hand)
 *     TSWearingHabitLeft: Device is worn on left hand
 *     TSWearingHabitRight: Device is worn on right hand
 * CN: 佩戴习惯（左手/右手）
 *     TSWearingHabitLeft: 设备佩戴在左手
 *     TSWearingHabitRight: 设备佩戴在右手
 * 
 * @param completion 
 * EN: Completion callback
 *     success: Whether the setting was successful
 *     error: Error information if failed, nil if successful
 * CN: 设置完成回调
 *     success: 是否设置成功
 *     error: 设置失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Set which hand the device is worn on.
 *     This setting affects:
 *     1. Screen orientation
 *     2. Gesture recognition direction
 *     3. Raise wrist detection
 * CN: 设置设备佩戴在哪只手上。
 *     此设置会影响：
 *     1. 屏幕显示方向
 *     2. 手势识别方向
 *     3. 抬腕检测
 */
- (void)setWearingHabit:(TSWearingHabit)habit
             completion:(TSCompletionBlock)completion;

/**
 * @brief Get current wearing habit
 * @chinese 获取当前佩戴习惯
 * 
 * @param completion 
 * EN: Completion callback with current wearing habit and error if any
 *     habit: Current wearing habit setting
 *     error: Error information if failed, nil if successful
 * CN: 完成回调，返回当前佩戴习惯和错误信息（如果有）
 *     habit: 当前的佩戴习惯设置
 *     error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Retrieves the current wearing habit setting from the device.
 *     This is useful when:
 *     1. Initializing the app
 *     2. Verifying setting changes
 *     3. Syncing settings between app and device
 * CN: 从设备获取当前的佩戴习惯设置。
 *     在以下情况下使用：
 *     1. 应用初始化时
 *     2. 验证设置更改时
 *     3. 同步应用和设备设置时
 */
- (void)getCurrentWearingHabit:(void(^)(TSWearingHabit habit, NSError * _Nullable error))completion;

#pragma mark - Bluetooth Disconnection Vibration

/**
 * @brief Set Bluetooth disconnection vibration
 * @chinese 设置蓝牙断连震动
 * 
 * @param enabled 
 * EN: Whether to enable vibration on Bluetooth disconnection
 *     YES: Device will vibrate when Bluetooth connection is lost
 *     NO: Device will not vibrate when Bluetooth connection is lost
 * CN: 是否启用蓝牙断连震动
 *     YES: 蓝牙连接断开时设备会震动
 *     NO: 蓝牙连接断开时设备不会震动
 * 
 * @param completion 
 * EN: Completion callback
 *     success: Whether the setting was successful
 *     error: Error information if failed, nil if successful
 * CN: 设置完成回调
 *     success: 是否设置成功
 *     error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Controls whether the device vibrates when Bluetooth connection is lost.
 *     This feature helps users notice when:
 *     1. Device moves out of Bluetooth range
 *     2. Phone's Bluetooth is turned off
 *     3. Connection is interrupted by interference
 * CN: 控制蓝牙连接断开时设备是否震动。
 *     此功能帮助用户注意到：
 *     1. 设备超出蓝牙范围
 *     2. 手机蓝牙被关闭
 *     3. 连接被干扰中断
 */
- (void)setBluetoothDisconnectionVibration:(BOOL)enabled
                               completion:(TSCompletionBlock)completion;

/**
 * @brief Get Bluetooth disconnection vibration status
 * @chinese 获取蓝牙断连震动状态
 * 
 * @param completion 
 * EN: Completion callback with current status and error if any
 *     enabled: Whether Bluetooth disconnection vibration is enabled
 *     error: Error information if failed, nil if successful
 * CN: 完成回调，返回当前状态和错误信息（如果有）
 *     enabled: 蓝牙断连震动是否启用
 *     error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Retrieves the current Bluetooth disconnection vibration setting.
 *     Used to:
 *     1. Initialize app settings display
 *     2. Verify setting changes
 *     3. Sync settings between app and device
 * CN: 获取当前的蓝牙断连震动设置。
 *     用于：
 *     1. 初始化应用设置显示
 *     2. 验证设置更改
 *     3. 同步应用和设备设置
 */
- (void)getBluetoothDisconnectionVibrationStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;

#pragma mark - Exercise Goal Achievement Reminder

/**
 * @brief Set exercise goal achievement reminder
 * @chinese 设置运动目标达成提醒
 * 
 * @param enabled 
 * EN: Whether to enable exercise goal achievement reminder
 *     YES: Device will notify when exercise goals are met
 *     NO: Device will not notify when exercise goals are met
 * CN: 是否启用运动目标达成提醒
 *     YES: 达到运动目标时设备会提醒
 *     NO: 达到运动目标时设备不会提醒
 * 
 * @param completion 
 * EN: Completion callback
 *     success: Whether the setting was successful
 *     error: Error information if failed, nil if successful
 * CN: 设置完成回调
 *     success: 是否设置成功
 *     error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Controls whether the device notifies when exercise goals are achieved.
 *     Notification includes:
 *     1. Vibration alert
 *     2. Screen display
 *     3. Achievement message
 *     Goals include steps, calories, and distance targets.
 * CN: 控制达到运动目标时设备是否提醒。
 *     提醒包括：
 *     1. 震动提醒
 *     2. 屏幕显示
 *     3. 成就消息
 *     目标包括步数、卡路里和距离目标。
 */
- (void)setExerciseGoalReminder:(BOOL)enabled
                    completion:(TSCompletionBlock)completion;

/**
 * @brief Get exercise goal reminder status
 * @chinese 获取运动目标提醒状态
 * 
 * @param completion 
 * EN: Completion callback with current status and error if any
 *     enabled: Whether exercise goal reminder is enabled
 *     error: Error information if failed, nil if successful
 * CN: 完成回调，返回当前状态和错误信息（如果有）
 *     enabled: 运动目标提醒是否启用
 *     error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Retrieves the current exercise goal reminder setting.
 *     Used to:
 *     1. Initialize app settings display
 *     2. Verify setting changes
 *     3. Sync settings between app and device
 * CN: 获取当前的运动目标提醒设置。
 *     用于：
 *     1. 初始化应用设置显示
 *     2. 验证设置更改
 *     3. 同步应用和设备设置
 */
- (void)getExerciseGoalReminderStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;

#pragma mark - Call Ring

/**
 * @brief Set call ring
 * @chinese 设置来电响铃
 * 
 * @param enabled 
 * EN: Whether to enable ring on incoming calls
 *     YES: Device will ring and vibrate for incoming calls
 *     NO: Device will not ring or vibrate for incoming calls
 * CN: 是否启用来电响铃
 *     YES: 来电时设备会响铃和震动
 *     NO: 来电时设备不会响铃和震动
 * 
 * @param completion 
 * EN: Completion callback
 *     success: Whether the setting was successful
 *     error: Error information if failed, nil if successful
 * CN: 设置完成回调
 *     success: 是否设置成功
 *     error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Controls device behavior for incoming calls.
 *     When enabled:
 *     1. Device rings with default ringtone
 *     2. Device vibrates
 *     3. Screen shows caller information
 *     Requires Bluetooth connection and call permission.
 * CN: 控制设备对来电的响应行为。
 *     启用时：
 *     1. 设备使用默认铃声响铃
 *     2. 设备震动
 *     3. 屏幕显示来电信息
 *     需要蓝牙连接和通话权限。
 */
- (void)setCallRing:(BOOL)enabled
         completion:(TSCompletionBlock)completion;

/**
 * @brief Get call ring status
 * @chinese 获取来电响铃状态
 * 
 * @param completion 
 * EN: Completion callback with current status and error if any
 *     enabled: Whether call ring is enabled
 *     error: Error information if failed, nil if successful
 * CN: 完成回调，返回当前状态和错误信息（如果有）
 *     enabled: 来电响铃是否启用
 *     error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Retrieves the current call ring setting.
 *     Used to:
 *     1. Initialize app settings display
 *     2. Verify setting changes
 *     3. Sync settings between app and device
 * CN: 获取当前的来电响铃设置。
 *     用于：
 *     1. 初始化应用设置显示
 *     2. 验证设置更改
 *     3. 同步应用和设备设置
 */
- (void)getCallRingStatus:(void(^)(BOOL enabled, NSError * _Nullable error))completion;

#pragma mark - Raise Wrist to Wake

/**
 * @brief Set raise wrist to wake screen settings
 * @chinese 设置抬腕亮屏
 * 
 * @param model 
 * EN: TSWristWakeUpModel object containing wake up settings
 *     - isEnable: Whether to enable screen wake on raising wrist
 *     - begin: Start time in minutes from midnight (0-1439)
 *     - end: End time in minutes from midnight (0-1439)
 *     Note: end time must be greater than begin time
 *     Example: begin=480 (8:00), end=1320 (22:00)
 * CN: 包含抬腕亮屏设置的TSWristWakeUpModel对象
 *     - isEnable: 是否启用抬腕亮屏
 *     - begin: 开始时间（从0点开始的分钟数，0-1439）
 *     - end: 结束时间（从0点开始的分钟数，0-1439）
 *     注意：结束时间必须大于开始时间
 *     示例：begin=480（8:00），end=1320（22:00）
 * 
 * @param completion 
 * EN: Completion callback
 *     success: Whether the setting was successful
 *     error: Error information if failed, nil if successful
 * CN: 设置完成回调
 *     success: 是否设置成功
 *     error: 设置失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Set the time period during which raising wrist will wake the screen.
 *     If isEnable is NO, the time period settings will be ignored.
 *     This feature:
 *     1. Helps preserve battery life
 *     2. Prevents unwanted screen activation
 *     3. Can be customized for user's active hours
 * CN: 设置抬腕亮屏的生效时间段。
 *     如果isEnable为NO，时间段设置将被忽略。
 *     此功能：
 *     1. 有助于节省电量
 *     2. 防止意外的屏幕激活
 *     3. 可以根据用户的活动时间自定义
 */
- (void)setRaiseWristToWake:(TSWristWakeUpModel *)model
                completion:(TSCompletionBlock)completion;

/**
 * @brief Get raise wrist to wake screen settings
 * @chinese 获取抬腕亮屏设置
 * 
 * @param completion 
 * EN: Completion callback
 *     - model: TSWristWakeUpModel object containing current settings, nil if failed
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成回调
 *     - model: 包含当前设置的TSWristWakeUpModel对象，获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Get the current raise wrist to wake settings, including:
 *     1. Whether the feature is enabled
 *     2. The time period during which the feature is active
 *     Used to:
 *     1. Initialize app settings display
 *     2. Verify setting changes
 *     3. Sync settings between app and device
 * CN: 获取当前抬腕亮屏的设置，包括：
 *     1. 功能是否启用
 *     2. 功能的生效时间段
 *     用于：
 *     1. 初始化应用设置显示
 *     2. 验证设置更改
 *     3. 同步应用和设备设置
 */
- (void)getRaiseWristToWakeStatus:(void(^)(TSWristWakeUpModel * _Nullable model, 
                                          NSError * _Nullable error))completion;

#pragma mark - Weather Display

/**
 * @brief Get weather display status
 * @chinese 获取天气显示状态
 * 
 * @param completion 
 * EN: Completion callback with weather display status and error if any
 *     enabled: Whether weather display is enabled
 *     error: Error information if failed, nil if successful
 * CN: 完成回调，返回天气显示状态和错误信息（如果有）
 *     enabled: 天气显示是否启用
 *     error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Retrieves whether weather information is displayed on device.
 *     When enabled, device will show:
 *     1. Current temperature
 *     2. Weather conditions
 *     3. Daily forecast
 * CN: 获取设备是否显示天气信息。
 *     启用时，设备将显示：
 *     1. 当前温度
 *     2. 天气状况
 *     3. 每日预报
 */
- (void)getWeatherEnableCompletion:(void(^)(BOOL enabled, NSError * _Nullable error))completion;

/**
 * @brief Set weather display status
 * @chinese 设置天气显示状态
 * 
 * @param enable 
 * EN: Whether to enable weather display
 *     YES: Show weather information on device
 *     NO: Hide weather information on device
 * CN: 是否启用天气显示
 *     YES: 在设备上显示天气信息
 *     NO: 在设备上隐藏天气信息
 * 
 * @param completion 
 * EN: Completion callback
 *     success: Whether the setting was successful
 *     error: Error information if failed, nil if successful
 * CN: 设置完成回调
 *     success: 是否设置成功
 *     error: 设置失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Controls whether weather information is displayed on device.
 *     Requires:
 *     1. Active Bluetooth connection
 *     2. Location permission
 *     3. Internet connection for weather updates
 * CN: 控制设备是否显示天气信息。
 *     需要：
 *     1. 活跃的蓝牙连接
 *     2. 位置权限
 *     3. 用于天气更新的网络连接
 */
- (void)setWeatherEnable:(BOOL)enable completion:(TSCompletionBlock)completion;

#pragma mark - Do Not Disturb Mode

/**
 * @brief Set do not disturb mode settings
 * @chinese 设置勿扰模式配置
 * 
 * @param model 
 * EN: TSLunchBreakDNDModel object containing DND settings
 *     - isEnabled: Whether to enable do not disturb mode
 *     - startTime: Start time in minutes from midnight (0-1439)
 *     - endTime: End time in minutes from midnight (0-1439)
 *     Note: end time must be greater than start time
 *     Example: startTime=720 (12:00), endTime=840 (14:00)
 * CN: 包含勿扰模式设置的TSLunchBreakDNDModel对象
 *     - isEnabled: 是否启用勿扰模式
 *     - startTime: 开始时间（从0点开始的分钟数，0-1439）
 *     - endTime: 结束时间（从0点开始的分钟数，0-1439）
 *     注意：结束时间必须大于开始时间
 *     示例：startTime=720（12:00），endTime=840（14:00）
 * 
 * @param completion 
 * EN: Completion callback
 *     success: Whether the setting was successful
 *     error: Error information if failed, nil if successful
 * CN: 设置完成回调
 *     success: 是否设置成功
 *     error: 设置失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Set the time period during which the device will enter do not disturb mode.
 *     If isEnabled is NO, the time period settings will be ignored.
 *     This feature:
 *     1. Helps users focus during specific time periods
 *     2. Prevents unnecessary notifications and disturbances
 *     3. Can be customized for user's preferred quiet hours
 * CN: 设置设备进入勿扰模式的生效时间段。
 *     如果isEnabled为NO，时间段设置将被忽略。
 *     此功能：
 *     1. 帮助用户在特定时间段保持专注
 *     2. 防止不必要的通知和打扰
 *     3. 可以根据用户的偏好设置安静时间
 */
- (void)setDoNotDisturb:(TSDoNotDisturbModel *)model
                 completion:(TSCompletionBlock)completion;

/**
 * @brief Get do not disturb mode settings
 * @chinese 获取勿扰模式配置
 * 
 * @param completion 
 * EN: Completion callback
 *     - model: TSLunchBreakDNDModel object containing current settings, nil if failed
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成回调
 *     - model: 包含当前设置的TSLunchBreakDNDModel对象，获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Get the current do not disturb mode settings, including:
 *     1. Whether the feature is enabled
 *     2. The time period during which the feature is active
 *     Used to:
 *     1. Initialize app settings display
 *     2. Verify setting changes
 *     3. Sync settings between app and device
 * CN: 获取当前勿扰模式的设置，包括：
 *     1. 功能是否启用
 *     2. 功能的生效时间段
 *     用于：
 *     1. 初始化应用设置显示
 *     2. 验证设置更改
 *     3. 同步应用和设备设置
 */
- (void)getDoNotDisturbInfo:(void(^)(TSDoNotDisturbModel * _Nullable model,
                                          NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
