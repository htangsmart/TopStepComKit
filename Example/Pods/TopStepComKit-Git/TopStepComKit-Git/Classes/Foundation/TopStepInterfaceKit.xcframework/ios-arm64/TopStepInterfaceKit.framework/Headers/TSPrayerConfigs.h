//
//  TSPrayerConfigs.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/18.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Prayer configuration model
 * @chinese 祈祷配置模型
 *
 * @discussion
 * [EN]: This model represents prayer configuration settings including:
 *       - Overall prayer feature enable/disable status
 *       - Individual prayer time switches for 7 prayer-related times (Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha)
 *       Note: Sunrise and Sunset switches are optional and may not be supported by all projects.
 * [CN]: 该模型表示祈祷配置设置，包括：
 *       - 祈祷功能总开关
 *       - 7个祈祷相关时间的独立开关（晨礼、日出、晌礼、晡礼、日落、昏礼、宵礼）
 *       注意：日出和日落开关是可选的，某些项目可能不支持。
 */
@interface TSPrayerConfigs : TSKitBaseModel

/**
 * @brief Whether prayer feature is enabled
 * @chinese 是否启用祈祷功能
 *
 * @discussion
 * [EN]: Master switch for the prayer feature.
 *       When set to NO, all prayer times are disabled regardless of individual switches.
 *       When set to YES, individual prayer time switches (fajrEnabled, dhuhrEnabled, asrEnabled, maghribEnabled, ishaEnabled) take effect.
 * [CN]: 祈祷功能的总开关。
 *       当设置为NO时，所有祈祷时间都被禁用，无论单个开关如何设置。
 *       当设置为YES时，单个祈祷时间开关（fajrEnabled、dhuhrEnabled、asrEnabled、maghribEnabled、ishaEnabled）生效。
 *
 * @note
 * [EN]: This is the master control for the entire prayer feature.
 * [CN]: 这是整个祈祷功能的主控制开关。
 */
@property (nonatomic, assign) BOOL prayerEnable;

/**
 * @brief Enable/disable Fajr prayer reminder
 * @chinese 启用/禁用晨礼(Fajr)提醒
 *
 * @discussion
 * [EN]: Controls whether to receive reminders for Fajr prayer (dawn prayer).
 * [CN]: 控制是否接收晨礼(黎明祈祷)的提醒。
 *
 * @note
 * [EN]: This setting is only effective when prayEnable is set to YES.
 * [CN]: 此设置仅在prayEnable设置为YES时有效。
 */
@property (nonatomic,assign) BOOL fajrReminderEnable;

/**
 * @brief Enable/disable Sunrise reminder
 * @chinese 启用/禁用日出提醒
 *
 * @discussion
 * [EN]: Controls whether to receive reminders for sunrise time.
 * [CN]: 控制是否接收日出时间的提醒。
 *
 * @note
 * [EN]: This setting is only effective when prayEnable is set to YES.
 *       This property is optional and may not be supported by all projects.
 *       If the project does not support sunrise reminders, this setting will be ignored.
 * [CN]: 此设置仅在prayEnable设置为YES时有效。
 *       此属性是可选的，某些项目可能不支持。
 *       如果项目不支持日出提醒，此设置将被忽略。
 */
@property (nonatomic,assign) BOOL sunriseReminderEnable;

/**
 * @brief Enable/disable Dhuhr prayer reminder
 * @chinese 启用/禁用晌礼(Dhuhr)提醒
 *
 * @discussion
 * [EN]: Controls whether to receive reminders for Dhuhr prayer (noon prayer).
 * [CN]: 控制是否接收晌礼(正午祈祷)的提醒。
 *
 * @note
 * [EN]: This setting is only effective when prayEnable is set to YES.
 * [CN]: 此设置仅在prayEnable设置为YES时有效。
 */
@property (nonatomic,assign) BOOL dhuhrReminderEnable;

/**
 * @brief Enable/disable Asr prayer reminder
 * @chinese 启用/禁用晡礼(Asr)提醒
 *
 * @discussion
 * [EN]: Controls whether to receive reminders for Asr prayer (afternoon prayer).
 * [CN]: 控制是否接收晡礼(下午祈祷)的提醒。
 *
 * @note
 * [EN]: This setting is only effective when prayEnable is set to YES.
 * [CN]: 此设置仅在prayEnable设置为YES时有效。
 */
@property (nonatomic,assign) BOOL asrReminderEnable;

/**
 * @brief Enable/disable Sunset reminder
 * @chinese 启用/禁用日落提醒
 *
 * @discussion
 * [EN]: Controls whether to receive reminders for sunset time.
 * [CN]: 控制是否接收日落时间的提醒。
 *
 * @note
 * [EN]: This setting is only effective when prayEnable is set to YES.
 *       This property is optional and may not be supported by all projects.
 *       If the project does not support sunset reminders, this setting will be ignored.
 * [CN]: 此设置仅在prayEnable设置为YES时有效。
 *       此属性是可选的，某些项目可能不支持。
 *       如果项目不支持日落提醒，此设置将被忽略。
 */
@property (nonatomic,assign) BOOL sunsetReminderEnable;

/**
 * @brief Enable/disable Maghrib prayer reminder
 * @chinese 启用/禁用昏礼(Maghrib)提醒
 *
 * @discussion
 * [EN]: Controls whether to receive reminders for Maghrib prayer (sunset prayer).
 * [CN]: 控制是否接收昏礼(日落祈祷)的提醒。
 *
 * @note
 * [EN]: This setting is only effective when prayEnable is set to YES.
 * [CN]: 此设置仅在prayEnable设置为YES时有效。
 */
@property (nonatomic,assign) BOOL maghribReminderEnable;

/**
 * @brief Enable/disable Isha prayer reminder
 * @chinese 启用/禁用宵礼(Isha)提醒
 *
 * @discussion
 * [EN]: Controls whether to receive reminders for Isha prayer (night prayer).
 * [CN]: 控制是否接收宵礼(夜间祈祷)的提醒。
 *
 * @note
 * [EN]: This setting is only effective when prayEnable is set to YES.
 * [CN]: 此设置仅在prayEnable设置为YES时有效。
 */
@property (nonatomic,assign) BOOL ishabReminderEnable;


@end

NS_ASSUME_NONNULL_END
