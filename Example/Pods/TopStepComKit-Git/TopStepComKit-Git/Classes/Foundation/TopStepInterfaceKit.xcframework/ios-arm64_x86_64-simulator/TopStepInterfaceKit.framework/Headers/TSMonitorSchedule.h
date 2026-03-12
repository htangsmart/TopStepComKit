//
//  TSMonitorSchedule.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/3.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMonitorSchedule : TSKitBaseModel

/**
 * @brief Is Enabled
 * @chinese 是否开启
 *
 * @discussion
 * [EN]: Indicates whether the monitoring is enabled.
 * [CN]: 表示监测是否启用。
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

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
 * [EN]: Interval between monitoring in minutes. Must be a multiple of 5 (5, 10, 15, 20, etc.).
 * [CN]: 监测之间的时间间隔，以分钟为单位。必须是5的倍数（5、10、15、20等）。
 *
 * @note
 * [EN]: Valid values are multiples of 5 minutes (5, 10, 15, 20, 25, 30, etc.).
 * [CN]: 有效值必须是5分钟的倍数（5、10、15、20、25、30等）。
 */
@property (nonatomic, assign) UInt16 interval;



@end

NS_ASSUME_NONNULL_END
