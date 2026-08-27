//
//  TSPrayerTimes+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/11/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPrayerTimes (Fit)

/**
 * @brief Convert TSPrayerTimes to OraimoMuslimPrayerAlarmClockModel
 * @chinese 将TSPrayerTimes转换为OraimoMuslimPrayerAlarmClockModel
 *
 * @param prayerTimes
 * EN: TSPrayerTimes object to be converted
 * CN: 需要转换的TSPrayerTimes对象
 *
 * @return
 * EN: Converted OraimoMuslimPrayerAlarmClockModel object, nil if conversion fails
 * CN: 转换后的OraimoMuslimPrayerAlarmClockModel对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: Converts TSPrayerTimes to OraimoMuslimPrayerAlarmClockModel for Fit device communication.
 *       Mapping rules:
 *       - fajrMinutesOffset -> minutesFromMidnightForFajr
 *       - dhuhrMinutesOffset -> minutesFromMidnightForDhuhr
 *       - asrMinutesOffset -> minutesFromMidnightForAsr
 *       - maghribMinutesOffset -> minutesFromMidnightForMaghrib
 *       - ishaMinutesOffset -> minutesFromMidnightForIsha
 *       Note: sunriseMinutesOffset and sunsetMinutesOffset are not supported by Fit devices and will be ignored.
 *       Note: dayTimestamp is not used in OraimoMuslimPrayerAlarmClockModel and will be ignored.
 * [CN]: 将TSPrayerTimes转换为OraimoMuslimPrayerAlarmClockModel用于Fit设备通信。
 *       映射规则：
 *       - fajrMinutesOffset -> minutesFromMidnightForFajr
 *       - dhuhrMinutesOffset -> minutesFromMidnightForDhuhr
 *       - asrMinutesOffset -> minutesFromMidnightForAsr
 *       - maghribMinutesOffset -> minutesFromMidnightForMaghrib
 *       - ishaMinutesOffset -> minutesFromMidnightForIsha
 *       注意：sunriseMinutesOffset 和 sunsetMinutesOffset 不被Fit设备支持，将被忽略。
 *       注意：dayTimestamp 在 OraimoMuslimPrayerAlarmClockModel 中不使用，将被忽略。
 */
+ (nullable OraimoMuslimPrayerAlarmClockModel *)oraimoMuslimPrayerAlarmClockModelWithPrayerTimes:(nullable TSPrayerTimes *)prayerTimes;

/**
 * @brief Convert TSPrayerTimes array to OraimoMuslimPrayerAlarmClockModel array
 * @chinese 将TSPrayerTimes数组转换为OraimoMuslimPrayerAlarmClockModel数组
 *
 * @param prayerTimesArray
 * EN: Array of TSPrayerTimes objects to be converted (maximum 7 days)
 * CN: 需要转换的TSPrayerTimes对象数组（最多7天）
 *
 * @return
 * EN: Converted OraimoMuslimPrayerAlarmClockModel array, empty array if conversion fails
 * CN: 转换后的OraimoMuslimPrayerAlarmClockModel数组，转换失败时返回空数组
 *
 * @discussion
 * [EN]: Converts an array of TSPrayerTimes to OraimoMuslimPrayerAlarmClockModel array for Fit device communication.
 *       Each TSPrayerTimes represents prayer times for one day.
 *       Maximum 7 days can be converted. If array contains more than 7 elements, only first 7 will be used.
 *       Mapping rules for each element:
 *       - fajrMinutesOffset -> minutesFromMidnightForFajr
 *       - dhuhrMinutesOffset -> minutesFromMidnightForDhuhr
 *       - asrMinutesOffset -> minutesFromMidnightForAsr
 *       - maghribMinutesOffset -> minutesFromMidnightForMaghrib
 *       - ishaMinutesOffset -> minutesFromMidnightForIsha
 *       Note: sunriseMinutesOffset and sunsetMinutesOffset are not supported by Fit devices and will be ignored.
 *       Note: dayTimestamp is not used in OraimoMuslimPrayerAlarmClockModel and will be ignored.
 * [CN]: 将TSPrayerTimes数组转换为OraimoMuslimPrayerAlarmClockModel数组用于Fit设备通信。
 *       每个TSPrayerTimes代表一天的祈祷时间。
 *       最多可以转换7天。如果数组包含超过7个元素，仅使用前7个。
 *       每个元素的映射规则：
 *       - fajrMinutesOffset -> minutesFromMidnightForFajr
 *       - dhuhrMinutesOffset -> minutesFromMidnightForDhuhr
 *       - asrMinutesOffset -> minutesFromMidnightForAsr
 *       - maghribMinutesOffset -> minutesFromMidnightForMaghrib
 *       - ishaMinutesOffset -> minutesFromMidnightForIsha
 *       注意：sunriseMinutesOffset 和 sunsetMinutesOffset 不被Fit设备支持，将被忽略。
 *       注意：dayTimestamp 在 OraimoMuslimPrayerAlarmClockModel 中不使用，将被忽略。
 */
+ (NSArray<OraimoMuslimPrayerAlarmClockModel *> *)oraimoMuslimPrayerAlarmClockModelArrayWithPrayerTimesArray:(nullable NSArray<TSPrayerTimes *> *)prayerTimesArray;

@end

NS_ASSUME_NONNULL_END
