//
//  TSHRValueModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <SJWatchLib/SJWatchLib.h>

NS_ASSUME_NONNULL_BEGIN

//@class WMHeartRateDataModel;
//@class WMBaseByDayDataModel;
//@class WMHeartRateStatisticsDataModel;

@interface TSHRValueModel (SJ)

/**
 * @brief Convert WMHeartRateDataModel to TSHRValueModel
 * @chinese 将WMHeartRateDataModel转换为TSHRValueModel
 * 
 * @param wmModel 
 * EN: WMHeartRateDataModel object to be converted
 * CN: 需要转换的WMHeartRateDataModel对象
 * 
 * @return 
 * EN: Converted TSHRValueModel object, nil if conversion fails
 * CN: 转换后的TSHRValueModel对象，转换失败时返回nil
 */
+ (nullable TSHRValueModel *)modelWithWMHeartRateDataModel:(nullable WMHeartRateDataModel *)wmModel;

/**
 * @brief Convert array of WMHeartRateDataModel to array of TSHRValueModel
 * @chinese 将WMHeartRateDataModel数组转换为TSHRValueModel数组
 * 
 * @param wmModels 
 * EN: Array of WMHeartRateDataModel objects to be converted
 * CN: 需要转换的WMHeartRateDataModel对象数组
 * 
 * @return 
 * EN: Array of converted TSHRValueModel objects, empty array if conversion fails
 * CN: 转换后的TSHRValueModel对象数组，转换失败时返回空数组
 */
+ (NSArray<TSHRValueModel *> *)modelsWithWMHeartRateDataModels:(nullable NSArray<WMHeartRateDataModel *> *)wmModels;


+ (NSArray<TSHRValueModel *> *)modelsWithWMHeartRateBaseByDayModels:(NSArray<WMBaseByDayDataModel<WMHeartRateDataModel *> *> * _Nullable)wmModels ;

+ (NSArray<TSHRValueModel *> *)modelsWithWMRestingHeartRateBaseByDayModels:(NSArray<WMBaseByDayDataModel<WMHeartRateStatisticsDataModel *> *> * _Nullable)wmModels ;

/**
 * @brief Convert WMActivityDataModel to array of TSHRValueModel
 * @chinese 将WMActivityDataModel转换为TSHRValueModel数组
 * 
 * @param activityModel 
 * EN: WMActivityDataModel object containing heart rate data to be converted
 * CN: 包含需要转换的心率数据的WMActivityDataModel对象
 * 
 * @return 
 * EN: Array of converted TSHRValueModel objects, empty array if conversion fails
 * CN: 转换后的TSHRValueModel对象数组，转换失败时返回空数组
 */
+ (NSArray<TSHRValueModel *> *)modelsWithWMActivityDataModel:(nullable WMActivityDataModel *)activityModel;

@end

NS_ASSUME_NONNULL_END
