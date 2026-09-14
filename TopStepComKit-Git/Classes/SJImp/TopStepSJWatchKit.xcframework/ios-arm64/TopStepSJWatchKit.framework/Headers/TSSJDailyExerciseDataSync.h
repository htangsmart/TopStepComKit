//
//  TSSJDailyExerciseDataSync.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import "TSSJBaseDataSync.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSSJDailyExerciseDataSync : TSSJBaseDataSync


+ (void)syncTodayDailyExerciseDataCompletion:(nonnull void (^)(TSDailyActivityValueModel * _Nullable, NSError * _Nullable))completion ;

@end

NS_ASSUME_NONNULL_END
