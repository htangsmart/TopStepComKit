//
//  TSDoNotDisturbModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Do Not Disturb Mode Configuration Model
 * @chinese 勿扰模式配置模型
 *
 * @discussion
 * EN: This model is used to configure the device's do not disturb mode settings,
 *     including all-day mode and time period mode.
 * CN: 此模型用于配置设备的勿扰模式设置，
 *     包括全天模式和时段模式。
 */
@interface TSDoNotDisturbModel : NSObject

/**
 * @brief Whether all-day do not disturb mode is enabled
 * @chinese 是否启用全天勿扰模式
 *
 * @discussion
 * EN: When enabled, the device will be in do not disturb mode 24/7,
 *     ignoring the time period settings.
 * CN: 启用时，设备将全天24小时处于勿扰模式，
 *     忽略时间段设置。
 */
@property (nonatomic, assign) BOOL isAllDayEnabled;

/**
 * @brief Whether time period do not disturb mode is enabled
 * @chinese 是否启用时段勿扰模式
 *
 * @discussion
 * EN: When enabled, the device will enter do not disturb mode during the specified time period.
 *     This setting is ignored if all-day mode is enabled.
 * CN: 启用时，设备将在指定时间段内进入勿扰模式。
 *     如果全天模式已启用，则忽略此设置。
 */
@property (nonatomic, assign) BOOL isTimePeriodEnabled;

/**
 * @brief Start time for do not disturb mode
 * @chinese 勿扰模式开始时间
 *
 * @discussion
 * EN: The start time in minutes from midnight (0-1440).
 *     Only effective when time period mode is enabled.
 *     Must be less than endTime.
 * CN: 从午夜开始计算的分钟数（0-1440）。
 *     仅在时段模式启用时有效。
 *     必须小于结束时间。
 */
@property (nonatomic, assign) NSInteger startTime;

/**
 * @brief End time for do not disturb mode
 * @chinese 勿扰模式结束时间
 *
 * @discussion
 * EN: The end time in minutes from midnight (0-1440).
 *     Only effective when time period mode is enabled.
 *     Must be greater than startTime.
 * CN: 从午夜开始计算的分钟数（0-1440）。
 *     仅在时段模式启用时有效。
 *     必须大于开始时间。
 */
@property (nonatomic, assign) NSInteger endTime;

@end

NS_ASSUME_NONNULL_END
