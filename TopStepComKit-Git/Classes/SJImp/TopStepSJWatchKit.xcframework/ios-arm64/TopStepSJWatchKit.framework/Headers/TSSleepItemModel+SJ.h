//
//  TSSleepItemModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/20.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <SJWatchLib/SJWatchLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepItemModel (SJ)

/**
 * @brief Convert WMSleepDataModel to array of TSSleepItemModel
 * @chinese 将WMSleepDataModel转换为TSSleepItemModel数组
 *
 * @param model 
 * EN: WMSleepDataModel object to be converted
 * CN: 需要转换的WMSleepDataModel对象
 *
 * @return 
 * EN: Array of TSSleepItemModel objects, nil if conversion fails
 * CN: TSSleepItemModel对象数组，转换失败时返回nil
 *
 * @discussion
 * EN: Conversion rules:
 * - Sleep status mapping:
 *   • WMSleepStatusAwake -> TSSleepStageWake
 *   • WMSleepStatusLight -> TSSleepStageLight
 *   • WMSleepStatusDeep -> TSSleepStageDeep
 *   • WMSleepStatusREM -> TSSleepStageREM
 * - Sleep period type mapping:
 *   • sleepType 0 -> TSSleepPeriodDaytime
 *   • sleepType 1 -> TSSleepPeriodNocturnal
 * - Timestamp conversion: milliseconds to seconds
 *
 * CN: 转换规则：
 * - 睡眠状态映射：
 *   • WMSleepStatusAwake -> TSSleepStageWake
 *   • WMSleepStatusLight -> TSSleepStageLight
 *   • WMSleepStatusDeep -> TSSleepStageDeep
 *   • WMSleepStatusREM -> TSSleepStageREM
 * - 睡眠时段类型映射：
 *   • sleepType 0 -> TSSleepPeriodDaytime
 *   • sleepType 1 -> TSSleepPeriodNocturnal
 * - 时间戳转换：毫秒转秒
 */
+ (nullable NSArray<TSSleepItemModel *> *)modelsWithWMSleepDataModel:(nullable WMSleepDataModel *)model;

@end

NS_ASSUME_NONNULL_END
