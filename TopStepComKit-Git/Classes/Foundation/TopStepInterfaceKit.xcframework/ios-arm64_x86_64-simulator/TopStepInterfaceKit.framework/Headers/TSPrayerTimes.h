//
//  TSPrayerTimes.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/18.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Prayer times model
 * @chinese 祈祷时间模型
 *
 * @discussion
 * [EN]: This model represents prayer times for a specific day, including:
 *       - Timestamp for the day (00:00:00 of the day)
 *       - Minute offsets from midnight for 7 prayer-related times (Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha)
 *       Note: Sunrise and Sunset offsets are optional and may not be supported by all projects.
 * [CN]: 该模型表示特定日期的祈祷时间，包括：
 *       - 日期的时间戳（当天的00:00:00）
 *       - 7个祈祷相关时间相对于午夜的分钟偏移量（晨礼、日出、晌礼、晡礼、日落、昏礼、宵礼）
 *       注意：日出和日落偏移量是可选的，某些项目可能不支持。
 */
@interface TSPrayerTimes : TSKitBaseModel

/**
 * @brief Timestamp for the day (00:00:00)
 * @chinese 当天0时0分0秒的时间戳
 *
 * @discussion
 * [EN]: Timestamp representing 00:00:00 of the day, used to determine the date for prayer times.
 *       This is the base timestamp from which all prayer time offsets are calculated.
 * [CN]: 表示当天00:00:00的时间戳，用于确定祈祷时间的日期。
 *       这是计算所有祈祷时间偏移量的基准时间戳。
 *
 * @note
 * [EN]: The timestamp is in seconds since 1970 (Unix timestamp).
 *       All prayer time minute offsets are calculated from this timestamp.
 * [CN]: 时间戳是自1970年以来的秒数（Unix时间戳）。
 *       所有祈祷时间的分钟偏移量都基于此时间戳计算。
 */
@property (nonatomic, assign) NSTimeInterval dayTimestamp;

/**
 * @brief Fajr prayer time offset in minutes from midnight
 * @chinese 晨礼(Fajr)时间相对于午夜的分钟偏移量
 *
 * @discussion
 * [EN]: Number of minutes from 00:00:00 of the day to Fajr prayer time.
 *       For example, if Fajr is at 5:30 AM, this value would be 330 (5 * 60 + 30).
 * [CN]: 从当天00:00:00到晨礼时间的分钟数。
 *       例如，如果晨礼在早上5:30，此值为330（5 * 60 + 30）。
 */
@property (nonatomic, assign) NSInteger fajrMinutesOffset;

/**
 * @brief Sunrise time offset in minutes from midnight
 * @chinese 日出时间相对于午夜的分钟偏移量
 *
 * @discussion
 * [EN]: Number of minutes from 00:00:00 of the day to sunrise time.
 *       For example, if sunrise is at 6:00 AM, this value would be 360 (6 * 60 + 0).
 * [CN]: 从当天00:00:00到日出时间的分钟数。
 *       例如，如果日出在早上6:00，此值为360（6 * 60 + 0）。
 *
 * @note
 * [EN]: This property is optional and may not be supported by all projects.
 *       If the project does not support sunrise time, this value will be ignored.
 * [CN]: 此属性是可选的，某些项目可能不支持。
 *       如果项目不支持日出时间，此值将被忽略。
 */
@property (nonatomic, assign) NSInteger sunriseMinutesOffset;

/**
 * @brief Dhuhr prayer time offset in minutes from midnight
 * @chinese 晌礼(Dhuhr)时间相对于午夜的分钟偏移量
 *
 * @discussion
 * [EN]: Number of minutes from 00:00:00 of the day to Dhuhr prayer time.
 *       For example, if Dhuhr is at 12:15 PM, this value would be 735 (12 * 60 + 15).
 * [CN]: 从当天00:00:00到晌礼时间的分钟数。
 *       例如，如果晌礼在中午12:15，此值为735（12 * 60 + 15）。
 */
@property (nonatomic, assign) NSInteger dhuhrMinutesOffset;

/**
 * @brief Asr prayer time offset in minutes from midnight
 * @chinese 晡礼(Asr)时间相对于午夜的分钟偏移量
 *
 * @discussion
 * [EN]: Number of minutes from 00:00:00 of the day to Asr prayer time.
 *       For example, if Asr is at 3:45 PM, this value would be 945 (15 * 60 + 45).
 * [CN]: 从当天00:00:00到晡礼时间的分钟数。
 *       例如，如果晡礼在下午3:45，此值为945（15 * 60 + 45）。
 */
@property (nonatomic, assign) NSInteger asrMinutesOffset;

/**
 * @brief Sunset time offset in minutes from midnight
 * @chinese 日落时间相对于午夜的分钟偏移量
 *
 * @discussion
 * [EN]: Number of minutes from 00:00:00 of the day to sunset time.
 *       For example, if sunset is at 6:30 PM, this value would be 1110 (18 * 60 + 30).
 * [CN]: 从当天00:00:00到日落时间的分钟数。
 *       例如，如果日落在晚上6:30，此值为1110（18 * 60 + 30）。
 *
 * @note
 * [EN]: This property is optional and may not be supported by all projects.
 *       If the project does not support sunset time, this value will be ignored.
 * [CN]: 此属性是可选的，某些项目可能不支持。
 *       如果项目不支持日落时间，此值将被忽略。
 */
@property (nonatomic, assign) NSInteger sunsetMinutesOffset;

/**
 * @brief Maghrib prayer time offset in minutes from midnight
 * @chinese 昏礼(Maghrib)时间相对于午夜的分钟偏移量
 *
 * @discussion
 * [EN]: Number of minutes from 00:00:00 of the day to Maghrib prayer time.
 *       For example, if Maghrib is at 6:20 PM, this value would be 1100 (18 * 60 + 20).
 * [CN]: 从当天00:00:00到昏礼时间的分钟数。
 *       例如，如果昏礼在晚上6:20，此值为1100（18 * 60 + 20）。
 */
@property (nonatomic, assign) NSInteger maghribMinutesOffset;

/**
 * @brief Isha prayer time offset in minutes from midnight
 * @chinese 宵礼(Isha)时间相对于午夜的分钟偏移量
 *
 * @discussion
 * [EN]: Number of minutes from 00:00:00 of the day to Isha prayer time.
 *       For example, if Isha is at 8:00 PM, this value would be 1200 (20 * 60 + 0).
 * [CN]: 从当天00:00:00到宵礼时间的分钟数。
 *       例如，如果宵礼在晚上8:00，此值为1200（20 * 60 + 0）。
 */
@property (nonatomic, assign) NSInteger ishaMinutesOffset;

@end

NS_ASSUME_NONNULL_END
