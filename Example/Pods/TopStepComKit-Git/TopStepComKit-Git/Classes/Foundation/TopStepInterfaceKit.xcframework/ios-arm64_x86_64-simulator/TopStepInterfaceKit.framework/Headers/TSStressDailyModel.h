//
//  TSStressDailyModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSHealthDailyModel.h"
#import "TSStressValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Per-day stress aggregation model
 * @chinese 按日聚合的压力数据模型
 *
 * @discussion
 * [EN]: Extends `TSHealthDailyModel` with min/max items, manual vs auto series, and helpers
 * aligned with `TSHealthValueType` markers in DB rows (`valueType`).
 *
 * [CN]: 在 `TSHealthDailyModel` 上增加当日最大/最小压力条目、主动/自动测量序列，并与库表中的 `valueType` 标记对齐。
 */
@interface TSStressDailyModel : TSHealthDailyModel

/**
 * @brief Maximum stress item of the day
 * @chinese 当天最大压力条目
 *
 * @discussion
 * [EN]: The TSStressValueItem representing the highest stress measurement for the day.
 *       Only records with appropriate valueType (e.g., max) should populate this field.
 * [CN]: 表示当天记录到的最高压力测量条目。
 *       仅应由标记为“最大值”的记录填充该字段。
 */
@property (nonatomic, strong, nullable) TSStressValueItem *maxStressItem;

/**
 * @brief Minimum stress item of the day
 * @chinese 当天最小压力条目
 *
 * @discussion
 * [EN]: The TSStressValueItem representing the lowest stress measurement for the day.
 *       Only records with appropriate valueType (e.g., min) should populate this field.
 * [CN]: 表示当天记录到的最低压力测量条目。
 *       仅应由标记为“最小值”的记录填充该字段。
 */
@property (nonatomic, strong, nullable) TSStressValueItem *minStressItem;

/**
 * @brief Manual measurement stress items
 * @chinese 主动测量压力条目数组
 *
 * @discussion
 * [EN]: Array of user-initiated stress measurements, ordered by time ascending.
 * [CN]: 用户主动测量的压力数组，按时间升序排列。
 */
@property (nonatomic, copy) NSArray<TSStressValueItem *> *manualItems;

/**
 * @brief Automatic monitoring stress items
 * @chinese 自动监测压力条目数组
 *
 * @discussion
 * [EN]: Array of automatically monitored stress items, ordered by time ascending.
 * [CN]: 设备自动监测的压力数组，按时间升序排列。
 */
@property (nonatomic, copy) NSArray<TSStressValueItem *> *autoItems;

/**
 * @brief Get maximum stress level value
 * @chinese 获取最大压力值
 *
 * @discussion
 * [EN]: Convenience value derived from maxStressItem.stressValue.
 *       Returns 0 if maxStressItem is nil.
 * [CN]: 由 maxStressItem.stressValue 推导的便捷数值。
 *       当 maxStressItem 为空时返回 0。
 *
 * @return
 * EN: Maximum stress value (0–100 scale); 0 if `maxStressItem` is nil.
 * CN: 最大压力值（0–100 量纲）；无条目时为 0。
 */
- (UInt8)maxStress;

/**
 * @brief Get minimum stress level value
 * @chinese 获取最小压力值
 *
 * @discussion
 * [EN]: Convenience value derived from minStressItem.stressValue.
 *       Returns 0 if minStressItem is nil.
 * [CN]: 由 minStressItem.stressValue 推导的便捷数值。
 *       当 minStressItem 为空时返回 0。
 *
 * @return
 * EN: Minimum stress value (0–100 scale); 0 if `minStressItem` is nil.
 * CN: 最小压力值（0–100 量纲）；无条目时为 0。
 */
- (UInt8)minStress;

/**
 * @brief Get all measured items (manual + auto)
 * @chinese 获取所有测量条目（主动 + 自动）
 *
 * @discussion
 * [EN]: Returns a combined array of manual and auto items, sorted by time.
 * [CN]: 返回合并后的主动和自动测量条目，按时间排序。
 *
 * @return
 * EN: Merged list of `manualItems` and `autoItems`, ordered by timestamp.
 * CN: 合并后的测量点列表，按时间排序。
 */
- (NSArray<TSStressValueItem *> *)allMeasuredItems;

/**
 * @brief Build daily stress models from flat DB/API rows
 * @chinese 由压力表多行字典按日分组并组装为每日模型数组
 *
 * @param dicts
 * EN: Row dictionaries (e.g. stress detail table); grouped by `dayStartTime` field.
 * CN: 表行字典数组（如压力明细表）；按 `dayStartTime` 分组到各自然统计日。
 *
 * @return
 * EN: Array of `TSStressDailyModel` sorted by day key; empty array if `dicts` is nil or empty.
 * CN: 按日键排序的模型数组；入参为空时返回空数组。
 */
+ (NSArray<TSStressDailyModel *> *)dailyModelsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Multi-line debug summary for logging
 * @chinese 多行调试输出
 *
 * @return
 * EN: Human-readable description of daily buckets and key metrics.
 * CN: 便于日志阅读的当日压力汇总描述。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
