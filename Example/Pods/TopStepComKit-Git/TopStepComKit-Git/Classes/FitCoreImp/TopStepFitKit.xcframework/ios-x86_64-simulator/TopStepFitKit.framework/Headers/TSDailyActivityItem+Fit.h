//
//  TSDailyActivityItem+Fit.h
//  iOSDFULibrary
//
//  Created by 磐石 on 2025/4/20.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class FitCloudDailyHealthAndSportsDataObject;
@class FitCloudManualSyncRecordObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSDailyActivityItem (Fit)

+ (NSArray<TSDailyActivityItem *> *)dailyExerciseModelWithDBDicts:(NSArray <NSDictionary *>*)dbDicts ;

+ (NSArray<NSDictionary *> *)dailyExerciseDictWithFitCloudManualSyncRecord:(FitCloudManualSyncRecordObject *)record ;

+ (TSDailyActivityItem *)dailyActivityModelWithFitDailyModel:(FitCloudDailyHealthAndSportsDataObject *)fitDailyModel;

@end

NS_ASSUME_NONNULL_END
