//
//  TSAutoMonitorHRConfigs.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/24.
//

#import "TSKitBaseModel.h"
#import "TSMonitorSchedule.h"
#import "TSMonitorAlert.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Heart rate auto monitor configuration
 * @chinese 心率自动监测配置
 *
 * @discussion
 * [EN]: Configuration for automatic heart rate monitoring, including:
 *       - Monitor schedule (enable/start/end/interval)
 *       - Resting heart rate alert thresholds
 *       - Exercise heart rate alert thresholds  
 *       - Maximum heart rate for zone calculation
 * [CN]: 心率自动监测的配置，包括：
 *       - 监测计划（开关/开始/结束/间隔）
 *       - 静息心率告警阈值
 *       - 运动心率告警阈值
 *       - 心率区间计算的最大值
 */
@interface TSAutoMonitorHRConfigs : TSKitBaseModel

#pragma mark - Monitor Configuration

/**
 * @brief Monitor schedule
 * @chinese 监测计划
 *
 * @discussion
 * [EN]: Includes enable switch, start/end time (minutes from 00:00), and interval.
 * [CN]: 包含开关、开始/结束时间（距0点分钟数）与间隔。
 */
@property (nonatomic, strong) TSMonitorSchedule *schedule;

#pragma mark - Heart Rate Alerts

/**
 * @brief Resting heart rate alert configuration
 * @chinese 静息心率告警配置
 *
 * @discussion
 * [EN]: Threshold-based alert policy for resting heart rate monitoring.
 *       Units: bpm (beats per minute).
 * [CN]: 静息心率监测的基于阈值的告警策略。
 *       单位：次/分（bpm）。
 */
@property (nonatomic, strong, nullable) TSMonitorAlert *restHRAlert;

/**
 * @brief Exercise heart rate alert configuration
 * @chinese 运动心率告警配置
 *
 * @discussion
 * [EN]: Threshold-based alert policy for exercise heart rate monitoring.
 *       Units: bpm (beats per minute).
 * [CN]: 运动心率监测的基于阈值的告警策略。
 *       单位：次/分（bpm）。
 */
@property (nonatomic, strong, nullable) TSMonitorAlert *exerciseHRAlert;

#pragma mark - Heart Rate Zones

/**
 * @brief Maximum exercise heart rate for zone calculation
 * @chinese 运动心率最大值（用于心率分区计算）
 *
 * @discussion
 * [EN]: Used to calculate heart rate zones: warm-up, fat burning, aerobic, anaerobic, and peak.
 *       This value represents the maximum heart rate achievable during exercise.
 * [CN]: 用于计算心率区间：热身、减脂、有氧、无氧、极限等。
 *       此值代表运动期间可达到的最大心率。
 *
 * @note
 * [EN]: Recommended range is 100-220 bpm. Typically calculated as 220 - age.
 * [CN]: 建议范围为100-220次/分。通常按 220 - 年龄 计算。
 */
@property (nonatomic, assign) UInt8 exerciseHRLimitMax;

@end

NS_ASSUME_NONNULL_END
