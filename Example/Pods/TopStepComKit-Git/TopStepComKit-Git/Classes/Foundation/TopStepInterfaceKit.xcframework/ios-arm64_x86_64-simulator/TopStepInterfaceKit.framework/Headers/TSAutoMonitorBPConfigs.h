//
//  TSAutoMonitorBPConfigs.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/14.
//

#import "TSKitBaseModel.h"
#import "TSMonitorSchedule.h"
#import "TSMonitorBPAlert.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSAutoMonitorBPConfigs : TSKitBaseModel

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
 * @brief Blood pressure alert configuration
 * @chinese 血压告警配置
 *
 * @discussion
 * [EN]: Blood pressure threshold-based alert policy with separate systolic and diastolic limits.
 *       Units: mmHg (millimeters of mercury).
 * [CN]: 基于阈值的血压告警策略，分别设置收缩压和舒张压的上下限。
 *       单位：毫米汞柱（mmHg）。
 */
@property (nonatomic, strong, nullable) TSMonitorBPAlert *alert;

@end

NS_ASSUME_NONNULL_END
