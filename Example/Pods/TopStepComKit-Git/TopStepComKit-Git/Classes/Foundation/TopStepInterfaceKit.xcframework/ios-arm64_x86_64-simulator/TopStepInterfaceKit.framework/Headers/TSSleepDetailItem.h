//
//  TSSleepDetailItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/4.
//

#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep stage type enumeration
 * @chinese 睡眠阶段类型枚举
 *
 * @discussion
 * [EN]: Defines different stages of sleep according to AASM standards:
 * - Awake: Subject is awake during sleep period
 * - Light: Light sleep phase (N1 and N2 stages)
 * - Deep: Deep sleep phase (N3 stage, slow-wave sleep)
 * - REM: Rapid Eye Movement sleep phase (dream sleep)
 *
 * [CN]: 根据AASM标准定义的不同睡眠阶段：
 * - 清醒：睡眠期间处于清醒状态
 * - 浅睡：浅睡眠阶段（N1和N2期）
 * - 深睡：深度睡眠阶段（N3期，慢波睡眠）
 * - 快速眼动：快速眼动睡眠阶段（做梦阶段）
 */
typedef NS_ENUM(NSInteger, TSSleepStage) {
    TSSleepStageAwake = 0,    // 清醒阶段 Awake stage
    TSSleepStageLight = 1,    // 浅睡阶段 Light sleep stage (N1 & N2)
    TSSleepStageDeep  = 2,    // 深睡阶段 Deep sleep stage (N3)
    TSSleepStageREM   = 3     // 快速眼动阶段 REM stage
};

/**
 * @brief Sleep detail item model class
 * @chinese 睡眠详情条目模型类
 *
 * @discussion
 * [EN]: This class represents a single sleep stage segment, containing:
 * - Sleep stage type (Awake/Light/Deep/REM)
 * - Start time and duration
 * Used for detailed sleep architecture analysis.
 *
 * [CN]: 该类表示单个睡眠阶段片段，包含：
 * - 睡眠阶段类型（清醒/浅睡/深睡/快速眼动）
 * - 开始时间和持续时长
 * 用于详细的睡眠结构分析。
 */
@interface TSSleepDetailItem : TSHealthValueItem

#pragma mark - Sleep Stage Information

/**
 * @brief Sleep stage type
 * @chinese 睡眠阶段类型
 *
 * @discussion
 * [EN]: The type of sleep stage for this segment (Awake/Light/Deep/REM).
 * Used to analyze sleep quality and architecture.
 *
 * [CN]: 该睡眠片段的阶段类型（清醒/浅睡/深睡/快速眼动）。
 * 用于分析睡眠质量和结构。
 */
@property (nonatomic, assign) TSSleepStage stage;

#pragma mark - Date Attribution

/**
 * @brief Belonging date timestamp (00:00:00)
 * @chinese 所属日期时间戳（0时0分0秒）
 *
 * @discussion
 * [EN]: The timestamp of 00:00:00 of the day this sleep data belongs to.
 * Sleep data uses 20:00 as the day boundary [20:00→20:00).
 * For example:
 * - Sleep at 2025-11-19 21:00 belongs to 2025-11-20 00:00:00
 * - Sleep at 2025-11-20 08:00 belongs to 2025-11-20 00:00:00
 * - Sleep at 2025-11-20 21:00 belongs to 2025-11-21 00:00:00
 *
 * [CN]: 该睡眠数据所属日期的0时0分0秒时间戳。
 * 睡眠数据以 20:00 为跨天分隔线 [20:00→20:00)。
 * 例如：
 * - 2025-11-19 21:00 的睡眠归属于 2025-11-20 00:00:00
 * - 2025-11-20 08:00 的睡眠归属于 2025-11-20 00:00:00
 * - 2025-11-20 21:00 的睡眠归属于 2025-11-21 00:00:00
 */
@property (nonatomic, assign) NSTimeInterval belongingDate;

@end

NS_ASSUME_NONNULL_END
