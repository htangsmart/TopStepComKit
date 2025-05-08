//
//  TSFitHRAutoMonitor.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSFitAutoMonitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitHRAutoMonitor : TSFitAutoMonitor

+ (void)getAutoMonitorSettingCompletion:(void (^)(TSHRAutoMonitorConfigs * _Nullable, NSError * _Nullable))completion ;

+ (void)setAutoMonitorSetting:(nonnull TSHRAutoMonitorConfigs *)setting completion:(nonnull TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
