//
//  NSDate+Tool.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Tool)

/**
 * @brief Get day start timestamp from given timestamp
 * @chinese 根据给定时间戳获取当天零点时间戳
 *
 * @param timestamp
 * [EN]: Unix timestamp to convert.
 * [CN]: 要转换的Unix时间戳。
 *
 * @return
 * [EN]: Day start timestamp (00:00:00 of the same day).
 * [CN]: 当天零点时间戳（同一天的00:00:00）。
 *
 * @discussion
 * [EN]: This method extracts the date part from the given timestamp and returns
 *        the timestamp for 00:00:00 of that day. Useful for date range queries
 *        and daily data processing.
 * [CN]: 该方法从给定的时间戳中提取日期部分，返回该天00:00:00的时间戳。
 *       适用于日期范围查询和日常数据处理。
 */
+ (NSTimeInterval)getDayStartTimestampFromTimestamp:(NSTimeInterval)timestamp;

/**
 * @brief Get today's start timestamp
 * @chinese 获取今天零点时间戳
 *
 * @return
 * [EN]: Today's start timestamp (00:00:00 of current day).
 * [CN]: 今天零点时间戳（当前天的00:00:00）。
 *
 * @discussion
 * [EN]: Convenience method to get the start timestamp of the current day.
 *        Equivalent to calling getDayStartTimestampFromTimestamp with current time.
 * [CN]: 获取当前天开始时间戳的便捷方法。
 *       等同于使用当前时间调用getDayStartTimestampFromTimestamp方法。
 */
+ (NSTimeInterval)getTodayStartTimestamp;

/**
 * @brief Get current time since 2000 in seconds
 * @chinese 获取当前时间距离2000年始的秒数
 *
 * @return
 * [EN]: Current time since 2000-01-01 00:00:00 UTC in seconds.
 * [CN]: 当前时间距离2000年1月1日00:00:00 UTC的秒数。
 *
 * @discussion
 * [EN]: Returns the number of seconds elapsed since January 1, 2000 00:00:00 UTC.
 *        This is commonly used in TopStep device protocols for time synchronization.
 * [CN]: 返回自2000年1月1日00:00:00 UTC以来经过的秒数。
 *       这通常用于TopStep设备协议中的时间同步。
 */
+ (NSTimeInterval)getCurrentTimeSince2000;

/**
 * @brief Convert Unix timestamp to time since 2000
 * @chinese 将Unix时间戳转换为距离2000年始的秒数
 *
 * @param unixTime
 * [EN]: Unix timestamp to convert (seconds since 1970-01-01 00:00:00 UTC).
 * [CN]: 要转换的Unix时间戳（自1970年1月1日00:00:00 UTC以来的秒数）。
 *
 * @return
 * [EN]: Time since 2000-01-01 00:00:00 UTC in seconds.
 *       Returns 0 if input time is before 2000-01-01 (clamped to minimum valid value).
 * [CN]: 距离2000年1月1日00:00:00 UTC的秒数。
 *       如果输入时间早于2000年1月1日，则返回0（限制为最小有效值）。
 *
 * @discussion
 * [EN]: Converts a standard Unix timestamp (seconds since 1970-01-01) to
 *        TopStep device time format (seconds since 2000-01-01).
 *        This method includes error handling: if the input time is before 2000-01-01,
 *        it returns 0 instead of a negative value to ensure compatibility with
 *        TopStep device protocols.
 * [CN]: 将标准Unix时间戳（自1970年1月1日以来的秒数）转换为
 *       TopStep设备时间格式（自2000年1月1日以来的秒数）。
 *       此方法包含错误处理：如果输入时间早于2000年1月1日，
 *       返回0而不是负值，以确保与TopStep设备协议的兼容性。
 *
 * @note
 * [EN]: Input time before 2000-01-01 will be clamped to 0 (2000-01-01).
 * [CN]: 2000年1月1日之前的输入时间将被限制为0（2000年1月1日）。
 */
+ (NSTimeInterval)convertUnixTimeToTimeSince2000:(NSTimeInterval)unixTime;

