//
//  TSAutoMonitorConfigs.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Monitor Type Enumeration
 * @chinese 监测类型枚举
 */
typedef NS_ENUM(NSInteger, TSMonitorType) {
    eTSMonitorTypeHeartRate,//心率监测。
    eTSMonitorTypeBloodOxygen,//血氧水平监测。
    eTSMonitorTypeBloodPressure,//血压水平监测。
    eTSMonitorTypeStress,//压力水平监测。
    eTSMonitorTypeTemperature,//血氧水平监测。
    eTSMonitorTypeSleep,//睡眠水平监测。
    eTSMonitorTypeEGC,//心电监测。

    // 其他监测类型可以在这里添加
};

@interface TSAutoMonitorConfigs : NSObject

/**
 * @brief Monitor Type
 * @chinese 监测类型
 *
 * @discussion
 * [EN]: Type of monitoring, such as heart rate, blood oxygen, blood pressure, stress.
 * [CN]: 监测类型，例如心率、血氧、血压、压力。
 */
@property (nonatomic, assign) TSMonitorType monitorType;

/**
 * @brief Is Enabled
 * @chinese 是否开启
 *
 * @discussion
 * [EN]: Indicates whether the monitoring is enabled.
 * [CN]: 表示监测是否启用。
 */
@property (nonatomic, assign) BOOL isEnabled;

/**
 * @brief Start Time
 * @chinese 开始时间
 *
 * @discussion
 * [EN]: Start time in minutes from midnight (e.g., 480 for 8 AM).
 * [CN]: 从零点开始的偏移分钟数（例如，480表示早上8点）。
 *
 * @note
 * [EN]: Valid range is 0-1440 minutes (0:00-24:00).
 * [CN]: 有效范围为0-1440分钟（0:00-24:00）。
 */
@property (nonatomic, assign) UInt16 startTime;

/**
 * @brief End Time
 * @chinese 结束时间
 *
 * @discussion
 * [EN]: End time in minutes from midnight (e.g., 1200 for 8 PM).
 * [CN]: 从零点开始的偏移分钟数（例如，1200表示晚上8点）。
 *
 * @note
 * [EN]: Valid range is 0-1440 minutes (0:00-24:00), must be greater than startTime.
 * [CN]: 有效范围为0-1440分钟（0:00-24:00），必须大于开始时间。
 */
@property (nonatomic, assign) UInt16 endTime;

/**
 * @brief Interval
 * @chinese 时间间隔
 *
 * @discussion
 * [EN]: Interval between monitoring in minutes.
 * [CN]: 监测之间的时间间隔，以分钟为单位。
 */
@property (nonatomic, assign) UInt16 interval;


@end

NS_ASSUME_NONNULL_END
