//
//  TSTempDailyModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSHealthDailyModel.h"
#import "TSTempValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Daily aggregation of paired body and wrist temperature samples
 * @chinese 成对体温与腕温采样的每日聚合模型
 */
@interface TSTempDailyModel : TSHealthDailyModel

/**
 * @brief Maximum body temperature item of the day
 * @chinese 当天最大体温条目
 *
 * @discussion
 * [EN]: The TSTempValueItem representing the highest body temperature measurement for the day.
 *       The maximum is determined independently from positive bodyTemperature values.
 * [CN]: 表示当天记录到的最高体温测量条目。
 *       最大值独立基于大于 0 的 bodyTemperature 确定。
 */
@property (nonatomic, strong, nullable) TSTempValueItem *maxBodyTempItem;

/**
 * @brief Minimum body temperature item of the day
 * @chinese 当天最小体温条目
 *
 * @discussion
 * [EN]: The TSTempValueItem representing the lowest body temperature measurement for the day.
 *       The minimum is determined independently from positive bodyTemperature values.
 * [CN]: 表示当天记录到的最低体温测量条目。
 *       最小值独立基于大于 0 的 bodyTemperature 确定。
 */
@property (nonatomic, strong, nullable) TSTempValueItem *minBodyTempItem;

/**
 * @brief Maximum wrist temperature item of the day
 * @chinese 当天最大腕温条目
 *
 * @discussion
 * [EN]: The TSTempValueItem representing the highest wrist temperature measurement for the day.
 *       The maximum is determined independently from positive wristTemperature values.
 * [CN]: 表示当天记录到的最高腕温测量条目。
 *       最大值独立基于大于 0 的 wristTemperature 确定。
 */
@property (nonatomic, strong, nullable) TSTempValueItem *maxWristTempItem;

/**
 * @brief Minimum wrist temperature item of the day
 * @chinese 当天最小腕温条目
 *
 * @discussion
 * [EN]: The TSTempValueItem representing the lowest wrist temperature measurement for the day.
 *       The minimum is determined independently from positive wristTemperature values.
 * [CN]: 表示当天记录到的最低腕温测量条目。
 *       最小值独立基于大于 0 的 wristTemperature 确定。
 */
@property (nonatomic, strong, nullable) TSTempValueItem *minWristTempItem;

/**
 * @brief Manual measurement temperature items
 * @chinese 主动测量体温条目数组
 *
 * @discussion
 * [EN]: User-initiated sampling events ordered by time. A paired sample appears only once.
 * [CN]: 按时间升序排列的用户主动采样事件，每个成对采样只出现一次。
 */
@property (nonatomic, copy) NSArray<TSTempValueItem *> *manualItems;

/**
 * @brief Automatic monitoring temperature items
 * @chinese 自动监测体温条目数组
 *
 * @discussion
 * [EN]: Automatically monitored sampling events ordered by time. A paired sample appears only once.
 * [CN]: 按时间升序排列的设备自动采样事件，每个成对采样只出现一次。
 */
@property (nonatomic, copy) NSArray<TSTempValueItem *> *autoItems;

/**
 * @brief Get maximum body temperature (°C)
 * @chinese 获取最大核心体温（摄氏度）
 *
 * @discussion
 * [EN]: Convenience value derived from maxBodyTempItem.bodyTemperature.
 *       Returns 0 if maxBodyTempItem is nil.
 * [CN]: 由 maxBodyTempItem.bodyTemperature 推导的便捷数值。
 *       当 maxBodyTempItem 为空时返回 0。
 */
- (CGFloat)maxBodyTemperature;

/**
 * @brief Get minimum body temperature (°C)
 * @chinese 获取最小核心体温（摄氏度）
 *
 * @discussion
 * [EN]: Convenience value derived from minBodyTempItem.bodyTemperature.
 *       Returns 0 if minBodyTempItem is nil.
 * [CN]: 由 minBodyTempItem.bodyTemperature 推导的便捷数值。
 *       当 minBodyTempItem 为空时返回 0。
 */
- (CGFloat)minBodyTemperature;

/**
 * @brief Get maximum wrist temperature (°C)
 * @chinese 获取最大腕温（摄氏度）
 *
 * @discussion
 * [EN]: Convenience value derived from maxWristTempItem.wristTemperature.
 *       Returns 0 if maxWristTempItem is nil.
 * [CN]: 由 maxWristTempItem.wristTemperature 推导的便捷数值。
 *       当 maxWristTempItem 为空时返回 0。
 */
- (CGFloat)maxWristTemperature;

/**
 * @brief Get minimum wrist temperature (°C)
 * @chinese 获取最小腕温（摄氏度）
 *
 * @discussion
 * [EN]: Convenience value derived from minWristTempItem.wristTemperature.
 *       Returns 0 if minWristTempItem is nil.
 * [CN]: 由 minWristTempItem.wristTemperature 推导的便捷数值。
 *       当 minWristTempItem 为空时返回 0。
 */
- (CGFloat)minWristTemperature;

/**
 * @brief Get all measured items (manual + auto)
 * @chinese 获取所有测量条目（主动 + 自动）
 *
 * @discussion
 * [EN]: Returns a combined array of manual and auto items, sorted by time.
 * [CN]: 返回合并后的主动和自动测量条目，按时间排序。
 */
- (NSArray<TSTempValueItem *> *)allMeasuredItems;

/**
 * @brief Build daily temperature models from database rows
 * @chinese 由数据库明细记录构建每日体温聚合模型
 *
 * @param dicts
 * EN: Temperature rows containing day boundaries, sample metadata, and paired values.
 * CN: 包含日边界、采样元数据和成对温度值的数据库记录。
 *
 * @return
 * EN: Daily models sorted by day. Invalid rows and non-normal samples are omitted.
 * CN: 按日期升序返回每日模型，无效记录和非普通采样会被忽略。
 */
+ (NSArray<TSTempDailyModel *> *)dailyModelsFromDBDicts:(nullable NSArray<NSDictionary *> *)dicts;

/**
 * @brief Debug description of the daily aggregation
 * @chinese 每日体温聚合模型的调试描述
 *
 * @return
 * EN: A formatted description containing extrema and sample counts.
 * CN: 包含极值及采样数量的格式化描述。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
