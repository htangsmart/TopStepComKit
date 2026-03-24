//
//  TSBPValueItem+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/28.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudBPItemObject;
@class FitCloudManualSyncRecordObject;
@class FitCloudRealTimeHealthMeasuringResultObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSBPValueItem (Fit)

+ (NSArray<TSBPValueItem *> *)bpModelWithDBDicts:(NSArray <NSDictionary *>*)dbDicts ;

+ (NSArray<NSDictionary *> *)bpDictWithFitCloudManualSyncRecord:(FitCloudManualSyncRecordObject *)record ;

/**
 * @brief Convert FitCloudRealTimeHealthMeasuringResultObject to TSBPValueItem
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject转换为TSBPValueItem
 * 
 * @param resultObject 
 * EN: FitCloudRealTimeHealthMeasuringResultObject object to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象
 * 
 * @return 
 * EN: Converted TSBPValueItem object, nil if conversion fails
 * CN: 转换后的TSBPValueItem对象，转换失败时返回nil
 */
+ (nullable TSBPValueItem *)modelWithFitCloudRealTimeHealthMeasuringResultObject:(nullable FitCloudRealTimeHealthMeasuringResultObject *)resultObject;

/**
 * @brief Convert array of FitCloudRealTimeHealthMeasuringResultObject to array of TSBPValueItem
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject数组转换为TSBPValueItem数组
 * 
 * @param resultObjects 
 * EN: Array of FitCloudRealTimeHealthMeasuringResultObject objects to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象数组
 * 
 * @return 
 * EN: Array of converted TSBPValueItem objects, empty array if conversion fails
 * CN: 转换后的TSBPValueItem对象数组，转换失败时返回空数组
 */
+ (NSArray<TSBPValueItem *> *)modelsWithFitCloudRealTimeHealthMeasuringResultObjects:(nullable NSArray<FitCloudRealTimeHealthMeasuringResultObject *> *)resultObjects;

@end

NS_ASSUME_NONNULL_END
