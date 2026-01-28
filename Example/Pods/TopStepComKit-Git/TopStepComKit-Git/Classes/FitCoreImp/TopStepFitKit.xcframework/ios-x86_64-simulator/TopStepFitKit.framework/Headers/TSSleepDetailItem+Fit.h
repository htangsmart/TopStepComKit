//
//  TSSleepDetailItem+Fit.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/4.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FitCloudManualSyncRecordObject;

@interface TSSleepDetailItem (Fit)

+ (NSArray<NSDictionary *> *)sleepDictWithFitCloudManualSyncRecord:(FitCloudManualSyncRecordObject *)record ;

+ (NSArray<TSSleepDetailItem *> *)sleepModelWithDBDicts:(NSArray<NSDictionary *> *)dbDicts ;

+ (NSTimeInterval)startOfDayTimestampForDate:(NSTimeInterval)timestamp ;

@end

NS_ASSUME_NONNULL_END
