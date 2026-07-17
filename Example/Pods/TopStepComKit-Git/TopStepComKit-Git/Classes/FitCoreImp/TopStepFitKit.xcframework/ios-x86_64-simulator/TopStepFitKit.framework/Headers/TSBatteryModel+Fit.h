//
//  TSBatteryModel+Fit.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudBatteryInfoObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSBatteryModel (Fit)

/**
 * @brief Convert FitCloudBatteryInfoObject to TSBatteryModel
 * @chinese 将FitCloudBatteryInfoObject转换为TSBatteryModel
 * 
 * @param fitBatteryInfo 
 * EN: FitCloudBatteryInfoObject object to be converted
 * CN: 需要转换的FitCloudBatteryInfoObject对象
 * 
 * @return 
 * EN: A new TSBatteryModel instance with properties set from fitBatteryInfo
 * CN: 根据fitBatteryInfo信息设置属性的新TSBatteryModel实例
 * 
 * @discussion 
 * EN: This method converts a FitCloudBatteryInfoObject to TSBatteryModel:
 *     - Sets isCharging based on state property (BATTERYSTATE_CHARGING)
 *     - Sets batteryLevel from percent property (0-100)
 * CN: 此方法将FitCloudBatteryInfoObject转换为TSBatteryModel：
 *     - 根据state属性（BATTERYSTATE_CHARGING）设置isCharging
 *     - 从percent属性设置batteryLevel（0-100）
 */
+ (nullable instancetype)modelWithFitCloudBatteryInfo:(nullable FitCloudBatteryInfoObject *)fitBatteryInfo;

@end

NS_ASSUME_NONNULL_END
