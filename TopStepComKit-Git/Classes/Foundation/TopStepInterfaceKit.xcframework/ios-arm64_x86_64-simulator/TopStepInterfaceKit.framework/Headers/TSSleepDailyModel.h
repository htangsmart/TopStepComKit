//
//  TSSleepDailyModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSHealthDailyModel.h"
#import "TSSleepSummary.h"
#import "TSSleepSegment.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep statistics rule type
 * @chinese 睡眠统计规则类型
 *
 * @discussion
 * [EN]: Different sleep statistics rules based on device capabilities and processing logic:
 * - Basic: No nap support, sensor active 20:00-12:00, all sleep treated as night sleep
 * - WithNap: Nap support enabled, sensor active 24h, distinguishes night/day sleep
 * - LongestNight: Uses longest continuous night sleep segment (20:00-08:00), valid naps counted
 * - LongestOnly: No distinction between night/day, uses longest continuous sleep segment only
 *
 * [CN]: 基于设备能力和处理逻辑的不同睡眠统计规则：
 * - Basic: 不带小睡功能，传感器20:00-12:00激活，所有睡眠视为夜间睡眠
 * - WithNap: 带小睡功能，传感器24小时激活，区分夜间和日间睡眠
 * - LongestNight: 使用最长连续夜间睡眠段（20:00-08:00），有效小睡计入统计
 * - LongestOnly: 不区分夜间和日间，仅使用最长连续睡眠段
 */
typedef NS_ENUM(NSInteger, TSSleepStatisticsRule) {
    /// 基础规则：不带小睡功能 Without nap support: No nap support
    TSSleepStatisticsRuleWithoutNap = 0,
    /// 带小睡功能：区分夜间和日间睡眠 With nap support: Distinguishes night and day sleep
    TSSleepStatisticsRuleWithNap = 1,
    /// 最长夜间段：使用最长连续夜间睡眠段 Longest night segment: Uses longest continuous night sleep
    TSSleepStatisticsRuleLongestNight = 2,
    /// 仅最长段：不区分夜间日间，仅使用最长连续段 Longest only: No distinction, uses longest continuous segment
    TSSleepStatisticsRuleLongestOnly = 3
};

/**
 * @brief Daily sleep data model
 * @chinese 每日睡眠数据模型
 *
 */
@interface TSSleepDailyModel : TSHealthDailyModel

#pragma mark - Basic Information

/**
 * @brief Statistics rule used for this sleep record
 * @chinese 此睡眠记录使用的统计规则
 *
 * @discussion
 * [EN]: Indicates which rule was used to process this sleep data.
 * Different devices/platforms may use different rules.
 *
 * [CN]: 指示使用哪个规则处理此睡眠数据。
 * 不同设备/平台可能使用不同规则。
 */
@property (nonatomic, assign) TSSleepStatisticsRule statisticsRule;

#pragma mark - Sleep Summary

/**
 * @brief Overall daily sleep summary
 * @chinese 当日睡眠总体汇总
 */
@property (nonatomic, strong) TSSleepSummary *dailySummary;

#pragma mark - Raw Data

/**
 * @brief Raw sleep items from device
 * @chinese 原始睡眠数据条目数组
 *
 * @discussion
 * [EN]: Array of raw sleep detail items synced from device before processing.
 * These items are used to generate sleep segments (nightSleeps and daytimeSleeps).
 *
 * [CN]: 从设备同步来的原始睡眠详情条目数组（未经处理）。
 * 这些条目用于生成睡眠段（nightSleeps 和 daytimeSleeps）。
 */
@property (nonatomic, strong) NSArray<TSSleepDetailItem *> *rawSleepItems;

#pragma mark - Sleep Segments

/**
 * @brief Night sleep segments
 * @chinese 夜间睡眠段数组
 */
@property (nonatomic, strong) NSArray<TSSleepSegment *> *nightSleeps;

/**
 * @brief Daytime sleep segments - all segments
 * @chinese 日间睡眠段数组 - 所有片段
 */
@property (nonatomic, strong) NSArray<TSSleepSegment *> *daytimeSleeps;

#pragma mark - Convenience Methods

/**
 * @brief Get valid daytime naps only
 * @chinese 获取仅有效的日间小睡
 *
 * @discussion
 * [EN]: Returns only valid naps from daytimeSleeps where isValid = YES.
 * This is a convenience method for filtering valid naps (20min < duration <= 3h).
 * Only these naps are counted in dailySummary statistics.
 *
 * [CN]: 从 daytimeSleeps 中筛选出 isValid = YES 的有效小睡。
 * 这是一个便捷方法，用于获取有效的小睡（20分钟 < 时长 <= 3小时）。
 * 仅这些小睡计入 dailySummary 统计。
 *
 * @return Array of valid naps
 */
- (NSArray<TSSleepSegment *> *)validNaps;

+ (NSArray<TSSleepDailyModel *> *)dailyModelsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

+ (NSArray<TSSleepDailyModel *> *)processWithStatisticsRule:(TSSleepStatisticsRule)statisticsRule                   rawItems:(NSArray<TSSleepDetailItem *> *)rawItems ;


- (NSString *)debugDescription ;

@end

NS_ASSUME_NONNULL_END

