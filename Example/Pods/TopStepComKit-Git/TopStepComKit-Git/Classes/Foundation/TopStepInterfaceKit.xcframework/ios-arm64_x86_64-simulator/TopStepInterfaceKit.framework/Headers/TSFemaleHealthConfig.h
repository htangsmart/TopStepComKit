//
//  TSFemaleHealthConfig.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/11/19.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Female health mode enumeration
 * @chinese 女性健康模式枚举
 *
 * @discussion
 * [EN]: Defines the different modes for female health tracking:
 *       - Disabled: Feature is turned off
 *       - Menstruation: Menstrual cycle tracking mode
 *       - PregnancyPreparation: Pregnancy preparation tracking mode
 *       - Pregnancy: Pregnancy tracking mode
 * [CN]: 定义女性健康追踪的不同模式：
 *       - Disabled: 功能关闭
 *       - Menstruation: 经期模式
 *       - PregnancyPreparation: 备孕模式
 *       - Pregnancy: 孕期模式
 */
typedef NS_ENUM(NSInteger, TSFemaleHealthMode) {
    TSFemaleHealthModeDisabled          = 0,    //关闭 Disabled
    TSFemaleHealthModeMenstruation      = 1,    //经期模式 Menstruation Mode
    TSFemaleHealthModePregnancyPreparation = 2, //备孕模式 Pregnancy Preparation Mode
    TSFemaleHealthModePregnancy         = 3     //孕期模式 Pregnancy Mode
};

/**
 * @brief Pregnancy reminder type enumeration
 * @chinese 孕期提醒类型枚举
 *
 * @discussion
 * [EN]: Defines the type of pregnancy reminder:
 *       - PregnancyDays: Reminder based on pregnancy days (days since conception)
 *       - DueDateDays: Reminder based on days until due date
 * [CN]: 定义孕期提醒类型：
 *       - PregnancyDays: 基于怀孕天数（自受孕以来的天数）
 *       - DueDateDays: 基于距离预产期的天数
 */
typedef NS_ENUM(NSInteger, TSPregnancyReminderType) {
    TSPregnancyReminderTypePregnancyDays = 0,  //怀孕天数 Pregnancy Days
    TSPregnancyReminderTypeDueDateDays  = 1   //距离预产期天数 Days Until Due Date
};

/**
 * @brief Female health reminder switch options
 * @chinese 女性健康提醒开关选项
 *
 * @discussion
 * [EN]: Bit flags for female health reminder switches. Can be combined using bitwise OR operations.
 *       Which switch is turned on, which reminder will be triggered.
 *       Example: TSFemaleHealthReminderSwitchMenstruationStart | TSFemaleHealthReminderSwitchMenstruationEnd
 *       to enable both menstruation start and end reminders.
 * [CN]: 女性健康提醒开关的位标志。可以使用按位或操作组合多个选项。
 *       哪个开关打开，哪个就能提醒。
 *       示例：TSFemaleHealthReminderSwitchMenstruationStart | TSFemaleHealthReminderSwitchMenstruationEnd
 *       以同时启用经期开始和结束提醒。
 *
 * @note
 * [EN]: Bit values:
 *       - 1: Menstruation start reminder switch
 *       - 2: Menstruation end reminder switch
 *       - 4: Fertile window start reminder switch
 *       - 8: Fertile window end reminder switch
 * [CN]: 位值：
 *       - 1: 经期开始提醒开关
 *       - 2: 经期结束提醒开关
 *       - 4: 易孕期开始提醒开关
 *       - 8: 易孕期结束提醒开关
 */
