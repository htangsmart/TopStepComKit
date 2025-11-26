//
//  TSFitHRAutoMonitor.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitHRAutoMonitor : TSFitKitBase

+ (void)fetchAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorHRConfigs * _Nullable, NSError * _Nullable))completion ;

+ (void)pushAutoMonitorConfigs:(nonnull TSAutoMonitorHRConfigs *)setting completion:(nonnull TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
