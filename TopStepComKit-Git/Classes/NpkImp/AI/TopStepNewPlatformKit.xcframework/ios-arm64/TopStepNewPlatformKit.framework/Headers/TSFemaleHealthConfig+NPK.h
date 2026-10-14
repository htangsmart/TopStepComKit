//
//  TSFemaleHealthConfig+NPK.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/11/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbConfigParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSFemaleHealthConfig (NPK)

/**
 * @brief Convert TSFemaleHealthConfig to TSMetaFemaleHealthConfig
 * @chinese 将TSFemaleHealthConfig转换为TSMetaFemaleHealthConfig
 *
 * @param femaleHealthConfig
 * EN: TSFemaleHealthConfig object to be converted
 * CN: 需要转换的TSFemaleHealthConfig对象
 *
 * @return
 * EN: Converted TSMetaFemaleHealthConfig object, nil if conversion fails
 * CN: 转换后的TSMetaFemaleHealthConfig对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: Converts TSFemaleHealthConfig to TSMetaFemaleHealthConfig for device communication.
 *       Mapping rules:
 *       - healthMode -> mode
 *       - reminderTimeMinutes -> remindTime
 *       - reminderAdvanceDays -> remindAdvance
 *       - pregnancyReminderType -> remindType
 *       - menstrualCycleLength -> cycle
 *       - menstrualPeriodDuration -> duration
 *       - lastPeriodStartTimestamp (Unix timestamp) -> latest (seconds since 2000-01-01)
 *       - menstruationEndDayInCycle -> menstruationEnd
 *       - reminderSwitches -> remindFlags
 * [CN]: 将TSFemaleHealthConfig转换为TSMetaFemaleHealthConfig用于设备通信。
 *       映射规则：
 *       - healthMode -> mode
 *       - reminderTimeMinutes -> remindTime
 *       - reminderAdvanceDays -> remindAdvance
 *       - pregnancyReminderType -> remindType
 *       - menstrualCycleLength -> cycle
 *       - menstrualPeriodDuration -> duration
 *       - lastPeriodStartTimestamp (Unix时间戳) -> latest (距离2000年1月1日的秒数)
 *       - menstruationEndDayInCycle -> menstruationEnd
 *       - reminderSwitches -> remindFlags
 */
+ (nullable TSMetaFemaleHealthConfig *)metaFemaleHealthConfigWithFemaleHealthConfig:(nullable TSFemaleHealthConfig *)femaleHealthConfig;

/**
 * @brief Convert TSMetaFemaleHealthConfig to TSFemaleHealthConfig
 * @chinese 将TSMetaFemaleHealthConfig转换为TSFemaleHealthConfig
 *
 * @param metaFemaleHealthConfig
 * EN: TSMetaFemaleHealthConfig object to be converted
 * CN: 需要转换的TSMetaFemaleHealthConfig对象
 *
 * @return
 * EN: Converted TSFemaleHealthConfig object, nil if conversion fails
 * CN: 转换后的TSFemaleHealthConfig对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: Converts TSMetaFemaleHealthConfig to TSFemaleHealthConfig from device response.
 *       Mapping rules:
 *       - mode -> healthMode
 *       - remindTime -> reminderTimeMinutes
 *       - remindAdvance -> reminderAdvanceDays
 *       - remindType -> pregnancyReminderType
 *       - cycle -> menstrualCycleLength
 *       - duration -> menstrualPeriodDuration
 *       - latest (seconds since 2000-01-01) -> lastPeriodStartTimestamp (Unix timestamp)
 *       - menstruationEnd -> menstruationEndDayInCycle
 *       - remindFlags -> reminderSwitches
 * [CN]: 将TSMetaFemaleHealthConfig转换为TSFemaleHealthConfig用于处理设备响应。
 *       映射规则：
 *       - mode -> healthMode
 *       - remindTime -> reminderTimeMinutes
 *       - remindAdvance -> reminderAdvanceDays
 *       - remindType -> pregnancyReminderType
 *       - cycle -> menstrualCycleLength
 *       - duration -> menstrualPeriodDuration
 *       - latest (距离2000年1月1日的秒数) -> lastPeriodStartTimestamp (Unix时间戳)
 *       - menstruationEnd -> menstruationEndDayInCycle
 *       - remindFlags -> reminderSwitches
 */
+ (nullable TSFemaleHealthConfig *)femaleHealthConfigWithMetaFemaleHealthConfig:(nullable TSMetaFemaleHealthConfig *)metaFemaleHealthConfig;

@end

NS_ASSUME_NONNULL_END
