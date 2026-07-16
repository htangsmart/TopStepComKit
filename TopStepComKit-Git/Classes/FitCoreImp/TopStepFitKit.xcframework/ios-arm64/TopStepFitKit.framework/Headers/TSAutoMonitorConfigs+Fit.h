//
//  TSAutoMonitorConfigs+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/24.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudHTMSingleObject;
@class FitCloudHTMObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSAutoMonitorConfigs (Fit)

#pragma mark - Single HTM (新接口)

+ (TSAutoMonitorConfigs *)temperatureConfigsWithTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmObjects;

+ (TSAutoMonitorConfigs *)bloodPressureConfigsWithTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmObjects;

+ (TSAutoMonitorConfigs *)stressConfigsWithTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmObjects;


+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWithBloodOxygenConfigs:(TSAutoMonitorConfigs *)configs;

+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWithStressConfigs:(TSAutoMonitorConfigs *)configs;

+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWithTemperatureConfigs:(TSAutoMonitorConfigs *)configs;

#pragma mark - HTM Object (旧接口)

/**
 * @brief Convert FitCloudHTMObject to TSAutoMonitorConfigs
 * @chinese 将FitCloudHTMObject转换为TSAutoMonitorConfigs
 *
 * @param htmObject
 * EN: FitCloudHTMObject to be converted
 * CN: 需要转换的FitCloudHTMObject对象
 *
 * @return
 * EN: Converted TSAutoMonitorConfigs object, nil if conversion fails
 * CN: 转换后的TSAutoMonitorConfigs对象，转换失败时返回nil
 */
+ (nullable TSAutoMonitorConfigs *)configsWithHTMObject:(nullable FitCloudHTMObject *)htmObject;

/**
 * @brief Convert TSAutoMonitorConfigs to FitCloudHTMObject
 * @chinese 将TSAutoMonitorConfigs转换为FitCloudHTMObject
 *
 * @param configs
 * EN: TSAutoMonitorConfigs to be converted
 * CN: 需要转换的TSAutoMonitorConfigs对象
 *
 * @return
 * EN: Converted FitCloudHTMObject, nil if conversion fails
 * CN: 转换后的FitCloudHTMObject对象，转换失败时返回nil
 */
+ (nullable FitCloudHTMObject *)fitHtmObjectWithConfigs:(nullable TSAutoMonitorConfigs *)configs;

@end

NS_ASSUME_NONNULL_END
