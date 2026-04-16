//
//  TSBODailyModel.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSHealthDailyModel.h"
#import "TSBOValueItem.h"

NS_ASSUME_NONNULL_BEGIN

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
 */
- (UInt8)minOxygenValue;

/**
 * @brief Get all measured items (manual + auto)
 * @chinese 获取所有测量条目（主动 + 自动）
 *
 * @discussion
 * [EN]: Returns a combined array of manual and auto items, sorted by time.
 * [CN]: 返回合并后的主动和自动测量条目，按时间排序。
 */
- (NSArray<TSBOValueItem *> *)allMeasuredItems;

- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
