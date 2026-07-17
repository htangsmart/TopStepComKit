//
//  TSSportDailyModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/20.
//

#import "TSHealthDailyModel.h"
#import "TSSportModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Per-calendar-day aggregation of sport sessions
 * @chinese 按日聚合的运动数据模型
 *
 * @discussion
 * [EN]: Extends `TSHealthDailyModel` with counts, total duration, and day-level min/max heart rate
 * derived from `sportRecords` (typically filled by sync or analytics layer).
 *
 * [CN]: 继承 `TSHealthDailyModel`，在 `sportRecords` 上汇总当日次数、总时长与心率极值（一般由同步或统计层赋值）。
 */
@interface TSSportDailyModel : TSHealthDailyModel

/**
 * @brief Sport activity records for the day
 * @chinese 当天的运动活动记录数组
 *
 * @discussion
 * [EN]: Array of TSSportModel objects representing all sport activities performed during the day.
 * [CN]: 表示当天所有运动活动的 TSSportModel 对象数组。
 */
@property (nonatomic, strong) NSArray<TSSportModel *> *sportRecords;

/**
 * @brief Number of sport activities
 * @chinese 运动次数
 *
 * @discussion
 * [EN]: The total number of sport activities performed during the day.
 *       This is a convenience property derived from sportRecords.count.
 * [CN]: 当天进行的运动活动总数。
 *       这是从 sportRecords.count 推导的便捷属性。
 */
@property (nonatomic, assign) NSUInteger sportCount;

/**
 * @brief Total sport duration
 * @chinese 总运动时长
 *
 * @discussion
 * [EN]: The total duration of all sport activities in seconds.
 *       Calculated by summing the duration of all activities in sportRecords.
 * [CN]: 所有运动活动的总时长，以秒为单位。
 *       通过累加 sportRecords 中所有活动的 duration 计算得出。
 */
@property (nonatomic, assign) NSTimeInterval totalDuration;

/**
 * @brief Maximum heart rate
 * @chinese 最大心率
 *
 * @discussion
 * [EN]: The highest heart rate recorded across all sport activities during the day, in BPM.
 *       Derived from the maxHrValue of all activities in sportRecords.
 * [CN]: 当天所有运动活动中记录的最高心率，以每分钟心跳次数表示。
 *       从 sportRecords 中所有活动的 maxHrValue 推导得出。
 */
@property (nonatomic, assign) UInt8 maxHeartRate;

/**
 * @brief Minimum heart rate
 * @chinese 最小心率
 *
 * @discussion
 * [EN]: The lowest heart rate recorded across all sport activities during the day, in BPM.
 *       Derived from the minHrValue of all activities in sportRecords.
 * [CN]: 当天所有运动活动中记录的最低心率，以每分钟心跳次数表示。
 *       从 sportRecords 中所有活动的 minHrValue 推导得出。
 */
@property (nonatomic, assign) UInt8 minHeartRate;

/**
 * @brief Debug dump of daily aggregates and a short preview of sessions
 * @chinese 调试输出：当日汇总及若干条运动预览
 *
 * @return
 * EN: Multi-line string with date key, duration, HR extrema, and up to a few `sportRecords` lines.
 * CN: 多行字符串，含日期键、时长、心率极值及少量运动记录预览。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
