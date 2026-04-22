//
//  TSDailyActivityItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Daily activity and exercise data model
 * @chinese 每日活动和运动数据模型
 *
 * @discussion
 * [EN]: This class represents daily activity and exercise statistics, including:
 * - Basic activity metrics (steps, distance, calories)
 * - Activity duration tracking
 * - Exercise session statistics
 * Used to analyze user's daily physical activity patterns and exercise habits.
 *
 * [CN]: 该类表示每日活动和运动统计数据，包括：
 * - 基础活动指标（步数、距离、卡路里）
 * - 活动时长追踪
 * - 运动会话统计
 * 用于分析用户的日常身体活动模式和运动习惯。
 */
@interface TSDailyActivityItem : TSHealthValueItem

/**
 * @brief Total step count for the day
 * @chinese 当日总步数
 *
 * @discussion
 * [EN]: The total number of steps taken during the day.
 * Used to track daily walking activity and progress towards step goals.
 *
 * [CN]: 当天累计的总步数。
 * 用于追踪每日步行活动和步数目标的完成进度。
 */
@property (nonatomic, assign) NSInteger steps;

/**
 * @brief Total calories burned in calories
 * @chinese 消耗的总卡路里（小卡）
 *
 * @discussion
 * [EN]: Total energy expenditure from all activities (in calories).
 * Includes both basal metabolic rate and activity-induced calorie burn.
 *
 * [CN]: 所有活动消耗的总能量（以小卡为单位）。
 * 包括基础代谢率和活动导致的卡路里消耗。
 */
@property (nonatomic, assign) NSInteger calories;

/**
 * @brief Total distance covered in meters
 * @chinese 总距离（米）
 *
 * @discussion
 * [EN]: Total distance covered during all activities (in meters).
 * Calculated based on step count and stride length estimation.
 *
 * [CN]: 所有活动累计的总距离（以米为单位）。
 * 根据步数和步幅估算计算得出。
 */
@property (nonatomic, assign) NSInteger distance;

/**
 * @brief Total activity duration in seconds
 * @chinese 总活动时长（秒）
 *
 * @discussion
 * [EN]: Total time spent in physical activity during the day (in seconds).
 * Includes all movement activities that exceed the minimum activity threshold.
 *
 * [CN]: 当天累计的身体活动时间（以秒为单位）。
 * 包括所有超过最小活动阈值的运动时间。
 */
@property (nonatomic, assign) NSInteger activityDuration;

/**
 * @brief Total exercise duration in seconds
 * @chinese 运动时长（秒）
 *
 * @discussion
 * [EN]: Total time spent in dedicated exercise sessions (in seconds).
 * Only includes activities that qualify as exercise based on intensity and duration.
 *
 * [CN]: 专门运动会话的总时长（以秒为单位）。
 * 仅包括根据强度和持续时间判定为运动的活动。
 */
@property (nonatomic, assign) NSInteger exercisesDuration;

/**
 * @brief Number of exercise sessions
 * @chinese 运动次数
 *
 * @discussion
 * [EN]: The total number of distinct exercise sessions during the day.
 * Each session is counted when it meets minimum duration and intensity criteria.
 *
 * [CN]: 当天进行的运动会话总次数。
 * 每次会话需要满足最小持续时间和强度标准才会被计数。
 */
@property (nonatomic, assign) NSInteger exercisesTimes;

/**
 * @brief Number of activity sessions
 * @chinese 活动次数
 *
 * @discussion
 * [EN]: The total number of distinct activity sessions during the day.
 * Includes all physical activities that exceed the minimum activity threshold,
 * regardless of whether they qualify as formal exercise.
 *
 * [CN]: 当天进行的活动会话总次数。
 * 包括所有超过最小活动阈值的身体活动，
 * 无论是否被认定为正式运动。
 */
@property (nonatomic, assign) NSInteger activityTimes;

/**
 * @brief Map multiple daily-activity rows to items
 * @chinese 将多条日活动统计行转为 TSDailyActivityItem 数组
 *
 * @param dicts
 * EN: Row dictionaries compatible with `valueItemFromDBDict:`.
 * CN: 与 `valueItemFromDBDict:` 字段约定一致的字典数组。
 *
 * @return
 * EN: Non-nil array; empty if `dicts` is nil or empty; nil rows skipped.
 * CN: 非 nil 数组；入参为空时返回空数组，无法解析的行被跳过。
 */
+ (NSArray<TSDailyActivityItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Map one daily-activity row to an item
 * @chinese 将单条日活动统计行转为模型
 *
 * @param dict
 * EN: Keys include `steps`, `calories`, `distance`, `activityDuration`/`exercisesDuration` (minutes in DB, converted to seconds in model), counts, and time fields.
 * CN: 含步数、卡路里、距离、`activityDuration`/`exercisesDuration`（库中为分钟，模型内转为秒）、次数及时间字段等。
 *
 * @return
 * EN: Populated item, or nil if `dict` is nil.
 * CN: 填充后的模型；`dict` 为 nil 时返回 nil。
 */
+ (nullable TSDailyActivityItem *)valueItemFromDBDict:(NSDictionary *)dict;

/**
 * @brief Multi-line formatted debug output
 * @chinese 多行格式化调试输出
 *
 * @return
 * EN: Steps, distance, calories, durations, session counts, and derived ratios when applicable.
 * CN: 步数、距离、卡路里、时长、会话次数及可计算的比例等。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
