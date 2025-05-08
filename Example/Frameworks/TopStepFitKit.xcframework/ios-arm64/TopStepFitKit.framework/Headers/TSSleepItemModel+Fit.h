//
//  TSSleepItemModel+Fit.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/4.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FitCloudManualSyncRecordObject;

@interface TSSleepItemModel (Fit)

+ (NSArray<NSDictionary *> *)sleepDictWithFitCloudManualSyncRecord:(FitCloudManualSyncRecordObject *)record ;

+ (NSArray<TSSleepItemModel *> *)sleepModelWithDBDicts:(NSArray<NSDictionary *> *)dbDicts ;

+ (TSSleepPeriodType)periodTypeWithItem:(TSSleepItemModel *)item;

- (TSSleepStageType)isUsefulSleepState;

+ (NSTimeInterval)startOfDayTimestampForDate:(NSTimeInterval)timestamp ;

@end

NS_ASSUME_NONNULL_END
