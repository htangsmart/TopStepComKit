//
//  TSSleepSummaryModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/4.
//

#import "TSHealthValueModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepSummaryModel : TSHealthValueModel

/**
 * @brief Timestamp of the day's start (00:00:00) that this sleep record belongs to
 * @chinese 睡眠记录所属日期的起始时间戳（00:00:00）
 *
 * @discussion
 * [EN]: Unix timestamp (in seconds) representing midnight (00:00:00) of the day
 * to which this sleep record belongs. Used for grouping and categorizing sleep
 * records by calendar day, regardless of when the actual sleep period started or ended.
 *
 * [CN]: Unix时间戳（以秒为单位），表示此睡眠记录所属日期的午夜时刻（00:00:00）。
 * 用于按日历日对睡眠记录进行分组和分类，无论实际睡眠时段何时开始或结束。
 *
 * @note
 * [EN]: For example, a sleep record spanning from 22:00 on 2025-03-01 to 07:00 on 2025-03-02
 * would have this value set to the timestamp of 2025-03-01 00:00:00.
 *
 * [CN]: 例如，一条从2025-03-01 20:00到2025-03-02 09:00的睡眠记录，
 * 该值将设置为2025-03-02 00:00:00的时间戳。
 */
@property (nonatomic, assign) NSTimeInterval dayStartTimestamp;

/**
 * @brief Total sleep duration in seconds
 * @chinese 总睡眠时长（秒）
 *
 * @discussion
 * [EN]: The total duration of the sleep period in seconds, including all sleep stages
 * (Light, Deep, REM) but excluding wake periods. For night sleep, this represents
 * the effective sleep time between 20:00-09:00. For naps, it includes sleep segments
 * between 09:00-20:00 that are:
 * - Longer than 20 minutes
 * - Shorter than 3 hours
 * - Have wake intervals less than 30 minutes between sleep stages
 *
 * [CN]: 睡眠期间的总持续时间（以秒为单位），包括所有睡眠阶段
 * （浅睡眠、深睡眠、快速眼动）但不包括清醒时间。对于夜间睡眠，
 * 表示20:00-09:00之间的有效睡眠时间。对于小睡，包括09:00-20:00之间符合以下条件的睡眠片段：
 * - 长于20分钟
 * - 短于3小时
 * - 睡眠阶段之间的清醒间隔小于30分钟
 *
 * @note
 * [EN]: Sleep segments that don't meet these criteria are excluded from the total duration.
 * This ensures accurate sleep analysis by filtering out invalid or insignificant sleep periods.
 *
 * [CN]: 不符合这些标准的睡眠片段将被排除在总时长之外。
 * 这确保通过过滤无效或不重要的睡眠期来进行准确的睡眠分析。
 */
@property (nonatomic, assign) NSInteger totalSleepDuration;

/**
 * @brief Sleep quality score
 * @chinese 睡眠质量评分
 *
 * @discussion
 * [EN]: A score from 0-100 indicating the quality of sleep, calculated based on
 * sleep duration, stages distribution, and interruptions.
 * Higher score indicates better sleep quality.
 *
 * [CN]: 0-100分的睡眠质量评分，基于睡眠时长、各阶段分布和中断次数计算。
 * 分数越高表示睡眠质量越好。
 */
@property (nonatomic, assign) UInt8 score;

/**
 * @brief Number of awake episodes during sleep
 * @chinese 睡眠期间清醒次数
 *
 * @discussion
 * [EN]: The number of times the user woke up during the sleep period.
 * Multiple consecutive awake records may be counted as a single episode.
 *
 * [CN]: 用户在睡眠期间醒来的次数。
 * 多个连续的清醒记录可能被计为一次清醒事件。
 */
@property (nonatomic, assign) UInt8 awakeSleepCount;

/**
 * @brief Number of light sleep episodes
 * @chinese 浅睡眠次数
 *
 * @discussion
 * [EN]: The number of light sleep episodes during the sleep period.
 * Light sleep includes N1 and N2 stages according to AASM classification.
 *
 * [CN]: 睡眠期间浅睡眠的次数。
 * 根据美国睡眠医学会(AASM)分类，浅睡眠包括N1和N2阶段。
 */
@property (nonatomic, assign) UInt8 lightSleepCount;

/**
 * @brief Number of deep sleep episodes
 * @chinese 深睡眠次数
 *
 * @discussion
 * [EN]: The number of deep sleep episodes during the sleep period.
 * Deep sleep corresponds to N3 stage (slow wave sleep) according to AASM classification.
 *
 * [CN]: 睡眠期间深睡眠的次数。
 * 根据美国睡眠医学会(AASM)分类，深睡眠对应N3阶段（慢波睡眠）。
 */
@property (nonatomic, assign) UInt8 deepSleepCount;

