//
//  TSSleepNapModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/5.
//

#import "TSHealthValueModel.h"
#import "TSSleepConcreteModel.h"
#import "TSSleepSummaryModel.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Daytime nap sleep data model
 * @chinese 日间小睡数据模型
 *
 * @discussion
 * [EN]: This class represents daytime nap sleep records (09:00-20:00), including:
 * - Overall nap summary (total duration, quality score, etc.)
 * - Individual nap segments with detailed sleep stages
 * - Only valid naps (duration between 20min and 3h) are included
 * - Naps are separated by wake periods >= 30min
 *
 * [CN]: 该类表示日间小睡记录（09:00-20:00），包含：
 * - 小睡总体汇总（总时长、质量评分等）
 * - 包含详细睡眠阶段的独立小睡片段
 * - 仅包含有效小睡（时长在20分钟到3小时之间）
 * - 小睡之间由>=30分钟的清醒间隔分隔
 */
@interface TSSleepNapModel : TSHealthValueModel

/**
 * @brief Summary of all daytime naps
 * @chinese 日间小睡汇总数据
 *
 * @discussion
 * [EN]: Aggregated statistics for all daytime naps, including:
 * - Total nap duration
 * - Average nap duration
 * - Sleep quality metrics
 * - Time distribution in different sleep stages
 * Note: Only includes valid naps (20min < duration <= 3h)
 *
 * [CN]: 所有日间小睡的汇总统计，包括：
 * - 总小睡时长
 * - 平均小睡时长
 * - 睡眠质量指标
 * - 各睡眠阶段时间分布
 * 注意：仅包含有效小睡（20分钟 < 时长 <= 3小时）
 */
@property (nonatomic, strong) TSSleepSummaryModel *napSummary;

/**
 * @brief Array of individual nap records
 * @chinese 独立小睡记录数组
 *
 * @discussion
 * [EN]: Collection of individual nap segments, each containing:
 * - Detailed sleep stages (Light/Deep/REM)
 * - Start and end times
 * - Sleep quality metrics
 * Rules for nap separation:
 * - Wake periods >= 30min separate naps
 * - Each nap must be 20min-3h in duration
 * - Invalid naps are excluded
 *
 * [CN]: 独立小睡片段的集合，每个片段包含：
 * - 详细的睡眠阶段（浅睡/深睡/快速眼动）
 * - 开始和结束时间
 * - 睡眠质量指标
 * 小睡分割规则：
 * - 清醒间隔>=30分钟视为不同小睡
 * - 每次小睡时长必须在20分钟到3小时之间
 * - 排除无效的小睡记录
 */
@property (nonatomic, strong) NSArray<TSSleepConcreteModel *> *napItems;

@end

NS_ASSUME_NONNULL_END
