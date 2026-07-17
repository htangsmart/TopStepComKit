//
//  TSSleepSummary.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep summary data model
 * @chinese 睡眠总结数据模型
 *
 * @discussion
 * [EN]: Statistical summary of sleep data, including:
 * - Total sleep duration and quality score
 * - Time and percentage in each sleep stage
 * - Number of episodes for each stage
 * Can be used for night sleep or overall daily sleep summary.
 *
 * [CN]: 睡眠数据的统计汇总，包括：
 * - 总睡眠时长和质量评分
 * - 各睡眠阶段的时长和百分比
 * - 各阶段的次数
 * 可用于夜间睡眠或每日总体睡眠汇总。
 */
@interface TSSleepSummary : NSObject

#pragma mark - Time Information

/**
 * @brief Sleep start time
 * @chinese 睡眠开始时间
 *
 * @discussion
 * [EN]: Unix timestamp of sleep start time.
 *
 * [CN]: 睡眠开始时间的Unix时间戳。
 */
@property (nonatomic, assign) NSTimeInterval startTime;

/**
 * @brief Sleep end time
 * @chinese 睡眠结束时间
 *
 * @discussion
 * [EN]: Unix timestamp of sleep end time.
 *
 * [CN]: 睡眠结束时间的Unix时间戳。
 */
@property (nonatomic, assign) NSTimeInterval endTime;

/**
 * @brief Segment end-to-end duration (seconds)
 * @chinese 段端到端时长（秒）
 *
 * @discussion
 * [EN]: End-to-end span of the segment.
 * = endTime - startTime
 * May be larger than `totalSleepDuration` if there are gaps between detail items.
 * Use this only for display ("22:30–06:30, 8h"); use `totalSleepDuration` for any analytics.
 *
 * [CN]: 段从开始到结束的端到端跨度。
 * = endTime - startTime
 * 当各 detailItem 之间存在时间空洞时，会大于 `totalSleepDuration`。
 * 仅用于展示（如"22:30–06:30 共 8 小时"）；任何统计分析请使用 `totalSleepDuration`。
 */
@property (nonatomic, assign) NSTimeInterval duration;

#pragma mark - Overall Statistics

/**
 * @brief Total sleep duration including in-segment awake (seconds)
 * @chinese 段内总睡眠时长（含段内清醒，秒）
 *
 * @discussion
 * [EN]: Accumulated time inside the segment including short awake periods between
 * sleep stages (aligned with the product spec "零星小睡时长" definition).
 * = awakeDuration + lightSleepDuration + deepSleepDuration + remDuration
 * Equal to `duration` when detail items are contiguous; otherwise smaller.
 * Use this for nap [20min, 3h] threshold judgment and as the denominator for
 * stage percentages. For "pure sleep" (excluding awake), compute
 * lightSleepDuration + deepSleepDuration + remDuration at the call site.
 *
 * [CN]: 段内累计时长，包含睡眠阶段之间的短暂清醒（对齐产品文档"零星小睡时长"口径）。
 * = 清醒时长 + 浅睡时长 + 深睡时长 + REM时长
 * 当 detailItem 连续无空洞时等于 `duration`，否则小于 `duration`。
 * 用于零星小睡 [20min, 3h] 阈值判定，以及各阶段百分比的分母。
 * 如需"纯睡眠"（不含清醒），调用方就地计算 浅睡+深睡+REM 即可。
 */
@property (nonatomic, assign) NSTimeInterval totalSleepDuration;

/**
 * @brief Sleep quality score (0-100)
 * @chinese 睡眠质量评分（0-100）
 *
 * @discussion
 * [EN]: Overall sleep quality score based on:
 * - Sleep duration
 * - Deep sleep percentage
 * - Number of awakenings
 * Higher score indicates better sleep quality.
 *
 * [CN]: 综合睡眠质量评分，基于：
 * - 睡眠时长
 * - 深睡百分比
 * - 觉醒次数
 * 分数越高表示睡眠质量越好。
 */
@property (nonatomic, assign) UInt8 qualityScore;

#pragma mark - Stage Duration (seconds)

/**
 * @brief Total awake duration during sleep period (seconds)
 * @chinese 睡眠期间总清醒时长（秒）
 */
@property (nonatomic, assign) NSTimeInterval awakeDuration;

/**
 * @brief Total light sleep duration (seconds)
 * @chinese 总浅睡时长（秒）
 */
@property (nonatomic, assign) NSTimeInterval lightSleepDuration;

/**
 * @brief Total deep sleep duration (seconds)
 * @chinese 总深睡时长（秒）
 */
@property (nonatomic, assign) NSTimeInterval deepSleepDuration;

/**
 * @brief Total REM sleep duration (seconds)
 * @chinese 总REM时长（秒）
 */
@property (nonatomic, assign) NSTimeInterval remDuration;

#pragma mark - Stage Percentage (0-100, denominator: totalSleepDuration)

/**
 * @brief Awake percentage relative to totalSleepDuration
 * @chinese 清醒时间百分比（分母为 totalSleepDuration）
 */
@property (nonatomic, assign) UInt8 awakePercentage;

/**
 * @brief Light sleep percentage relative to totalSleepDuration
 * @chinese 浅睡时间百分比（分母为 totalSleepDuration）
 */
@property (nonatomic, assign) UInt8 lightSleepPercentage;

/**
 * @brief Deep sleep percentage relative to totalSleepDuration
 * @chinese 深睡时间百分比（分母为 totalSleepDuration）
 */
@property (nonatomic, assign) UInt8 deepSleepPercentage;

/**
 * @brief REM sleep percentage relative to totalSleepDuration
 * @chinese REM时间百分比（分母为 totalSleepDuration）
 */
@property (nonatomic, assign) UInt8 remPercentage;

#pragma mark - Episode Counts

/**
 * @brief Number of awake episodes
 * @chinese 觉醒次数
 */
@property (nonatomic, assign) UInt16 awakeCount;

/**
 * @brief Number of light sleep episodes
 * @chinese 浅睡次数
 */
@property (nonatomic, assign) UInt16 lightSleepCount;

/**
 * @brief Number of deep sleep episodes
 * @chinese 深睡次数
 */
@property (nonatomic, assign) UInt16 deepSleepCount;

/**
 * @brief Number of REM episodes
 * @chinese REM次数
 */
@property (nonatomic, assign) UInt16 remCount;

@end

NS_ASSUME_NONNULL_END