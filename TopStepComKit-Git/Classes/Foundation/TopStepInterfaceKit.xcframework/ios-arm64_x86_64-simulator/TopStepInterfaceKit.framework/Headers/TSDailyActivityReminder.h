//
//  TSDailyActivityReminder.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/4.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Daily exercise reminder switches
 * @chinese 每日运动目标提醒配置
 *
 * @discussion
 * EN: Stores reminder switches corresponding to daily goals: steps, calories, distance,
 * activity duration, exercise duration, and exercise frequency.
 * CN: 存储与每日目标对应的提醒开关：步数、卡路里、距离、活动时长、运动时长与运动次数。
 */
@interface TSDailyActivityReminder : TSKitBaseModel

#pragma mark - Reminder Settings

/**
 * @brief Steps goal reminder enabled
 * @chinese 步数目标提醒是否开启
 *
 * @discussion
 * EN: Indicates whether reminder notifications are enabled for steps goal achievement.
 *     When enabled, the device will notify the user when the daily steps goal is reached.
 * CN: 表示是否开启步数目标达成提醒通知。
 *     开启后，当达到每日步数目标时，设备会通知用户。
 */
@property (nonatomic, assign) BOOL stepsReminderEnabled;

/**
 * @brief Calories goal reminder enabled
 * @chinese 卡路里目标提醒是否开启
 *
 * @discussion
 * EN: Indicates whether reminder notifications are enabled for calories goal achievement.
 *     When enabled, the device will notify the user when the daily calories goal is reached.
 * CN: 表示是否开启卡路里目标达成提醒通知。
 *     开启后，当达到每日卡路里目标时，设备会通知用户。
 */
@property (nonatomic, assign) BOOL caloriesReminderEnabled;

/**
 * @brief Distance goal reminder enabled
 * @chinese 距离目标提醒是否开启
 *
 * @discussion
 * EN: Indicates whether reminder notifications are enabled for distance goal achievement.
 *     When enabled, the device will notify the user when the daily distance goal is reached.
 * CN: 表示是否开启距离目标达成提醒通知。
 *     开启后，当达到每日距离目标时，设备会通知用户。
 */
@property (nonatomic, assign) BOOL distanceReminderEnabled;

/**
 * @brief Activity times goal reminder enabled
 * @chinese 活动次数目标提醒是否开启
 *
 * @discussion
 * EN: Indicates whether reminder notifications are enabled for activity times goal achievement.
 *     When enabled, the device will notify the user when the daily activity times goal is reached.
 * CN: 表示是否开启活动次数目标达成提醒通知。
 *     开启后，当达到每日活动次数目标时，设备会通知用户。
 */
@property (nonatomic, assign) BOOL activityTimesReminderEnabled;

/**
 * @brief Activity duration goal reminder enabled
 * @chinese 活动时长目标提醒是否开启
 *
 * @discussion
 * EN: Indicates whether reminder notifications are enabled for activity duration goal achievement.
 *     When enabled, the device will notify the user when the daily activity duration goal is reached.
 * CN: 表示是否开启活动时长目标达成提醒通知。
 *     开启后，当达到每日活动时长目标时，设备会通知用户。
 */
@property (nonatomic, assign) BOOL activityDurationReminderEnabled;

/**
 * @brief Exercise times goal reminder enabled
 * @chinese 运动次数目标提醒是否开启
 *
 * @discussion
 * EN: Indicates whether reminder notifications are enabled for exercise times goal achievement.
 *     When enabled, the device will notify the user when the daily exercise times goal is reached.
 * CN: 表示是否开启运动次数目标达成提醒通知。
 *     开启后，当达到每日运动次数目标时，设备会通知用户。
 */
@property (nonatomic, assign) BOOL exerciseTimesReminderEnabled;

/**
 * @brief Exercise duration goal reminder enabled
 * @chinese 运动时长目标提醒是否开启
 *
 * @discussion
 * EN: Indicates whether reminder notifications are enabled for exercise duration goal achievement.
 *     When enabled, the device will notify the user when the daily exercise duration goal is reached.
 * CN: 表示是否开启运动时长目标达成提醒通知。
 *     开启后，当达到每日运动时长目标时，设备会通知用户。
 */
@property (nonatomic, assign) BOOL exerciseDurationReminderEnabled;



@end

NS_ASSUME_NONNULL_END


