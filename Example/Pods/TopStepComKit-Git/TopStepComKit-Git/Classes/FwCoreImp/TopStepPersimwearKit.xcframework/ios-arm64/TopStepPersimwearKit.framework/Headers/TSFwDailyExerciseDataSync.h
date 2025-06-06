//
//  TSFwDailyExerciseDataSync.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSFwBaseDataSync.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFwDailyExerciseDataSync : TSFwBaseDataSync

+ (void)syncTodayDailyExerciseDataCompletion:(void (^)(TSDailyActivityValueModel * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
