//
//  TSHRVDailyModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/05/29.
//

#import "TSHealthDailyModel.h"
#import "TSHRVValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Per-day HRV aggregation with personal baseline
 * @chinese 按日聚合的 HRV 数据模型，含个人基线
 *
 * @discussion
 * [EN]: Provides per-user baseline (with upper/lower bounds), daily status
 *       classification, and the day's manual / automatic HRV time series.
 *       Baseline values represent the user's personal normal range, typically
 *       computed by the device or backend over a rolling window (e.g. 7-30 days).
 * [CN]: 提供个人基线（含上下限）、当日状态分类、以及当日的主动 / 自动测量序列。
 *       基线值代表用户个人的正常范围，通常由设备或后台基于滚动窗口
 *       （如 7-30 天）计算得出。
 */
@interface TSHRVDailyModel : TSHealthDailyModel

#pragma mark - Personal Baseline

/**
 * @brief Personal baseline HRV value (ms)
 * @chinese 个人基线 HRV 值（毫秒）
 *
 * @discussion
 * [EN]: User's normal HRV level derived from rolling history. 0 means unavailable.
 * [CN]: 用户由历史滚动数据推导出的正常 HRV 水平。0 表示无数据。
 */
@property (nonatomic, assign) UInt16 baseline;

/**
 * @brief Upper bound of the baseline healthy range (ms)
 * @chinese 基线上限（毫秒）
 *
 * @discussion
 * [EN]: Readings above this bound are categorized as "imbalanced high". 0 means unavailable.
 * [CN]: 超过此上限的读数被归类为"不平衡偏高"。0 表示无数据。
 */
@property (nonatomic, assign) UInt16 baselineUpper;

/**
 * @brief Lower bound of the baseline healthy range (ms)
 * @chinese 基线下限（毫秒）
 *
 * @discussion
 * [EN]: Readings below this bound are categorized as "low" or "imbalanced low". 0 means unavailable.
 * [CN]: 低于此下限的读数被归类为"低"或"不平衡偏低"。0 表示无数据。
 */
@property (nonatomic, assign) UInt16 baselineLower;

#pragma mark - Daily Aggregation

/**
 * @brief Average HRV of the day (ms)
 * @chinese 当日平均 HRV 值（毫秒）
 *
 * @discussion
 * [EN]: Mean of all measured HRV samples within the day. Aggregated by the device
 *       or backend, not derived from `manualItems` / `autoItems` on the client side.
 *       0 means unavailable.
 * [CN]: 当日全部 HRV 测量样本的平均值。由设备或后台聚合得到，非客户端基于
 *       `manualItems` / `autoItems` 计算。0 表示无数据。
 */
@property (nonatomic, assign) UInt16 avgValue;

#pragma mark - Daily Status

/**
 * @brief HRV status of the day
 * @chinese 当日 HRV 状态
 *
 * @discussion
 * [EN]: Categorical assessment based on the day's HRV against personal baseline.
 *       Defaults to TSHRVStatusNone when unavailable.
 * [CN]: 基于当日 HRV 相对个人基线的分类评估。无评估结果时为 TSHRVStatusNone。
 */
@property (nonatomic, assign) TSHRVStatus status;

#pragma mark - Daily Measurement Items

/**
 * @brief Manual measurement HRV items (time ascending)
 * @chinese 主动测量 HRV 条目数组（按时间升序）
 */
@property (nonatomic, copy) NSArray<TSHRVValueItem *> *manualItems;

/**
 * @brief Automatic monitoring HRV items (time ascending)
 * @chinese 自动监测 HRV 条目数组（按时间升序）
 */
@property (nonatomic, copy) NSArray<TSHRVValueItem *> *autoItems;

#pragma mark - Convenience Accessors

/**
 * @brief All measured items (manual + auto), sorted by time ascending
 * @chinese 全部测量条目（主动 + 自动），按时间升序排序
 *
 * @return
 * EN: Merged list of `manualItems` and `autoItems`, ordered by timestamp.
 * CN: 合并后的测量点列表，按时间排序。
 */
- (NSArray<TSHRVValueItem *> *)allMeasuredItems;

#pragma mark - DB Conversion

/**
 * @brief Build daily HRV models from two DB tables (daily + items)
 * @chinese 由 daily 表行和 items 表行装配每日 HRV 模型数组
 *
 * @param dailyDicts
 * EN: Rows from the HRV daily table; each row contains `dayStartTime`,
 *     `baseline`, `baselineUpper`, `baselineLower`,
 *     `baselineStartTime`, `baselineEndTime`, `status`.
 * CN: HRV daily 表行；每行含 `dayStartTime`、`baseline`、
 *     `baselineUpper`、`baselineLower`、`baselineStartTime`、
 *     `baselineEndTime`、`status` 等字段。
 *
 * @param itemDicts
 * EN: Rows from the HRV detail items table; grouped by `dayStartTime`.
 *     Field layout matches `TSHRVValueItem.valueItemFromDBDict:`.
 * CN: HRV 明细行；实现内按 `dayStartTime` 分组。字段布局与
 *     `TSHRVValueItem.valueItemFromDBDict:` 一致。
 *
 * @return
 * EN: Sorted `TSHRVDailyModel` array; empty if both inputs are nil/empty.
 * CN: 按日排序的模型数组；两个入参均为空时返回空数组。
 */
+ (NSArray<TSHRVDailyModel *> *)dailyModelsFromDailyDicts:(NSArray<NSDictionary *> *)dailyDicts
                                                itemDicts:(NSArray<NSDictionary *> *)itemDicts;

/**
 * @brief Multi-line debug summary for logging
 * @chinese 多行调试输出
 *
 * @return
 * EN: Daily baseline, status and item list sizes.
 * CN: 当日基线、状态、各列表规模等。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
