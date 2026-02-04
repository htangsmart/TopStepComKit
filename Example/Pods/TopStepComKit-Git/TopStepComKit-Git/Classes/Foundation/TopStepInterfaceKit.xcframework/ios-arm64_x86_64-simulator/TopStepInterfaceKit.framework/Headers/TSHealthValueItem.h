//
//  TSHealthValueItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSHealthValueModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Heart rate data type
 * @chinese 心率数据类型
 *
 * @discussion
 * [EN]:
 * - Normal: a raw time-series sample (auto or manual), NOT a derived statistic.
 * - Max/Min: daily extrema derived from that day's normal samples.
 * - Resting: resting HR derived by algorithm over normal samples in rest/sleep windows.
 *
 * [CN]:
 * - 普通(Normal)：原始时序样本（可为自动或手动），不是统计/汇总得到的派生值。
 * - 最大/最小(Max/Min)：从“当日普通数据”中计算出的极值代表点。
 * - 静息(Resting)：算法基于静息/睡眠时段内的“普通数据”计算的静息心率。
 *
 * Note/说明：是否为“自动/手动”由 isUserInitiated 字段独立表示，与本枚举正交。
 */
typedef NS_ENUM(NSUInteger, TSItemValueType) {
    /**
     * @brief Normal raw point (auto or manual)
     * @chinese 普通数据：原始时序点（自动或手动），非派生统计
     */
    TSItemValueTypeNormal  = 0,
    /**
     * @brief Daily maximum derived from normal points of that day
     * @chinese 当日最大值：由当日“普通数据”计算的极值
     */
    TSItemValueTypeMax     = 1,
    /**
     * @brief Daily minimum derived from normal points of that day
     * @chinese 当日最小值：由当日“普通数据”计算的极值
     */
    TSItemValueTypeMin     = 2,
    /**
     * @brief Resting heart rate derived by algorithm
     * @chinese 静息心率：算法基于静息/睡眠区段的“普通数据”计算
     */
    TSItemValueTypeResting = 3,
};


@interface TSHealthValueItem : TSHealthValueModel

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

/**
 * @brief Heart rate value type
 * @chinese 心率数据类型
 *
 * @discussion
 * [EN]: Classifies a sample as Normal raw point, Daily maximum/minimum, or Resting HR.
 * [CN]: 用于区分“普通原始点、当日最大/最小、静息心率”。
 *       是否为自动/手动由 `isUserInitiated` 表示，与本枚举正交。
 */
@property (nonatomic, assign) TSItemValueType valueType;



@end

NS_ASSUME_NONNULL_END
