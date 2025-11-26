//
//  TSAutoMonitorHRConfigs+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/24.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSAutoMonitorHRConfigs (Fit)


/**
 * @brief Generate TSAutoMonitorHRConfigs from FitCloudHRAlarmObject and FitCloudHTMSingleObject arrays.
 * @chinese 根据 FitCloudHRAlarmObject 和 FitCloudHTMSingleObject 对象数组生成 TSAutoMonitorHRConfigs。
 */
+ (TSAutoMonitorHRConfigs *)modelFromHRAlarm:(FitCloudHRAlarmObject *)hrAlarmObject
                                 htmSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmSingleObjects;


/**
 * @brief Generate TSAutoMonitorHRConfigs from FitCloudHRAlarmObject and FitCloudHTMObject.
 * @chinese 根据 FitCloudHRAlarmObject 和 FitCloudHTMObject 生成 TSAutoMonitorHRConfigs。
 */
+ (TSAutoMonitorHRConfigs *)modelFromHRAlarm:(FitCloudHRAlarmObject *)hrAlarmObject
                                        htmObject:(FitCloudHTMObject *)htmObject;


/**
 * @brief Convert TSAutoMonitorHRConfigs to FitCloudHRAlarmObject.
 * @chinese 将 TSAutoMonitorHRConfigs 转换为 FitCloudHRAlarmObject。
 */
+ (FitCloudHRAlarmObject *)fitHrAlarmObjectFromHeartRateModel:(TSAutoMonitorHRConfigs *)model;

/**
 * @brief Convert TSAutoMonitorHRConfigs to FitCloudHTMObject.
 * @chinese 将 TSAutoMonitorHRConfigs 转换为 FitCloudHTMObject。
 */
+ (FitCloudHTMObject *)fitHtmObjectFromHeartRateModel:(TSAutoMonitorHRConfigs *)model;


/**
 * @brief Convert TSAutoMonitorHRConfigs to FitCloudHTMSingleObject.
 * @chinese 将 TSAutoMonitorHRConfigs 转换为 FitCloudHTMSingleObject。
 */
+ (FitCloudHTMSingleObject *)fitHtmSingleObjectFromSettingModel:(TSAutoMonitorHRConfigs *)model;



@end

NS_ASSUME_NONNULL_END
