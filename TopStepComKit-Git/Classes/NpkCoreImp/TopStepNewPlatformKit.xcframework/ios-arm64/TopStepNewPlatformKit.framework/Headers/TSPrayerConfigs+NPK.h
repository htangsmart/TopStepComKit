//
//  TSPrayerConfigs+NPK.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/11/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbSettingParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPrayerConfigs (NPK)

/**
 * @brief Convert TSPrayerConfigs to TMetaPrayerConfig
 * @chinese 将TSPrayerConfigs转换为TMetaPrayerConfig
 *
 * @param prayerConfigs
 * EN: TSPrayerConfigs object to be converted
 * CN: 需要转换的TSPrayerConfigs对象
 *
 * @return
 * EN: Converted TMetaPrayerConfig object, nil if conversion fails
 * CN: 转换后的TMetaPrayerConfig对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: Converts TSPrayerConfigs to TMetaPrayerConfig for device communication.
 *       Mapping rules:
 *       - prayerEnable -> isEnabled
 *       - fajrReminderEnable -> itemsArray[0]
 *       - sunriseReminderEnable -> itemsArray[1]
 *       - dhuhrReminderEnable -> itemsArray[2]
 *       - asrReminderEnable -> itemsArray[3]
 *       - sunsetReminderEnable -> itemsArray[4]
 *       - maghribReminderEnable -> itemsArray[5]
 *       - ishabReminderEnable -> itemsArray[6]
 * [CN]: 将TSPrayerConfigs转换为TMetaPrayerConfig用于设备通信。
 *       映射规则：
 *       - prayerEnable -> isEnabled
 *       - fajrReminderEnable -> itemsArray[0]
 *       - sunriseReminderEnable -> itemsArray[1]
 *       - dhuhrReminderEnable -> itemsArray[2]
 *       - asrReminderEnable -> itemsArray[3]
 *       - sunsetReminderEnable -> itemsArray[4]
 *       - maghribReminderEnable -> itemsArray[5]
 *       - ishabReminderEnable -> itemsArray[6]
 */
+ (nullable TMetaPrayerConfig *)metaPrayerConfigWithPrayerConfigs:(nullable TSPrayerConfigs *)prayerConfigs;

/**
 * @brief Convert TMetaPrayerConfig to TSPrayerConfigs
 * @chinese 将TMetaPrayerConfig转换为TSPrayerConfigs
 *
 * @param metaPrayerConfig
 * EN: TMetaPrayerConfig object to be converted
 * CN: 需要转换的TMetaPrayerConfig对象
 *
 * @return
 * EN: Converted TSPrayerConfigs object, nil if conversion fails
 * CN: 转换后的TSPrayerConfigs对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: Converts TMetaPrayerConfig to TSPrayerConfigs from device response.
 *       Mapping rules:
 *       - isEnabled -> prayerEnable
 *       - itemsArray[0] -> fajrReminderEnable
 *       - itemsArray[1] -> sunriseReminderEnable
 *       - itemsArray[2] -> dhuhrReminderEnable
 *       - itemsArray[3] -> asrReminderEnable
 *       - itemsArray[4] -> sunsetReminderEnable
 *       - itemsArray[5] -> maghribReminderEnable
 *       - itemsArray[6] -> ishabReminderEnable
 * [CN]: 将TMetaPrayerConfig转换为TSPrayerConfigs用于处理设备响应。
 *       映射规则：
 *       - isEnabled -> prayerEnable
 *       - itemsArray[0] -> fajrReminderEnable
 *       - itemsArray[1] -> sunriseReminderEnable
 *       - itemsArray[2] -> dhuhrReminderEnable
 *       - itemsArray[3] -> asrReminderEnable
 *       - itemsArray[4] -> sunsetReminderEnable
 *       - itemsArray[5] -> maghribReminderEnable
 *       - itemsArray[6] -> ishabReminderEnable
 */
+ (nullable TSPrayerConfigs *)prayerConfigsWithMetaPrayerConfig:(nullable TMetaPrayerConfig *)metaPrayerConfig;

@end

NS_ASSUME_NONNULL_END
