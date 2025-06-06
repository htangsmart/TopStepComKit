//
//  TSDailyActivityGoalsModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/11.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDailyActivityGoalsModel (Fw)

+ (nullable TSDailyActivityGoalsModel *)goalsModelFromFwDailyGoalDict:(nullable NSDictionary *)fwDicts;


+ (nullable NSDictionary *)goalsDictWithDailyExerciseGoalsModel:(nullable TSDailyActivityGoalsModel *)dailyModel;


@end

NS_ASSUME_NONNULL_END
