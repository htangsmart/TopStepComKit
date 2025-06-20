//
//  TSSleepModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/20.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <SJWatchLib/SJWatchLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepModel (SJ)

/**
 * @brief Convert array of WMSleepDataModel to array of TSSleepModel
 * @chinese 将WMSleepDataModel数组转换为TSSleepModel数组
 * 
 * @param models 
 * EN: Array of WMSleepDataModel objects to be converted
 * CN: 需要转换的WMSleepDataModel对象数组
 * 
 * @return 
 * EN: Array of converted TSSleepModel objects, nil if conversion fails
 * CN: 转换后的TSSleepModel对象数组，转换失败时返回nil
 *
 * @discussion
 * [EN]: Conversion rules:
 * - Sleep type mapping:
 *   • sleepType 0 -> Daytime sleep (09:00-20:00)
 *   • sleepType 1 -> Night sleep (20:00-09:00)
 * - Sleep stage mapping:
 *   • WMSleepStatusAwake -> TSSleepStageWake
 *   • WMSleepStatusLight -> TSSleepStageLight
 *   • WMSleepStatusDeep -> TSSleepStageDeep
 *   • WMSleepStatusREM -> TSSleepStageREM
 * - Time conversion: milliseconds to seconds
 * - Duration conversion: minutes to seconds
 *
 * [CN]: 转换规则：
 * - 睡眠类型映射：
 *   • sleepType 0 -> 日间睡眠（09:00-20:00）
 *   • sleepType 1 -> 夜间睡眠（20:00-09:00）
 * - 睡眠阶段映射：
 *   • WMSleepStatusAwake -> TSSleepStageWake
 *   • WMSleepStatusLight -> TSSleepStageLight
 *   • WMSleepStatusDeep -> TSSleepStageDeep
 *   • WMSleepStatusREM -> TSSleepStageREM
 * - 时间转换：毫秒转秒
 * - 时长转换：分钟转秒
 */
+ (nullable NSArray<TSSleepModel *> *)modelsWithWMSleepDataModels:(nullable NSArray<WMSleepDataModel *> *)models;

@end

NS_ASSUME_NONNULL_END
