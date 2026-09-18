//
//  TSFwExerciseGoals.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/11.
//

#import "TSFwKitBase.h"
#import "TSDailyActivityGoals+Fw.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFwExerciseGoals : TSFwKitBase

+ (void)getDailyExerciseGoalsWithCompletion:(nullable void(^)(TSDailyActivityGoals *goalModel,NSError *error))completion ;


+ (void)setDailyExerciseGoals:(nonnull TSDailyActivityGoals *)goalsModel completion:(TSCompletionBlock)completion ;

    
@end

NS_ASSUME_NONNULL_END
