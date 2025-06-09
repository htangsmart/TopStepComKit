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


+ (TSAutoMonitorConfigs *)configsWithType:(TSMonitorType)monitorType hTMSingleObjects:(NSArray<FitCloudHTMSingleObject *> *)htmObjects ;

+ (FitCloudHTMSingleObject *)fitHtmSingleObjectFromSettingModel:(TSAutoMonitorConfigs *)model ;

@end

NS_ASSUME_NONNULL_END
