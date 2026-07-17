//
//  TSAutoMonitorConfigs.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/24.
//

#import "TSKitBaseModel.h"
#import "TSMonitorSchedule.h"
#import "TSMonitorAlert.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSAutoMonitorConfigs : TSKitBaseModel

/**
 * @brief Monitor schedule
 * @chinese 监测计划
 *
 * @discussion
 * [EN]: Includes enable switch, start/end time (minutes from 00:00), and interval.
 * [CN]: 包含开关、开始/结束时间（距0点分钟数）与间隔。
 */
@property (nonatomic, strong) TSMonitorSchedule *schedule;

/**
 * @brief Alert configuration
 * @chinese 告警配置
 *
 * @discussion
 * [EN]: Threshold-based alert policy. Unit depends on monitor type
 *       (e.g., bpm for heart rate, percent for SpO2, mmHg for blood pressure).
 * [CN]: 基于阈值的告警策略。单位随监测类型而定
 *       （如心率用 bpm，血氧用百分比，血压用 mmHg）。
 */
@property (nonatomic, strong, nullable) TSMonitorAlert *alert;

@end

NS_ASSUME_NONNULL_END
