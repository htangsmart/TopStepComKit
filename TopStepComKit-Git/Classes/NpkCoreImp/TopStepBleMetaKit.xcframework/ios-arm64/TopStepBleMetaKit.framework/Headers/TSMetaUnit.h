//
//  TSMetaUnit.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/8/28.
//

#import "TSBusinessBase.h"
#import "PbConfigParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unit configuration manager
 * @chinese 单位配置管理类
 */
@interface TSMetaUnit : TSBusinessBase

/**
 * @brief Set unit configuration
 * @chinese 设置单位配置信息
 *
 * @param config 
 * EN: Unit configuration message (flags bytes indicate metric/imperial, Celsius/Fahrenheit)
 * CN: 单位配置模型（flags 标志位表示公制/英制、摄氏/华氏）
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)setUnitConfig:(TSMetaUnitModel *)config completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Get unit configuration flags
 * @chinese 获取单位配置的 flags 原始字节
 *
 * @param completion 
 * EN: Completion callback with flags bytes and error
 * CN: 完成回调，返回 flags 原始字节与错误信息
 */
+ (void)getUnitConfig:(void(^)(NSData * _Nullable flags, NSError * _Nullable error))completion;

/**
 * @brief Register unit configuration change notification
 * @chinese 注册单位配置变更通知（返回 flags 原始字节）
 *
 * @param completion 
 * EN: Callback invoked when unit configuration changes; returns latest flags and error if any
 * CN: 当单位配置变化时触发回调；返回最新 flags 及错误
 */
+ (void)registerUnitConfigDidChanged:(void(^)(NSData * _Nullable flags, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END


