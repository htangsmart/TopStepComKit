//
//  TSActivityDailyModel.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSHealthDailyModel.h"
#import "TSDailyActivityItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSActivityDailyModel : TSHealthDailyModel


/**
 * @brief Daily aggregated steps
 * @chinese 当日步数汇总
 *
 * @discussion
 * [EN]: Sum of steps from all TSDailyActivityItem entries of the day.
 * [CN]: 当日所有 TSDailyActivityItem 的步数总和。
 */
@property (nonatomic, assign) NSInteger steps;

/**
 * @brief Daily aggregated calories (cal)
 * @chinese 当日卡路里汇总（小卡）
 *
 * @discussion
 * [EN]: Sum of calories from all entries.
 * [CN]: 当日所有条目的 calories 之和。
 */
@property (nonatomic, assign, readonly) NSInteger calories;

/**
 * @brief Daily aggregated distance (meters)
 * @chinese 当日距离汇总（米）
 *
 * @discussion
 * [EN]: Sum of distance from all entries.
 * [CN]: 当日所有条目的 distance 之和。
 */
@property (nonatomic, assign, readonly) NSInteger distance;

/**
 * @brief Daily aggregated activity duration (seconds)
 * @chinese 当日活动时长汇总（秒）
 *
 * @discussion
 * [EN]: Sum of activityDuration from all entries.
 * [CN]: 当日所有条目的 activityDuration 之和。
 */
@property (nonatomic, assign, readonly) NSInteger activityDuration;

/**
 * @brief Daily aggregated activity times
 * @chinese 当日活动次数汇总
 *
 * @discussion
 * [EN]: Sum of activityTimes from all entries.
 * [CN]: 当日所有条目的 activityTimes 之和。
 */
@property (nonatomic, assign, readonly) NSInteger activityTimes;

/**
 * @brief Daily aggregated exercises duration (seconds)
 * @chinese 当日运动时长汇总（秒）
 *
 * @discussion
 * [EN]: Sum of exercisesDuration from all entries.
 * [CN]: 当日所有条目的 exercisesDuration 之和。
 */
@property (nonatomic, assign, readonly) NSInteger exercisesDuration;

/**
 * @brief Daily aggregated exercises times
 * @chinese 当日运动次数汇总
 *
 * @discussion
 * [EN]: Sum of exercisesTimes from all entries.
 * [CN]: 当日所有条目的 exercisesTimes 之和。
 */
@property (nonatomic, assign, readonly) NSInteger exercisesTimes;


/**
 * @brief Daily activity measurement items
 * @chinese 当天活动测量条目数组
 *
 * @discussion
 * [EN]: Array of daily activity items for this day, ordered by time ascending.
 *       Each element is a TSDailyActivityItem.
 * [CN]: 当天活动测量条目数组，按时间升序排列。数组元素为 TSDailyActivityItem。
 */
@property (nonatomic, strong) NSArray<TSDailyActivityItem *> *activityItems;

/**
 * @brief Designated initializer with all daily aggregates
 * @chinese 含当日所有汇总字段的指定初始化方法
 *
 * @param startTime [EN]: Day start timestamp; [CN]: 当天开始时间戳
 * @param endTime [EN]: Day end timestamp; [CN]: 当天结束时间戳
 * @param duration [EN]: Day duration (seconds); [CN]: 当天持续时长（秒）
 * @param measuredItems [EN]: Detail items; [CN]: 当日明细条目数组
 * @param steps [EN]: Aggregated steps; [CN]: 步数汇总
 * @param calories [EN]: Aggregated calories; [CN]: 卡路里汇总
 * @param distance [EN]: Aggregated distance; [CN]: 距离汇总
 * @param activityDuration [EN]: Aggregated activity duration; [CN]: 活动时长汇总
 * @param exercisesDuration [EN]: Aggregated exercises duration; [CN]: 运动时长汇总
 * @param exercisesTimes [EN]: Aggregated exercises times; [CN]: 运动次数汇总
 * @param activityTimes [EN]: Aggregated activity times; [CN]: 活动次数汇总
 */
- (instancetype)initWithStartTime:(NSTimeInterval)startTime
                          endTime:(NSTimeInterval)endTime
                          duration:(NSTimeInterval)duration
                    activityItems:(NSArray<TSDailyActivityItem *> *)activityItems
                              steps:(NSInteger)steps
                            calories:(NSInteger)calories
                            distance:(NSInteger)distance
                   activityDuration:(NSInteger)activityDuration
                 exercisesDuration:(NSInteger)exercisesDuration
                      exercisesTimes:(NSInteger)exercisesTimes
                       activityTimes:(NSInteger)activityTimes NS_DESIGNATED_INITIALIZER;

+ (NSArray<TSActivityDailyModel *> *)dailyModelsFromDBDicts:(NSArray<NSDictionary *> *)dicts;


- (NSString *)debugDescription ;

@end

NS_ASSUME_NONNULL_END
