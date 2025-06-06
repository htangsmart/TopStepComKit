//
//  TSBatteryInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import "TSBatteryModel.h"
#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Battery operation callback
 * @chinese 电池操作回调
 *
 * @param batteryModel
 * EN: Battery information model containing level and charging status
 * CN: 包含电量和充电状态的电池信息模型
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 操作失败时的错误信息，成功时为nil
 */
typedef void (^TSBatteryBlock)(TSBatteryModel *_Nullable batteryModel, NSError *_Nullable error);

/**
 * @brief Battery management interface
 * @chinese 电池管理接口
 *
 * @discussion
 * EN: This interface defines all operations related to device battery, including:
 *     1. Get battery information (level and charging status)
 *     2. Monitor battery information changes
 * CN: 该接口定义了与设备电池相关的所有操作，包括：
 *     1. 获取电池信息（电量和充电状态）
 *     2. 监听电池信息变化
 */
@protocol TSBatteryInterface <TSKitBaseInterface>

/**
 * @brief Get current battery information
 * @chinese 获取当前电池信息
 *
 * @param completion
 * EN: Completion callback
 *     - batteryModel: Battery information model containing level and charging status
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - batteryModel: 包含电量和充电状态的电池信息模型
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: Retrieve current battery information from the device.
 *     The model contains battery percentage (0-100) and charging status.
 * CN: 从设备获取当前电池信息。
 *     模型包含电池电量百分比（0-100）和充电状态。
 */
- (void)requestBatteryInformationCompletion:(nullable TSBatteryBlock)completion;

/**
 * @brief Register battery information change listener
 * @chinese 注册电池信息变化监听
 *
 * @param completion
 * EN: Callback when battery information changes
 *     - batteryModel: Updated battery information model containing level and charging status
 *     - error: Error information if failed, nil if successful
 * CN: 电池信息变化时的回调
 *     - batteryModel: 更新后的电池信息模型，包含电量和充电状态
 *     - error: 监听失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This callback will be triggered when the device battery information changes.
 *     The model contains battery percentage (0-100) and charging status.
 * CN: 当设备电池信息发生变化时，此回调会被触发。
 *     模型包含电池电量百分比（0-100）和充电状态。
 */
- (void)registerBatteryDidChanged:(nullable TSBatteryBlock)completion;

@end

NS_ASSUME_NONNULL_END
