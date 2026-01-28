//
//  TSDailyActivityGoals.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/13.
//
//  文件说明:
//  每日运动目标数据模型，用于管理用户的运动目标设置，包括步数、卡路里、距离等指标

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Daily exercise goals model
 * @chinese 每日运动目标模型
 *
 * @discussion
 * EN: Manages user's daily exercise goals only, including:
 *     1) Steps 2) Calories 3) Distance 4) Activity duration 5) Exercise duration 6) Exercise frequency.
 *     For reminder switches, see TSDailyActivityReminder.
 * CN: 仅管理用户的每日运动目标，包括：
 *     1) 步数 2) 卡路里 3) 距离 4) 活动时长 5) 运动时长 6) 运动次数。
 *     提醒开关请见 TSDailyActivityReminder。
 */
@interface TSDailyActivityGoals : NSObject

/**
 * @brief Daily steps goal
 * @chinese 每日步数目标
 *
 * @discussion
 * EN: Daily target for number of steps. Unit: steps Range: 0–100,000 (recommended)
 * CN: 每日步数目标。单位：步 范围：0–100,000（建议）
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
 * EN: Daily target for calorie consumption. Unit: kilocalories (kcal) Range: 50–3,000 (recommended)
 * CN: 每日卡路里消耗目标。单位：千卡(kcal) 范围：50–3,000（建议）
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
 * EN: Daily target for movement distance. Unit: meters (m) Range: 0–100,000 (recommended)
 * CN: 每日运动距离目标。单位：米(m) 范围：0–100,000（建议）
 */
@property (nonatomic, assign) NSInteger distanceGoal;

/**
 * @brief Daily activity duration goal
 * @chinese 每日活动时长目标
 *
 * @discussion
 * EN: Daily target for total activity duration. Unit: minutes (min) Range: 0–1,440 (24h)
 * CN: 每日活动时长目标。单位：分钟(min) 范围：0–1,440（24小时）
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
 * EN: Daily target for exercise duration. Unit: minutes (min) Range: 0–1,440 (24h)
 * CN: 每日运动时长目标。单位：分钟(min) 范围：0–1,440（24小时）
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
 * EN: Daily target for exercise frequency. Unit: times Range: 1–50 (recommended)
 * CN: 每日运动次数目标。单位：次 范围：1–50（建议）
 *
 * @note
 * EN: Multiple short sessions can be as effective as one long session
 * CN: 多次短时运动的效果可能与一次长时运动相当
 */
@property (nonatomic, assign) NSInteger exerciseTimesGoal;

/**
 * @brief Daily activity frequency goal
 * @chinese 每日活动次数目标
 *
 * @discussion
 * EN: Daily target for activity frequency. Unit: times Range: 1–100 (recommended)
 * CN: 每日活动次数目标。单位：次 范围：1–100（建议）
 *
 * @note
 * EN: Includes all physical activities that exceed the minimum activity threshold,
 *     not just formal exercise sessions.
 * CN: 包括所有超过最小活动阈值的身体活动，不仅仅是正式运动。
 */
@property (nonatomic, assign) NSInteger activityTimesGoal;

@end

NS_ASSUME_NONNULL_END
