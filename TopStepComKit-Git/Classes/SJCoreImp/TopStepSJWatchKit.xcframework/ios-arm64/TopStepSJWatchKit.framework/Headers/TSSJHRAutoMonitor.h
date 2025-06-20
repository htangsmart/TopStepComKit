//
//  TSSJHRAutoMonitor.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import "TSSJAutoMonitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSSJHRAutoMonitor : TSSJAutoMonitor

+ (void)getAutoMonitorSettingCompletion:(void (^)(TSHRAutoMonitorConfigs * _Nullable setting, NSError * _Nullable error))completion ;


+ (void)setAutoMonitorSetting:(TSHRAutoMonitorConfigs *)setting
                   completion:(TSCompletionBlock)completion ;


@end

NS_ASSUME_NONNULL_END
