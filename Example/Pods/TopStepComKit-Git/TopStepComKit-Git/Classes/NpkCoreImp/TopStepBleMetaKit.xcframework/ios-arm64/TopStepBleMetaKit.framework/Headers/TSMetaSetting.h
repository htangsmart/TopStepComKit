//
//  TSMetaSetting.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/8/28.
//

#import "TSBusinessBase.h"
#import "PbConfigParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaSetting : TSBusinessBase

/**
 * @brief Set function configuration
 * @chinese 设置功能配置
 *
 * @param config 
 * EN: Function configuration message (e.g., flags bytes)
 * CN: 功能配置消息（如标志位字节）
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)setFunctionConfig:(TSMetaFunctionModel *)config completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Get function configuration
 * @chinese 获取功能配置
 *
 * @param completion 
 * EN: Completion callback with function configuration and error
 * CN: 完成回调，包含功能配置与错误信息
 */
+ (void)getFunctionConfig:(void(^)(TSMetaFunctionModel * _Nullable config, NSError * _Nullable error))completion;

/**
 * @brief Set DND (Do Not Disturb) configuration
 * @chinese 设置勿扰模式配置
 *
 * @param config 
 * EN: DND configuration message containing enable state, mode, and time period
 * CN: 勿扰配置消息，包含启用状态、模式和时间段
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)setDndConfig:(TSMetaDndModel *)config completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Get DND (Do Not Disturb) configuration
 * @chinese 获取勿扰模式配置
 *
 * @param completion 
 * EN: Completion callback with DND configuration and error
 * CN: 完成回调，包含勿扰配置与错误信息
 */
+ (void)getDndConfig:(void(^)(TSMetaDndModel * _Nullable config, NSError * _Nullable error))completion;

/**
 * @brief Register DND (Do Not Disturb) configuration change notification
 * @chinese 注册勿扰配置变化通知
 *
 * @param completion
 * EN: Completion callback with updated DND configuration and error
 * CN: 完成回调，返回变更后的勿扰配置与错误信息
 */
+ (void)registerDndConfigDidChange:(void(^)(TSMetaDndModel * _Nullable config, NSError * _Nullable error))completion;

/**
 * @brief Set raise to wake configuration
 * @chinese 设置抬腕亮屏配置
 *
 * @param config 
 * EN: Raise to wake configuration message containing enable state and time period
 * CN: 抬腕亮屏配置消息，包含启用状态和时间段
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)setRaiseWakeupConfig:(TSMetaRaiseWakeupModel *)config completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Get raise to wake configuration
 * @chinese 获取抬腕亮屏配置
 *
 * @param completion 
 * EN: Completion callback with raise to wake configuration and error
 * CN: 完成回调，包含抬腕亮屏配置与错误信息
 */
+ (void)getRaiseWakeupConfig:(void(^)(TSMetaRaiseWakeupModel * _Nullable config, NSError * _Nullable error))completion;

/**
 * @brief Register raise to wake configuration change notification
 * @chinese 注册抬腕亮屏配置变化通知
 *
 * @param completion
 * EN: Completion callback with updated raise to wake configuration and error
 * CN: 完成回调，返回变更后的抬腕亮屏配置与错误信息
 */
+ (void)registerRaiseWakeupConfigDidChange:(void(^)(TSMetaRaiseWakeupModel * _Nullable config, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END


