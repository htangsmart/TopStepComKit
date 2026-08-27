//
//  TSFitBaseAutoMonitor.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/4/23.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitBaseAutoMonitor : TSFitKitBase


+ (BOOL)isSupportIndividualMonitorConfig;

+ (BOOL)isSupportTimeIntervalSetting;

+ (BOOL)isSupportTimePeriodSetting;

@end

NS_ASSUME_NONNULL_END