typedef NS_OPTIONS(NSInteger, TSFemaleHealthReminderSwitch) {
    TSFemaleHealthReminderSwitchNone              = 0,        //无提醒 No Reminder
    ///< [中文]: 经期开始提醒开关，固定时间：预测经期前一天上午8点提醒
    ///< [EN]: Menstruation Start Reminder Switch, Fixed time: Remind at 8 AM one day before predicted menstruation
    TSFemaleHealthReminderSwitchMenstruationStart = 1 << 0,
    ///< [中文]: 经期结束提醒开关，固定时间：经期结束当天上午8点提醒
    ///< [EN]: Menstruation End Reminder Switch, Fixed time: Remind at 8 AM on the day menstruation ends
    TSFemaleHealthReminderSwitchMenstruationEnd   = 1 << 1,
    ///< [中文]: 易孕期开始提醒开关，固定时间：易孕期开始当天上午8点提醒
    ///< [EN]: Fertile Window Start Reminder Switch, Fixed time: Remind at 8 AM on the day fertile window starts
    TSFemaleHealthReminderSwitchFertileWindowStart = 1 << 2,
    ///< [中文]: 易孕期结束提醒开关，固定时间：易孕期结束当天上午8点提醒
    ///< [EN]: Fertile Window End Reminder Switch, Fixed time: Remind at 8 AM on the day fertile window ends
    TSFemaleHealthReminderSwitchFertileWindowEnd   = 1 << 3,
    ///< [中文]: 所有提醒开关 All Reminder Switches
    ///< [EN]: All Reminder Switches
    TSFemaleHealthReminderSwitchAll = TSFemaleHealthReminderSwitchMenstruationStart |
                                      TSFemaleHealthReminderSwitchMenstruationEnd |
                                      TSFemaleHealthReminderSwitchFertileWindowStart |
                                      TSFemaleHealthReminderSwitchFertileWindowEnd
};

/**
 * @brief Female health configuration model
 * @chinese 女性健康配置模型
 *
 * @discussion
 * [EN]: This model represents female health configuration settings including:
 *       - Health tracking mode (disabled, menstruation, pregnancy preparation, pregnancy)
 *       - Menstrual cycle information (cycle length, duration, last period date)
 *       - Reminder settings (reminder time, advance days, reminder type)
 *       - Pregnancy tracking information (menstruation end day)
 * [CN]: 该模型表示女性健康配置设置，包括：
 *       - 健康追踪模式（关闭、经期、备孕、孕期）
 *       - 月经周期信息（周期长度、经期长度、最近一次经期日期）
 *       - 提醒设置（提醒时间、提前天数、提醒类型）
 *       - 孕期追踪信息（月经结束天数）
 */
@interface TSFemaleHealthConfig : TSKitBaseModel

/**
 * @brief Female health tracking mode
 * @chinese 女性健康追踪模式
 *
 * @discussion
 * [EN]: The current mode for female health tracking.
 *       - Disabled: Feature is turned off
 *       - Menstruation: Track menstrual cycle
 *       - PregnancyPreparation: Track for pregnancy preparation
 *       - Pregnancy: Track pregnancy progress
 * [CN]: 当前女性健康追踪模式。
 *       - Disabled: 功能关闭
 *       - Menstruation: 追踪月经周期
 *       - PregnancyPreparation: 备孕追踪
 *       - Pregnancy: 孕期追踪
 *
 * @note
 * [EN]: Default value is Disabled.
 * [CN]: 默认值为 Disabled。
 */
@property (nonatomic, assign) TSFemaleHealthMode healthMode;

/**
 * @brief Reminder time offset in minutes from midnight
 * @chinese 提醒时间相对于午夜的分钟偏移量
 *
 * @discussion
 * [EN]: Number of minutes from 00:00:00 to the reminder time.
 *       For example, if reminder is at 8:00 AM, this value would be 480 (8 * 60 + 0).
 * [CN]: 从当天00:00:00到提醒时间的分钟数。
 *       例如，如果提醒在早上8:00，此值为480（8 * 60 + 0）。
 *
 * @note
 * [EN]: Valid range is 0-1439 (0:00 to 23:59).
 * [CN]: 有效范围为0-1439（0:00到23:59）。
 */
@property (nonatomic, assign) NSInteger reminderTimeMinutes;

/**
 * @brief Days in advance for reminder
 * @chinese 提前提醒天数
 *
 * @discussion
 * [EN]: Number of days in advance to send reminder before the event.
 *       For example, if set to 1, reminder will be sent 1 day before the expected period or event.
 * [CN]: 在事件发生前提前多少天发送提醒。
 *       例如，如果设置为1，将在预期经期或事件前1天发送提醒。
 *
 * @note
 * [EN]: Valid range is typically 0-7 days.
 * [CN]: 有效范围通常为0-7天。
 */
@property (nonatomic, assign) NSInteger reminderAdvanceDays;

/**
 * @brief Pregnancy reminder type
 * @chinese 孕期提醒类型
 *
 * @discussion
 * [EN]: Type of reminder for pregnancy mode:
 *       - PregnancyDays: Reminder based on pregnancy days (days since conception)
 *       - DueDateDays: Reminder based on days until due date
 * [CN]: 孕期模式的提醒类型：
 *       - PregnancyDays: 基于怀孕天数（自受孕以来的天数）
 *       - DueDateDays: 基于距离预产期的天数
 *
 * @note
 * [EN]: This property is only effective when healthMode is set to Pregnancy.
 * [CN]: 此属性仅在 healthMode 设置为 Pregnancy 时有效。
 */
