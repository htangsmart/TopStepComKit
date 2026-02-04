//
//  TSHRDailyModel.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSHealthDailyModel.h"
#import "TSHRValueItem.h"

NS_ASSUME_NONNULL_BEGIN

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
@property (nonatomic, strong) NSArray<TSHRValueItem *> *restingItems;

/**
 * @brief Manual measurement heart rate items
 * @chinese 主动测量心率条目数组
 *
 * @discussion
 * [EN]: Array of user-initiated heart rate measurements, ordered by time ascending.
 * [CN]: 用户主动测量的心率数组，按时间升序排列。
 */
@property (nonatomic, strong) NSArray<TSHRValueItem *> *manualItems;

/**
 * @brief Automatic monitoring heart rate items
 * @chinese 自动监测心率条目数组
 *
 * @discussion
 * [EN]: Array of automatically monitored heart rate items, ordered by time ascending.
 * [CN]: 设备自动监测的心率数组，按时间升序排列。
 */
@property (nonatomic, strong) NSArray<TSHRValueItem *> *autoItems;

/**
 * @brief Get maximum heart rate (BPM)
 * @chinese 获取最大心率（BPM）
 *
 * @discussion
 * [EN]: Convenience value derived from maxHRItem.hrValue.
 *       Returns 0 if maxHRItem is nil.
 * [CN]: 由 maxHRItem.hrValue 推导的便捷数值。
 *       当 maxHRItem 为空时返回 0。
 */
- (UInt16)maxBPM;

/**
 * @brief Get minimum heart rate (BPM)
 * @chinese 获取最小心率（BPM）
 *
 * @discussion
 * [EN]: Convenience value derived from minHRItem.hrValue.
 *       Returns 0 if minHRItem is nil.
 * [CN]: 由 minHRItem.hrValue 推导的便捷数值。
 *       当 minHRItem 为空时返回 0。
 */
- (UInt16)minBPM;

/**
 * @brief Get all measured items (manual + auto)
 * @chinese 获取所有测量条目（主动 + 自动）
 *
 * @discussion
 * [EN]: Returns a combined array of manual and auto items, sorted by time.
 * [CN]: 返回合并后的主动和自动测量条目，按时间排序。
 */
- (NSArray<TSHRValueItem *> *)allMeasuredItems;

+ (NSArray<TSHRDailyModel *> *)dailyModelsFromDBDicts:(NSArray<NSDictionary *> *)dicts;


- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
