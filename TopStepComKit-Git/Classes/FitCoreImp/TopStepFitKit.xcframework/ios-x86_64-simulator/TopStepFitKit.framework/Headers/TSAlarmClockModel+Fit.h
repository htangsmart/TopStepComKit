//
//  TSAlarmClockModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class FitCloudAlarmObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSAlarmClockModel (Fit)

/**
 * @brief Convert FitCloudAlarmObject array to TSAlarmClockModel array
 * @chinese 将FitCloudAlarmObject数组转换为TSAlarmClockModel数组
 * 
 * @param fitAlarmObjects 
 * EN: Array of FitCloudAlarmObject objects to be converted
 * CN: 需要转换的FitCloudAlarmObject对象数组
 * 
 * @return 
 * EN: Array of converted TSAlarmClockModel objects
 * CN: 转换后的TSAlarmClockModel对象数组
 */
+ (NSArray<TSAlarmClockModel *> *)alarmModelsFromFitCloudAlarmObjects:(NSArray<FitCloudAlarmObject *> *)fitAlarmObjects;

/**
 * @brief Convert single FitCloudAlarmObject to TSAlarmClockModel
 * @chinese 将单个FitCloudAlarmObject转换为TSAlarmClockModel
 * 
 * @param fitAlarmObject 
 * EN: Single FitCloudAlarmObject object to be converted
 * CN: 需要转换的单个FitCloudAlarmObject对象
 * 
 * @return 
 * EN: Converted TSAlarmClockModel object
 * CN: 转换后的TSAlarmClockModel对象
 */
+ (TSAlarmClockModel *)alarmModelFromFitCloudAlarmObject:(FitCloudAlarmObject *)fitAlarmObject;

/**
 * @brief Convert TSAlarmClockModel array to FitCloudAlarmObject array
 * @chinese 将TSAlarmClockModel数组转换为FitCloudAlarmObject数组
 * 
 * @param alarmModels 
 * EN: Array of TSAlarmClockModel objects to be converted
 * CN: 需要转换的TSAlarmClockModel对象数组
 * 
 * @return 
 * EN: Array of converted FitCloudAlarmObject objects
 * CN: 转换后的FitCloudAlarmObject对象数组
 */
+ (NSArray<FitCloudAlarmObject *> *)fitCloudAlarmObjectsFromAlarmModels:(NSArray<TSAlarmClockModel *> *)alarmModels;

/**
 * @brief Convert single TSAlarmClockModel to FitCloudAlarmObject
 * @chinese 将单个TSAlarmClockModel转换为FitCloudAlarmObject
 * 
 * @param alarmModel 
 * EN: Single TSAlarmClockModel object to be converted
 * CN: 需要转换的单个TSAlarmClockModel对象
 * 
 * @return 
 * EN: Converted FitCloudAlarmObject object
 * CN: 转换后的FitCloudAlarmObject对象
 */
+ (FitCloudAlarmObject *)fitCloudAlarmObjectFromAlarmModel:(TSAlarmClockModel *)alarmModel;

@end

NS_ASSUME_NONNULL_END
