//
//  TSDailyActivityGoalsModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/13.
//
//  文件说明:
//  每日运动目标数据模型，用于管理用户的运动目标设置，包括步数、卡路里、距离等指标

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Daily exercise goals model
 * @chinese 每日运动目标模型
 *
 * @discussion
 * EN: This class manages user's daily exercise goals, including:
 *     1. Daily steps target
 *     2. Calorie consumption target
 *     3. Distance target
 *     4. Activity duration target
 *     5. Exercise duration target
 *     6. Exercise frequency target
 *     Used for setting and retrieving user's daily exercise goals.
 *
 * CN: 该类用于管理用户的每日运动目标，包括：
 *     1. 每日步数目标
 *     2. 卡路里消耗目标
 *     3. 距离目标
 *     4. 活动时长目标
 *     5. 运动时长目标
 *     6. 运动次数目标
 *     用于设置和获取用户的每日运动目标数据。
 */
@interface TSDailyActivityGoalsModel : NSObject

/**
 * @brief Daily steps goal
 * @chinese 每日步数目标
 *
 * @discussion
 * EN: Daily target for number of steps.
 *     Unit: steps
 *     Range: 0-100,000 (recommended)
 *     Reference standards:
 *     - WHO recommendation: 6,000-8,000 steps/day
 *     - Sedentary lifestyle: 3,000-5,000 steps/day
 *     - Active lifestyle: 8,000-15,000 steps/day
 *     - Athletic lifestyle: >15,000 steps/day
 *
 * CN: 每日步数目标。
 *     单位：步
 *     范围：0-100,000（建议）
 *     参考标准：
 *     - WHO建议：每天6,000-8,000步
 *     - 久坐人群：3,000-5,000步
 *     - 活跃人群：8,000-15,000步
 *     - 运动达人：>15,000步
 *
 * @note
 * EN: Values outside the recommended range may affect accuracy of health analysis
 * CN: 超出建议范围的值可能会影响健康分析的准确性
 */
@property (nonatomic, assign) NSInteger stepsGoal;

/**
 * @brief Daily calories goal
 * @chinese 每日消耗卡路里目标
 *
 * @discussion
 * EN: Daily target for calorie consumption.
 *     Unit: kilocalories (kcal)
 *     Range: 50-3,000 (recommended)
 *     Reference standards:
 *     - Basic metabolism: 1,200-2,000 kcal/day
 *     - Daily activities: 300-1,000 kcal/day
 *     - Exercise consumption: 200-1,000 kcal/day
 *     The goal should be set based on individual's BMR and activity level.
 *
 * CN: 每日卡路里消耗目标。
 *     单位：千卡(kcal)
 *     范围：50-3,000（建议）
 *     参考标准：
 *     - 基础代谢：1,200-2,000kcal/天
 *     - 日常活动：300-1,000kcal/天
 *     - 运动消耗：200-1,000kcal/天
 *     目标应根据个人基础代谢率和活动水平设定。
 *
 * @note
 * EN: Consider age, gender, weight and activity level when setting this goal
 * CN: 设置此目标时需考虑年龄、性别、体重和活动水平
 */
@property (nonatomic, assign) NSInteger caloriesGoal;

/**
 * @brief Daily distance goal
 * @chinese 每日运动距离目标
 *
 * @discussion
 * EN: Daily target for movement distance.
 *     Unit: meters (m)
 *     Range: 0-100,000 (recommended)
 *     Reference standards:
 *     - WHO recommendation: 4,000-5,000 m/day
 *     - Daily activities: 2,000-6,000 m/day
 *     - Running exercise: 5,000-10,000 m/day
 *     - Maximum reference: 100km (ultra-marathon distance)
 *     The goal should align with user's fitness level and activity type.
 *
 * CN: 每日运动距离目标。
 *     单位：米(m)
 *     范围：0-100,000（建议）
 *     参考标准：
 *     - WHO建议：4,000-5,000米/天
 *     - 日常活动：2,000-6,000米/天
 *     - 跑步运动：5,000-10,000米/天
 *     - 最大值参考：100公里（超级马拉松距离）
 *     目标应与用户的体能水平和活动类型相匹配。
 */
@property (nonatomic, assign) NSInteger distanceGoal;

/**
 * @brief Daily activity duration goal
 * @chinese 每日活动时长目标
 *
 * @discussion
 * EN: Daily target for total activity duration.
 *     Unit: minutes (min)
 *     Range: 0-1,440 (24 hours)
 *     Includes all physical activities throughout the day:
 *     - Light activities (walking, standing)
 *     - Moderate activities (brisk walking)
 *     - Vigorous activities (running, sports)
 *
 * CN: 每日活动时长目标。
 *     单位：分钟(min)
 *     范围：0-1,440（24小时）
 *     包含全天所有身体活动：
 *     - 轻度活动（走路、站立）
 *     - 中度活动（快走）
 *     - 剧烈活动（跑步、运动）
 *
 * @note
 * EN: This includes all physical activities, not just exercise
 * CN: 这包括所有身体活动，不仅仅是运动
 */
@property (nonatomic, assign) NSInteger activityDurationGoal;

/**
 * @brief Daily exercise duration goal
 * @chinese 每日运动时长目标
 *
 * @discussion
 * EN: Daily target for exercise duration.
 *     Unit: minutes (min)
 *     Range: 0-1,440 (24 hours)
 *     Specifically refers to:
 *     - Moderate to vigorous physical activities
 *     - Continuous exercise sessions
 *     - Planned workout time
 *     Different from activity duration as it only counts moderate to vigorous exercise.
 *
 * CN: 每日运动时长目标。
 *     单位：分钟(min)
 *     范围：0-1,440（24小时）
 *     特指：
 *     - 中高强度身体活动
 *     - 持续运动时段
 *     - 计划锻炼时间
 *     与活动时长的区别：仅计算中高强度运动。
 *
 * @note
 * EN: WHO recommends 150+ minutes of moderate exercise per week
 * CN: WHO建议每周进行150分钟以上的中等强度运动
 */
@property (nonatomic, assign) NSInteger exerciseDurationGoal;

/**
 * @brief Daily exercise frequency goal
 * @chinese 每日运动次数目标
 *
 * @discussion
 * EN: Daily target for exercise frequency.
 *     Unit: times
 *     Range: 1-50 (recommended)
 *     Represents:
 *     - Number of planned exercise sessions per day
 *     - Each session should be a distinct exercise activity
 *     - Minimum duration per session: typically 10 minutes
 *
 * CN: 每日运动次数目标。
 *     单位：次
 *     范围：1-50（建议）
 *     表示：
 *     - 每天计划进行运动的次数
 *     - 每次应为独立的运动活动
 *     - 每次运动最短持续时间：通常10分钟
 *
 * @note
 * EN: Multiple short sessions can be as effective as one long session
 * CN: 多次短时运动的效果可能与一次长时运动相当
 */
@property (nonatomic, assign) NSInteger exerciseTimesGoal;

@end

NS_ASSUME_NONNULL_END
