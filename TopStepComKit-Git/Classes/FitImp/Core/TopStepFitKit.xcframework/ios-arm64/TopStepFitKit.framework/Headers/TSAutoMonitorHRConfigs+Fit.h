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
 * @brief Build heart rate configuration from individual monitoring settings.
 * @chinese 根据独立监测设置生成心率配置。
 *
 * @param hrAlarmObject
 * EN: Optional heart rate alarm settings.
 * CN: 可选的心率预警设置。
 *
 * @param htmSingleObjects
 * EN: Individual health monitoring settings.
 * CN: 独立健康监测设置。
 *
 * @return
 * EN: The configuration, or nil when the heart rate entry is missing.
 * CN: 心率配置，缺少心率项时返回 nil。
 */
+ (nullable TSAutoMonitorHRConfigs *)modelFromHRAlarm:(nullable FitCloudHRAlarmObject *)hrAlarmObject
                                    htmSingleObjects:(nullable NSArray<FitCloudHTMSingleObject *> *)htmSingleObjects;


/**
 * @brief Build heart rate configuration from common monitoring settings.
 * @chinese 根据通用监测设置生成心率配置。
 *
 * @param hrAlarmObject
 * EN: Optional heart rate alarm settings.
 * CN: 可选的心率预警设置。
 *
 * @param htmObject
 * EN: Common health monitoring settings.
 * CN: 通用健康监测设置。
 *
 * @return
 * EN: The configuration, or nil when monitoring settings are missing.
 * CN: 心率配置，缺少监测设置时返回 nil。
 */
+ (nullable TSAutoMonitorHRConfigs *)modelFromHRAlarm:(nullable FitCloudHRAlarmObject *)hrAlarmObject
                                           htmObject:(nullable FitCloudHTMObject *)htmObject;

/**
 * @brief Apply resting and exercise heart rate alarm settings.
 * @chinese 更新静息和运动心率预警设置。
 *
 * @param hrAlarmObject
 * EN: Heart rate alarm settings, or nil to clear both alarm fields.
 * CN: 心率预警设置，传 nil 清除两个预警字段。
 */
- (void)applyFitHRAlarm:(nullable FitCloudHRAlarmObject *)hrAlarmObject;


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
