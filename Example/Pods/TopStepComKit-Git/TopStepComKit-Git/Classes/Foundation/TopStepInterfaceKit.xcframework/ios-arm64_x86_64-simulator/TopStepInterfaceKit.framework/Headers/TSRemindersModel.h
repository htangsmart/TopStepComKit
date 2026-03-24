//
//  TSRemindersModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/21.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Reminder Type
 * @chinese 提醒类型
 *
 * @discussion
 * [EN]: Type of the reminder, indicating whether it's unknown, sedentary, drinking water,taking medicine, or custom .
 * [CN]: 提醒的类型，表示是未知、久坐、喝水、吃药还是自定义类型。
 */
typedef NS_ENUM(NSInteger, TSReminderType) {
    eTSReminderTypeUnknown = 0,        // Unknown
    eTSReminderTypeSedentary = 1,      // Sedentary reminder
    eTSReminderTypeDrinking = 2,       // Drinking water reminder
    eTSReminderTypeTakeMedicine = 3,   // Taking medicine reminder
    eTSReminderTypeCustom = 4,         // Custom
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
typedef NS_OPTIONS(NSInteger, TSReminderDays) {
    eTSReminderDayMonday    = 1 << 0, // Monday
    eTSReminderDayTuesday   = 1 << 1, // Tuesday
    eTSReminderDayWednesday = 1 << 2, // Wednesday
    eTSReminderDayThursday  = 1 << 3, // Thursday
    eTSReminderDayFriday    = 1 << 4, // Friday
    eTSReminderDaySaturday  = 1 << 5, // Saturday
    eTSReminderDaySunday    = 1 << 6, // Sunday

    eTSReminderRepeatWorkday =  eTSReminderDayMonday |
                                eTSReminderDayTuesday |
                                eTSReminderDayWednesday |
                                eTSReminderDayThursday |
                                eTSReminderDayFriday, ///< [EN]: Repeat on workdays

    eTSReminderRepeatWeekday    = eTSReminderDaySaturday |
                                eTSReminderDaySunday,///< [EN]: Repeat on weekends

    eTSReminderRepeatEveryday   = eTSReminderRepeatWorkday |
                                eTSReminderRepeatWeekday ///< [EN]: Repeat everyday
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
typedef NS_ENUM(NSInteger, TSReminderTimeType) {
    eTSReminderTimeTypePeriod, // Period of time
    eTSReminderTimeTypePoint, // Point in time
};

/**
 * @brief Reminder model class
 * @chinese 提醒模型类
 *
 * @discussion
 * [EN]: This class represents a reminder on the device.
 *
 *       ⚠️ IMPORTANT: DO NOT create instances of this class directly!
 *
 *       To obtain reminder instances:
 *       • For existing reminders: Use getAllRemindersWithCompletion: from TSRemindersInterface
 *       • For new custom reminders: Use createCustomReminderTemplateWithCompletion: from TSRemindersInterface
 *
 *       After obtaining a reminder instance, you can:
 *       1. Modify its properties (name, time, repeat days, etc.)
 *       2. Call updateReminder: to save changes to the device
 *       3. Call deleteReminderWithId: to remove custom reminders
 *
 * [CN]: 此类表示设备上的提醒。
 *
 *       ⚠️ 重要：请勿直接创建此类的实例！
 *
 *       获取提醒实例的方法：
 *       • 获取现有提醒：使用 TSRemindersInterface 的 getAllRemindersWithCompletion: 方法
 *       • 创建新的自定义提醒：使用 TSRemindersInterface 的 createCustomReminderTemplateWithCompletion: 方法
 *
 *       获取提醒实例后，您可以：
 *       1. 修改其属性（名称、时间、重复日期等）
 *       2. 调用 updateReminder: 将更改保存到设备
 *       3. 调用 deleteReminderWithId: 删除自定义提醒
 *
 * @note
 * [EN]: Built-in reminders (sedentary, drinking water, taking medicine) cannot be deleted,
 *       only modified. Custom reminders can be fully managed.
 * [CN]: 内置提醒（久坐、喝水、吃药）无法删除，只能修改。自定义提醒可以完全管理。
 */
@interface TSRemindersModel : TSKitBaseModel

#pragma mark - Properties

/**
 * @brief Reminder ID
 * @chinese 提醒ID
 *
 * @discussion
 * [EN]: Unique identifier for the reminder.
 *       This ID is automatically assigned by the system.
 * [CN]: 提醒的唯一标识符。
 *       此ID由系统自动分配。
 *
 * @note
 * [EN]: Do not manually assign or modify this ID.
 *       Use createCustomReminderTemplateWithCompletion: to get a reminder with a valid ID.
 * [CN]: 请勿手动分配或修改此ID。
 *       使用 createCustomReminderTemplateWithCompletion: 获取具有有效ID的提醒。
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
@property (nonatomic, assign) TSReminderType reminderType;

/**
 * @brief Repeat Days
 * @chinese 提醒循环
 *
 * @discussion
 * [EN]: Days of the week the reminder repeats (bitwise options).
 * [CN]: 提醒重复的星期几（位运算选项）。
 */
@property (nonatomic, assign) TSReminderDays repeatDays;

/**
 * @brief Time Type
 * @chinese 时间类型
 *
 * @discussion
 * [EN]: Type of time (point or period). When timeType is set to period, startTime, endTime, and interval are effective.
 * [CN]: 时间类型（时间点或时间段）。当timeType设置为时间段时，startTime、endTime和interval才生效。
 */
@property (nonatomic, assign) TSReminderTimeType timeType;

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
 * @brief Notes
 * @chinese 提醒备注
 *
 * @discussion
 * [EN]: Additional notes for the reminder.
 * [CN]: 提醒的附加备注。
 */
@property (nonatomic, strong) NSString *notes;

/**
 * @brief Is Lunch Break DND Enabled
 * @chinese 是否开启午休免打扰
 *
 * @discussion
 * [EN]: Indicates whether the lunch break do not disturb feature is enabled.
 *       When enabled, the device will enter do not disturb mode during lunch break.
 * [CN]: 表示是否启用午休免打扰功能。
 *       启用后，设备将在午休时间进入免打扰模式。
 */
@property (nonatomic, assign) BOOL isLunchBreakDNDEnabled;

/**
 * @brief Lunch Break DND Start Time
 * @chinese 午休免打扰开始时间
 *
 * @discussion
 * [EN]: Start time of lunch break DND in minutes from 0.
 *       Recommended time: 720 (12:00)
 * [CN]: 午休免打扰的开始时间，以分钟为单位，从0开始。
 *       建议时间：720（12:00）
 */
@property (nonatomic, assign) NSInteger lunchBreakDNDStartTime;

/**
 * @brief Lunch Break DND End Time
 * @chinese 午休免打扰结束时间
 *
 * @discussion
 * [EN]: End time of lunch break DND in minutes from 0.
 *       Recommended time: 840 (14:00)
 * [CN]: 午休免打扰的结束时间，以分钟为单位，从0开始。
 *       建议时间：840（14:00）
 */
@property (nonatomic, assign) NSInteger lunchBreakDNDEndTime;

/**
 * @brief Check if reminders array has errors
 * @chinese 检查提醒数组是否有错误
 *
 * @param reminders
 * [EN]: Array of reminder models to validate.
 * [CN]: 要验证的提醒模型数组。
 *
 * @discussion
 * [EN]: Validates an array of reminder models by checking each individual model.
 *        Returns the first error encountered, or nil if all models are valid.
 *        This method is useful for batch validation before setting multiple reminders.
 * [CN]: 通过检查每个单独的模型来验证提醒模型数组。
 *       返回遇到的第一个错误，如果所有模型都有效则返回nil。
 *       此方法在设置多个提醒之前进行批量验证时很有用。
 *
 * @note
 * [EN]: If the reminders array is nil or empty, this method returns nil (no error).
 *       The validation stops at the first error found to improve performance.
 * [CN]: 如果提醒数组为nil或为空，此方法返回nil（无错误）。
 *       验证在发现第一个错误时停止，以提高性能。
 */
+ (NSError *)doesRemindersHasError:(NSArray<TSRemindersModel *> *)reminders ;

@end

NS_ASSUME_NONNULL_END
