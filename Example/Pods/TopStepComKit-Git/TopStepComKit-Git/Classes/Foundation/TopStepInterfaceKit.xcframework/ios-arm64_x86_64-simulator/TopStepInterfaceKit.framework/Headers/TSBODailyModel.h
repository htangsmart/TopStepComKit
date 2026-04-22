//
//  TSBODailyModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSHealthDailyModel.h"
#import "TSBOValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Per-day blood oxygen aggregation
 * @chinese 按日聚合的血氧数据模型
 *
 * @discussion
 * [EN]: Combines min/max `TSBOValueItem` references with manual and automatic SpO2 time series for the day.
 *
 * [CN]: 包含当日最大/最小血氧条目及主动、自动测量序列。
 */
@interface TSBODailyModel : TSHealthDailyModel

/**
 * @brief Maximum blood oxygen item
 * @chinese 最大血氧条目
 *
 * @discussion
 * [EN]: The TSBOValueItem representing the maximum blood oxygen within the day.
 *       Includes value, timestamp, and whether it was user-initiated.
 * [CN]: 表示当天最大血氧的 TSBOValueItem，包含数值、时间戳及是否为主动测量等信息。
 */
@property (nonatomic, strong, nullable) TSBOValueItem *maxOxygenItem;

/**
 * @brief Minimum blood oxygen item
 * @chinese 最小血氧条目
 *
 * @discussion
 * [EN]: The TSBOValueItem representing the minimum blood oxygen within the day.
 *       Includes value, timestamp, and whether it was user-initiated.
 * [CN]: 表示当天最小血氧的 TSBOValueItem，包含数值、时间戳及是否为主动测量等信息。
 */
@property (nonatomic, strong, nullable) TSBOValueItem *minOxygenItem;

/**
 * @brief Manual measurement blood oxygen items
 * @chinese 主动测量血氧条目数组
 *
 * @discussion
 * [EN]: Array of user-initiated blood oxygen measurements, ordered by time ascending.
 * [CN]: 用户主动测量的血氧数组，按时间升序排列。
 */
@property (nonatomic, strong) NSArray<TSBOValueItem *> *manualItems;

/**
 * @brief Automatic monitoring blood oxygen items
 * @chinese 自动监测血氧条目数组
 *
 * @discussion
 * [EN]: Array of automatically monitored blood oxygen items, ordered by time ascending.
 * [CN]: 设备自动监测的血氧数组，按时间升序排列。
 */
@property (nonatomic, strong) NSArray<TSBOValueItem *> *autoItems;

/**
 * @brief Get maximum blood oxygen value (%)
 * @chinese 获取最大血氧值（%）
 *
 * @discussion
 * [EN]: Convenience value derived from maxOxygenItem.oxyValue.
 *       Returns 0 if maxOxygenItem is nil.
 * [CN]: 由 maxOxygenItem.oxyValue 推导的便捷数值。
 *       当 maxOxygenItem 为空时返回 0。
 *
 * @return
 * EN: Maximum SpO2 percentage; 0 if `maxOxygenItem` is nil.
 * CN: 最大血氧百分比；无条目时为 0。
 */
- (UInt8)maxOxygenValue;

/**
 * @brief Get minimum blood oxygen value (%)
 * @chinese 获取最小血氧值（%）
 *
 * @discussion
 * [EN]: Convenience value derived from minOxygenItem.oxyValue.
 *       Returns 0 if minOxygenItem is nil.
 * [CN]: 由 minOxygenItem.oxyValue 推导的便捷数值。
 *       当 minOxygenItem 为空时返回 0。
 *
 * @return
 * EN: Minimum SpO2 percentage; 0 if `minOxygenItem` is nil.
 * CN: 最小血氧百分比；无条目时为 0。
 */
- (UInt8)minOxygenValue;

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
 * CN: 合并后的血氧测量点，按时间排序。
 */
- (NSArray<TSBOValueItem *> *)allMeasuredItems;

/**
 * @brief Build daily SpO2 models from flat DB rows
 * @chinese 由血氧表多行字典按日分组并组装为每日模型数组
 *
 * @param dicts
 * EN: Blood oxygen detail rows; grouped by `dayStartTime` in implementation.
 * CN: 血氧明细行；实现内按 `dayStartTime` 分组。
 *
 * @return
 * EN: Sorted `TSBODailyModel` array; empty if input is nil or empty.
 * CN: 按日排序的模型数组；入参为空时返回空数组。
 */
+ (NSArray<TSBODailyModel *> *)dailyModelsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Multi-line debug summary
 * @chinese 多行调试输出
 *
 * @return
 * EN: Min/max values and list sizes for the day.
 * CN: 当日极值与各列表规模等。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
