//
//  TSBPDailyModel.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSHealthDailyModel.h"
#import "TSBPValueItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSBPDailyModel : TSHealthDailyModel

/**
 * @brief Maximum systolic blood pressure item of the day
 * @chinese 当天最大收缩压条目
 *
 * @discussion
 * [EN]: The item representing the highest systolic blood pressure measurement within the day.
 * [CN]: 表示当天记录到的最高收缩压（高压）测量条目。
 */
@property (nonatomic, strong, nullable) TSBPValueItem *maxSystolicItem;

/**
 * @brief Minimum systolic blood pressure item of the day
 * @chinese 当天最小收缩压条目
 *
 * @discussion
 * [EN]: The item representing the lowest systolic blood pressure measurement within the day.
 * [CN]: 表示当天记录到的最低收缩压（高压）测量条目。
 */
@property (nonatomic, strong, nullable) TSBPValueItem *minSystolicItem;

/**
 * @brief Maximum diastolic blood pressure item of the day
 * @chinese 当天最大舒张压条目
 *
 * @discussion
 * [EN]: The item representing the highest diastolic blood pressure measurement within the day.
 * [CN]: 表示当天记录到的最高舒张压（低压）测量条目。
 */
@property (nonatomic, strong, nullable) TSBPValueItem *maxDiastolicItem;

/**
 * @brief Minimum diastolic blood pressure item of the day
 * @chinese 当天最小舒张压条目
 *
 * @discussion
 * [EN]: The item representing the lowest diastolic blood pressure measurement within the day.
 * [CN]: 表示当天记录到的最低舒张压（低压）测量条目。
 */
@property (nonatomic, strong, nullable) TSBPValueItem *minDiastolicItem;

/**
 * @brief Manual measurement blood pressure items
 * @chinese 主动测量血压条目数组
 *
 * @discussion
 * [EN]: Array of user-initiated blood pressure measurements, ordered by time ascending.
 * [CN]: 用户主动测量的血压数组，按时间升序排列。
 */
@property (nonatomic, strong) NSArray<TSBPValueItem *> *manualItems;

/**
 * @brief Automatic monitoring blood pressure items
 * @chinese 自动监测血压条目数组
 *
 * @discussion
 * [EN]: Array of automatically monitored blood pressure items, ordered by time ascending.
 * [CN]: 设备自动监测的血压数组，按时间升序排列。
 */
@property (nonatomic, strong) NSArray<TSBPValueItem *> *autoItems;

/**
 * @brief Get maximum systolic blood pressure
 * @chinese 获取最大收缩压（高压）
 *
 * @discussion
 * [EN]: Convenience value derived from maxSystolicItem.systolic.
 *       Returns 0 if maxSystolicItem is nil.
 * [CN]: 由 maxSystolicItem.systolic 推导的便捷数值。
 *       当 maxSystolicItem 为空时返回 0。
 */
- (UInt8)maxSystolic;

/**
 * @brief Get minimum systolic blood pressure
 * @chinese 获取最小收缩压（高压）
 *
 * @discussion
 * [EN]: Convenience value derived from minSystolicItem.systolic.
 *       Returns 0 if minSystolicItem is nil.
 * [CN]: 由 minSystolicItem.systolic 推导的便捷数值。
 *       当 minSystolicItem 为空时返回 0。
 */
- (UInt8)minSystolic;

/**
 * @brief Get maximum diastolic blood pressure
 * @chinese 获取最大舒张压（低压）
 *
 * @discussion
 * [EN]: Convenience value derived from maxDiastolicItem.diastolic.
 *       Returns 0 if maxDiastolicItem is nil.
 * [CN]: 由 maxDiastolicItem.diastolic 推导的便捷数值。
 *       当 maxDiastolicItem 为空时返回 0。
 */
- (UInt8)maxDiastolic;

/**
 * @brief Get minimum diastolic blood pressure
 * @chinese 获取最小舒张压（低压）
 *
 * @discussion
 * [EN]: Convenience value derived from minDiastolicItem.diastolic.
 *       Returns 0 if minDiastolicItem is nil.
 * [CN]: 由 minDiastolicItem.diastolic 推导的便捷数值。
 *       当 minDiastolicItem 为空时返回 0。
 */
- (UInt8)minDiastolic;

/**
 * @brief Get all measured items (manual + auto)
 * @chinese 获取所有测量条目（主动 + 自动）
 *
 * @discussion
 * [EN]: Returns a combined array of manual and auto items, sorted by time.
 * [CN]: 返回合并后的主动和自动测量条目，按时间排序。
 */
- (NSArray<TSBPValueItem *> *)allMeasuredItems;



- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
