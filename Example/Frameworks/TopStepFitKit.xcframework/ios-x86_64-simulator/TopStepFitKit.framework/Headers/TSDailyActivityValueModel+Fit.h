//
//  TSDailyActivityValueModel+Fit.h
//  iOSDFULibrary
//
//  Created by 磐石 on 2025/4/20.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class FitCloudDailyHealthAndSportsDataObject;
@class FitCloudManualSyncRecordObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSDailyActivityValueModel (Fit)

+ (NSArray<TSDailyActivityValueModel *> *)dailyExerciseModelWithDBDicts:(NSArray <NSDictionary *>*)dbDicts ;

+ (NSArray<NSDictionary *> *)dailyExerciseDictWithFitCloudManualSyncRecord:(FitCloudManualSyncRecordObject *)record ;

+ (TSDailyActivityValueModel *)dailyActivityModelWithFitDailyModel:(FitCloudDailyHealthAndSportsDataObject *)fitDailyModel;

@end

NS_ASSUME_NONNULL_END
