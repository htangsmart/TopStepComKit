//
//  TSActivityDailyModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/10/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSMetaActivityCurrent;

NS_ASSUME_NONNULL_BEGIN

@interface TSActivityDailyModel (Npk)

/**
 * @brief Convert a current activity report (_ActivityCurrent) to TSActivityDailyModel
 * @chinese 将当前活动数据上报（_ActivityCurrent）转换为 TSActivityDailyModel
 *
 * @param current
 * [EN]: Message reported by device via 0x05-0x40
 * [CN]: 设备通过 0x05-0x40 上报的消息
 *
 * @return
 * [EN]: Model holding today's totals, or nil if current is nil. Durations are converted from
 *       minutes to seconds; negative values are clamped to 0; exercisesTimes is 0 and
 *       activityItems is empty; startTime / endTime are today's boundaries.
 * [CN]: 承载当天累计值的模型，current 为 nil 时返回 nil。时长由分钟换算为秒；负值按 0 处理；
 *       exercisesTimes 为 0、activityItems 为空；startTime / endTime 为当天起止时间。
 */
+ (nullable TSActivityDailyModel *)npkModelFromMetaActivityCurrent:(nullable TSMetaActivityCurrent *)current;

@end

NS_ASSUME_NONNULL_END
