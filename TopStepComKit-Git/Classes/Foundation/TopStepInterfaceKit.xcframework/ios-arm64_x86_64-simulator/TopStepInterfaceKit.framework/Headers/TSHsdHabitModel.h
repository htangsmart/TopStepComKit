//
//  TSHsdHabitModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/9/21.
//

#import "TSKitBaseModel.h"
#import "TSAlarmClockModel.h"
#import "TSHsdDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Habit model
 * @chinese 习惯模型
 *
 * @discussion
 * [EN]: Huashengda customer-specific feature.
 *      Exchanged through TSHuashengdaInterface.fetchHabits: / setHabits:completion:,
 *      at most TSHsdHabitMaxCount (10) habits per device.
 * [CN]: 华盛达定制能力。
 *      通过 TSHuashengdaInterface.fetchHabits: / setHabits:completion: 读写，每台设备最多 TSHsdHabitMaxCount（10）条。
 */
@interface TSHsdHabitModel : TSKitBaseModel <NSCopying>

/**
 * @brief Habit identifier
 * @chinese 习惯 ID
 */
@property (nonatomic, assign) NSInteger habitId;

/**
 * @brief Habit type
 * @chinese 习惯类型
 *
 * @discussion
 * [EN]: See TSHsdHabitType. label is only meaningful when the type is TSHsdHabitTypeCustom.
 * [CN]: 见 TSHsdHabitType。仅当类型为 TSHsdHabitTypeCustom 时 label 有效。
 */
@property (nonatomic, assign) TSHsdHabitType type;

/**
 * @brief Habit label
 * @chinese 习惯标签
 *
 * @discussion
 * [EN]: At most TSHsdHabitLabelMaxBytes (32) UTF-8 bytes; longer values fail validation.
 * [CN]: UTF-8 最多 TSHsdHabitLabelMaxBytes（32）字节，超出时校验失败。
 */
@property (nonatomic, copy, nullable) NSString *label;

/**
 * @brief Execution time of the habit
 * @chinese 习惯执行时间
 *
 * @discussion
 * [EN]: Minutes since midnight, valid range [0, 1439] (e.g. 11:30 = 690).
 * [CN]: 距零点的分钟数，取值范围 [0, 1439]（如 11:30 = 690）。
 */
@property (nonatomic, assign) NSInteger minuteOfDay;

/**
 * @brief Habit duration
 * @chinese 习惯时长
 *
 * @discussion
 * [EN]: In minutes.
 * [CN]: 单位为分钟。
 */
@property (nonatomic, assign) NSInteger duration;

/**
 * @brief Weekly repeat options
 * @chinese 星期重复选项
 *
 * @discussion
 * [EN]: Uses TSAlarmRepeat; combine days with |, e.g. TSAlarmRepeatMonday | TSAlarmRepeatFriday. TSAlarmRepeatNone means one-off.
 * [CN]: 使用闹钟的 TSAlarmRepeat，多天用 | 组合，如 TSAlarmRepeatMonday | TSAlarmRepeatFriday。TSAlarmRepeatNone 表示仅一次。
 */
@property (nonatomic, assign) TSAlarmRepeat repeatOptions;

/**
 * @brief Habit state
 * @chinese 习惯状态
 *
 * @discussion
 * [EN]: See TSHsdHabitState. Maintained by the device as the user checks in.
 * [CN]: 见 TSHsdHabitState。由设备随用户打卡维护。
 */
@property (nonatomic, assign) TSHsdHabitState state;

/**
 * @brief Days the goal has been reached
 * @chinese 已达成目标天数
 */
@property (nonatomic, assign) NSInteger reachGoalDays;

/**
 * @brief Maximum days the goal has been reached consecutively
 * @chinese 最大达成目标天数
 */
@property (nonatomic, assign) NSInteger maxReachGoalDays;

/**
 * @brief Total task days of the habit
 * @chinese 习惯任务天数
 */
@property (nonatomic, assign) NSInteger taskDays;

/**
 * @brief Function associated with the habit
 * @chinese 关联功能
 *
 * @discussion
 * [EN]: See TSHsdHabitAssociatedFunction.
 * [CN]: 见 TSHsdHabitAssociatedFunction。
 */
@property (nonatomic, assign) TSHsdHabitAssociatedFunction associatedFunction;

/**
 * @brief Reminder duration
 * @chinese 提醒时长
 *
 * @discussion
 * [EN]: In seconds.
 * [CN]: 单位为秒。
 */
@property (nonatomic, assign) NSInteger remindDuration;

/**
 * @brief Advance reminder time
 * @chinese 提前提醒时间
 *
 * @discussion
 * [EN]: Minutes before minuteOfDay at which the device reminds the user.
 * [CN]: 在 minuteOfDay 之前多少分钟提醒，单位为分钟。
 */
@property (nonatomic, assign) NSInteger remindAdvance;

/**
 * @brief Month of the latest goal achievement
 * @chinese 最近达成目标的月份
 *
 * @discussion
 * [EN]: Range [1, 12]; 0 means none.
 * [CN]: 取值范围 [1, 12]；0 表示无。
 */
@property (nonatomic, assign) NSInteger latestAchieveGoalMonth;

/**
 * @brief Day of the latest goal achievement
 * @chinese 最近达成目标的日期
 *
 * @discussion
 * [EN]: Range [1, 31]; 0 means none.
 * [CN]: 取值范围 [1, 31]；0 表示无。
 */
@property (nonatomic, assign) NSInteger latestAchieveGoalDay;

/**
 * @brief Weekdays on which the goal was reached in the past week
 * @chinese 过去一周达成目标的星期标志位
 *
 * @discussion
 * [EN]: Uses TSAlarmRepeat; each included day means the goal was achieved that day. Reported by the device, read-only.
 * [CN]: 使用 TSAlarmRepeat 表示，包含某天即该天达成目标。由设备上报，仅供展示。
 */
@property (nonatomic, assign) TSAlarmRepeat achieveGoalRepeat;

@end

NS_ASSUME_NONNULL_END
