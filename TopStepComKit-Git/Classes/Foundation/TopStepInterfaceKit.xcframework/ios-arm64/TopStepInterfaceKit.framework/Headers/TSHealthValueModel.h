//
//  TSHealthValueModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSHealthValueModel : NSObject

/**
 * @brief Start timestamp of the data record
 * @chinese 数据记录的开始时间戳
 *
 * @discussion
 * [EN]: Unix timestamp (in seconds) indicating when this data record started.
 * Used for tracking the beginning of various activities like sleep, exercise, or health measurements.
 *
 * [CN]: Unix时间戳（以秒为单位），表示该数据记录的开始时间。
 * 用于追踪睡眠、运动或健康测量等各种活动的开始时间。
 */
@property (nonatomic, assign) NSTimeInterval startTime;

/**
 * @brief End timestamp of the data record
 * @chinese 数据记录的结束时间戳
 *
 * @discussion
 * [EN]: Unix timestamp (in seconds) indicating when this data record ended.
 * Used in conjunction with startTime to calculate duration and analyze activity patterns.
 *
 * [CN]: Unix时间戳（以秒为单位），表示该数据记录的结束时间。
 * 与startTime一起用于计算持续时间和分析活动模式。
 */
@property (nonatomic, assign) NSTimeInterval endTime;

/**
 * @brief Duration of the data record in seconds
 * @chinese 数据记录的持续时间（秒）
 *
 * @discussion
 * [EN]: The total duration of this data record in seconds.
 * Can be calculated as (endTime - startTime) or directly provided by the device.
 *
 * [CN]: 该数据记录的总持续时间，以秒为单位。
 * 可以通过（结束时间 - 开始时间）计算得出，或由设备直接提供。
 */
@property (nonatomic, assign) double duration;

@end

NS_ASSUME_NONNULL_END
