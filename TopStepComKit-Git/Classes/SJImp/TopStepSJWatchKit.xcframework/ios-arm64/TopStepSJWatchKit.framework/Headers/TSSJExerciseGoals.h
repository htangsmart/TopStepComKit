//
//  TSSJExerciseGoals.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/18.
//

#import "TSSJKitBase.h"
#import "TSDailyActivityGoalsModel+SJ.h"
#import <SJWatchLib/SJWatchLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSJExerciseGoals : TSSJKitBase

+ (void)getDailyExerciseGoalsWithCompletion:(nullable void(^)(TSDailyActivityGoalsModel * _Nullable dailyModel,NSError * _Nullable error))completion ;


+ (void)setDailyExerciseGoals:(nonnull TSDailyActivityGoalsModel *)goalsModel
                   completion:(TSCompletionBlock)completion ;

@end

NS_ASSUME_NONNULL_END
