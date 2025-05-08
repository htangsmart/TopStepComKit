//
//  TSRemindersModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Reminder Type
 * @chinese 提醒类型
 *
 * @discussion
 * [EN]: Type of the reminder, indicating whether it's unknown, built-in, or custom.
 * [CN]: 提醒的类型，表示是未知、内置还是自定义类型。
 */
typedef NS_ENUM(NSInteger, ReminderType) {
    ReminderTypeUnknown, // Unknown
    ReminderTypeBuiltIn, // Built-in
    ReminderTypeCustom   // Custom
};

/**
 * @brief Reminder Days
 * @chinese 提醒重复日期
 *
 * @discussion
 * [EN]: Bitwise options for specifying which days of the week the reminder should repeat.
 *       Can be combined using bitwise OR operator (|).
 *       Example: ReminderDayMonday | ReminderDayWednesday | ReminderDayFriday
 * [CN]: 使用位运算选项指定提醒在星期几重复。
 *       可以使用位运算符（|）组合多个选项。
 *       示例：ReminderDayMonday | ReminderDayWednesday | ReminderDayFriday
 */
typedef NS_OPTIONS(NSInteger, ReminderDays) {
    ReminderDayMonday    = 1 << 0, // Monday
    ReminderDayTuesday   = 1 << 1, // Tuesday
    ReminderDayWednesday = 1 << 2, // Wednesday
    ReminderDayThursday  = 1 << 3, // Thursday
    ReminderDayFriday    = 1 << 4, // Friday
    ReminderDaySaturday  = 1 << 5, // Saturday
    ReminderDaySunday    = 1 << 6, // Sunday

    ReminderRepeatWorkday   = ReminderDayMonday | ReminderDayTuesday | ReminderDayWednesday |
    ReminderDayThursday | ReminderDayFriday,                       ///< [EN]: Repeat on workdays

    ReminderRepeatWeekday   = ReminderDaySaturday | ReminderDaySunday,///< [EN]: Repeat on weekends

    ReminderRepeatEveryday  = ReminderRepeatWorkday | ReminderRepeatWeekday ///< [EN]: Repeat everyday
};

/**
 * @brief Reminder Time Type
 * @chinese 提醒时间类型
 *
 * @discussion
 * [EN]: Specifies whether the reminder is set for a specific point in time or a time period.
 *       When set to ReminderTimeTypePeriod, startTime, endTime, and interval properties are used.
 * [CN]: 指定提醒是在特定时间点还是在一段时间内进行。
 *       当设置为 ReminderTimeTypePeriod 时，将使用 startTime、endTime 和 interval 属性。
 */
typedef NS_ENUM(NSInteger, ReminderTimeType) {
    ReminderTimeTypePeriod, // Period of time
    ReminderTimeTypePoint, // Point in time
};

@interface TSRemindersModel : NSObject

/**
 * @brief Reminder ID
 * @chinese 提醒ID
 *
 * @discussion
 * [EN]: Unique identifier for the reminder.
 * [CN]: 提醒的唯一标识符。久坐：0  、喝水：1 、吃药：2
 */
@property (nonatomic, strong) NSString *reminderId;


/**
 * @brief Reminder Name
 * @chinese 提醒名称
 *
 * @discussion
 * [EN]: Name of the reminder.
 * [CN]: 提醒的名称。
 */
@property (nonatomic, strong) NSString *reminderName;

/**
 * @brief Is Enabled
 * @chinese 是否开启
 *
 * @discussion
 * [EN]: Indicates if the reminder is enabled.
 * [CN]: 表示提醒是否启用。
 */
@property (nonatomic, assign) BOOL isEnabled;

/**
 * @brief Reminder Type
 * @chinese 提醒类型
 *
 * @discussion
 * [EN]: Type of the reminder (unknown, built-in, custom).
 * [CN]: 提醒的类型（未知、内置、自定义）。
 */
@property (nonatomic, assign) ReminderType reminderType;

/**
 * @brief Repeat Days
 * @chinese 提醒循环
 *
 * @discussion
 * [EN]: Days of the week the reminder repeats (bitwise options).
 * [CN]: 提醒重复的星期几（位运算选项）。
 */
@property (nonatomic, assign) ReminderDays repeatDays;

/**
 * @brief Time Type
 * @chinese 时间类型
 *
 * @discussion
 * [EN]: Type of time (point or period). When timeType is set to period, startTime, endTime, and interval are effective.
 * [CN]: 时间类型（时间点或时间段）。当timeType设置为时间段时，startTime、endTime和interval才生效。
 */
@property (nonatomic, assign) ReminderTimeType timeType;

/**
 * @brief Start Time
 * @chinese 开始时间
 *
 * @discussion
 * [EN]: Start time of the reminder in minutes from 0. For example, 360 represents 6 AM.
 * [CN]: 提醒的开始时间，以分钟为单位，从0开始。例如，360表示早上6点。
 */
@property (nonatomic, assign) NSInteger startTime;

/**
 * @brief End Time
 * @chinese 结束时间
 *
 * @discussion
 * [EN]: End time of the reminder in minutes from 0. For example, 720 represents 12 PM.
 * [CN]: 提醒的结束时间，以分钟为单位，从0开始。例如，720表示中午12点。
 */
@property (nonatomic, assign) NSInteger endTime;

/**
 * @brief Interval
 * @chinese 时间间隔
 *
 * @discussion
 * [EN]: Interval between reminders in minutes.
 * [CN]: 提醒之间的时间间隔，以分钟为单位。
 */
@property (nonatomic, assign) NSInteger interval;

/**
 * @brief Time Points
 * @chinese 时间点
 *
 * @discussion
 * [EN]: Array of specific time points for the reminder, where each element is an NSNumber representing the offset in minutes from 0. For example, [360, 720] indicates reminders at 6 AM and 12 PM.
 * [CN]: 提醒的具体时间点数组，每个元素为NSNumber类型，表示从0开始的偏移分钟数。例如，【360，720】表示早上6点和中午12点提醒。
 */
@property (nonatomic, strong) NSArray<NSNumber *> *timePoints;

/**
 * @brief Is No Disturb
 * @chinese 是否午休免打扰
 *
 * @discussion
 * [EN]: Indicates if Do Not Disturb is enabled during lunch.
 * [CN]: 表示午休期间是否启用免打扰。
 */
@property (nonatomic, assign) BOOL isNoDisturb;

/**
 * @brief No Disturb Start Time
 * @chinese 免打扰开始时间
 *
 * @discussion
 * [EN]: Start time for Do Not Disturb in minutes from 0 (e.g., 360 for 6 AM).
 * [CN]: 免打扰的开始时间，以分钟为单位，从0开始（例如，360表示早上6点）。
 */
@property (nonatomic, assign) NSInteger noDisturbStartTime;

/**
 * @brief No Disturb End Time
 * @chinese 免打扰结束时间
 *
 * @discussion
 * [EN]: End time for Do Not Disturb in minutes from 0 (e.g., 720 for 12 PM).
 * [CN]: 免打扰的结束时间，以分钟为单位，从0开始（例如，720表示中午12点）。
 */
@property (nonatomic, assign) NSInteger noDisturbEndTime;

/**
 * @brief Notes
 * @chinese 提醒备注
 *
 * @discussion
 * [EN]: Additional notes for the reminder.
 * [CN]: 提醒的附加备注。
 */
@property (nonatomic, strong) NSString *notes;

@end

NS_ASSUME_NONNULL_END