@property (nonatomic, assign) TSPregnancyReminderType pregnancyReminderType;

/**
 * @brief Menstrual cycle length in days
 * @chinese 月经周期长度（天）
 *
 * @discussion
 * [EN]: The length of the menstrual cycle in days, typically 21-35 days.
 *       This is the number of days from the start of one period to the start of the next period.
 * [CN]: 月经周期的长度（天），通常为21-35天。
 *       这是从一次经期开始到下一次经期开始的天数。
 *
 * @note
 * [EN]: Valid range is typically 21-35 days. Average is 28 days.
 * [CN]: 有效范围通常为21-35天。平均值为28天。
 */
@property (nonatomic, assign) NSInteger menstrualCycleLength;

/**
 * @brief Menstrual period duration in days
 * @chinese 经期长度（天）
 *
 * @discussion
 * [EN]: The duration of menstrual bleeding in days, typically 3-7 days.
 *       This is the number of days from the start to the end of menstrual bleeding.
 * [CN]: 月经出血的持续时间（天），通常为3-7天。
 *       这是从月经开始到结束的天数。
 *
 * @note
 * [EN]: Valid range is typically 3-7 days. Average is 5 days.
 * [CN]: 有效范围通常为3-7天。平均值为5天。
 */
@property (nonatomic, assign) NSInteger menstrualPeriodDuration;

/**
 * @brief Timestamp of the last menstrual period start date
 * @chinese 最近一次经期开始日期的时间戳
 *
 * @discussion
 * [EN]: Unix timestamp (in seconds since 1970) representing the start date of the last menstrual period.
 *       This is used to calculate the next expected period and track the menstrual cycle.
 * [CN]: Unix时间戳（自1970年以来的秒数），表示最近一次经期的开始日期。
 *       用于计算下一次预期经期和追踪月经周期。
 *
 * @note
 * [EN]: The timestamp should represent 00:00:00 of the start date.
 *       If not set, the value is 0.
 * [CN]: 时间戳应表示开始日期的00:00:00。
 *       如果未设置，值为0。
 */
@property (nonatomic, assign) NSTimeInterval lastPeriodStartTimestamp;

/**
 * @brief Day when menstruation ends (day of cycle)
 * @chinese 月经结束是第几天（周期中的第几天）
 *
 * @discussion
 * [EN]: The day number in the cycle when menstruation ends.
 *       For example, if period starts on day 1 and ends on day 5, this value would be 5.
 *       This is used to track the current state of the menstrual cycle.
 * [CN]: 月经结束在周期中的第几天。
 *       例如，如果经期从第1天开始，到第5天结束，此值为5。
 *       用于追踪月经周期的当前状态。
 *
 * @note
 * [EN]: Valid range is typically 1-7 days. Value 0 indicates menstruation has ended or not started.
 * [CN]: 有效范围通常为1-7天。值0表示月经已结束或未开始。
 */
@property (nonatomic, assign) NSInteger menstruationEndDayInCycle;

/**
 * @brief Female health reminder switches
 * @chinese 女性健康提醒开关
 *
 * @discussion
 * [EN]: Bit flags indicating which female health reminder switches are turned on.
 *       Which switch is turned on, which reminder will be triggered.
 *       Can be combined using bitwise OR operations to enable multiple reminders simultaneously.
 *       Example: TSFemaleHealthReminderSwitchMenstruationStart | TSFemaleHealthReminderSwitchMenstruationEnd
 *       enables both menstruation start and end reminders.
 * [CN]: 位标志，指示哪些女性健康提醒开关已打开。
 *       哪个开关打开，哪个就能提醒。
 *       可以使用按位或操作组合多个提醒开关。
 *       示例：TSFemaleHealthReminderSwitchMenstruationStart | TSFemaleHealthReminderSwitchMenstruationEnd
 *       启用经期开始和结束提醒。
 *
 * @note
 * [EN]: This property is not supported by all projects. Please check the current project's capabilities.
 * [CN]: 此属性并不是所有项目都支持，具体要看当前项目。
 */
@property (nonatomic, assign) TSFemaleHealthReminderSwitch reminderSwitches;

@end

NS_ASSUME_NONNULL_END
