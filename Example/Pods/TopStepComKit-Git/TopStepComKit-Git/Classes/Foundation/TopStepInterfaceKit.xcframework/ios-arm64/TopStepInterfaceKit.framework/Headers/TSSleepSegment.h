//
//  TSSleepSegment.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/20.
//

#import <Foundation/Foundation.h>
#import "TSSleepDetailItem.h"
#import "TSSleepSummary.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep period type enumeration
 * @chinese 睡眠时段类型枚举
 *
 * @discussion
 * [EN]: Defines the period of sleep based on data header time:
 * - Night: Main sleep period (20:00-09:00)
 * - Daytime: Daytime sleep period (09:00-20:00)
 *
 * [CN]: 根据数据头时间定义的睡眠时段：
 * - 夜间睡眠：主要睡眠时段（20:00-09:00）
 * - 日间睡眠：日间睡眠时段（09:00-20:00）
 */
typedef NS_ENUM(NSInteger, TSSleepPeriodType) {
    TSSleepPeriodTypeNight = 0,     // 夜间睡眠 [20:00-09:00)
    TSSleepPeriodTypeDaytime = 1    // 日间睡眠 [09:00-20:00)
};

/**
 * @brief Sleep segment model class
 * @chinese 睡眠段模型类
 *
 * @discussion
 * [EN]: This class represents a continuous sleep segment, containing:
 * - Period type (Night/Daytime)
 * - Summary statistics
 * - Detailed sleep stage items
 *
 * [CN]: 该类表示一个连续的睡眠段，包含：
 * - 时段类型（夜间/日间）
 * - 汇总统计信息
 * - 详细的睡眠阶段条目
 */
@interface TSSleepSegment : NSObject

/**
 * @brief Sleep period type
 * @chinese 睡眠时段类型
 *
 * @discussion
 * [EN]: Indicates whether this segment is night sleep or daytime sleep.
 *
 * [CN]: 指示此睡眠段是夜间睡眠还是日间睡眠。
 */
@property (nonatomic, assign) TSSleepPeriodType periodType;

/**
 * @brief Sleep summary statistics
 * @chinese 睡眠汇总统计
 *
 * @discussion
 * [EN]: Statistical summary of this sleep segment including time range,
 * durations, percentages, and quality score.
 *
 * [CN]: 此睡眠段的统计汇总，包括时间范围、时长、百分比和质量评分。
 */
@property (nonatomic, strong) TSSleepSummary *summary;

/**
 * @brief Detailed sleep stage items in chronological order
 * @chinese 按时间顺序的睡眠阶段详情条目数组
 *
 * @discussion
 * [EN]: Array of TSSleepDetailItem containing all sleep stages.
 * Used for detailed sleep architecture visualization and analysis.
 *
 * [CN]: 包含所有睡眠阶段的TSSleepDetailItem数组。
 * 用于详细的睡眠结构可视化和分析。
 */
@property (nonatomic, strong) NSArray<TSSleepDetailItem *> *detailItems;

@end

NS_ASSUME_NONNULL_END