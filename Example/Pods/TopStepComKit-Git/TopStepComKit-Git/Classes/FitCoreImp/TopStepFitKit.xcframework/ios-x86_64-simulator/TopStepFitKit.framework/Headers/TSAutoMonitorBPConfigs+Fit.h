//
//  TSAutoMonitorBPConfigs+Fit.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/3.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface TSAutoMonitorBPConfigs (Fit)


+ (TSAutoMonitorBPConfigs *)configWithHTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmSingleObjects
                                                 alarm:(FitCloudBPAlarmObject *)fitAlarm;

+ (TSAutoMonitorBPConfigs *)configWithHtmObject:(FitCloudHTMObject *)htmObject
                                          alarm:(FitCloudBPAlarmObject *)fitAlarm ;


+ (FitCloudBPAlarmObject *)fitHrAlarmObjectWihtConfigs:(TSAutoMonitorBPConfigs *)configs ;

+ (FitCloudHTMObject *)fitHtmObjectWihtConfigs:(TSAutoMonitorBPConfigs *)configs ;

+ (FitCloudHTMSingleObject *)fitHtmSingleObjectWihtConfigs:(TSAutoMonitorBPConfigs *)configs ;

@end

NS_ASSUME_NONNULL_END
