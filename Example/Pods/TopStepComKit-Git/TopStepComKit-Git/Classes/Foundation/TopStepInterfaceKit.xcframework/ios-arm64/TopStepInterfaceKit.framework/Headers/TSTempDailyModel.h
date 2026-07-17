//
//  TSTempDailyModel.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSHealthDailyModel.h"
#import "TSTempValueItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSTempDailyModel : TSHealthDailyModel

/**
 * @brief Maximum body temperature item of the day
 * @chinese 当天最大体温条目
 *
 * @discussion
 * [EN]: The TSTempValueItem representing the highest body temperature measurement for the day.
 *       The maximum is determined by temperature value where temperatureType is TSTemperatureTypeBody.
 * [CN]: 表示当天记录到的最高体温测量条目。
 *       最大值基于 temperature（当 temperatureType 为 TSTemperatureTypeBody 时）确定。
 */
@property (nonatomic, strong, nullable) TSTempValueItem *maxBodyTempItem;

/**
 * @brief Minimum body temperature item of the day
 * @chinese 当天最小体温条目
 *
 * @discussion
 * [EN]: The TSTempValueItem representing the lowest body temperature measurement for the day.
 *       The minimum is determined by temperature value where temperatureType is TSTemperatureTypeBody.
 * [CN]: 表示当天记录到的最低体温测量条目。
 *       最小值基于 temperature（当 temperatureType 为 TSTemperatureTypeBody 时）确定。
 */
@property (nonatomic, strong, nullable) TSTempValueItem *minBodyTempItem;

/**
 * @brief Maximum wrist temperature item of the day
 * @chinese 当天最大腕温条目
 *
 * @discussion
 * [EN]: The TSTempValueItem representing the highest wrist temperature measurement for the day.
 *       The maximum is determined by temperature value where temperatureType is TSTemperatureTypeWrist.
 * [CN]: 表示当天记录到的最高腕温测量条目。
 *       最大值基于 temperature（当 temperatureType 为 TSTemperatureTypeWrist 时）确定。
 */
@property (nonatomic, strong, nullable) TSTempValueItem *maxWristTempItem;

/**
 * @brief Minimum wrist temperature item of the day
 * @chinese 当天最小腕温条目
 *
 * @discussion
 * [EN]: The TSTempValueItem representing the lowest wrist temperature measurement for the day.
 *       The minimum is determined by temperature value where temperatureType is TSTemperatureTypeWrist.
 * [CN]: 表示当天记录到的最低腕温测量条目。
 *       最小值基于 temperature（当 temperatureType 为 TSTemperatureTypeWrist 时）确定。
 */
@property (nonatomic, strong, nullable) TSTempValueItem *minWristTempItem;

/**
 * @brief Manual measurement temperature items
 * @chinese 主动测量体温条目数组
 *
 * @discussion
 * [EN]: Array of user-initiated temperature measurements, ordered by time ascending.
 * [CN]: 用户主动测量的体温数组，按时间升序排列。
 */
@property (nonatomic, strong) NSArray<TSTempValueItem *> *manualItems;

/**
 * @brief Automatic monitoring temperature items
 * @chinese 自动监测体温条目数组
 *
 * @discussion
 * [EN]: Array of automatically monitored temperature items, ordered by time ascending.
 * [CN]: 设备自动监测的体温数组，按时间升序排列。
 */
@property (nonatomic, strong) NSArray<TSTempValueItem *> *autoItems;

/**
 * @brief Get maximum body temperature (°C)
 * @chinese 获取最大核心体温（摄氏度）
 *
 * @discussion
 * [EN]: Convenience value derived from maxBodyTempItem.temperature.
 *       Returns 0 if maxBodyTempItem is nil.
 * [CN]: 由 maxBodyTempItem.temperature 推导的便捷数值。
 *       当 maxBodyTempItem 为空时返回 0。
 */
- (CGFloat)maxBodyTemperature;

/**
 * @brief Get minimum body temperature (°C)
 * @chinese 获取最小核心体温（摄氏度）
 *
 * @discussion
 * [EN]: Convenience value derived from minBodyTempItem.temperature.
 *       Returns 0 if minBodyTempItem is nil.
 * [CN]: 由 minBodyTempItem.temperature 推导的便捷数值。
 *       当 minBodyTempItem 为空时返回 0。
 */
- (CGFloat)minBodyTemperature;

/**
 * @brief Get maximum wrist temperature (°C)
 * @chinese 获取最大腕温（摄氏度）
 *
 * @discussion
 * [EN]: Convenience value derived from maxWristTempItem.temperature.
 *       Returns 0 if maxWristTempItem is nil.
 * [CN]: 由 maxWristTempItem.temperature 推导的便捷数值。
 *       当 maxWristTempItem 为空时返回 0。
 */
- (CGFloat)maxWristTemperature;

/**
 * @brief Get minimum wrist temperature (°C)
 * @chinese 获取最小腕温（摄氏度）
 *
 * @discussion
 * [EN]: Convenience value derived from minWristTempItem.temperature.
 *       Returns 0 if minWristTempItem is nil.
 * [CN]: 由 minWristTempItem.temperature 推导的便捷数值。
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

- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
