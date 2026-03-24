//
//  TSHRValueItem+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/25.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudRestingHRValue;
@class FitCloudBPMDataModel;
@class FitCloudManualSyncRecordObject;
@class FitCloudRealTimeHealthMeasuringResultObject;
NS_ASSUME_NONNULL_BEGIN

@interface TSHRValueItem (Fit)

+ (TSHRValueItem *)hrModelWithFitCloudRestingHRValue:(FitCloudRestingHRValue *)fitCloudHRValue;

/**
 * @brief Convert an array of FitCloudRestingHRValue to an array of TSHRValueItem
 * @chinese 将FitCloudRestingHRValue数组转换为TSHRValueItem数组
 * 
 * @param fitCloudHRValues
 * EN: An array of FitCloudRestingHRValue objects to be converted
 * CN: 需要转换的FitCloudRestingHRValue对象数组
 * 
 * @return
 * EN: An array of TSHRValueItem objects
 * CN: TSHRValueItem对象数组
 */
+ (NSArray<TSHRValueItem *> *)hrModelsWithFitCloudRestingHRValues:(NSArray<FitCloudRestingHRValue *> *)fitCloudHRValues;

/**
 * @brief Convert an array of dictionaries to an array of TSHRValueItem
 * @chinese 将字典数组转换为TSHRValueItem数组
 * 
 * @param dbDicts
 * EN: An array of dictionaries containing heart rate data
 * CN: 包含心率数据的字典数组
 * 
 * @return
 * EN: An array of TSHRValueItem objects
 * CN: TSHRValueItem对象数组
 */
+ (NSArray<TSHRValueItem *> *)hrModelWithDBDicts:(NSArray <NSDictionary *>*)dbDicts;

/**
 * @brief Convert FitCloudManualSyncRecordObject to an array of dictionaries
 * @chinese 将FitCloudManualSyncRecordObject转换为字典数组
 * 
 * @param record
 * EN: FitCloudManualSyncRecordObject object to be converted
 * CN: 需要转换的FitCloudManualSyncRecordObject对象
 * 
 * @return
 * EN: Array of dictionaries containing timestamp, activeMeasure, and value
 * CN: 包含时间戳、活动测量和心率值的字典数组
 */
+ (NSArray<NSDictionary *> *)hrDictWithFitCloudManualSyncRecord:(FitCloudManualSyncRecordObject *)record;

/**
 * @brief Convert FitCloudRealTimeHealthMeasuringResultObject to TSHRValueItem
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject转换为TSHRValueItem
 * 
 * @param result
 * EN: FitCloudRealTimeHealthMeasuringResultObject object to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象
 * 
 * @return
 * EN: Converted TSHRValueItem object, nil if conversion fails or heart rate is invalid
 * CN: 转换后的TSHRValueItem对象，如果转换失败或心率无效则返回nil
 */
+ (nullable TSHRValueItem *)hrModelWithRealTimeHealthMeasuringResult:(nullable FitCloudRealTimeHealthMeasuringResultObject *)result;

/**
 * @brief Convert an array of FitCloudRealTimeHealthMeasuringResultObject to an array of TSHRValueItem
 * @chinese 将FitCloudRealTimeHealthMeasuringResultObject数组转换为TSHRValueItem数组
 * 
 * @param results
 * EN: An array of FitCloudRealTimeHealthMeasuringResultObject objects to be converted
 * CN: 需要转换的FitCloudRealTimeHealthMeasuringResultObject对象数组
 * 
 * @return
 * EN: An array of TSHRValueItem objects, only includes results with valid heart rate values
 * CN: TSHRValueItem对象数组，仅包含具有有效心率值的结果
 */
+ (NSArray<TSHRValueItem *> *)hrModelsWithRealTimeHealthMeasuringResults:(NSArray<FitCloudRealTimeHealthMeasuringResultObject *> *)results;




+ (NSDictionary *)sportHRDictWithFitCloudSportId:(NSTimeInterval)sportId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime bmDataModel:(FitCloudBPMDataModel *)bmDataModel;

@end

NS_ASSUME_NONNULL_END
