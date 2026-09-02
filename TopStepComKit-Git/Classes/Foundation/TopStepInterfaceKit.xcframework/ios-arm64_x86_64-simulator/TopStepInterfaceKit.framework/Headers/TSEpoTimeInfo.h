//
//  TSEpoTimeInfo.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/9.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief EPO time info model
 * @chinese EPO 时间信息模型
 *
 * @discussion
 * [EN]: The EPO time info queried from the device. Mainly for debugging.
 *       Each time is exposed both as a UTC timestamp(seconds) and an NSDate.
 * [CN]: 从设备查询到的 EPO 时间信息，主要用于调试。
 *       每个时间同时提供 UTC 时间戳(秒) 与 NSDate 两种形式。
 */
@interface TSEpoTimeInfo : TSKitBaseModel

/**
 * @brief Valid deadline timestamp (UTC seconds)
 * @chinese 星历有效截止时间戳（UTC 秒）
 *
 * @discussion
 * [EN]: The EPO data on device is valid before this time.
 * [CN]: 设备上的 EPO 星历在此时间之前有效。
 */
@property (nonatomic, assign, readonly) NSTimeInterval validTimestamp;

/**
 * @brief Valid deadline date
 * @chinese 星历有效截止时间
 *
 * @discussion
 * [EN]: Convenience NSDate converted from [validTimestamp](UTC seconds since 1970).
 * [CN]: 由 [validTimestamp](UTC 1970 起的秒数) 换算而来的便捷 NSDate。
 */
@property (nonatomic, strong, readonly) NSDate *validDate;

/**
 * @brief Last update timestamp (UTC seconds)
 * @chinese 上次更新时间戳（UTC 秒）
 */
@property (nonatomic, assign, readonly) NSTimeInterval updateTimestamp;

/**
 * @brief Last update date
 * @chinese 上次更新时间
 *
 * @discussion
 * [EN]: Convenience NSDate converted from [updateTimestamp](UTC seconds since 1970).
 * [CN]: 由 [updateTimestamp](UTC 1970 起的秒数) 换算而来的便捷 NSDate。
 */
@property (nonatomic, strong, readonly) NSDate *updateDate;

/**
 * @brief Create an EPO time info model
 * @chinese 创建 EPO 时间信息模型
 *
 * @param validTimestamp
 * EN: Valid deadline timestamp in UTC seconds
 * CN: 有效截止时间戳（UTC 秒）
 *
 * @param updateTimestamp
 * EN: Last update timestamp in UTC seconds
 * CN: 上次更新时间戳（UTC 秒）
 *
 * @return
 * EN: A configured EPO time info instance
 * CN: 配置好的 EPO 时间信息实例
 */
+ (instancetype)infoWithValidTimestamp:(NSTimeInterval)validTimestamp
                       updateTimestamp:(NSTimeInterval)updateTimestamp;

@end

NS_ASSUME_NONNULL_END
