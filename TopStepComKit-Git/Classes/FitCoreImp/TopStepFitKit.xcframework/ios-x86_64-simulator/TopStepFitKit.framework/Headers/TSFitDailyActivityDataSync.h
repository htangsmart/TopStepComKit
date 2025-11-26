//
//  TSFitDailyActivityDataSync.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSFitBaseDataSync.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitDailyActivityDataSync : TSFitBaseDataSync

+ (void)syncTodayDailyExerciseDataCompletion:(void (^)(TSActivityDailyModel * _Nullable, NSError * _Nullable))completion ;


@end

NS_ASSUME_NONNULL_END
