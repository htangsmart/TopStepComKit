//
//  TSMonitorAlert.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/3.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMonitorAlert : TSKitBaseModel

/**
 * @brief Alert enabled
 * @chinese 是否开启告警
 *
 * @discussion
 * [EN]: Indicates whether alert checking is enabled for the monitor.
 * [CN]: 表示该监测项是否启用告警判定。
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 * @brief Upper threshold
 * @chinese 上限阈值
 *
 * @discussion
 * [EN]: Upper threshold for alert decision. Unit depends on the monitor type:
 *       e.g., percent for SpO2, bpm for heart rate, mmHg for blood pressure.
 * [CN]: 用于告警判定的上限阈值。单位取决于监测类型：
 *       如血氧为百分比、心率为 bpm、血压为 mmHg 等。
 */
@property (nonatomic, assign) UInt16 upperLimit;

/**
 * @brief Lower threshold
 * @chinese 下限阈值
 *
 * @discussion
 * [EN]: Lower threshold for alert decision. Unit depends on the monitor type:
 *       e.g., percent for SpO2, bpm for heart rate, mmHg for blood pressure.
 * [CN]: 用于告警判定的下限阈值。单位取决于监测类型：
 *       如血氧为百分比、心率为 bpm、血压为 mmHg 等。
 */
@property (nonatomic, assign) UInt16 lowerLimit;

@end

NS_ASSUME_NONNULL_END
