//
//  TSSleepConcreteModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/4.
//

#import <Foundation/Foundation.h>

#import "TSSleepSummaryModel.h"
#import "TSSleepItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepConcreteModel : NSObject

/**
 * @brief Night sleep summary data
 * @chinese 夜间睡眠汇总数据
 *
 * @discussion
 * [EN]: Summary statistics for the night sleep period (20:00-09:00), including:
 * - Total sleep duration
 * - Sleep quality score
 * - Time in each sleep stage
 * - Sleep efficiency
 *
 * [CN]: 夜间睡眠时段（20:00-09:00）的汇总统计，包括：
 * - 总睡眠时长
 * - 睡眠质量评分
 * - 各睡眠阶段时长
 * - 睡眠效率
 */
@property (nonatomic, strong) TSSleepSummaryModel *sleepSummary;

/**
 * @brief Detailed night sleep stage records
 * @chinese 夜间睡眠阶段详细记录
 *
 * @discussion
 * [EN]: Array of sleep stage segments during night sleep period, each containing:
 * - Start and end time
 * - Sleep stage type (Wake/Light/Deep/REM)
 * - Duration of each stage
 * Used for detailed analysis of sleep architecture and patterns.
 *
 * [CN]: 夜间睡眠期间的睡眠阶段片段数组，每个片段包含：
 * - 开始和结束时间
 * - 睡眠阶段类型（清醒/浅睡/深睡/快速眼动）
 * - 每个阶段的持续时间
 * 用于详细分析睡眠结构和模式。
 */
@property (nonatomic, strong) NSArray<TSSleepItemModel *> *sleepItems;


@end

NS_ASSUME_NONNULL_END