/**
 * @brief Convert time since 2000 to Unix timestamp
 * @chinese 将距离2000年始的秒数转换为Unix时间戳
 *
 * @param timeSince2000
 * [EN]: Time since 2000-01-01 00:00:00 UTC in seconds.
 * [CN]: 距离2000年1月1日00:00:00 UTC的秒数。
 *
 * @return
 * [EN]: Unix timestamp (seconds since 1970-01-01 00:00:00 UTC).
 *       Input values less than 0 will be clamped to 0 (2000-01-01).
 * [CN]: Unix时间戳（自1970年1月1日00:00:00 UTC以来的秒数）。
 *       小于0的输入值将被限制为0（2000年1月1日）。
 *
 * @discussion
 * [EN]: Converts TopStep device time format to standard Unix timestamp.
 *        This is the inverse operation of convertUnixTimeToTimeSince2000.
 *        This method includes error handling: if the input is negative,
 *        it returns the timestamp for 2000-01-01 (Unix timestamp 946684800).
 * [CN]: 将TopStep设备时间格式转换为标准Unix时间戳。
 *       这是convertUnixTimeToTimeSince2000的逆操作。
 *       此方法包含错误处理：如果输入为负数，
 *       返回2000年1月1日的时间戳（Unix时间戳946684800）。
 *
 * @note
 * [EN]: Negative input values will be clamped to 0 (2000-01-01).
 * [CN]: 负输入值将被限制为0（2000年1月1日）。
 */
+ (NSTimeInterval)convertTimeSince2000ToUnixTime:(NSTimeInterval)timeSince2000;

/**
 * @brief Get time since 2000 from NSDate
 * @chinese 从NSDate获取距离2000年始的秒数
 *
 * @param date
 * [EN]: NSDate object to convert.
 * [CN]: 要转换的NSDate对象。
 *
 * @return
 * [EN]: Time since 2000-01-01 00:00:00 UTC in seconds.
 * [CN]: 距离2000年1月1日00:00:00 UTC的秒数。
 *
 * @discussion
 * [EN]: Converts an NSDate object to TopStep device time format.
 *        Useful when working with NSDate objects in TopStep protocols.
 * [CN]: 将NSDate对象转换为TopStep设备时间格式。
 *       在处理TopStep协议中的NSDate对象时很有用。
 */
+ (NSTimeInterval)getTimeSince2000FromDate:(NSDate *)date;

/**
 * @brief Create NSDate from time since 2000
 * @chinese 从距离2000年始的秒数创建NSDate对象
 *
 * @param timeSince2000
 * [EN]: Time since 2000-01-01 00:00:00 UTC in seconds.
 * [CN]: 距离2000年1月1日00:00:00 UTC的秒数。
 *
 * @return
 * [EN]: NSDate object representing the converted time.
 * [CN]: 表示转换后时间的NSDate对象。
 *
 * @discussion
 * [EN]: Creates an NSDate object from TopStep device time format.
 *        This is the inverse operation of getTimeSince2000FromDate.
 * [CN]: 从TopStep设备时间格式创建NSDate对象。
 *       这是getTimeSince2000FromDate的逆操作。
 */
+ (NSDate *)dateFromTimeSince2000:(NSTimeInterval)timeSince2000;

/**
 * @brief Get formatted time string from timestamp
 * @chinese 从时间戳获取格式化的时间字符串
 *
 * @param timestamp
 * [EN]: Unix timestamp to format.
 * [CN]: 要格式化的Unix时间戳。
 *
 * @param format
 * [EN]: Date format string (e.g., @"yyyy-MM-dd HH:mm:ss").
 * [CN]: 日期格式字符串（例如：@"yyyy-MM-dd HH:mm:ss"）。
 *
 * @return
 * [EN]: Formatted time string.
 * [CN]: 格式化的时间字符串。
 *
 * @discussion
 * [EN]: Converts a Unix timestamp to a formatted string using the specified format.
 *        Uses local timezone for formatting.
 * [CN]: 使用指定格式将Unix时间戳转换为格式化字符串。
 *       使用本地时区进行格式化。
 */
+ (NSString *)getFormattedTimeStringFromTimestamp:(NSTimeInterval)timestamp withFormat:(NSString *)format;

/**
 * @brief Get start time string from timestamp (YYYY-MM-DD HH:MM:SS)
 * @chinese 从时间戳获取开始时间字符串 (YYYY-MM-DD HH:MM:SS)
 *
 * @param timestamp
 * [EN]: Unix timestamp to convert.
 * [CN]: 要转换的Unix时间戳。
 *
 * @return
 * [EN]: Start time string in format "YYYY-MM-DD HH:MM:SS".
 * [CN]: 格式为"YYYY-MM-DD HH:MM:SS"的开始时间字符串。
 */
+ (NSString *)getStartTimeStringFromTimestamp:(NSTimeInterval)timestamp;

/**
 * @brief Get day string from timestamp (YYYY-MM-DD)
 * @chinese 从时间戳获取日期字符串 (YYYY-MM-DD)
 *
 * @param timestamp
 * [EN]: Unix timestamp to convert.
 * [CN]: 要转换的Unix时间戳。
 *
 * @return
 * [EN]: Day string in format "YYYY-MM-DD".
 * [CN]: 格式为"YYYY-MM-DD"的日期字符串。
 */
+ (NSString *)getDayStringFromTimestamp:(NSTimeInterval)timestamp;

@end

NS_ASSUME_NONNULL_END
