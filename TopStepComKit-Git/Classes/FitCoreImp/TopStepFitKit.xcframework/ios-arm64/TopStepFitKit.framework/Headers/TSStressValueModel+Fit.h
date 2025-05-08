//
//  TSStressValueModel+Fit.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/2/28.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class FitCloudStressIndexItemObject;
@class FitCloudManualSyncRecordObject;
@class FitCloudRealTimeHealthMeasuringResultObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSStressValueModel (Fit)

+ (NSArray<TSStressValueModel *> *)stressModelWithDBDicts:(NSArray <NSDictionary *>*)dbDicts ;

+ (NSArray<NSDictionary *> *)stressDictWithFitCloudManualSyncRecord:(FitCloudManualSyncRecordObject *)record ;

/**
 * @brief Convert FitCloudRealTimeHealthMeasuringResultObject to TSStressValueModel
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject转换为TSStressValueModel
 * 
 * @param resultObject 
 * EN: FitCloudRealTimeHealthMeasuringResultObject object to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象
 * 
 * @return 
 * EN: Converted TSStressValueModel object, nil if conversion fails
 * CN: 转换后的TSStressValueModel对象，转换失败时返回nil
 */
+ (nullable TSStressValueModel *)modelWithFitCloudRealTimeHealthMeasuringResultObject:(nullable FitCloudRealTimeHealthMeasuringResultObject *)resultObject;

/**
 * @brief Convert array of FitCloudRealTimeHealthMeasuringResultObject to array of TSStressValueModel
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject数组转换为TSStressValueModel数组
 * 
 * @param resultObjects 
 * EN: Array of FitCloudRealTimeHealthMeasuringResultObject objects to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象数组
 * 
 * @return 
 * EN: Array of converted TSStressValueModel objects, empty array if conversion fails
 * CN: 转换后的TSStressValueModel对象数组，转换失败时返回空数组
 */
+ (NSArray<TSStressValueModel *> *)modelsWithFitCloudRealTimeHealthMeasuringResultObjects:(nullable NSArray<FitCloudRealTimeHealthMeasuringResultObject *> *)resultObjects;

@end

NS_ASSUME_NONNULL_END
