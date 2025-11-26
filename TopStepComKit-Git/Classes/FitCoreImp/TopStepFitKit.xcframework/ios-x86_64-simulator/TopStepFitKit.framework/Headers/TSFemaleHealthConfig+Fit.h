//
//  TSFemaleHealthConfig+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/11/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSFemaleHealthConfig (Fit)

/**
 * @brief Convert TSFemaleHealthConfig to FitCloudWomenHealthSetting
 * @chinese 将TSFemaleHealthConfig转换为FitCloudWomenHealthSetting
 *
 * @param femaleHealthConfig
 * EN: TSFemaleHealthConfig object to be converted
 * CN: 需要转换的TSFemaleHealthConfig对象
 *
 * @return
 * EN: Converted FitCloudWomenHealthSetting object, nil if conversion fails
 * CN: 转换后的FitCloudWomenHealthSetting对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: Converts TSFemaleHealthConfig to FitCloudWomenHealthSetting for Fit device communication.
 *       Mapping rules:
 *       - healthMode -> mode
 *       - reminderAdvanceDays -> advanceDaysToRemind
 *       - reminderTimeMinutes -> offsetMinutesInDayOfRemind
 *       - menstrualPeriodDuration -> mensesDuration
 *       - menstrualCycleLength -> menstrualCycle
 *       - lastPeriodStartTimestamp -> recentMenstruationBegin (converted to yyyy-MM-dd format)
 *       - menstruationEndDayInCycle -> daysOfFinishSinceMensesBegin
 *       - pregnancyReminderType -> pregancyRemindType
 * [CN]: 将TSFemaleHealthConfig转换为FitCloudWomenHealthSetting用于Fit设备通信。
 *       映射规则：
 *       - healthMode -> mode
 *       - reminderAdvanceDays -> advanceDaysToRemind
 *       - reminderTimeMinutes -> offsetMinutesInDayOfRemind
 *       - menstrualPeriodDuration -> mensesDuration
 *       - menstrualCycleLength -> menstrualCycle
 *       - lastPeriodStartTimestamp -> recentMenstruationBegin (转换为 yyyy-MM-dd 格式)
 *       - menstruationEndDayInCycle -> daysOfFinishSinceMensesBegin
 *       - pregnancyReminderType -> pregancyRemindType
 */
+ (nullable FitCloudWomenHealthSetting *)fitCloudWomenHealthSettingWithFemaleHealthConfig:(nullable TSFemaleHealthConfig *)femaleHealthConfig;

/**
 * @brief Convert FitCloudWomenHealthSetting to TSFemaleHealthConfig
 * @chinese 将FitCloudWomenHealthSetting转换为TSFemaleHealthConfig
 *
 * @param fitSetting
 * EN: FitCloudWomenHealthSetting object to be converted
 * CN: 需要转换的FitCloudWomenHealthSetting对象
 *
 * @return
 * EN: Converted TSFemaleHealthConfig object, nil if conversion fails
 * CN: 转换后的TSFemaleHealthConfig对象，转换失败时返回nil
 *
 * @discussion
 * [EN]: Converts FitCloudWomenHealthSetting to TSFemaleHealthConfig from Fit device response.
 *       Mapping rules:
 *       - mode -> healthMode
 *       - advanceDaysToRemind -> reminderAdvanceDays
 *       - offsetMinutesInDayOfRemind -> reminderTimeMinutes
 *       - mensesDuration -> menstrualPeriodDuration
 *       - menstrualCycle -> menstrualCycleLength
 *       - recentMenstruationBegin (yyyy-MM-dd format) -> lastPeriodStartTimestamp (converted to Unix timestamp)
 *       - daysOfFinishSinceMensesBegin -> menstruationEndDayInCycle
 *       - pregancyRemindType -> pregnancyReminderType
 * [CN]: 将FitCloudWomenHealthSetting转换为TSFemaleHealthConfig用于处理Fit设备响应。
 *       映射规则：
 *       - mode -> healthMode
 *       - advanceDaysToRemind -> reminderAdvanceDays
 *       - offsetMinutesInDayOfRemind -> reminderTimeMinutes
 *       - mensesDuration -> menstrualPeriodDuration
 *       - menstrualCycle -> menstrualCycleLength
 *       - recentMenstruationBegin (yyyy-MM-dd 格式) -> lastPeriodStartTimestamp (转换为Unix时间戳)
 *       - daysOfFinishSinceMensesBegin -> menstruationEndDayInCycle
 *       - pregancyRemindType -> pregnancyReminderType
 */
+ (nullable TSFemaleHealthConfig *)femaleHealthConfigWithFitCloudWomenHealthSetting:(nullable FitCloudWomenHealthSetting *)fitSetting;

@end

NS_ASSUME_NONNULL_END
