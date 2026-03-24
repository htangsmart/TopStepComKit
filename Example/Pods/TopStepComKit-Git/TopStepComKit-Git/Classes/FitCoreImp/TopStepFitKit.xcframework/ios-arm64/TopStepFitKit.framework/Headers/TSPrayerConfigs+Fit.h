//
//  TSPrayerConfigs+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/11/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPrayerConfigs (Fit)

/**
 * @brief Convert TSPrayerConfigs to OraimoMuslimPrayerSwitchSettingsModel
 * @chinese 将TSPrayerConfigs转换为OraimoMuslimPrayerSwitchSettingsModel
 *
 * @param prayerConfigs
 * EN: TSPrayerConfigs object to be converted
 * CN: 需要转换的TSPrayerConfigs对象
 *
 * @return
 * EN: Converted OraimoMuslimPrayerSwitchSettingsModel object, nil if conversion fails
 * CN: 转换后的OraimoMuslimPrayerSwitchSettingsModel对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: Converts TSPrayerConfigs to OraimoMuslimPrayerSwitchSettingsModel for Fit device communication.
 *       Mapping rules:
 *       - prayerEnable -> mainSwitchEnabled
 *       - fajrReminderEnable -> fajrReminderEnabled
 *       - dhuhrReminderEnable -> dhuhrReminderEnabled
 *       - asrReminderEnable -> asrReminderEnabled
 *       - maghribReminderEnable -> maghribReminderEnabled
 *       - ishabReminderEnable -> ishaReminderEnabled
 *       Note: sunriseReminderEnable and sunsetReminderEnable are not supported by Fit devices and will be ignored.
 * [CN]: 将TSPrayerConfigs转换为OraimoMuslimPrayerSwitchSettingsModel用于Fit设备通信。
 *       映射规则：
 *       - prayerEnable -> mainSwitchEnabled
 *       - fajrReminderEnable -> fajrReminderEnabled
 *       - dhuhrReminderEnable -> dhuhrReminderEnabled
 *       - asrReminderEnable -> asrReminderEnabled
 *       - maghribReminderEnable -> maghribReminderEnabled
 *       - ishabReminderEnable -> ishaReminderEnabled
 *       注意：sunriseReminderEnable 和 sunsetReminderEnable 不被Fit设备支持，将被忽略。
 */
+ (nullable OraimoMuslimPrayerSwitchSettingsModel *)oraimoMuslimPrayerSwitchSettingsModelWithPrayerConfigs:(nullable TSPrayerConfigs *)prayerConfigs;

/**
 * @brief Convert OraimoMuslimPrayerSwitchSettingsModel to TSPrayerConfigs
 * @chinese 将OraimoMuslimPrayerSwitchSettingsModel转换为TSPrayerConfigs
 *
 * @param oraimoModel
 * EN: OraimoMuslimPrayerSwitchSettingsModel object to be converted
 * CN: 需要转换的OraimoMuslimPrayerSwitchSettingsModel对象
 *
 * @return
 * EN: Converted TSPrayerConfigs object, nil if conversion fails
 * CN: 转换后的TSPrayerConfigs对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: Converts OraimoMuslimPrayerSwitchSettingsModel to TSPrayerConfigs from Fit device response.
 *       Mapping rules:
 *       - mainSwitchEnabled -> prayerEnable
 *       - fajrReminderEnabled -> fajrReminderEnable
 *       - dhuhrReminderEnabled -> dhuhrReminderEnable
 *       - asrReminderEnabled -> asrReminderEnable
 *       - maghribReminderEnabled -> maghribReminderEnable
 *       - ishaReminderEnabled -> ishabReminderEnable
 *       Note: sunriseReminderEnable and sunsetReminderEnable will be set to NO (default) as Fit devices do not support them.
 * [CN]: 将OraimoMuslimPrayerSwitchSettingsModel转换为TSPrayerConfigs用于处理Fit设备响应。
 *       映射规则：
 *       - mainSwitchEnabled -> prayerEnable
 *       - fajrReminderEnabled -> fajrReminderEnable
 *       - dhuhrReminderEnabled -> dhuhrReminderEnable
 *       - asrReminderEnabled -> asrReminderEnable
 *       - maghribReminderEnabled -> maghribReminderEnable
 *       - ishaReminderEnabled -> ishabReminderEnable
 *       注意：sunriseReminderEnable 和 sunsetReminderEnable 将被设置为 NO（默认值），因为Fit设备不支持它们。
 */
+ (nullable TSPrayerConfigs *)prayerConfigsWithOraimoMuslimPrayerSwitchSettingsModel:(nullable OraimoMuslimPrayerSwitchSettingsModel *)oraimoModel;

@end

NS_ASSUME_NONNULL_END
