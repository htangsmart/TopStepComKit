//
//  TSRemoteControlInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Device remote control interface
 * @chinese 设备远程控制接口
 * 
 * @discussion 
 * EN: This interface defines basic remote control operations for the device
 * CN: 该接口定义了设备的基本远程控制操作
 */
@protocol TSRemoteControlInterface <TSKitBaseInterface>

/**
 * @brief Restart the device
 * @chinese 重启设备
 * 
 * @param completion 
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调
 *     - success: 操作是否成功
 *     - error: 操作失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: This method sends a restart command to the device.
 *     The device must be connected via Bluetooth.
 *     After successful execution, the device will restart and temporarily disconnect.
 * CN: 此方法向设备发送重启命令。
 *     设备必须通过蓝牙连接。
 *     执行成功后，设备将重启并暂时断开连接。
 */
- (void)restartDevice:(TSCompletionBlock)completion;

/**
 * @brief Power off the device
 * @chinese 关闭设备电源
 * 
 * @param completion 
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调
 *     - success: 操作是否成功
 *     - error: 操作失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: This method sends a power off command to the device.
 *     The device must be connected via Bluetooth.
 *     After successful execution, the device will disconnect.
 * CN: 此方法向设备发送关机命令。
 *     设备必须通过蓝牙连接。
 *     执行成功后，设备将断开连接。
 */
- (void)shutdownDevice:(TSCompletionBlock)completion;

/**
 * @brief Reset device to factory settings
 * @chinese 将设备恢复出厂设置
 * 
 * @param completion 
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调
 *     - success: 操作是否成功
 *     - error: 操作失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: This method resets the device to factory settings.
 *     All user data and settings will be cleared.
 *     After successful execution, the device will restart and disconnect.
 *     This operation cannot be undone.
 * CN: 此方法将设备重置为出厂设置。
 *     所有用户数据和设置将被清除。
 *     执行成功后，设备将重启并断开连接。
 *     此操作无法撤销。
 */
- (void)factoryResetDevice:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
