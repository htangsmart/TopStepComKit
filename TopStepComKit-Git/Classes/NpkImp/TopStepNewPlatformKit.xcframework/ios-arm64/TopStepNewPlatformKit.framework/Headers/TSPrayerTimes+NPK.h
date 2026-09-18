//
//  TSPrayerTimes+NPK.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/11/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbSettingParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPrayerTimes (NPK)

/**
 * @brief Convert TSPrayerTimes array to TSMetaPrayerDayList
 * @chinese 将TSPrayerTimes数组转换为TSMetaPrayerDayList
 *
 * @param prayerTimesArray
 * EN: Array of TSPrayerTimes objects to be converted (maximum 7 days)
 * CN: 需要转换的TSPrayerTimes对象数组（最多7天）
 *
 * @return
 * EN: Converted TSMetaPrayerDayList object, nil if conversion fails
 * CN: 转换后的TSMetaPrayerDayList对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: Converts an array of TSPrayerTimes to TSMetaPrayerDayList for device communication.
 *       Each TSPrayerTimes represents prayer times for one day.
 *       Mapping rules:
 *       - dayTimestamp (Unix timestamp) -> timestamp (seconds since 2000-01-01)
 *       - fajrMinutesOffset -> itemsArray[0]
 *       - sunriseMinutesOffset -> itemsArray[1]
 *       - dhuhrMinutesOffset -> itemsArray[2]
 *       - asrMinutesOffset -> itemsArray[3]
 *       - sunsetMinutesOffset -> itemsArray[4]
 *       - maghribMinutesOffset -> itemsArray[5]
 *       - ishaMinutesOffset -> itemsArray[6]
 *       Maximum 7 days can be converted. If array contains more than 7 elements, only first 7 will be used.
 * [CN]: 将TSPrayerTimes数组转换为TSMetaPrayerDayList用于设备通信。
 *       每个TSPrayerTimes代表一天的祈祷时间。
 *       映射规则：
 *       - dayTimestamp (Unix时间戳) -> timestamp (距离2000年1月1日的秒数)
 *       - fajrMinutesOffset -> itemsArray[0]
 *       - sunriseMinutesOffset -> itemsArray[1]
 *       - dhuhrMinutesOffset -> itemsArray[2]
 *       - asrMinutesOffset -> itemsArray[3]
 *       - sunsetMinutesOffset -> itemsArray[4]
 *       - maghribMinutesOffset -> itemsArray[5]
 *       - ishaMinutesOffset -> itemsArray[6]
 *       最多可以转换7天。如果数组包含超过7个元素，仅使用前7个。
 */
+ (nullable TSMetaPrayerDayList *)metaPrayerDayListWithPrayerTimesArray:(nullable NSArray<TSPrayerTimes *> *)prayerTimesArray;

@end

NS_ASSUME_NONNULL_END
