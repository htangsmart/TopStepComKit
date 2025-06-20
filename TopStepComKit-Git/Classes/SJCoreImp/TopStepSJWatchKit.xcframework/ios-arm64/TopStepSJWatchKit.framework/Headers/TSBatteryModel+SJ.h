//
//  TSBatteryModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMDeviceBatteryModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSBatteryModel (SJ)

/**
 * @brief Convert TSBatteryModel to WMDeviceBatteryModel
 * @chinese 将TSBatteryModel转换为WMDeviceBatteryModel
 *
 * @param tsModel 
 * EN: TSBatteryModel object to be converted
 * CN: 需要转换的TSBatteryModel对象
 *
 * @return 
 * EN: Converted WMDeviceBatteryModel object, nil if conversion fails
 * CN: 转换后的WMDeviceBatteryModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts TSBatteryModel to WMDeviceBatteryModel:
 *     - Converts battery level to percentage (0-100)
 *     - Sets charging status
 * CN: 该方法将TSBatteryModel转换为WMDeviceBatteryModel：
 *     - 将电量转换为百分比（0-100）
 *     - 设置充电状态
 */
+ (nullable WMDeviceBatteryModel *)wmModelWithTSBatteryModel:(nullable TSBatteryModel *)tsModel;

/**
 * @brief Convert WMDeviceBatteryModel to TSBatteryModel
 * @chinese 将WMDeviceBatteryModel转换为TSBatteryModel
 *
 * @param wmModel 
 * EN: WMDeviceBatteryModel object to be converted
 * CN: 需要转换的WMDeviceBatteryModel对象
 *
 * @return 
 * EN: Converted TSBatteryModel object, nil if conversion fails
 * CN: 转换后的TSBatteryModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts WMDeviceBatteryModel to TSBatteryModel:
 *     - Converts battery percentage to level
 *     - Sets charging status
 * CN: 该方法将WMDeviceBatteryModel转换为TSBatteryModel：
 *     - 将电量百分比转换为电量等级
 *     - 设置充电状态
 */
+ (nullable TSBatteryModel *)modelWithWMDeviceBatteryModel:(nullable WMDeviceBatteryModel *)wmModel;

@end

NS_ASSUME_NONNULL_END
