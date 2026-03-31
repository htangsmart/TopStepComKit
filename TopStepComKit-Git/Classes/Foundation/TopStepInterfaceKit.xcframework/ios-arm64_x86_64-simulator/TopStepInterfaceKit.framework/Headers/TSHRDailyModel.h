//
//  TSHRDailyModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSHealthDailyModel.h"
#import "TSHRValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Per-day heart rate aggregation model
 * @chinese 按日聚合的心率数据模型
 *
 * @discussion
 * [EN]: Holds max/min items, resting series, manual/auto monitoring samples; `valueType` on each
 * `TSHRValueItem` distinguishes normal vs max/min/resting rows from storage.
 *
 * [CN]: 包含当日最大/最小条目、静息序列及主动/自动监测点；各 `TSHRValueItem` 的 `valueType` 区分库表中的普通/最大/最小/静息记录。
 */
@interface TSHRDailyModel : TSHealthDailyModel

/**
 * @brief Maximum heart rate item of the day
 * @chinese 当天最大心率条目
 *
 * @discussion
 * [EN]: The TSHRValueItem representing the highest heart rate measurement for the day.
 *       Only records explicitly marked as max should populate this field.
 * [CN]: 表示当天记录到的最高心率测量条目。
 *       仅应由标记为“最大值”的记录填充该字段。
 */
@property (nonatomic, strong, nullable) TSHRValueItem *maxHRItem;

/**
 * @brief Minimum heart rate item of the day
 * @chinese 当天最小心率条目
 *
 * @discussion
 * [EN]: The TSHRValueItem representing the lowest heart rate measurement for the day.
 *       Only records explicitly marked as min should populate this field.
 * [CN]: 表示当天记录到的最低心率测量条目。
 *       仅应由标记为“最小值”的记录填充该字段。
 */
@property (nonatomic, strong, nullable) TSHRValueItem *minHRItem;

/**
 * @brief Resting heart rate items
 * @chinese 静息心率条目数组
 *
 * @discussion
 * [EN]: Array of resting heart rate items for this day, ordered by time ascending.
 *       Resting entries are those explicitly marked as resting-type.
 * [CN]: 当天的静息心率条目数组，按时间升序排列。
 *       静息条目为显式标记为静息类型的记录。
 */
@property (nonatomic, copy) NSArray<TSHRValueItem *> *restingItems;

/**
 * @brief Manual measurement heart rate items
 * @chinese 主动测量心率条目数组
 *
 * @discussion
 * [EN]: Array of user-initiated heart rate measurements, ordered by time ascending.
 * [CN]: 用户主动测量的心率数组，按时间升序排列。
 */
@property (nonatomic, copy) NSArray<TSHRValueItem *> *manualItems;

/**
 * @brief Automatic monitoring heart rate items
 * @chinese 自动监测心率条目数组
 *
 * @discussion
 * [EN]: Array of automatically monitored heart rate items, ordered by time ascending.
 * [CN]: 设备自动监测的心率数组，按时间升序排列。
 */
@property (nonatomic, copy) NSArray<TSHRValueItem *> *autoItems;

/**
 * @brief Get maximum heart rate (BPM)
 * @chinese 获取最大心率（BPM）
 *
 * @discussion
 * [EN]: Convenience value derived from maxHRItem.hrValue.
 *       Returns 0 if maxHRItem is nil.
 * [CN]: 由 maxHRItem.hrValue 推导的便捷数值。
 *       当 maxHRItem 为空时返回 0。
 *
 * @return
 * EN: Maximum BPM; 0 if `maxHRItem` is nil.
 * CN: 最大心率（BPM）；无条目时为 0。
 */
- (UInt8)maxBPM;

/**
 * @brief Get minimum heart rate (BPM)
 * @chinese 获取最小心率（BPM）
 *
 * @discussion
 * [EN]: Convenience value derived from minHRItem.hrValue.
 *       Returns 0 if minHRItem is nil.
 * [CN]: 由 minHRItem.hrValue 推导的便捷数值。
 *       当 minHRItem 为空时返回 0。
 *
 * @return
 * EN: Minimum BPM; 0 if `minHRItem` is nil.
 * CN: 最小心率（BPM）；无条目时为 0。
 */
- (UInt8)minBPM;

/**
 * @brief Get all measured items (manual + auto)
 * @chinese 获取所有测量条目（主动 + 自动）
 *
 * @discussion
 * [EN]: Returns a combined array of manual and auto items, sorted by time.
 * [CN]: 返回合并后的主动和自动测量条目，按时间排序。
 *
 * @return
 * EN: Combined manual and auto samples sorted by time.
 * CN: 合并后的测量点，按时间排序。
 */
- (NSArray<TSHRValueItem *> *)allMeasuredItems;

/**
 * @brief Build daily HR models from flat DB/API rows
 * @chinese 由心率表多行字典按日分组并组装为每日模型数组
 *
 * @param dicts
 * EN: Row dictionaries grouped internally by `dayStartTime`.
 * CN: 表行字典；实现内按 `dayStartTime` 归入各统计日。
 *
 * @return
 * EN: Sorted `TSHRDailyModel` array; empty if input is nil or empty.
 * CN: 按日排序的模型数组；入参为空时返回空数组。
 */
+ (NSArray<TSHRDailyModel *> *)dailyModelsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Multi-line debug summary
 * @chinese 多行调试输出
 *
 * @return
 * EN: Readable dump of buckets, resting/manual/auto counts, and extrema.
 * CN: 含分桶、静息/主动/自动条数与极值的可读字符串。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
