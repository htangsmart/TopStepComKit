//
//  TSDoNotDisturbModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/29.
//

#import "TSKitBaseModel.h"

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
@interface TSDoNotDisturbModel : TSKitBaseModel

/**
 * @brief Whether do not disturb mode is enabled
 * @chinese 是否开启勿扰模式
 *
 * @discussion
 * EN: Controls whether the do not disturb feature is active.
 *     - YES: Do not disturb mode is enabled
 *     - NO: Do not disturb mode is disabled
 * CN: 控制勿扰功能是否激活。
 *     - YES: 勿扰模式已开启
 *     - NO: 勿扰模式已关闭
 */
@property (nonatomic, assign) BOOL isEnabled;

/**
 * @brief Whether it's time period mode
 * @chinese 是否是阶段模式
 *
 * @discussion
 * EN: Determines the type of do not disturb mode.
 *     - YES: Time period mode (do not disturb during specific hours)
 *     - NO: All-day mode (24/7 do not disturb)
 * CN: 确定勿扰模式的类型。
 *     - YES: 阶段模式（指定时间段内勿扰）
 *     - NO: 全天模式（24小时勿扰）
 */
@property (nonatomic, assign) BOOL isTimePeriodMode;

/**
 * @brief Start time for do not disturb mode
 * @chinese 勿扰模式开始时间
 *
 * @discussion
 * EN: The start time in minutes from midnight (0-1440).
 *     Only effective when time period mode is enabled (isTimePeriodMode = YES).
 *     Must be less than endTime.
 * CN: 从午夜开始计算的分钟数（0-1440）。
 *     仅在阶段模式启用时有效（isTimePeriodMode = YES）。
 *     必须小于结束时间。
 */
@property (nonatomic, assign) NSInteger startTime;

/**
 * @brief End time for do not disturb mode
 * @chinese 勿扰模式结束时间
 *
 * @discussion
 * EN: The end time in minutes from midnight (0-1440).
 *     Only effective when time period mode is enabled (isTimePeriodMode = YES).
 *     Must be greater than startTime.
 * CN: 从午夜开始计算的分钟数（0-1440）。
 *     仅在阶段模式启用时有效（isTimePeriodMode = YES）。
 *     必须大于开始时间。
 */
@property (nonatomic, assign) NSInteger endTime;


@end

NS_ASSUME_NONNULL_END
