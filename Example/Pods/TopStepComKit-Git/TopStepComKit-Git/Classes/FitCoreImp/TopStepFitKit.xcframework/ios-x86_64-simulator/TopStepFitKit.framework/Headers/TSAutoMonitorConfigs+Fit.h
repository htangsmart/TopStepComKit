//
//  TSAutoMonitorConfigs+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/24.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudHTMSingleObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSAutoMonitorConfigs (Fit)


+ (TSAutoMonitorConfigs *)temperatureConfigsWithTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmObjects;

+ (TSAutoMonitorConfigs *)bloodPressureConfigsWithTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmObjects;

+ (TSAutoMonitorConfigs *)stressConfigsWithTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmObjects;


+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWithBloodOxygenConfigs:(TSAutoMonitorConfigs *)configs;

+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWithStressConfigs:(TSAutoMonitorConfigs *)configs;

+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWithTemperatureConfigs:(TSAutoMonitorConfigs *)configs;

@end

NS_ASSUME_NONNULL_END
