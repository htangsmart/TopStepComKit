//
//  TSFwExerciseGoals.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/11.
//

#import "TSFwKitBase.h"
#import "TSDailyActivityGoalsModel+Fw.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFwExerciseGoals : TSFwKitBase

+ (void)getDailyExerciseGoalsWithCompletion:(nullable void(^)(TSDailyActivityGoalsModel *goalModel,NSError *error))completion ;


+ (void)setDailyExerciseGoals:(nonnull TSDailyActivityGoalsModel *)goalsModel completion:(TSCompletionBlock)completion ;

    
@end

NS_ASSUME_NONNULL_END
