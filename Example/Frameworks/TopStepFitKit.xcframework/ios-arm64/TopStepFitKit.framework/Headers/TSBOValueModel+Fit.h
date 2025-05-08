//
//  TSBOValueModel+Fit.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/2/28.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FitCloudBOItemObject;
@class FitCloudManualSyncRecordObject;
@class FitCloudRealTimeHealthMeasuringResultObject;

@interface TSBOValueModel (Fit)

+ (NSArray<TSBOValueModel *> *)oxyModelWithDBDicts:(NSArray <NSDictionary *>*)dbDicts ;

+ (NSArray<NSDictionary *> *)oxyDictWithFitCloudManualSyncRecord:(FitCloudManualSyncRecordObject *)record ;

/**
 * @brief Convert FitCloudRealTimeHealthMeasuringResultObject to TSBOValueModel
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject转换为TSBOValueModel
 * 
 * @param resultObject 
 * EN: FitCloudRealTimeHealthMeasuringResultObject object to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象
 * 
 * @return 
 * EN: Converted TSBOValueModel object, nil if conversion fails
 * CN: 转换后的TSBOValueModel对象，转换失败时返回nil
 */
+ (nullable TSBOValueModel *)modelWithFitCloudRealTimeHealthMeasuringResultObject:(nullable FitCloudRealTimeHealthMeasuringResultObject *)resultObject;

/**
 * @brief Convert array of FitCloudRealTimeHealthMeasuringResultObject to array of TSBOValueModel
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject数组转换为TSBOValueModel数组
 * 
 * @param resultObjects 
 * EN: Array of FitCloudRealTimeHealthMeasuringResultObject objects to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象数组
 * 
 * @return 
 * EN: Array of converted TSBOValueModel objects, empty array if conversion fails
 * CN: 转换后的TSBOValueModel对象数组，转换失败时返回空数组
 */
+ (NSArray<TSBOValueModel *> *)modelsWithFitCloudRealTimeHealthMeasuringResultObjects:(nullable NSArray<FitCloudRealTimeHealthMeasuringResultObject *> *)resultObjects;

@end

NS_ASSUME_NONNULL_END
