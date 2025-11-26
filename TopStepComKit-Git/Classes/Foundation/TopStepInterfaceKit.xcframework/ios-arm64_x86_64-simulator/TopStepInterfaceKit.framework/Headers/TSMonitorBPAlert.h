//
//  TSMonitorBPAlert.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/3.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMonitorBPAlert : TSKitBaseModel

/**
 * @brief Blood pressure alert enabled
 * @chinese 血压告警是否开启
 *
 * @discussion
 * [EN]: Indicates whether blood pressure alert checking is enabled.
 * [CN]: 表示是否启用血压告警判定。
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 * @brief Systolic blood pressure upper threshold
 * @chinese 收缩压上限阈值
 *
 * @discussion
 * [EN]: Upper threshold for systolic blood pressure alert in mmHg.
 * [CN]: 收缩压告警的上限阈值，单位：毫米汞柱（mmHg）。
 */
@property (nonatomic, assign) UInt8 systolicUpperLimit;

/**
 * @brief Systolic blood pressure lower threshold
 * @chinese 收缩压下限阈值
 *
 * @discussion
 * [EN]: Lower threshold for systolic blood pressure alert in mmHg.
 * [CN]: 收缩压告警的下限阈值，单位：毫米汞柱（mmHg）。
 */
@property (nonatomic, assign) UInt8 systolicLowerLimit;

/**
 * @brief Diastolic blood pressure upper threshold
 * @chinese 舒张压上限阈值
 *
 * @discussion
 * [EN]: Upper threshold for diastolic blood pressure alert in mmHg.
 * [CN]: 舒张压告警的上限阈值，单位：毫米汞柱（mmHg）。
 */
@property (nonatomic, assign) UInt8 diastolicUpperLimit;

/**
 * @brief Diastolic blood pressure lower threshold
 * @chinese 舒张压下限阈值
 *
 * @discussion
 * [EN]: Lower threshold for diastolic blood pressure alert in mmHg.
 * [CN]: 舒张压告警的下限阈值，单位：毫米汞柱（mmHg）。
 */
@property (nonatomic, assign) UInt8 diastolicLowerLimit;

@end

NS_ASSUME_NONNULL_END
