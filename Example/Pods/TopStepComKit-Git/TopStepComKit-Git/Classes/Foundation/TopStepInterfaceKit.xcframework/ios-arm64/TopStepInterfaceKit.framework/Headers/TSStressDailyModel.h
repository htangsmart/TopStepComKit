//
//  TSStressDailyModel.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSHealthDailyModel.h"
#import "TSStressValueItem.h"

NS_ASSUME_NONNULL_BEGIN

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
@property (nonatomic, strong) NSArray<TSStressValueItem *> *manualItems;

/**
 * @brief Automatic monitoring stress items
 * @chinese 自动监测压力条目数组
 *
 * @discussion
 * [EN]: Array of automatically monitored stress items, ordered by time ascending.
 * [CN]: 设备自动监测的压力数组，按时间升序排列。
 */
@property (nonatomic, strong) NSArray<TSStressValueItem *> *autoItems;

/**
 * @brief Get maximum stress level value
 * @chinese 获取最大压力值
 *
 * @discussion
 * [EN]: Convenience value derived from maxStressItem.stressValue.
 *       Returns 0 if maxStressItem is nil.
 * [CN]: 由 maxStressItem.stressValue 推导的便捷数值。
 *       当 maxStressItem 为空时返回 0。
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
 */
- (UInt8)minStress;

/**
 * @brief Get all measured items (manual + auto)
 * @chinese 获取所有测量条目（主动 + 自动）
 *
 * @discussion
 * [EN]: Returns a combined array of manual and auto items, sorted by time.
 * [CN]: 返回合并后的主动和自动测量条目，按时间排序。
 */
- (NSArray<TSStressValueItem *> *)allMeasuredItems;

- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
