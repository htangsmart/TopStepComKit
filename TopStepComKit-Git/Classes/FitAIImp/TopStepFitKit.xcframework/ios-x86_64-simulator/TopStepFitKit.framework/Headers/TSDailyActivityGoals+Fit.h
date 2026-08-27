//
//  TSDailyActivityGoals+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TSDailyExerciseGoalsModel与FitCloudDailyGoalObject模型转换分类
 *
 * @discussion 该分类提供了TSDailyExerciseGoalsModel与FitCloudDailyGoalObject之间的相互转换方法
 *            在转换过程中会自动处理单位换算：
 *            - 距离：厘米(cm) <-> 米(m)
 *            - 卡路里：小卡(cal) <-> 千卡(kcal)
 */
@interface TSDailyActivityGoals (Fit)

/**
 * @brief 将FitCloudDailyGoalObject转换为TSDailyExerciseGoalsModel
 *
 * @param fitGoal FitCloudDailyGoalObject对象
 *
 * @return TSDailyExerciseGoalsModel对象，如果输入为nil则返回nil
 *
 * @discussion 单位转换说明：
 *            - 距离：厘米(cm) -> 米(m)，除以100
 *            - 卡路里：小卡(cal) -> 千卡(kcal)，除以1000
 */
+ (nullable TSDailyActivityGoals *)goalsModelFromFitCloudDailyGoalObject:(nullable FitCloudDailyGoalObject *)fitGoal;

/**
 * @brief 将FitCloudDailyGoalObject数组转换为TSDailyExerciseGoalsModel数组
 *
 * @param fitGoals FitCloudDailyGoalObject对象数组
 *
 * @return TSDailyExerciseGoalsModel对象数组，如果输入为nil或空数组则返回空数组
 */
+ (NSArray<TSDailyActivityGoals *> *)goalsModelsFromFitCloudDailyGoalObjects:(nullable NSArray<FitCloudDailyGoalObject *> *)fitGoals;


@end

NS_ASSUME_NONNULL_END
