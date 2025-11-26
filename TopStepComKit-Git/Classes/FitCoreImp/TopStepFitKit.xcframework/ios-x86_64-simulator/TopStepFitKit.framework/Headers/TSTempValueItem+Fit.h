//
//  TSTempValueItem+Fit.h
//  Pods
//
//  Created by 磐石 on 2025/4/20.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class FitCloudRealTimeHealthMeasuringResultObject;
NS_ASSUME_NONNULL_BEGIN

@interface TSTempValueItem (Fit)

/**
 * @brief Convert FitCloudRealTimeHealthMeasuringResultObject to TSTempValueItem
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject转换为TSTempValueItem
 * 
 * @param resultObject 
 * EN: FitCloudRealTimeHealthMeasuringResultObject object to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象
 * 
 * @return 
 * EN: Converted TSTempValueItem object, nil if conversion fails
 * CN: 转换后的TSTempValueItem对象，转换失败时返回nil
 */
+ (nullable TSTempValueItem *)modelWithFitCloudRealTimeHealthMeasuringResultObject:(nullable FitCloudRealTimeHealthMeasuringResultObject *)resultObject;

/**
 * @brief Convert array of FitCloudRealTimeHealthMeasuringResultObject to array of TSTempValueItem
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject数组转换为TSTempValueItem数组
 * 
 * @param resultObjects 
 * EN: Array of FitCloudRealTimeHealthMeasuringResultObject objects to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象数组
 * 
 * @return 
 * EN: Array of converted TSTempValueItem objects, empty array if conversion fails
 * CN: 转换后的TSTempValueItem对象数组，转换失败时返回空数组
 */
+ (NSArray<TSTempValueItem *> *)modelsWithFitCloudRealTimeHealthMeasuringResultObjects:(nullable NSArray<FitCloudRealTimeHealthMeasuringResultObject *> *)resultObjects;

@end

NS_ASSUME_NONNULL_END
