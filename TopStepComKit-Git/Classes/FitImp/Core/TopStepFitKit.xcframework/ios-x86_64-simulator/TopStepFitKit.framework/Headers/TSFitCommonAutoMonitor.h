//
//  TSFitCommonAutoMonitor.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/4/23.
//

#import "TSFitBaseAutoMonitor.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * kStressMessage = @"压力";
static NSString * kBloodOxygenMessage = @"血氧";
static NSString * kTemperatureMessage = @"体温";
static NSString * kElectrocardioMessage = @"心电";

@interface TSFitCommonAutoMonitor : TSFitBaseAutoMonitor

+ (void)fetchAutoMonitorConfigsWithNoteMessage:(NSString *)noteMessage completion:(nonnull void (^)(TSAutoMonitorConfigs * _Nullable, NSError * _Nullable))completion ;


+ (void)pushAutoMonitorConfig:(nonnull TSAutoMonitorConfigs *)config noteMessage:(NSString *)noteMessage completion:(nonnull TSCompletionBlock)completion ;

@end

NS_ASSUME_NONNULL_END