/**
 * @brief Number of REM sleep episodes
 * @chinese 眼动睡眠次数
 *
 * @discussion
 * [EN]: The number of REM (Rapid Eye Movement) sleep episodes during the sleep period.
 * REM sleep is associated with dreaming and memory consolidation.
 *
 * [CN]: 睡眠期间REM（快速眼动）睡眠的次数。
 * REM睡眠与做梦和记忆巩固有关。
 */
@property (nonatomic, assign) UInt8 remSleepCount;

/**
 * @brief Total time spent in awake state during sleep period (in second)
 * @chinese 睡眠期间清醒状态的总时间（秒）
 *
 * @discussion
 * [EN]: The total duration of awake episodes during the sleep period, measured in seconds.
 * High values may indicate sleep disturbances or insomnia.
 *
 * [CN]: 睡眠期间清醒状态的总持续时间，以秒为单位。
 * 较高的值可能表示睡眠障碍或失眠。
 */
@property (nonatomic, assign) UInt32 awakeSleepTime;

/**
 * @brief Total time spent in light sleep (in seconds)
 * @chinese 浅睡眠的总时间（秒）
 *
 * @discussion
 * [EN]: The total duration of light sleep stages during the sleep period, measured in seconds.
 * Light sleep typically accounts for 40-60% of total sleep time in healthy adults.
 *
 * [CN]: 睡眠期间浅睡眠阶段的总持续时间，以秒为单位。
 * 在健康成年人中，浅睡眠通常占总睡眠时间的40-60%。
 */
@property (nonatomic, assign) UInt32 lightSleepTime;

/**
 * @brief Total time spent in deep sleep (in seconds)
 * @chinese 深睡眠的总时间（秒）
 *
 * @discussion
 * [EN]: The total duration of deep sleep stages during the sleep period, measured in seconds.
 * Deep sleep is crucial for physical recovery and typically accounts for 10-25% of total sleep time.
 *
 * [CN]: 睡眠期间深睡眠阶段的总持续时间，以秒为单位。
 * 深睡眠对身体恢复至关重要，通常占总睡眠时间的10-25%。
 */
@property (nonatomic, assign) UInt32 deepSleepTime;

/**
 * @brief Total time spent in REM sleep (in seconds)
 * @chinese 眼动睡眠的总时间（秒）
 *
 * @discussion
 * [EN]: The total duration of REM sleep stages during the sleep period, measured in seconds.
 * REM sleep is important for cognitive functions and typically accounts for 20-25% of total sleep time.
 *
 * [CN]: 睡眠期间REM睡眠阶段的总持续时间，以秒为单位。
 * REM睡眠对认知功能很重要，通常占总睡眠时间的20-25%。
 */
@property (nonatomic, assign) UInt32 remSleepTime;

/**
 * @brief Percentage of awake time relative to total sleep duration
 * @chinese 清醒时间占总睡眠时长的百分比
 *
 * @discussion
 * [EN]: The percentage of time spent in awake state during the sleep period.
 * Values below 5% are considered normal for healthy sleep.
 *
 * [CN]: 睡眠期间处于清醒状态的时间百分比。
 * 低于5%的值被认为是健康睡眠的正常范围。
 */
@property (nonatomic, assign) UInt8 awakeSleepPercentage;

/**
 * @brief Percentage of light sleep time relative to total sleep duration
 * @chinese 浅睡眠时间占总睡眠时长的百分比
 *
 * @discussion
 * [EN]: The percentage of time spent in light sleep stages during the sleep period.
 * Typically ranges from 40-60% in healthy adults.
 *
 * [CN]: 睡眠期间处于浅睡眠阶段的时间百分比。
 * 在健康成年人中通常为40-60%。
 */
@property (nonatomic, assign) UInt8 lightSleepPercentage;

/**
 * @brief Percentage of deep sleep time relative to total sleep duration
 * @chinese 深睡眠时间占总睡眠时长的百分比
 *
 * @discussion
 * [EN]: The percentage of time spent in deep sleep stages during the sleep period.
 * Typically ranges from 10-25% in healthy adults, with higher percentages in children and adolescents.
 *
 * [CN]: 睡眠期间处于深睡眠阶段的时间百分比。
 * 在健康成年人中通常为10-25%，儿童和青少年的比例更高。
 */
@property (nonatomic, assign) UInt8 deepSleepPercentage;

/**
 * @brief Percentage of REM sleep time relative to total sleep duration
 * @chinese 眼动睡眠时间占总睡眠时长的百分比
 *
 * @discussion
 * [EN]: The percentage of time spent in REM sleep stages during the sleep period.
 * Typically ranges from 20-25% in healthy adults.
 *
 * [CN]: 睡眠期间处于REM睡眠阶段的时间百分比。
 * 在健康成年人中通常为20-25%。
 */
@property (nonatomic, assign) UInt8 remSleepPercentage;


@end

NS_ASSUME_NONNULL_END
