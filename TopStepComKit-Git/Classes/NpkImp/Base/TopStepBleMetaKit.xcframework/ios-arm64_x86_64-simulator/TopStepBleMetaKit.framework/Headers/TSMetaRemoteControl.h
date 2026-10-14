//
//  TSMetaRemoteControl.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/29.
//

#import "TSBusinessBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaRemoteControl : TSBusinessBase

/**
 * @brief Shutdown the device
 * @chinese 关机
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)shutdownDevice:(TSMetaCompletionBlock)completion;

/**
 * @brief Restart the device
 * @chinese 重启设备
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)restartDevice:(TSMetaCompletionBlock)completion;

/**
 * @brief Factory reset the device
 * @chinese 恢复出厂设置
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)factoryReset:(TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
