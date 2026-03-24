//
//  TSKitBaseInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/18.
//

#import "TSKitBaseInterface.h"
#import "TSAppStatusModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief App status management interface
 * @chinese App状态管理接口
 *
 * @discussion
 * [EN]: This interface provides methods to manage and synchronize app status with connected devices.
 *       Use this to notify devices about app state changes and permission updates.
 * [CN]: 此接口提供管理和同步应用状态与连接设备的方法。
 *       使用此接口通知设备应用状态变化和权限更新。
 */
@protocol TSAppStatusInterface <TSKitBaseInterface>

/**
 * @brief Update app status to device
 * @chinese 更新App状态到设备
 *
 * @param appStatus
 * EN: App status model containing current foreground state and permissions
 * CN: 包含当前前台状态和权限信息的App状态模型
 *
 * @param completion
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 *
 * @discussion
 * [EN]: Sends the current app status (foreground state, SMS permission, location permission)
 *       to the connected device. The device can adjust its behavior based on app status.
 *       Call this method when:
 *       - App enters foreground/background
 *       - User grants or denies permissions
 *       - Initial connection to device is established
 *
 * [CN]: 将当前应用状态（前台状态、短信权限、定位权限）发送到已连接的设备。
 *       设备可以根据应用状态调整其行为。
 *       以下情况应调用此方法：
 *       - 应用进入前台/后台时
 *       - 用户授予或拒绝权限时
 *       - 与设备建立初始连接时
 */
- (void)updateAppStatus:(TSAppStatusModel *)appStatus
             completion:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
