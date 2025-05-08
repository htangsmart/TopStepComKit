//
//  TSSleepItemModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/4.
//
#import "TSHealthValueModel.h"

/**
 * @brief Sleep period type enumeration
 * @chinese 睡眠时段类型枚举
 *
 * @discussion
 * [EN]: Defines the period of sleep based on circadian rhythm:
 * - Nocturnal: Main sleep period during night (typically 20:00-09:00)
 * - Daytime: Short periods of sleep during the day (typically 09:00-20:00)
 *   • Duration: Usually 10-90 minutes
 *   • Characteristics: Mainly light sleep, rarely enters deep sleep
 *   • Types: Power nap (10-20min), Regular nap (20-30min), Full cycle (90min)
 *
 * [CN]: 根据生理节律定义的睡眠时段：
 * - 夜间睡眠：夜间主要睡眠时段（通常在20:00-09:00之间）
 * - 日间睡眠：白天短暂的睡眠（通常在09:00-20:00之间）
 *   • 持续时间：通常10-90分钟
 *   • 特点：主要是浅睡眠，很少进入深睡眠
 *   • 类型：能量小憩(10-20分钟)、常规小憩(20-30分钟)、完整周期(90分钟)
 *
 * @note
 * [EN]: Based on sleep medicine standards and research on human sleep patterns.
 * Time ranges and durations are configurable based on individual sleep habits.
 *
 * [CN]: 基于睡眠医学标准和人类睡眠模式研究。
 * 时间范围和持续时间可根据个人睡眠习惯进行配置。
 */
typedef NS_ENUM(NSUInteger, TSSleepPeriodType) {
    TSSleepPeriodNocturnal = 0,    // 夜间睡眠 Nocturnal sleep (20:00-09:00)
    TSSleepPeriodDaytime           // 日间睡眠 Daytime sleep (09:00-20:00)
};

/**
 * @brief Sleep stage type enumeration
 * @chinese 睡眠阶段类型枚举
 *
 * @discussion
 * [EN]: Defines different stages of sleep according to AASM standards:
 * - Unknown: Sleep stage cannot be determined
 * - Wake: Subject is awake or in very light sleep
 * - Light: Light sleep phase (N1 and N2 stages)
 * - Deep: Deep sleep phase (N3 stage, slow-wave sleep)
 * - REM: Rapid Eye Movement sleep phase (dream sleep)
 *
 * [CN]: 根据AASM标准定义的不同睡眠阶段：
 * - 未知：无法判断的睡眠阶段
 * - 清醒：处于清醒或极浅睡眠状态
 * - 浅睡：浅睡眠阶段（N1和N2期）
 * - 深睡：深度睡眠阶段（N3期，慢波睡眠）
 * - 快速眼动：快速眼动睡眠阶段（做梦阶段）
 */
typedef NS_ENUM(NSUInteger, TSSleepStageType) {
    TSSleepStageUnknown,    // 未知阶段 Unknown stage
    TSSleepStageWake,       // 清醒阶段 Wake stage
    TSSleepStageLight,      // 浅睡阶段 Light sleep stage (N1 & N2)
    TSSleepStageDeep,       // 深睡阶段 Deep sleep stage (N3)
    TSSleepStageREM         // 快速眼动阶段 REM stage
};

/**
 * @brief Sleep item data model class
 * @chinese 睡眠数据模型类
 *
 * @discussion
 * [EN]: This class represents a sleep record segment, containing information about:
 * - Sleep start and end time
 * - Sleep duration
 * - Sleep state type
 * Used to track and analyze user's sleep patterns and quality.
 *
 * [CN]: 该类表示一段睡眠记录，包含以下信息：
 * - 睡眠开始和结束时间
 * - 睡眠持续时间
 * - 睡眠状态类型
 * 用于追踪和分析用户的睡眠模式和质量。
 */

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepItemModel : TSHealthValueModel

/**
 * @brief Sleep stage type
 * @chinese 睡眠状态类型
 *
 * @discussion
 * [EN]: The type of sleep state for this segment (Awake/Light/Deep/REM).
 * Used to analyze sleep quality and patterns.
 *
 * [CN]: 该睡眠片段的状态类型（清醒/浅睡/深睡/快速眼动）。
 * 用于分析睡眠质量和模式。
 */
@property (nonatomic, assign) TSSleepStageType sleepStageType;

/**
 * @brief Sleep period type
 * @chinese 睡眠时段类型
 *
 * @discussion
 * [EN]: Indicates whether this sleep segment belongs to nocturnal sleep (main sleep)
 * or daytime sleep (nap). This classification helps in differentiating between
 * primary sleep periods and supplementary naps for accurate sleep analysis.
 *
 * [CN]: 指示此睡眠片段属于夜间睡眠（主要睡眠）还是日间睡眠（小睡）。
 * 这种分类有助于区分主要睡眠时段和补充性小睡，以进行准确的睡眠分析。
 */
@property (nonatomic, assign) TSSleepPeriodType sleepPeriodType;

/**
 * @brief Timestamp of the day this sleep item belongs to
 * @chinese 睡眠项目所属日期的时间戳
 *
 * @discussion
 * [EN]: Unix timestamp (in seconds) representing midnight (00:00:00) of the day
 * to which this sleep item belongs. Used for grouping sleep items by calendar day
 * and associating them with the correct sleep record.
 *
 * [CN]: Unix时间戳（以秒为单位），表示此睡眠项目所属日期的午夜时刻（00:00:00）。
 * 用于按日历日对睡眠项目进行分组，并将它们与正确的睡眠记录关联。
 *
 * @note
 * [EN]: This value should match the belongingDayTimestamp of the parent sleep record.
 *
 * [CN]: 此值应与父睡眠记录的belongingDayTimestamp匹配。
 */
@property (nonatomic, assign) NSTimeInterval dayStartTimestamp;

@end

NS_ASSUME_NONNULL_END
