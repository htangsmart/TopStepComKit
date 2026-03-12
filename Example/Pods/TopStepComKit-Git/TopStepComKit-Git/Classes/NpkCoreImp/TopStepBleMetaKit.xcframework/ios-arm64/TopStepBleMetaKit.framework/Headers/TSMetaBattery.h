//
//  TSMetaBattery.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import "TSBusinessBase.h"
#import "PbConnectParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Battery management class
 * @chinese 电池管理类
 */
@interface TSMetaBattery : TSBusinessBase

/**
 * @brief Register battery change callback
 * @chinese 注册电池状态变化回调
 *
 * @param completion 
 * EN: Callback invoked when battery info changes; returns latest battery info and error if any
 * CN: 当电池信息变化时触发回调；返回最新电池信息及错误
 *
 * @discussion
 * [EN]: Listen for battery level (1-100) and charging status changes in real time.
 * [CN]: 实时监听电量（1-100）与充电状态的变化。
 */
+(void)registerBatteryDidChanged:(void(^)(TSMetaBatteryModel * _Nullable batteryInfo, NSError * _Nullable error))completion;


/**
 * @brief Get battery information
 * @chinese 获取电池信息
 *
 * @param completion 
 * EN: Completion callback with battery information and error
 * CN: 完成回调，包含电池信息和错误信息
 *
 * @discussion
 * [EN]: Returns battery level (1-100) and charging status
 * [CN]: 返回电池电量（1-100）和充电状态
 */
+ (void)getBatteryInfo:(void(^)(TSMetaBatteryModel * _Nullable batteryInfo, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
