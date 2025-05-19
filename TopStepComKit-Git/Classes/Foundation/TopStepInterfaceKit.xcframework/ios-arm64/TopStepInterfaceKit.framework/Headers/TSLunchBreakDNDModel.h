//
//  TSLunchBreakDNDModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSLunchBreakDNDModel : NSObject

/**
 * @brief Is All Day DND Enabled
 * @chinese 是否全天免打扰
 *
 * @discussion
 * [EN]: Indicates whether the do not disturb mode is enabled for the entire day.
 *       When enabled, the device will be in do not disturb mode 24/7,
 *       ignoring the start and end time settings.
 * [CN]: 表示是否启用全天免打扰模式。
 *       启用后，设备将全天24小时处于免打扰状态，
 *       忽略开始时间和结束时间的设置。
 *
 * @note
 * [EN]: This setting takes precedence over the time period settings.
 *       When this is enabled, startTime and endTime will be ignored.
 * [CN]: 此设置优先于时间段设置。
 *       当此设置启用时，startTime和endTime将被忽略。
 */
@property (nonatomic, assign) BOOL isAllDayDNDEnabled;

/**
 * @brief Is Period DND Enabled
 * @chinese 是否启用时段免打扰
 *
 * @discussion
 * [EN]: Indicates whether the period-based do not disturb feature is enabled.
 *       When enabled, the device will enter do not disturb mode during the specified time period.
 *       This setting is used when isAllDayDNDEnabled is NO.
 * [CN]: 表示是否启用基于时段的免打扰功能。
 *       启用后，设备将在指定时间段内进入免打扰模式。
 *       此设置在isAllDayDNDEnabled为NO时使用。
 *
 * @note
 * [EN]: This setting is independent of isAllDayDNDEnabled.
 *       When isAllDayDNDEnabled is YES, this setting will be ignored.
 * [CN]: 此设置与isAllDayDNDEnabled相互独立。
 *       当isAllDayDNDEnabled为YES时，此设置将被忽略。
 */
@property (nonatomic, assign) BOOL isPeriodDNDEnabled;

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

@end

NS_ASSUME_NONNULL_END
