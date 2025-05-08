//
//  TSHRAutoMonitorConfigs+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/24.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudHRAlarmObject;
@class FitCloudHTMSingleObject;
@class FitCloudHTMObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSHRAutoMonitorConfigs (Fit)


/**
 * @brief Generate TSAutoMonitorHeartRateModel from FitCloudHRAlarmObject and FitCloudHTMSingleObject arrays.
 * @chinese 根据 FitCloudHRAlarmObject 和 FitCloudHTMSingleObject 对象数组生成 TSAutoMonitorHeartRateModel。
 *
 * @param hrAlarmObject The heart rate alarm settings object.
 * @param htmSingleObjects The array of health timing monitoring single settings objects.
 *
 * @return A TSAutoMonitorHeartRateModel object populated with the provided settings.
 * @chinese 返回一个根据提供的设置填充的 TSAutoMonitorHeartRateModel 对象。
 *
 * @discussion
 * [EN]: This method creates a TSAutoMonitorHeartRateModel instance based on the provided heart rate alarm settings and health timing monitoring settings.
 * [CN]: 此方法根据提供的心率报警设置和健康定时监测设置创建 TSAutoMonitorHeartRateModel 实例。
 */
+ (TSHRAutoMonitorConfigs *)modelFromHRAlarm:(FitCloudHRAlarmObject *)hrAlarmObject
                                 htmSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmSingleObjects;


/**
 * @brief Generate TSAutoMonitorHeartRateModel from FitCloudHRAlarmObject and FitCloudHTMObject.
 * @chinese 根据 FitCloudHRAlarmObject 和 FitCloudHTMObject 生成 TSAutoMonitorHeartRateModel。
 *
 * @param hrAlarmObject The heart rate alarm settings object.
 * @param htmObject The health timing monitoring settings object.
 *
 * @return A TSAutoMonitorHeartRateModel object populated with the provided settings.
 * @chinese 返回一个根据提供的设置填充的 TSAutoMonitorHeartRateModel 对象。
 *
 * @discussion
 * [EN]: This method creates a TSAutoMonitorHeartRateModel instance based on the provided heart rate alarm settings and health timing monitoring settings.
 * [CN]: 此方法根据提供的心率报警设置和健康定时监测设置创建 TSAutoMonitorHeartRateModel 实例。
 */
+ (TSHRAutoMonitorConfigs *)modelFromHRAlarm:(FitCloudHRAlarmObject *)hrAlarmObject
                                        htmObject:(FitCloudHTMObject *)htmObject;


/**
 * @brief Convert TSAutoMonitorHeartRateModel to FitCloudHRAlarmObject.
 * @chinese 将 TSAutoMonitorHeartRateModel 转换为 FitCloudHRAlarmObject。
 *
 * @param model The heart rate model to convert.
 * @return A FitCloudHRAlarmObject object populated with the heart rate model settings.
 * @chinese 返回一个根据心率模型设置填充的 FitCloudHRAlarmObject 对象。
 *
 * @discussion
 * [EN]: This method converts a TSAutoMonitorHeartRateModel instance into a FitCloudHRAlarmObject instance.
 * [CN]: 此方法将 TSAutoMonitorHeartRateModel 实例转换为 FitCloudHRAlarmObject 实例。
 */
+ (FitCloudHRAlarmObject *)fitHrAlarmObjectFromHeartRateModel:(TSHRAutoMonitorConfigs *)model;

/**
 * @brief Convert TSAutoMonitorHeartRateModel to FitCloudHTMObject.
 * @chinese 将 TSAutoMonitorHeartRateModel 转换为 FitCloudHTMObject。
 *
 * @param model The heart rate model to convert.
 * @return A FitCloudHTMObject object populated with the heart rate model settings.
 * @chinese 返回一个根据心率模型设置填充的 FitCloudHTMObject 对象。
 *
 * @discussion
 * [EN]: This method converts a TSAutoMonitorHeartRateModel instance into a FitCloudHTMObject instance.
 * [CN]: 此方法将 TSAutoMonitorHeartRateModel 实例转换为 FitCloudHTMObject 实例。
 */
+ (FitCloudHTMObject *)fitHtmObjectFromHeartRateModel:(TSHRAutoMonitorConfigs *)model;



+ (FitCloudHTMSingleObject *)fitHtmSingleObjectFromSettingModel:(TSHRAutoMonitorConfigs *)model ;



@end

NS_ASSUME_NONNULL_END
