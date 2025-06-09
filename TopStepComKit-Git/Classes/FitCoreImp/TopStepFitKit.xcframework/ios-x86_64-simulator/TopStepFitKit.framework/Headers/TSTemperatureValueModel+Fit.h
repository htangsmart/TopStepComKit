//
//  TSTemperatureValueModel+Fit.h
//  Pods
//
//  Created by 磐石 on 2025/4/20.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class FitCloudRealTimeHealthMeasuringResultObject;
NS_ASSUME_NONNULL_BEGIN

@interface TSTemperatureValueModel (Fit)

/**
 * @brief Convert FitCloudRealTimeHealthMeasuringResultObject to TSTemperatureValueModel
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject转换为TSTemperatureValueModel
 * 
 * @param resultObject 
 * EN: FitCloudRealTimeHealthMeasuringResultObject object to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象
 * 
 * @return 
 * EN: Converted TSTemperatureValueModel object, nil if conversion fails
 * CN: 转换后的TSTemperatureValueModel对象，转换失败时返回nil
 */
+ (nullable TSTemperatureValueModel *)modelWithFitCloudRealTimeHealthMeasuringResultObject:(nullable FitCloudRealTimeHealthMeasuringResultObject *)resultObject;

/**
 * @brief Convert array of FitCloudRealTimeHealthMeasuringResultObject to array of TSTemperatureValueModel
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject数组转换为TSTemperatureValueModel数组
 * 
 * @param resultObjects 
 * EN: Array of FitCloudRealTimeHealthMeasuringResultObject objects to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象数组
 * 
 * @return 
 * EN: Array of converted TSTemperatureValueModel objects, empty array if conversion fails
 * CN: 转换后的TSTemperatureValueModel对象数组，转换失败时返回空数组
 */
+ (NSArray<TSTemperatureValueModel *> *)modelsWithFitCloudRealTimeHealthMeasuringResultObjects:(nullable NSArray<FitCloudRealTimeHealthMeasuringResultObject *> *)resultObjects;

@end

NS_ASSUME_NONNULL_END
