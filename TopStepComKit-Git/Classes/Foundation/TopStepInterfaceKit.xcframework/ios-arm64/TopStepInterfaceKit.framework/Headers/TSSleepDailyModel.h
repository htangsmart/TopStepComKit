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
    /// 基础规则：不带小睡功能
    /// Without nap support: No nap support
    TSSleepStatisticsRuleWithoutNap = 0,
    /// 带小睡功能：区分夜间和日间睡眠
    /// With nap support: Distinguishes night and day sleep
    TSSleepStatisticsRuleWithNap = 1,
    /// 最长夜间段：使用最长连续夜间睡眠段
    /// Longest night segment: Uses longest continuous night sleep
    TSSleepStatisticsRuleLongestNight = 2,
    /// 仅最长段：不区分夜间日间，仅使用最长连续段
    /// Longest only: No distinction, uses longest continuous segment
    TSSleepStatisticsRuleLongestOnly = 3
};

/**
 * @brief Daily sleep data model
 * @chinese 每日睡眠数据模型
 *
 * @discussion
 * [EN]: Represents one sleep calendar day: summary, night/day segments, and raw items after sync.
 * Inherits day bounds from `TSHealthDailyModel` (e.g. `startTime`).
 *
 * [CN]: 表示一个睡眠统计日：包含汇总、夜间/日间分段及同步后的原始条目；日期边界继承自 `TSHealthDailyModel`（如 `startTime`）。
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
 *
 * @discussion
 * [EN]: Aggregated metrics for the calendar sleep day after processing (e.g. total duration,
 * stage breakdown, quality score). Populated by the active statistics strategy together with segments.
 *
 * [CN]: 经策略处理后的该睡眠日汇总指标（如总时长、分期占比、质量分等），与夜间/日间分段一并生成。
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
 *
 * @discussion
 * [EN]: One or more continuous night-sleep segments for this day under the current statistics rule
 * (e.g. main sleep window). Order is typically chronological.
 *
 * [CN]: 在当前统计规则下，该日归属的夜间睡眠连续段（可有多段），顺序一般为时间先后。
 */
@property (nonatomic, strong) NSArray<TSSleepSegment *> *nightSleeps;

/**
 * @brief Daytime sleep segments - segments passing rule duration filter
 * @chinese 日间睡眠段数组（已通过规则时长过滤）
 *
 * @discussion
 * [EN]: Daytime sleep segments that already passed the rule's total sleep
 * duration window (e.g. WithNap / LongestNight: totalSleepDuration ∈ [20min, 3h],
 * where totalSleepDuration = awake + light + deep + rem).
 * `validNaps` returns this array as-is.
 *
 * [CN]: 已通过当前规则总睡眠时长窗口的日间睡眠段（如 WithNap / LongestNight
 * 要求 totalSleepDuration ∈ [20min, 3h]，其中 totalSleepDuration = 清醒+浅睡+深睡+REM）。
 * `validNaps` 直接返回此数组。
 */
@property (nonatomic, strong) NSArray<TSSleepSegment *> *daytimeSleeps;

#pragma mark - Convenience Methods

/**
 * @brief Get valid daytime naps
 * @chinese 获取有效的日间小睡
 *
 * @discussion
 * [EN]: Returns `daytimeSleeps` directly. The duration window
 * (totalSleepDuration ∈ [20min, 3h]) is enforced by the strategy when
 * populating `daytimeSleeps`, so no additional filtering is needed here.
 * The method is kept for call-site readability.
 *
 * [CN]: 直接返回 `daytimeSleeps`。时长窗口（totalSleepDuration ∈ [20min, 3h]）
 * 已由策略层在生成 `daytimeSleeps` 时保证，此处无需重复筛选。
 * 保留该方法仅为调用侧语义清晰。
 *
 * @return
 * EN: Same content as `daytimeSleeps`; empty array if none.
 * CN: 与 `daytimeSleeps` 等价；无数据时为空数组。
 */
- (NSArray<TSSleepSegment *> *)validNaps;

/**
 * @brief Process raw sleep items into daily models using a statistics rule
 * @chinese 按统计规则将原始睡眠条目处理为按日模型数组
 *
 * @param statisticsRule
 * EN: Rule selector (e.g. without nap, with nap, longest night, longest only).
 * CN: 统计规则（如不带小睡、带小睡、最长夜间段、仅最长段等）。
 *
 * @param rawItems
 * EN: Raw `TSSleepDetailItem` samples from device/sync; empty or nil yields nil from processor.
 * CN: 设备或同步侧的原始睡眠明细条目；为空或 nil 时处理器返回 nil。
 *
 * @return
 * EN: Array of `TSSleepDailyModel` sorted by sleep day, or nil if there is no input data.
 * CN: 按睡眠日排序的 `TSSleepDailyModel` 数组；无原始数据时为 nil。
 *
 * @discussion
 * [EN]: Convenience wrapper around `TSSleepDataProcessor` that groups items by belonging day,
 * merges awake segments, and applies the selected strategy.
 *
 * [CN]: 对 `TSSleepDataProcessor` 的便捷封装：按归属日分组、整理清醒段并执行对应策略。
 */
+ (nullable NSArray<TSSleepDailyModel *> *)processWithStatisticsRule:(TSSleepStatisticsRule)statisticsRule
                                                            rawItems:(NSArray<TSSleepDetailItem *> *)rawItems;

/**
 * @brief Human-readable multi-line description for debugging
 * @chinese 用于调试的多行可读描述
 *
 * @return
 * EN: String summarizing date, rule, raw count, summary metrics, and segment counts.
 * CN: 包含日期、规则、原始条数、汇总指标与分段信息的字符串。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END

