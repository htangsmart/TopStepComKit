//
//  TSAlarmClockModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMAlarmModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSAlarmClockModel (SJ)

/**
 * @brief Convert TSBatteryModel to WMDeviceBatteryModel
 * @chinese 将TSAlarmClockModel转换为WMAlarmModel
 *
 * @param tsModel 
 * EN: TSBatteryModel object to be converted
 * CN: 需要转换的TSAlarmClockModel对象
 *
 * @return 
 * EN: Converted WMAlarmModel object, nil if conversion fails
 * CN: 转换后的WMAlarmModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts TSBatteryModel to WMAlarmModel:
 *     - Converts alarm ID, time, name and repeat options
 *     - Sets alarm status
 * CN: 该方法将TSAlarmClockModel转换为WMAlarmModel：
 *     - 转换闹钟ID、时间、名称和重复选项
 *     - 设置闹钟状态
 */
+ (nullable WMAlarmModel *)wmModelWithTSAlarmClockModel:(nullable TSAlarmClockModel *)tsModel;

/**
 * @brief Convert TSBatteryModel array to WMDeviceBatteryModel array
 * @chinese 将TSAlarmClockModel数组转换为WMAlarmModel数组
 *
 * @param tsModels 
 * EN: Array of TSBatteryModel objects to be converted
 * CN: 需要转换的TSAlarmClockModel对象数组
 *
 * @return 
 * EN: Array of WMAlarmModel objects, empty array if conversion fails
 * CN: 转换后的WMAlarmModel对象数组，如果转换失败则返回空数组
 */
+ (NSArray<WMAlarmModel *> *)wmModelsWithTSAlarmClockModels:(NSArray<TSAlarmClockModel *> *)tsModels;

/**
 * @brief Convert WMAlarmModel to TSBatteryModel
 * @chinese 将WMAlarmModel转换为TSAlarmClockModel
 *
 * @param wmModel 
 * EN: WMAlarmModel object to be converted
 * CN: 需要转换的WMAlarmModel对象
 *
 * @return 
 * EN: Converted TSBatteryModel object, nil if conversion fails
 * CN: 转换后的TSAlarmClockModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts WMAlarmModel to TSBatteryModel:
 *     - Converts alarm ID, time, name and repeat options
 *     - Sets alarm status
 * CN: 该方法将WMAlarmModel转换为TSAlarmClockModel：
 *     - 转换闹钟ID、时间、名称和重复选项
 *     - 设置闹钟状态
 */
+ (nullable TSAlarmClockModel *)sjModelWithWMAlarmModel:(nullable WMAlarmModel *)wmModel;

/**
 * @brief Convert WMAlarmModel array to TSBatteryModel array
 * @chinese 将WMAlarmModel数组转换为TSAlarmClockModel数组
 *
 * @param wmModels 
 * EN: Array of WMAlarmModel objects to be converted
 * CN: 需要转换的WMAlarmModel对象数组
 *
 * @return 
 * EN: Array of TSBatteryModel objects, empty array if conversion fails
 * CN: 转换后的TSAlarmClockModel对象数组，如果转换失败则返回空数组
 */
+ (NSArray<TSAlarmClockModel *> *)sjModelsWithWMAlarmModels:(NSArray<WMAlarmModel *> *)wmModels;

@end

NS_ASSUME_NONNULL_END
