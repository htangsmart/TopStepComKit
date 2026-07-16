//
//  TSFitBPAutoMonitor.h
//  Pods
//
//  Created by 磐石 on 2025/4/20.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitBPAutoMonitor : TSFitKitBase

+ (void)fetchAutoMonitorSettingCompletion:(void (^)(TSAutoMonitorBPConfigs * _Nullable config, NSError * _Nullable error))completion ;

+ (void)pushAutoMonitorSettingConfig:(nonnull TSAutoMonitorBPConfigs *)setting completion:(nonnull TSCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
