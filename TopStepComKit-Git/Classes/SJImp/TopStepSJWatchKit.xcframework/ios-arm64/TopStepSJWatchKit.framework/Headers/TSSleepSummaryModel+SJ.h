//
//  TSSleepSummaryModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/20.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <SJWatchLib/SJWatchLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepSummaryModel (SJ)

/**
 * @brief Convert WMSleepDataModel to TSSleepSummaryModel
 * @chinese 将WMSleepDataModel转换为TSSleepSummaryModel
 *
 * @param model 
 * EN: WMSleepDataModel object to be converted
 * CN: 需要转换的WMSleepDataModel对象
 *
 * @return 
 * EN: Converted TSSleepSummaryModel object, nil if conversion fails
 * CN: 转换后的TSSleepSummaryModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: Conversion rules:
 * - Time conversion: milliseconds to seconds
 * - Sleep duration: minutes to seconds
 * - Sleep type mapping:
 *   • sleepType 0 -> TSSleepPeriodDaytime
 *   • sleepType 1 -> TSSleepPeriodNocturnal
 * - Sleep stage mapping:
 *   • WMSleepStatusAwake -> TSSleepStageWake
 *   • WMSleepStatusLight -> TSSleepStageLight
 *   • WMSleepStatusDeep -> TSSleepStageDeep
 *   • WMSleepStatusREM -> TSSleepStageREM
 *
 * CN: 转换规则：
 * - 时间转换：毫秒转秒
 * - 睡眠时长：分钟转秒
 * - 睡眠类型映射：
 *   • sleepType 0 -> TSSleepPeriodDaytime
 *   • sleepType 1 -> TSSleepPeriodNocturnal
 * - 睡眠阶段映射：
 *   • WMSleepStatusAwake -> TSSleepStageWake
 *   • WMSleepStatusLight -> TSSleepStageLight
 *   • WMSleepStatusDeep -> TSSleepStageDeep
 *   • WMSleepStatusREM -> TSSleepStageREM
 */
+ (nullable TSSleepSummaryModel *)modelWithWMSleepDataModel:(nullable WMSleepDataModel *)model;

@end

NS_ASSUME_NONNULL_END
