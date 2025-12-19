//
//  TSDailyActivityGoals+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/11.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDailyActivityGoals (Fw)

+ (nullable TSDailyActivityGoals *)goalsModelFromFwDailyGoalDict:(nullable NSDictionary *)fwDicts;


+ (nullable NSDictionary *)goalsDictWithDailyExerciseGoalsModel:(nullable TSDailyActivityGoals *)dailyModel;


@end

NS_ASSUME_NONNULL_END
