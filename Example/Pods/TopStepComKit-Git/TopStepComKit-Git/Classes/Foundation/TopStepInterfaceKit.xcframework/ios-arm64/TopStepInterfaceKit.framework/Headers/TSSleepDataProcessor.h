//
//  TSSleepDataProcessor.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/20.
//

#import <Foundation/Foundation.h>
#import "TSSleepDailyModel.h"
#import "TSSleepDetailItem.h"
#import "TSSleepStatisticsStrategy.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep data processor class
 * @chinese 睡眠数据处理类
 *
 * @discussion
 * [EN]: This class is responsible for processing raw sleep detail items and generating
 * TSSleepDailyModel with sleep segments and summary according to different statistics rules.
 *
 * [CN]: 该类负责处理原始睡眠详情条目，并根据不同的统计规则生成
 * 包含睡眠段和汇总的 TSSleepDailyModel。
 */
@interface TSSleepDataProcessor : NSObject

/**
 * @brief Process raw sleep detail items into per-day models using a statistics rule
 * @chinese 按统计规则将原始睡眠明细处理为按日睡眠模型
 *
 * @param statisticsRule
 * EN: Which `TSSleepStatisticsStrategy` implementation to use (maps to WithoutNap / WithNap / LongestNight / LongestOnly).
 * CN: 选用的统计规则，对应 WithoutNap、WithNap、LongestNight、LongestOnly 等策略实现。
 *
 * @param rawItems
 * EN: Chronological `TSSleepDetailItem` samples (including awake stages where present).
 * CN: 按时间排列的原始睡眠明细（可含清醒段）。
 *
 * @return
 * EN: Array of `TSSleepDailyModel` in ascending sleep-day order; `nil` if `rawItems` is nil or empty.
 * CN: 按睡眠日升序排列的 `TSSleepDailyModel` 数组；`rawItems` 为空或 nil 时返回 nil。
 *
 * @discussion
 * [EN]: Steps include: assign each item a belonging day (20:00 cut-off), group by day, strip and
 * re-insert awake intervals for continuity, then run the strategy to fill `dailySummary`, `nightSleeps`,
 * and `daytimeSleeps` on each `TSSleepDailyModel`.
 *
 * [CN]: 流程包括：按 20:00 规则计算归属日、按日分组、删除并重新插入清醒段以保证连续，再按策略生成每日的
 * `dailySummary`、`nightSleeps`、`daytimeSleeps`。
 */
+ (nullable NSArray<TSSleepDailyModel *> *)processWithStatisticsRule:(TSSleepStatisticsRule)statisticsRule
                                                            rawItems:(NSArray<TSSleepDetailItem *> *)rawItems;

@end

NS_ASSUME_NONNULL_END

