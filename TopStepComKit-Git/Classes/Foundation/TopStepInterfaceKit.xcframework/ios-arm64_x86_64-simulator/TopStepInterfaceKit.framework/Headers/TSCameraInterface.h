//
//  TSCameraInterface.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/12.
//  Copyright © 2025 TopStep. All rights reserved.
//

/**
 * @brief Camera Control Interface
 * @chinese 相机控制接口
 * 
 * @discussion 
 * EN: This interface defines the camera control protocol between App and peripheral devices.
 *     It provides methods for camera mode control and photo capture functionality.
 *     Mainly used for implementing remote camera control between App and smart devices (e.g., smartwatches).
 * 
 * CN: 该接口定义了App与外设之间的相机控制协议。
 *     提供相机模式控制和照片拍摄功能的方法。
 *     主要用于实现App与智能设备（如智能手表）之间的远程相机控制功能。
 * 
 * @version 1.0.0
 * EN: Initial version
 *     - Basic camera control functionality
 *     - Remote photo capture support
 *     - Camera mode state management
 * 
 * CN: 初始版本
 *     - 基础相机控制功能
 *     - 远程拍照支持
 *     - 相机模式状态管理
 */

#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Camera event callback
 * @chinese 相机事件回调
 * 
 * @discussion 
 * EN: Generic callback for camera events without parameters
 * CN: 无参数的通用相机事件回调
 */
typedef void (^TSCameraEventBlock)(void);

/**
 * @brief Camera control interface protocol
 * @chinese 相机控制接口协议
 * 
 * @discussion 
 * EN: This protocol defines all interaction methods between App and peripheral device regarding camera control.
 *     Used for implementing remote camera control between App and smart devices (e.g., smartwatches).
 * CN: 该协议定义了App与外设之间关于相机控制的所有交互方法。
 *     主要用于实现App与智能设备（如智能手表）之间的远程相机控制功能。
 */
@protocol TSCameraInterface <TSKitBaseInterface>

/**
 * @brief Notify peripheral device to start camera function
 * @chinese 通知外设启动相机功能
 * 
 * @param completion 
 * EN: Callback when operation is completed
 * CN: 操作完成的回调
 * 
 * @discussion 
 * EN: App notifies peripheral to enter camera mode, peripheral will enter camera control state after receiving the notification
 * CN: App通知外设进入相机模式，外设收到通知后会进入相机控制状态
 */
- (void)notifyPeripheralEnterCameraWithCompletion:(TSCompletionBlock)completion;

/**
 * @brief Notify peripheral device to exit camera function
 * @chinese 通知外设退出相机功能
 * 
 * @param completion 
 * EN: Callback when operation is completed
 * CN: 操作完成的回调
 * 
 * @discussion 
 * EN: App notifies peripheral to exit camera mode, peripheral will exit camera control state after receiving the notification
 * CN: App通知外设退出相机模式，外设收到通知后会退出相机控制状态
 */
- (void)notifyPeripheralExitCameraWithCompletion:(TSCompletionBlock)completion;

/**
 * @brief Register listener for peripheral entering camera mode
 * @chinese 注册外设进入相机模式的监听
 * 
 * @param enterCameraBlock 
 * EN: Callback when peripheral enters camera mode
 * CN: 外设进入相机模式时的回调
 * 
 * @discussion 
 * EN: When peripheral actively enters camera mode, enterCameraBlock will be called
 * CN: 当外设主动进入相机模式时，enterCameraBlock会被调用
 */
- (void)registerPeripheralDidEnterCameraBlock:(nullable TSCameraEventBlock)enterCameraBlock;

/**
 * @brief Register listener for peripheral exiting camera mode
 * @chinese 注册外设退出相机模式的监听
 * 
 * @param exitCameraBlock 
 * EN: Callback when peripheral exits camera mode
 * CN: 外设退出相机模式时的回调
 * 
 * @discussion 
 * EN: When peripheral actively exits camera mode, exitCameraBlock will be called
 * CN: 当外设主动退出相机模式时，exitCameraBlock会被调用
 */
- (void)registerPeripheralDidExitCameraBlock:(nullable TSCameraEventBlock)exitCameraBlock;

/**
 * @brief Register listener for peripheral triggering photo capture
 * @chinese 注册外设触发拍照的监听
 * 
 * @param takePhotoBlock 
 * EN: Callback when peripheral triggers photo capture
 * CN: 外设触发拍照时的回调
 * 
 * @discussion 
 * EN: When peripheral triggers photo capture (e.g., by shaking), takePhotoBlock will be called
 * CN: 当外设触发拍照操作时（如摇一摇），takePhotoBlock会被调用
 */
- (void)registerPeripheralTakePhotoBlock:(nullable TSCameraEventBlock)takePhotoBlock;

@end

NS_ASSUME_NONNULL_END
